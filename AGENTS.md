# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Personal dotfiles managed with GNU `stow`. Each top-level directory is a **stow package** whose internal layout mirrors `$HOME`. Stowing a package symlinks its files into `$HOME` at the matching path (e.g. `zsh/.zshrc` -> `~/.zshrc`, `claude/.claude/CLAUDE.md` -> `~/.claude/CLAUDE.md`).

## Commands

- `./install` - full bootstrap (zsh script, despite README saying `install.zsh`). Installs oh-my-zsh + plugins, tmux tpm, brew bundle (Linux), applies macOS `defaults`, removes existing `~/.zshrc`/`~/.zshenv`, then runs `stow.sh`.
- `./stow.sh` - just (re-)symlink packages into `$HOME`. Run this after adding a new file to an existing package so the symlink appears.
- `brew bundle --file=brew/Brewfile` - install/sync packages.
- `stow -t "$HOME" <package>` - stow a single package manually.

There is no build/lint/test suite; changes are shell/config files validated by sourcing or running them.

## Stow folding (important)

`stow.sh` defines two helpers; pick the right one when adding a package:

- `run_stow` - default. May **fold** an entire package dir into one symlink when the target dir doesn't exist yet.
- `run_stow_no_fold` (`--no-folding`) - creates real dirs in `$HOME` and symlinks files individually. Use for any package whose target dir **also receives runtime/generated files** (e.g. `~/.zsh/completions`, `~/.claude/projects|todos`, `~/.config/opencode/node_modules`) so those writes land in `$HOME` instead of following a folded symlink back into this repo. Trade-off: newly added repo files need a re-stow to appear.

Package selection is OS-gated in `stow.sh` (macOS vs `linux-gnu`/codespace).

## Zsh architecture

Load order matters; env vs interactive config is deliberately split:

- `zsh/.zshenv` - sourced for **all** shells (scripts, ssh, non-interactive, fzf preview subshells). Env only: `PATH`, `LANG`, `EDITOR`/`GIT_EDITOR`.
- `zsh/.zshrc` - **interactive** only: history, oh-my-zsh, fzf, completion/fzf-tab zstyles, prompt.
- `zsh/.zsh/*.zsh` - topic files (`git`, `dev`, `docker`, `k8s`, `tmux`, `agents`, `shell`, `misc`, `completion`), sourced in a loop by `.zshrc`.
- `zsh/.zsh/host/{cde,macos}.zsh` - machine-specific overlay sourced **last**. `cde.zsh` when `$IS_ON_ONA` is set (Gitpod/Ona codespace), else `macos.zsh`. Host file overrides earlier topic defaults.

Profile startup with `ZSHRC_PROFILE=1 zsh` (prints `zprof` at end of `.zshrc`).

## Other notable packages

- `bin/.local/bin/` - personal scripts on `PATH` (`init-claude`, `gcode`, `git-pr-checks`, `watch-ci-status`, `setup-efs`, etc.).
- `claude/.claude/` - Claude Code config stowed to `~/.claude`: global `CLAUDE.md`, `rules/` (codestyle, testing, planning), `agents/`, `commands/`, `skills/`. Editing these here changes Claude's global behavior after re-stow.
- `opencode/`, `ghostty/`, `tmux/`, `starship/`, `aerospace/`, `sketchybar/`, `gh-dash/`, `lnav/`, `fd/` - config for those tools, each mirroring its `~/.config` (or `~/`) path.
- `brew/Brewfile` - package manifest.

## Conventions

- Plans/research go in `.ai-dev/` directories (see `zsh/.ai-dev/plans/` for examples), never in `~/.claude/plans`.
- Bootstrap is idempotent: guards check for existing installs/dirs before cloning or creating.
