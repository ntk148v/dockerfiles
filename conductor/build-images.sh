#!/bin/bash

function docker_tag_exists() {
    curl --silent -f -lSL https://index.docker.io/v1/repositories/$1/tags/$2 >/dev/null
}

# Get all releases
curl -sL https://api.github.com/repos/netflix/conductor/releases | jq -r ".[].tag_name" >/tmp/releases.txt

# Clone
git clone https://github.com/netflix/conductor.git conductor-source

while IFS= read -r line; do
    tag=$line
    if docker_tag_exists kiennt26/conductor ${tag}; then
        echo "Docker image kiennt26/conductor:${tag} exist, skip..."
    else
        echo "Docker image kiennt26/conductor:${tag} not exist, let's build it!"
        cd conductor-source
        git checkout tags/${tag}
        # Build images
        docker build -t kiennt26/conductor-serer:${tag} -f docker/server/Dockerfile .
        docker push kiennt26/conductor-serer:${tag}
        cd -
    fi
done </tmp/releases.txt
