#!/usr/bin/env python3
"""kos-q: the unfinished-work register (KOS O54). Plain Python, any AI/PM can run it.

Data   QUEUE.json      one short record per work line (state only, no history)
Log    QUEUE-LOG.md    append-only history; not read by default
View   PRIORITY.md     generated, do not hand-edit

  digest                          ~10 lines: read at the start of a PM turn
  add ID --title T [--zone Z] [--rank N] [--next X] [--owner O] [--hold H]
  set ID [--state S] [--next X] [--owner O] [--hold H] [--zone Z] [--title T] [-m NOTE]
  rank ID N                       move ID to position N in the queue
  inbox "TEXT"                    capture now, sort later
  done ID [-m NOTE]
  gate ID_OR_DIR [--why REASON]   exit 0 = may dispatch; 2 = not registered; 3 = jumps the queue
  show ID | list [ZONE] | render
Zones: queue (can move now) / human (waiting on Human or outside) / parked / inbox / done
ID is also a task-directory prefix: record T9-PINYIN-CYCLE covers T9-PINYIN-CYCLE-009.
"""
import argparse, json, os, re, subprocess, sys, time

def queue_root():
    explicit = os.environ.get('KOS_QUEUE_ROOT')
    if explicit:
        return explicit
    home = os.environ.get('KOS_HOME', os.path.expanduser('~/.kos-work'))
    return os.path.join(home, os.environ.get('KOS_PROJECT', 'Universe-Keyboard'))

ROOT = queue_root()
DATA, LOG, VIEW = (os.path.join(ROOT, n) for n in ('QUEUE.json', 'QUEUE-LOG.md', 'PRIORITY.md'))
ZONES = ['queue', 'human', 'parked', 'inbox', 'done']
LIMITS = {'title': 60, 'state': 60, 'next': 80, 'owner': 20, 'hold': 60}
IDLE_DAYS = 2
TODAY = time.strftime('%Y-%m-%d')


def load():
    if not os.path.exists(DATA):
        return {'focus': '', 'items': []}
    with open(DATA, encoding='utf-8') as f:
        return json.load(f)


def save(db, note):
    tmp = DATA + '.tmp'
    with open(tmp, 'w', encoding='utf-8') as f:
        json.dump(db, f, ensure_ascii=False, indent=1)
    os.replace(tmp, DATA)
    with open(LOG, 'a', encoding='utf-8') as f:
        f.write(f'- {time.strftime("%Y-%m-%d %H:%M")} {note}\n')
    render(db)


def die(msg, code=1):
    print(msg, file=sys.stderr)
    sys.exit(code)


def find(db, key, required=True):
    key = os.path.basename(key.rstrip('/'))
    hits = [r for r in db['items'] if key == r['id'] or key.startswith(r['id'] + '-')]
    if hits:
        return max(hits, key=lambda r: len(r['id']))
    if required:
        die(f'未登记：{key}。先运行 kos-q.py add {key} --title "…"', 2)
    return None


def queue(db):
    return sorted((r for r in db['items'] if r['zone'] == 'queue'), key=lambda r: r['rank'])


def renumber(db):
    for i, r in enumerate(queue(db), 1):
        r['rank'] = i


def apply(r, a):
    for k in ('title', 'state', 'next', 'owner', 'hold'):
        v = getattr(a, k, None)
        if v is None:
            continue
        if len(v) > LIMITS[k]:
            die(f'{k} 超过 {LIMITS[k]} 字（现 {len(v)}）。只写当前状态；过程用 -m 记进日志。')
        r[k] = v
    r['touched'] = TODAY


def line(r):
    hold = f'｜挡:{r["hold"]}' if r.get('hold') else ''
    return f'{r["id"]}｜{r.get("state", "")}｜下一步:{r.get("next", "")}｜{r.get("owner", "")}{hold}｜{r["touched"][5:]}'


def days(d):
    return int((time.mktime(time.strptime(TODAY, '%Y-%m-%d')) - time.mktime(time.strptime(d, '%Y-%m-%d'))) / 86400)


def active_dirs(since_days=3):
    out, now = [], time.time()
    for d in sorted(os.listdir(ROOT)):
        p = os.path.join(ROOT, d, 'reports')
        if not re.match(r'^[A-Z0-9][A-Z0-9-]+$', d) or not os.path.isdir(p):
            continue
        ms = [os.path.getmtime(os.path.join(p, f)) for f in os.listdir(p)
              if not f.startswith(('.', 'next-block', 'block-', 'params-', 'human-authorization'))]
        if ms and now - max(ms) < since_days * 86400:
            out.append((d, max(ms)))
    return out


def alerts(db):
    out, q = [], queue(db)
    free = [r for r in q if not r.get('hold')]
    if free:
        top = free[0]
        later = [r for r in free[1:] if r['touched'] > top['touched']]
        if days(top['touched']) >= IDLE_DAYS and later:
            out.append(f'队首 {top["id"]} 已 {days(top["touched"])} 天没动，而 {later[0]["id"]} 在推进')
    unreg = []
    for d, m in active_dirs():
        r = find(db, d, required=False)
        if not r:
            unreg.append(d)
        elif time.strftime('%Y-%m-%d', time.localtime(m)) > r['touched']:
            out.append(f'{d} 有新报告，{r["id"]} 的状态没更新')
    if unreg:
        out.append(f'未登记的活动目录 {len(unreg)} 个：' + '、'.join(unreg[:4]) + ('…' if len(unreg) > 4 else ''))
    n = [r for r in db['items'] if r['zone'] == 'inbox']
    if n:
        old = max(days(r['touched']) for r in n)
        out.append(f'收件箱 {len(n)} 条未排（最久 {old} 天）：kos-q.py list inbox')
    return out


def digest(db):
    print(f'聚焦规则：{db.get("focus") or "未设"}')
    for r in queue(db)[:3]:
        print(f'{r["rank"]}. {line(r)}')
    rest = len(queue(db)) - 3
    if rest > 0:
        print(f'   …队列还有 {rest} 项（kos-q.py list queue）')
    h = [r for r in db['items'] if r['zone'] == 'human']
    if h:
        print('等 Human：' + '；'.join(f'{r["id"]}({r.get("next", "")})' for r in h[:4]) + (f' 等 {len(h)} 项' if len(h) > 4 else ''))
    board = os.path.join(ROOT, 'tools', 'kos-board.sh')
    if os.path.exists(board):
        try:
            b = subprocess.run(['bash', board], capture_output=True, text=True, timeout=10).stdout
            busy = [' '.join(x.split()[:3]) for x in b.splitlines() if '工作中' in x]
            print('在工作的角色：' + ('；'.join(busy) if busy else '无'))
        except Exception:
            pass
    for a in alerts(db):
        print('! ' + a)
    sug = os.path.join(ROOT, 'tools', 'kos-suggest.py')
    if os.path.exists(sug):
        try:
            print(subprocess.run([sys.executable, sug, 'digest'], capture_output=True, text=True, timeout=10).stdout, end='')
        except Exception:
            pass


def render(db):
    L = ['# PRIORITY（由 tools/kos-q.py 生成，不要手改；历史在 QUEUE-LOG.md，旧表在 PRIORITY-legacy-20261114.md）',
         f'生成：{time.strftime("%Y-%m-%d %H:%M")}　聚焦规则：{db.get("focus") or "未设"}', '',
         '排序键：Human 明令 ＞ 上线关键路径 ＞ 阻塞别的任务 ＞ 上线前必修 ＞ KOS 工具流程 ＞ 上线后。',
         '用法：`python3 -I tools/kos-q.py digest`（回合开头）；改动只经 add/set/rank/inbox/done。', '']
    names = {'queue': '可动队列（按序）', 'human': '等 Human / 等外部', 'parked': '搁置 / 上线后', 'inbox': '收件箱（未排）'}
    for z in ZONES[:4]:
        rows = queue(db) if z == 'queue' else [r for r in db['items'] if r['zone'] == z]
        L.append(f'## {names[z]}')
        for r in rows:
            L.append(f'- {str(r["rank"]) + ". " if z == "queue" else ""}**{r["id"]}** {r.get("title", "")}｜{line(r).split("｜", 1)[1]}')
        L.append('')
    done = sorted((r for r in db['items'] if r['zone'] == 'done'), key=lambda r: r['touched'], reverse=True)[:5]
    L.append('## 近期完成')
    L += [f'- {r["touched"]} {r["id"]} {r.get("title", "")}' for r in done]
    with open(VIEW, 'w', encoding='utf-8') as f:
        f.write('\n'.join(L) + '\n')


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    s = p.add_subparsers(dest='cmd', required=True)
    s.add_parser('digest'); s.add_parser('render')
    for name in ('add', 'set'):
        a = s.add_parser(name); a.add_argument('id')
        for k in ('title', 'state', 'next', 'owner', 'hold'):
            a.add_argument('--' + k)
        a.add_argument('--zone', choices=ZONES); a.add_argument('--rank', type=int); a.add_argument('-m', default='')
    a = s.add_parser('rank'); a.add_argument('id'); a.add_argument('n', type=int)
    a = s.add_parser('inbox'); a.add_argument('text')
    a = s.add_parser('done'); a.add_argument('id'); a.add_argument('-m', default='')
    a = s.add_parser('gate'); a.add_argument('id'); a.add_argument('--why', default=os.environ.get('KOS_Q_WHY', ''))
    a = s.add_parser('show'); a.add_argument('id')
    a = s.add_parser('list'); a.add_argument('zone', nargs='?', choices=ZONES)
    a = s.add_parser('focus'); a.add_argument('text')
    a = p.parse_args()
    db = load()

    if a.cmd == 'digest':
        digest(db)
    elif a.cmd == 'render':
        render(db)
    elif a.cmd == 'focus':
        db['focus'] = f'{a.text}（{TODAY} 设）'; save(db, f'focus: {a.text}')
    elif a.cmd == 'add':
        if any(r['id'] == a.id for r in db['items']):
            die(f'已存在：{a.id}，用 set')
        if not a.title:
            die('add 需要 --title')
        r = {'id': a.id, 'zone': a.zone or 'queue', 'rank': 999, 'state': '', 'next': '', 'owner': '', 'hold': ''}
        apply(r, a); db['items'].append(r)
        if r['zone'] == 'queue':
            renumber(db)
            if a.rank:
                move(db, r, a.rank)
        save(db, f'add {a.id} [{r["zone"]}] {a.title} {a.m}')
    elif a.cmd == 'set':
        r = find(db, a.id); apply(r, a)
        if a.zone:
            r['zone'] = a.zone
            if a.zone == 'queue' and not r.get('rank'):
                r['rank'] = 999
        renumber(db)
        if a.rank:
            move(db, r, a.rank)
        save(db, f'set {r["id"]}: {r.get("state", "")} / next {r.get("next", "")} {a.m}')
    elif a.cmd == 'rank':
        r = find(db, a.id); move(db, r, a.n); r['touched'] = TODAY; save(db, f'rank {r["id"]} -> {a.n}')
    elif a.cmd == 'inbox':
        base = 'INBOX-' + time.strftime('%m%d%H%M%S')
        used = {r['id'] for r in db['items']}
        i = base
        n = 2
        while i in used:
            i = f'{base}-{n}'
            n += 1
        db['items'].append({'id': i, 'zone': 'inbox', 'rank': 0, 'title': a.text[:120], 'state': '', 'next': '', 'owner': '', 'hold': '', 'touched': TODAY})
        save(db, f'inbox {i}: {a.text}'); print(i)
    elif a.cmd == 'done':
        r = find(db, a.id); r['zone'] = 'done'; r['touched'] = TODAY; renumber(db); save(db, f'done {r["id"]} {a.m}')
    elif a.cmd == 'show':
        print(json.dumps(find(db, a.id), ensure_ascii=False, indent=1))
    elif a.cmd == 'list':
        for z in ([a.zone] if a.zone else ZONES[:4]):
            rows = queue(db) if z == 'queue' else [r for r in db['items'] if r['zone'] == z]
            for r in rows:
                print(f'[{z}] ' + (f'{r["rank"]}. ' if z == 'queue' else '') + (r.get('title', '') + '｜' if z == 'inbox' else '') + line(r))
    elif a.cmd == 'gate':
        r = find(db, a.id)
        free = [x for x in queue(db) if not x.get('hold')]
        top = free[0] if free else None
        jumps = (top and top is not r and top['touched'] < TODAY
                 and (r['zone'] != 'queue' or r['rank'] > top['rank']))
        if jumps and not a.why:
            die(f'越序：队首 {top["id"]}（下一步:{top.get("next", "")}，{top.get("owner", "")}）今天还没动。\n'
                f'先推进它，或加 --why "<理由>"（或环境变量 KOS_Q_WHY）再派 {r["id"]}。', 3)
        r['touched'] = TODAY
        save(db, f'gate {r["id"]} ok' + (f' 越序理由: {a.why}' if jumps else ''))
        print(f'gate ok: {r["id"]}')


def move(db, r, n):
    q = [x for x in queue(db) if x is not r]
    q.insert(max(0, min(n - 1, len(q))), r)
    r['zone'] = 'queue'
    for i, x in enumerate(q, 1):
        x['rank'] = i


if __name__ == '__main__':
    main()
