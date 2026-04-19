#!/usr/bin/env python3
"""Resolve domains from domains.txt and write unique IPv4 addresses."""

from __future__ import annotations

import socket
from pathlib import Path


ROOT = Path(__file__).resolve().parent
DOMAINS_FILE = ROOT / "domains.txt"
OUTPUT_FILE = ROOT / "cursor_ips.txt"


def read_domains(path: Path) -> list[str]:
    return [
        line.strip()
        for line in path.read_text(encoding="utf-8").splitlines()
        if line.strip() and not line.lstrip().startswith("#")
    ]


def resolve_ipv4(domain: str) -> set[str]:
    _, _, addresses = socket.gethostbyname_ex(domain)
    return set(addresses)


def main() -> int:
    domains = read_domains(DOMAINS_FILE)
    all_ips: set[str] = set()

    for domain in domains:
        try:
            all_ips.update(resolve_ipv4(domain))
        except socket.gaierror as error:
            print(f"warning: failed to resolve {domain}: {error}")

    OUTPUT_FILE.write_text("\n".join(sorted(all_ips)) + "\n", encoding="utf-8")
    print(f"saved {len(all_ips)} unique IPv4 addresses to {OUTPUT_FILE.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
