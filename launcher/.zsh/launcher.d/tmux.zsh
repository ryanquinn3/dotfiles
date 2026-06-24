# tmux window switcher — first launcher plugin.
#
# Prints one launcher row per tmux window (MRU-sorted) when sourced. No wrapping
# function: the core sources this file in a subshell and captures stdout.
#
# Safety contract (the row's command fields are eval'd downstream):
#   - Action/preview targets use STABLE tmux IDs (#{session_id} $N,
#     #{window_id} @N, #{pane_id} %N) — integer tokens with no injectable text.
#   - DISPLAY may show names but is sanitized: [[:cntrl:]] (incl. \x1e/\x1f/
#     newlines) stripped before wrapping in ANSI.
#   - Field separator into awk is \x1e (Record Separator-adjacent control byte),
#     not '|', because window names/paths can contain '|' and shift fields.

local d=$_LAUNCHER_DELIM
tmux list-windows -a -F \
  $'#{window_activity}\x1e#{session_id}\x1e#{window_id}\x1e#{pane_id}\x1e#{session_name}\x1e#{window_name}\x1e#{pane_current_command}\x1e#{pane_current_path}' \
  2>/dev/null \
  | sort -t $'\x1e' -k1,1nr \
  | awk -F $'\x1e' -v home="$HOME" -v d="$d" -v icon=$'\uf120' \
        -v w1=$_LAUNCHER_COLW[1] -v w2=$_LAUNCHER_COLW[2] -v w3=$_LAUNCHER_COLW[3] '
    {
      sid=$2; wid=$3; pid=$4; sess=$5; win=$6; cmd=$7; path=$8
      gsub(/[[:cntrl:]]/," ",sess); gsub(/[[:cntrl:]]/," ",win)   # sanitize display fields
      gsub(/[[:cntrl:]]/," ",cmd);  gsub(/[[:cntrl:]]/," ",path)
      hl=length(home); if (substr(path,1,hl)==home) path="~" substr(path,hl+1)
      # leading icon (terminal, blue) + sess/win/cmd padded to shared grid widths,
      # path as the free tail. Columns line up with other plugins rows.
      disp=sprintf("\033[34m%s\033[0m  \033[33m%-*s\033[0m \033[36m%-*s\033[0m \033[90m%-*s\033[0m \033[32m%s\033[0m", icon, w1, sess, w2, win, w3, cmd, path)
      preview="tmux capture-pane -t " pid " -ep"
      # session_id is $N: wrap it in single quotes (emitted via \047 so the
      # apostrophe does not close this shell-single-quoted awk program) so the
      # core eval passes a literal $N to tmux instead of expanding it as a shell
      # param. @N/%N are not shell special. IDs only: injection-safe.
      exec="tmux switch-client -t \047" sid "\047 \\; select-window -t " wid
      alt="tmux kill-window -t " wid
      printf "%s%s%s%s%s%s%s\n", disp, d, preview, d, exec, d, alt
    }'
