USE_PYENV=0
# File to be included when running locally on macos
alias ls="eza"
alias cat="bat"

export DOT_FILES=$HOME/repos/dotfiles
export EDITOR='fresh --wait'

# Node tooling
eval "$(fnm env --use-on-cd --shell zsh)"

# GH autocompletion
eval "$(gh completion -s zsh)"

# disable mouse reporting
function fix_mouse(){
  print -n -- $'\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1015l'
}

alias fm="fix_mouse"


ona_ssh() {
  gitpod_env=$( gitpod config context list -f Environment)
  if [[ -z "$gitpod_env" ]]; then
    echo "No active Gitpod environments in context. Set one with gitpod config context modify default --environment-id $ENV"
    return 1
  fi

  if [[ $(gitpod env get $gitpod_env -f phase) != "running" ]]; then
    gum spin --spinner dot --title "Starting Gitpod environment" -- gitpod env start --editor vscode $gitpod_env
  fi

  gitpod_host="${gitpod_env}.gitpod.environment"
  echo "Connecting to ${gitpod_host}..."
  # Connect via SSH and attach to main tmux session
  ssh -tt "${gitpod_host}" "tmux new-session -A -s main"
  # When ssh session ends, disable mouse reporting so that terminal behaves correctly
  local ec=$?
  [[ -t 1 ]] && print -n -- $'\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1015l'
  return $ec
}

ona_stop(){
  gitpod environment stop $(gitpod config context list -f Environment)
}

ona_create(){
  gitpod environment create https://github.com/VantaInc/obsidian.git --class-id 019b3485-7dbc-73b5-92f3-023820982606
}

ona_set_env() {
  if [[ -z "$1" ]]; then
    echo "Usage: ona_set_env <environment-id>"
    return 1
  fi
   gitpod config context modify default --environment-id $1
}

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
