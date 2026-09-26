# INT-003 P1 diagnostic field review packet

Status: **awaiting independent Architecture & Knowledge Steward review**. This is a source-bound design packet, not implementation evidence. Source baseline: `9838c092672dae60c63b34e4d9be6dffafc3869f` after PR #179. [P1 AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-INSTRUMENTATION-001.md) is Active but unconsumed; [P2 AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-SIM-CAPTURE-001.md) is Proposed.

## Source facts and proposed signal

1. `TypoCorrectionRecallDriver.nextEvent` emits `.query(suggestion)` for both stages. The coordinator sees the query but cannot classify its stage. Add a finite `stageOne`/`stageTwo` tag to that value event; keep its scheduling and query budgets unchanged.
2. `TypoCorrectionRecallCoordinator.performQuery` records begin before the installed facade and outcome after driver state/journal work. Measure the facade call with a monotonic clock immediately around `correctionCandidates`, and record a bounded elapsed value and `0`/`1–3` candidate bucket **after** the call. The existing `query_succeeded` means only that the fence survived; retain that meaning.
3. `RimeSessionManager.correctionCandidatesForInput` currently returns the same empty candidate array when the correction session cannot be ensured and when a ready session finds no candidates. A finite readiness result must originate at that bridge boundary, travel only through the installed query facade, and never expose the raw engine or create another query route. Until a reviewed safe result exists, record `unknown`; never count unknown-zero as ready-empty.
4. One attempted call produces one stage, one candidate bucket, one readiness class and one facade duration. Incomplete, cancelled and discarded calls remain explicitly censored. Emit finite operation aggregates outside the measured call. Debug high-fidelity enablement and queue drops must be recorded in the evidence envelope, not assumed away.

## Privacy and cost budget for review

Allowed: per-process operation ordinal, finite stage/readiness enums, clamped candidate count, bounded elapsed duration and existing fence fields if strictly needed for pairing. Forbidden: composition, hypothesis, candidate or host text; candidate identity; new stable fingerprint; arbitrary strings; synchronous disk/JSON/DateFormatter/locks on the input path. The existing `compositionFingerprint` field is historical and must not be copied into a new cost aggregate. Any `DiagnosticEvent` field extension requires ADR 0027 allowlist review and a schema/compatibility decision. Inspect impact of building two journal events per query versus an aggregate event; prefer the smallest observation that answers the decision questions.

## Reviewer decision requested

Approve or amend the stage tag, ready/unavailable/unknown semantics, facade timing boundary, event schema version, field budget, threading/route ownership and overhead comparison method. Record an independent review with exact source and packet hashes **before** P1 AUTH consumption and Swift/ObjC edits. If readiness cannot be obtained without session or privacy risk, limit P1 to `unknown` and return to Product; do not infer query usefulness or cost acceptance from zero counts.
