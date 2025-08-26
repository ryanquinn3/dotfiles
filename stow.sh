#!/bin/zsh

stow -t "$HOME" zsh
stow -t "$HOME" docker
stow -t "$HOME" tmux
stow -t "$HOME" git
stow -t "$HOME" fd

if [[ $OSTYPE == 'darwin'* ]]; then
  stow -t "$HOME" aerospace
  stow -t "$HOME" ghostty
fi
