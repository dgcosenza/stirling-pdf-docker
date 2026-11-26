# Stirling-PDF (Open-Source MIT Core) on Debian 13 (trixie)

[![Daily Stirling-PDF image](https://github.com/dgcosenza/stirling-pdf-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/stirling-pdf-docker/actions/workflows/daily.yml)
[![Packaging License: MIT](https://img.shields.io/badge/packaging-MIT-blue.svg)](https://github.com/dgcosenza/stirling-pdf-docker/blob/main/LICENSE)
[![Upstream License: MIT](https://img.shields.io/badge/upstream-MIT-green.svg)](https://github.com/Stirling-Tools/Stirling-PDF/blob/main/LICENSE)
[![Signed with Cosign](https://img.shields.io/badge/signed-cosign%20OIDC-blueviolet.svg)](#supply-chain-verification)
[![SLSA Level 3](https://img.shields.io/badge/SLSA-Level%203-brightgreen.svg)](#supply-chain-verification)
[![Architectures](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-informational.svg)](#supported-architectures)
[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/dgcosenza/stirling-pdf-docker/badge)](https://scorecard.dev/viewer/?uri=github.com/dgcosenza/stirling-pdf-docker)
[![Docker Pulls](https://img.shields.io/docker/pulls/dgcosenza/stirling-pdf)](https://hub.docker.com/r/dgcosenza/stirling-pdf)
[![Docker Image Size](https://img.shields.io/docker/image-size/dgcosenza/stirling-pdf/latest)](https://hub.docker.com/r/dgcosenza/stirling-pdf)
[![Latest Release](https://img.shields.io/github/v/release/dgcosenza/stirling-pdf-docker?label=version)](https://github.com/dgcosenza/stirling-pdf-docker/releases)

A hardened, multi-arch, rootless **open-source MIT core** **Stirling-PDF** container image compiled from official upstream release tags (`STIRLING_FLAVOR=core`, `DISABLE_ADDITIONAL_FEATURES=true`, `BUILD_PORTAL=false`) on **Debian 13 (`trixie-slim`)** with **Adoptium Temurin 25 JRE** and OCR/PDF CLI tooling (`tesseract-ocr`, `qpdf`, `poppler-utils`, `unpaper`, `pngquant`), maintained by **Daniel G. Cosenza from FNX Labs**.

- **Docker Hub:** [`dgcosenza/stirling-pdf`](https://hub.docker.com/r/dgcosenza/stirling-pdf)
- **GitHub Container Registry (GHCR):** [`ghcr.io/dgcosenza/stirling-pdf`](https://github.com/dgcosenza/stirling-pdf-docker/pkgs/container/stirling-pdf) (identical signed multi-arch digest)
- **Source Repository:** [`dgcosenza/stirling-pdf-docker`](https://github.com/dgcosenza/stirling-pdf-docker)
- **Upstream Application:** [`Stirling-Tools/Stirling-PDF`](https://github.com/Stirling-Tools/Stirling-PDF) (`MIT` core)

> **License boundary:** This image builds **exclusively the MIT-licensed open-source core** of Stirling-PDF. Upstream proprietary directories (`app/proprietary/src`, `app/saas`, `engine`) are purged before compilation and never redistributed. Features governed by the proprietary Stirling PDF User License (such as the proprietary login/security module and enterprise portal) are intentionally excluded; protect public deployments with an authenticating reverse proxy or Zero Trust access layer.

---

## Current Versions

<!-- versions:start -->
| Component | Resolved Version |
| --- | --- |
| Stirling-PDF (MIT core) | `3.5.0` |
| Java Runtime | `openjdk version "25.0.5.1" 2026-11-17 LTS` |
| Base OS | `Debian 13.8 (trixie-slim)` |
| Architectures | `linux/amd64, linux/arm64` |
| Uncompressed size (per arch) | `amd64: 461.6 MB, arm64: 847.1 MB` |
| Last verified build (UTC) | `2026-11-26` |
| Published multi-arch digest | `dgcosenza/stirling-pdf@sha256:d85e2b712d8b3538ef8bcac9c047134b912c609803dc36db660c111d4fffba71` |
| GHCR mirror | `ghcr.io/dgcosenza/stirling-pdf@sha256:d85e2b712d8b3538ef8bcac9c047134b912c609803dc36db660c111d4fffba71` |
| Supply chain | Cosign OIDC signed + SPDX & CycloneDX SBOM attestations + SLSA Build L3 provenance |
| Security gate (Trivy + Grype on SBOM) | **0 fixable findings of any severity** (76 upstream-unfixed) |

**Recent upstream changes:**
- **Stirling-PDF:** `3.5.0` -> `3.5.0`
- **Upstream version changed:** `no`
- Official Stirling-PDF v3.5.0 release (https://github.com/Stirling-Tools/Stirling-PDF/releases/tag/v3.5.0).
- Stirling Office Convert has now replaced Libreoffice in our docker containers!
- Along with speed increases and better quality conversions it also means our docker going forward in 3.5.1 will be half the size!  Thank you to everyone who sent us example files...
<!-- versions:end -->

---

## Supported Tags & Tag Policy

Identical multi-arch OCI digests are published to **Docker Hub** (`dgcosenza/stirling-pdf`) and **GHCR** (`ghcr.io/dgcosenza/stirling-pdf`), accompanied by an automated signed [GitHub Release](https://github.com/dgcosenza/stirling-pdf-docker/releases):

| Tag | Policy | Description |
| --- | --- | --- |
| `<version>-<YYYYMMDD>` (e.g. `3.5.0-20261125`) | **Immutable** | Date-stamped daily rebuild pinning the Stirling-PDF release and UTC build date. |
| `sha-<short>` | **Immutable** | Packaging repository Git commit tag. |
| `<version>` (e.g. `3.5.0`) | Moving | Latest verified Debian 13 security rebuild of that Stirling-PDF release. |
| `latest` | Moving | Latest verified build tracking the newest official Stirling-PDF release. |

**Production pinning:** Pin by immutable registry digest rather than an unpinned moving tag:

```yaml
image: dgcosenza/stirling-pdf:latest@sha256:<digest>
# or via GitHub Container Registry (identical digest):
image: ghcr.io/dgcosenza/stirling-pdf:latest@sha256:<digest>
```

---

## Supported Architectures

| Architecture | Status | Verification |
| --- | --- | --- |
| `linux/amd64` | **Published & natively tested** | Built, smoke-tested (`--cap-drop ALL`, UID 1000), Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native x86_64 CI runners. |
| `linux/arm64` | **Published & natively tested** | Built, smoke-tested (`--cap-drop ALL`, UID 1000), Dive-gated, Syft/Trivy/Grype-scanned, and Cosign-signed on native ARM64 CI runners. |

---

## Quick Start

### Docker CLI (hardened, rootless)

```bash
docker run -d --name stirling-pdf \
  --read-only \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  --tmpfs /tmp/stirling-pdf:nosuid,size=512m \
  --tmpfs /home/stirlingpdfuser:nosuid,size=64m \
  -p 127.0.0.1:8080:8080 \
  -e SYSTEM_DEFAULTLOCALE=en-GB \
  -e SPRINGDOC_APIDOCS_ENABLED=false \
  -e SPRINGDOC_SWAGGERUI_ENABLED=false \
  -v stirling_configs:/configs \
  -v stirling_logs:/logs \
  -v stirling_custom:/customFiles \
  dgcosenza/stirling-pdf:latest
```

### Hardened Docker Compose

See [`docker-compose.example.yml`](https://github.com/dgcosenza/stirling-pdf-docker/blob/main/docker-compose.example.yml):

```yaml
services:
  stirling-pdf:
    image: dgcosenza/stirling-pdf:latest
    restart: unless-stopped
    read_only: true
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    tmpfs:
      - /tmp/stirling-pdf:nosuid,size=512m
      - /home/stirlingpdfuser:nosuid,size=64m
    environment:
      - SYSTEM_DEFAULTLOCALE=en-GB
      - LANGUAGE=en_GB:en
      - SPRINGDOC_APIDOCS_ENABLED=false
      - SPRINGDOC_SWAGGERUI_ENABLED=false
      - JAVA_TOOL_OPTIONS=-XX:MaxMetaspaceSize=256m
    volumes:
      - ./trainingData:/usr/share/tesseract-ocr/5/tessdata
      - ./extraConfigs:/configs
      - ./customFiles:/customFiles
      - ./logs:/logs
    ports:
      - "127.0.0.1:8080:8080"
    healthcheck:
      test: ["CMD-SHELL", "curl -fsS --max-time 10 http://127.0.0.1:8080/api/v1/info/status || exit 1"]
      interval: 30s
      timeout: 15s
      retries: 5
      start_period: 120s
```

---

## Configuration

### Environment Variables

| Variable | Description | Default |
| --- | --- | --- |
| `SYSTEM_DEFAULTLOCALE` | Default UI locale (e.g. `en-GB`, `en-US`) | — |
| `LANGUAGE` | Locale preference | — |
| `SPRINGDOC_APIDOCS_ENABLED` | Enable OpenAPI JSON docs endpoint | `true` (set `false` in production) |
| `SPRINGDOC_SWAGGERUI_ENABLED` | Enable Swagger UI | `true` (set `false` in production) |
| `JAVA_TOOL_OPTIONS` / `JAVA_CUSTOM_OPTS` | Additional JVM flags | `""` |
| `STIRLING_AOT_ENABLE` | Enable Project Leyden AOT cache | `false` |
| `PUID` / `PGID` | Runtime user/group IDs | `1000` / `1000` |
| `UMASK` | Default file creation mask | `022` |
| `TESS_BASE_PATH` | Tesseract traineddata directory | `/usr/share/tesseract-ocr/5/tessdata` |

### Volumes, Ports, and UID/GID

| Path / Port | Mode / Owner | Purpose |
| --- | --- | --- |
| `/configs` | `1000:1000` | Persistent Stirling-PDF configuration (`settings.yml`) |
| `/logs` | `1000:1000` | Application logs |
| `/customFiles` | `1000:1000` | Custom branding/static overrides |
| `/usr/share/tesseract-ocr/5/tessdata` | `1000:1000` | Additional Tesseract OCR language files |
| `8080/tcp` | Non-root HTTP | Stirling-PDF web interface and API |

Runs as non-root **`stirlingpdfuser:stirlingpdfgroup` (UID/GID `1000:1000`)** under `tini` as PID 1, compatible with `cap_drop: [ALL]`, `no-new-privileges:true`, and `read_only: true` (with writable volumes and `tmpfs`).

---

## Healthcheck

```bash
curl -fsS --max-time 10 http://127.0.0.1:8080/api/v1/info/status
```

---

## Upgrade and Migration from Upstream `frooodle/s-pdf`

1. **Important authentication notice:** Because this image excludes Stirling-PDF's proprietary login module (`app/proprietary`), if your existing deployment relied on `DOCKER_ENABLE_SECURITY=true` / `SECURITY_ENABLE_LOGIN=true`, place an authenticating reverse proxy (or Cloudflare Access / OAuth2 Proxy) in front of port `8080` **before** switching so public exposure does not become unauthenticated.
2. Back up `/configs` and `/customFiles` and tag the outgoing image locally for rollback.
3. Ensure host-mounted `/configs`, `/logs`, and `/customFiles` are writable by UID/GID `1000:1000`.
4. Replace the image reference with `dgcosenza/stirling-pdf:latest@sha256:<digest>` (or GHCR) and recreate the service.

---

## Supply-Chain Verification

Every published digest (multi-arch index and per-architecture manifests) on both Docker Hub and GHCR is keyless-signed with **Sigstore Cosign** (GitHub OIDC), attested with **SPDX** and **CycloneDX** SBOMs, and backed by **SLSA Build L3** provenance (`actions/attest-build-provenance`).

### Verify image signature with Cosign

```bash
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/stirling-pdf-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/stirling-pdf:latest

# Or against Docker Hub (identical digest):
cosign verify \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/stirling-pdf-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  dgcosenza/stirling-pdf:latest
```

### Verify SPDX / CycloneDX SBOM attestations

```bash
cosign verify-attestation \
  --type spdxjson \
  --certificate-identity-regexp="^https://github\.com/dgcosenza/stirling-pdf-docker/\.github/workflows/daily\.yml@refs/heads/main$" \
  --certificate-oidc-issuer="https://token.actions.githubusercontent.com" \
  ghcr.io/dgcosenza/stirling-pdf@sha256:<arch-digest>
```

### Verify SLSA Build Provenance

```bash
gh attestation verify oci://ghcr.io/dgcosenza/stirling-pdf:latest --owner dgcosenza
```

---

## Security

- **Preflight gates:** Every push and PR runs **Hadolint** (blocking on warning+), **Gitleaks** secret scanning across git history, and **public-content/attribution** checks.
- **Vulnerability scan policy (all severities with a fix):** Every build generates **SPDX** and **CycloneDX** SBOMs with **Syft** per architecture, scans with **Trivy** (OS + Java JAR libraries: table, JSON, SARIF upload, blocking `--ignore-unfixed` gate) and **Grype** scanning the SPDX SBOM (`--only-fixed --fail-on negligible`), and enforces a **Dive** efficiency gate (`>= 95%`, `<= 5%` wasted user bytes).
- **Current status:** **0 fixable vulnerabilities of any severity** across Debian 13 OS packages and compiled Java dependencies.
- **Dependency automation:** Renovate (`renovate.json`) pins base image digests and GitHub Action commit SHAs; Dependabot security alerts and OpenSSF Scorecard monitoring are enabled.
- See [`SECURITY.md`](https://github.com/dgcosenza/stirling-pdf-docker/blob/main/SECURITY.md) for private disclosure instructions.

---

## Build Locally

```bash
docker buildx build --platform linux/amd64 --load \
  --build-arg STIRLING_VERSION=3.5.0 \
  -t dgcosenza/stirling-pdf:local .
```

---

## Update Policy

[`.github/workflows/daily.yml`](https://github.com/dgcosenza/stirling-pdf-docker/blob/main/.github/workflows/daily.yml) runs automatically every day at **05:17 UTC**, on pushes to `main`, on pull requests (verification only), and via `workflow_dispatch`:

1. **Preflight & upstream check:** Runs public-content checks, **Hadolint**, and **Gitleaks**; queries the authenticated GitHub API (`Stirling-Tools/Stirling-PDF`) for the latest official release and resolves digest-pinned Debian 13 and Gradle base images, emitting `upstream-changes.md`.
2. **Multi-arch no-cache rebuild:** Compiles the MIT open-source core edition (`STIRLING_FLAVOR=core`, proprietary trees purged) natively on `linux/amd64` and `linux/arm64` runners with `--no-cache` on schedule and `apt-get upgrade` on `debian:trixie-slim` + Adoptium Temurin 25 JRE.
3. **Smoke, Dive & vulnerability gates:** Runs [`tests/smoke.sh`](https://github.com/dgcosenza/stirling-pdf-docker/blob/main/tests/smoke.sh) natively on both architectures, enforces the **Dive** efficiency gate (`>= 95%`, `<= 5%` wasted), generates **Syft** SPDX + CycloneDX SBOMs per arch, and gates publication on **0 fixable findings of any severity** in both **Trivy** and **Grype** (scanning the SPDX SBOM).
4. **Dual-registry publish & supply-chain signing:** Assembles the multi-arch OCI manifest index on **GHCR** (`ghcr.io/dgcosenza/stirling-pdf`) and mirrors the identical digest to **Docker Hub** (`dgcosenza/stirling-pdf`) with tags `latest`, `<version>`, `<version>-<YYYYMMDD>`, and `sha-<short>`; signs every digest and attaches SPDX/CycloneDX SBOM attestations via **Cosign** keyless OIDC; emits **SLSA Build L3** provenance; and publishes a signed **GitHub Release** with checksums and SBOMs.
5. **Automated documentation sync:** Commits updated `versions.json`, the README `Current Versions` block, and a dated `CHANGELOG.md` entry via `github-actions[bot]` (`[skip ci]`, validated by `public-check.sh`), then syncs the Docker Hub overview and short description.
6. **Failure alerting:** Opens or updates a single GitHub issue labeled `ci-failure` on any `main` or scheduled failure, and auto-closes it on the next green run.

---

## Design Decisions

- **Strict open-source MIT build:** Upstream Stirling-PDF mixes MIT core code with proprietary directories (`app/proprietary/`, `app/saas/`, `engine/`) governed by the non-redistributable Stirling PDF User License. Purging those directories before compilation and setting `STIRLING_FLAVOR=core` guarantees clean MIT redistribution compliance.
- **Debian 13 (`trixie-slim`) + Adoptium Temurin 25 JRE:** Installs `temurin-25-jre` from Adoptium's official GPG-verified Debian 13 APT repository (`3B04D753C9050D9A5D343F39843C48A565F8F04B`) rather than Ubuntu 24.04, with `tini` as PID 1 and non-root execution (`UID 1000`).
- **SHA-256 verified build toolchain:** Node.js and `task` binaries in the discarded builder stage are fetched directly from upstream releases and verified by SHA-256 checksum rather than piping remote scripts to a shell.
- **Patched transitive Java dependencies:** The upstream Gradle build pins some transitive libraries to old releases. Where a fixed release exists, the image build pins it as an explicit core-module dependency so Gradle conflict resolution selects the patched version (currently `org.json:json`, resolved from Maven Central on every CI run). `com.posthog.java:posthog:1.2.0` additionally shades a relocated copy of that library with stale Maven metadata, so its shaded classes are rebuilt from the patched release sources and the bundled metadata is corrected. Both copies are verified in the bootJar, so the all-severity vulnerability gate stays green without modifying upstream sources.
- **Hadolint `DL3008` ignore:** Daily `--no-cache` security rebuilds intentionally pull the newest Debian 13 security updates via `apt-get`.

---

## License

This repository follows a clear packaging-vs-upstream license split:

- **Container packaging, CI workflows, scripts, and documentation (`packaging: MIT`):** Licensed under the [MIT License](https://github.com/dgcosenza/stirling-pdf-docker/blob/main/LICENSE) — copyright **Daniel G. Cosenza from FNX Labs**.
- **Bundled upstream software — Stirling-PDF Open-Source Core (`upstream: MIT`):** Built exclusively from MIT-licensed core code under the [Stirling-PDF MIT License](https://github.com/Stirling-Tools/Stirling-PDF/blob/main/LICENSE) (all proprietary upstream directories are removed prior to compilation).

Full third-party notices are maintained in [`THIRD-PARTY-NOTICES.md`](https://github.com/dgcosenza/stirling-pdf-docker/blob/main/THIRD-PARTY-NOTICES.md). Release history is maintained in [`CHANGELOG.md`](https://github.com/dgcosenza/stirling-pdf-docker/blob/main/CHANGELOG.md).

## Credits

- [Stirling-Tools/Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF)
- [Eclipse Adoptium Temurin](https://adoptium.net/)
- [Debian Project](https://www.debian.org/)

Maintained by **Daniel G. Cosenza from FNX Labs**.
