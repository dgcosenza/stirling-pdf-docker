#!/usr/bin/env python3
"""Update versions.json, README.md versions block, and CHANGELOG.md from CI metadata."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


def update_readme(readme_path: Path, v: dict, prev: dict) -> None:
    content = readme_path.read_text(encoding="utf-8")
    start_marker = "<!-- versions:start -->"
    end_marker = "<!-- versions:end -->"
    if start_marker not in content or end_marker not in content:
        raise SystemExit("ERROR: README.md missing versions markers")

    highlights = []
    if prev.get("stirling_version") and prev.get("stirling_version") != v["stirling_version"]:
        highlights.append(f"- Stirling-PDF (MIT core) updated from `{prev['stirling_version']}` to `{v['stirling_version']}`.")
    if not highlights:
        highlights.append("- Daily Debian 13 OS + Temurin 25 JRE security refresh and CVE-gated verification.")

    block = "\n".join(
        [
            start_marker,
            f"_Last verified build: **{v['last_updated']}** (UTC)_",
            "",
            "| Component | Resolved Version |",
            "|-----------|------------------|",
            f"| Stirling-PDF (MIT Core) | `{v['stirling_version']}` (`STIRLING_FLAVOR=core`) |",
            f"| Java Runtime | `{v['java_version']}` (Adoptium Temurin 25 JRE) |",
            f"| Base OS | Debian `{v['debian_version']}` (`debian:trixie-slim`) |",
            f"| Fixable Critical/High (Trivy / Grype) | `{v['trivy_fixable_critical_high']}` / `{v['grype_fixable_critical_high']}` |",
            "",
            "**Recent upstream updates:**",
            *highlights,
            end_marker,
        ]
    )
    pattern = re.compile(re.escape(start_marker) + r".*?" + re.escape(end_marker), re.DOTALL)
    readme_path.write_text(pattern.sub(block, content, count=1), encoding="utf-8")


def update_changelog(changelog_path: Path, v: dict, prev: dict, cves_fixed: list[str]) -> None:
    content = changelog_path.read_text(encoding="utf-8")
    header = f"## [{v['last_updated']}]"
    if prev.get("stirling_version") and prev.get("stirling_version") != v["stirling_version"]:
        changed_line = f"- Stirling-PDF (MIT core) updated `{prev['stirling_version']}` -> `{v['stirling_version']}` (`{v['digest']}`)"
    else:
        changed_line = f"- Rebuilt Stirling-PDF `{v['stirling_version']}` on Debian `{v['debian_version']}` + `{v['java_version']}` (`{v['digest']}`)"
    sec_line = (
        f"- CVEs fixed since previous build: {', '.join(sorted(cves_fixed))}"
        if cves_fixed
        else "- Trivy and Grype gates verified: 0 fixable Critical/High vulnerabilities."
    )
    entry = "\n".join([header, "", "### Changed", changed_line, "", "### Security", sec_line, ""])
    if header in content:
        pattern = re.compile(re.escape(header) + r"\n.*?(?=\n## \[|\Z)", re.DOTALL)
        new_content = pattern.sub(entry.rstrip("\n"), content, count=1)
    else:
        marker = "## [Unreleased]\n"
        if marker in content:
            idx = content.index(marker)
            next_h2 = content.find("\n## [", idx + len(marker))
            if next_h2 == -1:
                new_content = content.rstrip() + "\n\n" + entry
            else:
                new_content = content[: next_h2 + 1] + "\n" + entry + content[next_h2 + 1 :]
        else:
            new_content = content.rstrip() + "\n\n" + entry
    changelog_path.write_text(new_content.rstrip() + "\n", encoding="utf-8")


def main() -> None:
    meta_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("build-meta/meta.json")
    meta = json.loads(meta_path.read_text(encoding="utf-8"))
    vpath = Path("versions.json")
    prev = json.loads(vpath.read_text(encoding="utf-8")) if vpath.exists() else {}

    prev_cves = set(prev.get("cves_seen", []))
    cur_cves = set(meta.get("cves_seen", []))
    cves_fixed = sorted(prev_cves - cur_cves)

    new_v = {
        "last_updated": meta["date_iso"],
        "debian_version": meta["debian_version"],
        "stirling_version": meta["stirling_version"],
        "java_version": meta["java_version"],
        "digest": meta.get("digest") or "pending-hub-publish",
        "trivy_fixable_critical_high": meta.get("trivy_fixable_critical_high", 0),
        "grype_fixable_critical_high": meta.get("grype_fixable_critical_high", 0),
        "cves_seen": sorted(cur_cves),
    }

    changed = any(
        new_v.get(k) != prev.get(k)
        for k in ("debian_version", "stirling_version", "java_version", "digest", "cves_seen")
    )
    vpath.write_text(json.dumps(new_v, indent=2) + "\n", encoding="utf-8")
    update_readme(Path("README.md"), new_v, prev)
    if changed or cves_fixed:
        update_changelog(Path("CHANGELOG.md"), new_v, prev, cves_fixed)
    print(f"Docs updated (changed={changed}, cves_fixed={len(cves_fixed)})")


if __name__ == "__main__":
    main()
