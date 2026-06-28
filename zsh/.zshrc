# Set ZSHRC_PROFILE=1 before launching zsh to profile startup;
# the matching `zprof` report is printed at the end of this file.
[ -n "$ZSHRC_PROFILE" ] && zmodload zsh/zprof
# ZSH config

ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
ZSH_DISABLE_COMPFIX="true"
export ZSH_CACHE_DIR="$HOME/.oh-my-zsh/cache"
export ZSH_COMPDUMP="$ZSH_CACHE_DIR/.zcompdump"
##########
# HISTORY
##########

HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
# Immediately append to history file:
setopt INC_APPEND_HISTORY
# Record timestamp in history:
setopt EXTENDED_HISTORY
# Expire duplicate entries first when trimming history:
setopt HIST_EXPIRE_DUPS_FIRST
# Dont record an entry that was just recorded again:
setopt HIST_IGNORE_DUPS
# Delete old recorded entry if new entry is a duplicate:
setopt HIST_IGNORE_ALL_DUPS
# Do not display a line previously found:
setopt HIST_FIND_NO_DUPS
# Dont record an entry starting with a space:
setopt HIST_IGNORE_SPACE
# Dont write duplicate entries in the history file:
setopt HIST_SAVE_NO_DUPS
# Share history between all sessions:
setopt SHARE_HISTORY
# Execute commands using history (e.g.: using !$) immediately:
unsetopt HIST_VERIFY

# env (PATH, LANG, EDITOR, exports) lives in .zshenv
export ZSH="$HOME/.oh-my-zsh"
export ZSHRC="$HOME/.zshrc"

fpath=(~/.zsh/completions $fpath)

# init brew early (before fzf/completion) so brew tools win over older system
# copies (e.g. apt fzf without --zsh). brew usually isn't on PATH in a fresh
# shell, so try it directly, then fall back to the canonical install prefixes;
# shellenv then sets PATH/MANPATH/etc.
for brew_bin in brew /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if command -v "$brew_bin" >/dev/null 2>&1; then
    eval "$("$brew_bin" shellenv)"
    break
  fi
done



plugins=(git brew fzf-tab zsh-yarn-completions tmux)
source $ZSH/oh-my-zsh.sh


# fzf (--zsh needs fzf >= 0.48; guard so an older system fzf doesn't error)
if fzf --zsh >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --no-ignore-vcs"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --no-ignore-vcs"
export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept --preview-window='right:60%'
# zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'tree -C $realpath | head -200'
# when completing a command name, preview what it resolves to
# (alias target, function body, or binary path + tldr). source our
# alias/function files (fzf runs previews in a non-interactive shell
# that hasn't loaded rc) then resolve.
zstyle ':fzf-tab:complete:-command-:*' fzf-preview \
  'for f in ~/.zsh/*.zsh; do source "$f"; done 2>/dev/null; cmd_preview $word'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'
# zstyle ':fzf-tab:*' fzf-flags --preview 'bat -n --color=always {}'


# load topic files (cross-platform), then the machine-specific host overlay last
for f in ~/.zsh/*.zsh(N); do source "$f"; done
if [[ -n "$IS_ON_ONA" ]]; then
  source ~/.zsh/host/cde.zsh
else
  source ~/.zsh/host/macos.zsh
fi

# if zoxide is installed, initialize it
[ -x "$(command -v zoxide)" ] && eval "$(zoxide init zsh)"

# fzf-git is cloned as an omz custom plugin (see install: fzf_git_plugin_dir)
fzf_git="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-git-plugin/fzf-git.sh"
[ -f "$fzf_git" ] && source "$fzf_git"

eval "$(starship init zsh)"

# print startup profile if ZSHRC_PROFILE was set (see top of file)
[ -n "$ZSHRC_PROFILE" ] && zprof
