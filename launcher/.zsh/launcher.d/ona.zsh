# ona (gitpod) environments -- launcher plugin. Mac-only (lives in the launcher
# package, never stowed on ona/cde).
#
#   enter   -> start the env if stopped, then ssh-attach in a fresh detached
#              local session ona-<short> (stamped @is_remote so tmux.conf drops
#              into dumb-terminal mode on entry). On disconnect (instance stop,
#              clean detach, or dropped link) the session tears itself down and
#              hops the client back to where it launched from -- no bare shell.
#   alt     -> stop the env (running only)
#   preview -> ona env details
#
# Envs that already have a live local ona-<short> session AND are running are
# skipped: the tmux plugin already lists them, so showing them here would
# duplicate. Only the env id (a UUID, injection-safe) and its short form travel
# in `data`; the core feeds it to the helpers below on stdin.

# Cache path for `ona env list` (SWR machinery lives below the emit guard).
# Defined up here so the launch/disconnect helpers can invalidate it: both events
# change an env's phase, so dropping the cache forces a fresh fetch (and accurate
# stopped/running state) on the next picker open.
typeset -g _ONA_CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/launcher-ona.json
_ona_clear_cache() { rm -f "$_ONA_CACHE"; }

# An ssh that exits nonzero in under this many seconds never made it past the
# ProxyCommand/auth (e.g. expired token in ~/.ssh/gitpod) -- a "failed to
# connect", not a real session that later dropped. Used by _ona_connect to keep
# the window (and the error) on screen instead of tearing down and bouncing.
typeset -gi _ONA_CONNECT_MIN=10

# Runs INSIDE the spawned ona-<short> window. Reads the env id from $ONA_ID
# (set on the session via `new-session -e`), so nothing is interpolated into a
# command string. Falls back to $1 when called directly.
_ona_connect() {
  local id=${1:-$ONA_ID}
  local host="${id}.gitpod.environment"
  if [[ $(ona env get "$id" -f phase) != "running" ]]; then
    gum spin --spinner dot --title "Starting $id" -- ona env start "$id"
  fi
  echo "Connecting to ${host}..."
  local start=$(date +%s)
  ssh -tt "$host" "tmux new-session -A -s main"
  local ec=$? elapsed=$(( $(date +%s) - start ))
  # reset mouse reporting the remote session may have left on
  [[ -t 1 ]] && print -n -- $'\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1015l'

  # Did we ever connect? A clean tmux detach exits 0; a real session that later
  # drops (laptop lid, dead link) exits nonzero but only after being alive a
  # while. An ssh that dies nonzero within _ONA_CONNECT_MIN never got past the
  # ProxyCommand/auth -- DON'T tear down: keep this window so the error stays on
  # screen and the user can fix it (commonly a stale token: `gitpod login
  # --gitpod-config-dir ~/.ssh/gitpod`) and relaunch, instead of being bounced
  # back with no clue why. @is_remote is unset so the lingering shell behaves
  # normally rather than staying in dumb-terminal mode.
  if (( ec != 0 && elapsed < _ONA_CONNECT_MIN )); then
    print -ru2 -- $'\nCould not connect to '"${host}"$' (ssh exited '"$ec"$' in '"${elapsed}"$'s).\nFix the error above, then close this window or reconnect.'
    _ona_clear_cache
    tmux set-option -u @is_remote 2>/dev/null
    exec zsh
  fi

  # Connected, then the session ended (clean detach, instance stop, or dropped
  # link): tear this throwaway session down instead of stranding a bare shell.
  # Hop the client back to the session we launched from FIRST -- killing the
  # attached session would otherwise detach the client (detach-on-destroy
  # defaults to on). @is_remote is session-scoped, so dumb mode dies with the
  # session and the origin is normal again. No attached client (navigated away /
  # stopped elsewhere) -> the switch is a harmless no-op and kill-session just
  # reaps the zombie.
  _ona_clear_cache   # env likely stopped/stopping; next open refetches. Before
                     # kill-session, which ends this process.
  tmux switch-client -t "=$ONA_ORIGIN" 2>/dev/null || tmux switch-client -l 2>/dev/null
  tmux kill-session -t "=ona-${id%%-*}"
}

_ona_launch() {                        # enter
  local d; d=$(jq -c .)
  local id short origin
  id=$(jq -r .id <<<"$d")
  short=$(jq -r .short <<<"$d")
  origin=$(tmux display-message -p '#{session_name}')   # where to return on teardown
  # detached local session whose window connects; ONA_ID + ONA_ORIGIN are read by
  # _ona_connect (the latter for the teardown hop-back on disconnect).
  tmux new-session -d -s "ona-$short" -e "ONA_ID=$id" -e "ONA_ORIGIN=$origin" \
    'zsh -c "source ~/.zsh/launcher.d/ona.zsh && _ona_connect"'
  tmux set-option -t "ona-$short" @is_remote 1   # bare name: set-option rejects =name
  tmux set-option -t "ona-$short" @icon '󰞶'      # tmux launcher renders this glyph for the row
  tmux switch-client -t "=ona-$short"            # =name: exact match, accepted here
  _ona_clear_cache                               # phase will change; next open refetches
}

_ona_stop() {                          # alt
  local d; d=$(jq -c .)
  [[ $(jq -r .phase <<<"$d") == running ]] || return 0
  ona env stop "$(jq -r .id <<<"$d")"
}

_ona_preview() { ona env get "$(jq -r .id)"; }

[[ -n $_LAUNCHER_EMIT ]] || return 0   # re-sourced just for a helper: stop here

# --- stale-while-revalidate cache for `ona env list` ----------------------
# `ona env list` is a network call and the slowest thing in emit; it blocks
# the picker from appearing. The set of envs and their phases changes rarely, so
# we cache the raw JSON and serve it stale: print the cached copy immediately and
# (if it's older than the TTL) refresh in the background so the NEXT open is
# fresh. Only the slow remote call is cached -- the live tmux-session dedup below
# is always recomputed, so a freshly opened/closed local session is never stale.
typeset -gi _ONA_TTL=30                 # seconds before a served cache is refreshed (_ONA_CACHE defined above the guard)

# One foreground refresh: ona -> unique temp -> atomic rename. The temp is
# per-invocation (mktemp) so concurrent refreshes can't clobber a shared file;
# the rename is atomic so a reader never sees a half-written cache.
_ona_refresh() {
  local tmp
  [[ -d ${_ONA_CACHE:h} ]] || mkdir -p "${_ONA_CACHE:h}"
  tmp=$(mktemp "${_ONA_CACHE}.XXXXXX") || return
  if ona env list -o json >"$tmp" 2>/dev/null; then
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
