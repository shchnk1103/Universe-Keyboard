# Product Decision: KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001

## Current Status

| Field | Value |
|---|---|
| Lifecycle | **Recorded — v6 contract accepted** |
| Current phase | The Human Product Owner accepted the reviewed v6 recommendation. ADR 0036 Addendum 002 is now **Accepted; implementation pending** after exact Architecture R7 and Quality R5 reviews. The paired-rollout Assignment remains **Assigned / Not Ready** pending current-scope role rebind and its stage-specific Entry conditions. |
| Material non-claims | No implementation, build, test, Simulator, installation, production marker emission, Product/Quality Gate, Release, root-cause conclusion, or parent closure is authorized or claimed. |
| Next handoff | Rebind the paired-rollout Assignment to the accepted v6 contract; complete exact-scope role ACKs, fresh writer-v5 stage authorization, source/provenance/ownership checks, and an exclusive Simulator reservation before source work. A future v6 implementation and production promotion need separate exact-candidate authorizations and reviews. See the [M-02 state-sync receipt](../evidence/keyboard-wake-diagnostic-wire-version-reconciliation-001-adr-0036-addendum-002-state-sync-2026-09-30.md). |
| Residuals | ENTRY-ID-DRIFT-01 is accepted only as exclusion of the erroneous historical identity row. Before v6 promotion, resolve the reader/fallback matrix, duplicate-JSON-member disposition, paired Entry rebind, and version-bound Maps dependency; see Architecture R7 and Quality R5 reviews. |

---

## Authority and decision source

- **Decision maker:** Human Product Owner / Product Lead in the current Codex task.
- **Decision date:** 2026-09-30 Asia/Shanghai.
- **Parent:** [KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001](../assignments/keyboard-wake-lifecycle-diagnostics-001.md).
- **Assignment:** [KEYBOARD-WAKE-DIAGNOSTIC-WIRE-VERSION-RECONCILIATION-001](../assignments/keyboard-wake-diagnostic-wire-version-reconciliation-001.md).
- **Decision source:** After being asked to choose between the recommended v6 contract, extending v5, or keeping production markers off pending another decision, the Human Product Owner replied: “可以按照你的最建议的方案继续下一步，之后也继续汇报进度。” This is recorded as selection of the recommended v6 contract and authorization to document that selection within the bounded reconciliation Assignment.

## Exact reviewed candidate

- Proposal candidate SHA-256: 3962a2f9bac051737319666775cd560c2730d776e89a141ae1ee8bcdfc71a9ed.
- Architecture R6 packet SHA-256: b5042e18752e6d920c9cf0be09d7f601416e66f827d91b137adaa9dc9953e778.
- Architecture R6 review SHA-256: 20d861d81585c490588676e858725c1851a8183654efc5ed49d18d0dfd611af5 (**Pass with conditions**).
- Quality R4 packet SHA-256: fc7afe2d3bdfc469b7df6b166c26ddcc12ffbb116f770e4bd8c35f44f9d9e579.
- Quality R4 review SHA-256: 3a64f5084818a1dcc9d7dfedc6caed26851ca4947c1019adc8509674955891fc (**Conditional / Pass with conditions**).
- Assignment reviewed-scope SHA-256: edf450b3dbfbe621849d0fbf6bc641518cbc22e992fde6239034d05d2e7729c6.
- Baseline: 84b9c19227330b0fe6ff391be001ee398010fd6a.

The accepted product contract is bound to the reviewed proposal candidate above. The addendum and paired-rollout update may clarify and route that contract, but must not materially change it. A material change requires a new exact-candidate Product disposition.

## Accepted product contract

The Human Product Owner accepts the proposal's forward **wire v6** contract for a future wake-marker-enabled paired build:

1. Every newly persisted event from a v6 writer build uses schemaVersion 6, including existing event families such as typo_recall and all wake markers. Production per-code version mixing is prohibited.
2. A v6 reader validates and reads retained v3, v4, v5, and v6 records against each record's own version. It must accept v6-labeled typo_recall and marker payloads while preserving retained v5 typo_recall and v4 marker records in their original versions and bytes.
3. Retained history is never relabeled or rewritten. Unknown, future, malformed, or rejected records remain bounded incomplete/unsupported state; valid neighboring records remain available; incomplete state suppresses legacy fallback.
4. The existing schema-v5 compatibility candidate remains a separate producer-off candidate. It does not validate or promote a future v6 candidate.
5. A future v6 marker-enabled build requires a new exact source/test baseline, same-build Main App + Keyboard Extension identity, full target validation, independent exact-candidate Architecture and Quality review, separate implementation and promotion authorization, and a fresh exclusive Simulator reservation before Simulator validation or installation.

## Conditions carried forward

| ID | Owner | Disposition | Requirement |
|---|---|---|---|
| ENTRY-ID-DRIFT-01 | Paired-rollout Executor / Product Lead | accept narrowly | Exclude the historical one-character DiagnosticEventTests.swift hash transcription error from current identity and integration proof. The current source and manifest hashes matched; the old row is not repaired or used as current evidence. |
| v6 reader/fallback matrix | Future KeyboardCore and App & Data Operations implementation owners | fix | Add direct v6-only and mixed v5/v6 source-selection coverage with legacy text present, rejected-only history, unknown raw keys, malformed payloads, and incomplete propagation before any promotion. |
| Duplicate JSON member detection | Future KeyboardCore / Input Intelligence implementation owner | fix or exact Product disposition | Use a parser that detects duplicates or document the selected parser limitation before claiming closed-object enforcement. |
| Older-reader behavior | Future paired-rollout owner | accept as non-claim | Do not claim arbitrary installed v3/v4/v5 readers safely consume v6; require a same-build writer/reader gate. |

## Explicit non-authorization

This decision accepts the wire-version contract and authorizes the bounded ADR/Assignment documentation follow-through. It does **not** authorize source or test edits, builds, Simulator operations, installation, App Group mutation, production marker emission, manual Maps reproduction, commit, push, PR, merge, Product/Quality Gate, Release, root-cause claims, or closure of the parent Assignment. The pre-revision paired-rollout implementation authorization was for a writer-v3 compatibility-gate candidate and was held at Entry; it does not apply to the revised scope or a future v6 candidate.
