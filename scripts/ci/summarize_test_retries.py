#!/usr/bin/env python3
"""Summarize XCTest cases that were attempted again after a failure."""
import re
import sys
from collections import defaultdict
from pathlib import Path

RESULT = re.compile(r"^Test Case '-\[(.+?) (.+?)\]' (passed|failed) \(")


def summarize(text):
    results = defaultdict(list)
    for line in text.splitlines():
        match = RESULT.match(line)
        if match:
            suite, case, result = match.groups()
            results[f"{suite}.{case}"].append(result)
    recovered = sorted(name for name, attempts in results.items() if len(attempts) > 1 and 'failed' in attempts[:-1] and attempts[-1] == 'passed')
    failed = sorted(name for name, attempts in results.items() if len(attempts) > 1 and 'failed' in attempts[:-1] and attempts[-1] == 'failed')
    return recovered, failed


def main():
    recovered, failed = summarize(Path(sys.argv[1]).read_text(encoding='utf-8', errors='replace'))
    for title, cases in [('Failed then passed on retry', recovered), ('Still failed after retry', failed)]:
        print(f'### {title}')
        print('\n'.join(f'- {case}' for case in cases) if cases else '- None')


if __name__ == '__main__':
    main()
