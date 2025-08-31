#!/bin/zsh

function run_stow(){
  for dir in $@; do
    stow -t "$HOME" $dir
  done
}

run_stow zsh docker tmux git-common fd lnav


if [[ $OSTYPE == 'darwin'* ]]; then
  run_stow aerospace ghostty personal
fi

if [[ $OSTYPE == 'linux-gnu'* ]]; then
  run_stow codespace
fi
