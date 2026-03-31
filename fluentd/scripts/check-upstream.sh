#!/bin/bash
# Check for changes in upstream fluent/fluentd-docker-image repository
# Outputs "changed" or "unchanged" to stdout

set -e

UPSTREAM_REPO="fluent/fluentd-docker-image"
API_URL="https://api.github.com/repos/${UPSTREAM_REPO}/commits"
SYNC_FILE="$(dirname "$0")/../.last-upstream-sync"
TARGET_PATH="Dockerfile.template.erb"

output_result() {
    echo "$1"
    exit 0
}

if [ ! -f "$SYNC_FILE" ]; then
    output_result "changed"
fi

LAST_SYNC=$(cat "$SYNC_FILE" 2>/dev/null || echo "")

if [ -z "$LAST_SYNC" ]; then
    output_result "changed"
fi

LATEST_COMMIT=$(python3 -c "
import urllib.request, json, sys
try:
    data = json.load(urllib.request.urlopen('${API_URL}?path=${TARGET_PATH}&per_page=1', timeout=30))
    print(data[0]['sha'] if data else '')
except Exception:
    pass
" 2>/dev/null || echo "")

if [ -z "$LATEST_COMMIT" ]; then
    output_result "unchanged"
fi

if [ "$LATEST_COMMIT" != "$LAST_SYNC" ]; then
    output_result "changed"
else
    output_result "unchanged"
fi