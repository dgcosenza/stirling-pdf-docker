# Security Policy

Maintained by **Daniel G. Cosenza from FNX Labs**.

## Supported Versions

Only the latest daily build (`latest`) receives security updates. Immutable date-stamped tags (`<version>-YYYYMMDD`) are frozen for reproducibility.

## Vulnerability Scanning & Gates

- **Trivy** (OS + Java JAR libraries): SARIF uploaded to GitHub Code Scanning; table and JSON reports retained for 90 days; **blocking hard gate** on any fixable vulnerability of any severity.
- **Grype**: **blocking hard gate** (`--only-fixed --fail-on negligible`, all severities); table report retained for 90 days.
- **SBOM & Provenance**: SPDX-JSON SBOM via Syft plus provenance JSON retained for 90 days.

## Authentication Note

Because this image contains only the MIT-licensed core of Stirling-PDF (excluding upstream's proprietary login module), place an authenticating reverse proxy or Zero Trust access gateway in front of port `8080` for any network-exposed deployment.

## Reporting a Vulnerability

**Do not open a public issue** for security vulnerabilities.

Report privately through GitHub Security Advisories: open the repository's **Security** tab or submit a private advisory directly at [dgcosenza/stirling-pdf-docker Security Advisories](https://github.com/dgcosenza/stirling-pdf-docker/security/advisories/new).

For upstream Stirling-PDF vulnerabilities, follow the [Stirling-Tools/Stirling-PDF Security Policy](https://github.com/Stirling-Tools/Stirling-PDF/security/policy).
