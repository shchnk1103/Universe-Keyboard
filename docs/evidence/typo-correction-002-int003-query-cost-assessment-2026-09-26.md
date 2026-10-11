# INT-003 query count and observed timing cost — bounded assessment

## Evidence identity and scope

| Field | Value |
|---|---|
| Assignment / AUTH | [`QUERY-COST-ASSESSMENT-001`](../assignments/typo-correction-002-int003-query-cost-assessment-001.md) / [`AUTH-…-QUERY-COST-ASSESSMENT-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-ASSESSMENT-001.md), Consumed for this read-only slice |
| Source | GitHub `main` `9f6f83edb13c8dd7d5598c1b398587bf4aa76f5b` |
| Existing Run | [`TC2-SIM-20260925-161830-INT003-QUERY-DENSITY-DIAGNOSTIC-001`](typo-correction-002-sim-run-2026-09-25-int003-query-density-diagnostic-001.md), Simulator / Debug; no new input |
| Raw input | Local `keyboard_extension-596AEB2F-5018-451A-9F89-4AB127C3A4FE-20260925T08-0.jsonl`; 571,204 bytes; SHA-256 `aa523a6e8330b529e0ffc03283b142f842401b2321e2b323e6ce2762d5b59f84`, rechecked before parsing; raw file remains outside the repository |
| Evidence grade | **Executor-recorded**; no independent Quality recheck |

Only event code, `monotonicNanoseconds`, local sequence, operation ordinal, process/appearance identity and permitted outcome enum were projected. No input, candidate, host text, fingerprint, or raw JSONL is published. The journal has 863 rows, one process and one appearance; all 863 local sequences are unique. Pairing `typo_recall.query_begin` with the next `query_outcome` within the same operation gives 359 pairs, no unmatched begin/outcome and no negative interval. Twelve `debounce_scheduled`, eleven `debounce_cancelled`, two `epoch_bumped` and three `fence_discarded` markers are separate counts.

## Measured aggregates

All durations below are same-process monotonic timestamp differences, in milliseconds. P95 uses nearest rank; with only 12 operations its p95 is the observed maximum. `query_begin → query_outcome` brackets the installed candidate-query facade call **plus** event processing and marker recording. It is not a CPU profile or a RIME-only timer.

| Metric | n | Minimum | Median | P95 | Maximum |
|---|---:|---:|---:|---:|---:|
| Query pairs per operation | 12 | 26 | 31 | 32 | 32 |
| One query begin → outcome | 359 | 0.008 | 0.010 | 0.025 | 0.360 |
| Sum of paired intervals per operation | 12 | 0.300 | 0.340 | 0.659 | 0.659 |
| First query begin → last outcome per operation | 12 | 28.305 | 75.815 | 147.225 | 147.225 |
| Latest preceding schedule → first query begin | 12 | 215.032 | 234.384 | 259.581 | 259.581 |

The 359 paired intervals sum to **4.454 ms** across the entire run. That sum is not total CPU time: it includes instrumentation, may underrepresent work outside the bracket, and says nothing about cost of generating hypotheses, UI application, memory, or other main-thread work. The first-to-last span includes yielded RunLoop turns and intervening work; it is **not** 28–147 ms of continuous blocking. The scheduler marker carries the *pre-start* ordinal, so schedule-to-first is associated by the latest preceding schedule in monotonic order, not by equal ordinal. Each operation's schedule precedes its first query; the correlation reproduces the prior run's 219–260 ms range to rounding, with one 215.032 ms case.

| Operation ordinal | Pairs | Sum of paired intervals (ms) | First → last query span (ms) | Schedule → first query (ms) |
|---:|---:|---:|---:|---:|
| 1 | 31 | 0.659 | 31.335 | 218.942 |
| 2 | 31 | 0.300 | 28.305 | 220.319 |
| 3 | 31 | 0.306 | 37.651 | 215.032 |
| 4 | 32 | 0.319 | 53.185 | 222.100 |
| 5 | 31 | 0.333 | 74.795 | 227.623 |
| 6 | 32 | 0.348 | 68.020 | 232.810 |
| 7 | 31 | 0.423 | 76.834 | 235.958 |
| 8 | 31 | 0.369 | 124.848 | 247.266 |
| 9 | 26 | 0.315 | 147.225 | 249.505 |
| 10 | 26 | 0.349 | 139.502 | 259.581 |
| 11 | 26 | 0.325 | 143.080 | 258.388 |
| 12 | 31 | 0.407 | 138.649 | 259.002 |

Operations 9–11 have fewer pairs while the run also contains three fence discards. Without per-stage and candidate-result observations, the 26-pair counts must not be read as a stable lower budget or proof that all 26 were useful. This is one Debug run of 12 operations with manual key intervals of 285–576 ms; it is neither a controlled cadence comparison nor a Release-like product measurement.

## Source interpretation and decision boundary

The [`coordinator`](../../Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift) emits one begin marker immediately before `owner.correctionCandidates` and one outcome after the call and driver processing. The [`installed owner`](../../Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionSidecarOwner.swift) delegates to its query facade. The production [`RimeEngineImpl` adapter](../../Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+CorrectionQuery.swift) calls the ObjC sidecar query, whose [implementation](../../Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m) can return an empty result before querying if its correction session is unavailable. The journal does not expose the installed route, candidate count, sidecar readiness or actual RIME work for each pair. Therefore the roughly 10-microsecond median **cannot prove** that RIME candidate generation is cheap in normal use. `query_succeeded` in the coordinator means the fence survived; it does not mean candidates were found.

The [`driver`](../../Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift) queries the Stage 1 contextual and legacy single-edit hypothesis queue before Stage 2. The eight-attempt limit applies to Stage 2's ledger, **not** to Stage 1; Stage 1 stops after four accepted nonempty results or queue exhaustion. The [prior Architecture review](../reviews/typo-correction-002-runtime-integration-implementation-architecture-review-2026-09-21.md) already identifies that separation. Thus 26–32 real facade calls per operation do not by themselves prove a violated eight-query runtime contract. The journal has no stage label or result count, so this run cannot allocate the 359 calls between stages or determine useful versus empty queries.

**Assessment:** total query *count* is well supported for this run (359; 26–32 per operation). The measured bracket and operation spans describe Debug elapsed time only. They do not establish an acceptable product cost, a RIME CPU cost, or a before/after improvement. The original Product Capture's 574/574 query density and 16/16 rapid window remain separate evidence; its raw journal is unavailable here for equivalent operation/timing grouping. The broader Product residual remains **open**, and this result supplies no reason to change Swift or the fence now.

**Recommended Product choice:** keep the residual open while deciding whether query count itself warrants a new budget. If Product needs an acceptability or optimization decision, authorize a separate, content-free measurement plan that records per-stage attempts, empty/nonempty result counts and sidecar-ready state, then compares same-build cold/warm runs on a Release-like physical device with a controlled synthetic workload. Follow [`PERFORMANCE_BASELINE`](../PERFORMANCE_BASELINE.md), including Human-operated device rules and independent Quality review. Set a numeric budget only from reviewed evidence and an explicit Product decision. A stage budget or scheduling change needs its own Assignment/AUTH and appropriate Architecture/Quality review. No Product Gate or parent Close follows from this assessment.

## Reproduction recipe and validation

Rehash the local raw file to the exact SHA above. Parse JSONL without printing rows; project only the allowlisted fields above. Sort by `monotonicNanoseconds`; pair begin/outcome by operation ordinal and count unmatched markers. For each operation, count pairs, sum their timestamp differences, and subtract first begin from last outcome. Associate the latest preceding schedule in time with each operation's first begin. Sort metric values; report minimum, median, nearest-rank p95 and maximum. Cross-check overall paired count against the [`diagnostic Run`](typo-correction-002-sim-run-2026-09-25-int003-query-density-diagnostic-001.md) and the [diagnosis](typo-correction-002-int003-query-density-diagnosis-001.md). This analysis was repeated after correcting the schedule ordinal association; the erroneous equal-ordinal schedule join was discarded before publication.

Validation grade: **Executor-recorded** for SHA, 863-row identity, 359 matched pairs, 12 grouped operations and source tracing. No Simulator run, Swift test, xcodebuild, independent Quality recheck, Product acceptance or Gate was performed.
