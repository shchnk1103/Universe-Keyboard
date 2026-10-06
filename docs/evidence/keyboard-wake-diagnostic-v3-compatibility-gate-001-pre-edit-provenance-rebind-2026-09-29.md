# V3 Compatibility Gate — Pre-Edit Provenance Rebind

## Scope and identity

- Assignment: `KEYBOARD-WAKE-DIAGNOSTIC-V3-COMPATIBILITY-GATE-001`
- Current Assignment SHA-256: `d2d254dea05ec8fbadc8b7ff783b429e9097a5013877482b3440cfd79989f0f5`
- Product Authorization SHA-256: `600c9e0419d050912d59b8496bce592896cf75aa08ef48d07a215d28df63fe4e`
- Exact current source base and worktree `HEAD`: `84b9c19227330b0fe6ff391be001ee398010fd6a`
- Candidate branch: `codex/keyboard-wake-v3-compatibility-gate`
- Prior provenance record SHA-256: `ab43646343ae77ec014f2d405869eeb2beaef9cd350077acd1a42a9bdf38a1d4`; its Assignment SHA was `49638b87156ff489aa444307833e7a354259418818dd148762c60527c4b2fa2b`.
- This record rebinds the source/history provenance to the current lifecycle-only Assignment revision. It supplements, and does not rewrite, the earlier snapshot.

The Human Product Owner approved changing Entry Criterion 2 to require exact-base and historical-input provenance before source edits, with the integrated source/test manifest remaining an Exit Criterion. The Assignment SHA changed because of this pre-edit sequencing clarification and its status text; the accepted technical contract, source base, Product Authorization, historical input identities, and in-scope source/test identities did not change.

## Exact-base and current source/test identity

The managed candidate worktree is rooted at `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`. Its `HEAD` is the exact required base. `git diff --name-only` returned no tracked-file paths before implementation. The following current-base paths were rehashed and match the values in the prior provenance snapshot:

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

`DiagnosticEventWireValidator.swift` and `DiagnosticsJournalV4WriterTests.swift` remain absent from the exact base and are historical reference inputs only.

## Historical input verification

All predecessor candidates remain historical inputs based on `9eb83158e49218c1e8f75dbe7dd9e0390db81409`; none is treated as a new-base identity or a passing result for this candidate.

| Input | Revalidated identity | Read-only result and treatment |
|---|---|---|
| Runtime API | Ten-file source/test manifest SHA-256 `abbe6154d52b5b4e23fcde32cea455f2de93d9a3a56356ef77e12486217f975c` | Recomputed all 10 listed file hashes in the retained `runtime-record-api-impl` worktree; `mismatch_count=0`. Its `HEAD` remains `9eb83158…`. Reconcile its v3 default / explicit-v4 writer with current schema v5 before copying. |
| KeyboardCore reader | Five-file aggregate SHA-256 `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7` | Recomputed the aggregate from the five reviewed file hashes in the retained `keyboard-wake-diagnostics` worktree. Its `HEAD` remains `9eb83158…`. Preserve current schema-v5 and strict-reader boundaries when reintegrating. |
| Main App consumer | Two-file aggregate SHA-256 `5f46d25950eafc33adf7850c43986129e65ad7bab5701d25df3b32391001405a` | Recomputed the aggregate from the reviewed source/test paths in the retained `keyboard-wake-diagnostics` worktree. Its `HEAD` remains `9eb83158…`. Reprove current-candidate completeness and fallback behavior. |
| Extension instrumentation | Five-file patch digest `c4998815078e790e1a14109ecefde8a3fb467f197c90eece5dbda20b4a7f7a8d` | Recomputed the exact `git diff --binary 9eb83158… -- <five recorded controller paths>` digest in `keyboard-wake-diagnostics`. Do not transplant its production wake-marker call sites; preserve current-main source and keep markers off. |

Both predecessor worktrees remain dirty historical inputs and were inspected read-only. They were not edited, cleaned, archived, committed, or otherwise changed by this task.

## Entry applicability and remaining boundary

- The old provenance snapshot remains applicable because the Assignment correction only changed the pre-edit sequencing rule, all exact source/base/historical identities above remain equal, and the current Assignment still requires the same integration contract.
- This satisfies the source/provenance portion of Entry Criterion 2 before edits. The final integrated source/test manifest remains an Exit Criterion and must be newly generated for the candidate.
- The current worktree still contains no tracked source/test edits. This record does **not** establish that the worktree has exclusive writer/process ownership; that is a separate Entry Criterion to verify immediately before source edits.
- No code was edited; no tests, formatting, builds, Simulator operations, installation, network access, production marker emission, root-cause conclusion, Gate, Release, or parent closure occurred.
