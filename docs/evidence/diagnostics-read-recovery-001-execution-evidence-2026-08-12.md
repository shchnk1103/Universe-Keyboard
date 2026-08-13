# DIAGNOSTICS-READ-RECOVERY-001 Execution Evidence

- Evidence grade: `Executor-recorded`
- Date / timezone: `2026-08-12 Asia/Shanghai`
- Baseline: `origin/main` at `9a177aba23f2443eb837313174ef27b32af7b4d3`
- Branch / worktree: `codex/diagnostics-v1-read-recovery` / isolated `/private/tmp` worktree
- Toolchain: Xcode `27.0 (27A5237l)`, Swift 6 strict concurrency
- Simulator: `iPhone 17 Pro`, iOS `26.5`, UDID `900FB396-39BF-4A84-9E75-FF813C155FA7`
- Physical device: not used

## Scope Evidence

The tracked diff is limited to Main App diagnostics UI/source/store, their tests, and KOS/debugging/changelog records. No candidate-bar, Keyboard Extension input-path, RimeBridge, model G2, device-evidence or vendor source file is changed. Ignored RIME Vendor artifacts were copied read-only from the existing verified local inventory into the isolated worktree only to satisfy package linking.

## Validation

| Grade | Check | Result |
|---|---|---|
| `Executor-recorded` | `swift-format lint --strict` on five changed Swift files | Pass |
| `Executor-recorded` | `git diff --check` | Pass |
| `Executor-recorded` | RIME Vendor structural inventory and receipt verification | Pass, 12 artifacts |
| `Executor-recorded` | Targeted `DiagnosticsLogSourceTests` + `DiagnosticsStoreTests` on iPhone 17 Pro Simulator | Pass, 11 tests / 0 failures |
| `Executor-recorded` | Full `Universe Keyboard` scheme test on iPhone 17 Pro Simulator | Pass, Main App 156 + Keyboard 6 / 0 failures |
| `Executor-recorded` | Debug Simulator build with Swift 6 strict concurrency and warnings-as-errors | Pass |
| `Executor-recorded` | Release Simulator build with Swift 6 strict concurrency and warnings-as-errors | Pass; Xcode emitted a non-fatal dSYM precompiled-module path warning |

Targeted test result bundle:
`/private/tmp/universe-keyboard-diagnostics-read-recovery-derived/Logs/Test/Test-Universe Keyboard-2026.08.12_12-46-41-+0800.xcresult`

Full scheme result bundle:
`/private/tmp/universe-keyboard-diagnostics-read-recovery-derived/Logs/Test/Test-Universe Keyboard-2026.08.12_12-42-39-+0800.xcresult`

## Non-claims And Remaining Handoff

- This evidence was not independently re-run by Quality.
- No physical-device install, App Group observation, UI interaction capture, candidate-bar test or Release claim was performed.
- `KeyboardCore` and `RimeBridgeTests` were not separately re-run because their production sources were unchanged; the affected Main App scheme and both Debug/Release products were built, and the complete Main App/Keyboard test action passed.
- A future combined branch containing G2 changes must run its own merge-base validation; this isolated evidence does not validate G2.
