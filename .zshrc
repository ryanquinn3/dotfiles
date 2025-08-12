# ZSH config
ZSH_THEME="bureau"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
ZSH_DISABLE_COMPFIX="true"

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

# Uncomment to add kube settings to prompt
# USING_KUBE=1

export LANG=en_US.UTF-8
export ZSH="$HOME/.oh-my-zsh"
export ZSHRC="$HOME/.zshrc"
export DOCKER_BUILDKIT=1
export PATH="$PATH:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.cargo/bin:/usr/local/opt/openssl@1.1/bin:$HOME/.local/bin"
autoload -Uz compinit
compinit

# fzf
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completions.zsh ] && source /usr/share/doc/fzf/examples/completions.zsh

plugins=(git brew kubectl kube-ps1 fzf-zsh-plugin)
source $ZSH/oh-my-zsh.sh

if [[ -n "$USING_KUBE" ]]; then
    RPROMPT=$RPROMPT'$(kube_ps1)'
fi



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

# Node tooling
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
nvm use default
source <(npm completion)
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

autoload -Uz compinit
compinit -i



# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ryanquinn/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ryanquinn/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ryanquinn/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ryanquinn/google-cloud-sdk/completion.zsh.inc'; fi


export PATH="$HOME/.poetry/bin:$PATH"


if [ -f ./usr/local/opt/asdf/libexec/asdf.sh ]; then ./usr/local/opt/asdf/libexec/asdf.sh; fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Ruby 
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"


