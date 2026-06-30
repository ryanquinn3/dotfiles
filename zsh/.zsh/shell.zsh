reload_zsh() {
  [[ -n "$TMUX" ]] && tmux source-file ~/.tmux.conf
  exec zsh
}

kill_process_on_port() {
  kill $(lsof -i tcp:$1 | tail -n 1 | awk {'print $2'})
}

# Install a plugin from a git repository into the custom plugins directory
# Usage: install_plugin <plugin_name> <git_url>
install_plugin() {
  local plugin_name=$1
  local plugin_url=$2
  local plugin_dir="${ZSH_PLUGIN_DIR:-$HOME/.oh-my-zsh/custom/plugins}/${plugin_name}"

  if [ -d "$plugin_dir" ]; then
    echo "$plugin_name already installed"
  else
    git clone --depth 1 "$plugin_url" "$plugin_dir"
  fi
}

# Load a plugin from the custom plugins directory
# Usage: load_plugin <plugin_name>
load_plugin() {
  local plugin_name=$1
  local plugin_dir="${ZSH_PLUGIN_DIR:-$HOME/.oh-my-zsh/custom/plugins}"
  local plugin_file="${plugin_dir}/${plugin_name}"

  if [ -f "$plugin_file" ]; then
    source "$plugin_file"
  else
    echo "Plugin $plugin_name not found in $plugin_dir"
  fi
}

alias rz="reload_zsh"
alias l="eza --group-directories-first --icons --long --color=always --icons=always --no-user -a"
