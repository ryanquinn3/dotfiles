#!/usr/bin/env zsh

function run_stow(){
  for dir in $@; do
    stow -t "$HOME" $dir
  done
}

run_stow zsh docker tmux git-common fd lnav bin


if [[ $OSTYPE == 'darwin'* ]]; then
  run_stow aerospace ghostty personal sketchybar
fi

if [[ $OSTYPE == 'linux-gnu'* ]]; then
  run_stow codespace claude
fi
