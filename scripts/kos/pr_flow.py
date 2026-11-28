#!/usr/bin/env python3
"""Push a branch and open a PR, or wait for CI and optionally merge it.

PM sessions must not run `open`, and must not run `land --merge`.
Merge only when a Human orders it or runs the command.
"""
from __future__ import annotations

import argparse
import fcntl
import hashlib
import json
import importlib.util
import os
import re
import subprocess
import sys
import tarfile
import tempfile
import time
from io import BytesIO
from pathlib import Path

DEFAULT_IDENTITY = "Cowork 3P <cowork-3p@localhost>"
DEFAULT_REPO = "shchnk1103/Universe-Keyboard"
CASE_FAILED = re.compile(r"Test Case '-\[(\S+) ([^\]]+)\]' failed")
RUN_JOB = re.compile(r"/runs/(\d+)/job/(\d+)")
DOC_PREFIXES = (
    "docs/kos/",
    "docs/assignments/",
    "docs/PORTFOLIO.md",
    "AGENTS.md",
    "CLAUDE.md",
)


class Result:
    def __init__(self, code: int, out: str | bytes = "", err: str = ""):
        self.code = code
        self.out = out
        self.err = err

    @property
    def text(self) -> str:
        out = self.out.decode("utf-8", "replace") if isinstance(self.out, bytes) else self.out
        return out + self.err


class SubprocessRunner:
    def run(self, argv: list[str], cwd: str | None = None, env: dict | None = None) -> Result:
        proc = subprocess.run(argv, cwd=cwd, env=env, capture_output=True)
        return Result(proc.returncode, proc.stdout, proc.stderr.decode("utf-8", "replace"))


def _die(message: str) -> int:
    print(message, file=sys.stderr)
    return 1


_WAIT_CLOCK = None  # KOS-PR-WAIT-CLEANUP-001: injectable (sleep, print) clock


class _DefaultClock:
    def sleep(self, seconds: float) -> None:
        time.sleep(seconds)

    def print(self, line: str) -> None:
        print(line)


def _wait_clock():
    return _WAIT_CLOCK if _WAIT_CLOCK is not None else _DefaultClock()


def _land_lock_path(args) -> Path:
    """KOS-LAND-LOCK-001: default anchor is the main checkout's .git dir.

    If the checkout has no .git dir (stub-runner tests), fall back to a
    deterministic temp anchor keyed by the checkout path so concurrent lands
    on the same checkout still exclude each other without touching /main.
    """
    explicit = getattr(args, "lock_file", None)
    if explicit:
        return Path(explicit)
    candidate = Path(args.main_checkout) / ".git" / "land.lock"
    if candidate.parent.is_dir():
        return candidate
    key = hashlib.sha256(str(Path(args.main_checkout)).encode("utf-8")).hexdigest()[:16]
    return Path(tempfile.gettempdir()) / f"kos-land-{key}.lock"


def _acquire_land_lock(path: Path, timeout: float) -> "int | None":
    """Exclusive flock with bounded wait. Returns fd, or None on timeout.

    Never removes a lock held by someone else: a live flock is the only
    proof of ownership, and expiry just fails closed.
    """
    path = Path(path)
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        fd = os.open(path, os.O_CREAT | os.O_RDWR, 0o644)
    except OSError as exc:
        raise RuntimeError(f"land lock unavailable: {path}: {exc}") from exc
    deadline = time.monotonic() + max(timeout, 0.0)
    while True:
        try:
            fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
            return fd
        except OSError:
            if time.monotonic() >= deadline:
                os.close(fd)
                return None
            time.sleep(0.05)


_PORTFOLIO_REF = re.compile(r"\b(?:PF-\d+|PB-\d+[A-Z]?|O\d+)\b")


def _portfolio_refs(*chunks: str) -> list[str]:
    """Unique PF / PB / O ids, in first-seen order. Empty when nothing matches."""
    found: list[str] = []
    seen: set[str] = set()
    for chunk in chunks:
        for match in _PORTFOLIO_REF.finditer(chunk or ""):
            token = match.group(0)
            if token not in seen:
                seen.add(token)
                found.append(token)
    return found


def _portfolio_todo_line(refs: list[str]) -> str:
    if not refs:
        return ""
    return (
        "PORTFOLIO_RECONCILE_TODO: "
        + ", ".join(refs)
        + " -> 请同步更新 docs/PORTFOLIO.md 与当前 docs/releases/vX.Y.Z.md"
    )


def _portfolio_todo_from_land(args, info: dict) -> str:
    """O84: remind the publisher to close portfolio rows after a real merge.

    Title and commit subjects come from the view payload already fetched.
    Missing fields stay silent. No extra gh/git call, so CI stubs stay valid.
    """
    commits = info.get("commits") or []
    commit_text = "\n".join(
        " ".join(str(item.get(key, "")) for key in ("messageHeadline", "messageBody", "message"))
        for item in commits
        if isinstance(item, dict)
    )
    refs = _portfolio_refs(
        getattr(args, "portfolio_refs", "") or "",
        getattr(args, "task_id", "") or "",
        str(info.get("title") or ""),
        commit_text,
    )
    return _portfolio_todo_line(refs)


def _summary(payload: dict, log_dir: Path | None, pr: str) -> None:
    print(
        "status={status} pr={pr} head={head} reruns={reruns} merge={merge} ff={ff} record={record} cleanup={cleanup}".format(
            status=payload.get("status"),
            pr=payload.get("pr"),
            head=payload.get("head"),
            reruns=payload.get("reruns"),
            merge=payload.get("merge_commit"),
            ff=payload.get("ff"),
            record=payload.get("record"),
            cleanup=payload.get("cleanup"),
        )
    )
    if log_dir is not None:
        log_dir.mkdir(parents=True, exist_ok=True)
        (log_dir / f"land-{pr}.json").write_text(
            json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )


def _git(runner, worktree: str, *args: str) -> Result:
    return runner.run(["git", "-C", worktree, *args])


def _allowed_untracked(path: str, prefixes: list[str]) -> bool:
    for prefix in prefixes:
        prefix = prefix.rstrip("/")
        if path == prefix or path.startswith(prefix + "/"):
            return True
    return False


def _worktree_dirty(status: str, allow: list[str]) -> str | None:
    for raw in status.splitlines():
        if not raw.strip():
            continue
        path = raw[3:] if len(raw) > 3 else raw
        if raw.startswith("?? ") and _allowed_untracked(path, allow):
            continue
        return raw
    return None


def _identity_errors(log_text: str, identity: str) -> list[str]:
    errors = []
    for line in log_text.splitlines():
        if line.startswith("AUTHOR:") or line.startswith("COMMITTER:"):
            value = line.split(":", 1)[1]
            if value != identity:
                errors.append(line)
    return errors


def _name_set(text: str) -> set[str]:
    return {line.strip() for line in text.splitlines() if line.strip()}


def _bilingual_error(title: str, body: str) -> str | None:
    left, sep, right = title.partition("/")
    if not sep or not re.search(r"[A-Za-z]", left) or not re.search(r"[\u4e00-\u9fff]", right):
        return "H10: title must contain '/' with English on the left and Chinese on the right"
    summary = next((line for line in body.splitlines() if line.startswith("Summary:")), "")
    if not re.search(r"[A-Za-z]", summary) or not re.search(r"[\u4e00-\u9fff]", body):
        return "H10: body needs a Summary: line with English text and Chinese anywhere in the body"
    return None


def _body_rejected(body: str) -> bool:
    lowered = body.lower()
    return "co-authored-by" in lowered or "generated with" in lowered


def _push_retryable(result: Result) -> bool:
    blob = result.text.lower()
    return result.code != 0 and ("remote rejected" in blob or re.search(r"\b5\d\d\b", result.text) is not None)


def _load_flaky(path: Path) -> set[str]:
    names = set()
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            names.add(line)
    return names


def _parse_cases(log_text: str) -> list[tuple[str, str]]:
    """Return (Target.Class.method, error quote) pairs. Quotes are at most 300 characters."""
    lines = log_text.splitlines()
    found = []
    for index, line in enumerate(lines):
        match = CASE_FAILED.search(line)
        if not match:
            continue
        name = f"{match.group(1)}.{match.group(2)}"
        quote = ""
        for earlier in lines[: index + 1]:
            at = earlier.find("error:")
            if at >= 0:
                quote = earlier[at : at + 300]
        found.append((name, quote))
    return found


# Final CI snapshot buckets. README cites this same set.
SNAPSHOT_BUCKETS = frozenset({"pass", "fail", "pending", "skipping", "skipped", "cancel"})


def _module_domain(path: str) -> str:
    """Collapse a repo path to its module/package domain for drift comparison.

    Named packages (Packages/<P>, Keyboard, Universe Keyboard, scripts/kos) map
    to themselves; everything else falls back to the first path segment.
    """
    parts = Path(path).parts
    if not parts:
        return path
    if parts[0] == "Packages" and len(parts) > 1:
        return "Packages/" + parts[1]
    if parts[0] in {"Keyboard", "Universe Keyboard", "scripts"} and len(parts) > 1:
        if parts[0] == "scripts":
            return "scripts/" + parts[1]
        return parts[0]
    return parts[0]


def _same_module_drift_error(runner, worktree: str, base_sha: str, head: str,
                             branch_files: set[str]) -> str | None:
    """Reject open when origin/main moved past base into the same module domain.

    Returns an error string to block the push, or None when origin/main has not
    advanced beyond base or the advanced changes touch disjoint module domains.
    """
    origin = _git(runner, worktree, "rev-parse", "origin/main")
    if origin.code != 0:
        return None  # offline / no remote ref: stay permissive
    origin_tip = origin.text.strip()
    if origin_tip == base_sha:
        return None
    ahead = _git(runner, worktree, "merge-base", "--is-ancestor", base_sha, origin_tip)
    if ahead.code != 0:
        return None  # origin/main is not ahead of base (diverged or unrelated)
    remote_diff = _git(runner, worktree, "diff", "--name-only", base_sha, origin_tip)
    if remote_diff.code != 0:
        return f"same-module drift check failed: {remote_diff.text.strip() or 'diff failed'}"
    remote_modules = {_module_domain(name) for name in _name_set(remote_diff.text)}
    branch_modules = {_module_domain(name) for name in branch_files}
    if not remote_modules & branch_modules:
        return None
    return (
        "same-module drift: origin/main advanced past --base-sha and touches "
        f"{sorted(remote_modules & branch_modules)}; rebase onto origin/main and rerun tests before opening"
    )


def _snapshot_rows(text: str) -> list[dict] | None:
    """Rows from one `gh pr checks --json` snapshot. Watch tables are not accepted."""
    try:
        data = json.loads(text)
    except json.JSONDecodeError:
        return None
    if not isinstance(data, list):
        return None
    rows = []
    for index, item in enumerate(data):
        if not isinstance(item, dict):
            return None
        link = str(item.get("link") or "")
        found = RUN_JOB.search(link)
        bucket = item.get("bucket")
        # Keep the raw bucket. Case or whitespace folding would admit values
        # outside the contract whitelist.
        rows.append(
            {
                "name": str(item.get("name") or ""),
                "state": ("skipped" if bucket == "skipping" and item.get("state") == "SKIPPED"
                          else bucket if isinstance(bucket, str) else ""),
                "url": link,
                "run": found.group(1) if found else "",
                "job": found.group(2) if found else "",
                "index": index,
            }
        )
    return rows


def _snapshot_buckets_invalid(rows: list[dict]) -> bool:
    """True when the final snapshot is empty or any bucket is outside the whitelist."""
    if not rows:
        return True
    return any(row["state"] not in SNAPSHOT_BUCKETS for row in rows)


def _matrix_error(rows: list[dict], classification: str, common: frozenset,
                  required_by_class: dict, heavy: frozenset) -> str | None:
    """Validate a complete check snapshot against an independently obtained tier."""
    required = required_by_class.get(classification)
    if required is None:
        return "unknown classification"
    by_name: dict[str, list[str]] = {}
    for row in rows:
        name, state = row.get("name"), row.get("state")
        if not isinstance(name, str) or not name:
            return "unnamed check"
        by_name.setdefault(name, []).append(state)
        if state not in {"pass", "skipped"}:
            return f"unfinished or unsuccessful check: {name}"
        if state == "skipped" and name not in heavy - required:
            return f"unexpected skipped check: {name}"
    for name in common | heavy:
        states = by_name.get(name, [])
        if len(states) != 1:
            return f"missing or duplicate check: {name}"
        if name in common | required and states[0] != "pass":
            return f"unexpected result for {name}: {states[0]}"
    return None


def _classification_error(evidence: dict, expected_head: str, expected_base: str,
                          required_by_class: dict) -> str | None:
    """Reject classification evidence unless it belongs to this exact comparison."""
    if not isinstance(evidence, dict):
        return "classification evidence is not an object"
    if evidence.get("head_sha") != expected_head or evidence.get("base_sha") != expected_base:
        return "classification comparison mismatch"
    if evidence.get("classification") not in required_by_class:
        return "unknown classification"
    return None


def _bad_states(rows: list[dict]) -> list[dict]:
    return [row for row in rows if row["state"] in {"fail", "cancel"}]


def _failure_key(row: dict) -> tuple[str, str | int]:
    """One failed row, one key. Job names can repeat, so they are not keys.

    A job id parsed from ``link`` is stable across the row. Otherwise the
    snapshot index keeps two unparsed rows from collapsing into one.
    """
    if row.get("job"):
        return ("job", row["job"])
    return ("index", row["index"])


def _pending_states(rows: list[dict]) -> list[dict]:
    return [row for row in rows if row["state"] in {"pending", "skipping"}]


def _doc_paths(names: set[str]) -> bool:
    for name in names:
        for prefix in DOC_PREFIXES:
            if name == prefix or name.startswith(prefix):
                return True
    return False


def _warning_lines(text: str) -> set[str]:
    return {line for line in text.splitlines() if "WARNING" in line}



def _open_log_path(log_dir: str | None, branch: str) -> Path | None:
    if not log_dir:
        return None
    return Path(log_dir) / f"open-{branch.replace('/', '-')}.json"


def _write_open_log(path: Path | None, payload: dict) -> None:
    if path is None:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def _cleanup_requested(args) -> bool:
    return bool(getattr(args, "cleanup_worktree", None) or getattr(args, "cleanup_branch", None))


def _cleanup_args_ok(args) -> str | None:
    has_wt = bool(getattr(args, "cleanup_worktree", None))
    has_br = bool(getattr(args, "cleanup_branch", None))
    if has_wt ^ has_br:
        return "cleanup requires both --cleanup-worktree and --cleanup-branch"
    return None


def _worktree_listed(runner, main_checkout: str, worktree: str) -> bool:
    listed = _git(runner, main_checkout, "worktree", "list", "--porcelain")
    if listed.code != 0:
        return False
    target = str(Path(worktree).resolve())
    for line in listed.text.splitlines():
        if line.startswith("worktree "):
            current = str(Path(line[len("worktree "):]).resolve())
            if current == target:
                return True
    return False


def _run_cleanup(args, runner, expect_head: str) -> str:
    """Return cleanup status string after a successful merged+ff land."""
    tip = _git(runner, args.main_checkout, "rev-parse", f"refs/heads/{args.cleanup_branch}")
    if tip.code != 0 or tip.text.strip() != expect_head:
        return "skipped:branch-tip-mismatch"
    if args.cleanup_branch in {"main", "master"} or args.cleanup_branch.startswith(("preserve/", "local/", "backup")):
        return "skipped:protected-branch"
    ancestor = _git(runner, args.main_checkout, "merge-base", "--is-ancestor", args.cleanup_branch, "origin/main")
    if ancestor.code != 0:
        return "skipped:not-ancestor"
    if not _worktree_listed(runner, args.main_checkout, args.cleanup_worktree):
        return "skipped:worktree-mismatch"
    wt_head = _git(runner, args.cleanup_worktree, "rev-parse", "HEAD")
    if wt_head.code != 0 or wt_head.text.strip() != expect_head:
        return "skipped:worktree-mismatch"
    status = _git(runner, args.cleanup_worktree, "status", "--porcelain")
    if status.code != 0:
        return "failed:status"
    allow = list(args.cleanup_allow_untracked or [])
    # Cleanup is authorized only for the existing Vendor symlink, never an
    # arbitrary caller-supplied path (which could escape the worktree).
    if any(path != "Packages/RimeBridge/Vendor" for path in allow):
        return "skipped:unsupported-allowed-path"
    # The main checkout is never a cleanup target; this guard must fire before
    # the dirty check so a dirty main checkout still reports main-checkout.
    if Path(args.cleanup_worktree).resolve() == Path(args.main_checkout).resolve():
        return "skipped:main-checkout"
    dirty = _worktree_dirty(status.text, allow)
    if dirty:
        return "skipped:worktree-dirty"
    for prefix in allow:
        candidate = Path(args.cleanup_worktree) / prefix
        if not candidate.exists() and not candidate.is_symlink():
            continue
        if candidate.is_symlink():
            try:
                candidate.unlink()
            except OSError as exc:
                return f"failed:unlink:{exc}"
        else:
            return "skipped:allowed-path-not-symlink"
    removed = _git(runner, args.main_checkout, "worktree", "remove", args.cleanup_worktree)
    if removed.code != 0:
        return "failed:worktree-remove:" + removed.text.strip()
    return "worktree-removed"

def cmd_open(args, runner) -> int:
    log_path = _open_log_path(args.log_dir, args.branch)
    payload = {
        "status": "error",
        "branch": args.branch,
        "head": None,
        "pr_url": None,
        "error": None,
    }
    code = 1
    try:
        head = _git(runner, args.worktree, "rev-parse", "HEAD")
        if head.code != 0:
            payload["error"] = head.text.strip() or "rev-parse failed"
            return _die(payload["error"])
        actual = head.text.strip()
        payload["head"] = actual
        if actual != args.expect_head:
            payload["error"] = f"HEAD {actual} != --expect-head {args.expect_head}"
            return _die(payload["error"])

        status = _git(runner, args.worktree, "status", "--porcelain")
        if status.code != 0:
            payload["error"] = status.text.strip() or "status failed"
            return _die(payload["error"])
        dirty = _worktree_dirty(status.text, args.allow_untracked)
        if dirty:
            payload["error"] = f"worktree not clean: {dirty}"
            return _die(payload["error"])

        ident = _git(
            runner,
            args.worktree,
            "log",
            "--format=AUTHOR:%an <%ae>%nCOMMITTER:%cn <%ce>",
            f"{args.base_sha}..HEAD",
        )
        if ident.code != 0:
            payload["error"] = ident.text.strip() or "git log failed"
            return _die(payload["error"])
        bad_ident = _identity_errors(ident.text, args.identity)
        if bad_ident:
            payload["error"] = "identity mismatch: " + "; ".join(bad_ident)
            return _die(payload["error"])

        diff = _git(runner, args.worktree, "diff", "--name-only", args.base_sha, "HEAD")
        if diff.code != 0:
            payload["error"] = diff.text.strip() or "diff failed"
            return _die(payload["error"])
        expected = _name_set(Path(args.files).read_text(encoding="utf-8"))
        actual_files = _name_set(diff.text)
        if actual_files != expected:
            payload["error"] = f"file set mismatch: got {sorted(actual_files)} expected {sorted(expected)}"
            return _die(payload["error"])

        body = Path(args.body_file).read_text(encoding="utf-8")
        if _body_rejected(body):
            payload["error"] = "body contains Co-authored-by or Generated with"
            return _die(payload["error"])

        tip = _git(runner, args.worktree, "rev-parse", f"refs/heads/{args.branch}")
        if tip.code != 0:
            payload["error"] = tip.text.strip() or "branch rev-parse failed"
            return _die(payload["error"])
        tip_sha = tip.text.strip()
        if tip_sha != args.expect_head:
            payload["error"] = f"branch ref {tip_sha} != --expect-head {args.expect_head}"
            return _die(payload["error"])

        remote = _git(runner, args.worktree, "ls-remote", "--heads", "origin", args.branch)
        if remote.code != 0:
            payload["error"] = remote.text.strip() or "ls-remote failed"
            return _die(payload["error"])
        if remote.text.strip():
            payload["error"] = f"remote branch already exists: {remote.text.strip()}"
            return _die(payload["error"])

        bilingual = _bilingual_error(args.title, body)
        if bilingual:
            payload["error"] = bilingual
            return _die(payload["error"])

        drift = _same_module_drift_error(runner, args.worktree, args.base_sha, actual, actual_files)
        if drift:
            payload["error"] = drift
            return _die(payload["error"])

        if args.dry_run:
            payload["status"] = "dry-run"
            payload["error"] = None
            print(f"dry-run ok branch={args.branch} head={actual}")
            code = 0
            return 0

        push_argv = [
            "git",
            "-C",
            args.worktree,
            "-c",
            "push.followTags=false",
            "push",
            "origin",
            f"refs/heads/{args.branch}:refs/heads/{args.branch}",
        ]
        pushed = runner.run(push_argv)
        if _push_retryable(pushed):
            again = _git(runner, args.worktree, "ls-remote", "--heads", "origin", args.branch)
            if again.code != 0:
                payload["error"] = again.text.strip() or "ls-remote failed after push"
                return _die(payload["error"])
            if again.text.strip():
                payload["error"] = "push failed and remote branch now exists; not retrying"
                return _die(payload["error"])
            pushed = runner.run(push_argv)
        if pushed.code != 0:
            payload["error"] = "push failed: " + pushed.text.strip()
            return _die(payload["error"])

        created = runner.run(
            [
                "gh",
                "pr",
                "create",
                "--repo",
                args.repo,
                "--base",
                "main",
                "--head",
                args.branch,
                "--title",
                args.title,
                "--body-file",
                args.body_file,
            ]
        )
        if created.code != 0:
            payload["error"] = "gh pr create failed: " + created.text.strip()
            return _die(payload["error"])
        url = created.text.strip()
        print(url)
        payload["status"] = "opened"
        payload["pr_url"] = url
        payload["error"] = None
        code = 0
        return 0
    finally:
        if payload["status"] == "error" and payload["error"] is None and code != 0:
            payload["error"] = "open failed"
        if code == 0 and payload["status"] == "error":
            payload["status"] = "opened"
        _write_open_log(log_path, payload)


def _write_record(path: Path, pr: str, head: str, rows: list[dict], parsed: dict, action: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    lines = [f"# CI PR {pr}", "", f"- PR: {pr}", f"- head: {head}", "", "## jobs"]
    for row in rows:
        lines.append(f"- {row['name']}: {row['state']} run={row['run']} job={row['job']}")
    lines.append("")
    lines.append("## failures")
    for key, cases in parsed.items():
        label = f"{key[0]}={key[1]}"
        if not cases:
            lines.append(f"- {label}: (no test case)")
            continue
        lines.append(f"- {label}")
        for name, quote in cases:
            lines.append(f"- {name}")
            if quote:
                lines.append(f"  - {quote}")
    lines.append("")
    lines.append(f"## action\n\n{action}\n")
    path.write_text("\n".join(lines), encoding="utf-8")


def _append_record(path: Path | None, text: str) -> None:
    if path is None:
        return
    with path.open("a", encoding="utf-8") as handle:
        handle.write("\n" + text + "\n")


def _export_archive(runner, main_checkout: str, head: str, dest: Path) -> Result:
    archived = runner.run(["git", "-C", main_checkout, "archive", head])
    if archived.code != 0:
        return archived
    raw = archived.out if isinstance(archived.out, bytes) else archived.out.encode("utf-8")
    dest.mkdir(parents=True, exist_ok=True)
    with tarfile.open(fileobj=BytesIO(raw), mode="r:*") as tar:
        if sys.version_info >= (3, 12):
            tar.extractall(dest, filter="data")
        else:
            # Python 3.9-3.11 has no extraction-filter kwarg; the default
            # (unfiltered) behaviour is the only option there.
            tar.extractall(dest)
    return Result(0, "", "")


def _task_id_error(task_id: str) -> "str | None":
    """KOS-PR-WAIT-CLEANUP-001: empty/illegal task ids must never reach the
    cleanup tool (an empty id would make it sweep the whole library)."""
    if not task_id or not task_id.strip():
        return "empty task id"
    if task_id.strip() != task_id or any(ch.isspace() for ch in task_id):
        return "task id contains whitespace"
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]*", task_id):
        return "task id has illegal characters"
    return None


def _run_auto_cleanup(args, runner) -> None:
    """Best-effort cache recycle after a merged+ff land. Never fatal."""
    tool = getattr(args, "cleanup_tool", None)
    task_id = getattr(args, "task_id", None)
    clock = _wait_clock()
    if task_id is None and getattr(args, "cleanup_worktree", None):
        parent = Path(args.cleanup_worktree).resolve().parent.name
        # only infer for KOS-style task dirs (uppercase hyphenated ids like
        # KOS-XXX-001); temp dirs and plain names must never trigger a sweep
        if parent and re.fullmatch(r"[A-Z][A-Z0-9]*(-[A-Za-z0-9]+)+", parent) and not _task_id_error(parent):
            task_id = parent
    if task_id is None:
        return
    error = _task_id_error(task_id)
    if error:
        clock.print(f"cleanup-warning: skipped ({error}); cache not recycled")
        return
    if not tool or not Path(tool).is_file():
        clock.print(f"cleanup-warning: tool missing ({tool}); cache not recycled")
        return
    result = runner.run(["bash", str(tool), "r", task_id, "--apply"])
    if result.code != 0:
        clock.print(
            f"cleanup-warning: {tool} r {task_id} --apply exited {result.code}; "
            "merged state kept, cache not recycled"
        )
    else:
        clock.print(f"cleanup-done: {tool} r {task_id} --apply")


def cmd_land(args, runner) -> int:
    bad = _cleanup_args_ok(args)
    if bad:
        return _die(bad)
    log_dir = Path(args.log_dir) if args.log_dir else None
    view = runner.run(
        ["gh", "pr", "view", args.pr, "--repo", args.repo, "--json", "state,headRefOid,title,commits"]
    )
    payload = {
        "status": "stop",
        "pr": args.pr,
        "head": None,
        "reruns": 0,
        "merge_commit": None,
        "ff": None,
        "record": None,
        "cleanup": None,
    }
    if view.code != 0:
        payload["status"] = "view-failed"
        _summary(payload, log_dir, args.pr)
        return _die(view.text.strip() or "gh pr view failed")
    try:
        info = json.loads(view.text)
    except json.JSONDecodeError:
        payload["status"] = "view-unparsed"
        _summary(payload, log_dir, args.pr)
        return _die("gh pr view did not return JSON")
    # Keep the opening view: a later re-fetch overwrites `info` without title/commits.
    opened_info = info
    state = str(info.get("state", ""))
    head = str(info.get("headRefOid", ""))
    payload["head"] = head
    if state.upper() != "OPEN" or head != args.expect_head:
        payload["status"] = "not-open-or-head-mismatch"
        _summary(payload, log_dir, args.pr)
        return _die(f"stop: state={state} head={head} expect={args.expect_head}")
    if args.dry_run:
        payload["status"] = "dry-run"
        payload["cleanup"] = "dry-run" if _cleanup_requested(args) else None
        _summary(payload, log_dir, args.pr)
        print("dry-run: PR is OPEN and head matches; not watching")
        return 0

    flaky = _load_flaky(Path(args.known_flaky))
    reruns = 0
    attempt = 1
    record_path: Path | None = None
    rows: list[dict] = []
    while True:
        # --watch only waits. Its printed tables are not the judgment.
        runner.run(
            ["gh", "pr", "checks", args.pr, "--repo", args.repo, "--watch", "--interval", "30"]
        )
        snapshot = runner.run(
            ["gh", "pr", "checks", args.pr, "--repo", args.repo, "--json", "name,state,bucket,link"]
        )
        rows = _snapshot_rows(snapshot.text) if snapshot.code == 0 else None
        if rows is None:
            payload.update(status="checks-failed-unparsed", reruns=reruns)
            _summary(payload, log_dir, args.pr)
            return _die("checks snapshot was not JSON")
        if _snapshot_buckets_invalid(rows):
            payload.update(status="checks-snapshot-invalid", reruns=reruns, head=head)
            _summary(payload, log_dir, args.pr)
            return _die("checks snapshot empty or bucket outside the whitelist; not rerunning or merging")
        if _pending_states(rows):
            run_ids = sorted({row["run"] for row in rows if row["run"]})
            run_label = run_ids[0] if run_ids else "none"
            record_path = Path(args.pm_log) / "ci" / f"pr{args.pr}-run{run_label}-attempt{attempt}.md"
            _write_record(record_path, args.pr, head, rows, {}, "checks-pending")
            payload.update(status="checks-pending", reruns=reruns, head=head, record=str(record_path))
            _summary(payload, log_dir, args.pr)
            return _die("checks still pending; not rerunning or merging")
        bad = _bad_states(rows)
        if not bad:
            break

        parsed: dict[tuple, list] = {}
        substantive = []
        for row in bad:
            key = _failure_key(row)
            if "final-quality-gate" in row["name"]:
                parsed[key] = []
                continue
            substantive.append(row)
            if not row["run"] or not row["job"]:
                parsed[key] = []
                continue
            log = runner.run(
                [
                    "gh",
                    "run",
                    "view",
                    row["run"],
                    "--repo",
                    args.repo,
                    "--job",
                    row["job"],
                    "--log-failed",
                ]
            )
            parsed[key] = _parse_cases(log.text) if log.code == 0 or log.text.strip() else []

        run_ids = sorted({row["run"] for row in substantive if row["run"]})
        run_label = run_ids[0] if run_ids else "none"
        record_path = Path(args.pm_log) / "ci" / f"pr{args.pr}-run{run_label}-attempt{attempt}.md"
        cases = [name for group in parsed.values() for name, _quote in group]
        can_rerun = (
            substantive
            and all(parsed.get(_failure_key(row)) for row in substantive)
            and all(name in flaky for name in cases)
            and reruns < args.max_reruns
        )
        action = "rerun" if can_rerun else "stop-no-merge"
        _write_record(record_path, args.pr, head, rows, parsed, action)
        payload["record"] = str(record_path)
        if not can_rerun:
            payload.update(status="ci-failed", reruns=reruns, head=head)
            _summary(payload, log_dir, args.pr)
            return _die("CI failed outside the known-flaky rerun rule; not merging")
        for run_id in run_ids:
            rerun = runner.run(["gh", "run", "rerun", run_id, "--repo", args.repo, "--failed"])
            if rerun.code != 0:
                payload.update(status="rerun-failed", reruns=reruns)
                _summary(payload, log_dir, args.pr)
                return _die("gh run rerun failed: " + rerun.text.strip())
        reruns += 1
        attempt += 1

    # Bind the local classification to the PR's current base and candidate head.
    base_view = runner.run(["gh", "pr", "view", args.pr, "--repo", args.repo,
                            "--json", "baseRefOid,headRefOid"])
    try:
        base_info = json.loads(base_view.text) if base_view.code == 0 else {}
        base = base_info.get("baseRefOid", "")
        if not base or base_info.get("headRefOid") != head:
            raise ValueError("base or head unavailable")
        classifier = Path(args.main_checkout) / "scripts/ci/classify_changes.py"
        classified = runner.run([sys.executable, "-I", str(classifier), "--base", base,
                                 "--head", head], cwd=args.main_checkout)
        evidence = json.loads(classified.text) if classified.code == 0 else {}
        spec = importlib.util.spec_from_file_location("kos_clauses_spec", Path(__file__).with_name("clauses_spec.py"))
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        error = _classification_error(evidence, head, base, module.CLASSIFICATION_REQUIRED_HEAVY)
        if not error:
            error = _matrix_error(rows, evidence["classification"], module.COMMON_REQUIRED_CHECKS,
                                  module.CLASSIFICATION_REQUIRED_HEAVY, module.HEAVY_CHECKS)
        if error:
            raise ValueError(error)
    except (ValueError, TypeError, KeyError, OSError) as exc:
        payload.update(status="classification-or-checks-invalid", reruns=reruns)
        _summary(payload, log_dir, args.pr)
        return _die(f"classification or checks invalid: {exc}")
    payload["classification"] = evidence["classification"]
    payload["base"] = base
    payload.update(status="green", reruns=reruns, head=head)
    if record_path is None:
        run_ids = sorted({row["run"] for row in rows if row["run"]})
        run_label = run_ids[0] if run_ids else "none"
        record_path = Path(args.pm_log) / "ci" / f"pr{args.pr}-run{run_label}-attempt{attempt}.md"
        _write_record(record_path, args.pr, head, rows, {}, "green")
        payload["record"] = str(record_path)
    if not args.merge:
        payload["status"] = "green-no-merge"
        _summary(payload, log_dir, args.pr)
        return 0

    again = runner.run(["gh", "pr", "view", args.pr, "--repo", args.repo, "--json", "state,headRefOid"])
    if again.code != 0:
        return _die(again.text.strip() or "second pr view failed")
    try:
        info = json.loads(again.text)
    except json.JSONDecodeError:
        payload["status"] = "view-unparsed"
        _summary(payload, log_dir, args.pr)
        return _die("second gh pr view did not return JSON")
    if str(info.get("headRefOid", "")) != args.expect_head:
        payload["status"] = "head-changed"
        _summary(payload, log_dir, args.pr)
        return _die(f"head changed to {info.get('headRefOid')}; not merging")

    if args.validator:
        names = runner.run(["gh", "pr", "diff", args.pr, "--repo", args.repo, "--name-only"])
        if names.code != 0:
            return _die(names.text.strip() or "gh pr diff failed")
        if _doc_paths(_name_set(names.text)):
            if not log_dir:
                return _die("--log-dir is required to export the tree for --validator")
            exported = log_dir / f"validator-{args.expect_head[:12]}"
            archived = _export_archive(runner, args.main_checkout, args.expect_head, exported)
            if archived.code != 0:
                payload["status"] = "archive-failed"
                _summary(payload, log_dir, args.pr)
                return _die("git archive failed; not merging")
            env = os.environ.copy()
            if args.kos_as_of:
                env["KOS_AS_OF"] = args.kos_as_of
            left = runner.run(["bash", args.validator, str(exported)], env=env)
            right = runner.run(["bash", args.validator, args.main_checkout], env=env)
            if left.code != right.code or _warning_lines(left.text) != _warning_lines(right.text):
                payload["status"] = "validator-differs"
                _summary(payload, log_dir, args.pr)
                return _die("validator exit or WARNING set differs; not merging")

    readiness = runner.run(
        ["gh", "pr", "view", args.pr, "--repo", args.repo, "--json", "autoMergeRequest,mergeStateStatus,headRefOid"]
    )
    try:
        ready = json.loads(readiness.text) if readiness.code == 0 else {}
    except json.JSONDecodeError:
        ready = {}
    if ready.get("autoMergeRequest") is not None:
        payload["status"] = "auto-merge-present"
        _summary(payload, log_dir, args.pr)
        return _die("auto-merge present; not merging")
    if ready.get("mergeStateStatus") != "CLEAN" or ready.get("headRefOid") != args.expect_head:
        payload["status"] = "not-clean"
        _summary(payload, log_dir, args.pr)
        return _die("merge readiness or head check failed; not merging")

    merged = runner.run(
        [
            "gh",
            "pr",
            "merge",
            args.pr,
            "--repo",
            args.repo,
            "--merge",
            "--match-head-commit",
            args.expect_head,
        ]
    )
    if "auto-merge" in merged.text.lower():
        payload["status"] = "auto-merge-refused"
        _summary(payload, log_dir, args.pr)
        return _die("gh would enable auto-merge; not treating this as a merge")
    if merged.code != 0:
        payload["status"] = "merge-failed"
        _summary(payload, log_dir, args.pr)
        return _die("gh pr merge failed: " + merged.text.strip())

    shown = runner.run(
        ["gh", "pr", "view", args.pr, "--repo", args.repo, "--json", "mergeCommit"]
    )
    merge_oid = None
    if shown.code == 0:
        try:
            merge_oid = json.loads(shown.text).get("mergeCommit", {}) or {}
            if isinstance(merge_oid, dict):
                merge_oid = merge_oid.get("oid")
        except json.JSONDecodeError:
            merge_oid = None
    payload["merge_commit"] = merge_oid

    def stop(status, message):
        payload["status"] = status
        _append_record(record_path, f"merge={merge_oid}\nff={payload['ff']}\ncleanup={payload['cleanup']}")
        _summary(payload, log_dir, args.pr)
        return _die(message)

    if not isinstance(merge_oid, str) or not re.fullmatch(r"[0-9a-fA-F]{40}", merge_oid):
        return stop("merge-result-unknown", "merge commit unavailable; cleanup stopped")
    lock_fd = _acquire_land_lock(_land_lock_path(args), float(getattr(args, "lock_timeout", 30.0)))
    if lock_fd is None:
        payload["status"] = "land-lock-timeout"
        _summary(payload, log_dir, args.pr)
        return _die(f"land-lock-timeout: {_land_lock_path(args)} held elsewhere; waited {getattr(args, 'lock_timeout', 30.0)}s")
    try:
        fetched = _git(runner, args.main_checkout, "fetch", "origin", "main")
        if fetched.code != 0:
            return stop("fetch-failed", "fetch failed; cleanup stopped")
        for commit in (merge_oid, args.expect_head):
            if _git(runner, args.main_checkout, "merge-base", "--is-ancestor", commit, "origin/main").code != 0:
                return stop("unreachable", "merge or task commit not reachable; cleanup stopped")

        if _cleanup_requested(args):
            payload["cleanup"] = _run_cleanup(args, runner, args.expect_head)
            if payload["cleanup"] != "worktree-removed":
                return stop("cleanup-stopped", "worktree cleanup stopped")

        branch = _git(runner, args.main_checkout, "rev-parse", "--abbrev-ref", "HEAD")
        porcelain = _git(runner, args.main_checkout, "status", "--porcelain", "--untracked-files=all")
        old = _git(runner, args.main_checkout, "rev-parse", "HEAD")
        if branch.code or branch.text.strip() != "main":
            payload["ff"] = "skipped:not-main; tell Human"
        elif porcelain.code or porcelain.text.strip():
            payload["ff"] = "skipped:dirty-or-status-unknown; tell Human"
        elif old.code:
            payload["ff"] = "skipped:head-unknown; tell Human"
        else:
            ancestor = _git(runner, args.main_checkout, "merge-base", "--is-ancestor", "HEAD", "origin/main")
            if ancestor.code != 0:
                payload["ff"] = "skipped:not-ancestor-or-unknown; tell Human"
            else:
                fast = _git(runner, args.main_checkout, "merge", "--ff-only", "origin/main")
                if fast.code:
                    payload["ff"] = "failed:ff-only"
                    return stop("ff-failed", "fast-forward failed; cleanup stopped")
                new = _git(runner, args.main_checkout, "rev-parse", "HEAD")
                if new.code:
                    payload["ff"] = "failed:new-head-unknown"
                    return stop("ff-failed", "new HEAD unknown; cleanup stopped")
                payload["ff"] = f"ff-only {old.text.strip()} -> {new.text.strip()}"

        if _cleanup_requested(args) and str(payload["ff"]).startswith("ff-only"):
            # Delete only after a real fast-forward. git branch -d is the final
            # safety check; a skipped or failed ff leaves the local branch alone.
            if _git(runner, args.main_checkout, "merge-base", "--is-ancestor", args.cleanup_branch, "origin/main").code:
                return stop("cleanup-stopped", "branch no longer reachable")
            deleted = _git(runner, args.main_checkout, "branch", "-d", args.cleanup_branch)
            if deleted.code:
                return stop("cleanup-stopped", "branch deletion failed: " + deleted.text.strip())
            payload["cleanup"] = "local-branch-deleted"
            remote = _git(runner, args.main_checkout, "ls-remote", "--heads", "origin", f"refs/heads/{args.cleanup_branch}")
            if remote.code:
                return stop("cleanup-stopped", "remote branch query failed")
            if not remote.text.strip():
                payload["cleanup"] = "already_deleted_on_origin"
            elif not args.delete_remote_branch:
                payload["cleanup"] = "remote-retained:not-authorized"
            else:
                removed = _git(runner, args.main_checkout, "push", "origin", "--delete", args.cleanup_branch)
                if removed.code:
                    return stop("cleanup-stopped", "remote deletion failed")
                payload["cleanup"] = "remote-deleted"
        payload["status"] = "merged" if payload["ff"].startswith("ff-only") else "merged-no-ff"
        _append_record(record_path, f"merge={merge_oid}\nff={payload['ff']}\ncleanup={payload['cleanup']}")
        _summary(payload, log_dir, args.pr)
        if str(payload["status"]).startswith("merged"):
            todo = _portfolio_todo_from_land(args, opened_info)
            if todo:
                print(todo)
        if payload["status"] == "merged" and not args.dry_run:
            _run_auto_cleanup(args, runner)
        return 0
    finally:
        fcntl.flock(lock_fd, fcntl.LOCK_UN)
        os.close(lock_fd)


def cmd_wait(args, runner) -> int:
    """KOS-PR-WAIT-CLEANUP-001: poll CI at a low frequency, print only on
    state changes, fail closed on any failure terminal or timeout."""
    clock = _wait_clock()
    log_dir = Path(args.log_dir) if args.log_dir else None
    payload = {
        "status": "stop",
        "pr": args.pr,
        "head": None,
        "reruns": 0,
        "merge_commit": None,
        "ff": None,
        "record": None,
        "cleanup": None,
    }
    view = runner.run(["gh", "pr", "view", args.pr, "--repo", args.repo, "--json", "state,headRefOid"])
    if view.code != 0:
        payload["status"] = "view-failed"
        _summary(payload, log_dir, args.pr)
        return _die(view.text.strip() or "gh pr view failed")
    info = json.loads(view.text)
    state, head = str(info.get("state", "")), str(info.get("headRefOid", ""))
    payload["head"] = head
    if state.upper() != "OPEN" or head != args.expect_head:
        payload["status"] = "not-open-or-head-mismatch"
        _summary(payload, log_dir, args.pr)
        return _die(f"stop: state={state} head={head} expect={args.expect_head}")

    flaky = _load_flaky(Path(args.known_flaky))
    deadline = clock.now + float(args.wait_timeout)
    last_sig = None
    attempt = 1
    while True:
        snapshot = runner.run(
            ["gh", "pr", "checks", args.pr, "--repo", args.repo, "--json", "name,state,bucket,link"]
        )
        rows = _snapshot_rows(snapshot.text) if snapshot.code == 0 else None
        if rows is None:
            payload.update(status="checks-failed-unparsed")
            _summary(payload, log_dir, args.pr)
            return _die("checks snapshot was not JSON")
        bad = _bad_states(rows)
        pending = _pending_states(rows)
        if pending:
            sig = tuple(sorted((r["name"], str(r["state"])) for r in pending))
            if sig != last_sig:
                clock.print(f"wait: pending {len(pending)}: " + ", ".join(sorted(r["name"] for r in pending)))
                last_sig = sig
            if clock.now >= deadline:
                payload.update(status="wait-timeout")
                _summary(payload, log_dir, args.pr)
                return _die(f"wait-timeout after {args.wait_timeout}s; still pending")
            clock.sleep(float(args.poll_interval))
            continue
        if bad:
            payload.update(status="ci-failed")
            _summary(payload, log_dir, args.pr)
            return _die("CI failed during wait; not merging")
        clock.print("wait: all checks pass")
        payload.update(status="green")
        _summary(payload, log_dir, args.pr)
        return 0


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="pr_flow.py")
    sub = parser.add_subparsers(dest="command", required=True)

    open_cmd = sub.add_parser("open")
    open_cmd.add_argument("--worktree", required=True)
    open_cmd.add_argument("--branch", required=True)
    open_cmd.add_argument("--base-sha", required=True)
    open_cmd.add_argument("--expect-head", required=True)
    open_cmd.add_argument("--files", required=True)
    open_cmd.add_argument("--title", required=True)
    open_cmd.add_argument("--body-file", required=True)
    open_cmd.add_argument("--identity", default=DEFAULT_IDENTITY)
    open_cmd.add_argument("--repo", default=DEFAULT_REPO)
    open_cmd.add_argument("--allow-untracked", action="append", default=[])
    open_cmd.add_argument("--log-dir")
    open_cmd.add_argument("--dry-run", action="store_true")

    land_cmd = sub.add_parser("land")
    land_cmd.add_argument("pr")
    land_cmd.add_argument("--expect-head", required=True)
    land_cmd.add_argument("--repo", default=DEFAULT_REPO)
    land_cmd.add_argument("--main-checkout", required=True)
    land_cmd.add_argument(
        "--known-flaky",
        default=str(Path(__file__).resolve().parent / "known-flaky.txt"),
    )
    land_cmd.add_argument("--pm-log", required=True)
    land_cmd.add_argument("--max-reruns", type=int, default=1)
    land_cmd.add_argument("--merge", action="store_true")
    land_cmd.add_argument("--validator")
    land_cmd.add_argument("--kos-as-of")
    land_cmd.add_argument("--dry-run", action="store_true")
    land_cmd.add_argument("--lock-timeout", type=float, default=30.0)
    land_cmd.add_argument("--task-id")
    land_cmd.add_argument(
        "--portfolio-refs",
        default="",
        help="Optional PF/PB/O ids to remind after a successful land (O84)",
    )
    land_cmd.add_argument(
        "--cleanup-tool",
        default="/Users/doubleshy0n/.kos-work/Universe-Keyboard/tools/kos-cleanup.sh",
    )
    land_cmd.add_argument("--lock-file")
    land_cmd.add_argument("--log-dir")
    land_cmd.add_argument("--cleanup-worktree")
    land_cmd.add_argument("--cleanup-branch")
    land_cmd.add_argument("--delete-remote-branch", action="store_true")
    land_cmd.add_argument(
        "--cleanup-allow-untracked",
        action="append",
        default=None,
    )

    wait_cmd = sub.add_parser("wait")
    wait_cmd.add_argument("pr")
    wait_cmd.add_argument("--expect-head", required=True)
    wait_cmd.add_argument("--repo", default=DEFAULT_REPO)
    wait_cmd.add_argument(
        "--known-flaky",
        default=str(Path(__file__).resolve().parent / "known-flaky.txt"),
    )
    wait_cmd.add_argument("--max-reruns", type=int, default=0)
    wait_cmd.add_argument("--wait-timeout", type=float, default=1800.0)
    wait_cmd.add_argument("--poll-interval", type=float, default=60.0)
    wait_cmd.add_argument("--pm-log", required=True)
    wait_cmd.add_argument("--log-dir")
    return parser


def main(argv: list[str] | None = None, runner=None) -> int:
    args = _parser().parse_args(argv)
    if getattr(args, "cleanup_allow_untracked", None) is None and args.command == "land":
        args.cleanup_allow_untracked = ["Packages/RimeBridge/Vendor"]
    runner = runner or SubprocessRunner()
    if args.command == "open":
        return cmd_open(args, runner)
    if args.command == "wait":
        return cmd_wait(args, runner)
    return cmd_land(args, runner)


if __name__ == "__main__":
    sys.exit(main())
