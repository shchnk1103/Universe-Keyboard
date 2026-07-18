# KEYBOARD-LAYOUT-9KEY-PINYIN-001 — Keyboard Extension Startup Crash Fix Record

Reviewer / fixer: Codex  
Date / timezone: `2026-07-19 Asia/Shanghai`  
Branch: `feature/keyboard-layout-9key-pinyin-001`  
Baseline HEAD: `44d42130bd8e2012bce7b4c034c4bc51a149dec3` (dirty worktree preserved)

## Scope And Status

This is an independent diagnostic and repair record for the reported failure: after selecting the nine-key keyboard and attempting input, the Keyboard Extension crashed and could no longer start.

- Assignment remains **`Active`**.
- Product Gate remains **Open**.
- This simulator regression result does not replace the physical-device matrix in the Human Dependency handoff.
- No commit, push or PR was performed.

## Reproduction Evidence

Environment: iOS 27.0 Simulator, iPhone 17 Pro Max, UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`.

Two consecutive extension launches produced:

- `Keyboard-2026-07-18-235207.ips`
- `Keyboard-2026-07-18-235212.ips`

Both reports contained main-thread `EXC_BREAKPOINT` / `SIGTRAP` with the same project stack:

1. `KeyboardViewController.shouldReserveT9PinyinPathBar.getter`
2. `KeyboardViewController.preferredKeyboardHeight.getter`
3. `KeyboardViewController.installPreferredKeyboardHeight()`
4. `KeyboardViewController.bootstrapKeyboard()`
5. `KeyboardViewController.viewDidLoad()`

## Root Cause

`bootstrapKeyboard()` installs the preferred-height constraint before constructing `KeyboardController`. The new `shouldReserveT9PinyinPathBar` computed property dereferenced the controller's implicitly unwrapped optional state during that pre-controller window.

The result was deterministic: every extension relaunch reached the same getter during `viewDidLoad` and trapped before the keyboard surface could appear. This is a Keyboard UI lifecycle-ordering defect, not a RIME session, App Group or user-input-data failure.

## Fix

`shouldReserveT9PinyinPathBar` now fails closed when the controller has not been installed. Before Core initialization, height calculation reserves no T9 path bar and therefore uses the ordinary 26-key bootstrap surface. Once Core exists, the existing Chinese + letters + nine-key + readiness conditions remain unchanged.

A gated XCUITest was added for the exact regression path: activate Universe Keyboard from a known Apple keyboard baseline, locate the T9 `MNO` / digit-6 key, tap it, and assert that the key and host app remain present. Normal CI skips this environment-dependent test unless a reviewed T9 runtime and matching readiness marker are installed.

## Verification

| Check | Result |
|---|---|
| Debug Simulator build/install after production fix | **Pass** |
| Focused `testNineKeyFirstInputCrashRegression` | **Pass** — 1 passed, 0 failed, 0 skipped |
| First `MNO` input keeps Keyboard Extension alive | **Pass** |
| New `Keyboard-*.ips` after fixed regression run | **None observed** |
| Release Simulator build, `Universe Keyboard` scheme | **Pass** |
| `git diff --check` | **Pass** |
| Physical-device Product Gate matrix | **Not run; still required** |

Focused result bundle:

`~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-07-18T16-10-40-234Z_pid1923_fe814896.xcresult`

## Handoff

Install the fixed build on the physical device, re-enable/select Universe Keyboard if iOS fell back after the repeated crashes, and first verify keyboard activation plus one `MNO` input. If that smoke check passes, continue the full matrix in `keyboard-layout-9key-pinyin-001-product-gate-human-handoff.md`. Do not mark Product Gate Pass from this simulator record alone.
