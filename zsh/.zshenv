# .zshenv - sourced for ALL shells (interactive, non-interactive, scripts).
# Put environment here (PATH, exports, EDITOR) so non-interactive shells
# (ssh commands, scripts, fzf/preview subshells) see it. Interactive-only
# config (plugins, prompt, keybinds, completion) belongs in .zshrc.

export LANG=en_US.UTF-8
export DOCKER_BUILDKIT=1

[[ -f ~/.zshenv.old ]] && source ~/.zshenv.old

# keep PATH entries unique so re-sourcing in subshells doesn't duplicate them
typeset -U path PATH
export PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.cargo/bin:/usr/local/opt/openssl@1.1/bin:$HOME/.local/bin:$HOME/.poetry/bin"

export ZSH_COMPLETIONS_DIR="$HOME/.zsh/completions"
# Editor: inside a VS Code / CDE integrated terminal use code, else gcode.
# On macOS .local-config overrides this to `fresh`; in CDEs nothing overrides
# it, so this block is the source of truth there. (see .zshrc sourcing order)
if [[ -n "$VSCODE_GIT_IPC_HANDLE" ]]; then
  export GIT_EDITOR="code --wait"
  export EDITOR="code --wait"
else
  export GIT_EDITOR="gcode --wait"
  export EDITOR="gcode --wait"
fi
