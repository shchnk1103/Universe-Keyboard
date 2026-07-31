# Architecture Re-review: T9-RESPONSIVE-PIPELINE-001 R1 P1 remediation

**Reviewer role:** 🏛️ Architecture & Knowledge Steward (independent subagent re-review)  
**Date:** 2026-07-30 Asia/Shanghai  
**Scope:** Original R1 Architecture **P1** conditions only (remediation evidence), against repository sources  
**Verdict:** **Pass**  
**P0:** 0 · **P1:** 0 · **P2:** 4 · **P3:** 3

> Adversarial / independent re-review. Does **not** claim Product Gate, Quality Pass,
> ADR 0025 Accept, or R2 authorization. Does **not** re-run full KeyboardCore suite
> as Quality evidence (optional focused note below).

## Authority read

| Artifact | Result |
|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimePipeline.swift` | Full read |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveRimePipelineTests.swift` | Full P1 + related matrices |
| ADR 0025 §§10–11 (+ surrounding decision) | Read; Status still **Proposed** |
| `t9-responsive-pipeline-001-r1-architecture-review.md` | Original + Executor addendum |
| Assignment exit criteria (P1-related) | Read |
| Production wiring into `KeyboardController` / `RimeEngineImpl` | **Still absent** (grep: pipeline only self-references + tests/docs) |

## Original P1 disposition

| ID | Disposition | Evidence |
|---|---|---|
| **P1-1** latestOnly vs fail-closed (applied vs published) | **Closed** | Split watermarks `lastAppliedRevision` / `lastPublishedRevision` and snapshots `lastApplied` / `lastPublished` (`ResponsiveRimePipeline`). `validateSelection` requires epoch match **and** `lastAppliedRevision == boundRevision` **and** `lastPublished.revision == boundRevision` (engine head not past bound **and** user-visible authority). `.latestOnly` skips intermediate publish (`coalescedSkipCount`) but still runs engine in order; `catchUpPublishIfNeeded()` publishes applied when `pending.isEmpty` and applied > published. Tests: `testLatestOnlySelectionBoundToPublishedFailsWhenEngineAlreadyAdvanced`, `testLatestOnlyCatchUpPublishWhenTrailingWorkIsSkipped`, `testSelectionRequiresAppliedEqualsPublished` (mid-drain applied-ahead-of-published). |
| **P1-2** non-isolated class API / R2 isolation plan | **Closed** (as written freeze; not production isolation) | ADR 0025 **§10** freezes: R1 bed is single-thread only; R2 owner must be `actor` or single-consumer serial executor; MainActor = feedback/enqueue/apply; RIME owner = all session APIs; forbids `@unchecked Sendable` session/engine shuttling; lists full session surface. Source comments on `ResponsiveRimePipeline` and `ResponsiveRimeWork` restate non-concurrent R1 contract. Class remains non-isolated **by design** for R1 — condition was freeze, not R2 implementation. |
| **P1-3** reset/recover `sessionEpoch` mapping | **Closed** | ADR 0025 **§11** who-bumps table (visibility/`bumpSessionEpoch`, enqueued reset/recover, fail-closed recovery, process death N/A). R1: `.resetSession` / `.recoverSession` return `advancesEpoch: true`; after engine call, apply/publish then `advanceEpochAfterLifecycleWork(clearPending: false)` so trailing same-epoch pending fails closed on epoch guard. Explicit `bumpSessionEpoch` clears pending. Tests: `testEnqueuedResetAdvancesEpochAndInvalidatesTrailingPending`, `testEnqueuedRecoverAdvancesEpoch`, `testOldEpochSnapshotCannotPublishAfterBump`, plus prior `testSessionEpochBumpClearsPendingAndInvalidatesOldResults`. |

## P1-1 adversarial checks (detail)

Original defect: under coalesce, selection bound to **published** could still run after **engine** advanced without publish.

| Counter-example | Observed behavior | OK? |
|---|---|---|
| Settle `ni`, enqueue `h` + select(bound: ni), `.latestOnly` | `h` applies; select discarded; no commit; catch-up publishes `nih` | Yes — test named above |
| Partial drain: applied=3, published=2 | `validateSelection(bound:2)` and `(bound:3)` both reject | Yes — applied-only not selectable; published-behind-engine not selectable |
| Trailing stale select only (no further keys) | Catch-up still surfaces last applied | Yes |

Contract note: selection is **stricter** than “engine authority only” — it requires **applied == published == bound**. That is the correct fail-closed reading of “user saw X and engine has not moved past X.”

## P1-2 adversarial checks (detail)

| Check | Result |
|---|---|
| Written freeze exists before R2 discussion | **Yes** — §10.1–10.5 |
| Forbids `@unchecked Sendable` session shuttle | **Yes** — §10.4 + repo policy alignment |
| Claims R1 class is production-safe concurrent owner | **No** (correct negative claim) |
| Authorizes wiring / ADR Accept | **No** (correct) |

## P1-3 adversarial checks (detail)

| Boundary | Table (§11) | R1 bed |
|---|---|---|
| `bumpSessionEpoch` / visibility abandon | Caller bumps; clear pending | Implemented (`clearPending: true`) |
| Enqueued reset | Owner bumps **after** engine reset | Implemented (`advancesEpoch`) |
| Enqueued recover | Owner bumps **after** recover | Implemented |
| Remaining pending after enqueued lifecycle | Fail closed by epoch **or** clear | Fail closed without clear — allowed by §11 |
| suspend/resume work items | Same owner (R2 surface list §10.3); bump via visibility/`bumpSessionEpoch` | **Not** in `ResponsiveRimeWork` enum — expected R1 gap; lifecycle API path documented |

## New findings (residual; none re-open original P1)

### P0
None.

### P1
None. Original three P1 conditions are satisfied by code + ADR freezes + tests.

### P2 (carry / mild new)

1. **Post-lifecycle UI authority is nil, not a new-epoch empty snapshot.**  
   Enqueued reset/recover: `recordApplied` + `publishIfEligible` under the **old** epoch, then `advanceEpochAfterLifecycleWork` **zeros** `lastApplied` / `lastPublished`. Final public authority after lifecycle drain is `lastPublished == nil` even though the engine session is empty. Fine for R1 single-thread bed; R2 MainActor apply path must define how chrome clears composition/Path/candidates on epoch bump (synthetic new-epoch empty publish vs treat nil as clear). Do not treat current wipe as a complete atomic UI transaction design.

2. **Path / chrome atomicity still outside `ResponsiveRimeSnapshot`.**  
   Original P2: snapshot is `RimeOutput` only. ADR §5 still requires composition + Path + candidates + published revision in one MainActor transaction at production publish time. R1 bed does not model Path presentation fields — still an R2/R3 contract obligation, not closed by P1-1.

3. **Work enum still incomplete vs §10.3 owner surface.**  
   No `suspendForVisibilityChange` / `resumeAfterVisibilityChange` (or equivalent) work cases. Visibility is documented as caller `bumpSessionEpoch`. Acceptable for R1; incomplete coverage remains an R2 architectural risk if any session API stays on a parallel path.

4. **`publishedHistory` / ID history arrays survive epoch advance.**  
   `advanceEpochAfterLifecycleWork` clears watermarks and pending (when requested) but not `publishedHistory` / `acceptedActionIDs` / `executedActionIDs`. Diagnostics `publishedSnapshotCount` can span epochs. Test-bed smell; freeze or clear policy before production diagnostics consumers.

### P3

1. **ADR 0025 §4 cross-reference error:** text points to “§10 `sessionEpoch` mapping”; the freeze table is **§11** (§10 is isolation). Doc hygiene only.
2. **`testResetClearsCompositionInOrder` is weak on epoch semantics** (`lastPublished?.composition` is nil when `lastPublished` is nil after advance). Epoch behavior is covered by dedicated P1-3 tests; this older test does not prove empty composition publish.
3. **Original residual P3** (page/global-select dedicated cases, controller isolation as positive smoke only) unchanged and non-blocking for P1 closure.

### Closed relative to original P2 noise

- **Coalesce skip counter:** now present as `diagnostics.coalescedSkipCount` (no longer “missing”).

## Assignment exit criteria (P1-related) — architecture view

| Criterion (assignment) | Architecture disposition |
|---|---|
| Arch review Pass with conditions; 3 P1 block R2 | Original accurate; **this re-review closes those three P1s** |
| P1-2 / P1-3 documented in ADR §§10–11; Status Proposed | **Met** in repo |
| P1-1 applied vs published + catch-up + interleaving tests | **Met** in source + tests |
| Does not Accept ADR / authorize R2 / claim Product Gate | **Honored** by this review |

## R2 readiness (architecture-only, not Product authorization)

| Gate | Status |
|---|---|
| Original Architecture **P1 blockers** for *discussing* R2 | **Cleared** |
| ADR 0025 | Still **Proposed** — not Accepted |
| Production serial owner | **Not** implemented; not wired; Release default remains ADR 0004 MainActor path |
| Product R2 authorization | **Not granted** (out of scope of this review) |
| Quality re-review / Product Gate | **Not claimed** |

Architecture opinion: Product **may** consider R2 authorization on product grounds; architecture no longer holds the three R1 P1 conditions as open blockers. Any R2 design must still implement §10 owner shape, §11 epoch table on the wired path, applied/published dual watermarks, catch-up publish, fail-closed selection, and ADR §5 atomic UI publish — without `@unchecked Sendable`.

## Optional test note

This re-review did **not** independently re-execute `swift test` (not claimed as Quality Pass). Executor/addendum reported `ResponsiveRimePipelineTests` 23/0 and full KeyboardCore 801/0; initial independent Quality review covered pre-remediation 17/795. Architecture acceptance of P1 closure is based on **source and test code review**, not a new green CI claim.

## Explicit non-claims

- **Not** Product Gate  
- **Not** Quality Pass (no independent suite re-run claimed here)  
- **Not** ADR 0025 Accepted  
- **Not** R2 / R3 / Release-default enablement authorization  
- **Not** proof of real UIKit non-stutter or device latency  
- **Not** proof that production wiring already implements §§10–11  

## Summary

The three Architecture P1 conditions that blocked R2 *discussion* after the initial R1 review are **closed** with repository evidence: dual applied/published watermarks + fail-closed selection + catch-up under `.latestOnly`; written R2 isolation freeze; `sessionEpoch` mapping freeze plus enqueued reset/recover bumps in the R1 bed. Residual findings are **P2/P3** design and hygiene items for R2/R3, not reopenings of those P1s.
