#!/usr/bin/env python3
"""Read-only post-merge housekeeping audit; never invokes a network client."""

import argparse
from pathlib import Path
import re
import sys


MERGED = re.compile(r"已(?:经)?(?:合并|合入)|已并入|\bmerged(?:_at|At)?\b|合入\s*[,，。]", re.I)
NEGATED = re.compile(
    r"未合并|尚未合并|不得合并|不(?:能|可|予)合并|待合并|禁止合并|准备合入|等待\s*CI|\bunmerged\b"
    r"|\b(?:never|not|no|without|cannot|can't|hasn't)\b[^。；;.!?\n]*\bmerged\b"
    # Future tense is a promise, not a fact.
    r"|\bwill\b[^。；;.!?\n]*\bmerged\b"
    # Explicit falsy merge values are evidence of a non-merge, not a merge.
    r"|\bmerged(?:_at|At)?\s*[:=：]\s*(?:null|nil|none|false|no|0|['\"]\s*['\"])"
    # A reverted merge is no longer merged.
    r"|\breverted\b",
    re.I,
)
PRODUCT = re.compile(r"(?<![A-Z0-9])(?:PB|PF)-\d+[A-Z]?(?![A-Z0-9])", re.I)
OPEN = re.compile(
    r"backlog|pending|\bopen\b|\bactive\b|待|未|规划中|进行中|部分落地"
    # English negative/unfinished states must never read as closed.
    r"|\bnot\s+(?:released|merged|completed|done|closed|started)\b"
    # Partial completion is still open work.
    r"|\bpartial(?:ly)?\b|部分",
    re.I,
)
CLOSED = re.compile(r"已完成|已合并|已合入|已销账|\breleased\b|\bcompleted\b|\bclosed\b|\bdone\b", re.I)
TARGET = re.compile(r"^\s*(?:[-*]\s*)?(?:#{1,6}\s*)?.{0,30}(?:任务|目标|task|target)\s*(?:ID|id)?\s*[:：]", re.I)


def merged_report(text):
    if re.match(r"\s*(?:STOPPED|BLOCKED|FAIL)\b", text, re.I):
        return False
    for line in text.splitlines():
        # A sentence about a pending merge must not establish that a PR merged.
        for sentence in re.split(r"[；;。]", line):
            if MERGED.search(sentence) and not NEGATED.search(sentence):
                return True
    return False


def active_release(path):
    text = path.read_text(encoding="utf-8")
    status = re.search(r"(?im)^\s*-\s*\*\*Status:\*\*\s*(.*)$", text)
    return bool(status and not re.search(r"\b(?:released|closed|archived|superseded)\b|已发布|已归档", status.group(1), re.I))


def matching_rows(path, identifiers):
    rows = []
    status_column = None
    for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if not line.lstrip().startswith("|"):
            status_column = None
            continue
        cells = [cell.strip() for cell in line.strip().strip("|").split("|")]
        headers = [i for i, cell in enumerate(cells) if re.fullmatch(r"(?:当前)?状态|status", cell.strip(" *`"), re.I)]
        if headers:
            status_column = headers[0]
            continue
        index = next((i for i in range(min(2, len(cells))) if any(
            re.search(r"(?<![\w-])" + re.escape(item) + r"(?![\w-])", cells[i], re.I)
            for item in identifiers
        )), None)
        if index is None:
            continue
        column = status_column if status_column is not None else index + 1
        status = cells[column] if column < len(cells) else ""
        closed = bool(CLOSED.search(status)) and not OPEN.search(status)
        rows.append((number, line.strip(), closed))
    return rows


def target_identifiers(task_name, reports):
    identifiers = {task_name, *(m.group(0).upper() for m in PRODUCT.finditer(task_name))}
    for report in reports:
        text = report.read_text(encoding="utf-8")
        title_seen = False
        for line in text.splitlines():
            heading = bool(re.match(r"^\s*#\s+", line))
            # Only the main title and task-own metadata lines declare
            # targets; "相关任务：" style prose mentions must not be swept in.
            declared = TARGET.search(line) and (
                heading or not title_seen
                or bool(re.search(r"任务\s*(?:ID|id)|^\s*[-*]\s*\*\*(?:任务|目标)", line, re.I))
            )
            if declared or (heading and not title_seen):
                identifiers.update(m.group(0).upper() for m in PRODUCT.finditer(line))
                # Task-ID metadata lines name the audited task itself even
                # when the id carries no PB/PF product number.
                identifiers.update(m.group(0).upper() for m in re.finditer(
                    r"(?<![\w-])[A-Z][A-Z0-9]*-[A-Z0-9]+(?:-[A-Z0-9]+)+(?![\w-])", line
                ))
            if heading:
                title_seen = True
    return identifiers


def audit(kos_root, repo):
    if not kos_root.is_dir():
        raise ValueError(f"KOS root is not a directory: {kos_root}")
    portfolio = repo / "docs" / "PORTFOLIO.md"
    releases = repo / "docs" / "releases"
    if not portfolio.is_file() or not releases.is_dir():
        raise ValueError("Missing docs/PORTFOLIO.md or docs/releases; audit incomplete")
    ledgers = [portfolio] + [p for p in sorted(releases.glob("v*.md")) if active_release(p)]
    if len(ledgers) == 1:
        # Distinguish "nothing active to audit" from an incomplete audit.
        print("no active release: docs/releases has no active Released/In Preparation "
              "record or is missing a Status header", file=sys.stderr)
        raise ValueError("audit incomplete: no active release record found")
    tasks = 0
    issues = 0
    for task in sorted(kos_root.iterdir()):
        if not task.is_dir():
            continue
        reports = sorted((task / "reports").glob("publish-*.md"))
        merged = [p for p in reports if merged_report(p.read_text(encoding="utf-8"))]
        if not merged:
            continue
        tasks += 1
        print(f"\n{task.name}: merged evidence: {', '.join(p.name for p in merged)}")
        identifiers = target_identifiers(task.name, merged)
        task_issues = []
        if (task / "worktree").exists() or (task / "worktree").is_symlink():
            task_issues.append(f"worktree remains: {task / 'worktree'}")
        known = False
        per_target_closed = {}
        for ledger in ledgers:
            for number, row, closed in matching_rows(ledger, identifiers):
                known = True
                if not closed:
                    task_issues.append(f"ledger outstanding or unknown: {ledger.relative_to(repo)}:{number}: {row}")
                else:
                    for item in identifiers:
                        if re.search(r"(?<![\w-])" + re.escape(item) + r"(?![\w-])", row, re.I):
                            per_target_closed[item] = True
        # Every declared target must be closed somewhere; one completed row
        # must not mask a sibling target that is still outstanding.
        for item in sorted(identifiers):
            if not per_target_closed.get(item) and any(
                re.search(r"(?<![\w-])" + re.escape(item) + r"(?![\w-])", ledger.read_text(encoding="utf-8"), re.I)
                for ledger in ledgers
            ):
                task_issues.append(f"target not closed: {item}")
        # A PB/PF product target must exist in PORTFOLIO.md even when some
        # release record already shows it closed.
        for item in sorted(identifiers):
            if not PRODUCT.fullmatch(item):
                continue
            if not re.search(r"(?<![\w-])" + re.escape(item) + r"(?![\w-])", portfolio.read_text(encoding="utf-8"), re.I):
                task_issues.append(f"portfolio row missing: {item} has no PORTFOLIO.md row")
        if not known:
            task_issues.append(
                "ledger record not found: no PORTFOLIO.md or active release row mentions "
                + ", ".join(sorted(identifiers))
            )
        if task_issues:
            issues += len(task_issues)
            for issue in task_issues:
                print(f"  - {issue}")
        else:
            print("  clean: no remaining worktree or matching outstanding ledger row")
    print(f"\nAudited merged tasks: {tasks}; outstanding items: {issues}")
    return 1 if issues else 0


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--kos-root", type=Path, default=Path.home() / ".kos-work" / "Universe-Keyboard")
    parser.add_argument("--repo", type=Path, default=Path(__file__).resolve().parents[2])
    args = parser.parse_args()
    try:
        return audit(args.kos_root, args.repo)
    except (OSError, UnicodeError, ValueError) as exc:
        print(f"audit incomplete: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
