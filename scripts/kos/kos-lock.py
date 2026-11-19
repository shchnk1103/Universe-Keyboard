#!/usr/bin/env python3
"""Physical resource locks for sim and main (KOS O54 companion).

RESOURCES.json records holders only. QUEUE.json and BOARD.md stay separate.
All writes take an exclusive flock and replace the file atomically.
"""
import argparse
import fcntl
import json
import os
import sys
import time

RESOURCES = ("main", "sim")
STALE_SECONDS = 6 * 60 * 60


def queue_root():
    explicit = os.environ.get("KOS_QUEUE_ROOT")
    if explicit:
        return explicit
    home = os.environ.get("KOS_HOME", os.path.expanduser("~/.kos-work"))
    return os.path.join(home, os.environ.get("KOS_PROJECT", "Universe-Keyboard"))


ROOT = queue_root()
DATA = os.path.join(ROOT, "RESOURCES.json")
LOCK = DATA + ".lock"
LOG = os.path.join(ROOT, "QUEUE-LOG.md")


def die(msg, code):
    print(msg, file=sys.stderr)
    sys.exit(code)


def empty_db():
    return {"schema": 1, "resources": {name: None for name in RESOURCES}}


def parse_since(value):
    try:
        return time.mktime(time.strptime(value, "%Y-%m-%dT%H:%M:%SZ"))
    except (TypeError, ValueError):
        return None


def pid_alive(pid):
    try:
        os.kill(int(pid), 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    except (OSError, TypeError, ValueError):
        return False
    return True


def suspect(record):
    if not isinstance(record, dict):
        return False
    if not pid_alive(record.get("pid")):
        return True
    since = parse_since(record.get("since"))
    return since is None or time.time() - since > STALE_SECONDS


def normalize(names):
    ordered = list(dict.fromkeys(names))
    if any(name not in RESOURCES for name in ordered):
        die("资源名非法：只允许 sim 或 main", 2)
    return tuple(sorted(ordered))


def load(handle):
    handle.seek(0)
    raw = handle.read()
    if not raw.strip():
        return empty_db()
    try:
        db = json.loads(raw)
    except json.JSONDecodeError:
        die("RESOURCES.json 损坏", 1)
    if not isinstance(db, dict) or not isinstance(db.get("resources"), dict):
        die("RESOURCES.json 损坏", 1)
    for name in RESOURCES:
        db["resources"].setdefault(name, None)
    return db


def store_direct(db):
    os.makedirs(ROOT, exist_ok=True)
    tmp = DATA + ".tmp"
    with open(tmp, "w", encoding="utf-8") as out:
        json.dump(db, out, ensure_ascii=False, indent=1)
        out.write("\n")
    os.replace(tmp, DATA)


def locked(mutator):
    os.makedirs(ROOT, exist_ok=True)
    with open(LOCK, "a+", encoding="utf-8") as lock:
        fcntl.flock(lock.fileno(), fcntl.LOCK_EX)
        try:
            if os.path.exists(DATA):
                with open(DATA, encoding="utf-8") as handle:
                    db = load(handle)
            else:
                db = empty_db()
            return mutator(db)
        finally:
            fcntl.flock(lock.fileno(), fcntl.LOCK_UN)


def holder(record):
    return f'{record["task"]} session={record.get("session", "")} pid={record.get("pid", "")} since={record.get("since", "")}'


def acquire(db, names, args):
    targets = normalize(names)
    now = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    for name in targets:
        current = db["resources"].get(name)
        if current and current.get("task") != args.task:
            die(f"已被占用：{name} {holder(current)}", 4)
    changed = False
    for name in targets:
        current = db["resources"].get(name)
        if current and current.get("task") == args.task:
            print(f"已持有：{name} {holder(current)}")
            continue
        db["resources"][name] = {
            "task": args.task, "session": args.session, "pid": args.pid or os.getpid(),
            "since": now, "note": args.note or ""}
        changed = True
        print(f"持有：{name} {holder(db['resources'][name])}")
    if changed:
        store_direct(db)
    return 0


def store_direct(db):
    os.makedirs(ROOT, exist_ok=True)
    tmp = DATA + ".tmp"
    with open(tmp, "w", encoding="utf-8") as out:
        json.dump(db, out, ensure_ascii=False, indent=1)
        out.write("\n")
    os.replace(tmp, DATA)


def release(db, name, task):
    normalize([name])
    current = db["resources"].get(name)
    if not current or current.get("task") != task:
        die(f"不是持有者：{name}", 5)
    db["resources"][name] = None
    store_direct(db)
    print(f"已释放：{name}")
    return 0


def status(db):
    for name in RESOURCES:
        current = db["resources"].get(name)
        if not current:
            print(f"{name}: 空")
        else:
            mark = " SUSPECT" if suspect(current) else ""
            print(f"{name}: {holder(current)}{mark}")
    return 0


def force_release(db, name, why):
    normalize([name])
    if not why:
        die("force-release 需要 --why", 1)
    db["resources"][name] = None
    store_direct(db)
    with open(LOG, "a", encoding="utf-8") as log:
        log.write(f'- {time.strftime("%Y-%m-%d %H:%M")} force-release {name}: {why}\n')
    print(f"强制释放：{name}")
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="cmd", required=True)
    acquire_cmd = commands.add_parser("acquire")
    acquire_cmd.add_argument("resources", nargs="+")
    acquire_cmd.add_argument("--task", required=True)
    acquire_cmd.add_argument("--session", required=True)
    acquire_cmd.add_argument("--note", default="")
    acquire_cmd.add_argument("--pid", type=int)
    release_cmd = commands.add_parser("release")
    release_cmd.add_argument("resource")
    release_cmd.add_argument("--task", required=True)
    commands.add_parser("status")
    force = commands.add_parser("force-release")
    force.add_argument("resource")
    force.add_argument("--why", default="")
    args = parser.parse_args()

    def act(db):
        if args.cmd == "acquire":
            return acquire(db, args.resources, args)
        if args.cmd == "release":
            return release(db, args.resource, args.task)
        if args.cmd == "status":
            return status(db)
        return force_release(db, args.resource, args.why)

    try:
        sys.exit(locked(act))
    except FileNotFoundError as exc:
        die(str(exc), 1)


if __name__ == "__main__":
    main()
