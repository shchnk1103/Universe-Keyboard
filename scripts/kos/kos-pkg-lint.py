#!/usr/bin/env python3
"""kos-pkg-lint.py --start <本阶段起点提交SHA> [--prev <上一阶段任务目录>] [--stage <本阶段目录>（自动选各类最高修订版与最新章程）] [--charter <章程>] [包文件...]
O1/O19：包与包之间的机械一致性检查（只读）。退出码 1=有错误，0=仅提示或无问题。
检查：
 E1 起点类 SHA：出现在“起点/父提交/HEAD/起点提交”语境里的 40 位 SHA 必须等于 --start（或同一行同时写了“取代/历史/旧”视为引用旧物）。
 E2 遗留 SHA：出现在 --prev 目录各包里、但本阶段章程（或本批包）并未自己声明的 40 位 SHA，若出现在本批包里 → 报“可能是拷贝遗留”。
 E3 参数键：包里 kos-block.sh 命令行的 key=值 的 key 必须在章程第 4 条键表里。
 E4 引用路径：包里的绝对路径（排除 reports/、scratch/、worktree、含 < > 的占位）必须存在。
 W1 数字短语：同一“名词+数字”（如 7 条断言、18 项跳过）在不同包里数字不同 → 提示人工核对。
 W2 量词：同一份文本里既有“各自/分别/逐项”又有“或”描述同一类枚举时提示（启发式：同一行有“或”且另一包同关键词的行有“各自/分别”）。
"""
import sys, re, os, collections
args = sys.argv[1:]
def opt(n):
    if n in args:
        i = args.index(n); v = args[i+1]; del args[i:i+2]; return v
start = opt('--start'); prev = opt('--prev'); charter = opt('--charter'); stage = opt('--stage')
files = args
if stage:  # 自动选各类包的最高修订版与最新章程
    import glob, re as _re
    def rev(fn):
        m = _re.search(r'-r(\d+)\.md$', fn); return int(m.group(1)) if m else 0
    files = []
    for kind in ['pre', 'impl', 'quality', 'fix']:
        c = sorted(glob.glob(f'{stage}/instructions/task-package-{kind}*.md'), key=rev)
        if c: files.append(c[-1])
    cs = sorted(glob.glob(f'{stage}/STAGE-CHARTER*.md'), key=rev)
    if cs and not charter: charter = cs[-1]
assert start and files, __doc__
H = os.path.join(os.environ.get('KOS_HOME', os.path.expanduser('~/.kos-work')), os.environ.get('KOS_PROJECT', 'Universe-Keyboard'))
err, warn = [], []
txt = {f: open(f, encoding='utf-8').read() for f in files}
if charter: txt[charter] = open(charter, encoding='utf-8').read()
SHA = re.compile(r'(?<![0-9a-f])[0-9a-f]{40}(?![0-9a-f])')
CTX = re.compile(r'起点|父提交|HEAD|基线提交')
OLD = re.compile(r'取代|历史|旧|未下发|原包|上一')
for f, t in txt.items():
    for n, line in enumerate(t.split('\n'), 1):
        for m in SHA.finditer(line):
            s = m.group(0)
            win = line[max(0, m.start()-40):m.end()+10]
            if CTX.search(win) and s != start and not OLD.search(line):
                err.append(f"E1 {os.path.basename(f)}:{n} 起点类语境里的 SHA {s[:8]} ≠ 本阶段起点 {start[:8]}")
if prev:
    prevsha = set()
    for pf in os.popen(f"ls {prev}/instructions/task-package-*.md {prev}/STAGE-CHARTER*.md 2>/dev/null").read().split():
        prevsha |= set(SHA.findall(open(pf, encoding='utf-8').read()))
    own = set()
    if charter: own = set(SHA.findall(txt[charter]))
    for f in files:
        for s in set(SHA.findall(txt[f])) & prevsha:
            if s != start and s not in own:
                err.append(f"E2 {os.path.basename(f)} 含上一阶段包里的 SHA {s[:8]}，本阶段章程未声明：可能是拷贝遗留")
keytab = set()
if charter:
    for m in re.finditer(r'^\| ([a-zA-Z_]+) \|', txt[charter], re.M): keytab.add(m.group(1))
if keytab:
    for f in files:
        for m in re.finditer(r'kos-block\.sh[^`\n]*', txt[f]):
            for k in re.findall(r'\s([a-zA-Z_]+)=', m.group(0)):
                if k not in keytab: err.append(f"E3 {os.path.basename(f)} 的 kos-block 命令用了章程键表外的键 {k}")
seen = set()
for f in files:
    for m in re.finditer(r'(/Users/[^\s`（）()，。;；]+)', txt[f].replace('/Users/doubleshy0n/Dev/Universe Keyboard','/Users/doubleshy0n/Dev/UniverseKeyboard')):
        p = m.group(1).rstrip('.,:')
        if p in seen or '/Dev/UniverseKeyboard' in p or '/reports/' in p or '/scratch' in p or '/worktree' in p or '<' in p or p.endswith('/') or 'STAGE-LEDGER' in p: continue
        seen.add(p)
        if not os.path.exists(p): err.append(f"E4 {os.path.basename(f)} 引用的路径不存在：{p}")
nums = collections.defaultdict(lambda: collections.defaultdict(set))
for f in files:
    for m in re.finditer(r'(\d+) ?(条|项|个|次|轮|种|处)([一-鿿A-Za-z]{0,6})', txt[f]):
        noun = m.group(2) + m.group(3)[:4]
        nums[noun][m.group(1)].add(os.path.basename(f))
for noun, d in nums.items():
    if len(d) > 1 and noun.strip():
        warn.append("W1 “数字+" + noun + "” 在不同位置数字不同：" + "; ".join(f"{k}→{sorted(v)}" for k, v in sorted(d.items())))
kw = ['反例', '断言', '清单', '快照', '情形']
for k in kw:
    each = [(os.path.basename(f), n) for f in files for n, l in enumerate(txt[f].split('\n'), 1) if k in l and re.search('各自|分别|逐项', l)]
    orr = [(os.path.basename(f), n) for f in files for n, l in enumerate(txt[f].split('\n'), 1) if k in l and re.search(r'[，、（(]或|或者|或 ', l)]
    if each and orr:
        warn.append(f"W2 关键词“{k}”既有“各自/分别/逐项”（{each[:2]}）又有“或”（{orr[:2]}）：确认量词对齐")

# W3 同一编号条目（U1/U2…、(1)(2)…）在不同文件里的文字相似度过低 → 提示可能互相矛盾
def items(txt):
    d = {}
    for l in txt.split('\n'):
        m = re.match(r'^\(?([A-Z]\d+)[\).]\s*(.*)$', l)
        if m: d[m.group(1)] = m.group(2)
    return d
def grams(s):
    s = re.sub(r'\s+', '', s); return {s[i:i+3] for i in range(len(s)-2)}
its = {f: items(t) for f, t in txt.items()}
names = list(its)
for i in range(len(names)):
    for j in range(i+1, len(names)):
        for k in set(its[names[i]]) & set(its[names[j]]):
            a, b = grams(its[names[i]][k]), grams(its[names[j]][k])
            if a and b and len(a & b) / len(a | b) < 0.30:
                warn.append(f"W3 条目 {k} 在 {os.path.basename(names[i])} 与 {os.path.basename(names[j])} 里文字差异很大，请人工核对是否矛盾")
for e in err: print(e)
for w in warn: print(w)
print(f"== 错误 {len(err)}，提示 {len(warn)}")
sys.exit(1 if err else 0)
