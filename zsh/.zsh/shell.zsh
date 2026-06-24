reload_zsh() {
  exec zsh
}

kill_process_on_port() {
  kill $(lsof -i tcp:$1 | tail -n 1 | awk {'print $2'})
}

alias rz="reload_zsh"
alias l="eza --group-directories-first --icons --long --color=always --icons=always --no-user -a"
