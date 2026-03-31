# Fluentd Docker Image Sync Automation

## TL;DR

> **Objective**: Automate syncing with upstream fluent/fluentd-docker-image to build multi-arch Docker images with extra plugins (elasticsearch, grok-parser, prometheus, rewrite-tag-filter, record-modifier).
>
> **Deliverables**:
> - Weekly sync workflow checking upstream for changes
> - Multi-arch build workflow (amd64, arm64, armhf) for v1.17, v1.18, v1.19
> - Patch-based customization system (no template forks)
> - Plugin verification testing
> - Automated cleanup (keep last 5 builds per version)
>
> **Estimated Effort**: Medium (3-4 hours)
> **Parallel Execution**: YES - 3 waves
> **Critical Path**: Template Setup → Patch System → Build Workflow → Verification

---

## Context

### Original Request
User wants to automate updates to their Fluentd Docker image repository instead of manually updating when upstream releases new versions. Currently extends `fluent/fluentd:v1.17-1` and installs 5 plugins manually.

### Interview Summary
**Key Decisions**:
- **Versions**: Support v1.17, v1.18, v1.19 (multi-version)
- **Architecture**: Multi-arch (amd64, arm64, armhf)
- **Sync Strategy**: Weekly scheduled workflow (cron)
- **Customization**: Patch-based approach (not template fork)
- **Registry**: Docker Hub (kiennt26/fluentd)
- **Tagging**: Match upstream tags (e.g., `v1.17-debian-1.0`)
- **Testing**: Plugin verification (smoke test + plugin load check)
- **Retention**: Keep last 5 builds per version

**Research Findings**:
- Upstream uses ERB templates (Dockerfile.template.erb) + Makefile for generation
- Upstream supports debian, alpine (deprecated v1.19+), arm64, armhf, Windows
- Current user's setup: Static Dockerfile extending upstream image
- Plugin list: fluent-plugin-elasticsearch, fluent-plugin-grok-parser, fluent-plugin-prometheus, fluent-plugin-rewrite-tag-filter, fluent-plugin-record-modifier

### Metis Review
**Identified Gaps** (addressed in decisions):
- Conflict resolution: Patch-based approach minimizes merge issues
- Testing: Plugin verification level agreed
- Notifications: Workflow logs only (no external alerts)
- Retention: Last 5 builds policy established

---

## Work Objectives

### Core Objective
Create automated system that:
1. Checks upstream fluent/fluentd-docker-image weekly for changes
2. Applies plugin customization patch to upstream templates
3. Generates Dockerfiles for v1.17, v1.18, v1.19 (debian, arm64, armhf)
4. Builds and pushes multi-arch images to Docker Hub
5. Verifies plugins are properly installed
6. Cleans up old images (keep last 5 builds)

### Concrete Deliverables
- `.github/workflows/sync-fluentd.yml` - Weekly sync workflow
- `.github/workflows/build-fluentd.yml` - Multi-arch build workflow
- `.github/workflows/cleanup-fluentd.yml` - Image retention cleanup
- `fluentd/plugins.txt` - Configurable plugin list
- `fluentd/Dockerfile.patch` - Plugin installation patch
- `fluentd/Makefile` - Local build automation
- `fluentd/scripts/check-upstream.sh` - Upstream change detection
- `fluentd/scripts/generate.sh` - Dockerfile generation
- `fluentd/scripts/verify.sh` - Plugin verification
- `fluentd/v1.17/debian/Dockerfile` - Generated
- `fluentd/v1.17/arm64/Dockerfile` - Generated
- `fluentd/v1.17/armhf/Dockerfile` - Generated
- `fluentd/v1.18/` - Full version directory
- `fluentd/v1.19/` - Full version directory

### Definition of Done
- [ ] Weekly sync workflow runs without errors
- [ ] Build workflow produces multi-arch images for all 3 versions
- [ ] All 5 plugins are verified installed in each image
- [ ] Images pushed to Docker Hub with correct tags
- [ ] Cleanup workflow removes images older than 5th build
- [ ] Local `make generate` works for development

### Must Have
- Multi-arch support (amd64, arm64, armhf)
- All 5 plugins installed and verified
- Weekly automated sync
- Patch-based customization (no template forks)
- Docker Hub integration
- Build verification (smoke test + plugin check)

### Must NOT Have (Guardrails)
- NO Windows container support
- NO Alpine variants (upstream deprecated)
- NO automated plugin functionality testing beyond load verification
- NO external notifications (email, Slack)
- NO auto-promotion to 'latest' without verification
- NO Helm charts or K8s manifests
- NO security scanning in MVP
- NO support for versions upstream deprecated

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: NO (creating new)
- **Automated tests**: Tests-after (verification scripts)
- **Framework**: Bash scripts for smoke testing
- **Agent-Executed QA**: YES - Every task includes verification scenarios

### QA Policy
Every task MUST include agent-executed QA scenarios:
- **Scripts**: Bash execution with exit code validation
- **Workflows**: Use `act` tool or validate YAML syntax
- **Docker**: Build and run containers, verify output
- **Evidence**: Screenshots, logs, command outputs saved to `.sisyphus/evidence/`

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Foundation - can all start immediately):
├── Task 1: Create plugins.txt configuration
├── Task 2: Create Dockerfile.patch for plugin installation
├── Task 3: Create Makefile with generate/build targets
├── Task 4: Create check-upstream.sh script
└── Task 5: Create generate.sh script

Wave 2 (Workflows - depends on Wave 1):
├── Task 6: Create sync-fluentd.yml workflow
├── Task 7: Create build-fluentd.yml workflow
└── Task 8: Create cleanup-fluentd.yml workflow

Wave 3 (Generation & Verification - depends on Wave 1):
├── Task 9: Generate v1.17 Dockerfiles (all arches)
├── Task 10: Generate v1.18 Dockerfiles (all arches)
├── Task 11: Generate v1.19 Dockerfiles (all arches)
└── Task 12: Create verify.sh test script

Wave 4 (Integration & Testing - depends on Waves 2-3):
├── Task 13: Test local generation (make generate)
├── Task 14: Test build workflow (one arch)
├── Task 15: Test verification script
└── Task 16: Documentation and README updates

Wave FINAL (Review - after ALL tasks):
├── Task F1: Plan compliance audit (oracle)
├── Task F2: Workflow validation (unspecified-high)
├── Task F3: End-to-end test (unspecified-high)
└── Task F4: Documentation review (writing)
-> Present results -> Get explicit user okay

Critical Path: Task 1-5 → Task 9-11 → Task 13-15 → F1-F4 → user okay
Parallel Speedup: ~60% faster than sequential
Max Concurrent: 5 (Wave 1)
```

### Dependency Matrix

| Task | Depends On | Blocks |
|------|-----------|--------|
| 1-5 | — | 6-12 |
| 6-8 | 1-5 | 13-16 |
| 9-12 | 1-5 | 13-16 |
| 13-16 | 6-12, 9-12 | F1-F4 |
| F1-F4 | 13-16 | — |

### Agent Dispatch Summary

- **Wave 1**: 5 tasks → `quick` (configuration files, scripts)
- **Wave 2**: 3 tasks → `quick` (GitHub Actions YAML)
- **Wave 3**: 4 tasks → `quick` (generation, testing)
- **Wave 4**: 4 tasks → `unspecified-high` (integration testing)
- **FINAL**: 4 tasks → `oracle`, `unspecified-high`, `writing`

---

## TODOs

- [x] 1. Create plugins.txt configuration file

  **What to do**:
  - Create `fluentd/plugins.txt` with the 5 plugins and their versions
  - Format: one plugin per line with optional version pinning
  - Include comments explaining the format
  
  **Must NOT do**:
  - Don't add more than 5 plugins without explicit approval
  - Don't use loose version constraints (pin to specific versions)
  
  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - Reason: Simple configuration file creation
  
  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: Task 2 (patch needs plugin list)
  - **Blocked By**: None
  
  **References**:
  - Current plugins from user's Dockerfile: fluent-plugin-elasticsearch, fluent-plugin-grok-parser, fluent-plugin-prometheus, fluent-plugin-rewrite-tag-filter, fluent-plugin-record-modifier
  - Upstream gem install pattern: `gem install <name> -v <version>`
  
  **Acceptance Criteria**:
  - [ ] File exists at `fluentd/plugins.txt`
  - [ ] Contains all 5 plugins with pinned versions
  - [ ] Format is parseable by shell script (one per line)
  
  **QA Scenarios**:
  ```
  Scenario: Verify plugins.txt format
    Tool: Bash
    Preconditions: File created
    Steps:
      1. Run: cat fluentd/plugins.txt
      2. Verify: Each line contains "fluent-plugin-"
      3. Verify: No empty lines
      4. Verify: File has exactly 5 plugins
    Expected Result: 5 plugin entries, all with version pins
    Evidence: .sisyphus/evidence/task-1-plugins-txt.txt
  ```
  
  **Commit**: YES
  - Message: `feat(fluentd): add plugins.txt configuration`
  - Files: `fluentd/plugins.txt`

- [x] 2. Create Dockerfile.patch for plugin installation

  **What to do**:
  - Create `fluentd/Dockerfile.patch` - a unified diff patch
  - Patch adds plugin installation step to upstream Dockerfile
  - Patch should be applied after upstream's gem install commands
  - Must work with debian-based images (not alpine)
  
  **Must NOT do**:
  - Don't modify upstream's base image or core Fluentd installation
  - Don't add new RUN layers unnecessarily (combine plugin installs)
  - Don't use alpine-specific commands
  
  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - Reason: Creating a patch file requires understanding Dockerfile structure
  
  **Parallelization**:
  - **Can Run In Parallel**: YES (with Task 1)
  - **Parallel Group**: Wave 1
  - **Blocks**: Task 5 (generation needs patch)
  - **Blocked By**: None
  
  **References**:
  - Upstream v1.17/debian/Dockerfile structure
  - Current user's Dockerfile plugin installation pattern
  - Patch format: `diff -u original modified > patchfile`
  
  **Acceptance Criteria**:
  - [ ] Patch file exists at `fluentd/Dockerfile.patch`
  - [ ] Patch applies cleanly to upstream Dockerfile
  - [ ] Patch installs all plugins from plugins.txt
  - [ ] Patch cleans up build dependencies
  
  **QA Scenarios**:
  ```
  Scenario: Verify patch applies cleanly
    Tool: Bash
    Preconditions: Upstream Dockerfile available at /tmp/fluentd-docker-image/v1.17/debian/Dockerfile
    Steps:
      1. Copy upstream Dockerfile to test location
      2. Run: patch -p0 < fluentd/Dockerfile.patch
      3. Verify: Exit code 0 (success)
      4. Verify: Resulting Dockerfile contains plugin install commands
    Expected Result: Patch applies without errors, plugins installed
    Evidence: .sisyphus/evidence/task-2-patch-apply.txt
  ```
  
  **Commit**: YES
  - Message: `feat(fluentd): add Dockerfile.patch for plugin installation`
  - Files: `fluentd/Dockerfile.patch`

- [x] 3. Create Makefile with generate/build targets

  **What to do**:
  - Create `fluentd/Makefile` with targets:
    - `generate`: Generate Dockerfiles from upstream + patch
    - `build`: Build images locally
    - `verify`: Run verification tests
    - `clean`: Remove generated files
  - Match upstream Makefile structure where applicable
  - Support VERSION and ARCH variables
  
  **Must NOT do**:
  - Don't copy entire upstream Makefile (only needed targets)
  - Don't include release/push targets (CI handles that)
  - Don't hardcode version numbers (use variables)
  
  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - Reason: Makefile creation is straightforward scripting
  
  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: Task 13 (local testing needs Makefile)
  - **Blocked By**: None
  
  **References**:
  - Upstream Makefile: /tmp/fluentd-docker-image/Makefile
  - Target patterns: image, src, dockerfile, test
  
  **Acceptance Criteria**:
  - [ ] Makefile exists at `fluentd/Makefile`
  - [ ] `make generate` works (with mock upstream)
  - [ ] `make clean` removes generated files
  - [ ] Variables VERSION and ARCH are supported
  
  **QA Scenarios**:
  ```
  Scenario: Verify Makefile targets exist
    Tool: Bash
    Preconditions: Makefile created
    Steps:
      1. Run: make -n generate (dry-run)
      2. Verify: No errors
      3. Run: make -n clean
      4. Verify: No errors
    Expected Result: All targets parse correctly
    Evidence: .sisyphus/evidence/task-3-makefile.txt
  ```
  
  **Commit**: YES
  - Message: `feat(fluentd): add Makefile for local development`
  - Files: `fluentd/Makefile`

- [x] 4. Create check-upstream.sh script

  **What to do**:
  - Create `fluentd/scripts/check-upstream.sh`
  - Script checks if upstream fluent/fluentd-docker-image has new commits
  - Compares upstream HEAD with last synced commit (stored in file)
  - Outputs: "changed" or "unchanged"
  - Supports checking specific paths (Dockerfile.template.erb)
  
  **Must NOT do**:
  - Don't clone entire upstream repo (use GitHub API)
  - Don't fail on network errors (exit 0 with "unchanged")
  - Don't modify any files (read-only check)
  
  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - Reason: API call and comparison logic
  
  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: Task 6 (sync workflow needs this)
  - **Blocked By**: None
  
  **References**:
  - GitHub API: https://api.github.com/repos/fluent/fluentd-docker-image/commits
  - Last sync tracking: `.last-upstream-sync` file
  
  **Acceptance Criteria**:
  - [ ] Script exists at `fluentd/scripts/check-upstream.sh`
  - [ ] Script is executable (chmod +x)
  - [ ] Returns "changed" when upstream has new commits
  - [ ] Returns "unchanged" when no changes
  - [ ] Handles API errors gracefully
  
  **QA Scenarios**:
  ```
  Scenario: Test check script returns valid output
    Tool: Bash
    Preconditions: Script created, network available
    Steps:
      1. Run: ./fluentd/scripts/check-upstream.sh
      2. Verify: Output is either "changed" or "unchanged"
      3. Verify: Exit code 0
    Expected Result: Script runs without errors, valid output
    Evidence: .sisyphus/evidence/task-4-check-upstream.txt
  ```
  
  **Commit**: YES
  - Message: `feat(fluentd): add upstream change detection script`
  - Files: `fluentd/scripts/check-upstream.sh`

- [x] 5. Create generate.sh script

  **What to do**:
  - Create `fluentd/scripts/generate.sh`
  - Script generates Dockerfiles for specified version and architectures
  - Steps:
    1. Clone/fetch upstream repo (or use cached)
    2. Copy upstream Dockerfile for version/arch
    3. Apply Dockerfile.patch
    4. Output to fluentd/v{VERSION}/{ARCH}/Dockerfile
  - Supports VERSION and ARCH environment variables
  
  **Must NOT do**:
  - Don't commit upstream repo to this repo
  - Don't modify upstream files in place (copy first)
  - Don't fail if output directory exists (create if needed)
  
  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - Reason: File manipulation and patching
  
  **Parallelization**:
  - **Can Run In Parallel**: YES (with Tasks 1-4)
  - **Parallel Group**: Wave 1
  - **Blocks**: Tasks 9-11 (generation needs this script)
  - **Blocked By**: Task 2 (needs patch file)
  
  **References**:
  - Upstream repo: https://github.com/fluent/fluentd-docker-image
  - Patch command: `patch -p0 < Dockerfile.patch`
  - Directory structure: fluentd/v1.17/debian/Dockerfile
  
  **Acceptance Criteria**:
  - [ ] Script exists at `fluentd/scripts/generate.sh`
  - [ ] Script is executable
  - [ ] Generates Dockerfile for given VERSION and ARCH
  - [ ] Applies patch successfully
  - [ ] Creates output directory if needed
  
  **QA Scenarios**:
  ```
  Scenario: Generate v1.17 debian Dockerfile
    Tool: Bash
    Preconditions: Script created, network available
    Steps:
      1. Run: VERSION=1.17 ARCH=debian ./fluentd/scripts/generate.sh
      2. Verify: fluentd/v1.17/debian/Dockerfile exists
      3. Verify: File contains plugin installation commands
      4. Verify: File is valid Dockerfile syntax
    Expected Result: Dockerfile generated with plugins
    Evidence: .sisyphus/evidence/task-5-generate.txt
  ```
  
  **Commit**: YES
  - Message: `feat(fluentd): add Dockerfile generation script`
  - Files: `fluentd/scripts/generate.sh`

- [ ] 6. Create sync-fluentd.yml workflow

  **What to do**:
  - Create `.github/workflows/sync-fluentd.yml`
  - Weekly cron schedule (Sundays at midnight)
  - Steps: checkout, check upstream, generate if changed, create PR
  - Supports manual trigger (workflow_dispatch)
  
  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - **Parallel Group**: Wave 2
  
  **Acceptance Criteria**:
  - [ ] Workflow file exists
  - [ ] Runs weekly + manual trigger
  - [ ] Creates PR on changes (not auto-commit)
  
  **QA Scenarios**:
  ```
  Scenario: Validate workflow syntax
    Tool: Bash
    Steps:
      1. Validate YAML syntax
      2. Verify cron schedule set
      3. Verify PR creation step present
    Expected Result: Valid workflow file
    Evidence: .sisyphus/evidence/task-6-sync-workflow.txt
  ```
  
  **Commit**: YES
  - Message: `ci(fluentd): add weekly sync workflow`
  - Files: `.github/workflows/sync-fluentd.yml`

- [ ] 7. Create build-fluentd.yml workflow

  **What to do**:
  - Create `.github/workflows/build-fluentd.yml`
  - Multi-arch build (amd64, arm64, armhf)
  - Matrix: versions × architectures
  - Push to Docker Hub (kiennt26/fluentd)
  
  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - **Parallel Group**: Wave 2
  
  **Acceptance Criteria**:
  - [ ] Matrix strategy for 3 versions × 3 arches
  - [ ] Docker Hub push configured
  - [ ] Multi-arch platforms specified
  
  **QA Scenarios**:
  ```
  Scenario: Validate build workflow
    Tool: Bash
    Steps:
      1. Validate YAML syntax
      2. Verify matrix defined
      3. Verify Docker Hub login present
    Expected Result: Valid multi-arch workflow
    Evidence: .sisyphus/evidence/task-7-build-workflow.txt
  ```
  
  **Commit**: YES
  - Message: `ci(fluentd): add multi-arch build workflow`
  - Files: `.github/workflows/build-fluentd.yml`

- [ ] 8. Create cleanup-fluentd.yml workflow

  **What to do**:
  - Create `.github/workflows/cleanup-fluentd.yml`
  - Weekly cleanup of old images
  - Keep last 5 builds per version/arch
  - Use Docker Hub API
  
  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - **Parallel Group**: Wave 2
  
  **Acceptance Criteria**:
  - [ ] Workflow deletes old images
  - [ ] Keeps last 5 builds
  - [ ] Logs deletions
  
  **Commit**: YES
  - Message: `ci(fluentd): add image cleanup workflow`
  - Files: `.github/workflows/cleanup-fluentd.yml`

- [ ] 9. Generate v1.17 Dockerfiles (all arches)

  **What to do**:
  - Generate Dockerfiles for v1.17:
    - fluentd/v1.17/debian/Dockerfile
    - fluentd/v1.17/arm64/Dockerfile
    - fluentd/v1.17/armhf/Dockerfile
  
  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - **Parallel Group**: Wave 3
  
  **Acceptance Criteria**:
  - [ ] All 3 Dockerfiles generated
  - [ ] Valid syntax
  - [ ] Plugins included
  
  **Commit**: YES
  - Message: `feat(fluentd): generate v1.17 Dockerfiles`
  - Files: `fluentd/v1.17/*/Dockerfile`

- [ ] 10. Generate v1.18 Dockerfiles (all arches)

  **What to do**:
  - Same as Task 9 for v1.18
  - Create fluentd/v1.18/ directory
  
  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - **Parallel Group**: Wave 3
  
  **Commit**: YES
  - Message: `feat(fluentd): generate v1.18 Dockerfiles`
  - Files: `fluentd/v1.18/*/Dockerfile`

- [ ] 11. Generate v1.19 Dockerfiles (all arches)

  **What to do**:
  - Same as Tasks 9-10 for v1.19
  - No alpine (upstream deprecated)
  
  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - **Parallel Group**: Wave 3
  
  **Commit**: YES
  - Message: `feat(fluentd): generate v1.19 Dockerfiles`
  - Files: `fluentd/v1.19/*/Dockerfile`

- [ ] 12. Create verify.sh test script

  **What to do**:
  - Create `fluentd/scripts/verify.sh`
  - Test image: start container, check Fluentd running, verify plugins
  - Accepts IMAGE tag as argument
  
  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []
  - **Parallel Group**: Wave 3
  
  **Acceptance Criteria**:
  - [ ] Script tests Fluentd process
  - [ ] Verifies all 5 plugins
  - [ ] Cleans up containers
  
  **Commit**: YES
  - Message: `feat(fluentd): add image verification script`
  - Files: `fluentd/scripts/verify.sh`

- [ ] 13. Test local generation (make generate)

  **What to do**:
  - Run `make generate` locally
  - Verify all Dockerfiles created
  - Test one build locally
  
  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: []
  - **Parallel Group**: Wave 4
  
  **Acceptance Criteria**:
  - [ ] make generate works
  - [ ] Dockerfiles valid
  - [ ] Local build succeeds
  
  **Commit**: NO (testing only)

- [ ] 14. Test build workflow (one arch)

  **What to do**:
  - Test build workflow manually
  - Build one architecture first
  - Verify push to Docker Hub
  
  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: []
  - **Parallel Group**: Wave 4
  
  **Acceptance Criteria**:
  - [ ] Workflow runs successfully
  - [ ] Image pushed to registry
  - [ ] Tags correct
  
  **Commit**: NO (testing only)

- [ ] 15. Test verification script

  **What to do**:
  - Run verify.sh against built image
  - Confirm all plugins detected
  - Fix any issues
  
  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: []
  - **Parallel Group**: Wave 4
  
  **Acceptance Criteria**:
  - [ ] verify.sh passes
  - [ ] All 5 plugins found
  - [ ] No false positives
  
  **Commit**: NO (testing only)

- [ ] 16. Documentation and README updates

  **What to do**:
  - Update fluentd/README.md
  - Document: how sync works, how to add plugins, how to build locally
  - Add badges for build status
  
  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: []
  - **Parallel Group**: Wave 4
  
  **Acceptance Criteria**:
  - [ ] README explains the automation
  - [ ] Plugin addition documented
  - [ ] Local development guide
  
  **Commit**: YES
  - Message: `docs(fluentd): add automation documentation`
  - Files: `fluentd/README.md`

---

## Final Verification Wave (MANDATORY)

> 4 review agents run in PARALLEL. ALL must APPROVE. Present results to user and get explicit "okay".

- [ ] F1. **Plan Compliance Audit** — `oracle`
  Read the plan end-to-end. Verify:
  - All 16 tasks have clear deliverables
  - All file references are valid paths
  - QA scenarios are specific and testable
  - No tasks require human intervention
  Output: `Tasks [16/16] | Files Valid [YES/NO] | QA Testable [YES/NO] | VERDICT`

- [ ] F2. **Workflow Validation** — `unspecified-high`
  Validate all 3 workflow files:
  - YAML syntax is valid
  - All required secrets referenced (DOCKERHUB_USERNAME, DOCKERHUB_PASSWORD)
  - Matrix strategies are valid
  - No syntax errors in shell scripts embedded in workflows
  Output: `Workflows [3/3 Valid] | Secrets [Complete/Incomplete] | VERDICT`

- [ ] F3. **End-to-End Test** — `unspecified-high`
  Simulate the full flow:
  1. Run check-upstream.sh (mock mode)
  2. Run generate.sh for one version
  3. Verify generated Dockerfile
  4. Run verify.sh (if test image available)
  Output: `Check [PASS/FAIL] | Generate [PASS/FAIL] | Verify [PASS/FAIL] | VERDICT`

- [ ] F4. **Documentation Review** — `writing`
  Review README and documentation:
  - Clear explanation of automation
  - Plugin addition process documented
  - Local development steps clear
  - Troubleshooting section included
  Output: `Clarity [High/Medium/Low] | Completeness [%] | VERDICT`

---

## Commit Strategy

| Task | Commit | Message | Files |
|------|--------|---------|-------|
| 1 | YES | `feat(fluentd): add plugins.txt configuration` | `fluentd/plugins.txt` |
| 2 | YES | `feat(fluentd): add Dockerfile.patch for plugin installation` | `fluentd/Dockerfile.patch` |
| 3 | YES | `feat(fluentd): add Makefile for local development` | `fluentd/Makefile` |
| 4 | YES | `feat(fluentd): add upstream change detection script` | `fluentd/scripts/check-upstream.sh` |
| 5 | YES | `feat(fluentd): add Dockerfile generation script` | `fluentd/scripts/generate.sh` |
| 6 | YES | `ci(fluentd): add weekly sync workflow` | `.github/workflows/sync-fluentd.yml` |
| 7 | YES | `ci(fluentd): add multi-arch build workflow` | `.github/workflows/build-fluentd.yml` |
| 8 | YES | `ci(fluentd): add image cleanup workflow` | `.github/workflows/cleanup-fluentd.yml` |
| 9 | YES | `feat(fluentd): generate v1.17 Dockerfiles` | `fluentd/v1.17/*/Dockerfile` |
| 10 | YES | `feat(fluentd): generate v1.18 Dockerfiles` | `fluentd/v1.18/*/Dockerfile` |
| 11 | YES | `feat(fluentd): generate v1.19 Dockerfiles` | `fluentd/v1.19/*/Dockerfile` |
| 12 | YES | `feat(fluentd): add image verification script` | `fluentd/scripts/verify.sh` |
| 13 | NO | Testing only | — |
| 14 | NO | Testing only | — |
| 15 | NO | Testing only | — |
| 16 | YES | `docs(fluentd): add automation documentation` | `fluentd/README.md` |

---

## Success Criteria

### Verification Commands
```bash
# Test local generation
cd fluentd && make generate VERSION=1.17 ARCH=debian

# Verify Dockerfiles exist
ls -la fluentd/v1.17/*/Dockerfile

# Test one local build
docker build -t test:v1.17 fluentd/v1.17/debian

# Verify plugins
./fluentd/scripts/verify.sh test:v1.17

# Validate workflow syntax
actionlint .github/workflows/sync-fluentd.yml
actionlint .github/workflows/build-fluentd.yml
actionlint .github/workflows/cleanup-fluentd.yml
```

### Final Checklist
- [ ] All 16 tasks completed
- [ ] 13 commits made (Tasks 1-12, 16)
- [ ] 3 GitHub Actions workflows active
- [ ] 9 Dockerfiles generated (3 versions × 3 arches)
- [ ] All 5 plugins verified in images
- [ ] Weekly sync scheduled
- [ ] Documentation complete
- [ ] User explicitly approved ("okay")

---

## Notes

### Patch-Based Approach Benefits
- No template forks to maintain
- Upstream changes apply cleanly
- Our customization is isolated in patch file
- Easy to see what we changed vs upstream

### Multi-Arch Considerations
- armhf builds may be slower (QEMU emulation)
- Build matrix runs in parallel where possible
- Each arch has separate Dockerfile (upstream pattern)

### Security
- Docker Hub credentials in GitHub Secrets
- No credentials in code
- Cleanup workflow uses API token (not password)

### Future Enhancements (Out of Scope)
- Automated security scanning (Trivy)
- Plugin version auto-updates
- Helm charts for Kubernetes
- Windows container support
- Alpine variants (upstream deprecated)
