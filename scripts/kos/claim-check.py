#!/usr/bin/env python3
"""claim-check: mechanical provenance check for fact-bearing docs changes.

Usage: python3 -I claim-check.py REPO BASE HEAD SOURCE [SOURCE ...]

1. Token check: every SHA (8+ hex), PR/issue number, PF/TD/ADR id, date, and
   number+unit token in ADDED lines must appear in at least one SOURCE
   (or in the BASE version of the changed file). Missing tokens are listed.
2. Lexicon check: added lines containing causal/definitive words are listed so a
   human reviewer can confirm the evidence class (proved / inferred / UNKNOWN /
   Human decision / Human statement / PM suggestion).
3. Table check: for each changed markdown table row, cell count is compared
   with the table header found above it.
It does NOT prove a claim true; it only catches unsupported tokens and
over-strong wording before a package or PR is sent for review.
"""
import re, subprocess, sys

def sh(*a):
    return subprocess.run(a, capture_output=True, text=True).stdout

def main():
    if len(sys.argv) < 5:
        print(__doc__); sys.exit(2)
    repo, base, head, *srcs = sys.argv[1:]
    diff = sh("git", "-C", repo, "diff", "--unified=0", base, head)
    added = [l[1:] for l in diff.split("\n") if l.startswith("+") and not l.startswith("+++")]
    files = [l for l in sh("git", "-C", repo, "diff", "--name-only", base, head).split("\n") if l]
    corpus = ""
    for p in srcs:
        try: corpus += open(p, encoding="utf-8", errors="ignore").read() + "\n"
        except OSError as e: print("WARN cannot read", p, e)
    for f in files:
        corpus += sh("git", "-C", repo, "show", f"{base}:{f}") + "\n"
    text = "\n".join(added)
    pats = {
      "hex": r"\b[0-9a-f]{8,64}\b",
      "pr": r"(?:PR\s*)?#\d{2,4}\b",
      "id": r"\b(?:PF|TD|ADR|UK|B)-?\d{1,4}\b",
      "date": r"\b20\d{2}-\d{2}-\d{2}\b",
      "numunit": r"\b\d[\d,\.]*\s?(?:个|行|项|次|条|轮|MB|GB|ms|文件|提交|列|pt)\b",
    }
    missing = {}
    for k, pat in pats.items():
        for m in sorted(set(re.findall(pat, text))):
            tok = m.strip()
            if k == "hex" and not re.search(r"[0-9]", tok): continue
            if tok not in corpus and re.sub(r"\s+", "", tok) not in re.sub(r"\s+", "", corpus):
                missing.setdefault(k, []).append(tok)
    print("== token check (tokens in added lines not found in any source) ==")
    if not missing: print("none")
    for k, v in missing.items(): print(k, len(v), v[:60])
    lex = ["导致", "原因是", "根因", "已证", "证明", "确认", "已修复", "修复", "决定", "批准", "保证", "一定", "必然"]
    print("\n== lexicon check (review evidence class) ==")
    n = 0
    for l in added:
        hit = [w for w in lex if w in l]
        if hit:
            n += 1; print(f"[{','.join(hit)}] {l[:200]}")
    if not n: print("none")
    print("\n== table check ==")
    bad = 0
    for f in files:
        if not f.endswith(".md"): continue
        body = sh("git", "-C", repo, "show", f"{head}:{f}").split("\n")
        header = None
        for l in body:
            if re.match(r"^\|[\s\-|:]+\|$", l): continue
            if l.startswith("|"):
                cells = len(l.strip().strip("|").split(" | "))
                if header is None: header = cells
                elif cells != header and l in added:
                    bad += 1; print(f"{f}: {cells} cells vs header {header}: {l[:100]}")
            else: header = None
    print("none" if not bad else f"{bad} problem rows")

main()
