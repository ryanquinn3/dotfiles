# Local lookup for default branch (no network call)
_git_default_branch() {
  git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo main
}

# Interactive git commit: select files to stage and provide a commit message
git_commit_interactive() {
  local -a changed_files untracked_files staged_files selected_files files_to_unstage
  local staged_selected msg

  changed_files=("${(@f)$(git diff --name-only)}")
  untracked_files=("${(@f)$(git ls-files --others --exclude-standard)}")
  staged_files=("${(@f)$(git diff --name-only --cached)}")
  changed_files=("${(@)changed_files:#}")
  untracked_files=("${(@)untracked_files:#}")
  staged_files=("${(@)staged_files:#}")
  changed_files+=("${untracked_files[@]}")
  changed_files=("${(@u)changed_files[@]}")

  if (( ! ${#changed_files} )); then
    echo "No changed files to commit."
    return 0
  fi

  staged_selected="${(j:,:)staged_files}"
  selected_files=("${(@f)$(gum choose --header "Select files to stage" --no-limit --selected="$staged_selected" "$changed_files[@]")}")
  selected_files=("${(@)selected_files:#}")
  if [ $? -ne 0 ]; then
    return 1
  fi

  if (( ! ${#selected_files} )); then
    echo "No files selected."
    return 1
  fi

  msg=$(gum input --header "Enter a commit message" --placeholder "Commit message")
  if [ $? -ne 0 ]; then
    return 1
  fi

  for staged_file in "$staged_files[@]"; do
    if (( ${selected_files[(Ie)$staged_file]} == 0 )); then
      files_to_unstage+=("$staged_file")
    fi
  done

  if (( ${#files_to_unstage} )); then
    git restore --staged -- "${files_to_unstage[@]}" || return 1
  fi

  git add -- "${selected_files[@]}" || return 1
  git commit -m "$msg"
}
alias gci='git_commit_interactive'

# Git commit all with message, retrying if pre-commit hooks fail
gacm(){
  if [ -z "$1" ]; then
    echo "Please provide a commit message"
    return 1
  fi

  echo "Committing code..."

  git add --all

  # if this fails, retry
  git commit -m $1
  if [ $? -ne 0 ]; then
    echo "Pre commit hooks may have failed... retrying..."
    git add --all
    git commit -m $1
  fi
}

# Use fzf to interactively select and checkout a git branch
_change_branch(){
  git branch --sort=-committerdate | \
  fzf  --border rounded --ansi \
       --preview 'git show --color=always --compact-summary {-1}' \
      --bind 'enter:become(git checkout {-1})'
}

# Fetch a branch without switching to it (default: main)
syncb() {
  local branch="${1:-$(_git_default_branch)}"
  git fetch origin "$branch:$branch" --update-head-ok --no-tags
  if [ "$(git branch --show-current)" = "$branch" ]; then
    git reset --hard "$branch"
  fi
}

# Reset current branch to match remote exactly
resetb() {
  local branch=$(git branch --show-current)
  git fetch origin "$branch" --no-tags && git reset --hard "origin/$branch"
}

# Sync main + rebase current branch onto it
rebasem() {
  local main=$(_git_default_branch)
  syncb "$main" && git rebase "$main"
}

# Delete local branches interactively using gum
git_delete_branches() {
  git branch | cut -c 3- | gum choose --no-limit | xargs git branch -D
}
alias gbdel='git_delete_branches'

# Smart Git Squash Function
git_smart_squash() {
  local target_branch=$1
  local current_head=$(git rev-parse --short HEAD)

  # 1. Check if a branch/commit was provided
  if [[ -z "$target_branch" ]]; then
    echo "Usage: git-squash-all <base-branch>"
    return 1
  fi

  # 2. Identify the merge base
  local merge_base=$(git merge-base HEAD "$target_branch")
  local target_rev=$(git rev-parse "$target_branch")

  echo "Original HEAD: $current_head"

  # 3. Warning if the provided branch is not the merge base
  if [[ "$merge_base" != "$target_rev" ]]; then
    echo "⚠️  WARNING: '$target_branch' is not the direct merge base of your current branch."
    echo "The merge base is actually: $(git rev-parse --short $merge_base)"
    echo -n "Do you want to proceed with squashing against the merge base? (y/n): "
    read -q "choice"
    echo "" # Move to new line
    if [[ "$choice" != "y" ]]; then
      echo "Aborting."
      return 1
    fi
  fi

  # 4. Perform the squash
  echo "Squashing all commits since $merge_base..."
  git reset --soft "$merge_base"

  echo "Ready to commit. Use 'git commit' to finalize."
}

# List local branches with commits that are not pushed to origin
unpushed() {
  # Fetch latest metadata from origin to ensure accuracy
  git fetch origin --quiet

  echo "Branches with local commits not on origin:"
  echo "----------------------------------------"

  # Iterate through all local branches
  git for-each-ref --format='%(refname:short) %(upstream:short)' refs/heads | while read local remote; do
    if [ -z "$remote" ]; then
      echo "[NEW] $local (No remote tracking branch found)"
    else
      # Check if local is ahead of remote
      ahead=$(git rev-list --count "$remote..$local")
      if [ "$ahead" -gt 0 ]; then
        echo "[$ahead ahead] $local"
      fi
    fi
  done
}

alias gbsort="git branch --sort=-committerdate"
alias gcan="git add --all && git commit --amend --no-edit"
alias pullhead='git pull origin $(git rev-parse --abbrev-ref HEAD)'
alias gcb='_change_branch'

push(){
  if [[ -z "$1" ]]; then
    echo "Usage: push <commit-message>"
    return 1
  fi
  gacm "$1"
  gp
}
