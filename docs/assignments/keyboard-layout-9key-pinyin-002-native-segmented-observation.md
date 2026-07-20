# KEYBOARD-LAYOUT-9KEY-PINYIN-002 — Native Segmented Disambiguation Observation

**Status:** Product evidence input for Amendment A  
**Date / timezone:** `2026-07-19 Asia/Shanghai`  
**Environment:** Device Hub, iPhone 17 Pro Max Simulator, iOS 27.0, system 简体中文－拼音（九宫格）, Safari address field

This record preserves observed behavior without depending on temporary screenshots or conversation text. It is Product evidence, not proof that pinned librime has the same internal capability.

## Observed sequences

| Sequence | Precise-path bar | Selected path | Host marked/display value | Space title |
|---|---|---|---|---|
| `MNO` | `m / n / o` | none | context-selected default (`n` in this Safari run) | `选定` |
| `MNO → GHI` | `mi / ni / m / n / o` | none | `ni` in this run | `选定` |
| `MNO → 选拼音 → 选拼音` | `m / n / o` | `n` | `n` | `选定` |
| selected `n` → `GHI` | retained `m / n / o` | retained `n` | visually `n' h` | `选定` |
| tap already-selected `n` | `g / h` | none | remains segmented `n' h` | `选定` |
| press space/选定 | path bar clears after finalization | none | commits first Chinese candidate `你好` | returns `空格` |

## Conclusions

1. The native model separates whole-composition paths from focused segment choices.
2. Later digit input does not erase a tentative earlier segment.
3. Tapping the already-selected path is a confirm/advance gesture; it does not commit host text.
4. The next group is filtered (`g/h`, not mechanical `g/h/i`), so implementation needs live engine authorization rather than Cartesian key expansion.
5. Space/选定 is candidate finalization, not segment-focus confirmation.
6. Initial marked display is contextual and must not be treated as an implicit selected-path state.

## Tool limitation

XcodeBuildMCP semantic snapshot failed because the active Xcode beta lacks the expected `SimulatorKit.framework`. XcodeBuildMCP screenshots succeeded; interaction and accessibility inspection continued through the local Computer Use runtime. This limitation affects tooling only, not the captured system keyboard state transitions.
