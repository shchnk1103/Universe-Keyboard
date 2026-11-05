#!/usr/bin/env python3
"""Push a branch and open a PR, or wait for CI and optionally merge it.

PM sessions must not run `open`, and must not run `land --merge`.
Merge only when a Human orders it or runs the command.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import tarfile
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


def _summary(payload: dict, log_dir: Path | None, pr: str) -> None:
    print(
        "status={status} pr={pr} head={head} reruns={reruns} merge={merge} ff={ff} record={record}".format(
            status=payload.get("status"),
            pr=payload.get("pr"),
            head=payload.get("head"),
            reruns=payload.get("reruns"),
            merge=payload.get("merge_commit"),
            ff=payload.get("ff"),
            record=payload.get("record"),
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
SNAPSHOT_BUCKETS = frozenset({"pass", "fail", "pending", "skipping", "cancel"})


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
                "state": bucket if isinstance(bucket, str) else "",
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
    return [row for row in rows if row["state"] == "pending"]


def _doc_paths(names: set[str]) -> bool:
    for name in names:
        for prefix in DOC_PREFIXES:
            if name == prefix or name.startswith(prefix):
                return True
    return False


def _warning_lines(text: str) -> set[str]:
    return {line for line in text.splitlines() if "WARNING" in line}


def cmd_open(args, runner) -> int:
    head = _git(runner, args.worktree, "rev-parse", "HEAD")
    if head.code != 0:
        return _die(head.text.strip() or "rev-parse failed")
    actual = head.text.strip()
    if actual != args.expect_head:
        return _die(f"HEAD {actual} != --expect-head {args.expect_head}")

    status = _git(runner, args.worktree, "status", "--porcelain")
    if status.code != 0:
        return _die(status.text.strip() or "status failed")
    dirty = _worktree_dirty(status.text, args.allow_untracked)
    if dirty:
        return _die(f"worktree not clean: {dirty}")

    ident = _git(
        runner,
        args.worktree,
        "log",
        "--format=AUTHOR:%an <%ae>%nCOMMITTER:%cn <%ce>",
        f"{args.base_sha}..HEAD",
    )
    if ident.code != 0:
        return _die(ident.text.strip() or "git log failed")
    bad_ident = _identity_errors(ident.text, args.identity)
    if bad_ident:
        return _die("identity mismatch: " + "; ".join(bad_ident))

    diff = _git(runner, args.worktree, "diff", "--name-only", args.base_sha, "HEAD")
    if diff.code != 0:
        return _die(diff.text.strip() or "diff failed")
    expected = _name_set(Path(args.files).read_text(encoding="utf-8"))
    actual_files = _name_set(diff.text)
    if actual_files != expected:
        return _die(f"file set mismatch: got {sorted(actual_files)} expected {sorted(expected)}")

    body = Path(args.body_file).read_text(encoding="utf-8")
    if _body_rejected(body):
        return _die("body contains Co-authored-by or Generated with")

    remote = _git(runner, args.worktree, "ls-remote", "--heads", "origin", args.branch)
    if remote.code != 0:
        return _die(remote.text.strip() or "ls-remote failed")
    if remote.text.strip():
        return _die(f"remote branch already exists: {remote.text.strip()}")

    if args.dry_run:
        print(f"dry-run ok branch={args.branch} head={actual}")
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
            return _die(again.text.strip() or "ls-remote failed after push")
        if again.text.strip():
            return _die("push failed and remote branch now exists; not retrying")
        pushed = runner.run(push_argv)
    if pushed.code != 0:
        return _die("push failed: " + pushed.text.strip())

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
        return _die("gh pr create failed: " + created.text.strip())
    print(created.text.strip())
    return 0


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
        tar.extractall(dest, filter="data")
    return Result(0, "", "")


def cmd_land(args, runner) -> int:
    log_dir = Path(args.log_dir) if args.log_dir else None
    view = runner.run(
        ["gh", "pr", "view", args.pr, "--repo", args.repo, "--json", "state,headRefOid"]
    )
    payload = {
        "status": "stop",
        "pr": args.pr,
        "head": None,
        "reruns": 0,
        "merge_commit": None,
        "ff": None,
        "record": None,
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
    state = str(info.get("state", ""))
    head = str(info.get("headRefOid", ""))
    payload["head"] = head
    if state.upper() != "OPEN" or head != args.expect_head:
        payload["status"] = "not-open-or-head-mismatch"
        _summary(payload, log_dir, args.pr)
        return _die(f"stop: state={state} head={head} expect={args.expect_head}")
    if args.dry_run:
        payload["status"] = "dry-run"
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

    branch = _git(runner, args.main_checkout, "rev-parse", "--abbrev-ref", "HEAD")
    porcelain = _git(runner, args.main_checkout, "status", "--porcelain")
    on_main = branch.code == 0 and branch.text.strip() == "main"
    clean = porcelain.code == 0 and porcelain.text.strip() == ""
    if not on_main or not clean:
        reason = f"skipped:branch={branch.text.strip()!r} clean={clean}; tell Human"
        payload.update(status="merged-no-ff", ff=reason)
        _append_record(record_path, f"merge={merge_oid}\nff={reason}")
        _summary(payload, log_dir, args.pr)
        return 0

    fetched = _git(runner, args.main_checkout, "fetch", "origin", "main")
    if fetched.code != 0:
        reason = f"failed:fetch {fetched.text.strip()}; tell Human"
        payload.update(status="ff-fetch-failed", ff=reason)
        _append_record(record_path, f"merge={merge_oid}\nff={reason}")
        _summary(payload, log_dir, args.pr)
        return _die("git fetch origin main failed")
    ancestor = _git(runner, args.main_checkout, "merge-base", "--is-ancestor", "HEAD", "origin/main")
    if ancestor.code == 1:
        reason = "skipped:HEAD is not an ancestor of origin/main; tell Human"
        payload.update(status="merged-no-ff", ff=reason)
        _append_record(record_path, f"merge={merge_oid}\nff={reason}")
        _summary(payload, log_dir, args.pr)
        return 0
    if ancestor.code != 0:
        reason = f"failed:ancestor check {ancestor.text.strip()}; tell Human"
        payload.update(status="ff-failed", ff=reason)
        _append_record(record_path, f"merge={merge_oid}\nff={reason}")
        _summary(payload, log_dir, args.pr)
        return _die("git merge-base failed")
    fast = _git(runner, args.main_checkout, "merge", "--ff-only", "origin/main")
    if fast.code != 0:
        reason = f"failed:merge {fast.text.strip()}; tell Human"
        payload.update(status="ff-failed", ff=reason)
        _append_record(record_path, f"merge={merge_oid}\nff={reason}")
        _summary(payload, log_dir, args.pr)
        return _die("git merge --ff-only failed")
    new_head = _git(runner, args.main_checkout, "rev-parse", "HEAD")
    ff_text = "ff-only " + new_head.text.strip()
    payload.update(status="merged", ff=ff_text)
    _append_record(record_path, f"merge={merge_oid}\n{ff_text}")
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
    land_cmd.add_argument("--log-dir")
    return parser


def main(argv: list[str] | None = None, runner=None) -> int:
    args = _parser().parse_args(argv)
    runner = runner or SubprocessRunner()
    if args.command == "open":
        return cmd_open(args, runner)
    return cmd_land(args, runner)


if __name__ == "__main__":
    sys.exit(main())
