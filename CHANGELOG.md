# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

Maintained by **Daniel G. Cosenza from FNX Labs**.

## [Unreleased]

## [2026-11-24]

### Added
- Initial hardened open-source MIT core Stirling-PDF (`3.5.0`) image on Debian 13 (`trixie-slim`) with Adoptium Temurin 25 JRE and OCR/PDF CLI tools (`tesseract-ocr`, `qpdf`, `poppler-utils`, `unpaper`, `pngquant`).
- Explicit pre-build purge of upstream proprietary/SaaS source trees (`app/proprietary/src`, `app/saas`, `engine`) with `STIRLING_FLAVOR=core` and `-PbuildWithPortal=false` to ensure strict MIT license compliance.
- Non-root execution (`UID 1000`), `tini` PID 1, built-in healthcheck, functional smoke tests, and 7-step automated daily CI pipeline.

### Security
- Eliminated fixable Ubuntu 24.04 vulnerabilities present in upstream `frooodle/s-pdf:latest`; verified 0 fixable Critical/High in Trivy and Grype.
