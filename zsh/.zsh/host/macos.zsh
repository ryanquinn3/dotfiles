USE_PYENV=0
# File to be included when running locally on macos
alias ls="eza"
alias cat="bat"

export DOT_FILES=$HOME/repos/dotfiles
export EDITOR='fresh --wait'

# Node tooling
eval "$(fnm env --use-on-cd --shell zsh)"


gen_completion gh gh completion -s zsh   # gh uses `-s zsh`, not `completion zsh`

# disable mouse reporting
function fix_mouse(){
  print -n -- $'\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1015l'
}

alias fm="fix_mouse"

# ona environment helpers live in ~/.zsh/ona.zsh (sourced as a topic file)

# print current wifi network
ssid() {
  echo $(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')
}

# Print current wifi settings
wifi(){
  if [ -z "$1" ]
  then
     echo "SSID: $(ssid)"
     security find-generic-password -ga $currentnetwork | tr -d '\n' | grep "password:"
  else
     echo "SSID: $1"
     security find-generic-password -ga $1 | tr -d '\n' | grep "password:"
  fi
}

ssh_desktop() {
  DESKTOP_IP=192.168.86.38
  echo "Running on wifi $(ssid)"
  ssh ryan@$DESKTOP_IP
}
