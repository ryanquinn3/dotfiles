# ona (gitpod) environments -- launcher plugin. Mac-only (lives in the launcher
# package, never stowed on ona/cde).
#
#   enter   -> start the env if stopped, then ssh-attach in a fresh detached
#              local session ona-<short> (stamped @is_remote so tmux.conf drops
#              into dumb-terminal mode on entry)
#   alt     -> stop the env (running only)
#   preview -> gitpod env details
#
# Envs that already have a live local ona-<short> session AND are running are
# skipped: the tmux plugin already lists them, so showing them here would
# duplicate. Only the env id (a UUID, injection-safe) and its short form travel
# in `data`; the core feeds it to the helpers below on stdin.

# Runs INSIDE the spawned ona-<short> window. Reads the env id from $ONA_ID
# (set on the session via `new-session -e`), so nothing is interpolated into a
# command string. Falls back to $1 when called directly.
_ona_connect() {
  local id=${1:-$ONA_ID}
  local host="${id}.gitpod.environment"
  if [[ $(gitpod env get "$id" -f phase) != "running" ]]; then
    gum spin --spinner dot --title "Starting $id" -- gitpod env start "$id"
  fi
  echo "Connecting to ${host}..."
  ssh -tt "$host" "tmux new-session -A -s main"
  # reset mouse reporting the remote session may have left on
  [[ -t 1 ]] && print -n -- $'\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1015l'
  exec zsh   # keep the window alive as a shell after disconnect
}

_ona_launch() {                        # enter
  local d; d=$(jq -c .)
  local id short
  id=$(jq -r .id <<<"$d")
  short=$(jq -r .short <<<"$d")
  # detached local session whose window connects; ONA_ID is read by _ona_connect.
  tmux new-session -d -s "ona-$short" -e "ONA_ID=$id" \
    'zsh -c "source ~/.zsh/launcher.d/ona.zsh && _ona_connect"'
  tmux set-option -t "ona-$short" @is_remote 1   # bare name: set-option rejects =name
  tmux switch-client -t "=ona-$short"            # =name: exact match, accepted here
}

_ona_stop() {                          # alt
  local d; d=$(jq -c .)
  [[ $(jq -r .phase <<<"$d") == running ]] || return 0
  gitpod env stop "$(jq -r .id <<<"$d")"
}

_ona_preview() { gitpod env get "$(jq -r .id)"; }

[[ -n $_LAUNCHER_EMIT ]] || return 0   # re-sourced just for a helper: stop here

# --- stale-while-revalidate cache for `gitpod env list` ----------------------
# `gitpod env list` is a network call and the slowest thing in emit; it blocks
# the picker from appearing. The set of envs and their phases changes rarely, so
# we cache the raw JSON and serve it stale: print the cached copy immediately and
# (if it's older than the TTL) refresh in the background so the NEXT open is
# fresh. Only the slow remote call is cached -- the live tmux-session dedup below
# is always recomputed, so a freshly opened/closed local session is never stale.
typeset -g  _ONA_CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/launcher-ona.json
typeset -gi _ONA_TTL=30                 # seconds before a served cache is refreshed

# One foreground refresh: gitpod -> unique temp -> atomic rename. The temp is
# per-invocation (mktemp) so concurrent refreshes can't clobber a shared file;
# the rename is atomic so a reader never sees a half-written cache.
_ona_refresh() {
  local tmp
  [[ -d ${_ONA_CACHE:h} ]] || mkdir -p "${_ONA_CACHE:h}"
  tmp=$(mktemp "${_ONA_CACHE}.XXXXXX") || return
  if gitpod env list -o json >"$tmp" 2>/dev/null; then
    mv -f "$tmp" "$_ONA_CACHE"
  else
    rm -f "$tmp"
  fi
}

# SWR read: cold start fetches once (we have nothing to show); otherwise print
# the cache and, when stale, kick off a detached background refresh. The
# background subshell redirects its fds off the emit pipe (&>/dev/null </dev/null)
# so it can't hold the pipe open and stall _launcher_render's wait for EOF, and
# is disowned (&!) so it outlives this short-lived emit subshell.
_ona_env_list() {
  if [[ ! -f $_ONA_CACHE ]]; then
    _ona_refresh
  else
    local age=$(( $(date +%s) - $(stat -f %m "$_ONA_CACHE") ))
    (( age >= _ONA_TTL )) && ( _ona_refresh ) </dev/null &>/dev/null &!
  fi
  cat "$_ONA_CACHE" 2>/dev/null
}
# -----------------------------------------------------------------------------

local sh='source ~/.zsh/launcher.d/ona.zsh'
# ona-<short> sessions that already exist locally, as a JSON array, used to drop
# running+bound envs (the tmux plugin already shows them).
local live
live=$(tmux list-sessions -F '#{session_name}' 2>/dev/null \
       | jq -Rsc 'split("\n") | map(select(startswith("ona-")))')

_ona_env_list \
  | jq -c --argjson live "${live:-[]}" \
       --arg enter   "$sh && _ona_launch" \
       --arg alt     "$sh && _ona_stop" \
       --arg preview "$sh && _ona_preview" '
      .[]
      | { id:     .id,
          short:  ( .id | split("-")[0] ),
          phase:  ( .status.phase // "" | sub("ENVIRONMENT_PHASE_"; "") | ascii_downcase ),
          branch: ( .status.content.git.branch // "?" ),
          repo:   ( .status.content.git.cloneUrl // "" | sub("\\.git$"; "") | split("/") | last ) }
      | select( ( .phase == "running" and ( .short as $s | $live | index("ona-" + $s) ) ) | not )
      | { display: { icon: "\uf0c2", color: 35, cols: [ .branch, .phase, .repo ], tail: "" },
          data:    { id: .id, short: .short, phase: .phase },
          enter: $enter, alt: $alt, preview: $preview }'
