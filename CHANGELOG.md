# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

Maintained by **Daniel G. Cosenza from FNX Labs**.

## [Unreleased]

### Security
- Fix CVE-2026-59171 (`org.json:json` `20231013`) in both places: pin the transitive library to the latest Maven Central release (resolved by CI on every run) via an explicit core-module dependency, and rebuild the copy shaded inside `com.posthog.java:posthog:1.2.0` from the patched release sources. Verify the patched versions are bundled in the bootJar.

<!-- changelog:auto -->

## [3.5.0] — 2026-11-25

### Automated Daily Build
- Verified components: Stirling-PDF (MIT core) `3.5.0`, Java Runtime `openjdk version "25.0.5.1" 2026-11-17 LTS`, Base OS `Debian 13.8 (trixie-slim)`.
- Architectures verified: `linux/amd64, linux/arm64` (native smoke tests + Dive efficiency gate).
- Upstream changes:
  - **Stirling-PDF:** `3.5.0` -> `3.5.0`
  - **Upstream version changed:** `no`
  - Official Stirling-PDF v3.5.0 release (https://github.com/Stirling-Tools/Stirling-PDF/releases/tag/v3.5.0).
  - Stirling Office Convert has now replaced Libreoffice in our docker containers!
  - Along with speed increases and better quality conversions it also means our docker going forward in 3.5.1 will be half the size!  Thank you to everyone who sent us example files...
- Vulnerability gate: **0 fixable Critical/High** in Trivy and Grype (SBOM scan) (74 upstream-unfixed).
- Published multi-arch digest (Docker Hub + GHCR): `dgcosenza/stirling-pdf@sha256:b8e235d99f030c21f871bb557d63ed62ca5905a184962a7f52b2705f94302af9` (Cosign OIDC signed + SPDX/CycloneDX SBOM + SLSA L3 provenance).
---

---

## [2026-11-24]

### Added
- Initial hardened open-source MIT core Stirling-PDF (`3.5.0`) image on Debian 13 (`trixie-slim`) with Adoptium Temurin 25 JRE and OCR/PDF CLI tools (`tesseract-ocr`, `qpdf`, `poppler-utils`, `unpaper`, `pngquant`).
- Explicit pre-build purge of upstream proprietary/SaaS source trees (`app/proprietary/src`, `app/saas`, `engine`) with `STIRLING_FLAVOR=core` and `-PbuildWithPortal=false` to ensure strict MIT license compliance.
- Non-root execution (`UID 1000`), `tini` PID 1, built-in healthcheck, functional smoke tests, multi-arch (`linux/amd64`, `linux/arm64`), Cosign OIDC signing, SPDX/CycloneDX SBOM attestations, SLSA Build L3 provenance, dual-registry publishing (GHCR + Docker Hub), and automated daily CI pipeline.

### Security
- Eliminated fixable Ubuntu 24.04 vulnerabilities present in upstream `frooodle/s-pdf:latest`; verified 0 fixable Critical/High in Trivy and Grype.
