#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
rows_file="$repo_root/Keyboard/Controllers/KeyboardViewController+Rows.swift"
layout_file="$repo_root/Keyboard/Controllers/KeyboardViewController+KaomojiLayout.swift"
actions_file="$repo_root/Keyboard/Controllers/KeyboardViewController+ModeActions.swift"

assert_contains() {
    local file="$1"
    local expected="$2"
    local description="$3"

    if ! rg --fixed-strings --quiet -- "$expected" "$file"; then
        echo "FAIL: $description" >&2
        echo "  missing: $expected" >&2
        echo "  file: $file" >&2
        exit 1
    fi
}

# 两处入口必须继续汇合到同一个颜表情面板动作。
assert_contains "$rows_file" \
    'let kaomojiButton = makeKeyButton(title: "^_^", action: #selector(showKaomojiCandidates(_:)))' \
    "nine-key kaomoji entry"
assert_contains "$rows_file" \
    'for key in ["…", "，", "^_^", "？", "！", "‘"]' \
    "secondary-symbol kaomoji entry position"
assert_contains "$rows_file" \
    '? #selector(showKaomojiCandidates(_:))' \
    "secondary-symbol kaomoji action"

# 分类切换必须更新选择状态并重建当前面板。
assert_contains "$layout_file" \
    'selectedKaomojiCategoryIndex = sender.tag' \
    "kaomoji category selection state"
assert_contains "$layout_file" \
    'reloadKeyboardContent()' \
    "kaomoji category reload"

# 条目必须继续走统一 direct-text 最终提交路径，返回必须关闭面板。
assert_contains "$layout_file" \
    'let button = makeKeyButton(title: kaomoji, action: #selector(insertDirectText(_:)))' \
    "exact kaomoji insertion action"
assert_contains "$layout_file" \
    'let backButton = makeKeyButton(title: "返回", action: #selector(dismissKaomojiPanel(_:)))' \
    "kaomoji back action"
assert_contains "$actions_file" \
    'isKaomojiPanelVisible = false' \
    "kaomoji panel dismissal state"

echo "PASS: kaomoji UI interaction contract"
