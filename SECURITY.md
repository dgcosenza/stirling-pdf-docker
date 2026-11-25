# Security Policy

Maintained by **Daniel G. Cosenza from FNX Labs**.

## Supported Versions

Only the latest daily build (`latest`) receives security updates. Immutable date-stamped tags (`<version>-YYYYMMDD`) are frozen for reproducibility.

## Vulnerability Scanning & Gates

- **Trivy** (OS + Java JAR libraries): SARIF uploaded to GitHub Code Scanning; table and JSON reports retained for 90 days; **blocking hard gate** on any fixable `CRITICAL` or `HIGH` finding.
- **Grype**: **blocking hard gate** (`only-fixed: true`, severity cutoff `high`); table report retained for 90 days.
- **SBOM & Provenance**: SPDX-JSON SBOM via Syft plus provenance JSON retained for 90 days.

## Authentication Note

Because this image contains only the MIT-licensed core of Stirling-PDF (excluding upstream's proprietary login module), place an authenticating reverse proxy or Zero Trust access gateway in front of port `8080` for any network-exposed deployment.

## Reporting a Vulnerability

**Do not open a public issue** for security vulnerabilities.

Report privately through GitHub's private vulnerability reporting: open the repository's **Security** tab and select **Report a vulnerability**.
