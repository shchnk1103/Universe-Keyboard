#!/usr/bin/env python3
"""Classify a Git diff into the documentation-only or full CI tier."""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from dataclasses import dataclass
from pathlib import PurePosixPath


@dataclass(frozen=True)
class Classification:
    name: str
    requires_full: bool
    changed_paths: tuple[str, ...]
    full_required_paths: tuple[str, ...]
    reason: str


def is_lightweight_path(raw_path: str) -> bool:
    """Return true only for the intentionally small documentation allowlist."""

    path = PurePosixPath(raw_path)
    if path.is_absolute() or ".." in path.parts or not path.parts:
        return False

    if path.parts[0] in {"docs", ".kos"}:
        return True

    # scripts/kos/<file> only. The directory entry itself and lookalikes
    # such as scripts/kosx stay on the full path.
    if len(path.parts) >= 3 and path.parts[0] == "scripts" and path.parts[1] == "kos":
        return True

    # Root-level Markdown is documentation. Markdown nested under source or
    # tooling directories stays full-path so new locations fail closed.
    return len(path.parts) == 1 and path.suffix.lower() == ".md"


def is_kos_tools_path(raw_path: str) -> bool:
    path = PurePosixPath(raw_path)
    return len(path.parts) >= 3 and path.parts[0] == "scripts" and path.parts[1] == "kos"


def classify_paths(paths: list[str]) -> Classification:
    normalized = tuple(sorted(set(paths)))
    if not normalized:
        return Classification(
            name="full",
            requires_full=True,
            changed_paths=(),
            full_required_paths=(),
            reason="empty_diff_fails_closed",
        )

    # Code tiers apply only when every path belongs to one controlled family.
    families = []
    for raw in normalized:
        path = PurePosixPath(raw)
        if path.is_absolute() or ".." in path.parts or path.suffix.lower() == ".pbxproj":
            families.append("full")
        elif path.parts[0] in {"Keyboard", "KeyboardTests", "KeyboardExtensionTests", "KeyboardLayoutIntegrationTests"} and len(path.parts) > 1:
            families.append("keyboard_ui_only")
        elif len(path.parts) > 2 and path.parts[:2] == ("Packages", "RimeBridge"):
            families.append("rimebridge_only")
        elif path.parts[0] in {"Universe Keyboard", "UniverseKeyboardTests"} and len(path.parts) > 1:
            families.append("app_only")
        else:
            families.append("other")
    if len(set(families)) == 1 and families[0] in {"keyboard_ui_only", "rimebridge_only", "app_only"}:
        name = families[0]
        # Sync/Keychain changes need the signed integration job.
        if name != "keyboard_ui_only" and any("sync" in path.lower() or "keychain" in path.lower() for path in normalized):
            name = name.replace("_only", "_sync_only")
        return Classification(name, False, normalized, (), "controlled_code_tier")

    full_required = tuple(path for path in normalized if not is_lightweight_path(path))
    if full_required:
        return Classification(
            name="full",
            requires_full=True,
            changed_paths=normalized,
            full_required_paths=full_required,
            reason="sensitive_or_unknown_path",
        )

    if any(is_kos_tools_path(path) for path in normalized):
        return Classification(
            name="kos_tools_only",
            requires_full=False,
            changed_paths=normalized,
            full_required_paths=(),
            reason="all_paths_in_lightweight_allowlist",
        )

    return Classification(
        name="docs_only",
        requires_full=False,
        changed_paths=normalized,
        full_required_paths=(),
        reason="all_paths_in_lightweight_allowlist",
    )


def require_commit(reference: str) -> None:
    if not reference:
        raise ValueError("comparison reference is empty")
    result = subprocess.run(
        ["git", "cat-file", "-e", f"{reference}^{{commit}}"],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise ValueError(f"comparison reference is not a commit: {reference}")


def changed_paths(base: str, head: str) -> list[str]:
    require_commit(base)
    require_commit(head)
    result = subprocess.run(
        [
            "git",
            "diff",
            "--name-only",
            "--no-renames",
            "--diff-filter=ACDMRTUXB",
            "-z",
            base,
            head,
        ],
        check=True,
        capture_output=True,
    )
    return [item.decode("utf-8", errors="surrogateescape") for item in result.stdout.split(b"\0") if item]


def append_github_output(path: str, values: dict[str, str]) -> None:
    with open(path, "a", encoding="utf-8") as output:
        for key, value in values.items():
            output.write(f"{key}={value}\n")


def append_summary(path: str, result: Classification) -> None:
    with open(path, "a", encoding="utf-8") as summary:
        summary.write("## CI change classification\n\n")
        summary.write(f"- Classification: `{result.name}`\n")
        summary.write(f"- Requires full Swift gate: `{str(result.requires_full).lower()}`\n")
        summary.write(f"- Reason: `{result.reason}`\n")
        summary.write(f"- Changed paths: `{len(result.changed_paths)}`\n")
        if result.full_required_paths:
            summary.write("- Full-gate paths:\n")
            for changed_path in result.full_required_paths:
                summary.write(f"  - `{json.dumps(changed_path, ensure_ascii=True)[1:-1]}`\n")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", required=True)
    parser.add_argument("--head", required=True)
    parser.add_argument("--github-output")
    parser.add_argument("--summary")
    args = parser.parse_args()

    try:
        result = classify_paths(changed_paths(args.base, args.head))
    except (ValueError, subprocess.CalledProcessError) as error:
        print(f"FAIL closed: unable to classify change: {error}", file=sys.stderr)
        return 2

    matrix = {
        "full": (1, 1, 1, 1, 1, 1),
        "docs_only": (0, 0, 0, 0, 0, 0),
        "kos_tools_only": (0, 0, 0, 0, 0, 0),
        "keyboard_ui_only": (1, 0, 0, 1, 0, 1),
        "rimebridge_only": (1, 0, 1, 1, 0, 1),
        "rimebridge_sync_only": (1, 0, 1, 1, 1, 1),
        "app_only": (1, 0, 0, 1, 0, 1),
        "app_sync_only": (1, 0, 0, 1, 1, 1),
    }
    jobs = ("format", "keyboardcore", "rimebridge", "app_keyboard", "keychain", "build_release")
    payload = {
        "classification": result.name,
        "requires_full": str(result.requires_full).lower(),
        "reason": result.reason,
        "changed_count": str(len(result.changed_paths)),
        "base_sha": args.base,
        "head_sha": args.head,
    }
    payload.update({f"run_{job}": str(bool(value)).lower() for job, value in zip(jobs, matrix[result.name])})
    print(json.dumps({**payload, "full_required_paths": result.full_required_paths}, ensure_ascii=False))
    if args.github_output:
        append_github_output(args.github_output, payload)
    if args.summary:
        append_summary(args.summary, result)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
