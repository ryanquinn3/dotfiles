# Claude Code launcher.
#
# Lives in the `claude` stow package but stows to ~/.zsh/claude.zsh so the
# `~/.zsh/*.zsh` loop in .zshrc auto-sources it (both `zsh` and `claude` are
# stowed --no-folding, so they co-populate the real ~/.zsh dir).
#
# It resolves its OWN real path through the stow symlink to locate the plugin
# bundles in this repo, so it works regardless of where dotfiles is cloned
# (mac, cde) and without depending on $DOT_FILES.
typeset -g _CLAUDE_PLUGINS_DIR="${${(%):-%x}:A:h:h}/plugins"

# Purpose-grouped plugins loaded on every interactive `claude` invocation.
# The DEFAULT is empty: a plain machine (mac) loads nothing and composes a
# profile per-repo. Host overlays (~/.zsh/host/{cde,macos}.zsh) are sourced
# after this file and reassign _CLAUDE_PLUGINS for a machine-wide profile
# (e.g. cde.zsh loads the work plugins on every cde).
typeset -ga _CLAUDE_PLUGINS=()

# Wrapper: inject --plugin-dir for each selected plugin, then defer to the real
# binary. `command claude` avoids recursing back into this function. Unknown
# plugin names are skipped (with a warning) so a stale override can't stop
# claude from launching.
claude() {
  local -a plugin_args
  local p dir
  for p in $_CLAUDE_PLUGINS; do
    dir="$_CLAUDE_PLUGINS_DIR/$p"
    if [[ ! -d "$dir" ]]; then
      print -u2 "claude: skipping unknown plugin '$p' ($dir not found)"
      continue
    fi
    plugin_args+=(--plugin-dir "$dir")
  done
  command claude "${plugin_args[@]}" "$@"
}

# Interactively choose from the plugins available in plugins/. Prints the chosen
# names one per line to stdout (the gum UI renders on the terminal); returns
# non-zero if cancelled. Names passed as args are preselected, defaulting to the
# active _CLAUDE_PLUGINS. Embeddable, e.g.:
#   local -a picked=("${(@f)$(_claude_choose_plugins)}") || return
_claude_choose_plugins(){
  local -a available preselect
  local d
  for d in "$_CLAUDE_PLUGINS_DIR"/*/.claude-plugin/plugin.json(N); do
    available+=("${d:h:h:t}")
  done
  (( ${#available} )) || { print -u2 "no plugins found in $_CLAUDE_PLUGINS_DIR"; return 1; }
  if (( $# )); then preselect=("$@"); else preselect=($_CLAUDE_PLUGINS); fi
  print -rl -- $available | gum choose --no-limit --header='Claude plugins:' --selected="${(j:,:)preselect}"
}

# Pick plugins interactively, then launch. Calls the real binary directly (not
# the claude() wrapper) so the chosen set fully replaces the machine profile
# rather than stacking on top of it.
clp(){
  local -a chosen plugin_args
  local p
  chosen=("${(@f)$(_claude_choose_plugins)}") || return
  (( ${#chosen} )) || return
  for p in $chosen; do plugin_args+=(--plugin-dir "$_CLAUDE_PLUGINS_DIR/$p"); done
  command claude "${plugin_args[@]}" "$@"
}

# Boot Claude with all permission prompts skipped.
clc(){
  GITHUB_TOKEN= ANTHROPIC_API_KEY= claude --dangerously-skip-permissions "$@"
}

# Pick a model interactively, then launch.
clm(){
  local model
  model=$(gum choose --header="Claude model:" --label-delimiter=":" \
    "opus:opus" \
    "sonnet:sonnet" \
    "Opus 4.7:claude-opus-4-7" \
    "Opus 4.6:claude-opus-4-6") || return
  [[ -z "$model" ]] && return
  claude --model "$model" "$@"
}

# Launch with the chrome-devtools MCP server wired up.
_claude_dev_tools() {
  claude \
    --dangerously-skip-permissions \
    --mcp-config '{"mcpServers": {"chrome-devtools": {"command": "npx", "args": ["-y", "chrome-devtools-mcp@latest", "--auto-connect"]}}}'
}

alias cc="tmux_claude_code"
tmux_claude_code() {
  tmux_new_window "claude-code" "claude --dangerously-skip-permissions"
}
