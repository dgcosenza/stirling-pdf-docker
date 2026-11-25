# Third-Party Notices

This image bundles software from the following open-source projects. Each component retains its original license.

## Stirling-PDF (Open-Source MIT Core)

- **License:** MIT License (excluding `app/proprietary/`, `app/saas/`, `engine/`, and proprietary frontend directories, which are purged prior to compilation and excluded via `STIRLING_FLAVOR=core` and `-PbuildWithPortal=false`)
- **Source:** https://github.com/Stirling-Tools/Stirling-PDF

## Eclipse Adoptium Temurin 25 JRE

- **License:** GPL-2.0-with-classpath-exception
- **Source:** https://packages.adoptium.net/artifactory/deb (GPG key `3B04D753C9050D9A5D343F39843C48A565F8F04B`)

## Debian 13 (`trixie`) & PDF/OCR Tools

- `tesseract-ocr` (Apache-2.0), `qpdf` (Apache-2.0), `poppler-utils` (GPL-2.0+), `unpaper` (GPL-2.0), `pngquant` (GPL-3.0+), `tini` (MIT), and Debian main packages (DFSG-compatible).

---

This repository's own build definitions, CI workflows, tests, and documentation are licensed under the MIT License — Copyright (c) 2026 Daniel G. Cosenza from FNX Labs (see [LICENSE](LICENSE)).
