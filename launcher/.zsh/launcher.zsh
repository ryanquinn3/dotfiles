# Plugin-based fzf launcher (mac-only; package stowed only in the darwin branch).
#
# A single fzf core that pipes rows from any number of plugins into one picker.
# The core stays domain-agnostic: it knows nothing about tmux, ssh, or gitpod.
#
# DATA-IN, NOT CODE-IN. A plugin emits one JSON object per line (JSONL) with a
# `data` payload and three FIXED command strings (enter/alt/preview). The core
# renders the row and, on selection, feeds `data` to the chosen command *on
# stdin* and `eval`s the command. The command strings are plugin-authored
# constants (trusted code); `data` is the only per-row value and never reaches
# the parser. That split removes the escaping/quoting tax the old delimited
# string contract paid: untrusted text can't become code if it only ever
# travels as JSON on stdin.
#
# Row schema (compact JSON, one per line - see launcher.d/tmux.zsh for an example):
#   {
#     "display": { "icon": "", "color": 34, "cols": ["c1","c2","c3"], "tail": "" },
#     "data":    { ... },          # arbitrary, plugin-defined; passed to cmds on stdin
#     "enter":   "<cmd>",          # run on Enter   (action)
#     "alt":     "<cmd>",          # run on ctrl-x  (alt action)
#     "preview": "<cmd>"           # run for the preview pane
#   }
#
# - display: the CORE renders this into the colored, aligned grid (one place,
#   not per plugin). `icon`+`color` lead; `cols[0..2]` fill the shared column
#   widths (_LAUNCHER_COLW); `tail` is the free, unpadded remainder. The core
#   also strips control bytes from every display field, so plugins hand over
#   raw text and never touch ANSI or alignment.
# - enter/alt/preview: command strings the core `eval`s with the row's `data`
#   piped to stdin. The idiomatic value is a thin re-source shim, e.g.
#   "source ~/.zsh/launcher.d/tmux.zsh && _tmux_switch", so the real logic lives
#   in a normal, readable zsh helper that reads `data` from stdin with jq. (The
#   re-source is cheap and is how plugins expose helpers to the subshell that
#   fzf runs preview/alt in, where the plugin was never sourced.)
#
# Plugin contract:
#   1. Define helper functions (enter/alt/preview logic) at the TOP of the file.
#   2. Then `[[ -n $_LAUNCHER_EMIT ]] || return 0` - so a re-source for a helper
#      stops here (only the core's emit pass sets _LAUNCHER_EMIT).
#   3. Below the guard, print JSONL rows (one object per line). Building rows
#      with `jq` keeps all JSON escaping automatic.

typeset -ga _LAUNCHER_COLW=(26 14 12)        # shared column widths for the grid
typeset -g _LAUNCHER_LOG=${XDG_CACHE_HOME:-$HOME/.cache}/launcher.log
[[ -d ${_LAUNCHER_LOG:h} ]] || mkdir -p ${_LAUNCHER_LOG:h}

# Source each plugin in its own subshell with _LAUNCHER_EMIT set; collect JSONL.
# Sequential (not backgrounded) = deterministic order, no concurrent-write
# corruption. A plugin's stderr goes to the debug log so a noisy/broken plugin
# can't poison the row stream.
_launcher_emit_rows() {
  local p
  for p in ~/.zsh/launcher.d/*.zsh(N); do
    ( _LAUNCHER_EMIT=1; source "$p" ) 2>>"$_LAUNCHER_LOG"
  done
}

# JSONL on stdin -> "DISPLAY<TAB>ROW_JSON" on stdout. fzf shows field 1 (the
# rendered display); field 2 carries the row's JSON (sans display) for dispatch.
# jq -c guarantees the JSON is single-line and tab-free, so exactly one TAB
# separates the two fields.
_launcher_render() {
  jq -rc --argjson w "[${(j:,:)_LAUNCHER_COLW}]" '
    def pad($n): . + ((" " * ($n - length)) // "");   # pad short, never truncate
    def clean:   gsub("[[:cntrl:]]"; " ");             # strip control bytes
    .display as $d
    | ( "\u001b[\($d.color)m\($d.icon)\u001b[0m  "
      + "\u001b[33m" + (($d.cols[0] // "" | clean) | pad($w[0])) + "\u001b[0m "
      + "\u001b[36m" + (($d.cols[1] // "" | clean) | pad($w[1])) + "\u001b[0m "
      + "\u001b[90m" + (($d.cols[2] // "" | clean) | pad($w[2])) + "\u001b[0m "
      + "\u001b[32m" + ($d.tail // "" | clean) + "\u001b[0m" )
    + "\t" + (del(.display) | tojson)
  '
}

# Run a row command. $1 = enter|alt|preview, $2 = row JSON. The row`s `data` is
# piped to stdin; the command (a trusted, plugin-authored constant) is eval`d
# and reads `data` from stdin with jq. `data` never touches the parser.
_launcher_run() {
  local row=$2
  print -r -- "$row" | jq -c '.data' | eval "$(print -r -- "$row" | jq -r ".$1")"
}

launcher() {
  local line
  line=$(_launcher_emit_rows | _launcher_render | fzf \
    --ansi --delimiter='\t' --with-nth=1 \
    --layout=reverse --cycle --info=inline --border=rounded \
    --border-label=' launch ' --prompt='  ' --pointer='▶' --scrollbar='█' \
    --header=$'\033[2menter: run   ctrl-x: alt\033[0m' \
    --preview='source ~/.zsh/launcher.zsh && _launcher_run preview {2..}' \
    --preview-window=right:55% \
    --bind='ctrl-x:execute-silent(source ~/.zsh/launcher.zsh && _launcher_run alt {2..})+reload(zsh -c "source ~/.zsh/launcher.zsh && _launcher_emit_rows | _launcher_render")') || return
  [[ -n $line ]] || return
  _launcher_run enter "${line#*$'\t'}"     # strip the DISPLAY field, keep ROW_JSON
}
alias tjump='launcher'
