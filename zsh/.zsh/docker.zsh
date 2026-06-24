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

# Select Docker Compose services
function dcs() {
  file=${1:-docker-compose.yml}
  docker compose -f $file config --format json | jq -r '.services | keys | .[]' | fzf --multi
}

alias dc="docker compose"
