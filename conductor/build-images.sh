#!/bin/bash

function docker_tag_exists() {
    curl --silent -f -lSL https://index.docker.io/v1/repositories/$1/tags/$2 >/dev/null
}

# Get all releases
curl -sL https://api.github.com/repos/netflix/conductor/releases | jq -r ".[].tag_name" >/tmp/releases.txt

# Clone
git clone https://github.com/netflix/conductor.git conductor-source

function build_image() {
    image=$1
    tag=$2
    dockerfile=$3
    if docker_tag_exists kiennt26/${image} ${tag}; then
        echo "## Docker image kiennt26/${image}:${tag} exists, skip..."
    else
        echo "## Docker image kiennt26/${image}:${tag} not exist, let's build it"
        cd conductor-source
        git checkout tags/${tag}
        # Build images
        docker build -q -t kiennt26/${image}:${tag} -f ${dockerfile} .
        docker push kiennt26/${image}:${tag}
        cd -
    fi
}

while IFS= read -r line; do
    tag=$line
    build_image netflix-conductor-server ${tag} docker/server/Dockerfile
    build_image netflix-conductor-ui ${tag} docker/ui/Dockerfile
    build_image netflix-conductor-aio ${tag} docker/serverAndUI/Dockerfile
done </tmp/releases.txt
