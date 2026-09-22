# Authorization: AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-001

## Current Status

| Field | Value |
|---|---|
| Status | `superseded — unconsumed; exact source snapshot changed before capture; do not reuse` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Scope | Diagnostic paired baseline/treatment comparison only |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-19 Asia/Shanghai` |
| Action | Collect one controlled paired performance evidence slice |
| Run ID | Allocate `TC2-PERF-20260919-<HHMMSS>-REVAL-<n>` at paired-capture start; use arm labels `BASELINE` and `TREATMENT` |

## Exact Execution Identity

- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Branch / HEAD: `codex/typo-correction-002-provenance-sidecar` / `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- `origin/main` context: `162b09fd58ba60538a944026b1902efa405c75aa`; no same-head claim
- Tracked production/test diff SHA-256: `c9225a435b833aa1c637c21bead8f85f1465d2b6d161c30a74b5789408c523be`
- Untracked production/test file-content SHA-256: `f0ad8759e22deedaa3d5424280c481b2625c550c29609cc70258e3590861ec9d`
- Designated target: iPhone 17 Pro Max / iOS 27 Simulator, UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`, Messages, `+1 (888) 555-1212`

## Authorized Scope

- Compare only the declared baseline and treatment under the same installed build, source snapshot, Simulator, OS, host, active `rime_ice` schema, Full Access state, warm/cold state and measurement method.
- Use synthetic input and content-free diagnostics. Measure the documented candidate-refresh/query lifecycle, event counts and observed timing distributions; report sample count, median and worst observed value when the method supports them.
- Keep human/AX input cadence separate from engine/UI timing. If the harness or manual cadence dominates, report that confound instead of treating it as a product latency budget.
- Preserve paired artifacts and hashes so an independent reviewer can reproduce the comparison boundary.

## Required Evidence

- One fresh pair Run ID with explicit `BASELINE`/`TREATMENT` arm records, exact runtime provenance and raw-artifact SHA-256.
- Same-device/build/schema/access-state statement and any warm/cold separation.
- Measurement method, sample count, aggregate values and observed stalls/side effects; record all skipped or non-comparable arms.
- Diagnostic interpretation only: no invented numeric acceptance threshold, Release baseline or Product performance approval.

## Explicit Exclusions

- No source, test, schema, vendor, recall-budget, logging-hot-path or runtime behavior change.
- No physical-device substitution for this Simulator pair, and no use of a single favorable run as a performance conclusion.
- No `typeText`, pasteboard, host injection, raw user content or candidate text in retained artifacts.
- No INT-003, QA-001, Product, Quality, TestFlight, Release, merge or Assignment-closure conclusion.

## Stop / Completion

Stop if the two arms are not comparable, exact provenance is missing, the pair requires a rebuild/reinstall without a new Run ID, or the measurement is only an automation-clock artifact. Completion produces a diagnostic paired-performance receipt for independent Quality review; it does not establish a Release budget.
