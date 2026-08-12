# DIAGNOSTICS-DAY-BROWSER-001 Execution Evidence

- Evidence grade: `Executor-recorded`
- Date / timezone: `2026-08-12 Asia/Shanghai`
- Baseline: `origin/main` at `9a177aba23f2443eb837313174ef27b32af7b4d3`
- Branch / worktree: `codex/diagnostics-v1-read-recovery` / isolated `/private/tmp` worktree
- Toolchain: Xcode `27.0 (27A5237l)`, Swift 6 strict concurrency
- Simulator: `iPhone 17 Pro`, iOS `26.5`, UDID `900FB396-39BF-4A84-9E75-FF813C155FA7`
- Physical device: not used

## Scope Evidence

The implementation is limited to KeyboardCore diagnostics reading, Main App diagnostics source/store/view, their tests, and KOS/changelog records. It does not modify RimeBridge source, Keyboard Extension candidate/input code, the Wanxiang G2 work, writer format, retention, generation clear, privacy fields, or device evidence. Existing ignored RIME Vendor artifacts were used only for local linking.

## Validation

| Grade | Check | Result |
|---|---|---|
| `Executor-recorded` | `swift-format lint --strict` on all changed Swift files | Pass |
| `Executor-recorded` | `git diff --check` | Pass |
| `Executor-recorded` | Targeted `DiagnosticsJournalTests` | Pass, 22 tests / 0 failures |
| `Executor-recorded` | Full `KeyboardCore` suite | Pass, 976 tests / 0 failures |
| `Executor-recorded` | Targeted `DiagnosticsLogSourceTests` + `DiagnosticsStoreTests` | Pass, 12 tests / 0 failures |
| `Executor-recorded` | Full `Universe Keyboard` scheme test | Pass, Main App 157 + Keyboard 6 / 0 failures |
| `Executor-recorded` | `RimeBridgeTests` | Pass, 57 tests / 0 failures / 20 environment-gated skips |
| `Executor-recorded` | Debug Simulator build, Swift 6 strict concurrency, warnings-as-errors | Pass |
| `Executor-recorded` | Release Simulator build, Swift 6 strict concurrency, warnings-as-errors | Pass |

Targeted Main App result bundle:
`/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-emxsvllcocrspwdtwulsntweaomy/Logs/Test/Test-Universe Keyboard-2026.08.12_13-16-43-+0800.xcresult`

Full scheme result bundle:
`/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-emxsvllcocrspwdtwulsntweaomy/Logs/Test/Test-Universe Keyboard-2026.08.12_13-22-37-+0800.xcresult`

RimeBridge result bundle:
`/Users/doubleshy0n/Library/Developer/Xcode/DerivedData/Universe_Keyboard-emxsvllcocrspwdtwulsntweaomy/Logs/Test/Test-RimeBridgeTests-2026.08.12_13-18-41-+0800.xcresult`

## Non-claims And Remaining Handoff

- This evidence was not independently re-run by Architecture or Quality and does not accept ADR 0028.
- No physical-device installation, App Group observation, UI screenshot review, timezone-change interaction, candidate-bar test, G2 validation, merge, or Release claim was performed.
- The partial recent window is intentionally incomplete and has no older-page cursor. Complete deep pagination for arbitrarily large single-day history remains a future disk-index/external-merge design.
- A future combined branch containing G2 changes must run its own merge-base and integrated validation; this isolated evidence does not validate or alter G2.
