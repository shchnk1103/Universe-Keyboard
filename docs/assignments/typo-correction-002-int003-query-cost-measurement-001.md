# Assignment: TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-001",
  "record_type": "assignment",
  "title": "Decision-ready measurement of INT-003 query count, usefulness and runtime cost",
  "lifecycle": "active",
  "current_phase": "P0 completed; P1 source authority active but unconsumed pending independent Architecture field review; P2 capture authority proposed pending exact installed-payload freeze. No Swift or device action has begun",
  "authorization_action": "plan_int003_query_cost_measurement",
  "updated_at": "2026-09-26T23:16:00+08:00",
  "revalidation_triggers": [
    "github_main_tip_changes_from_7b0025a",
    "source_or_diagnostic_schema_changes",
    "measurement_environment_or_Human_operator_changes",
    "Product_query_budget_or_parent_scope_changes",
    "request_for_Swift_capture_Gate_or_Release"
  ],
  "authorization_refs": ["AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-PLAN-001", "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-INSTRUMENTATION-001", "AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-SIM-CAPTURE-001"],
  "parent_refs": ["TYPO-CORRECTION-002"],
  "evidence_refs": [
    "docs/evidence/typo-correction-002-int003-query-cost-assessment-2026-09-26.md",
    "docs/plans/typo-correction-002-int003-query-cost-measurement-001.md"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Codex current task for P1 after independent review and consumption; P2 executor bound in its separate AUTH before capture",
    "environment_executor": "Codex isolated worktree for P1; Codex designated Simulator operator for P2 after exact run/payload freeze and consumption",
    "human_dependency": "Human Product Owner / Product Lead authorized separate P1/P2 scopes; any physical-device performance round requires a later Human decision and operator",
    "architecture_reviewer": "Independent Architecture & Knowledge Steward before P1 diagnostic field or bridge implementation",
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
| Authority | [P0 AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-PLAN-001.md) Consumed; [P1 AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P1-INSTRUMENTATION-001.md) Active/unconsumed; [P2 AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-P2-SIM-CAPTURE-001.md) Proposed/unconsumed |
| Non-claims | No Swift/ObjC change, new Capture, Release-like result, numeric budget, independent Quality conclusion, Product/QA-001 Gate, parent Close, TestFlight/Release or `RimeRuntimeProvenance` restore |
| Next | Independent Architecture review of [P1 field packet](../plans/typo-correction-002-int003-query-cost-p1-field-review-001.md); then consume P1 before source edits. Freeze P2 installed payload and run separately; parent remains [Active](typo-correction-002.md) |

## Assignment authority and inputs

- **Assignment Authority / Product Approver:** Human Product Owner / Product Lead. **Decision source:** Human 2026-09-26 Asia/Shanghai instruction authorizing a new Assignment/AUTH and KOS continuation after PR #178.
- **Required P0 inputs:** [query-cost assessment](../evidence/typo-correction-002-int003-query-cost-assessment-2026-09-26.md), [Product residual](../product-decisions/TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-PRODUCT-RESIDUAL.md), [`PERFORMANCE_BASELINE`](../PERFORMANCE_BASELINE.md), [`TYPO_CORRECTION`](../TYPO_CORRECTION.md), designated Simulator and physical-device [evidence profile](../kos/universe-keyboard-human-operated-evidence-profile.md), current source at GitHub `main` `7b0025a10a3079731628e63a7ffd587af57608d6`.
- **P0 scope:** Source/evidence reading, measurement method and privacy boundary design, this Assignment/AUTH, parent and status navigation mirrors, docs-only validation, one draft PR. No executable instrumentation or device operation.
- **Future stage dependency:** P1 instrument/verify and P2 capture can enter Ready only after a distinct Product Assignment decision/AUTH binds exact source, allowed files, reviewer, environment executor, run manifest and evidence question. P2 physical evidence also needs the Human-operated profile's readiness review and one-round budget. A Product performance budget or residual disposition is a further decision after evidence.

## Entry, exit and stop

| Stage | Entry | Exit / handoff |
|---|---|---|
| P0 plan (current) | Clean isolated worktree at verified GitHub main; Human authorized new Assignment/AUTH; prior raw/evidence identity already bound | [Plan](../plans/typo-correction-002-int003-query-cost-measurement-001.md), authority record and mirrors published for Product review. This does not make P1 Ready |
| P1 instrumentation (future) | Distinct consumed AUTH and exact source/allowlist; reviewed diagnostic semantics; Swift format hard gate before any Swift commit/push | Content-free, low-overhead instrumentation with focused correctness/overhead evidence and independent review; no numeric Product acceptance |
| P2 controlled capture (future) | Separate capture AUTH and freeze; designated Simulator for diagnostic validation. A Release-like physical Product claim requires a separate device-specific decision, installed-payload manifest and Human readiness review | Multiple cold/warm runs, exact build/environment/attachment hashes, count/usefulness/timing distributions, negative cases and independent Quality handoff |

Stop on `UNKNOWN` required responsibility for the current stage, source/plan drift, inability to distinguish an empty result from unavailable sidecar, any sensitive input/candidate/host logging, synchronous hot-path persistence, wrong device, missing installed-payload identity, Human round exhaustion, or scope expansion to budget change, Gate, release or parent Close. Record a bounded limitation rather than a guessed performance conclusion.

**Handoff target:** Human Product Owner / Product Lead for a separate P1/P2 authorization decision; Architecture & Knowledge Steward for any boundary-changing instrumentation; independent Test / Release reviewer for future evidence. The original query-density Product residual remains open throughout P0.
