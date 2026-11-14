#!/usr/bin/env python3
"""Mechanically check a KOS report: cited hashes, logs, commits, skips."""
import argparse, hashlib, os, re, subprocess, time

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
    for base in filter(None, [task, os.path.join(task, "reports"), wt]):
        q = os.path.join(base, p)
        if os.path.exists(q):
            return q
    return os.path.join(task, p)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("report"); ap.add_argument("--worktree"); ap.add_argument("--base")
    a = ap.parse_args()
    task = os.path.dirname(os.path.dirname(os.path.abspath(a.report)))
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
        for m in re.finditer(r"`([^`]+\.[A-Za-z0-9]+)`[^`\n]{0,40}?`?([0-9a-f]{64})`?", line):
            p, h = m.group(1), m.group(2)
            if (p, h) in seen: continue
            seen.add((p, h))
            q = resolve(p, task, a.worktree)
            if not os.path.isfile(q):
                print("MISSING ", p)
            else:
                print("OK      " if sha(q) == h else "MISMATCH", p)
    print("\n== logs")
    for p in sorted(set(re.findall(r"[`\s(]((?:/|scratch/)[^`\s)]+\.log)", text))):
        q = resolve(p, task, a.worktree)
        if not os.path.isfile(q):
            print("MISSING ", p); continue
        with open(q, encoding="utf-8", errors="replace") as f:
            body = f.read().splitlines()
        top = "\n".join(body[:8]); tail = "\n".join(body[-5:])
        exitc = re.findall(r"EXIT:\s*(\d+)", tail); lh = re.findall(r"HEAD:\s*([0-9a-f]{40})", tail)
        flags = []
        if "COMMAND" not in top and "xcodebuild" not in top and "swift" not in top: flags.append("no-command-header")
        if not exitc: flags.append("no-EXIT")
        if head and lh and lh[-1] != head: flags.append("HEAD!=worktree")
        print(f"{'OK      ' if not flags else 'CHECK   '} {p} EXIT={exitc[-1] if exitc else '?'} HEAD={lh[-1][:8] if lh else '?'} {' '.join(flags)}")
    if a.worktree:
        print("\n== worktree")
        print("HEAD", head, "tree", git(a.worktree, "rev-parse", "HEAD^{tree}"))
        print("status:\n" + (git(a.worktree, "status", "--porcelain") or "(clean)"))
        if a.base:
            for l in git(a.worktree, "log", "--format=%h|%an <%ae>|%cn <%ce>|%(trailers:key=Co-authored-by,valueonly)|%s", f"{a.base}..HEAD").splitlines():
                print(" ", l)
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
    print("\n== skip mentions")
    for line in lines:
        if re.search(r"skip|跳过|XCTSkip", line, re.I):
            print(" ", line.strip()[:200])

if __name__ == "__main__":
    main()
