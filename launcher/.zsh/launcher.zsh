# Plugin-based fzf launcher (mac-only; package stowed only in the darwin branch).
#
# A single fzf core that pipes rows from any number of plugins into one picker.
# Each row carries its own preview command and its own actions, so the core
# stays agnostic: it knows nothing about tmux, ssh, or any specific domain.
#
# Discovery: glob ~/.zsh/launcher.d/*.zsh and source each in its OWN subshell;
# the plugin prints its rows as a side effect of being sourced. No registry, no
# naming convention. The subshell isolates each plugin's helpers/vars.
#
# Row contract (fields joined by $_LAUNCHER_DELIM = \x1f):
#   DISPLAY ␟ PREVIEW_CMD ␟ EXEC_CMD ␟ ALT_CMD
#   - DISPLAY:     colored/aligned string shown in the list (ANSI ok, no \x1f).
#   - PREVIEW_CMD: command string; fzf runs `eval {2}` to render the preview.
#   - EXEC_CMD:    command string the core evals on enter.
#   - ALT_CMD:     command string bound to ctrl-x; ':' (no-op) when unused.
#
# Plugin-author contract — what every plugin owes vs. what's situational. The
# safety machinery is a function of how much UNTRUSTED text the plugin emits,
# not a flat tax; a plugin over self-controlled data needs almost none of it.
#
#   UNIVERSAL (every plugin):
#     - Print rows of exactly 4 fields joined by $_LAUNCHER_DELIM.
#     - PREVIEW/EXEC/ALT must be self-contained (they run where the plugin was
#       never sourced — fzf's preview shell, the dispatch shell) and shell-safe
#       (the core `eval`s EXEC; fzf `eval`s PREVIEW/ALT). For self-authored
#       command strings this is free.
#
#   CONDITIONAL (only when a field carries arbitrary/external text):
#     - Never interpolate raw untrusted text into a command field. Use a stable
#       opaque token as the target (tmux IDs @N/$N/%N), or quote with ${(q)...}.
#       A plugin with no untrusted data (static menu, known-safe ids) skips this.
#     - Sanitize DISPLAY for control bytes (incl. \x1f/newlines) only if it
#       shows arbitrary text: `gsub(/[[:cntrl:]]/," ",field)` (awk) or the zsh
#       equivalent. Known/static labels need no scrub.
#     - A \x1e intermediate separator is only relevant if you pipe multi-field
#       external output through awk/sort (as tmux.zsh does); rows built in pure
#       zsh have no such parsing step.
#
# See launcher.d/tmux.zsh for the worst-case reference (user-renamable names +
# arbitrary paths): it uses all three. Most plugins use one or none.

typeset -g _LAUNCHER_DELIM=$'\x1f'   # inherited by the per-plugin emit subshell
# Shared DISPLAY column widths so rows line up into one grid across plugins.
# Layout: <icon> <col1> <col2> <col3> <free tail>. Plugins pad cols 1-3 to these
# widths (overflow shifts, never truncates); the tail is unpadded. Inherited by
# the emit subshell, same as _LAUNCHER_DELIM.
typeset -ga _LAUNCHER_COLW=(26 14 12)
typeset -g _LAUNCHER_LOG=${XDG_CACHE_HOME:-$HOME/.cache}/launcher.log
[[ -d ${_LAUNCHER_LOG:h} ]] || mkdir -p ${_LAUNCHER_LOG:h}

_launcher_emit_rows() {
  local p
  for p in ~/.zsh/launcher.d/*.zsh(N); do
    # subshell per plugin: isolates helpers/vars; sequential (not backgrounded)
    # = deterministic order, no concurrent-write corruption. stdout is rows
    # ONLY; a plugin's stderr goes to the debug log so a noisy/broken plugin
    # can't poison the row stream or corrupt the fzf UI.
    ( source "$p" ) 2>>"$_LAUNCHER_LOG"
  done
}

launcher() {
  local sel
  sel=$(_launcher_emit_rows | fzf \
    --ansi --delimiter=$'\x1f' --with-nth=1 \
    --layout=reverse --cycle --info=inline --border=rounded \
    --border-label=' launch ' --prompt='  ' --pointer='▶' --scrollbar='█' \
    --header=$'\033[2menter: run   ctrl-x: alt\033[0m' \
    --preview='eval {2}' --preview-window=right:55% \
    --bind='ctrl-x:execute-silent(eval {4})+reload(zsh -c "source ~/.zsh/launcher.zsh && _launcher_emit_rows")') || return
  [[ -n $sel ]] || return
  local -a parts=("${(@ps:\x1f:)sel}")
  eval "$parts[3]"          # EXEC_CMD; plugins guarantee a shell-safe string
}
alias tjump='launcher'
