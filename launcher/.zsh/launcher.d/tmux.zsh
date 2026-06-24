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
# One JSON row per window, MRU-sorted (most-recent activity first). tmux emits
# \x1f-separated fields (window names/paths can contain anything but \x1f); jq
# splits on the same byte (0x1f) and builds the row, so all JSON escaping is
# automatic. The $HOME prefix in the path is shortened to ~ for display.
tmux list-windows -a -F \
  $'#{window_activity}\x1f#{session_id}\x1f#{window_id}\x1f#{pane_id}\x1f#{session_name}\x1f#{window_name}\x1f#{pane_current_command}\x1f#{pane_current_path}' \
  2>/dev/null \
  | sort -t $'\x1f' -k1,1nr \
  | jq -Rc --arg home "$HOME" \
       --arg enter   "$sh && _tmux_switch" \
       --arg alt     "$sh && _tmux_kill" \
       --arg preview "$sh && _tmux_preview" '
      split("\u001f")
      | { display: { icon: "\uf120", color: 34,
                     cols: [ .[4], .[5], .[6] ],
                     tail: ( .[7] | if startswith($home) then "~" + .[($home|length):] else . end ) },
          data:    { sid: .[1], wid: .[2], pid: .[3] },
          enter: $enter, alt: $alt, preview: $preview }'
