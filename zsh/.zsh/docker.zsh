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
  docker compose -f $file config --format json | jq -r '.services | keys | .[]' | gum filter
}
alias -g dcsp='$(docker_compose_services)'

# Select one or more Docker containers from the list of running containers
docker_containers(){
  docker ps --format '{{json .}}' | jq -r ".Names" | gum filter
}

alias -g dcp='$(docker_containers)'

alias dc="docker compose"
