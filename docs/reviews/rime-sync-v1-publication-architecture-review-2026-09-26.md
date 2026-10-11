# RIME-SYNC-001 publication Architecture review — 2026-09-27

## Decision

**Accept with conditions.** The independent Architecture lane completed A1–A5
for the bounded iOS V1 local-folder publication candidate after the exact A4
test result was reconfirmed in a narrowly authorized round-5 continuation.
This Architecture conclusion is not a Quality substitute, merge approval,
TestFlight approval or Release decision.

## Reviewed identity

| Field | Value |
| --- | --- |
| Work item / lane / final round | `RIME-SYNC-001` / `RIME-SYNC-001/publication-20260926/architecture` / `5` |
| Branch / base | `codex/rime-sync-v1-local-folder-pr` / `9838c092672dae60c63b34e4d9be6dffafc3869f` |
| Candidate at review | 79 staged paths; full staged diff SHA-256 `add6e4421963a426e7a210c2bc970b4a42eaa3fbf79fbc3379915e9d5a280785` |
| Implementation/test/workflow scope SHA-256 | `a6f99ceca98a7c1331f7289efd3847a4f6a886e5a9f562f052c678ac96e3f284` |
| Base packet SHA-256 | `2a8aa3fb3f917d73b150b7bc796754c61da1a51ffe61b507aaa5089b0cdbd741` |
| Round-5 A4 supplement SHA-256 | `7f7f9b56606f0947f345af21c7d858dcff74acab006224a57a6113a975ab8c37` |
| Complete round-5 packet SHA-256 | `6f6819e2249c211cf5d0a574b10433965939ea05478c6600bff9052032da876b` |

The reviewed candidate identity is the pre-receipt 79-path tree. This receipt
was recorded by the coordinator after review and is not represented as part of
the Architecture review target.

## Coverage and A4 confirmation

| Criterion | Result |
| --- | --- |
| A1 — exact branch, base, staged candidate identity and scope | Covered. The final bounded continuation confirmed the authorized branch and frozen candidate identity. |
| A2 — Main App sync/deployment ownership, Extension boundary and process gate | Covered. The process gate does not resolve cross-process `TD-002`. |
| A3 — Security.framework Keychain denial, recovery guidance and distinct persisted diagnostic | Covered. |
| A4 — remote deletion, partial local Keychain cleanup and retry semantics | Covered. The exact test `RimeSyncModelTests/testRemoteDeletionReportsPartialKeychainCleanupAndCanBeRetried()` has `testStatus=Success`, 0 failure summaries, in `Universe-Keyboard-keychain-terminal-final.xcresult`; suite total is 420, with 410 passed, 10 skipped and 0 failed. |
| A5 — Assignment-close decision, M-03 dispositions, CloudKit exclusion and retained debts | Covered; all limitations and debt dispositions below remain in force. |

The A4 result was read from the existing result bundle with the read-only
legacy `xcresulttool` object interface because the newer test-report command
attempted to write inside the result bundle and was denied. No test was rerun
for this confirmation. The reviewer used **9/15 calls and about 2–3/15 active
minutes** under the Human Product Owner's explicit round-5 budget.

## Conditions and residual dispositions

| Residual | Disposition / boundary |
| --- | --- |
| `QR-PROVIDER-DELETE-01` | Keep `fix` scoped to the recorded single Simulator Apple Files LocalStorage observation; owner areas remain Main App / Quality / Architecture. Fake transport does not establish real WebDAV or provider propagation. |
| Manual action/capture correlation, Files UI refresh and installed-binary provenance | `accept` as bounded evidence limitations; do not promote them to automated or source-bound proof. |
| Original provider-deletion UI XCTest | `accept` as a reporting boundary; preserve **1 failed / 0 passed**. |
| `QR-CURRENT-01` | `accept` for exact documented runs only; the XcodeBuildMCP cause and future-run accuracy remain unknown. |
| UI-02 narrow-device/source-binding limits | `accept` within the bounded V1 scope; not a full accessibility-conformance claim. |
| Run 02 `INVALID` | `accept` only as an invalid historical record; preserve the original `HOLD`. |
| `TD-002`, `TD-008`, `TD-013`, `TD-017`, `TD-019` | Retain as open `tech_debt:<ID>` items with existing severities and owners; none is resolved by this review. In particular, `TD-002` remains an open High risk. |
| UI-01, SEC-01 and stable diagnostic mapping | Keep the existing scope-specific `fix` dispositions and evidence; do not expand their claims beyond their documented scope. |
| CloudKit / iCloud | Deferred and outside the accepted iOS V1 local-folder scope. |

Pointers and authoritative dispositions are in the [Assignment close decision](../product-decisions/RIME-SYNC-001-ASSIGNMENT-CLOSE-2026-09-25.md), [local-folder/WebDAV scope decision](../product-decisions/RIME-SYNC-001-LOCAL-FOLDER-CLOSURE-WEBDAV-DEFERRED-2026-09-24.md), [technical-debt register](../TECH_DEBT.md), and the evidence/review links recorded there.

No live WebDAV, provider propagation, cross-platform portability, CloudKit,
physical-device provider deletion, merge, TestFlight or Release result is
claimed. The final Architecture disposition supports the already authorized
commit, push and PR preparation only after local gates pass.
