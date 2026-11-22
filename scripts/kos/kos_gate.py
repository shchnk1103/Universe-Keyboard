#!/usr/bin/env python3
"""kos_gate.py -- single quality-gate wrapper with a dedup cache (KOS-GATE-DEDUP-001).

Runs doc_verify.sh (classify + lightweight checks + identity) once per
(mode, base_sha, head_sha, tree_sha, porcelain_clean) key; identical reruns
within the same mode hit the cache and print GATE_CACHED instead of paying
for the full suite again. executor and quality caches are strictly isolated.

Stdlib only; Python 3.9+.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

VENDOR_ALLOW = "Packages/RimeBridge/Vendor"


def die(code: int, message: str) -> int:
    print(message, file=sys.stderr)
    return code


def git(repo: str, *args: str) -> subprocess.CompletedProcess:
    return subprocess.run(["git", "-C", repo, *args], capture_output=True, text=True)


def porcelain_state(repo: str) -> "tuple[bool, list[str]]":
    """(clean, offending_paths). The RimeBridge Vendor symlink subtree is exempt."""
    r = git(repo, "status", "--porcelain", "--untracked-files=all")
    if r.returncode != 0:
        return False, ["<status-failed>"]
    offenders = []
    for line in r.stdout.splitlines():
        path = line[3:].strip('"').split(" -> ")[0]
        norm = path.replace("\\", "/")
        if norm == VENDOR_ALLOW or norm.startswith(VENDOR_ALLOW + "/"):
            continue
        offenders.append(path)
    return (not offenders), offenders


def resolve_base(repo: str, base: str) -> "str | None":
    r = git(repo, "rev-parse", "--verify", base + "^{commit}")
    return r.stdout.strip() if r.returncode == 0 else None


def gate_key(mode: str, base_sha: str, head_sha: str, tree_sha: str, clean: bool) -> str:
    raw = json.dumps([mode, base_sha, head_sha, tree_sha, clean], sort_keys=True)
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


def cache_path(cache_dir: Path, key: str) -> Path:
    return cache_dir / (key + ".json")


def main(argv: "list[str] | None" = None) -> int:
    ap = argparse.ArgumentParser(prog="kos_gate.py", description=__doc__.splitlines()[0])
    ap.add_argument("--worktree", default=".")
    ap.add_argument("--base", default="main")
    ap.add_argument("--mode", choices=("executor", "quality"), default="executor")
    ap.add_argument("--cache-dir", default=None,
                    help="cache directory (default: system temp dir, never inside the worktree)")
    ap.add_argument("--doc-verify", default="scripts/kos/doc_verify.sh")
    ap.add_argument("--no-cache", action="store_true")
    a = ap.parse_args(argv)

    worktree = os.path.abspath(a.worktree)
    # KOS-GATE-WORKTREE-001 (O79): accept linked worktrees whose .git is a
    # gitfile, not only directories; verify via rev-parse, fail closed otherwise.
    if not (os.path.isdir(os.path.join(worktree, ".git"))
            or os.path.isfile(os.path.join(worktree, ".git"))):
        return die(2, "not a git worktree: %s" % worktree)
    inside = subprocess.run(["git", "-C", worktree, "rev-parse", "--is-inside-work-tree"],
                            capture_output=True, text=True)
    if inside.returncode != 0 or inside.stdout.strip() != "true":
        return die(2, "not a git worktree: %s" % worktree)

    clean, offenders = porcelain_state(worktree)
    if not clean:
        return die(2, "worktree not clean (RimeBridge Vendor symlink exempt): %s" % ", ".join(offenders[:5]))

    head_r = git(worktree, "rev-parse", "HEAD")
    tree_r = git(worktree, "rev-parse", "HEAD^{tree}")
    if head_r.returncode or tree_r.returncode:
        return die(2, "cannot resolve HEAD/tree: " + head_r.stderr.strip())
    head_sha, tree_sha = head_r.stdout.strip(), tree_r.stdout.strip()

    base_sha = resolve_base(worktree, a.base)
    if not base_sha:
        return die(2, "cannot resolve --base %s" % a.base)

    summary = {
        "mode": a.mode,
        "base_sha": base_sha,
        "head_sha": head_sha,
        "tree_sha": tree_sha,
        "porcelain_clean": clean,
    }

    if a.cache_dir:
        cache_dir = Path(os.path.abspath(os.path.expanduser(a.cache_dir)))
        cache_dir.mkdir(parents=True, exist_ok=True)
    else:
        cache_dir = Path(tempfile.gettempdir()) / "kos-gate-cache"
        cache_dir.mkdir(parents=True, exist_ok=True)
    # never allow the cache to land inside the worktree (self-dirtying trap)
    if cache_dir.resolve() == Path(worktree).resolve() or str(cache_dir.resolve()).startswith(
        str(Path(worktree).resolve()) + os.sep
    ):
        return die(2, "cache dir must live outside the worktree: %s" % cache_dir)

    key = gate_key(a.mode, base_sha, head_sha, tree_sha, clean)
    entry = cache_path(cache_dir, key)
    if not a.no_cache and entry.is_file():
        try:
            cached = json.loads(entry.read_text(encoding="utf-8"))
            if cached.get("key") == key and cached.get("result") == "GATE_PASS":
                summary["result"] = "GATE_CACHED"
                print("GATE_CACHED")
                print(json.dumps(summary, ensure_ascii=False, indent=2))
                return 0
        except (ValueError, OSError):
            pass  # corrupt entry: fall through and rerun

    doc_verify = a.doc_verify
    if not os.path.isabs(doc_verify):
        doc_verify = os.path.join(worktree, doc_verify)
    proc = subprocess.run(["bash", doc_verify, base_sha], cwd=worktree,
                          capture_output=True, text=True)
    sys.stdout.write(proc.stdout)
    sys.stderr.write(proc.stderr)
    if proc.returncode != 0:
        # fail closed: no cache entry, non-zero exit
        summary["result"] = "GATE_FAIL"
        print("GATE_FAIL (exit %d); no cache written" % proc.returncode, file=sys.stderr)
        return proc.returncode if proc.returncode else 4

    entry.write_text(json.dumps({"key": key, "result": "GATE_PASS",
                                 "summary": summary}, ensure_ascii=False, indent=2) + "\n",
                     encoding="utf-8")
    summary["result"] = "GATE_PASS"
    print("GATE_PASS")
    print(json.dumps(summary, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
