#!/bin/bash
# Generate Dockerfile by applying patches to upstream fluentd-docker-image
#
# Usage:
#   VERSION=1.17 ARCH=debian ./generate.sh
#
# Environment Variables:
#   VERSION: Fluentd version (e.g., 1.17, 1.18, 1.19)
#   ARCH: Architecture (debian, arm64, armhf)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
UPSTREAM_BASE="/tmp/fluentd-docker-image"
PATCH_FILE="${REPO_ROOT}/Dockerfile.patch"

error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}

info() {
    echo "[INFO] $1"
}

if [ -z "$VERSION" ]; then
    error_exit "VERSION environment variable is required. Example: VERSION=1.17"
fi

if [ -z "$ARCH" ]; then
    error_exit "ARCH environment variable is required. Example: ARCH=debian"
fi

case "$ARCH" in
    debian|arm64|armhf)
        ;;
    *)
        error_exit "Invalid ARCH: $ARCH. Must be one of: debian, arm64, armhf"
        ;;
esac

case "$ARCH" in
    debian)
        UPSTREAM_DOCKERFILE="${UPSTREAM_BASE}/v${VERSION}/debian/Dockerfile"
        ;;
    arm64|armhf)
        UPSTREAM_DOCKERFILE="${UPSTREAM_BASE}/v${VERSION}/${ARCH}/debian/Dockerfile"
        ;;
esac

if [ ! -f "$UPSTREAM_DOCKERFILE" ]; then
    error_exit "Upstream Dockerfile not found: ${UPSTREAM_DOCKERFILE}"
fi

if [ ! -f "$PATCH_FILE" ]; then
    error_exit "Patch file not found: ${PATCH_FILE}"
fi

OUTPUT_DIR="${REPO_ROOT}/v${VERSION}/${ARCH}"
OUTPUT_DOCKERFILE="${OUTPUT_DIR}/Dockerfile"

if [ ! -d "$OUTPUT_DIR" ]; then
    info "Creating output directory: ${OUTPUT_DIR}"
    mkdir -p "$OUTPUT_DIR"
fi

if [ -f "$OUTPUT_DOCKERFILE" ]; then
    error_exit "Output file already exists: ${OUTPUT_DOCKERFILE}. Remove it first or use a different location."
fi

TEMP_DIR=$(mktemp -d)
trap "rm -rf ${TEMP_DIR}" EXIT

info "Copying upstream Dockerfile from: ${UPSTREAM_DOCKERFILE}"
cp "$UPSTREAM_DOCKERFILE" "${TEMP_DIR}/Dockerfile"

# Copy supporting files (entrypoint.sh and fluent.conf)
UPSTREAM_DIR=$(dirname "$UPSTREAM_DOCKERFILE")
if [ -f "${UPSTREAM_DIR}/entrypoint.sh" ]; then
    info "Copying entrypoint.sh from: ${UPSTREAM_DIR}"
    cp "${UPSTREAM_DIR}/entrypoint.sh" "${TEMP_DIR}/entrypoint.sh"
fi
if [ -f "${UPSTREAM_DIR}/fluent.conf" ]; then
    info "Copying fluent.conf from: ${UPSTREAM_DIR}"
    cp "${UPSTREAM_DIR}/fluent.conf" "${TEMP_DIR}/fluent.conf"
fi

info "Adding fluent-plugin installations..."
awk '/gem install fluentd -v/ {
    print
    print "  && gem install fluent-plugin-elasticsearch \\"
    print "  && gem install fluent-plugin-grok-parser \\"
    print "  && gem install fluent-plugin-prometheus \\"
    print "  && gem install fluent-plugin-rewrite-tag-filter \\"
    print "  && gem install fluent-plugin-record-modifier \\"
    next
}
{ print }' "${TEMP_DIR}/Dockerfile" > "${TEMP_DIR}/Dockerfile.new"

if [ ! -s "${TEMP_DIR}/Dockerfile.new" ]; then
    error_exit "Failed to add plugin installations. Check if the upstream Dockerfile format has changed."
fi

mv "${TEMP_DIR}/Dockerfile.new" "${TEMP_DIR}/Dockerfile"

info "Moving patched Dockerfile to: ${OUTPUT_DOCKERFILE}"
mv "${TEMP_DIR}/Dockerfile" "$OUTPUT_DOCKERFILE"

# Copy supporting files to output directory
if [ -f "${TEMP_DIR}/entrypoint.sh" ]; then
    info "Copying entrypoint.sh to: ${OUTPUT_DIR}"
    cp "${TEMP_DIR}/entrypoint.sh" "${OUTPUT_DIR}/entrypoint.sh"
fi
if [ -f "${TEMP_DIR}/fluent.conf" ]; then
    info "Copying fluent.conf to: ${OUTPUT_DIR}"
    cp "${TEMP_DIR}/fluent.conf" "${OUTPUT_DIR}/fluent.conf"
fi

if [ ! -f "$OUTPUT_DOCKERFILE" ]; then
    error_exit "Output Dockerfile was not created: ${OUTPUT_DOCKERFILE}"
fi

if [ ! -s "$OUTPUT_DOCKERFILE" ]; then
    error_exit "Output Dockerfile is empty: ${OUTPUT_DOCKERFILE}"
fi

if ! grep -q "fluent-plugin-" "$OUTPUT_DOCKERFILE"; then
    error_exit "Output Dockerfile does not contain fluent-plugin installations"
fi

info "Successfully generated Dockerfile: ${OUTPUT_DOCKERFILE}"
info "Version: ${VERSION}, Architecture: ${ARCH}"