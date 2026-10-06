# V3 Compatibility Gate — Pre-Edit Source Provenance

## Scope and identity

- Assignment: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Assignment SHA-256: `49638b87156ff489aa444307833e7a354259418818dd148762c60527c4b2fa2b`
- Product Authorization SHA-256: `600c9e0419d050912d59b8496bce592896cf75aa08ef48d07a215d28df63fe4e`
- Architecture R2 disposition: **Pass with conditions**, packet `6b2e01b4de0de7e6b003c584e52de3d1aa797f324a5e187b9abd7f394a7dc9c6`
- Quality R2 disposition: **Pass with conditions**, packet `1841350e16bf6c225a4cab66affc09e8e90f1d841df46d1ba1fb1c38b2ad693b`
- Exact source base: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Candidate branch: `codex/keyboard-wake-v3-compatibility-gate`

This is the read-only provenance snapshot before source edits. It is not the final candidate manifest or test evidence.

## Current-base source/test identities

The following in-scope inputs are unchanged in the dedicated worktree relative to exact base `84b9c19227330b0fe6ff391be001ee398010fd6a`:

| File | SHA-256 |
|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift` | `b67dbb084c6e7a3201e6b64e411532845df3fde2c1bee6f54462b022a0f3a534` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift` | `9c999e18645573da1519d0f84be0f83152e800a41b109783b5730788f7a4f005` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalIngress.swift` | `22df98f25a44704763e4669d60787c2157477a97587645645e5b10af3437a696` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift` | `9720d22bb3ec5668b7a9f466ac84c34d77c7a7ed2969da01b5c6f2568c41b406` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift` | `8846bdaafa0490bbc310d00c23ff09db9569dcbc59b26ba0715c9c290e0591be` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift` | `a712ec5b004af538346b63deac2ffad4980bb4d80c35a4c9c91fdaba8095820d` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalIngressTests.swift` | `15a5a39a318b1b73e24735f6258110dcba714a3dee337afecff29ff2c7ebb339` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalRuntimeTests.swift` | `67fd13af32f939613578feaef98e30675879f06bfcadd254723a7ac45b6cdd33` |
| `Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift` | `0d8efe45eb428d9ea05aa49bbf7dbebb83c7ab546fe11120c335a35a1447031c` |
| `UniverseKeyboardTests/DiagnosticsLogSourceTests.swift` | `aeb7e75c30614af255e0a224eaae422ac06527e75accccbb1db41510aff934af` |
| `Universe Keyboard/Views/Diagnostics/DiagnosticsStore.swift` | `5036ce52647b5d5383450b8b7e99e9b09d43c3cb308075aee967843c5073aed4` |
| `UniverseKeyboardTests/DiagnosticsStoreTests.swift` | `5374ae55fd68f9ac1aa3c0380e9f7e9e3763967d4988b1459cf9cefcb268d38f` |
| `Keyboard/Controllers/KeyboardViewController.swift` | `8591c5d9c7b93530bb2c5eb2a3eb000a3c53bc8133183eaa3b9a48b1be147aa8` |
| `Keyboard/Controllers/KeyboardViewController+Bootstrap.swift` | `e931105a51915084e90ef39270ebd3c3378b0d3e01dfe633d51f54293ff48db8` |
| `Keyboard/Services/UITextDocumentProxyAdapter.swift` | `f5cad10abb6b01594819cbb5dcf72a2989d389ed235364237abdfce7853b6de5` |

`DiagnosticEventWireValidator.swift` and `DiagnosticsJournalV4WriterTests.swift` are not present in the exact base; their historical versions are reference inputs only.

## Historical inputs and revalidation limits

| Input | Historical identity | Historical base | Treatment in this candidate |
|---|---|---|---|
| Runtime API | Canonical ten-file manifest `abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c` | `9eb83158e49218c1e8f75dbe7dd9e0390db81409` | Manifest's ten file hashes were recomputed and matched in the retained worktree. Reintegrate only after reconciling its v3 default / explicit-v4 writer with current schema v5; the current candidate must preserve production v5. |
| KeyboardCore reader | `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7` | `9eb83158e49218c1e8f75dbe7dd9e0390db81409` | Reviewed implementation is historical input only; extend/rebind it for v5 and v3/v4/v5 per-record compatibility. |
| Main App consumer | `5f46d25950eafc33adf7850c43986129e65ad7bab5701d25df3b32391001405a` | `9eb83158e49218c1e8f75dbe7dd9e0390db81409` | Reviewed consumer is historical input only; prove current candidate fallback behavior and query completeness. |
| Extension instrumentation | Five-file patch `c4998815078e790e1a14109ecefde8a3fb467f197c90eece5dbda20b4a7f7a8d` | `9eb83158e49218c1e8f75dbe7dd9e0390db81409` | Do not transplant production wake-marker call sites. The old paired-rollout contract explicitly selected writer v3, which would contradict the current v5 production writer. Preserve current-main Extension changes and current v5 event behavior. |

Both predecessor worktrees remain dirty and are retained as historical inputs. Read-only status showed their original base at `9eb83158…`; no source files, statuses, commits, or documents in those worktrees were changed by this task.

## Integration boundary

- Current production `DiagnosticEvent.schemaVersion` remains v5 and existing Extension/Main App diagnostics remain on that writer contract.
- Reader code validates retained v3, v4, and v5 records individually. Strict raw-key validation remains in the `DiagnosticsJournalReader` boundary.
- Do not introduce a production wake-marker call site. Use raw, content-free JSON fixtures in isolated tests; do not route v4 fixtures through production App Group storage, `DiagnosticsJournalRuntime`, or real Extension ingress.
- Main App consumes query-wide completeness and suppresses legacy fallback except for a known-complete empty v1 journal result.
- Preserve `typo_recall` lifecycle/current-main changes in the Extension; do not overwrite or reformat them using the historical patch.

## Worktree and writer check

- `HEAD` and branch matched the identities above.
- No tracked source or test file had a diff before implementation. The worktree contains copied historical input documents and the new Assignment/review artifacts as untracked documentation; these are recorded inputs and must be preserved.
- R1/R2 reviewers and domain consultants performed read-only work. No other agent was assigned source edits in this worktree. The primary checkout and both predecessor worktrees remain untouched.
- This provenance record does not claim the final candidate is clean, implemented, validated, or ready for promotion.
