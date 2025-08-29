#!/bin/zsh

function run_stow(){
  for dir in $@; do
    stow -t "$HOME" $dir
  done
}

run_stow zsh docker tmux git fd lnav


if [[ $OSTYPE == 'darwin'* ]]; then
  run_stow aerospace ghostty
fi
