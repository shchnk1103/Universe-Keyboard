#!/usr/bin/env python3
"""kos-contains.py <正则> <日志文件> <对照文件>  —— 日志里匹配正则的每一行是否都在对照文件里出现（逐字）。
输出匹配行数、缺失行数；缺失则打印前 5 条；退出码 0 全在，1 有缺失。用来替代"人通读报告核对每一行"。只读。"""
import sys, re
rx, a, b = re.compile(sys.argv[1]), sys.argv[2], sys.argv[3]
other = set(open(b, encoding='utf-8', errors='replace').read().splitlines())
rows = [l for l in open(a, encoding='utf-8', errors='replace').read().splitlines() if rx.search(l)]
miss = [l for l in rows if l not in other]
print(f"匹配 {len(rows)} 行，缺失 {len(miss)} 行")
for l in miss[:5]: print("缺失：", l[:200])
sys.exit(1 if miss else 0)
