#!/bin/bash

AMTOOL_VERSION=$(curl -Ls https://api.github.com/repos/prometheus/alertmanager/releases/latest | jq ".tag_name" | xargs | cut -c2-)
PROMTOOL_VERSION=$(curl -Ls https://api.github.com/repos/prometheus/prometheus/releases/latest | jq ".tag_name" | xargs | cut -c2-)
docker build -q --build-arg AMTOOL_VERSION=${AMTOOL_VERSION} \
    --build-arg PROMTOOL_VERSION=${PROMTOOL_VERSION} \
    -t kiennt26/pramtool:v${PROMTOOL_VERSION}-v${AMTOOL_VERSION} -f pramtool/Dockerfile .
docker push kiennt26/pramtool:v${PROMTOOL_VERSION}-v${AMTOOL_VERSION}
