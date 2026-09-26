# Assignment: TYPO-CORRECTION-002 — Contextual Multi-Error Pinyin Recovery

**Policy version:** `1.0.0`

**Lifecycle status:** `Active`

**Repository change types:** `Contract`, `Implementation`, `Evidence`, `State`

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner authorization in Codex task `019f6101-b9db-7821-9db6-ca288d9e1189` / `2026-07-14 Asia/Shanghai`; designated simulator clarification / `2026-07-15 Asia/Shanghai`
- **Product Approver:** Product Lead acting under the human owner's explicit delegation
- **Product Contract:** [`docs/TYPO_CORRECTION.md`](../TYPO_CORRECTION.md)

## Boundary

- **Scope:** Replace the fallback-only typo-correction candidate query with a bounded real-RIME sidecar query session; add bounded multi-error pinyin hypothesis generation and sentence-candidate ranking; add contracts, tests, benchmark cases, performance evidence and acceptance on the designated Device Hub iOS 27 iPhone 17 Pro Max simulator.
- **Non-goals:** Network/cloud correction; host context; automatic commit; RIME schema/weight/user-dictionary changes; unbounded search; input-history persistence; changes to `TYPING-INTELLIGENCE-001`; substituting another simulator or physical device for the designated Device Hub target.
- **Required Inputs:** `TYPO_CORRECTION.md`; ADR 0002, 0004, 0008, 0009, 0010 and 0015; `TYPO_BENCHMARK.md`; `TYPO_BENCHMARK_REGISTRY.md`; `PERFORMANCE_BASELINE.md`; `DEBUGGING.md`; `RELEASE_CHECKLIST.md`; current KeyboardCore/RimeBridge source and tests.

### Scope Amendment — 2026-09-17

- **Authorization:** The Human Product Owner explicitly authorizes a physical-device supplemental evidence arm in the current Codex task on 2026-09-17 Asia/Shanghai.
- **Supplemental arm:** A connected physical iOS device may collect additional manual-cadence and stale-work observations for `TC2-CASE-INT-003` only. The run must capture the physical model, UDID, OS build, signed app/extension identity, active schema, exact RIME provenance receipt, Full Access state, host app and a new Run ID.
- **No substitution:** This arm supplements the designated Device Hub iOS 27 iPhone 17 Pro Max simulator. It cannot satisfy `TC2-CASE-QA-001`, the paired performance case, the Product acceptance boundary or any Product, Quality, TestFlight, Release or merge decision.
- **Revalidation boundary:** A physical-device run is a separately bound evidence receipt. Any rebuild, reinstall, device change, schema change or restarted capture requires a new Run ID and fresh identity capture.

### Related child closure — 2026-09-19

- [`TYPO-CORRECTION-002-TESTABILITY-ACCESSIBILITY-001`](typo-correction-002-testability-accessibility-001.md) is Closed only for the bounded keyboard UI testability/accessibility child after PR #140 merged as `162b09fd58ba60538a944026b1902efa405c75aa`.
- This child closure does not close or satisfy the parent sidecar observability, INT-003, QA-001 or paired performance exits. The parent remains `Active`.

### Parent checkpoint publication — 2026-09-19

- The existing parent implementation and KOS evidence pack were frozen and published in checkpoint [`84978748d89d329a7d2c6e89400c1ff556cfd9b5`](../evidence/typo-correction-002-parent-checkpoint-2026-09-19.md).
- This is a recovery/provenance checkpoint, not a new Run and not a Product, Quality, Release or merge decision. Existing sidecar, INT-003, QA-001 and paired-performance receipts retain their original source/build/Run ID boundaries.
- The next production change requires a separate bounded recall-remediation Assignment/Authorization rooted at the exact checkpoint commit. No search-budget or candidate-recall change is authorized by this checkpoint.

## Assignment

- **Domain Owner:** Input Intelligence Maintainer
- **Executor:** Input Intelligence Maintainer, acting through bounded RIME Platform and Keyboard Experience work packages
- **Environment Executor:** Quality, Performance & Release Maintainer for automated evidence and Device Hub iOS 27 iPhone 17 Pro Max validation
- **Human Dependency:** `Not Applicable — the human owner delegated Product and execution decisions and clarified that the designated Device Hub target is a simulator.`
- **Architecture Reviewer:** Architecture & Knowledge Steward
- **Quality Reviewer:** Quality, Performance & Release Maintainer
- **Product Approver:** Product Lead
- **Handoff Target:** Product Lead for Product Review, then Program Manager for source-linked Dashboard synchronization

## Related child records (link only)

Keyboard UI testability/accessibility and F-02 overlay on/off **do not close this parent**. Canonical F-02/QR-01 residual for the child worktree is:

- [`F-02 reconcile Assignment`](typo-correction-002-testability-accessibility-f02-reconcile-001.md) — `Reviewed`, not Closed
- [`F-02/QR-01 evidence`](../evidence/typo-correction-002-testability-accessibility-f02-reconciliation.md) — **bounded Pass**
- [`F-02 Architecture 最终处置`](../reviews/typo-correction-002-testability-accessibility-f02-architecture-final.md) — **有界 Pass**；不关闭本 parent
- [`Child consolidated Quality`](../reviews/typo-correction-002-testability-accessibility-001-quality-consolidated.md) — **Pass with conditions**；不关闭本 parent
- Sidecar implementation/revalidation records remain under `/private/tmp/universe-keyboard-typo-correction-002-provenance-sidecar/docs/` (do not fork status there)

This parent remains **Active** for sidecar observability, INT-003, QA-001, and performance evidence.



### INT-003 evidence package — 2026-09-23 (Stale-cancel Product Capture)

- Capture AUTH [`AUTH-…-STALE-CANCEL-PRODUCT-CAPTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001.md) **Consumed**; Assignment [`…-stale-cancel-product-capture-001`](typo-correction-002-int003-stale-cancel-product-capture-001.md)
- Squash-merge PR [#157](https://github.com/shchnk1103/Universe-Keyboard/pull/157) → evidence on main; [#158](https://github.com/shchnk1103/Universe-Keyboard/pull/158) → Architecture; [#159](https://github.com/shchnk1103/Universe-Keyboard/pull/159) → Quality; [#161](https://github.com/shchnk1103/Universe-Keyboard/pull/161) → Product residual; [#162](https://github.com/shchnk1103/Universe-Keyboard/pull/162) → Proposed remediation AUTH on main tip `a9b82a58cac0c28e8a5d8a957d464d803d6d92d1`
- Evidence [`…-int003-stale-cancel-product-001.md`](../evidence/typo-correction-002-sim-run-2026-09-23-int003-stale-cancel-product-001.md) SHA-256 `3dde0362923fb36071c611134c6c0022ce70d20839afa2dd67894260428835b4` — **Bounded / Pass-with-conditions** (Capture ≠ Gate)
- Architecture [`…-001-architecture-review.md`](../reviews/typo-correction-002-int003-stale-cancel-product-capture-2026-09-23-001-architecture-review.md) SHA-256 `50fba2bc918c26a39a86419ef15a444e4fd28105629cdfcbcba85a18d85b13a4` — **Pass with conditions**; AUTH [`…-ARCHITECTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-ARCHITECTURE-001.md) **Consumed**
- Quality [`…-001-quality-review.md`](../reviews/typo-correction-002-int003-stale-cancel-product-capture-2026-09-23-001-quality-review.md) SHA-256 `bf54b8745091d24dd1af66136960c20356391a9c2a21098dfbe99d076c3495ac` — **Bounded Pass with conditions** (on main via #159); AUTH [`…-QUALITY-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-QUALITY-001.md) **Consumed**
- Residuals: `fence_discarded=0`; high `query_*` (574/574); same-lineage reviewer; raw JSONL not re-hashed on review hosts
- Product residual [`…-STALE-CANCEL-PRODUCT-CAPTURE-001-PRODUCT-RESIDUAL`](../product-decisions/TYPO-CORRECTION-002-INT003-STALE-CANCEL-PRODUCT-CAPTURE-001-PRODUCT-RESIDUAL.md) — Human selected **Open remediation (narrow `query_*`)** after #161 tip `65a0a11…`. Does **not** grant Gate / Close / Swift / TestFlight / Release
- Remediation AUTH [`AUTH-…-QUERY-DENSITY-REMEDIATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-REMEDIATION-001.md) + Assignment [`…-query-density-remediation-001`](typo-correction-002-int003-query-density-remediation-001.md) — **Consumed** at `2026-09-25T15:35:47+08:00` after binding to main `e28491a…`; PR [#163](https://github.com/shchnk1103/Universe-Keyboard/pull/163) merged as `15e2be5…`, and its M-02 closeout PR [#173](https://github.com/shchnk1103/Universe-Keyboard/pull/173) merged as `e28491a…`.
- Follow-up diagnostic Capture Assignment [`…-QUERY-DENSITY-DIAGNOSTIC-CAPTURE-001`](typo-correction-002-int003-query-density-diagnostic-capture-001.md) / AUTH [`…-DIAGNOSTIC-CAPTURE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CAPTURE-001.md) — **Consumed** at `2026-09-25T16:06:56+08:00`, bound to main `4ef275b…`; Run [`TC2-SIM-20260925-161830-INT003-QUERY-DENSITY-DIAGNOSTIC-001`](../evidence/typo-correction-002-sim-run-2026-09-25-int003-query-density-diagnostic-001.md) records 359 real query pairs across 12 operations (26–32 per operation). User's fastest manual input remained above 180 ms, so the earlier 16/16 rapid-window cause remains unresolved; no Swift change.
- [Product criterion decision](../product-decisions/TYPO-CORRECTION-002-INT003-QUERY-DENSITY-DIAGNOSTIC-CRITERION-001.md) on `2026-09-26` removes `<180 ms` as a hard pass condition **only for this follow-up diagnosis**. The remediation and first diagnostic Capture children are **Completed** with bounded outputs, not Reviewed/Closed. The prepared [rapid child](typo-correction-002-int003-query-density-rapid-diagnostic-001.md) has a no-run disposition: its AUTH is Consumed, but only a read-only UI snapshot occurred before Product stopped that route. The original rapid-window attribution and wider query-density Product residual remain open; no rapid-behavior Pass is inferred.
- [PR #175](https://github.com/shchnk1103/Universe-Keyboard/pull/175) published that docs-only package as squash merge `10faa51caf20e3c558f21f26b625eff7f3aa941d`. The [M-02 receipt](../evidence/typo-correction-002-int003-query-density-post-merge-state-sync-2026-09-26.md) binds this one lifecycle-changing merge; its closeout [PR #176](https://github.com/shchnk1103/Universe-Keyboard/pull/176) merged as `9f6f83edb13c8dd7d5598c1b398587bf4aa76f5b`.
- New [query-cost assessment child](typo-correction-002-int003-query-cost-assessment-001.md) is **Completed** under its distinct [Consumed AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-ASSESSMENT-001.md). Its [bounded evidence](../evidence/typo-correction-002-int003-query-cost-assessment-2026-09-26.md) counts 359 actual facade calls over 12 operations and reports Debug elapsed intervals, not RIME CPU cost or Product acceptance. The wider Product residual remains open; parent remains **Active** with no Product/QA-001 Gate.
- Human-authorized [PR #177](https://github.com/shchnk1103/Universe-Keyboard/pull/177) published that child as squash merge `501299dd14f317d67965330cb32dbf2e04ea2780`. Its [single M-02 receipt](../evidence/typo-correction-002-int003-query-cost-post-merge-state-sync-2026-09-26.md) binds the exact trigger; the closeout publication is recorded below. This publication does not resolve Product cost acceptability or the wider residual. Parent remains **Active**.
- Human-authorized [PR #178](https://github.com/shchnk1103/Universe-Keyboard/pull/178) published that non-recursive closeout as squash merge `7b0025a10a3079731628e63a7ffd587af57608d6`. A distinct [query-cost measurement Assignment](typo-correction-002-int003-query-cost-measurement-001.md) is **Active** for P0 planning only under its [Consumed docs-only AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-QUERY-COST-MEASUREMENT-PLAN-001.md). The [plan](../plans/typo-correction-002-int003-query-cost-measurement-001.md) requires a separate P1/P2 execution decision; no Swift, device operation, Product budget or Gate is inferred. Parent remains **Active**.
- Markers AUTH and the original Product Capture AUTH remain **Consumed**. Parent remains **Active**. No Product Gate / QA-001 Gate / Close / TestFlight / Release.

### INT-003 evidence package — 2026-09-22 (Cadence-003)

- Child [`TYPO-CORRECTION-002-INT003-CADENCE-003`](typo-correction-002-int003-cadence-003.md) **Closed** after same-process smoke→rapid
- Run `TC2-SIM-20260922-225841-INT003-CADENCE-003` on tip `69f5bd1ad662be4d980787d9a496b0d85aa7428a`
- Evidence [`typo-correction-002-int003-cadence-2026-09-22-003.md`](../evidence/typo-correction-002-int003-cadence-2026-09-22-003.md) — same process `F9245C6C-…`; rapid starts 3/3 <180 ms
- Architecture **Pass with conditions** ([review](../reviews/typo-correction-002-int003-cadence-2026-09-22-003-architecture-review.md)); Quality **Bounded Pass with conditions** ([review](../reviews/typo-correction-002-int003-cadence-2026-09-22-003-quality-review.md))
- Capture-002 process-churn and rapid <180 residuals addressed for this Run; same-agent-lineage review residual remains visible
- Product residual [`TYPO-CORRECTION-002-INT003-CADENCE-003-PRODUCT-RESIDUAL`](../product-decisions/TYPO-CORRECTION-002-INT003-CADENCE-003-PRODUCT-RESIDUAL.md) **Accepted** under [`AUTH-…-PRODUCT-RESIDUAL-001`](../authorizations/AUTH-TYPO-CORRECTION-002-INT003-CADENCE-003-PRODUCT-RESIDUAL-001.md) after PR #147 merge `bfee5ff…` — cleared residuals for this Run; **not** Product Gate / parent Close

This package does **not** close the parent, satisfy Product/Quality/Release Gate, or invent a global <180 ms product claim. Parent remains `Active`.

### INT-003 evidence package — 2026-09-22 (Capture-002)

Journal-backed controlled capture after Main App / App Group container diagnostics arm:

- Assignment [`TYPO-CORRECTION-002-INT003-CONTROLLED-CAPTURE-002`](typo-correction-002-int003-controlled-capture-002.md) — execution complete for Run `TC2-SIM-20260922-223301-INT003-CONTROLLED-002`
- Evidence [`typo-correction-002-int003-controlled-capture-2026-09-22-002.md`](../evidence/typo-correction-002-int003-controlled-capture-2026-09-22-002.md) — smoke Pass (`touch.terminal`); rapid timeline recorded; `<180 ms` cadence bar **not** met
- Architecture [`…-002-architecture-review.md`](../reviews/typo-correction-002-int003-controlled-capture-2026-09-22-002-architecture-review.md) — **Pass with conditions**
- Quality [`…-002-quality-review.md`](../reviews/typo-correction-002-int003-controlled-capture-2026-09-22-002-quality-review.md) — **Bounded Pass with conditions**

Supporting diagnostics arm records: [`arm-preflight`](typo-correction-002-diagnostics-journal-arm-preflight-001.md), [`ui-arm-retest`](typo-correction-002-diagnostics-journal-ui-arm-retest-001.md).

This package does **not** close the parent, satisfy Product/Quality/Release Gate, or clear the INT-003 cadence residual. Parent remains `Active`.

### Recall remediation child

The bounded recall-remediation lane is tracked separately and does not close this parent:

- [`Recall remediation Assignment`](typo-correction-002-recall-remediation-001.md) — `Active`
- [`Final Product decision`](../product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-FINAL-BOUNDED-PUBLICATION-PREPARATION-DECISION-2026-09-20.md) — `Bounded Accept with conditions`; parent remains `Active`
- [`Final publication Authorization`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-FINAL-PUBLICATION-001.md) — `Consumed` for commit/push/PR; merge remains separately unauthorized
- [`Scope reconciliation evidence`](../evidence/typo-correction-002-recall-remediation-publication-scope-reconciliation-2026-09-20.md) — old mixed worktree retained; clean `origin/main` staging started

The child remains bounded to recall remediation and its own provenance/quality handoff; it does not authorize parent closure, Product/Quality/Release Gate, device evidence, INT-003, QA-001 or paired-performance conclusions.

### Runtime integration child

The bounded controller/sidecar runtime-integration lane is tracked separately and does not close this parent:

- [`Runtime integration design`](typo-correction-002-runtime-integration-design-001.md) — `Reviewed`, Conditional Accept
- [`Runtime integration implementation`](typo-correction-002-runtime-integration-implementation-001.md) — `Reviewed`; Product accepted bounded residuals
- [`Product Decision`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md) — bounded Grok implementation package
- [`Residual Product Decision`](../product-decisions/TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-RESIDUAL-001.md) — accepted named residuals; no publication
- [`Implementation AUTH`](../authorizations/AUTH-TYPO-CORRECTION-002-RUNTIME-INTEGRATION-IMPLEMENTATION-001.md) — consumed
- [`Residual-hardening Assignment`](typo-correction-002-runtime-integration-hardening-001.md) — `Active`; independent Architecture returned `Blocker`, so Quality is blocked
- [`Blocker-remediation Assignment`](typo-correction-002-runtime-integration-hardening-blocker-remediation-001.md) — `Ready`; Grok-only Authorization is active/unconsumed; no execution, publication or parent-evidence authority

This child does not authorize parent closure, Product/Quality/Release Gate, device evidence, INT-003, QA-001 or paired-performance conclusions.

## Gates

### Entry Criteria

- Product Contract and ADR 0015 are accepted.
- This Assignment has no `UNKNOWN` field.
- The implementation plan defines a bounded query/search budget and negative cases.
- The active composition/session boundary remains unchanged before implementation starts.

### Exit Criteria

- Real RIME sidecar queries are isolated from the live session and verified by tests.
- Multi-error hypotheses and candidate ranking are bounded, tested and default-safe.
- Registry and benchmark cases distinguish single-edit legacy behavior from V2 multi-error behavior.
- Focused and full affected-package tests pass, along with Debug and Release builds.
- Performance evidence records the required environment and comparison results.
- Device Hub iOS 27 iPhone 17 Pro Max acceptance records candidate recovery and interaction regression results.
- Documentation, changelog and Dashboard impacts are complete.

### Stop Conditions

- A design requires mutating the live composition to query a hypothesis.
- A design requires raw sentence persistence, host context, network or synchronous key-path I/O.
- Search/query work cannot be bounded or produces unexplained normal-input regressions.
- The designated Device Hub iOS 27 iPhone 17 Pro Max simulator is unavailable or its runtime/build identity cannot be verified.
- An Accepted ADR or this Assignment requires revalidation.

## Handoff

- **Required Handoff Content:** changed-file inventory, candidate/session boundary evidence, benchmark results, performance evidence, Device Hub result, residual risks and documentation impact.
- **Revalidation Trigger:** any change to data retention, learning semantics, query-session lifecycle, RIME/session ownership, default promotion, device constraint or Product Contract.
