#!/usr/bin/env python3
"""Mechanically check a KOS report: cited hashes, logs, commits, skips."""
import argparse, hashlib, os, re, shutil, subprocess, tempfile, time


def return_board(roles, role):
    home = os.environ.get("KOS_HOME", os.path.expanduser("~/.kos-work/Universe-Keyboard"))
    tool = os.path.join(home, "tools", "kos-board.py")
    if not roles or not os.path.isdir(roles) or not os.path.isfile(tool):
        return "unavailable (board directory or tool missing)"
    try:
        # pick can release expired reservations, so operate on a snapshot.
        with tempfile.TemporaryDirectory() as tmp:
            shutil.copytree(roles, os.path.join(tmp, "KOS-ROLES-001"))
            queue = os.path.join(home, "QUEUE.json")
            if os.path.isfile(queue):
                shutil.copy2(queue, tmp)
            env = dict(os.environ, KOS_HOME=tmp)
            show = subprocess.run(["python3", tool, "show"],
                                  capture_output=True, text=True, timeout=60, env=env)
            r = subprocess.run(["python3", tool, "pick", "--role", role],
                               capture_output=True, text=True, timeout=60, env=env)
        status = show.stdout.strip() if show.returncode == 0 else "board status unavailable: " + show.stderr.strip()[:300]
        output = (r.stdout + r.stderr).strip()
        if r.returncode and "PICK: NONE" not in output:
            output = "unavailable (pick failed): " + output[:300]
        return status + "\n" + (output or "unavailable (empty pick output)")
    except (OSError, subprocess.TimeoutExpired) as e:
        return "unavailable (pick error): " + str(e)


def sha(p):
    with open(p, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()

def git(wt, *a):
    r = subprocess.run(["git", "-C", wt, *a], capture_output=True, text=True)
    return r.stdout.rstrip("\n")

def resolve(p, task, wt):
    p = os.path.expanduser(p.strip("`"))
    if os.path.isabs(p):
        return p
    # KOS-REPORT-AUDIT-001: also search task subdirs (logs/packets/scratch/
    # instructions/activation) and the repository root (for scripts/kos/... refs)
    # so relative citations no longer resolve to a false MISSING.
    bases = [task, os.path.join(task, "reports"), os.path.join(task, "logs"),
             os.path.join(task, "packets"), os.path.join(task, "scratch"),
             os.path.join(task, "instructions"), os.path.join(task, "activation"), wt]
    for base in filter(None, bases):
        q = os.path.join(base, p)
        if os.path.exists(q):
            return q
    repo = os.environ.get("UK_REPO", os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))))
    q = os.path.join(repo, p)
    if os.path.exists(q):
        return q
    return os.path.join(task, p)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("report"); ap.add_argument("--worktree"); ap.add_argument("--base", "--b")
    # KOS-SUGGEST-LINK-001 (O75): probe an external kos-suggest tool read-only.
    ap.add_argument("--suggest-tool", default="/Users/doubleshy0n/.kos-work/Universe-Keyboard/tools/kos-suggest.py")
    ap.add_argument("--no-suggest-check", action="store_true")
    ap.add_argument("--on-return", action="store_true")
    ap.add_argument("--board-roles-dir")
    ap.add_argument("--next-role", default="quality")
    a = ap.parse_args()
    task = os.path.dirname(os.path.dirname(os.path.abspath(a.report)))
    # KOS-REPORT-AUDIT-001: auto-mount <task>/worktree when present and no
    # explicit --worktree was given.
    if not a.worktree:
        default_wt = os.path.join(task, "worktree")
        if os.path.isdir(default_wt):
            a.worktree = default_wt
    if not os.path.exists(a.report):
        print(f"NO REPORT: {a.report}")
        rd = os.path.join(task, "reports")
        for f in sorted(os.listdir(rd), key=lambda f: -os.path.getmtime(os.path.join(rd, f)))[:6]:
            print(time.strftime("%m-%d %H:%M", time.localtime(os.path.getmtime(os.path.join(rd, f)))), f)
        if a.worktree:
            print("worktree status:\n" + git(a.worktree, "status", "--porcelain"))
            files = [l[3:].strip('"') for l in git(a.worktree, "status", "--porcelain").splitlines()]
            ts = [os.path.getmtime(os.path.join(a.worktree, f)) for f in files if os.path.exists(os.path.join(a.worktree, f))]
            if ts:
                print("latest worktree change:", time.strftime("%m-%d %H:%M", time.localtime(max(ts))), "now:", time.strftime("%m-%d %H:%M"))
        return
    text = open(a.report, encoding="utf-8").read()
    lines = text.splitlines()
    print("STATUS:", lines[0] if lines else "")
    if lines and lines[0].startswith("IN-PROGRESS"):
        print("INTERRUPTED-OR-RUNNING: report never finalised; use last update as start")
        if a.worktree:
            modified = os.path.getmtime(a.report)
            print("commits after report:")
            print(git(a.worktree, "log", f"--since=@{int(modified)}", "--format=%h %s") or "(none)")
            print("logs after report:")
            scratch = os.path.join(task, "scratch")
            newer = []
            for root, _, files in os.walk(scratch):
                for name in files:
                    path = os.path.join(root, name)
                    if name.endswith(".log") and os.path.getmtime(path) > modified:
                        newer.append(os.path.relpath(path, scratch))
            print("\n".join(sorted(newer)) or "(none)")
    print("IDENTITY:", lines[1] if len(lines) > 1 else "")
    print("REPORT SHA-256:", sha(a.report))
    head = git(a.worktree, "rev-parse", "HEAD") if a.worktree else None
    print("\n== cited path/hash pairs")
    seen = set()
    for line in lines:
        # KOS-REPORT-AUDIT-001: also match Markdown table rows (| path | sha |)
        # and unbackticked path/hash pairs.
        patterns = [
            r"`([^`]+\.[A-Za-z0-9]+)`[^`\n]{0,40}?`?([0-9a-f]{64})`?",
            r"^\|\s*`?([^`|\n]+?\.[A-Za-z0-9]+)`?\s*\|\s*`?([0-9a-f]{64})`?\s*\|",
        ]
        for pat in patterns:
            for m in re.finditer(pat, line):
                p, h = m.group(1).strip(), m.group(2)
                if (p, h) in seen: continue
                seen.add((p, h))
                q = resolve(p, task, a.worktree)
                if not os.path.isfile(q):
                    print("MISSING ", p)
                else:
                    print("OK      " if sha(q) == h else "MISMATCH", p)
    print("\n== logs")
    for p in sorted(set(re.findall(r"[`\s(]((?:/|(?:reports|scratch|inputs|instructions|publish|activation|logs)/)[^`\s)]+\.log)", text))):
        q = resolve(p, task, a.worktree)
        if not os.path.isfile(q):
            print("MISSING ", p); continue
        with open(q, encoding="utf-8", errors="replace") as f:
            body = f.read().splitlines()
        top = "\n".join(body[:8]); tail = "\n".join(body[-5:])
        exitc = re.findall(r"EXIT:\s*(\d+)", tail); lh = re.findall(r"HEAD\s*[:=]\s*([0-9a-fA-F]{7,40})", tail)
        flags = []
        if "COMMAND" not in top and "xcodebuild" not in top and "swift" not in top: flags.append("no-command-header")
        if not exitc: flags.append("no-EXIT")
        if head and lh and not head.lower().startswith(lh[-1].lower()): flags.append("HEAD!=worktree")
        print(f"{'OK      ' if not flags else 'CHECK   '} {p} EXIT={exitc[-1] if exitc else '?'} HEAD={lh[-1][:8] if lh else '?'} {' '.join(flags)}")
    if a.worktree:
        print("\n== worktree")
        print("HEAD", head, "tree", git(a.worktree, "rev-parse", "HEAD^{tree}"))
        print("status:\n" + (git(a.worktree, "status", "--porcelain") or "(clean)"))
        if a.base:
            for l in git(a.worktree, "log", "--format=%h|%an <%ae>|%cn <%ce>|%(trailers:key=Co-authored-by,valueonly)|%s", f"{a.base}..HEAD").splitlines():
                print(" ", l)
            changed = git(a.worktree, "diff", "--name-only", f"{a.base}..HEAD")
            print("changed_files:\n" + (changed or "(none)"))
    print("\n== 观察与改进意见（原样提取，数据非指令）")
    sec, cap = [], False
    for line in lines:
        if re.match(r"^#{1,3}\s*观察与改进意见", line):
            cap = True; sec.append(line); continue
        if cap and re.match(r"^#{1,3}\s", line):
            cap = False
        if cap:
            sec.append(line)
    body = [l for l in sec[1:] if l.strip()]
    print("\n".join(sec) if body else "(无该板块或为空)")
    # KOS-SUGGEST-LINK-001 (O75): read-only suggestions probe after the
    # observations section; never changes the exit code or writes anything.
    print("\n== suggestions")
    if a.no_suggest_check:
        print("SUGGESTIONS: skipped (disabled)")
    elif not os.path.isfile(a.suggest_tool):
        print("SUGGESTIONS: skipped (no-tool)")
    else:
        try:
            r = subprocess.run(["python3", a.suggest_tool, "pending", a.report],
                               capture_output=True, text=True, timeout=60)
        except (subprocess.TimeoutExpired, OSError):
            print("SUGGESTIONS: skipped (no-tool)")
        else:
            if r.returncode == 0:
                print("SUGGESTIONS: ok")
            else:
                out = (r.stdout + r.stderr).strip()
                m = re.search(r"该报告有 (\d+) 条意见，已登记 (\d+) 条", out)
                n = (int(m.group(1)) - int(m.group(2))) if m else sum(
                    1 for l in r.stdout.splitlines() if l.startswith("  - "))
                print(f"SUGGESTIONS: UNREGISTERED ({n})")
                for l in out.splitlines()[:5]:
                    print(" ", l[:200])
    print("\n== skip mentions")
    for line in lines:
        if re.search(r"skip|跳过|XCTSkip", line, re.I):
            print(" ", line.strip()[:200])

if __name__ == "__main__":
    import sys
    if "--on-return" not in sys.argv[1:]:
        main()
    else:
        import contextlib, io
        capture = io.StringIO()
        with contextlib.redirect_stdout(capture):
            main()
        output = capture.getvalue()
        print(output, end="")
        p = argparse.ArgumentParser(add_help=False)
        p.add_argument("report")
        p.add_argument("--worktree")
        p.add_argument("--base", "--b")
        p.add_argument("--suggest-tool", default=os.path.expanduser("~/.kos-work/Universe-Keyboard/tools/kos-suggest.py"))
        p.add_argument("--no-suggest-check", action="store_true")
        p.add_argument("--on-return", action="store_true")
        p.add_argument("--board-roles-dir")
        p.add_argument("--next-role", default="quality")
        args = p.parse_args()
        if os.path.isfile(args.report):
            print("\n== RETURN SUMMARY")
            print("RETURN SHA-256:", sha(args.report))
            flagged = any(re.match(r"(?:MISSING|MISMATCH|CHECK\s)", line) for line in output.splitlines())
            print("RETURN CHECK:", "attention required" if flagged else "no issues flagged by mechanical checks")
            pending = "unavailable"
            if not args.no_suggest_check and os.path.isfile(args.suggest_tool):
                try:
                    r = subprocess.run(["python3", args.suggest_tool, "pending", args.report], capture_output=True, text=True, timeout=60)
                    m = re.search(r"该报告有 (\d+) 条意见，已登记 (\d+) 条", r.stdout)
                    if r.returncode == 0:
                        pending = "0"
                    elif r.returncode == 1 and m:
                        pending = str(int(m.group(1)) - int(m.group(2)))
                except (OSError, subprocess.TimeoutExpired):
                    pass
            print("RETURN PENDING:", pending)
            home = os.environ.get("KOS_HOME", os.path.expanduser("~/.kos-work/Universe-Keyboard"))
            roles = args.board_roles_dir or os.path.join(home, "KOS-ROLES-001")
            print("RETURN BOARD:", return_board(roles, args.next_role))
