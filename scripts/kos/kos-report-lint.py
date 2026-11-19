#!/usr/bin/env python3
"""kos-report-lint.py <报告.md> [--max-bytes N] [--warn-bytes N] [--rep-lines 20]
机械检查"摘要报告"是否合规（O16）：大小、首行状态、机器输出整段内嵌、引用的日志路径+SHA 是否实测一致。
默认上限按文件名分层：design-*.md 与 arch-review-*.md 为 24576 字节（16384 提醒），其余报告为 12288（8192 提醒）。
显式 --max-bytes / --warn-bytes 始终覆盖默认值。
退出码：0 合规；1 有问题（逐条打印）。只读。"""
import sys, re, hashlib, os, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from clauses_spec import PM_HANDOFF_ROLE, RELAY_SECTION_HEADING

args = sys.argv[1:]
require_o41 = "--require-o41" in args or os.environ.get("KOS_REQUIRE_O41") == "1"
args = [a for a in args if a != "--require-o41"]
def opt(n, d):
    return int(args[args.index(n)+1]) if n in args else d
path = args[0]
name = os.path.basename(path)
if name.endswith('.md') and (name.startswith('design-') or name.startswith('arch-review-')):
    default_max, default_warn = 24576, 16384
else:
    default_max, default_warn = 12288, 8192
mx, wn, rep = opt('--max-bytes', default_max), opt('--warn-bytes', default_warn), opt('--rep-lines', 20)
raw = open(path, 'rb').read(); txt = raw.decode('utf-8', 'replace'); lines = txt.splitlines()
bad = []
if len(raw) > mx: bad.append(f"报告 {len(raw)} 字节，超过上限 {mx}：把机器输出移到日志/附录文件，只在摘要里写路径、SHA-256、计数")
elif len(raw) > wn: print(f"提示：报告 {len(raw)} 字节，接近上限 {mx}")
status = lines[0].strip().split()[0] if lines and lines[0].strip() else ""
if status not in ('DONE','PARTIAL','BLOCKED','STOPPED','PASS','CHANGES_REQUESTED','FAIL','APPROVE','CONDITIONAL'):
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
has_relay = RELAY_SECTION_HEADING in txt
if require_o41 and not has_relay:
    bad.append(f"缺少 O41 接力节：{RELAY_SECTION_HEADING}")
if has_relay:
    relay_sec = txt.split(RELAY_SECTION_HEADING, 1)[1]
    m_role = re.search(r"next_role[^\n:：]*[:：]\s*`?([^\n`]+)", relay_sec)
    if not m_role:
        bad.append(f"{RELAY_SECTION_HEADING} 缺少 next_role")
    elif status in ('PARTIAL', 'BLOCKED', 'STOPPED', 'FAIL') and PM_HANDOFF_ROLE not in m_role.group(1):
        bad.append(f"状态为 {status} 时 next_role 必须交 {PM_HANDOFF_ROLE}（实为 {m_role.group(1).strip()}）")
print("\n".join(("问题：" + b) for b in bad) if bad else "OK")
sys.exit(1 if bad else 0)
