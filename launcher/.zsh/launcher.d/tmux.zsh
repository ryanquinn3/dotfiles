# tmux window switcher -- launcher plugin.
#
#   enter   -> switch the client to that session/window
#   alt     -> kill the window
#   preview -> show the pane's contents
#
# Every target is a stable tmux ID ($N/@N/%N) carried in `data`; the core pipes
# `data` to these helpers on stdin and they read it with jq. No window name or
# path ever reaches a command, so there is nothing to escape.

_tmux_switch() {                       # enter
  local d; d=$(jq -c .)
  tmux switch-client -t "$(jq -r .sid <<<"$d")"
  tmux select-window -t "$(jq -r .wid <<<"$d")"
}
_tmux_kill()    { tmux kill-window  -t "$(jq -r .wid)"; }   # alt
_tmux_preview() { tmux capture-pane -t "$(jq -r .pid)" -ep; }

[[ -n $_LAUNCHER_EMIT ]] || return 0   # re-sourced just for a helper: stop here

local sh='source ~/.zsh/launcher.d/tmux.zsh'
# Window the picker was opened from; dropped from the list so the top MRU row is
# the window you were *last* on -- making cmd+k -> enter a "jump back" toggle
# instead of a no-op that re-selects the current window.
local cur
cur=$(tmux display-message -p '#{window_id}' 2>/dev/null)
# One JSON row per window. Each carries a numeric `sort` key (last-*focus* epoch)
# and the core MRU-sorts the merged stream of all plugins by it, so no local sort
# is needed here. The key is @focus_ts, the epoch stamped on each window by the
# pane-focus-in hook in .tmux.conf; windows never focused since that hook was
# installed have no @focus_ts, so we fall back to #{window_activity} (last
# output) via the #{?...} ternary.
#
# Fields are pipe-separated (|). A single visible delimiter keeps the jq simple,
# and | is safe here: window/session names, commands, and paths never contain a
# pipe in practice. jq splits the line and builds the row, so all JSON escaping
# is automatic. The $HOME prefix in the path is shortened to ~ for display.
tmux list-windows -a -F \
  $'#{?#{@focus_ts},#{@focus_ts},#{window_activity}}|#{session_id}|#{window_id}|#{pane_id}|#{session_name}|#{window_name}|#{pane_current_command}|#{pane_current_path}|#{@icon}' \
  2>/dev/null \
  | jq -Rc --arg home "$HOME" --arg cur "$cur" \
       --arg enter   "$sh && _tmux_switch" \
       --arg alt     "$sh && _tmux_kill" \
       --arg preview "$sh && _tmux_preview" '
      split("|")
      | { display: { icon: ( if .[8] == "" then "" else .[8] end ), color: 34,
                     cols: [ .[4], .[5], .[6] ],
                     tail: ( .[7] | if startswith($home) then "~" + .[($home|length):] else . end ) },
          data:    { sid: .[1], wid: .[2], pid: .[3] },
          sort:    ( .[0] | tonumber ),   # last-focus epoch; core MRU-merges this with rows from other plugins
          enter: $enter, alt: $alt, preview: $preview }
      | select( .data.wid != $cur )       # drop the window the picker was opened from'
