# Authorization: AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-002

## Current Status

| Field | Value |
|---|---|
| Status | `consumed — inconclusive; baseline produced no product timing events, treatment was not run, and the high-fidelity window had expired` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Scope | Diagnostic paired baseline/treatment comparison only |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-19 Asia/Shanghai` |
| Action | Collect one controlled paired performance evidence slice on the current exact source snapshot |
| Run ID | `TC2-PERF-20260919-192740-REVAL-02` |
| Arm labels | `BASELINE` and `TREATMENT` |
| Supersedes | `AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-001`, which remains unconsumed and must not be reused because its bound source diff SHA predates the coordinate-harness change |

## Exact Execution Identity

- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar`
- Branch / HEAD: `codex/typo-correction-002-provenance-sidecar` / `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
- `origin/main` context: `162b09fd58ba60538a944026b1902efa405c75aa`; no same-head claim
- Tracked Swift diff SHA-256: `f1e4e17637bf6aaaaf314f882b229d50751792cfafc488f0d2cd8197863c7862`
- Untracked Swift manifest SHA-256: `f0ad8759e22deedaa3d5424280c481b2625c550c29609cc70258e3590861ec9d`
- Designated target: iPhone 17 Pro Max / iOS 27.0 Simulator, UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Host: Messages, conversation `+1 (888) 555-1212`

## Authorized Scope

- Build and install the current exact worktree snapshot once, then use that
  same installed package for both arms.
- Compare only `BASELINE` (contextual correction disabled) and `TREATMENT`
  (contextual correction enabled) under the same Simulator, OS, host, active
  `rime_ice` schema, Full Access state, warm/cold state and measurement method.
- Use the declared synthetic sequence and content-free diagnostics. Keep human
  keyboard cadence separate from engine/UI timing; report it as a confound when
  it dominates the interval.
- Record direct sidecar query counts, route/outcome, elapsed distributions,
  live-session stability, event counts, arm comparability and any visible
  stalls or unexpected commits.
- Preserve paired raw artifacts and SHA-256 values for independent review.

## Required Evidence

- One fresh pair Run ID with explicit `BASELINE`/`TREATMENT` arm records.
- Exact source/build/device/schema/provenance identity shared by both arms.
- Measurement method, sample counts, median/worst values where supported,
  skipped or non-comparable arms, and warm/cold separation.
- Diagnostic-only interpretation; no invented numeric acceptance threshold or
  Release budget.

## Explicit Exclusions

- No source, test, schema, vendor, recall-budget, logging-hot-path or runtime
  behavior change.
- No physical-device substitution, single-favorable-run conclusion, host
  injection, `typeText`, pasteboard or retained raw input/candidate text.
- No INT-003, QA-001, Product, Quality, TestFlight, Release, merge or
  Assignment-closure conclusion.

## Stop / Completion

Stop if the two arms are not comparable, exact provenance is missing, a rebuild
or reinstall is needed after the pair begins, or the measurement is only an
automation-clock artifact. Completion produces one diagnostic paired-performance
receipt for independent Quality review; it does not establish a Release budget.
