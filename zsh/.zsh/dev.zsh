lint_changed(){
  trunk="main"
  branch_name=$(git rev-parse --abbrev-ref HEAD)
  main_ancestor=$(git merge-base $branch_name $trunk)
  changed_files=$(git diff --name-only HEAD..$main_ancestor)
  num_files_changed=$(echo "$changed_files" | wc -l)
  echo "Running eslint against $num_files_changed files"
  npx eslint --fix $(echo "$changed_files")
}

npm_latest_version() {
  # parameter 1: package name
  # if exists, print $package@latest_version
  if [ -z "$1" ]; then
    echo "Usage: npm_latest_version PACKAGE_NAME"
    return 1
  fi

  version=$(npm view $1 version)
  if [ $? -ne 0 ]; then
    echo "Package $1 not found"
    return 1
  fi
  echo "$1@$version"
}

install_gh_extensions(){
  install_gh_extension dlvhdr/gh-dash
  install_gh_extension dlvhdr/gh-enhance
}

install_gh_extension(){
  gh extension list | grep $1 || gh extension install $1
}
