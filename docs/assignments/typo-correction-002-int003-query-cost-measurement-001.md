# Assignment: TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001",
  "record_type": "assignment",
  "title": "Decision-ready measurement of INT-003 query count, usefulness and runtime cost",
  "lifecycle": "active",
  "current_phase": "P0 completed; P1 authority active/unconsumed, rebound to the PR #181 merge tip 2b9b15e with a 28-file source freeze; independent Architecture lane round 1 packet is frozen and awaiting review. P2 authority active/unconsumed and bound to the designated Simulator, with execution pending exact P1 payload and Run manifest freeze. No Swift or device action has begun",
  "authorization_action": "plan_int003_query_cost_measurement",
  "updated_at": "2026-09-27T16:31:00+08:00",
  "revalidation_triggers": [
    "p1_source_manifest_sha256_changes_from_5c19b79be205ba9afe2e50f321283071695c0b2dd9c4bdda9a4723af535b6d8a",
    "source_or_diagnostic_schema_changes",
    "measurement_environment_or_Human_operator_changes",
    "Product_query_budget_or_parent_scope_changes",
    "request_for_Swift_capture_Gate_or_Release"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-PLAN-001",
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-PLAN-M02-001",
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-INSTRUMENTATION-001",
    "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-SIM-CAPTURE-001"
  ],
  "parent_refs": ["TYPO-CORRECTION-002"],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-int003-query-cost-assessment-2026-09-26.md",
    "docs/plans/typo-correction-002-int003-query-cost-measurement-001.md",
    "docs/evidence/typo-correction-002-int003-query-cost-measurement-plan-m02-2026-09-26.md",
    "docs/evidence/typo-correction-002-int003-query-cost-p1-arch-source-freeze-r1.json",
    "docs/reviews/typo-correction-002-int003-query-cost-p1-architecture-review-packet-r1.md",
    "docs/reviews/typo-correction-002-int003-query-cost-p1-architecture-review-r1.md",
    "docs/evidence/typo-correction-002-int003-query-cost-p1-p2-authorization-post-merge-state-sync-2026-09-27.md"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Codex current task for P1 after independent review and consumption; P2 executor bound in its separate AUTH before capture",
    "environment_executor": "Codex isolated worktree for P1; Codex designated Simulator operator for P2 after exact run/payload freeze and consumption",
    "human_dependency": "Human Product Owner / Product Lead authorized separate P1/P2 scopes; any physical-device performance round requires a later Human decision and operator",
    "architecture_reviewer": "Fresh independent Architecture & Knowledge Steward lane TYPO-CORRECTION-002-INT003-QUERY-COST-P1-ARCH-001 round 1 before P1 diagnostic field or bridge implementation",
    "quality_reviewer": "Independent Test / Release lane after P1/P2 evidence, before any Quality claim",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Lifecycle | **Active** — P0 complete; P1 review pending, P2 environment freeze pending |
| Current phase | [Measurement plan](../plans/typo-correction-002-int003-query-cost-measurement-001.md) records the data needed to distinguish useful Stage 1/2 calls from empty or unavailable-sidecar calls and to assess elapsed cost |
| Authority | [P0 AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-PLAN-001.md) Consumed; [P1 AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-INSTRUMENTATION-001.md) Active/unconsumed; [P2 AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-SIM-CAPTURE-001.md) Active/unconsumed, execution gated on exact payload and Run freeze |
| Publication / M-02 | [PR #179](https://github.com/shchnk1103/Universe-Keyboard/pull/179) merged `9838c092672dae60c63b34e4d9be6dffafc3869f`; [PR #180](https://github.com/shchnk1103/Universe-Keyboard/pull/180) merged `c3cc229619604131d6358bbc85f74e81f2874dc6` with the single non-recursive closeout receipt. [PR #181](https://github.com/shchnk1103/Universe-Keyboard/pull/181) merged `2b9b15ee2d1d903b3a948109b2c2217535bd5248`, adding the separate P1/P2 authority records; its M-02 receipt is prepared at [post-merge state sync](../evidence/typo-correction-002-int003-query-cost-p1-p2-authorization-post-merge-state-sync-2026-09-27.md) |
| Non-claims | No Swift/ObjC change, new Capture, Release-like result, numeric budget, independent Quality conclusion, Product/QA-001 Gate, parent Close, TestFlight/Release or `RimeRuntimeProvenance` restore |
| Next | Complete Architecture lane `TYPO-CORRECTION-002-INT003-QUERY-COST-P1-ARCH-001` round 1; if approved, consume P1 before source edits. Then freeze and consume P2 against its exact installed payload and Run manifest; parent remains [Active](typo-correction-002.md) |

## Assignment authority and inputs

- **Assignment Authority / Product Approver:** Human Product Owner / Product Lead. **Decision source:** Human 2026-09-26 Asia/Shanghai instruction authorizing a new Assignment/AUTH and KOS continuation after PR #178.
- **Required P0 inputs (historical baseline):** [query-cost assessment](../evidence/typo-correction-002-int003-query-cost-assessment-2026-09-26.md), [Product residual](../product-decisions/TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-PRODUCT-RESIDUAL.md), [`PERFORMANCE_BASELINE`](../PERFORMANCE_BASELINE.md), [`TYPO_CORRECTION`](../TYPO_CORRECTION.md), designated Simulator and physical-device [evidence profile](../kos/universe-keyboard-human-operated-evidence-profile.md), source at GitHub `main` `7b0025a10a3079731628e63a7ffd587af57608d6` when P0 assessment began.
- **P0 scope:** Source/evidence reading, measurement method and privacy boundary design, this Assignment/AUTH, parent and status navigation mirrors, docs-only validation, one draft PR. No executable instrumentation or device operation.
- **Future stage dependency:** P1 instrument/verify and P2 capture can enter Ready only after a distinct Product Assignment decision/AUTH binds exact source, allowed files, reviewer, environment executor, run manifest and evidence question. P2 physical evidence also needs the Human-operated profile's readiness review and one-round budget. A Product performance budget or residual disposition is a further decision after evidence.

## Entry, exit and stop

| Stage | Entry | Exit / handoff |
|---|---|---|
| P0 plan (complete) | Clean isolated worktree at verified GitHub main; Human authorized new Assignment/AUTH; prior raw/evidence identity already bound | [Plan](../plans/typo-correction-002-int003-query-cost-measurement-001.md), P0 AUTH and one M-02 closeout are published and merged |
| P1 instrumentation (active, unconsumed) | Separate P1 AUTH bound to main `2b9b15ee…` and source manifest `5c19b79b…`, allowed paths, isolated macOS worktree and independent Architecture lane round 1; consume before source edits. Swift format strict lint before any Swift commit/push | Content-free, low-overhead instrumentation with focused correctness/overhead evidence and independent review; no numeric Product acceptance |
| P2 controlled capture (active, unconsumed) | Separate P2 AUTH bound to the designated Simulator; after P1 review/implementation, bind exact installed payload, run ID, schema/access/host state and archive location; consume before any Simulator operation | Multiple cold/warm runs, exact build/environment/attachment hashes, count/usefulness/timing distributions, negative cases and independent Quality handoff |

Stop on `UNKNOWN` required responsibility for the current stage, source/plan drift, inability to distinguish an empty result from unavailable sidecar, any sensitive input/candidate/host logging, synchronous hot-path persistence, wrong device, missing installed-payload identity, Human round exhaustion, or scope expansion to budget change, Gate, release or parent Close. Record a bounded limitation rather than a guessed performance conclusion.

**Handoff target:** Architecture & Knowledge Steward for the independent P1 field review; then the Input Intelligence Maintainer for implementation. Independent Test / Release reviews measurement evidence, and the Human Product Owner / Product Lead retains Product decisions. The original query-density Product residual remains open.
