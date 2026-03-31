# Fluentd Docker Images

![Sync](https://github.com/ntk148v/dockerfiles/actions/workflows/sync-fluentd.yml/badge.svg)
![Build](https://github.com/ntk148v/dockerfiles/actions/workflows/build-fluentd.yml/badge.svg)

Automated Docker images for Fluentd with pre-installed plugins, multi-architecture support, and weekly upstream synchronization.

## Overview

This repository provides customized Fluentd Docker images based on the official [fluent/fluentd-docker-image](https://github.com/fluent/fluentd-docker-image) upstream. The images include essential plugins for log aggregation and are automatically built for multiple architectures.

**Key Features:**
- Pre-installed plugins for common log processing scenarios
- Multi-architecture support (amd64, arm64, armhf)
- Weekly automatic sync with upstream changes
- Automated CI/CD pipeline with GitHub Actions
- Local development tools via Makefile

**Docker Hub:** [kiennt26/fluentd](https://hub.docker.com/r/kiennt26/fluentd)

## Architecture

### Patch-Based Approach

This repository uses a patch-based approach to customize upstream Dockerfiles:

1. **Upstream Source**: Official `fluent/fluentd-docker-image` repository
2. **Customization**: Patches applied to add plugin installations
3. **Generation**: Automated script generates Dockerfiles for all versions/architectures
4. **Build**: Multi-platform builds pushed to Docker Hub

### Supported Versions

- **v1.17** - Stable release
- **v1.18** - Latest stable
- **v1.19** - Current version

### Supported Architectures

- **debian** - Linux amd64 (x86_64)
- **arm64** - ARM 64-bit (aarch64)
- **armhf** - ARM 32-bit (armv7)

### Weekly Sync Workflow

The system automatically checks for upstream changes every Sunday at midnight UTC:

1. Checks the latest commit SHA from upstream `Dockerfile.template.erb`
2. Compares with `.last-upstream-sync` file
3. If changes detected:
   - Clones upstream repository
   - Generates Dockerfiles for all versions/architectures
   - Creates a pull request with updates
4. If no changes, exits silently

## Plugins

### Included Plugins

The following plugins are pre-installed in all images:

| Plugin | Version | Purpose |
|--------|---------|---------|
| fluent-plugin-elasticsearch | 6.0.0 | Output to Elasticsearch |
| fluent-plugin-grok-parser | 2.6.2 | Parse unstructured logs with Grok patterns |
| fluent-plugin-prometheus | 2.2.2 | Export metrics to Prometheus |
| fluent-plugin-rewrite-tag-filter | 2.4.0 | Dynamically rewrite tags based on conditions |
| fluent-plugin-record-modifier | 2.2.1 | Modify record fields |

### Adding/Removing Plugins

To modify the plugin list:

1. **Edit `plugins.txt`**:
   ```bash
   # Format: plugin-name -v version
   fluent-plugin-elasticsearch -v 6.0.0
   fluent-plugin-grok-parser -v 2.6.2
   # Add your new plugin here
   ```

2. **Update the generation script** (`scripts/generate.sh`):
   - Modify the `awk` command around line 79-86 to include your new plugin
   - Add a line like: `print "  && gem install your-new-plugin \\"`

3. **Regenerate Dockerfiles**:
   ```bash
   make generate VERSION=1.17 ARCH=debian
   ```

4. **Update verification script** (`scripts/verify.sh`):
   - Add your plugin to the `PLUGINS` array (line 11-17)

5. **Commit and push** to trigger the build workflow

### Plugin Version Pinning

All plugins are pinned to specific versions to ensure reproducible builds. When updating plugins:

- Test compatibility with your Fluentd version
- Update the version in `plugins.txt`
- Regenerate and test locally before pushing

## Local Development

### Prerequisites

- Docker installed
- Make installed
- Bash shell

### Makefile Targets

The `Makefile` provides convenient targets for local development:

#### Generate Dockerfiles

Generate Dockerfiles from upstream with custom patches:

```bash
# Generate for specific version and architecture
make generate VERSION=1.17 ARCH=debian

# Generate for all combinations (manual)
for version in 1.17 1.18 1.19; do
  for arch in debian arm64 armhf; do
    make generate VERSION=$version ARCH=$arch
  done
done
```

#### Build Images Locally

Build Docker images for testing:

```bash
# Build specific version/architecture
make build VERSION=1.17 ARCH=debian

# This builds: kiennt26/fluentd:1.17-debian
```

#### Verify Images

Run verification tests on built images:

```bash
# Verify specific image
make verify VERSION=1.17 ARCH=debian

# Tests include:
# - Fluentd process running
# - All plugins installed
```

#### Clean Generated Files

Remove all generated Dockerfiles:

```bash
make clean
```

#### Help

Display all available targets:

```bash
make help
```

### Manual Script Usage

You can also use scripts directly:

```bash
# Generate Dockerfile
./scripts/generate.sh 1.17 debian

# Check for upstream changes
./scripts/check-upstream.sh

# Verify image
./scripts/verify.sh kiennt26/fluentd:v1.17-debian-1.0
```

### Testing Locally

After building an image:

```bash
# Run container
docker run -it --rm kiennt26/fluentd:1.17-debian

# Check installed plugins
docker run --rm kiennt26/fluentd:1.17-debian fluent-gem list | grep fluent-plugin

# Verify Fluentd version
docker run --rm kiennt26/fluentd:1.17-debian fluentd --version
```

## GitHub Actions

### Workflows

#### 1. Sync Fluentd Upstream (`.github/workflows/sync-fluentd.yml`)

**Trigger:** Weekly (Sunday 00:00 UTC) or manual dispatch

**Process:**
1. Checks upstream for changes using `check-upstream.sh`
2. If changes detected:
   - Clones upstream repository
   - Generates Dockerfiles for all versions/architectures
   - Updates `.last-upstream-sync` with latest commit SHA
   - Creates pull request with updates
3. If no changes, exits without action

**Output:** Pull request labeled `automated, sync`

#### 2. Build and Push Fluentd (`.github/workflows/build-fluentd.yml`)

**Trigger:**
- Push to `main` branch (changes in `fluentd/` directory)
- Pull request merged to `main` (changes in `fluentd/` directory)
- Manual workflow dispatch

**Process:**
1. Sets up QEMU for multi-arch builds
2. Sets up Docker Buildx
3. Logs into Docker Hub using secrets
4. Builds and pushes images for all version/architecture combinations:
   - v1.17: debian, arm64, armhf
   - v1.18: debian, arm64, armhf
   - v1.19: debian, arm64, armhf

**Tags:** `kiennt26/fluentd:v{version}-{arch}-1.0`

**Platforms:** linux/amd64, linux/arm64, linux/arm/v7

### Required Secrets

Configure these secrets in your GitHub repository settings:

- `DOCKERHUB_USERNAME` - Docker Hub username
- `DOCKERHUB_PASSWORD` - Docker Hub password or access token

### Workflow Status

- ![Sync](https://github.com/ntk148v/dockerfiles/actions/workflows/sync-fluentd.yml/badge.svg) - Weekly upstream sync
- ![Build](https://github.com/ntk148v/dockerfiles/actions/workflows/build-fluentd.yml/badge.svg) - Build and push images

## Troubleshooting

### Common Issues

#### 1. Build Fails - "Upstream Dockerfile not found"

**Problem:** The upstream repository structure has changed.

**Solution:**
```bash
# Manually clone upstream to check structure
git clone https://github.com/fluent/fluentd-docker-image.git /tmp/fluentd-docker-image
ls -la /tmp/fluentd-docker-image/v1.17/

# Update the path in scripts/generate.sh if needed
```

#### 2. Plugin Installation Fails

**Problem:** Plugin version incompatible with Fluentd version.

**Solution:**
- Check plugin compatibility matrix
- Update version in `plugins.txt`
- Test with `gem install fluent-plugin-name -v version` locally

#### 3. Verification Fails - "Plugin NOT installed"

**Problem:** Plugin installation failed during build.

**Solution:**
```bash
# Check build logs for gem installation errors
# Test plugin installation manually
docker run --rm kiennt26/fluentd:1.17-debian fluent-gem install fluent-plugin-name

# Check if plugin conflicts with others
docker run --rm kiennt26/fluentd:1.17-debian fluent-gem list
```

#### 4. Multi-Arch Build Fails

**Problem:** QEMU or Buildx not properly configured.

**Solution:**
```bash
# Ensure QEMU is installed
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# Check Buildx is available
docker buildx version

# Inspect builder
docker buildx inspect
```

#### 5. Weekly Sync Not Creating PR

**Problem:** Upstream check returns "unchanged" incorrectly.

**Solution:**
```bash
# Check .last-upstream-sync file
cat fluentd/.last-upstream-sync

# Manually run check script
cd fluentd
./scripts/check-upstream.sh

# Force sync by removing the file
rm fluentd/.last-upstream-sync
git commit -am "Force upstream sync"
```

#### 6. Docker Hub Push Fails

**Problem:** Authentication or rate limiting issues.

**Solution:**
- Verify `DOCKERHUB_USERNAME` and `DOCKERHUB_PASSWORD` secrets
- Check if Docker Hub account has push permissions
- Verify rate limits: `docker run --rm quay.io/skopeo/stable docker://kiennt26/fluentd`

### Debug Mode

Enable verbose output for debugging:

```bash
# Generate with bash debug mode
bash -x ./scripts/generate.sh 1.17 debian

# Check upstream with debug
bash -x ./scripts/check-upstream.sh

# Verify with debug
bash -x ./scripts/verify.sh kiennt26/fluentd:v1.17-debian-1.0
```

### Getting Help

If you encounter issues not covered here:

1. Check the [official Fluentd documentation](https://docs.fluentd.org/)
2. Review [upstream Docker image repository](https://github.com/fluent/fluentd-docker-image)
3. Open an issue in this repository with:
   - Error message
   - Steps to reproduce
   - Environment details (OS, Docker version)

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with `make verify`
5. Submit a pull request

## License

This repository follows the same license as the upstream [fluent/fluentd-docker-image](https://github.com/fluent/fluentd-docker-image) project.