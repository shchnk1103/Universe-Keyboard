# Final Candidate Rebind: KEYBOARD-WAKE-DIAGNOSTIC-RUNTIME-RECORD-API-001

## Purpose and disposition

This receipt records the post-acceptance identity rebind and read-only pre-implementation preflight. It does not advance the Assignment lifecycle or authorize implementation.

| Role | Disposition | Boundary |
|---|---|---|
| Domain Owner — Input Intelligence Maintainer | **ACKNOWLEDGED — Pass with conditions** | Scope and ownership remain unchanged; no new scope blocker. |
| Architecture Reviewer — Architecture & Knowledge Steward | **ACKNOWLEDGED — Pass with conditions** | Conditional ADR contract and residual gates remain intact. |
| Quality Reviewer — Quality, Performance & Release Maintainer | **ACKNOWLEDGED — Pass with conditions** | Documentation identity rebind only; no implementation verification or Gate. Dirty source/test ownership remains unresolved. |
| Executor — current Codex task | **ACKNOWLEDGED** | Read-only candidate and source/test identity preflight completed; no code or runtime operation. |

## Reviewed document candidate

The reviewers bound their conclusions to these exact current file identities:

| Document | SHA-256 |
|---|---|
| ADR 0036 | `f950e4ee62c643efb21308cd7d633844379cb373fcde2e3e5604e5988fe5959c` |
| Runtime Record API Assignment | `1c1acea3c45e2a5026b9d0ce7605634d3ce5e420b2273079dcd7575b64fa3a14` |
| Writer Product Decision | `1ee751d4d87396ae5fad13e669b95daa3c46f1db648783fc99fe6f2c137ae206` |
| ADR 0036 acceptance decision | `3926918c0ae5f7aa0704f1696d75bbd32dfc1b32fd0895225bc49bcd9dc5035d` |
| Extension Producer Reassigned record | `d375fb41db63d97696e4382a12d1b8ce89efec4c90b8a70725078d3d9b46818c` |
| Parent lifecycle Assignment | `af1afd06c59a81e5cf542c3a23d6363551f7331dae3a9b27fea676855818ba05` |
| `docs/ACTIVE_WORK.md` | `61b0d56a24d932da865410b791225acdd24f78ae264ae6d24e5ce4d907929133` |
| ADR acceptance evidence | `c4e12e3ade168a94aa4a33adfea082de7143f96014074b1ba564bb915fccf54b` |

The Architecture and Quality dispositions remain conditional. Human Architecture Authority and Product Lead acceptance is recorded separately; none of these reviewer dispositions transfers implementation authority.

## KeyboardCore source and test identity snapshot

Worktree `HEAD` was `9eb83158e49218c1e8f75dbe7dd9e0390db81409`. These hashes describe the working tree at preflight time; changed files were not edited by this preflight.

| File | Worktree state | `HEAD` SHA-256 | Current SHA-256 |
|---|---|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift` | Modified | `1bd22fde04849e6a5f85ebc2750e80b7888931a3dc9a9e59c1aef3376ead3613` | `331f57ad6a55c6ceb041d30cf325a6a8bcd94b54dcf23553b22e67a99e90ce2b` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEventWireValidator.swift` | Untracked | — | `554f06386f845e938b25926c6f62f81f5e75b488765a1367ab7f45ca591e8442` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift` | Modified | `9c999e18645573da1519d0f84be0f83152e800a41b109783b5730788f7a4f005` | `c5a050217c6e02ba720d90e5a6298eadb7ab76f814c177be4049a4a5631402f0` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalIngress.swift` | Clean | `22df98f25a44704763e4669d60787c2157477a97587645645e5b10af3437a696` | `22df98f25a44704763e4669d60787c2157477a97587645645e5b10af3437a696` |
| `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift` | Clean | `9720d22bb3ec5668b7a9f466ac84c34d77c7a7ed2969da01b5c6f2568c41b406` | `9720d22bb3ec5668b7a9f466ac84c34d77c7a7ed2969da01b5c6f2568c41b406` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticEventTests.swift` | Modified | `89e60f281385a447a2475e1866325cfcaa8ec3dd134356c159ff6b47cd4d6a30` | `9ce72314f26fc308e92c459ee51672873490b73aa86d29296dddd8320ddebfb8` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalTests.swift` | Modified | `a712ec5b004af538346b63deac2ffad4980bb4d80c35a4c9c91fdaba8095820d` | `5e34af66516746a04c2e3dd560a404240a90a427c8c14656252457bff25cf947` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalIngressTests.swift` | Clean | `d2bcf72ea11831becbdc282975aaab66ec1b19df0fea7620f7d91d68aa2c49d6` | `d2bcf72ea11831becbdc282975aaab66ec1b19df0fea7620f7d91d68aa2c49d6` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/DiagnosticsJournalRuntimeTests.swift` | Clean | `ce92f25fd0d0666582217c78cd233615e18c78c65f3036fe78d77ccdf66459f0` | `ce92f25fd0d0666582217c78cd233615e18c78c65f3036fe78d77ccdf66459f0` |

The five modified/untracked reader files exactly match the independently reviewed KeyboardCore reader candidate `c752ffe96743bca3df96d54dccdce2d2be2e59e186c85125b0b0c21174787ed7` in [its evidence record](../evidence/keyboard-wake-diagnostic-reader-implementation-001-2026-09-28.md). The nine-file identity manifest above is `fa81f49c83596a741daed20ecd56094e2a6d629a44cc67ad4eaa3ec541f338f4`, computed over path-sorted records of `path\0current-SHA\0worktree-status\0HEAD-SHA-or-UNTRACKED`, joined with newline and terminated with newline.

## Read-only findings and remaining Entry Criteria

- `DiagnosticsJournalRuntime.record` currently constructs the v3 `DiagnosticEvent` and sends it to `DiagnosticsJournalIngress.record`; that ingress is bounded and schedules its flush asynchronously.
- `DiagnosticEvent.schemaVersion` is still `3`; the constructor rejects v4-only codes, and `DiagnosticsJournal.append` still requires every event to satisfy `isWritableV3`. The three new typed lifecycle/resume/text-proxy submission methods are not present in the current Runtime API candidate.
- No active Codex task in the task-list snapshot showed this isolated worktree as its working directory. The dirty files match the completed reader candidate, but the snapshot does not establish a writer handoff or prove ownership of all local processes. Quality therefore retains exclusive writer ownership as an unresolved pre-implementation condition.
- The modified `DiagnosticEventTests.swift` and `DiagnosticsJournalTests.swift` remain protected. The Assignment requires isolated test coverage or an explicit writer handoff before either file is edited.
- Source/test hashes were revalidated, but a fresh implementation baseline and exclusive writer ownership are not yet authorized. Existing ingress routing was confirmed; the future typed methods still need to demonstrate that they submit through that ingress.

| Entry Criterion | Result |
|---|---|
| Exact final document acknowledgments | Rebound by Domain Owner, Executor, Architecture and Quality to the document candidate above. |
| Conditional ADR 0036 acceptance | Satisfied; recorded separately. |
| Separate implementation authorization | **Not satisfied.** |
| Exact source/test baseline and exclusive writer ownership | Hashes captured; ownership/handoff remains **unresolved**. |
| Typed methods use bounded ingress | Existing generic path confirmed; new typed methods do not yet exist, so implementation behavior remains **unverified**. |

The Runtime Record API Assignment remains **Assigned / Not Ready / Not Active**. No code, test, build, Simulator, installation, v4 event emission, paired-build rollout, Product/Quality Gate, Release decision, commit, push or parent closure occurred in this preflight.
