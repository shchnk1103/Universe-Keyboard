#!/usr/bin/env python3
"""Freeze a KOS task package draft: resolve placeholders, lint standard clauses, print SHA + dispatch block."""
import argparse, hashlib, os, re, subprocess, sys

VERIFY = os.path.join(os.path.dirname(os.path.abspath(__file__)), "verify-tree.py")

def sha(path):
    with open(path, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()

def verify(directory, mode, ref):
    r = subprocess.run([sys.executable, "-I", VERIFY, directory, mode, ref], capture_output=True, text=True)
    if r.returncode != 0:
        raise SystemExit(f"verify failed for {directory} against {ref}:\n{r.stdout}{r.stderr}")
    return sha(ref)

def git(wt, *args):
    return subprocess.run(["git", "-C", wt, *args], capture_output=True, text=True, check=True).stdout.strip()

def resolve(m):
    kind, arg = m.group(1), m.group(2)
    if kind == "sha":
        return sha(arg)
    if kind in ("verify-zip", "verify-inv"):
        d, ref = arg.split("|", 1)
        return verify(d, "--zip" if kind == "verify-zip" else "--inventory", ref)
    if kind == "git-head":
        return git(arg, "rev-parse", "HEAD")
    if kind == "git-tree":
        return git(arg, "rev-parse", "HEAD^{tree}")
    raise SystemExit(f"unknown placeholder {kind}")

REQUIRED = [
    ("role line", r"\*\*你的角色："),
    ("not PM", r"你不是 PM"),
    ("one-sentence final message", r"最终消息只写一句话"),
    ("write denial stop", r"写入被拒"),
    ("no /tmp", r"/tmp"),
    ("authorization receipt", r"授权(原文|消息原文)另存"),
    ("report path", r"reports/[^`\s]+\.md"),
]

def _without_limited_network(text):
    """Drop sentences that only allow a bounded read-only gh, so they are not a network pre-approval."""
    kept = []
    for part in re.split(r"([。\n])", text):
        if part in ("。", "\n") or not re.search(r"联网只限[^。\n]*只读\s*`gh`", part):
            kept.append(part)
    return "".join(kept)

def build_tools_negated(text):
    """Explicit denial: do not run builds/tests, or do not start a device."""
    return bool(
        re.search(r"不运行[^。\n]*构建与测试", text)
        or re.search(r"不启动[^。\n]*设备", text)
    )

def has_swift_path(text):
    """A path ending in .swift. Bare `.swift` and `.swift-format` do not count."""
    return bool(re.search(r"[A-Za-z0-9_][\w./-]*\.swift(?!-)", text))

def has_assignment_clause(text):
    """docs/assignments/<name>.md, or the same sentence gives a non-empty reason after 无 Assignment.
    docs/ASSIGNMENT_POLICY.md alone does not count."""
    if re.search(r"docs/assignments/[A-Za-z0-9_./-]+\.md", text):
        return True
    for sentence in re.split(r"[。\n]", text):
        mark = "无 Assignment"
        i = sentence.find(mark)
        if i < 0:
            continue
        reason = sentence[i + len(mark):].strip(" \t：:，,；;（()）")
        if reason:
            return True
    return False

def consistency(text, readonly=False):
    """Cross-clause checks for the contradiction types seen in preflight FAILs (2026-11)."""
    errs = []
    sentences = [x for x in re.split(r"[。\n]", text) if x.strip()]
    # 1. frozen input with a bare filename (no absolute path) followed by a hash
    dir_stated = re.search(r"均位于 `/", text)
    for m in ([] if dir_stated else re.finditer(r"`([^`/\s]+\.[A-Za-z0-9]+)`\s*`[0-9a-f]{64}`", text)):
        errs.append(f"frozen input without absolute path: {m.group(1)}")
    # 2. test ban vs mandatory lightweight script
    bans = re.search(r"(不运行|禁止)[^。\n]*(测试|构建)", text)
    if bans and "run_lightweight_checks" in text and not re.search(r"允许[^。\n]*轻量检查", text):
        errs.append("bans tests/builds but requires run_lightweight_checks without saying it is allowed")
    # 3. stop vs PARTIAL in the same sentence
    for x in sentences:
        if "停止" in x and "PARTIAL" in x and "STOPPED" not in x and "BLOCKED" not in x:
            errs.append("stop vs PARTIAL in one sentence: " + x.strip()[:60])
    # 4. exact file-count vs PARTIAL
    if "DONE =" in text and re.search(r"恰为[^。\n]{0,20}(个|文件)", text) and "PARTIAL" in text and "子集" not in text:
        errs.append("'恰为N个文件' with PARTIAL allowed but no subset rule")
    # 5. network wording. "联网只限……只读 `gh`" is a limit, not a conflicting pre-approval.
    net_scope = _without_limited_network(text)
    if re.search(r"不联网", text) and re.search(r"只读联网|联网（", net_scope):
        errs.append("both '不联网' and a network pre-approval")
    if re.search(r"\bHEAD\b[^\n]*(状态码|HTTP|GET)", text) and "仅 GET" not in text and "GET" in text:
        errs.append("mixes HEAD and GET network methods")
    # 6. builds present but writes limited to listed dirs, with no statement about external tool writes.
    # --readonly or “不运行……构建” is not a build this package will run (ledger line 22).
    build_exempt = (
        readonly
        or re.search(r"不运行[^。\n]*(xcodebuild|swift build)", text)
        or re.search(r"不运行[^。\n]*构建", text)
    )
    if re.search(r"xcodebuild|swift build|swift test", text) and not build_exempt:
        if "只写" in text and not re.search(r"derivedDataPath|--scratch-path", text):
            errs.append("builds mentioned with a 'write only' scope but no build output location")
    # 7. report referenced as input but not in the frozen inputs list
    for m in re.finditer(r"(?:引用|采纳)[^。\n]*`(/[^`]+\.md)`", text):
        path = m.group(1)
        if not re.search(re.escape(path) + r"`\s*`?[0-9a-f]{64}", text) and not re.search(re.escape(path) + r"[^\n]{0,30}SHA-256", text):
            errs.append("referenced report without hash: " + path)
    return errs

def lint_problems(text, requires_commit=False, readonly=False):
    problems = [name for name, pat in REQUIRED if not re.search(pat, text)]
    if requires_commit and "Cowork 3P <cowork-3p@localhost>" not in text:
        problems.append("commit identity with email")
    # Docs-only packages have no .swift path, so --requires-commit does not force swift-format.
    if requires_commit and has_swift_path(text) and "lint --strict" not in text:
        problems.append("swift-format lint gate")
    # Tool names in an explicit denial are not a build this package runs.
    if not readonly and not build_tools_negated(text) and re.search(r"xcodebuild|swift test|模拟器", text):
        for name, pat in [("build output location", r"scratch-path|derivedDataPath|DerivedData"), ("skip wording", r"自行跳过")]:
            if not re.search(pat, text):
                problems.append(name)
    problems += ["CONSISTENCY: " + e for e in consistency(text, readonly=readonly)]
    if requires_commit and not has_assignment_clause(text):
        problems.append("CONSISTENCY: missing Assignment path or reasoned 无 Assignment")
    return problems

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("draft"); ap.add_argument("out")
    ap.add_argument("--title", required=True); ap.add_argument("--role", required=True)
    ap.add_argument("--forbid", nargs="*", default=[])
    ap.add_argument("--requires-commit", action="store_true")
    ap.add_argument("--readonly", action="store_true")
    a = ap.parse_args()
    if os.path.exists(a.out):
        raise SystemExit(f"EXISTS: {a.out} — write a revision package instead of overwriting")
    text = open(a.draft, encoding="utf-8").read()
    text = re.sub(r"\{\{(sha|verify-zip|verify-inv|git-head|git-tree):([^}]+)\}\}", resolve, text)
    left = re.findall(r"\{\{[^}]*\}\}", text)
    if left:
        raise SystemExit(f"unresolved placeholders: {left}")
    problems = lint_problems(text, requires_commit=a.requires_commit, readonly=a.readonly)
    for s in a.forbid:
        if s in text:
            problems.append(f"forbidden leftover: {s}")
    if problems:
        raise SystemExit("lint failed: " + "; ".join(problems))
    with open(a.out, "x", encoding="utf-8") as f:
        f.write(text)
    h = sha(a.out)
    print(h)
    print("\n```text\n" + a.title + "\n角色：" + a.role + "\n包：" + a.out.replace(os.path.expanduser("~"), "~") + "\nSHA-256：" + h + "\n授权，直接执行\n```")

if __name__ == "__main__":
    main()
