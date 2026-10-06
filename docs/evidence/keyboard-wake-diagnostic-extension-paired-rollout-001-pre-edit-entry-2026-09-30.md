# Paired Extension Rollout — Pre-edit Entry Receipt

## Identity

- Assignment: [KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001](../assignments/keyboard-wake-diagnostic-extension-paired-rollout-001.md)
- Assignment SHA-256 before this status writeback: `91b78be7d7fafe6688487bbd9c77eed946af1f114ede9fd9dca80ec790fba253`
- Assignment SHA-256 after lifecycle/history-only writeback: `8ad8edff7b3fa96ca47dab47f562bac6095984662ac85bde961ec35f1f3ecf9f`
- Worktree: `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`
- Branch / base: `codex/keyboard-wake-v3-compatibility-gate` / `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Compatibility candidate manifest r2 SHA-256: `c75a75bd8ed180149a7bc8cb6c26a5fa5e4f5cbec122eede980f73a4d8cef835`
- Separate implementation authorization: [authorization record](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-implementation-authorization.md)
- Product decision needed: [writer-version reconciliation brief](../plans/keyboard-wake-diagnostic-extension-writer-version-reconciliation-001.md)

## Frozen source and contract observations

All seven source/test files named in manifest r2 were rehashed in this worktree and **MATCHED** the manifest. This is a seven-file identity claim only; it does not claim whole-worktree equality or clean status.

| Manifest path | SHA-256 |
|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift` | `346efd59225cdf71fc61917fcb26bc72f3b1cf84aea19d873b3f238e791b492b` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift` | `49077a7a6ade1b41724fda92314cb4a41071163dc9f6c5e2a8666ee38273dbc9` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift` | `965667328c2db1cba4c4f99e21a82ee13ae3890ff18bf510b9967c5396273534` |
| `Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift` | `bc874c7f019645e18c04b8b2c3a9d21c8247afc75b44cc8951a857078d558a70` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift` | `7da854233e4454ccd44c587acca5cf8b4d4b89b15b726277748fa172da1e7c53` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift` | `8760b930ff9f1045f8689f73c2dddb33bf199b86d7246cc6dd6e50feb2af1ba5` |
| `UniverseKeyboardTests/DiagnosticsLogSourceTests.swift` | `ad24cef7d5512b621a53724b3b1043b29a5b1863ef163aa8de0e25b6e2fa855c` |

The manifest's `schema_contract` says the reader accepts versions 3, 4 and 5, the production writer is version 5, production v4 wake-marker emission is false, and test fixtures use isolated temporary or in-memory storage. The accepted v3 compatibility-gate Assignment also says not to add a production Extension wake-marker call site in that candidate.

The seven-file candidate agrees with the manifest's v5 contract:

- `DiagnosticEvent.schemaVersion` is `5` (`Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:7-8`). Neither `DiagnosticsJournalRuntime.swift` nor `DiagnosticsJournalIngress.swift` is included among manifest r2's seven files; the selector-bearing versions are only described in the separate, archived Runtime API candidate below.
- `DiagnosticEvent.isWritableV5` requires the current schema version and rejects the v4-only marker codes/payloads (`DiagnosticEvent.swift:1167-1173`). `DiagnosticsJournal.append` enforces that predicate (`DiagnosticsJournal.swift:326-335`).
- The decoder requires v4-only payload keys and marker codes to use schema version 4, and rejects them when labeled v3 or v5 (`DiagnosticEvent.swift:1257-1269`, `1314-1323`).
- ADR 0036 states that each writer build uses one static persisted schema version and forbids labeling v4-only data as v3 (`docs/architecture/decisions/0036-diagnostic-event-wire-v4-writer-compatibility.md:17-24, 29-32`).
- The separate Runtime Record API evidence describes an explicit `.v3` / `.v4` writer selector and typed marker APIs (`docs/evidence/keyboard-wake-diagnostic-runtime-record-api-001-implementation-2026-09-29.md:28-32`). Its ten-file candidate manifest is `abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c`, on older base `9eb83158e49218c1e8f75dbe7dd9e0390db81409`. The archived managed-worktree artifact is `01a0ed89-8853-7581-9d62-419f1e68fe78`; it was not restored, so source-byte revalidation remains open. The API candidate is not present in manifest r2.
- The Extension's existing `TypoCorrectionRecallCoordinator` records `.typoRecallQueryMeasured` and related events (`Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift:296-307, 344-356`), and `DiagnosticEvent` marks the typo-recall family as v5-only (`DiagnosticEvent.swift:1146-1165`). The paired-rollout Assignment requires Extension writer `.v3` in its compatibility candidate and `.v4` in a later promotion (`docs/assignments/keyboard-wake-diagnostic-extension-paired-rollout-001.md:61-66, 99-102`). Current evidence does not show how either writer mode preserves this v5-only Extension behavior while satisfying ADR 0036's static writer-version rule. Product/Architecture disposition and exact-candidate proof are required.

## Extension provenance and observable boundaries

The in-scope Extension source and `KeyboardTests/` are clean relative to this worktree's base commit. Current hashes are:

| Path | SHA-256 |
|---|---|
| `Keyboard/Controllers/KeyboardViewController.swift` | `8591c5d9c7b93530bb2c5eb2a3eb000a3c53bc8133183eaa3b9a48b1be147aa8` |
| `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift` | `e931105a51915084e90ef39270ebd3c3378b0d3e01dfe633d51f54293ff48db8` |
| `Keyboard/Services/UITextDocumentProxyAdapter.swift` | `f5cad10abb6b01594819cbb5dcf72a2989d389ed235364237abdfce7853b6de5` |

The historical five-file Extension patch still hashes to `c4998815078e790e1a14109ecefde8a3fb467f197c90eece5dbda20b4a7f7a8d` against its recorded base `9eb83158e49218c1e8f75dbe7dd9e0390db81409`; the adapter hash matches its recorded identity. This verifies historical provenance, not ownership or integration of that dirty patch into this worktree. It has not been copied or edited.

Existing boundaries support markers only where the Extension can observe them: `viewWillAppear` resumes diagnostic persistence and RIME visibility (`KeyboardViewController.swift:361-387`), `viewDidAppear` activates runtime after presentation (`421-433`), and `viewWillDisappear` records the presentation frame then suspends runtime (`436-464`). Bootstrap observes `.NSExtensionHostWillResignActive` and suspends (`KeyboardViewController+Bootstrap.swift:805-828`); no matching host-did-become-active observer was found, so that phase is unavailable. `UITextDocumentProxyAdapter` directly forwards `insertText`, `setMarkedText`, and `unmarkText` (`UITextDocumentProxyAdapter.swift:44-76`); a returned call cannot prove host display or insertion.

## Simulator and ownership

- The Assignment's historical target is iPhone 18 Pro / iOS 27.0, UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`.
- No fresh exclusive-use window has been recorded for this Assignment. No Simulator was booted, tested, installed to, or otherwise changed during this Entry pass.
- The current worktree contains the pre-existing manifest-r2 compatibility candidate and many pre-existing KOS edits. Those inputs were preserved. A fresh point-in-time source-writer ownership check and writer-owned work window remain required before any source edit.

## Entry disposition

The six exact-scope role ACKs/reviews remain bound to pre-status Assignment SHA-256 `f7e8304df7a9d8e56a6fa1387b9815410cccc21f52a0c87929f05b66be0ba6cb`; Architecture returned Pass with conditions and Quality returned PASS. The separate implementation authorization is now recorded. Existing call-boundary observability and the seven-file candidate identity are verified.

**Assignment remains Acknowledged / Not Ready.** Entry stops at the persisted-wire reconciliation: the paired Assignment specifies an Extension writer of `.v3` for compatibility and `.v4` for promotion, while the accepted candidate preserves schema-v5 Extension diagnostics and the reviewed Runtime API is only available as a separate archived input not yet revalidated/integrated with that v5 source. Existing Extension `typo_recall` events are v5-only. Product and Architecture must decide and prove how the paired writer contract preserves these events under the static-version rule before Ready/Active or source implementation. The historical API source revalidation, a fresh exclusive Simulator reservation, and a source-ownership recheck also remain open.

No source edit, formatting, test, build, Simulator operation, installation, marker emission, manual reproduction, commit, push, PR, merge, Gate, Release, or root-cause conclusion occurred in this Entry pass.

The seven changed Markdown records passed local-link and trailing-whitespace checks. This documentation check is not code-test or build evidence.
