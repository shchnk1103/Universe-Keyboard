#!/usr/bin/env python3
"""kos-signals.py [--inbox "Human 原话"]   O17：从真实账本/报告自动发现可优化信号。只读（--inbox 只追加到 SIGNALS-INBOX.md）。
信号：①升级/失败事件及其原因标签（CAUSE-TAGS.tsv：阶段|时间前缀|原因）；未标签的升级事件被列出，必须补标；
②同一原因出现 ≥2 次 → 应有流程修复；③账本引用的报告超过 12288 字节；④改进清单中状态仍为"待"的条目数。
--inbox：Human 提出的流程类问题/建议原话立刻入收件箱，PM 在同一回合转成 backlog 条目。"""
import sys, os, re, glob, collections, datetime
H = os.path.join(os.environ.get('KOS_HOME', os.path.expanduser('~/.kos-work')), os.environ.get('KOS_PROJECT', 'Universe-Keyboard'))
if len(sys.argv) > 2 and sys.argv[1] == '--inbox':
    open(f'{H}/SIGNALS-INBOX.md', 'a').write(f"- {datetime.datetime.now():%Y-%m-%d %H:%M} Human：{sys.argv[2]}\n  状态：待转 backlog\n")
    print("已入收件箱"); sys.exit(0)
tags = {}
tf = f'{H}/CAUSE-TAGS.tsv'
if os.path.exists(tf):
    for l in open(tf, encoding='utf-8'):
        p = l.rstrip('\n').split('|')
        if len(p) >= 3 and not l.startswith('#'): tags[(p[0], p[1])] = p[2]
BAD = ('STOPPED', 'FAIL', 'CHANGES_REQUESTED', 'PARTIAL', 'BLOCKED')
events, untagged, big = [], [], []
for led in sorted(glob.glob(f'{H}/*/STAGE-LEDGER.md')):
    stage = os.path.basename(os.path.dirname(led))
    for l in open(led, encoding='utf-8'):
        f = [x.strip() for x in l.split(' | ')]
        if len(f) < 7: continue
        t, role, verdict, rpt = f[0], f[1], f[2], f[3]
        if verdict.split()[0] in BAD or '升级 PM' in f[6]:
            cause = next((c for (s, tp), c in tags.items() if s == stage and t.startswith(tp)), None)
            events.append((stage, t, role, verdict, cause))
            if not cause: untagged.append((stage, t, role, verdict))
        if rpt.startswith('/') and os.path.isfile(rpt) and rpt.endswith('.md'):
            n = os.path.getsize(rpt)
            if n > 12288 and 'executor-report' in rpt or n > 12288 and 'preflight' in rpt or n > 12288 and 'quality' in rpt:
                big.append((stage, rpt, n))
print(f"== 升级/失败事件 {len(events)} 个")
cnt = collections.Counter(c for *_, c in events if c)
for c, n in cnt.most_common(): print(f"   {c}: {n}" + ("   ← 重复原因，必须有流程修复而不是再修一个包" if n >= 2 else ""))
if untagged:
    print(f"== 未标原因的事件 {len(untagged)} 个（补写到 CAUSE-TAGS.tsv：阶段|时间前缀|原因）")
    for s, t, r, v in untagged: print(f"   {s} {t} {r} {v}")
print(f"== 超过 12288 字节的报告 {len(big)} 份")
for s, p, n in big: print(f"   {s} {os.path.basename(p)} {n} 字节")
bl = open(f'{H}/KOS-IMPROVEMENT-BACKLOG.md', encoding='utf-8').read() if os.path.exists(f'{H}/KOS-IMPROVEMENT-BACKLOG.md') else ''
open_items = len(re.findall(r'状态：待', bl))
print(f"== 改进清单中状态仍为'待'的条目 {open_items} 个")
ib = f'{H}/SIGNALS-INBOX.md'
if os.path.exists(ib):
    pend = open(ib, encoding='utf-8').read().count('状态：待转')
    print(f"== 收件箱待转 {pend} 条")
