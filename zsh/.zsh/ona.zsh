# ona (formerly gitpod) environment helpers. The CLI is `ona`; the SSH host
# suffix is still `<id>.gitpod.environment` (matched by ~/.ssh/gitpod/config,
# whose ProxyCommand drives the connection), so that literal stays as-is.
# check if interactive shell before doing completions

[[ -o interactive ]] && gen_completion ona


# Cache path for `ona env list` (SWR machinery lives below the emit guard).
# Defined up here so the launch/disconnect helpers can invalidate it: both events
# change an env's phase, so dropping the cache forces a fresh fetch (and accurate
# stopped/running state) on the next picker open.
typeset -g _ONA_CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/launcher-ona.json
_ona_clear_cache() { rm -f "$_ONA_CACHE"; }


# fzf-pick an ona environment. Preview shows `ona env get` for the highlighted
# row; the selected environment id is printed to stdout (so it composes:
# `ona_set_env "$(ona_pick)"`, `ssh "$(ona_pick).gitpod.environment"`, ...).
ona_pick() {
  local rows cache
  rows=$(ona env list -o json | jq -r '
    .[] | [
      .id,
      .id[0:8],
      .metadata.name // "[none]",
      ( .status.phase // "" | sub("ENVIRONMENT_PHASE_"; "") | ascii_downcase ),
      ( .status.content.git.branch // "?" ),
      ( .status.content.git.cloneUrl // "" | sub("\\.git$"; "") | split("/") | last ),
      ( .metadata.createdAt // "" )[0:10],
      ( .metadata.lastStartedAt // "" )[0:10]
    ] | join(",")') || return
  [[ -n $rows ]] || { echo "No ona environments." >&2; return 1; }

  # Per-session preview cache: `ona env get` is a network call, so memoize each
  # id to a tempdir for the life of the picker (cursoring back is then a `cat`,
  # not a refetch). $ONA_PREVIEW_CACHE is read by the preview subshell.
  cache=$(mktemp -d) || return
  export ONA_PREVIEW_CACHE=$cache

  # Prepend a header row and render the whole table with `gum table -p` so the
  # sticky header lines up with the data. `gum table` pads with all-whitespace
  # lines (top, bottom, and between header and rows); grep drops them so
  # --header-lines=1 lands on the real header instead of a blank line. Then
  # --with-nth='2..' hides col 1 (id) from the header and rows; id stays field
  # {1} for the preview, and `awk` pulls it back out of the selected row.
  print -r -- "id,id,name,phase,branch,repo,created,started"$'\n'"$rows" \
   | column -t -s, \
    | fzf  \
          --ansi \
          --header-lines=1 \
          --with-nth='2..' \
          --preview 'f="$ONA_PREVIEW_CACHE"/{1}; [ -f "$f" ] || ona env get {1} >"$f" 2>&1; cat "$f"' \
          --border=rounded \
          --layout=reverse \
          --info=inline \
          --preview-window='nohidden,40%,<50(down,50%,border-rounded)' \
    | awk '{ print $1 }' | tee >(pbcopy)

  rm -rf "$cache"; unset ONA_PREVIEW_CACHE
}
alias oep="ona_pick"

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
  ona environment delete $env_id "$@"
  context_env=$(ona env get -f id)
  if [[ "$context_env" == "$env_id" ]]; then
    echo "Deleted environment was the current context. Resetting context to a new environment..."
    ona_reset_context_env "$env_id"
  fi
  _ona_clear_cache
}

ona_stop(){
  local env_id="${1:-$(oep)}"
  [[ -n "$env_id" ]] || { echo "No ona environment selected." >&2; return 1; }
  ona environment stop "$env_id"
  _ona_clear_cache
}

# A custom postStart hook. Run only on ona machines
ona_bootstrap() {
  if [[ $OSTYPE == 'darwin'* ]]; then
    echo "ona_bootstrap does not run on macOS. Skipping..."
    return 0
  fi
  echo "Setting up efs symlinks"
  setup-efs

  echo "Restoring brew prefix"
  brew-prefix-restore

  echo "Running brew bundle"
  time_start=$(date +%s)
  # Don't upgrade already-installed formulae during bootstrap; just install
  # what's missing. Scoped to this call only, not exported globally.
  HOMEBREW_BUNDLE_NO_UPGRADE=1 install-apps
  time_end=$(date +%s)
  echo "Brew bundle completed in $((time_end - time_start)) seconds"
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
    --logs
  echo "Created and set new environment as context: $(ona env get -f id). Install brew".
  ona environment ssh $(ona env get -f id) -- -t 'zsh -ic "ona_bootstrap"'
  _ona_clear_cache
}

# Reset the current ona context to a most recent env. If [env_id] is provided, 
# it will be excluded from the search for a new context. If no other envs are found, an error is returned.
# Usage: ona_reset_context_env [env_id]
ona_reset_context_env() {
  old_env_id=$1
  local new_env_id
  env_ids=$(ona env list -o json | jq -r '.[].id')
  if [[ -z "$old_env_id" ]]; then
    echo "No old environment id provided. Resetting context to the first available environment."
    new_env_id=$(echo "$env_ids" | head -n 1)
  else
    new_env_id=$(echo "$env_ids" | grep -v "$old_env_id" | head -n 1)
  fi
  if [[ -z "$new_env_id" ]]; then
    echo "No ona environments found to reset context."
    return 1
  fi
  echo "Resetting context to ona environment $new_env_id..."
  ona config context modify --current --environment-id $new_env_id
}

ona_set_env() {
  ona_env=$(oep)
  if [[ -z "$ona_env" ]]; then
    echo "No ona environment selected."
    return 1
  fi
  ona config context modify --current --environment-id $ona_env
}
