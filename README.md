# Stirling-PDF (Open-Source MIT Core) on Debian 13 (trixie)

[![CI](https://github.com/dgcosenza/stirling-pdf-docker/actions/workflows/daily.yml/badge.svg)](https://github.com/dgcosenza/stirling-pdf-docker/actions/workflows/daily.yml)
[![Docker Hub Pulls](https://img.shields.io/docker/pulls/dgcosenza/stirling-pdf?label=docker%20pulls)](https://hub.docker.com/r/dgcosenza/stirling-pdf)
[![Image Size](https://img.shields.io/docker/image-size/dgcosenza/stirling-pdf/latest?label=image%20size)](https://hub.docker.com/r/dgcosenza/stirling-pdf)
[![License](https://img.shields.io/github/license/dgcosenza/stirling-pdf-docker)](LICENSE)

A hardened, continuously rebuilt **open-source MIT core** **Stirling-PDF** container image compiled from official upstream release tags (`STIRLING_FLAVOR=core`, `DISABLE_ADDITIONAL_FEATURES=true`, `BUILD_PORTAL=false`) on **Debian 13 (`trixie-slim`)** with **Adoptium Temurin 25 JRE** and OCR/PDF CLI tooling (`tesseract-ocr`, `qpdf`, `poppler-utils`, `unpaper`, `pngquant`).

> **License boundary:** This image builds **exclusively the MIT-licensed open-source core** of Stirling-PDF. Upstream proprietary directories (`app/proprietary/src`, `app/saas`, `engine`) are purged before compilation and never redistributed. Features governed by the proprietary Stirling PDF User License (such as the proprietary login/security module and enterprise portal) are intentionally excluded; protect public deployments with an authenticating reverse proxy or Zero Trust access layer.

Maintained by **Daniel G. Cosenza from FNX Labs**.

## Current Versions

<!-- versions:start -->
_Last verified build: **2026-11-24** (UTC)_

| Component | Resolved Version |
|-----------|------------------|
| Stirling-PDF (MIT Core) | `3.5.0` (`STIRLING_FLAVOR=core`) |
| Java Runtime | `25` (Adoptium Temurin 25 JRE) |
| Base OS | Debian `13` (`debian:trixie-slim`) |
| Fixable Critical/High (Trivy / Grype) | `0` / `0` |

**Recent upstream updates:**
- Initial hardened Debian 13 + Temurin 25 JRE release for open-source MIT core Stirling-PDF 3.5.0.
<!-- versions:end -->

## Supported Tags

| Tag | Description |
|-----|-------------|
| `latest` | Moving tag tracking the newest verified daily build |
| `<version>` | Latest build for a specific upstream release (e.g. `3.5.0`) |
| `<version>-YYYYMMDD` | Immutable date-stamped build (e.g. `3.5.0-20261124`) |
| `sha-<short>` | Immutable commit-stamped build |

## Quick Start

### Docker CLI

```bash
docker run -d --name stirling-pdf \
  --security-opt no-new-privileges:true \
  -p 127.0.0.1:8080:8080 \
  -e SYSTEM_DEFAULTLOCALE=en-GB \
  -e SPRINGDOC_APIDOCS_ENABLED=false \
  -e SPRINGDOC_SWAGGERUI_ENABLED=false \
  -v stirling_configs:/configs \
  -v stirling_logs:/logs \
  dgcosenza/stirling-pdf:latest
```

### Docker Compose

```yaml
services:
  stirling-pdf:
    image: dgcosenza/stirling-pdf:latest
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
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

See [docker-compose.example.yml](docker-compose.example.yml) for a full example.

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SYSTEM_DEFAULTLOCALE` | Default UI locale (e.g. `en-GB`, `en-US`) | — |
| `LANGUAGE` | Locale preference | — |
| `SPRINGDOC_APIDOCS_ENABLED` | Enable OpenAPI JSON docs endpoint | `true` (set `false` in production) |
| `SPRINGDOC_SWAGGERUI_ENABLED` | Enable Swagger UI | `true` (set `false` in production) |
| `JAVA_TOOL_OPTIONS` / `JAVA_CUSTOM_OPTS` | Additional JVM flags | `""` |
| `STIRLING_AOT_ENABLE` | Enable Project Leyden AOT cache | `false` |
| `PUID` / `PGID` | Runtime user/group IDs | `1000` / `1000` |
| `UMASK` | Default file creation mask | `022` |
| `TESS_BASE_PATH` | Tesseract traineddata directory | `/usr/share/tesseract-ocr/5/tessdata` |

### Volumes

| Path | Purpose |
|------|---------|
| `/configs` | Persistent Stirling-PDF configuration (`settings.yml`) |
| `/logs` | Application logs |
| `/customFiles` | Custom branding/static overrides |
| `/usr/share/tesseract-ocr/5/tessdata` | Additional Tesseract OCR language files |

### Ports

- `8080/tcp` — Stirling-PDF HTTP server

### User, UID, and GID

- Runs as non-root `stirlingpdfuser:stirlingpdfgroup` (**UID 1000 / GID 1000**) by default under `tini` as PID 1.

### Healthcheck

```bash
curl -fsS --max-time 10 http://127.0.0.1:8080/api/v1/info/status
```

## Upgrade and Migration from Upstream `frooodle/s-pdf`

1. **Important authentication notice:** Because this image excludes Stirling-PDF's proprietary login module (`app/proprietary`), if your existing deployment relied on `DOCKER_ENABLE_SECURITY=true` / `SECURITY_ENABLE_LOGIN=true`, place an authenticating reverse proxy (or Cloudflare Access / OAuth2 Proxy) in front of port `8080` **before** switching so public exposure does not become unauthenticated.
2. Back up `/configs` and `/customFiles` and tag the outgoing image locally for rollback.
3. Ensure host-mounted `/configs`, `/logs`, and `/customFiles` are writable by UID/GID `1000:1000`.
4. Replace the image reference with `dgcosenza/stirling-pdf:latest` (or pinned `@sha256:...`) and recreate the service.

## Security

- **Trivy** (OS + Java JAR libraries): SARIF uploaded to GitHub Code Scanning; table and JSON reports retained for 90 days; **blocking hard gate** on 0 fixable `CRITICAL`/`HIGH` findings.
- **Grype**: **blocking hard gate** (`only-fixed: true`, severity cutoff `high`); table report retained for 90 days.
- **SBOM & Provenance**: SPDX-JSON SBOM (Syft) and provenance JSON retained for 90 days.

See [SECURITY.md](SECURITY.md) for private disclosure instructions.

## Build Locally

```bash
docker buildx build --platform linux/amd64 --load \
  --build-arg STIRLING_VERSION=3.5.0 \
  -t dgcosenza/stirling-pdf:local .
```

## Update Policy

Every day at **05:17 UTC** (and on push to `main`, pull requests, or manual dispatch), `.github/workflows/daily.yml` runs a 7-step automated pipeline gated by `.github/scripts/public-check.sh`:

1. **Upstream check:** Queries the authenticated GitHub API (`Stirling-Tools/Stirling-PDF`) for the latest official release tag and release notes, diffs against `versions.json`, and saves `upstream-changes.md` as a 90-day artifact.
2. **Clean rebuild:** Compiles the MIT open-source core edition (`STIRLING_FLAVOR=core`, proprietary trees purged) and assembles the `debian:trixie-slim` + Adoptium Temurin 25 JRE runtime with `--no-cache` on scheduled runs, producing SPDX-JSON SBOM and provenance artifacts.
3. **Vulnerability fix & hard gates:** Runs Trivy (table, JSON, SARIF upload, and blocking 0 fixable `CRITICAL`/`HIGH` gate) and Grype (blocking 0 fixable `CRITICAL`/`HIGH` gate), retaining all reports for 90 days.
4. **Functional smoke test:** Executes `tests/smoke.sh` to verify healthy startup, UID 1000 non-root execution, `/api/v1/info/status` (`UP`), HTTP 200 UI, `qpdf`/`tesseract` tools, and negative healthcheck failure.
5. **Registry publish:** Pushes `latest`, `<version>`, `<version>-<YYYYMMDD>`, and `sha-<short>` tags when Docker Hub credentials are configured.
6. **Automated documentation sync:** Updates `versions.json`, the `<!-- versions:start -->` block in `README.md`, and `CHANGELOG.md` via `github-actions[bot]` (`[skip ci]`, verified by `public-check.sh`), then syncs README and short description to Docker Hub.
7. **Failure alerting:** Opens or updates a single GitHub issue labeled `ci-failure` on any `main` or scheduled failure, and auto-closes it on the next green run.

## Design Decisions

- **Strict open-source MIT build:** Upstream Stirling-PDF mixes MIT core code with proprietary directories (`app/proprietary/`, `app/saas/`, `engine/`) governed by the non-redistributable Stirling PDF User License. Purging those directories before compilation and setting `STIRLING_FLAVOR=core` guarantees clean MIT redistribution compliance.
- **Debian 13 (`trixie-slim`) + Adoptium Temurin 25 JRE:** Installs `temurin-25-jre` from Adoptium's official GPG-verified Debian 13 APT repository (`3B04D753C9050D9A5D343F39843C48A565F8F04B`) rather than Ubuntu 24.04, providing consistent Debian 13 security patching with `tini` as PID 1 and non-root execution (`UID 1000`).

## License

- Repository build files, scripts, and documentation: **MIT License** — see [LICENSE](LICENSE).
- Stirling-PDF open-source core (`STIRLING_FLAVOR=core`): **MIT License** — see [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

## Credits

- [Stirling-Tools/Stirling-PDF](https://github.com/Stirling-Tools/Stirling-PDF)
- [Eclipse Adoptium Temurin](https://adoptium.net/)
- [Debian Project](https://www.debian.org/)

Maintained by **Daniel G. Cosenza from FNX Labs**.
