#!/usr/bin/env bash

# Symlink a package into $HOME. stow may fold a whole package directory into a
# single symlink when the target dir doesn't exist yet (new files added to a
# folded dir then appear automatically).
function run_stow(){
  for dir in "$@"; do
    stow -t "$HOME" "$dir"
  done
}

# Symlink a package with --no-folding: stow creates real directories in the
# target and symlinks files individually, never collapsing a dir into one
# symlink. Use for packages whose target dir ALSO receives runtime/generated
# files (~/.zsh/completions, ~/.claude/projects|todos, ~/.config/opencode/
# node_modules) so those writes land in $HOME instead of being followed back
# into this repo. Trade-off: a newly added repo file needs a re-stow to appear.
function run_stow_no_fold(){
  for dir in "$@"; do
    stow --no-folding -t "$HOME" "$dir"
  done
}

run_stow tmux git-common fd lnav bin starship gh-dash
run_stow_no_fold zsh opencode claude


if [[ $OSTYPE == 'darwin'* ]]; then
  run_stow aerospace ghostty personal sketchybar docker fresh
  run_stow_no_fold launcher
fi

if [[ $OSTYPE == 'linux-gnu'* ]]; then
  run_stow codespace
  if [ -f ~/.docker/config.json ]; then
    jq -s '.[0] + .[1]' ~/.docker/config.json $DOT_FILES/docker/.docker/config.json > /tmp/merged_docker_config.json
    mv /tmp/merged_docker_config.json $HOME/.docker/config.json
  else
    run_stow docker
  fi
fi
