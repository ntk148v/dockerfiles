#!/bin/sh
VERSION=${1:-master}

docker build -t kiennt26/neovim:$VERSION --build-arg VERSION=$VERSION . -f Dockerfile
