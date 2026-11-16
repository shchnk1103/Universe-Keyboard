#!/usr/bin/env python3
"""Shared KOS O41 clause specifications (Single Source of Truth with docs/kos/pm-packet-clauses.md)."""

THREE_LINE_FINAL_LABELS = ("结论：", "下一位交付：", "报告：")
LEGACY_ONE_SENTENCE_PATTERN = r"最终消息只写一句话"

# Transition-period pattern: accepts either the new three-line format
# (结论：/ 下一位交付：/ 报告：) or the legacy one-sentence clause.
FINAL_MESSAGE_TRANSITION_REGEX = (
    r"(?:结论：[\s\S]*?下一位交付：[\s\S]*?报告：|最终消息只写一句话)"
)

RELAY_SECTION_HEADING = "## 下一站接力（O41）"
UN_DISPATCHED_MARKER = "未派发"
PM_HANDOFF_ROLE = "Jack"

CLAUSES_DOC_SYNC_MARKERS = (
    "结论：",
    "下一位交付：",
    "报告：",
    "## 唯一入口与条件接力（O41）",
    "CURRENT.json",
    "## 下一站接力（O41）",
    "--recover",
)
