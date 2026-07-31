# Architecture Review: T9-RESPONSIVE-PIPELINE-001 R1

**Reviewer role:** 🏛️ Architecture & Knowledge Steward (independent subagent)  
**Date:** 2026-07-30 Asia/Shanghai  
**Verdict:** **Pass with conditions**  
**P0:** 0 · **P1:** 3 · **P2:** 6 · **P3:** 4

> Independent review. Does **not** claim Quality Pass or Product Gate.
> Does **not** Accept ADR 0025. Does **not** authorize R2.

## Scope verified

R1 only: Fake RIME + pure KeyboardCore state machine + tests.

| Check | Result |
|---|---|
| PD / Assignment / Plan / ADR 0025 / ADR 0004 | Reviewed |
| `ResponsiveRimePipeline.swift` + tests | Reviewed |
| Wired into `KeyboardController` / `RimeEngineImpl` | **No** |
| Production input-pipeline / swift6 ownership docs rewritten | **No** (correct) |

**Authorization boundary:** Inside R1. No real session off-MainActor migration; Release default unchanged.

## Findings

### P0
None.

### P1 (must address before R2 authorization)

1. **`.latestOnly` vs fail-closed selection inconsistency**  
   `lastPublished` is used both as UI publish watermark and as selection authority. Under coalesce, engine can advance without publish, so a selection bound to an old published revision can still execute against a newer engine composition. Also: trailing skipped work may leave applied-but-unpublished engine state without catch-up publish.  
   **Required:** split `lastAppliedRevision` vs `lastPublishedRevision`; selection/Path bind against engine authority (or “published with no later applied mutation”); catch-up publish when queue settles; add interleaving regression tests.

2. **Non-isolated class API is an R2 concurrency landmine**  
   Mutable class with re-entrant `accept`/`drain` holding non-Sendable `RimeEngine`. Fine as single-thread test bed; unsafe to share across MainActor + background without redesign.  
   **Required:** freeze R2 owner shape (actor / single-consumer serial executor); forbid `@unchecked Sendable` session shuttling.

3. **`reset` / `recover` work items do not bump `sessionEpoch`**  
   ADR expects epoch on reset/recover/visibility boundaries; only explicit `bumpSessionEpoch()` does.  
   **Required:** freeze epoch mapping table even if implementation lands in R3.

### P2 (summary)
Path atomicity not in snapshot; work enum missing suspend/resume/candidateWindow; optional Path binding; unbounded history APIs; missing coalesce skip counter; no stable commit hash for evidence binding at review time.

### P3 (summary)
Missing page/recover tests; bump doesn’t clear history arrays; controller isolation test is weak positive smoke; revision apply prose still ambiguous.

## Contract alignment

| Contract | Alignment |
|---|---|
| PD/Assignment R1 boundary | Aligned |
| ADR 0004 still production rule | Preserved |
| ADR 0025 Proposed (not Accepted) | Correct; not yet Accept-ready |
| Ordered queue / no drop | Aligned |
| Fail-closed selection | Aligned under `.everyResult`; **broken under `.latestOnly` combos** |
| Content-free diagnostics | Acceptable |

## Conditions before R2 discussion

1. Fix P1-1 (applied vs published + tests).  
2. Written freeze of P1-2 isolation plan.  
3. Freeze P1-3 epoch mapping for reset/recover/visibility.  
4. Do not interpret this review as ADR Accept, Quality Pass, or Product Gate.

## Explicit non-claims

- Not Product Gate  
- Not Quality Pass  
- Not ADR 0025 Accepted  
- Not R2+ authorization  
- Not proof of real UIKit non-stutter  

---

## Remediation addendum (2026-07-30, Executor)

Post-review code+doc work (not a second independent Architecture Pass unless
re-requested):

| Condition | Status |
|---|---|
| P1-1 applied vs published + interleaving tests | **Remediated** in `ResponsiveRimePipeline` + 6 new tests |
| P1-2 isolation plan written freeze | **Documented** ADR 0025 §10 |
| P1-3 epoch mapping + enqueued reset/recover bump | **Documented** ADR 0025 §11; **implemented** in R1 bed |

Verification (Executor): `ResponsiveRimePipelineTests` 23/0; full KeyboardCore
801/0. Independent Architecture re-review optional before Product R2 decision.
