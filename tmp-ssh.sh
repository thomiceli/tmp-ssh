#!/bin/sh

IMAGE="ghcr.io/thomiceli/tmp-ssh:latest"

usage() {
  echo "Usage: $0 {start [--image image_name] [num_images] | stop | build [username]}"
  exit 1
}

start() {
  num_images="$1"

  for i in $(seq 1 "$num_images"); do
    if docker ps --filter "name=tmp-ssh-$i" | grep -q tmp-ssh-"$i"; then
      echo "Container tmp-ssh-$i is already running"
      exit 1
    fi

    container=$(docker run -tid --rm --name tmp-ssh-$i "$IMAGE")
    if [ $? -ne 0 ]; then
      echo "Failed to start container tmp-ssh-$i"
      exit 1
    fi
    container_id=$(docker inspect --format '{{.Id}}' "$container" | cut -c1-12)
    container_ip=$(docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$container")
    echo "tmp-ssh-$i ($container_id) => $container_ip"
    echo "" >> ~/.ssh/config
    echo "Host $container_ip" >> ~/.ssh/config
    echo "  StrictHostKeyChecking no" >> ~/.ssh/config
  done
}

stop() {
  docker stop $(docker ps -q --filter "name=tmp-ssh-*")
  sed -i.bak '/^Host [0-9.]*$/d; /^  StrictHostKeyChecking no$/d; /^$/d' ~/.ssh/config && rm -f ~/.ssh/config.bak
  grep -v '^172\.17\.0\.' ~/.ssh/known_hosts > ~/.ssh/known_hosts_tmp && mv ~/.ssh/known_hosts_tmp ~/.ssh/known_hosts
}

build() {
  arg="$1"
  if [ -z "$arg" ]; then
    docker build -t "tmp-ssh:latest" .
  else
    docker build -t "tmp-ssh:latest" --build-arg "USERNAME=$arg" .
  fi
}

while [ $# -gt 0 ]; do
  case "$1" in
    --image)
      IMAGE="$2"
      shift 2
      ;;
    start)
      if [ -z "$2" ]; then
        num_images=3
      else
        num_images="$2"
      fi
      start "$num_images"
      exit 0
      ;;
    stop)
      stop
      exit 0
      ;;
    build)
      build "$2"
      exit 0
      ;;
    clean)
      clean
      exit 0
      ;;
    *)
      usage
      ;;
  esac
done