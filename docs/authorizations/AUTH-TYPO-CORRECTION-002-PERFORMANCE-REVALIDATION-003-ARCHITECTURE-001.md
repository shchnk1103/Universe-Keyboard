# Authorization: AUTH-TYPO-CORRECTION-002-PERFORMANCE-REVALIDATION-003-ARCHITECTURE-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed — bounded Pass; receipt preserves paired-performance inconclusive disposition` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Review target | [`TC2-PERF-20260919-195848-REVAL-03`](../evidence/typo-correction-002-sim-run-2026-09-19-performance-reval-03-inconclusive.md) |
| Reviewer role | Independent Architecture reviewer |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-19 Asia/Shanghai` |
| Review mode | Read-only; no new Simulator run |

## Authorized scope

This Authorization permits one independent Architecture review of the exact
paired-performance Run Receipt, its retained raw artifacts, the capture
Authorization and the parent Assignment. The reviewer may verify:

- whether the receipt preserves the BASELINE/TREATMENT distinction and exact
  package, device, schema and provenance identity;
- whether the different keyboard-extension process IDs are a valid
  comparability break under the capture Authorization;
- whether the direct `real_rime_sidecar` route, session identity and 1–6 ms
  values are bounded observations rather than an end-to-end performance claim;
- whether the receipt's candidate-visibility observation and non-claims are
  correctly separated from QA-001 and Product conclusions.

The reviewer may write one Architecture review record and may consume this
Authorization when the verdict is recorded.

## Explicit exclusions

- No source, test, schema, vendor archive or documentation implementation edit.
- No rebuild, reinstall, schema deployment, Simulator interaction or recapture.
- No use of historical `rime_diag_log` as fresh arm evidence.
- No reproduction of raw pinyin, candidate text or host text beyond the
  already recorded receipt boundary.
- No INT-003, QA-001, paired-performance pass, Product/Quality/Release Gate,
  TestFlight, Release, commit, push, PR, merge or Assignment closure.

## Completion

The review must preserve the receipt's `inconclusive` disposition if the arm
comparison is not valid. A bounded Architecture verdict does not authorize a
new performance capture or publication. Independent Quality review remains a
separate Authorization.
