#!/bin/bash
set -exo pipefail

docker_image=$1
port=$2

container_id=''

wait_start() {
    for in in {1..10}; do
        if  /usr/bin/curl -s -m 5 -f "http://localhost:${port}/metrics" > /dev/null; then
            docker_cleanup
            exit 0
        else
            sleep 1
        fi
    done

    exit 1
}

docker_start() {
    container_id=$(docker run -d -p "${port}":"${port}" "${docker_image}" \
    --collector.vc.url=test \
    --collector.vc.username=test \
    --collector.vc.password=test)
}

docker_cleanup() {
    docker kill "${container_id}"
}

if [[ "$#" -ne 2 ]] ; then
    echo "Usage: $0 ynsta/govc-exporter:v0.1.1 9752" >&2
    exit 1
fi

docker_start
wait_start
