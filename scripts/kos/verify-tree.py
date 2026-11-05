#!/usr/bin/env python3
"""Verify a directory against a sha256 inventory ("<sha>  <relpath>" lines) or a zip's members.
Usage: python3 -I verify-tree.py DIR (--inventory FILE | --zip FILE)
Exit 0 only when file set and every sha256 match and there are no file or directory symlinks."""
import sys, os, hashlib, zipfile
def tree(d):
    out = {}
    for r, ds, fs in os.walk(d, followlinks=False):
        for dn in ds:
            if os.path.islink(os.path.join(r, dn)):
                out[os.path.relpath(os.path.join(r, dn), d) + "/"] = "LINK"
        for f in fs:
            p = os.path.join(r, f)
            out[os.path.relpath(p, d)] = "LINK" if os.path.islink(p) else hashlib.sha256(open(p, "rb").read()).hexdigest()
    return out
def main(argv=None):
    if argv is None:
        argv = sys.argv
    d, mode, src = argv[1], argv[2], argv[3]
    if mode == "--inventory":
        exp = {}
        for line in open(src, encoding="utf-8"):
            line = line.rstrip("\n")
            if line:
                h, _, p = line.partition("  "); exp[p.strip()] = h
    else:
        z = zipfile.ZipFile(src)
        exp = {n: hashlib.sha256(z.read(n)).hexdigest() for n in z.namelist() if not n.endswith("/")}
    act = tree(d)
    missing = sorted(set(exp) - set(act)); extra = sorted(set(act) - set(exp))
    diff = sorted(p for p in set(exp) & set(act) if exp[p] != act[p])
    print(f"expected={len(exp)} actual={len(act)} missing={len(missing)} extra={len(extra)} mismatch={len(diff)}")
    for name, lst in (("missing", missing), ("extra", extra), ("mismatch", diff)):
        for p in lst[:20]: print(f"{name}: {p}")
    sys.exit(0 if not (missing or extra or diff) else 1)

if __name__ == "__main__":
    main()
