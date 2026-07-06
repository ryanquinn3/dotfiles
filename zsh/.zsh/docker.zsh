# Custom completion helper to grab running compose services
_docker_compose_running_services() {
    local -a running_svcs
    # Fetch only running service names from the current directory context
    running_svcs=($(docker compose ps --services --status=running 2>/dev/null))
    _describe 'running services' running_svcs
}

# _docker has no compose support at all, so wrap it: dispatch to our function
# for these subcommands, otherwise fall through to the real completion.
_docker_with_compose_override() {
    if [[ $words[2] == compose && $words[3] == (exec|logs|stop) ]]; then
        _docker_compose_running_services
        return
    fi
    _docker
}
compdef _docker_with_compose_override docker

clean_docker() {
  if [ ! -z "$1" ]; then
    images=$(docker images -a | grep $1 | awk '{ print $3 }')
    if [ ! -z "$images" ]; then
      docker rmi -f $(docker images -a | grep $1 | awk '{ print $3 }')
    fi
  fi
  docker rm -v $(docker ps -a -q -f status=exited)
  docker rmi $(docker images -f "dangling=true" -q)
}

# Select one or more Docker Compose services from config file
docker_compose_services() {
  file=${1:-docker-compose.yml}
  docker compose -f $file config --format json | jq -r '.services | keys | .[]' | gum filter --no-limit --select-if-one
}
alias -g dcsp='$(docker_compose_services)'

# Select one or more Docker containers from the list of running containers
docker_containers(){
  docker ps --format '{{json .}}' | jq -r ".Names" | gum filter --no-limit --select-if-one
}

alias -g dcp='$(docker_containers)'

alias dc="docker compose"
