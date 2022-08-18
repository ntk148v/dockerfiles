#!/bin/bash

function docker_tag_exists() {
    curl --silent -f -lSL https://index.docker.io/v1/repositories/$1/tags/$2 >/dev/null
}

# Get all releases
curl -sL https://api.github.com/repos/netflix/conductor/releases | jq -r ".[].tag_name" >/tmp/releases.txt

while IFS= read -r line; do
    tag=$line
    if docker_tag_exists kiennt26/conductor ${tag}; then
        echo "Docker image kiennt26/conductor:${tag} exist, skip..."
    else
        echo "Docker image kiennt26/conductor:${tag} not exist, let's build it!"
        # Get release
        curl -sL https://github.com/Netflix/conductor/archive/refs/tags/${tag}.zip >${tag}.zip
        unzip -q ${tag}.zip -d ${tag}
        # Build images
        docker build -t kiennt26/conductor-serer:${tag} -f ${tag}/conductor-${tag//v}/docker/server/Dockerfile ./${tag}/conductor-${tag//v}
        docker push kiennt26/conductor-serer:${tag}
    fi
done </tmp/releases.txt
