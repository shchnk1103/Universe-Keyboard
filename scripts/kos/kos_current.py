#!/usr/bin/env python3
"""Atomic CURRENT.json (schema 2) state machine for KOS O41 minimal relay loop."""
import argparse
import datetime
import fcntl
import hashlib
import json
import os
import sys
import uuid


def _now_iso():
    return datetime.datetime.now().astimezone().isoformat(timespec="seconds")


def _sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(65536), b""):
            h.update(chunk)
    return h.hexdigest()


def _atomic_write_json(target_path, data):
    directory = os.path.dirname(os.path.abspath(target_path))
    tmp_path = os.path.join(directory, f"CURRENT.json.tmp.{os.getpid()}")
    payload = json.dumps(data, ensure_ascii=False, indent=2) + "\n"
    with open(tmp_path, "w", encoding="utf-8") as f:
        f.write(payload)
        f.flush()
        os.fsync(f.fileno())
    os.replace(tmp_path, target_path)


def _with_lock(task_dir, fn):
    os.makedirs(task_dir, exist_ok=True)
    lock_path = os.path.join(task_dir, ".CURRENT.lock")
    current_path = os.path.join(task_dir, "CURRENT.json")
    lock_fd = os.open(lock_path, os.O_CREAT | os.O_RDWR, 0o644)
    try:
        fcntl.flock(lock_fd, fcntl.LOCK_EX)
        current = None
        if os.path.isfile(current_path):
            with open(current_path, "r", encoding="utf-8") as f:
                current = json.load(f)
        return fn(current_path, current)
    finally:
        fcntl.flock(lock_fd, fcntl.LOCK_UN)
        os.close(lock_fd)


def cmd_dispatch(args):
    for label, p in (
        ("authorization_path", args.authorization_path),
        ("package_path", args.package_path),
        ("params_path", args.params_path),
    ):
        if not os.path.isfile(p):
            print(f"STOPPED: missing {label}: {p}", file=sys.stderr)
            return 2

    pkg_sha = _sha256(args.package_path)
    params_sha = _sha256(args.params_path)
    auth_sha = _sha256(args.authorization_path)

    def _op(current_path, current):
        if current is None:
            if args.expect_rev != 0:
                print(
                    f"CONFLICT: CURRENT.json absent, expect_rev={args.expect_rev} != 0",
                    file=sys.stderr,
                )
                return 3
            prev_entry = None
            prev_claim = None
        else:
            if current.get("revision") != args.expect_rev:
                print(
                    f"CONFLICT: revision={current.get('revision')} != expect_rev={args.expect_rev}",
                    file=sys.stderr,
                )
                return 3
            state = current.get("state")
            if state == "CLAIMED":
                if not args.claim_id or args.claim_id != current.get("claim_id"):
                    print(
                        "DENIED: state is CLAIMED and claim_id missing or mismatched",
                        file=sys.stderr,
                    )
                    return 4
            elif state not in ("COMPLETED", "UPGRADED_TO_PM", "READY_TO_DISPATCH"):
                print(f"DENIED: invalid source state {state}", file=sys.stderr)
                return 5
            prev_entry = {
                "package_path": current.get("package_path"),
                "package_sha256": current.get("package_sha256"),
                "superseded_at": _now_iso(),
            }
            prev_claim = current.get("prev_claim")

        new_data = {
            "schema": 2,
            "task_id": args.task_id,
            "revision": args.expect_rev + 1,
            "active_step": args.active_step,
            "role": args.role,
            "state": "READY_TO_DISPATCH",
            "claimed_by": None,
            "claim_id": None,
            "claimed_at": None,
            "resume_from_report": None,
            "package_path": os.path.realpath(args.package_path),
            "package_sha256": pkg_sha,
            "params_path": os.path.realpath(args.params_path),
            "params_sha256": params_sha,
            "authorization_path": os.path.realpath(args.authorization_path),
            "authorization_sha256": auth_sha,
            "prev_entry": prev_entry,
            "prev_claim": prev_claim,
            "updated_by": args.updated_by,
            "updated_at": _now_iso(),
        }
        _atomic_write_json(current_path, new_data)
        print(json.dumps(new_data, ensure_ascii=False))
        return 0

    return _with_lock(args.task_dir, _op)


def cmd_claim(args):
    def _op(current_path, current):
        if current is None:
            print("STOPPED: CURRENT.json does not exist", file=sys.stderr)
            return 2
        state = current.get("state")
        if state == "CLAIMED":
            print(
                f"STOPPED: already CLAIMED by {current.get('claimed_by')} at {current.get('claimed_at')}; "
                "direct takeover forbidden without PM --recover",
                file=sys.stderr,
            )
            return 5
        if state != "READY_TO_DISPATCH":
            print(f"STOPPED: cannot claim from state {state}", file=sys.stderr)
            return 5
        if current.get("role") != args.role:
            print(
                f"STOPPED: role mismatch (expected {current.get('role')}, got {args.role})",
                file=sys.stderr,
            )
            return 6
        if args.expect_rev is not None and current.get("revision") != args.expect_rev:
            print(
                f"CONFLICT: revision={current.get('revision')} != expect_rev={args.expect_rev}",
                file=sys.stderr,
            )
            return 3

        now = _now_iso()
        new_claim_id = uuid.uuid4().hex
        updated = dict(current)
        updated["revision"] = current["revision"] + 1
        updated["state"] = "CLAIMED"
        updated["claimed_by"] = args.claimed_by
        updated["claim_id"] = new_claim_id
        updated["claimed_at"] = now
        updated["updated_by"] = args.claimed_by
        updated["updated_at"] = now
        _atomic_write_json(current_path, updated)
        print(json.dumps(updated, ensure_ascii=False))
        return 0

    return _with_lock(args.task_dir, _op)


def _finish_claimed(args, target_state):
    def _op(current_path, current):
        if current is None:
            print("STOPPED: CURRENT.json does not exist", file=sys.stderr)
            return 2
        if current.get("state") != "CLAIMED":
            print(f"STOPPED: state is {current.get('state')}, not CLAIMED", file=sys.stderr)
            return 5
        if current.get("revision") != args.expect_rev:
            print(
                f"CONFLICT: revision={current.get('revision')} != expect_rev={args.expect_rev}",
                file=sys.stderr,
            )
            return 3
        if not args.claim_id or current.get("claim_id") != args.claim_id:
            print("DENIED: claim_id mismatch or revoked", file=sys.stderr)
            return 4

        updated = dict(current)
        updated["revision"] = current["revision"] + 1
        updated["state"] = target_state
        updated["claim_id"] = None
        updated["updated_by"] = args.updated_by
        updated["updated_at"] = _now_iso()
        if getattr(args, "reason", None):
            updated["upgrade_reason"] = args.reason
        _atomic_write_json(current_path, updated)
        print(json.dumps(updated, ensure_ascii=False))
        return 0

    return _with_lock(args.task_dir, _op)


def cmd_complete(args):
    return _finish_claimed(args, "COMPLETED")


def cmd_upgrade(args):
    return _finish_claimed(args, "UPGRADED_TO_PM")


def cmd_recover(args):
    if not args.recover:
        print("DENIED: --recover flag is required", file=sys.stderr)
        return 6
    if "Jack" not in args.updated_by:
        print("DENIED: only PM (Jack) may recover a CLAIMED entry", file=sys.stderr)
        return 6

    def _op(current_path, current):
        if current is None:
            print("STOPPED: CURRENT.json does not exist", file=sys.stderr)
            return 2
        if current.get("state") != "CLAIMED":
            print(f"STOPPED: recover requires state CLAIMED, got {current.get('state')}", file=sys.stderr)
            return 5
        if current.get("revision") != args.expect_rev:
            print(
                f"CONFLICT: revision={current.get('revision')} != expect_rev={args.expect_rev}",
                file=sys.stderr,
            )
            return 3

        now = _now_iso()
        updated = dict(current)
        updated["prev_claim"] = {
            "claimed_by": current.get("claimed_by"),
            "claim_id": current.get("claim_id"),
            "claimed_at": current.get("claimed_at"),
            "recovered_at": now,
            "recovered_by": args.updated_by,
            "reason": args.reason,
        }
        updated["revision"] = current["revision"] + 1
        updated["state"] = "READY_TO_DISPATCH"
        updated["claimed_by"] = None
        updated["claim_id"] = None
        updated["claimed_at"] = None
        updated["resume_from_report"] = args.resume_from_report
        updated["updated_by"] = args.updated_by
        updated["updated_at"] = now
        _atomic_write_json(current_path, updated)
        print(json.dumps(updated, ensure_ascii=False))
        return 0

    return _with_lock(args.task_dir, _op)


def cmd_verify(args):
    current_path = os.path.join(args.task_dir, "CURRENT.json")
    if not os.path.isfile(current_path):
        print(f"STOPPED: CURRENT.json not found in {args.task_dir}", file=sys.stderr)
        return 2
    with open(current_path, "r", encoding="utf-8") as f:
        current = json.load(f)

    if args.package_path:
        given = os.path.realpath(args.package_path)
        expected = os.path.realpath(current.get("package_path", ""))
        if given != expected:
            print(
                f"STOPPED: stale or mismatched entry {given}; current valid entry is {expected}",
                file=sys.stderr,
            )
            return 7

    state = current.get("state")
    if state != "READY_TO_DISPATCH":
        print(
            f"STOPPED: state is {state} (claimed_by={current.get('claimed_by')}), not READY_TO_DISPATCH",
            file=sys.stderr,
        )
        return 5

    if current.get("role") != args.role:
        print(
            f"STOPPED: role mismatch (expected {current.get('role')}, got {args.role})",
            file=sys.stderr,
        )
        return 6

    for path_key, sha_key in (
        ("package_path", "package_sha256"),
        ("params_path", "params_sha256"),
        ("authorization_path", "authorization_sha256"),
    ):
        p = current.get(path_key, "")
        if not os.path.isfile(p):
            print(f"STOPPED: missing {path_key}: {p}", file=sys.stderr)
            return 8
        actual = _sha256(p)
        if actual != current.get(sha_key):
            print(f"STOPPED: {sha_key} mismatch for {p}", file=sys.stderr)
            return 8

    print(json.dumps({"status": "OK", "task_id": current.get("task_id"), "revision": current.get("revision")}, ensure_ascii=False))
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(description="KOS O41 atomic CURRENT.json manager")
    sub = parser.add_subparsers(dest="cmd", required=True)

    p_disp = sub.add_parser("dispatch")
    p_disp.add_argument("--task-dir", required=True)
    p_disp.add_argument("--task-id", required=True)
    p_disp.add_argument("--active-step", required=True)
    p_disp.add_argument("--role", required=True)
    p_disp.add_argument("--package-path", required=True)
    p_disp.add_argument("--params-path", required=True)
    p_disp.add_argument("--authorization-path", required=True)
    p_disp.add_argument("--updated-by", required=True)
    p_disp.add_argument("--expect-rev", type=int, default=0)
    p_disp.add_argument("--claim-id", default=None)

    p_claim = sub.add_parser("claim")
    p_claim.add_argument("--task-dir", required=True)
    p_claim.add_argument("--role", required=True)
    p_claim.add_argument("--claimed-by", required=True)
    p_claim.add_argument("--expect-rev", type=int, default=None)

    p_comp = sub.add_parser("complete")
    p_comp.add_argument("--task-dir", required=True)
    p_comp.add_argument("--expect-rev", type=int, required=True)
    p_comp.add_argument("--claim-id", required=True)
    p_comp.add_argument("--updated-by", required=True)

    p_upg = sub.add_parser("upgrade")
    p_upg.add_argument("--task-dir", required=True)
    p_upg.add_argument("--expect-rev", type=int, required=True)
    p_upg.add_argument("--claim-id", required=True)
    p_upg.add_argument("--updated-by", required=True)
    p_upg.add_argument("--reason", default="")

    p_rec = sub.add_parser("recover")
    p_rec.add_argument("--task-dir", required=True)
    p_rec.add_argument("--expect-rev", type=int, required=True)
    p_rec.add_argument("--updated-by", required=True)
    p_rec.add_argument("--resume-from-report", required=True)
    p_rec.add_argument("--reason", default="")
    p_rec.add_argument("--recover", action="store_true")

    p_ver = sub.add_parser("verify")
    p_ver.add_argument("--task-dir", required=True)
    p_ver.add_argument("--role", required=True)
    p_ver.add_argument("--package-path", default=None)

    args = parser.parse_args(argv)
    dispatch_map = {
        "dispatch": cmd_dispatch,
        "claim": cmd_claim,
        "complete": cmd_complete,
        "upgrade": cmd_upgrade,
        "recover": cmd_recover,
        "verify": cmd_verify,
    }
    return dispatch_map[args.cmd](args)


if __name__ == "__main__":
    sys.exit(main())
