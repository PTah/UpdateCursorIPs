#!/usr/bin/env python3
"""Update a plain text file that stores one IP address per line."""

from __future__ import annotations

import argparse
import ipaddress
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Add or remove IP addresses in a plain text file."
    )
    parser.add_argument(
        "--file",
        required=True,
        type=Path,
        help="Path to the file that should contain the IP addresses.",
    )
    parser.add_argument(
        "--add",
        nargs="*",
        default=[],
        help="IP addresses to add to the target file.",
    )
    parser.add_argument(
        "--remove",
        nargs="*",
        default=[],
        help="IP addresses to remove from the target file.",
    )
    return parser.parse_args()


def validate_ips(ips: list[str]) -> list[str]:
    validated: list[str] = []
    for ip in ips:
        validated.append(str(ipaddress.ip_address(ip)))
    return validated


def load_ips(target: Path) -> set[str]:
    if not target.exists():
        return set()
    return {line.strip() for line in target.read_text(encoding="utf-8").splitlines() if line.strip()}


def write_ips(target: Path, ips: set[str]) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    content = "\n".join(sorted(ips)) + "\n" if ips else ""
    target.write_text(content, encoding="utf-8")


def main() -> None:
    args = parse_args()
    to_add = set(validate_ips(args.add))
    to_remove = set(validate_ips(args.remove))
    current = load_ips(args.file)
    updated = (current | to_add) - to_remove
    write_ips(args.file, updated)
    print(
        f"Updated {args.file} with {len(updated)} IP address(es) "
        f"({len(to_add)} added, {len(to_remove)} removed)."
    )


if __name__ == "__main__":
    main()
