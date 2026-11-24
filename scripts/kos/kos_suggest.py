#!/usr/bin/env python3
"""kos-suggest: register report suggestions ("观察与改进意见"), count repeats, raise priority.

Human 2026-11-15 approved: suggestions are registered by tool, not by memory; the
same topic raised again raises the priority of the work item it is linked to.

Data  SUGGESTIONS.json            one record per topic (count, link, status, sources)
Log   PM-LOG/suggestions-ledger.md  append-only human-readable ledger (one row per mention)

  add --task T --report PATH --text "一句话" --topic KEY [--layer L] [--status S] [--link ID]
        Register one suggestion. Same --topic again = repeat: count +1.
        2nd mention: shown in digest. 3rd and later: linked queue item moves up one
        place (never above rank 2) and the output says to tell the Human.
  topics [WORD]     list topic keys (use before add, to reuse an existing key)
  link TOPIC ID     attach a topic to a register item (kos-q id)
  status TOPIC S    新 / 已采纳 / 已拒绝 / 已完成 / 需 Human 决定
  pending REPORT    exit 1 if the report has a suggestions section whose items are not registered
  digest            repeats (count>=2, still open) and adopted topics with no register link
Statuses that close a topic: 已拒绝, 已完成.
"""
import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import time

ROOT = os.environ.get('KOS_HOME', os.path.expanduser('~/.kos-work/Universe-Keyboard'))
DATA = os.path.join(ROOT, 'SUGGESTIONS.json')
LEDGER = os.path.join(ROOT, 'PM-LOG', 'suggestions-ledger.md')
KOSQ = os.path.join(ROOT, 'tools', 'kos-q.py')
QUEUE = os.path.join(ROOT, 'QUEUE.json')
TODAY = time.strftime('%Y-%m-%d')
CLOSED = ('已拒绝', '不采纳', '已完成', '已关闭', '关闭')
STATUSES = ('新', '已采纳', '已拒绝', '不采纳', '已完成', '已关闭', '关闭', '需 Human 决定')
HEADING = '观察与改进意见'
NONE_WORDS = ('没有', '没有。', '无', '无。', 'None', 'none')


def die(msg, code=2):
    print(msg, file=sys.stderr)
    sys.exit(code)


def load():
    if not os.path.exists(DATA):
        return {'topics': {}}
    with open(DATA, encoding='utf-8') as f:
        return json.load(f)


def save(db):
    tmp = DATA + '.tmp'
    with open(tmp, 'w', encoding='utf-8') as f:
        json.dump(db, f, ensure_ascii=False, indent=1)
    os.replace(tmp, DATA)


def sha8(path):
    with open(path, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()[:8]


def queue_item(item_id):
    if not os.path.exists(QUEUE):
        return None
    with open(QUEUE, encoding='utf-8') as f:
        for r in json.load(f).get('items', []):
            if r['id'] == item_id:
                return r
    return None


def section_items(path):
    """Return the suggestion lines of every 观察与改进意见 section (empty if none/没有).

    Subheadings (### and deeper) inside a section do not stop collection; only a
    heading of the same or higher level than the section (or a handoff block) does.
    """
    with open(path, encoding='utf-8') as f:
        lines = f.read().split('\n')
    starts = [i for i, l in enumerate(lines) if l.startswith('#') and HEADING in l]
    if not starts:
        return None
    body = []
    for start in starts:
        level = len(lines[start]) - len(lines[start].lstrip('#'))
        for l in lines[start + 1:]:
            if l.startswith('```'):
                break
            if l.startswith('交回：'):
                break
            if l.startswith('#'):
                l_level = len(l) - len(l.lstrip('#'))
                if l_level <= level:
                    break
                continue
            if '报告格式检查' in l or 'kos-report-lint' in l:
                continue
            if l.strip():
                body.append(l.strip())
    items = [re.sub(r'^([-*]|\d+[.、)]|O-?\d+[:：]?)\s*', '', l) for l in body]
    return [i for i in items if i and i not in NONE_WORDS
            and re.fullmatch(r'(?:没有更多|无其他建议|无其它建议)[。.!！]?', i) is None]


def normalize(text):
    return re.sub(r'\s+', '', text).strip('。.!！;；')


def validate_status(status, task='', evidence='', reason=''):
    if status == '已采纳' and not re.search(r'\b[A-Z0-9]+-[A-Z0-9-]+\b', ' '.join((task, evidence))):
        die('已采纳需要挂接任务 ID')
    if status in ('已完成', '已关闭', '关闭') and not re.search(
        r'(?<![0-9A-Za-z])[0-9a-fA-F]{7,64}(?![0-9A-Za-z])|/|\.(?:md|py|sh)\b|PR\s*#\s*\d+', evidence, re.I
    ):
        die('关闭需要可核对证据')
    if status in ('已拒绝', '不采纳') and not reason.strip():
        die('拒绝需要理由')


def cmd_add(a, db):
    if a.status not in STATUSES:
        die('status 只能是：' + ' / '.join(STATUSES))
    validate_status(a.status, a.target_task or a.link, ' '.join((a.evidence, a.note)), a.reason)
    if a.link and not queue_item(a.link):
        die(f'登记簿里没有 {a.link}；先 kos-q.py add 或换一个 --link')
    if not os.path.exists(a.report):
        die(f'报告不存在：{a.report}')
    rsha = sha8(a.report)
    t = db['topics'].setdefault(a.topic, {'count': 0, 'status': a.status, 'link': '', 'layer': a.layer, 'first': TODAY, 'sources': []})
    key = [a.task, rsha, a.text]
    if any(s[:3] == key for s in t['sources']):
        die(f'已登记过（同一报告同一句）：{a.topic}', 0)
    t['count'] += 1
    t['last'] = TODAY
    t['sources'].append(key + [TODAY])
    if a.evidence:
        t['evidence'] = a.evidence
    if a.reason:
        t['reason'] = a.reason
    if a.target_task or a.link:
        t['link'] = a.target_task or a.link
    if a.note:
        t['note'] = a.note
    if t['count'] > 1 and t['status'] in CLOSED:
        print(f'注意：主题 {a.topic} 原状态为「{t["status"]}」却再次被提出，已改回「新」')
        t['status'] = '新'
    elif t['count'] == 1:
        t['status'] = a.status
    save(db)
    text = a.text.replace('|', '／')
    with open(LEDGER, 'a', encoding='utf-8') as f:
        f.write(f'| {TODAY} | {a.task} | {rsha} | {text} | {a.layer} | {t["status"]}｜主题 {a.topic} 第 {t["count"]} 次｜挂 {t["link"] or "未挂"} |\n')
    print(f'已登记：{a.topic} 第 {t["count"]} 次（状态 {t["status"]}，挂 {t["link"] or "未挂"}）')
    if t['count'] >= 3:
        r = queue_item(t['link']) if t['link'] else None
        if r and r['zone'] == 'queue' and r['rank'] > 2:
            new = r['rank'] - 1
            subprocess.run([sys.executable, KOSQ, 'rank', t['link'], str(new)], check=True, stdout=subprocess.DEVNULL)
            subprocess.run([sys.executable, KOSQ, 'set', t['link'], '-m', f'kos-suggest: 主题 {a.topic} 第 {t["count"]} 次被提出，上移到第 {new} 位'], check=True, stdout=subprocess.DEVNULL)
            print(f'提级：{t["link"]} 上移到队列第 {new} 位')
        elif not t['link']:
            print('提级：该主题还没挂登记簿任务，先 kos-suggest.py link 再处理')
        print(f'告诉 Human：主题「{a.topic}」已被提出 {t["count"]} 次')


def pending_items(report, db, items):
    rsha = sha8(report)
    done = {normalize(s[2]) for t in db['topics'].values() for s in t['sources'] if s[1] == rsha}
    items = list({normalize(i): i for i in items}.values())
    matched = {i for i in items if normalize(i) in done}
    return items, matched


def cmd_pending(a, db):
    items = section_items(a.report)
    if items is None:
        print('MISSING_SECTION: 缺少观察与改进意见')
        return 1
    if not items:
        print('无意见需要登记')
        return 0
    items, matched = pending_items(a.report, db, items)
    n = len(matched)
    if n == len(items):
        print(f'该报告 {len(items)} 条意见均已登记')
        return 0
    print(f'该报告有 {len(items)} 条意见，已登记 {n} 条。待登记原文：')
    for i in items:
        print(('  [可能已登记] ' if i in matched else '  - ') + i[:200])
    print('用 kos-suggest.py topics 找已有主题，再 kos-suggest.py add 逐条登记')
    return 1


def cmd_check_task(task, db):
    reports = os.path.join(task, 'reports')
    if not os.path.exists(reports):
        return 0
    if not os.path.isdir(reports):
        die(f'报告目录不是目录：{reports}')
    pending = False
    for name in sorted(os.listdir(reports)):
        if not name.endswith('.md'):
            continue
        report = os.path.join(reports, name)
        items = section_items(report)
        if items is None or not items:
            continue
        items, matched = pending_items(report, db, items)
        count = len(items) - len(matched)
        if count:
            print(f'{report}: {count} 条未登记意见。待登记原文：')
            for i in items:
                if i not in matched:
                    print('  - ' + i[:200])
            pending = True
    return 1 if pending else 0


def cmd_digest(db):
    out = []
    for k, t in sorted(db['topics'].items(), key=lambda kv: -kv[1]['count']):
        if t['status'] in CLOSED:
            continue
        if t['count'] >= 2:
            out.append(f'意见重复 {t["count"]} 次：{k}（{t["status"]}，挂 {t["link"] or "未挂"}）')
        elif t['status'] == '已采纳' and not t['link']:
            out.append(f'已采纳但未挂任务：{k}')
    for l in out[:6]:
        print('! ' + l)
    if len(out) > 6:
        print(f'! …另有 {len(out) - 6} 条重复或未挂任务的意见（kos-suggest.py topics）')


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    s = p.add_subparsers(dest='cmd', required=True)
    a = s.add_parser('add')
    for k in ('task', 'report', 'text', 'topic'):
        a.add_argument('--' + k, required=True)
    a.add_argument('--layer', default='KOS 流程'); a.add_argument('--status', default='新'); a.add_argument('--link', default='')
    a.add_argument('--evidence', default=''); a.add_argument('--reason', default='')
    a.add_argument('--target-task', default=''); a.add_argument('--note', default='')
    a = s.add_parser('topics'); a.add_argument('word', nargs='?', default='')
    a = s.add_parser('link'); a.add_argument('topic'); a.add_argument('id')
    a = s.add_parser('status'); a.add_argument('topic'); a.add_argument('status')
    a.add_argument('--task', default=''); a.add_argument('--target-task', default=''); a.add_argument('--evidence', default=''); a.add_argument('--note', default=''); a.add_argument('--reason', default='')
    a = s.add_parser('pending'); a.add_argument('report')
    a = s.add_parser('check-task'); a.add_argument('task_dir')
    s.add_parser('digest')
    a = p.parse_args()
    db = load()
    if a.cmd == 'add':
        cmd_add(a, db)
    elif a.cmd == 'topics':
        for k, t in sorted(db['topics'].items()):
            if a.word in k or any(a.word in src[2] for src in t['sources']):
                print(f'{k}｜{t["count"]} 次｜{t["status"]}｜挂 {t["link"] or "未挂"}｜{t["sources"][-1][2][:50]}')
    elif a.cmd in ('link', 'status'):
        if a.topic not in db['topics']:
            die(f'没有主题 {a.topic}（kos-suggest.py topics）')
        if a.cmd == 'link':
            if not queue_item(a.id):
                die(f'登记簿里没有 {a.id}')
            db['topics'][a.topic]['link'] = a.id
        else:
            if a.status not in STATUSES:
                die('status 只能是：' + ' / '.join(STATUSES))
            validate_status(a.status, a.target_task or a.task or db['topics'][a.topic].get('link', ''), ' '.join((a.evidence, a.note)), a.reason)
            db['topics'][a.topic]['status'] = a.status
            if a.target_task or a.task:
                db['topics'][a.topic]['link'] = a.target_task or a.task
            if a.note:
                db['topics'][a.topic]['note'] = a.note
            if a.evidence:
                db['topics'][a.topic]['evidence'] = a.evidence
            if a.reason:
                db['topics'][a.topic]['reason'] = a.reason
        save(db)
    elif a.cmd == 'pending':
        sys.exit(cmd_pending(a, db))
    elif a.cmd == 'check-task':
        sys.exit(cmd_check_task(a.task_dir, db))
    elif a.cmd == 'digest':
        cmd_digest(db)


if __name__ == '__main__':
    main()
