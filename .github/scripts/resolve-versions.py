#!/usr/bin/env python3
"""Resolve latest official Stirling-PDF GitHub release."""

from __future__ import annotations

import json
import os
import re
import urllib.request
from pathlib import Path


def fetch_json(url: str):
    headers = {
        "User-Agent": "dgcosenza-stirling-pdf-docker-ci",
        "Accept": "application/vnd.github+json",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if token:
        headers["Authorization"] = f"Bearer {token}"
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def main() -> None:
    override = os.environ.get("OVERRIDE_STIRLING", "").strip().lstrip("v")
    if override:
        ver = override
        notes = f"Manual override requested: Stirling-PDF v{ver}."
    else:
        rel = fetch_json("https://api.github.com/repos/Stirling-Tools/Stirling-PDF/releases/latest")
        tag = (rel.get("tag_name") or "").strip()
        ver = tag.lstrip("v")
        if not re.fullmatch(r"\d+\.\d+\.\d+", ver):
            raise SystemExit(f"ERROR: Unexpected Stirling-PDF tag: {tag}")
        url = rel.get("html_url") or f"https://github.com/Stirling-Tools/Stirling-PDF/releases/tag/{tag}"
        body = (rel.get("body") or "").strip()
        notes = f"Official Stirling-PDF v{ver} release ({url})."
        if body:
            lines = [ln.strip() for ln in body.splitlines() if ln.strip()][:10]
            notes += "\n\n" + "\n".join(lines)

    prev = {}
    vpath = Path("versions.json")
    if vpath.exists():
        prev = json.loads(vpath.read_text(encoding="utf-8"))
    prev_ver = prev.get("stirling_version", "")
    changed = ver != prev_ver

    md = [
        "# Upstream changes — Stirling-PDF (Open-Source MIT Core)",
        "",
        f"- **Stirling-PDF:** `{prev_ver or 'none'}` -> `{ver}`",
        f"- **Upstream version changed:** `{'yes' if changed else 'no'}`",
        "",
        "## Release notes",
        "",
        notes,
        "",
    ]
    Path("upstream-changes.md").write_text("\n".join(md), encoding="utf-8")

    outputs = {
        "stirling_version": ver,
        "prev_stirling_version": prev_ver,
        "upstream_changed": "true" if changed else "false",
    }
    gh_out = os.environ.get("GITHUB_OUTPUT")
    if gh_out:
        with open(gh_out, "a", encoding="utf-8") as fh:
            for k, v in outputs.items():
                fh.write(f"{k}={v}\n")
    for k, v in outputs.items():
        print(f"{k}={v}")


if __name__ == "__main__":
    main()
