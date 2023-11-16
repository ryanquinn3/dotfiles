# ZSH config
ZSH_THEME="bureau"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"
ZSH_DISABLE_COMPFIX="true"

# Uncomment to add kube settings to prompt
# USING_KUBE=1

export LANG=en_US.UTF-8
export ZSH="$HOME/.oh-my-zsh"
export ZSHRC="$HOME/.zshrc"
export DOCKER_BUILDKIT=1
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.cargo/bin:/usr/local/opt/openssl@1.1/bin:$HOME/.local/bin"
autoload -Uz compinit
compinit

plugins=(git brew kubectl kube-ps1)
source $ZSH/oh-my-zsh.sh
export EDITOR='subl -w'

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
    alias ls="exa"
    command -v pyenv && eval "$(pyenv init -)"
    # Node tooling
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    source <(npm completion)
    # Setup autojump
    [ -f $(brew --prefix)/etc/profile.d/autojump.sh ] && . $(brew --prefix)/etc/profile.d/autojump.sh

    # GH autocompletion
    eval "$(gh completion -s zsh)"
fi


autoload -Uz compinit
compinit -i



# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ryanquinn/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ryanquinn/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ryanquinn/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ryanquinn/google-cloud-sdk/completion.zsh.inc'; fi
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$HOME/.poetry/bin:$PATH"

nvm use node



if [ -f ./usr/local/opt/asdf/libexec/asdf.sh ]; then ./usr/local/opt/asdf/libexec/asdf.sh; fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

