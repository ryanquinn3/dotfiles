# ona (formerly gitpod) environment helpers. The CLI is `ona`; the SSH host
# suffix is still `<id>.gitpod.environment` (matched by ~/.ssh/gitpod/config,
# whose ProxyCommand drives the connection), so that literal stays as-is.

gen_completion ona

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

ona_stop(){
  ona environment stop $(oep)
}

ona_bootstrap() {
  echo "Setting up efs symlinks"
  ./setup-efs

  echo "Restoring brew cellar"
  brew-cellar-restore

  echo "Running brew bundle"
  time_start=$(date +%s)
  ./install-apps
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
    --inactivity-timeout 8h
  echo "Created and set new environment as context: $(ona env get -f id). Install brew".
  ona environment ssh $(ona env get -f id) -- -t 'zsh -ic "ona_bootstrap"'
}

ona_set_env() {
  ona_env=$(oep)
  if [[ -z "$ona_env" ]]; then
    echo "No ona environment selected."
    return 1
  fi
  ona config context modify default --environment-id $ona_env
}
