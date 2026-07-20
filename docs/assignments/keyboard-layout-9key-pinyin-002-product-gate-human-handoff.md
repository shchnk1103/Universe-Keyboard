# KEYBOARD-LAYOUT-9KEY-PINYIN-002 — Product Gate Human Dependency Handoff

Prepared by: Codex（Executor）  
Handoff target: Human Product Owner → Quality device review → Product Lead  
Date / timezone: `2026-07-19 Asia/Shanghai`

> Assignment remains `Active`. Simulator automation and the real-runtime Spike do not equal Product Gate PASS. No commit, push, PR, or lifecycle closure is authorized by this handoff.

## Required physical-device matrix

Record device model, iOS version, build configuration, active schema/effective `t9` readiness, screenshots or short video, and PASS/FAIL for each row:

1. Press `MNO` once: the fixed path bar shows exactly `m / n / o` in order while the host contains marked composition only.
2. Press **选拼音** once: `m` becomes visibly selected; Chinese candidates refresh; no raw `m` is committed to the host.
3. Press **选拼音** again: selection moves to `n`; then `o`; the next press wraps to `m`.
4. Directly tap `m`, then `n`: each uses the same refinement behavior and preserves all three sibling choices.
5. With VoiceOver, each path is announced as a button; the active path is selected; **选拼音** reports the current value and “选择下一个拼音”.
6. After selecting `n`, press `GHI`: the `m/n/o` focus remains, `n` remains selected, and no host text commits.
7. Repeat around Delete, Chinese candidate commit, page switch, language switch, keyboard dismissal/reappearance, and Extension restart: no stale choice survives and no raw letter/digit leaks.
8. Exercise an unavailable/failed refinement if reproducible: prior marked composition, candidates, choices, and selected item remain coherent.
9. Compare keyboard height, path-bar reservation, hit targets, and key latency with the supplied native reference; record any visible jump, freeze, or multi-second delay.
10. Confirm **选拼音** never opens the predecessor full-path panel.

## Amendment A Manual Matrix

1. Fresh `MNO → GHI`: verify `mi / ni / m / n / o`, no selected path, and space title `选定`.
2. From retained `n + GHI`, tap an unselected sibling: verify only the tentative first-group value changes and the pending GHI input remains.
3. Tap the already selected `n`: verify no host commit, path bar becomes unselected `g / h`, and `i` is absent.
4. Press **选拼音** in the new focus: verify it selects/cycles `g / h` but never confirms merely by wrapping.
5. Press `选定`: verify highlighted/first Chinese candidate commits and focus clears; it must not act as segment confirmation.
6. From retained `n + GHI`, press Delete: verify it returns to `m / n / o` with `n` selected and exact marked spelling restored.
7. Repeat in light/dark mode and with VoiceOver; capture any latency/jank during selected-item confirmation separately.

## Decision flow

1. Independent Architecture and Quality review must be recorded first.
2. Quality evaluates this device evidence against Assignment exit/stop conditions.
3. Product Lead records Product Gate PASS, FAIL, or changes required.
4. Only after separate publication authorization may the Executor form a clean commit, rerun the Spike for clean-commit provenance, push, or open a PR.

## Related sources

- [`keyboard-layout-9key-pinyin-002.md`](keyboard-layout-9key-pinyin-002.md)
- [`keyboard-layout-9key-pinyin-002-review-handoff.md`](keyboard-layout-9key-pinyin-002-review-handoff.md)
- [`PD-KEYBOARD-LAYOUT-9KEY-PINYIN-002`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-002-authorization.md)
- [ADR 0021](../architecture/decisions/0021-t9-deterministic-single-key-choices-and-cycle-selection.md)
- [`RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md)
