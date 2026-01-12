

ZSHRC_PROFILE="1"
# if $ZSHRC_PROFILE is set, source it at start
[ -n "$ZSHRC_PROFILE" ] && zmodload zsh/zprof
# ZSH config
# ZSH_THEME="powerlevel10k/powerlevel10k"
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

export LANG=en_US.UTF-8
export ZSH="$HOME/.oh-my-zsh"
export ZSHRC="$HOME/.zshrc"
export DOCKER_BUILDKIT=1
export PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.cargo/bin:/usr/local/opt/openssl@1.1/bin:$HOME/.local/bin"

fpath=(~/.zsh/completions $fpath)


# Node tooling
eval "$(fnm env --use-on-cd --shell zsh)"

plugins=(git brew fzf-tab zsh-yarn-completions)
source $ZSH/oh-my-zsh.sh

if [[ -n "$VSCODE_GIT_IPC_HANDLE"  ]]; then
  export GIT_EDITOR="code --wait"
  export EDITOR="code --wait"
else
  export GIT_EDITOR="vim"
  export EDITOR="vim"
fi


# fzf
source <(fzf --zsh)
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
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'tree -C $realpath | head -200'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'
# zstyle ':fzf-tab:*' fzf-flags --preview 'bat -n --color=always {}'


for file in ~/.{aliases,functions,path,dockerfunc,extra,exports}; do
	if [[ -r "$file" ]] && [[ -f "$file" ]]; then
		source "$file"
	fi
done
unset file



# only add these if we are not in a codespace
if [[ -z "$CODESPACES" ]]; then
   source ~/.local-config
else
    source ~/.codespaces-config
fi

export PATH="$HOME/.poetry/bin:$PATH"


# if zoxide is installed, initialize it
[ -x "$(command -v zoxide)" ] && eval "$(zoxide init zsh)"

source ~/fzf-git.sh/fzf-git.sh

eval "$(starship init zsh)"
