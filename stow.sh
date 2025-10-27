#!/usr/bin/env zsh

function run_stow(){
  for dir in $@; do
    stow -t "$HOME" $dir
  done
}

run_stow zsh  tmux git-common fd lnav bin


if [[ $OSTYPE == 'darwin'* ]]; then
  run_stow aerospace ghostty personal sketchybar docker
fi

if [[ $OSTYPE == 'linux-gnu'* ]]; then
  run_stow codespace claude
  if [ -f ~/.docker/config.json ]; then
    jq -s '.[0] + .[1]' ~/.docker/config.json $DOT_FILES/docker/.docker/config.json > /tmp/merged_docker_config.json
    mv /tmp/merged_docker_config.json $HOME/.docker/config.json
  else
    run_stow docker
  fi
fi
