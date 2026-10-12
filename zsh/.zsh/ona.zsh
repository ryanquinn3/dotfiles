# ona (formerly gitpod) environment helpers. The CLI is `ona`; the SSH host
# suffix is still `<id>.gitpod.environment` (matched by ~/.ssh/gitpod/config,
# whose ProxyCommand drives the connection), so that literal stays as-is.
# check if interactive shell before doing completions

[[ -o interactive ]] && gen_completion ona


_ona_refresh_cache() { bkt --warm --ttl 1d -- ona env list -o json >/dev/null; }

# An ssh that exits nonzero this quickly failed during connection setup rather
# than after a usable remote session.
typeset -gi _ONA_CONNECT_MIN=10

# Runs inside the temporary local ona-<name> tmux session.
_ona_connect() {
  local id=${1:-$ONA_ID}
  local session=${ONA_SESSION:?Ona tmux session name required}
  local host="${id}.gitpod.environment"

  while true; do
    if [[ $(ona env get "$id" -f phase) != "running" ]]; then
      gum spin --spinner dot --title "Starting $id" -- ona env start "$id"
    fi

    echo "Connecting to ${host}..."
    local start=$(date +%s)
    ssh -tt \
      -o ServerAliveInterval=15 \
      -o ServerAliveCountMax=3 \
      -o ConnectTimeout=5 \
      "$host" "tmux new-session -A -s main"
    local ec=$? elapsed=$(( $(date +%s) - start ))

    (( ec == 0 )) && break

    if (( elapsed < _ONA_CONNECT_MIN )); then
      print -ru2 -- $'\nCould not connect to '"${host}"$' (ssh exited '"$ec"$' in '"${elapsed}"$'s).\nFix the error above, then close this window or reconnect.'
      _ona_refresh_cache
      tmux set-option -u @is_remote 2>/dev/null
      exec zsh
    fi

    if [[ $(ona env get "$id" -f phase) == "running" ]]; then
      print -ru2 -- $'\nlink dropped after '"${elapsed}"$'s, env still up; reconnecting...'
      sleep 2
      continue
    fi
    break
  done

  _ona_refresh_cache
  tmux switch-client -t "=$ONA_ORIGIN" 2>/dev/null || tmux switch-client -l 2>/dev/null
  tmux kill-session -t "=$session"
}

_ona_launch() {
  local id=${1:?environment id required}
  local name=$2
  local origin

  if [[ -z "$name" ]]; then
    name=$(ona env get "$id" -f name) || return 1
  fi
  # Fall back for unnamed environments; tmux disallows dots and colons.
  name=${name:-${id%%-*}}
  local session="ona-${name//[.:]/_}"

  if tmux has-session -t "=$session" 2>/dev/null; then
    tmux switch-client -t "=$session"
    return
  fi

  origin=$(tmux display-message -p '#{session_name}')
  tmux new-session -d -s "$session" -e "ONA_ID=$id" -e "ONA_ORIGIN=$origin" \
    -e "ONA_SESSION=$session" \
    'zsh -c "source ~/.zsh/ona.zsh && _ona_connect"' || return 1
  tmux set-option -t "=$session" @is_remote 1
  tmux set-option -t "=$session" @icon '󰞶'
  tmux switch-client -t "=$session"
  _ona_refresh_cache
}



alias -g oep="tv ona"

ona_ssh() {
  local env_id host
  env_id=$(oep) || return 1

  if [[ $(ona env get $env_id -f phase) != "running" ]]; then
    gum spin --spinner dot --title "Starting ona environment" -- ona env start $env_id
  fi

  host="${env_id}.gitpod.environment"
  echo "Connecting to ${host}..."
  # Connect via SSH and attach to main tmux session
  ssh -tt "${host}" "tmux new-session -A -s main"
  # When ssh session ends, disable mouse reporting so that terminal behaves correctly
  local ec=$?
  [[ -t 1 ]] && print -n -- $'\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1015l'
  return $ec
}

# Select an ona env and delete it
ona_delete() {
  local env_id="${1:-$(oep)}"
  [[ -n "$env_id" ]] || { echo "No ona environment selected." >&2; return 1; }
  echo "Deleting ona environment $env_id..."
  ona environment delete $env_id
  _ona_refresh_cache
}

ona_stop(){
  local env_id="${1:-$(oep)}"
  [[ -n "$env_id" ]] || { echo "No ona environment selected." >&2; return 1; }
  ona environment stop "$env_id"
  _ona_refresh_cache
}

# A custom postStart hook. Run only on ona machines
ona_bootstrap() {
  if [[ $OSTYPE == 'darwin'* ]]; then
    echo "ona_bootstrap does not run on macOS. Skipping..."
    return 0
  fi
  echo "Setting up efs symlinks"
  setup-efs

  echo "Restoring dev workspace"
  dev-workspace-pull

  echo "Restoring brew prefix"
  brew-prefix-restore

  echo "Running brew bundle"
  time_start=$(date +%s)
  # Don't upgrade already-installed formulae during bootstrap; just install
  # what's missing. Scoped to this call only, not exported globally.
  HOMEBREW_BUNDLE_NO_UPGRADE=1 install-apps
  time_end=$(date +%s)
  echo "Brew bundle completed in $((time_end - time_start)) seconds"
  npm install -g --ignore-scripts @earendil-works/pi-coding-agent
  echo "Restoring git ignore"
  cat ~/.config/git/ignore > .git/info/exclude
}

ona_create(){
  if [[ -z "$ONA_PROJECT_ID" || -z "$ONA_CLASS_ID" ]]; then
    echo "ONA_PROJECT_ID and ONA_CLASS_ID must be set to create an environment."
    return 1
  fi
  ona environment create $ONA_PROJECT_ID \
    --class-id $ONA_CLASS_ID \
    --set-as-context \
    --inactivity-timeout 8h \
    --name "$(random-name)" \
    --logs
  echo "Created and set new environment as context: $(ona env get -f id). Installing brew".
  ona environment ssh $(ona env get -f id) -- -t 'zsh -ic "ona_bootstrap"'
  _ona_refresh_cache
}
