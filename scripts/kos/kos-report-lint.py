#!/usr/bin/env python3
"""kos-report-lint.py <报告.md> [--max-bytes 12288] [--warn-bytes 8192] [--rep-lines 20]
机械检查"摘要报告"是否合规（O16）：大小、首行状态、机器输出整段内嵌、引用的日志路径+SHA 是否实测一致。
退出码：0 合规；1 有问题（逐条打印）。只读。"""
import sys, re, hashlib, os, collections
args = sys.argv[1:]
def opt(n, d):
    return int(args[args.index(n)+1]) if n in args else d
path = args[0]
mx, wn, rep = opt('--max-bytes', 12288), opt('--warn-bytes', 8192), opt('--rep-lines', 20)
raw = open(path, 'rb').read(); txt = raw.decode('utf-8', 'replace'); lines = txt.splitlines()
bad = []
if len(raw) > mx: bad.append(f"报告 {len(raw)} 字节，超过上限 {mx}：把机器输出移到日志/附录文件，只在摘要里写路径、SHA-256、计数")
elif len(raw) > wn: print(f"提示：报告 {len(raw)} 字节，接近上限 {mx}")
if not lines or lines[0].strip() not in ('DONE','PARTIAL','BLOCKED','STOPPED','PASS','CHANGES_REQUESTED','FAIL','APPROVE','CONDITIONAL'):
    bad.append("第一行不是状态词")
pre = collections.Counter()
for l in lines:
    m = re.match(r'^([A-Z][A-Z0-9_]{5,})\b', l)
    if m: pre[m.group(1)] += 1
for k, v in pre.items():
    if v > rep: bad.append(f"以 {k} 开头的行出现 {v} 次（>{rep}）：疑似整段内嵌机器输出，应改为引用日志文件")
for m in re.finditer(r'(/[^\s`（）()]+?\.(?:log|txt|md|json|patch))[^\n]{0,40}?(?:SHA-256[ ：:]*`?|`)([0-9a-f]{64})', txt):
    p, h = m.group(1), m.group(2)
    if os.path.isfile(p):
        a = hashlib.sha256(open(p,'rb').read()).hexdigest()
        if a != h: bad.append(f"引用文件 SHA 与实测不符：{p}")
print("\n".join(("问题：" + b) for b in bad) if bad else "OK")
sys.exit(1 if bad else 0)
