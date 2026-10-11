# C1 KeyboardCore author handoff

本交接记录仅说明 scratch 五文件作者实现及其范围内验证；不是独立 Quality / Architecture review，也不是 Gate、Product 或 Release 结论。

## 输入与写入边界

- Repository identity recorded by the coordinator: `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`, `HEAD 84b9c19227330b0fe6ff391be001ee398010fd6a`, branch `codex/keyboard-wake-v3-compatibility-gate`.
- Only the following five files were written, under `/private/tmp/ukey-wake-c1-20260930/KeyboardCore`:
  - `Sources/KeyboardCore/DiagnosticEvent.swift`
  - `Sources/KeyboardCore/DiagnosticsJournal.swift`
  - `Sources/KeyboardCore/DiagnosticsJournalIngress.swift`
  - `Sources/KeyboardCore/DiagnosticsJournalRuntime.swift`
  - `Tests/KeyboardCoreTests/DiagnosticsJournalV6WriterTests.swift` (new)
- No repository checkout files were edited. No Git mutation, Simulator, App Group, or real app was used.

## Implementation notes

- Preserved `DiagnosticEvent.schemaVersion == 5`, the existing public event initializer, `isWritableV5`, and v5 as the default for the public finite `DiagnosticsJournalWriterVersion` selector across Runtime → Ingress → Journal.
- Explicit `.v6` normalizes new v5 ordinary events and valid v6 events only. It rejects decoded historical v3/v4 inputs. The Journal performs the existing strict wire validation on v6 encoded lines before filesystem writes; existing generic-field value semantics remain unchanged.
- Added typed v6 wake marker submission for keyboard lifecycle, RIME resume, and text-proxy operation. These are Extension/v6-only, use fixed code/level/category and empty generic fields, validate the RIME failure pair, and block marker codes in the generic Runtime path. `recordTextProxyOperation` accepts optional `actionSequence` and carries it through without synthesizing one. Return values indicate ingress submission attempts, not persistence.
- The focused integration test covers deferred suspend health, typo-recall query measurement, Scheme delivery, runtime route, RIME sync, all three marker families including RIME start/failure, action sequence and nonnil appearance identity preservation, unique local sequences 2...11 after one suspended drop, and `UInt64.max` session epoch round-trip. It reads mixed v3/v4/v5/v6 history and verifies retained v3/v4 segment bytes remain unchanged. Additional cases reject v3/v4 rewrite attempts and a decoded invalid route payload before file creation; the strict raw wire validator rejects an unknown generic-field key.

## Verification evidence

- Strict formatting passed for all five files. Logs: `/private/tmp/ukey-wake-c1-20260930/swift-format-c1-corrected-format.log` and `/private/tmp/ukey-wake-c1-20260930/swift-format-c1-corrected-lint.log`; corresponding exit files both contain `0`.
- Final focused scratch-package command: `/private/tmp/ukey-wake-c1-20260930/focused-test-c1-corrected-command.txt`.
- Full output: `/private/tmp/ukey-wake-c1-20260930/focused-test-c1-corrected.log`; exit: `/private/tmp/ukey-wake-c1-20260930/focused-test-c1-corrected-exit.txt` (`0`). Result: `DiagnosticsJournalV6WriterTests`, 3 tests, 0 failures.
- The first focused attempt is preserved in `/private/tmp/ukey-wake-c1-20260930/focused-test-command.txt`, `/private/tmp/ukey-wake-c1-20260930/focused-test.log`, and `/private/tmp/ukey-wake-c1-20260930/focused-test-exit.txt` (`1`). That test incorrectly assumed a rejected write had already created `g1/open`; the writer correctly rejected the event before creating the directory. The assertion was corrected and the final focused run passed.
- The focused command used the scratch package build path but did not redirect SwiftPM config/security/module-cache paths. Its log reports those user-level paths as inaccessible or read-only. It does not establish full cache isolation; the coordinator owns the full-host run and its explicit path isolation.
- Full KeyboardCore suite, Xcode host targets, Simulator tests, and full-host validation were not run by this subagent; the coordinator owns the next validation stage.

## Final SHA-256 (scratch files)

| Path | SHA-256 |
| --- | --- |
| `Sources/KeyboardCore/DiagnosticEvent.swift` | `e6aa39532653eb62af41ff62d2caca8af2984a79f841a849aeb36249ce33c235` |
| `Sources/KeyboardCore/DiagnosticsJournal.swift` | `ba85bd454b3fa5b9765513cb3b3c4d54dbfc2f23f60dc456d4795cfae6e894ac` |
| `Sources/KeyboardCore/DiagnosticsJournalIngress.swift` | `097f888e7d3ca91b98fcb943d9ce007cb3caee47ec452c3dacec5b1b7bc9040c` |
| `Sources/KeyboardCore/DiagnosticsJournalRuntime.swift` | `d694e226522930e585553818a58591a8a3733818ccdda7545bf1a62bcec73329` |
| `Tests/KeyboardCoreTests/DiagnosticsJournalV6WriterTests.swift` | `6a57819ac4a5de73c23e1d29f8488c0129f40d35014ed3509e46047b55c18af2` |
