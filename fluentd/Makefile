# Makefile for local development of fluentd Docker images
#
# Usage:
#   make generate VERSION=1.17 ARCH=debian
#   make build VERSION=1.17 ARCH=debian
#   make verify VERSION=1.17 ARCH=debian
#   make clean

# Variables
IMAGE_NAME ?= kiennt26/fluentd
VERSION ?= 1.17
ARCH ?= debian

# Derived variables
DOCKERFILE_DIR := v$(VERSION)/$(ARCH)
IMAGE_TAG := $(IMAGE_NAME):$(VERSION)-$(ARCH)

.PHONY: generate build verify clean help

# Generate Dockerfiles from upstream + patch
generate:
	./scripts/generate.sh $(VERSION) $(ARCH)

# Build Docker image locally
build:
	docker build -t $(IMAGE_TAG) $(DOCKERFILE_DIR)

# Run verification tests
verify:
	./scripts/verify.sh $(VERSION) $(ARCH)

# Remove generated files
clean:
	find v* -type f -name "Dockerfile" -delete
	find v* -type f -name "fluent.conf" -delete
	find v* -type f -name "entrypoint.sh" -delete

# Show help
help:
	@echo "Available targets:"
	@echo "  generate - Generate Dockerfiles from upstream + patch"
	@echo "  build    - Build Docker image locally"
	@echo "  verify   - Run verification tests"
	@echo "  clean    - Remove generated files"
	@echo "  help     - Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  VERSION  - Fluentd version (default: $(VERSION))"
	@echo "  ARCH     - Architecture (default: $(ARCH))"
	@echo "  IMAGE_NAME - Docker image name (default: $(IMAGE_NAME))"