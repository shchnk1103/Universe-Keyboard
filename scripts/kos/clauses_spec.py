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

# Specifications describe packet content; they do not certify execution or CI results.
COMMON_REQUIRED_CHECKS = frozenset({
    "classify-change", "lightweight-checks", "final-quality-gate",
    "GitGuardian Security Checks",
})
HEAVY_CHECKS = frozenset({
    "format-swift", "test-keyboardcore", "test-rimebridge",
    "test-app-keyboard", "test-rime-sync-keychain", "build-release",
})
CLASSIFICATION_REQUIRED_HEAVY = {
    "docs_only": frozenset(),
    "kos_tools_only": frozenset(),
    "keyboard_ui_only": frozenset({"format-swift", "test-app-keyboard", "build-release"}),
    "rimebridge_only": frozenset({"format-swift", "test-rimebridge", "test-app-keyboard", "build-release"}),
    "rimebridge_sync_only": frozenset({"format-swift", "test-rimebridge", "test-app-keyboard", "test-rime-sync-keychain", "build-release"}),
    "app_only": frozenset({"format-swift", "test-app-keyboard", "build-release"}),
    "app_sync_only": frozenset({"format-swift", "test-app-keyboard", "test-rime-sync-keychain", "build-release"}),
    "full": HEAVY_CHECKS,
}
CLASSIFICATION_ALLOWED_SKIPPED = {
    classification: HEAVY_CHECKS - required
    for classification, required in CLASSIFICATION_REQUIRED_HEAVY.items()
}

COMMON_PACKET_MARKERS = ("## 分类与检查结果（publish / land）",)
PUBLISH_PACKET_MARKERS = ("## 发布差异、manifest 与工具预检（publish）", "O21", "shasum -a 256 -c")
LAND_PACKET_MARKERS = ("## Wendy 合并与清理顺序（land）", "already_deleted_on_origin", "test -L")

CLAUSES_DOC_SYNC_MARKERS = (
    "结论：",
    "下一位交付：",
    "报告：",
    "## 唯一入口与条件接力（O41）",
    "CURRENT.json",
    "## 下一站接力（O41）",
    "--recover",
) + COMMON_PACKET_MARKERS + PUBLISH_PACKET_MARKERS + LAND_PACKET_MARKERS
