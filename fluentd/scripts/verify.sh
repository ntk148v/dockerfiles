#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Plugins to verify
PLUGINS=(
    "fluent-plugin-elasticsearch"
    "fluent-plugin-grok-parser"
    "fluent-plugin-prometheus"
    "fluent-plugin-rewrite-tag-filter"
    "fluent-plugin-record-modifier"
)

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Validate input
if [ -z "$1" ]; then
    print_error "Image tag is required"
    echo "Usage: $0 <image-tag>"
    echo "Example: $0 kiennt26/fluentd:v1.17-debian-1.0"
    exit 1
fi

IMAGE="$1"
CONTAINER_NAME="fluentd-verify-$$"
FAILED=0

print_info "Verifying image: $IMAGE"
echo ""

# Test 1: Check Fluentd process is running
print_info "Test 1: Checking Fluentd process..."
if docker run --rm --name "$CONTAINER_NAME" "$IMAGE" pgrep -f fluentd > /dev/null 2>&1; then
    print_success "Fluentd process is running"
else
    print_error "Fluentd process is NOT running"
    FAILED=1
fi
echo ""

# Test 2: Verify all plugins are installed
print_info "Test 2: Verifying plugins..."

# Get list of installed plugins
INSTALLED_PLUGINS=$(docker run --rm "$IMAGE" fluent-gem list 2>/dev/null | grep fluent-plugin || true)

for plugin in "${PLUGINS[@]}"; do
    if echo "$INSTALLED_PLUGINS" | grep -q "$plugin"; then
        print_success "Plugin installed: $plugin"
    else
        print_error "Plugin NOT installed: $plugin"
        FAILED=1
    fi
done
echo ""

# Summary
echo "=========================================="
if [ $FAILED -eq 0 ]; then
    print_success "All tests passed!"
    echo "=========================================="
    exit 0
else
    print_error "Some tests failed!"
    echo "=========================================="
    exit 1
fi