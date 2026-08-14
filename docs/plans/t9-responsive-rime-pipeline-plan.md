# Plan: T9 responsive RIME input pipeline

| Field | Value |
|---|---|
| Status | **Reviewed — parent no longer Active (2026-08-14); ADR 0025 Accepted; ALL-LAYOUTS L0 universal; Product Gate dual-gate Release request default-on (RESPONSIVE-DEFAULT-ON-001, 2026-08-06); Formal R5 FAIL historical; no performance SLO; App Store separate** |
| Created | 2026-07-30 |
| Product lock | 2026-07-30 (direction); Product Gate default-on 2026-08-06 |
| Work item | [`T9-RESPONSIVE-PIPELINE-001`](../assignments/t9-responsive-rime-pipeline-001.md) |
| Product direction | [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md) · [`PD-RESPONSIVE-DEFAULT-ON-001`](../product-decisions/RESPONSIVE-DEFAULT-ON-001-authorization.md) |
| Architecture | [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) (**Accepted**; §8 Product Gate default request) |
| Predecessor | [`t9-long-composition-process-key-latency-plan.md`](t9-long-composition-process-key-latency-plan.md) (**Hold/harvest** after S2.3 direction FAIL) |
| Design baseline | branch `codex/t9-auto-anchor-s5-checkpoint` @ `dddbe61` |

## Problem statement

Chinese nine-key long composition still freezes under continuous input. Bridge
and device diagnostics attribute spikes primarily to librime `process_key`, not
to local Path computation. The current Extension path is effectively:

```text
touch → MainActor → KeyboardController.handle
  → RimeEngine.processKey (wait librime)
  → mutate marked text / Path / candidates
  → UI draw
```

So engine wall time becomes perceived key latency. Auto-anchor experiments
(S2.1–S2.3) reduced ambiguity in some arms but **did not meet the product
north-star** of smooth continuous typing without forcing Path habits. Product
chose Hold/harvest on that route and opened this architecture track.

## Goals

1. Key feedback (visual / click / haptics) never waits on librime.
2. All librime session APIs remain **strictly serial** under one owner.
3. Results may lag; stale results never clobber newer state.
4. Marked text, Path and candidates publish **atomically** per accepted snapshot.
5. Preserve T9 host-digit safety, Path/Partial Commit contracts, 26-key and
   user-dictionary privacy.
6. Prove the model with Fake RIME before moving the real session off today’s
   MainActor-synchronous calls.
7. Keep Release default unchanged until Product Gate.

## Non-goals

- Making librime itself faster (schema/Lua) as the primary fix for this plan
- Expanding auto-anchor knives under a new name
- Dropping or merging RIME input events in v1
- Inventing numeric SLOs without baselines
- Shipping Release-default async without gates
- Weakening ADR 0020–0023 Path presentation contracts

## Current-state audit (read-only, R0)

| Finding | Source |
|---|---|
| Extension session ops intended on main actor/thread | ADR 0004 (Accepted) |
| `KeyboardController` is `@MainActor` | `KeyboardController.swift` |
| `RimeEngine` API is synchronous `processKey → RimeOutput` | `RimeEngine.swift` |
| Production impl calls ObjC/librime inline | `RimeEngineImpl` |
| Full deploy already uses actor serialization | `RimeDeploymentService` |
| Long-input spikes deterministic on frozen sequence | evidence 2026-07-26 |
| Path-only local work is not the primary stall | same evidence + plan Lane analysis |
| Auto-anchor Hold/harvest; default-off stack retained | S2.3 evidence + PD-T9-AUTO-ANCHOR-001 |

**Implication:** Lane C from the latency plan (“dedicated serial queue”) is now
the primary product track, but must be specified with revision/epoch, UI
atomicity and Swift 6 isolation — not a casual `DispatchQueue.async` sprinkle.

## Target architecture (summary)

```text
touch / action
  → MainActor immediate feedback
  → MainActor enqueue ordered work item (revision++)
  → RIME serial owner executes librime APIs one-by-one
  → result(sessionEpoch, revision, RimeOutput-derived snapshot)
  → MainActor: if epoch/revision still valid → atomic publish
              else discard (content-free counter)
```

ADR 0025 owns the decision text. This plan owns sequencing and validation.

## Relationship to ADR 0004

ADR 0004 remains Accepted. This plan does **not** silently edit it.

ADR 0025 (Proposed) will, when Accepted, **revise the Extension session
threading clause**: session operations stay single-threaded/serial, but the
serial owner may be a dedicated executor rather than the UI MainActor. Main App
deploy ownership and process-local session rules stay.

Until ADR 0025 is Accepted and an implementation phase is authorized,
production code continues to follow ADR 0004 as written.

## Phased plan

### R0 — Governance and design

| Item | Status |
|---|---|
| Product Decision | Recorded |
| Assignment | Active |
| Plan | This document |
| Proposed ADR 0025 | Recorded |
| Predecessor successor links | Done |
| Production wiring | Unchanged at R0 |

**Exit:** Human design acceptance; R1 authorization — **done 2026-07-30**.

### R1 — Fake RIME responsive state machine — **implemented 2026-07-30**

**Authority:** Human Product Owner explicit R1 authorization after R0 design
acceptance.

Delivered:

- `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimePipeline.swift`
  — ordered `accept`, serial `drain`/`processNext`, `sessionEpoch` /
  `revision`, publish policies (`.everyResult` / `.latestOnly`), fail-closed
  candidate/Path binding, content-free diagnostics, injectable execution clock.
- `Packages/KeyboardCore/Tests/KeyboardCoreTests/ResponsiveRimePipelineTests.swift`
  — accept-without-wait, 20 ms burst + 150 ms clock, order, stale revision,
  epoch bump, coalesce, Delete/candidate/Path/reset, controller default-path
  isolation.
- Production `KeyboardController` and `RimeEngineImpl` **not** wired.
- Release default path remains today’s synchronous call.

**Exit:** focused tests green — **done**; independent Architecture/Quality
review — **Pass with conditions** (2026-07-30). Architecture P1 conditions
blocking R2 were: P1-1 applied/published split (code), P1-2 isolation plan
(docs freeze), P1-3 epoch mapping (docs freeze). **All three remediated
2026-07-30** in the R1 bed + ADR 0025 §§10–11 (no R2 authorization, no ADR
Accept, no Product Gate). Historical note — prior text said P1-1 open until
code + tests land.

### R2 — Serial RIME owner (default-off) — **implemented 2026-07-30**

**Authority:** Human Product Owner R2 authorization (session).

Delivered:

- `SerialRimeSessionOwner` + `ResponsiveRimeSessionCoordinator`
  (`Packages/KeyboardCore/Sources/KeyboardCore/SerialRimeSession.swift`)
- Controller gate `isResponsiveRimePipelineEnabled` (**default false**)
- When enabled: composition `processKey` via `scheduleProcessKey` (accept now,
  drain next MainActor turn); visibility abandon bumps epoch
- When disabled: ADR 0004 synchronous `rimeEngine` path unchanged
- Tests: `ResponsiveRimeR2CoordinatorTests`
- **No** `@unchecked Sendable`; **no** Release default-on; **no** ADR Accept

**Isolation residual:** Engine remains MainActor-confined (Swift 6 cannot move
non-Sendable `RimeEngine` off-main without forbidden shuttling). Deferred drain
still makes `handle` return before librime for the key path. True off-main
librime needs a later Architecture-approved thread-confined design.

**Exit:** focused tests green — Executor claim only; independent Arch/Quality
for R2 **pending**.

### R3 — Contract completion / gate-on parity — **implemented 2026-07-30 (default-off)**

**Authority:** Product “先 A 后 B；B 授权实现”.

Delivered:

- FIFO `responsiveKeyApplyContexts` so deferred `processKey` publish re-runs
  Path retain / auto-anchor / recovery-style post-processing (gate-off parity)
- Coordinator rebuild prefers `.everyResult` so contexts stay 1:1 with drains
- `underlyingRimeEngine` + Extension chrome uses it (`viewWillAppear` / feedback)
- handle-level key→delete order test; path presentation context test
- Still **default-off**; **not** off-main (P1-3); **not** ADR Accept / Gate

Residual for later R3 polish or R4+:

- Full handle multi-gesture matrix beyond key→delete
- Symbol-page replace still sync-drains on handle
- Queue growth / jetsam policy

### Spike-P1-3 — thread-affine off-MainActor proof — **authorized 2026-07-30**

This is a proof slice between R3 and R4, not R4 real-librime integration.

- Dedicated `Thread` + blocking Sendable mailbox + one consumer.
- Engine constructed, used and released only on that thread.
- MainActor accepts only process-key descriptors and applies only validated
  value snapshots.
- 150 ms+ controlled stall, FIFO/no-drop, epoch/revision and gate-off isolation
  tests.
- No controller/Extension/real `RimeEngineImpl` wiring.
- Stop for independent Architecture and Quality review; remediate only inside
  the Spike boundary.

Design:
[`../assignments/t9-responsive-pipeline-001-spike-p1-3-design.md`](../assignments/t9-responsive-pipeline-001-spike-p1-3-design.md).

### R4-Owner — Arch P2 owner contract — **authorized 2026-07-31**

Closes Spike-P1-3 Architecture residual P2 items before any real-librime
production owner claim. Product policy: refuse-at-bound; never drop accepted
FIFO process-key work; gate stays off; owner stays disconnected from Extension
and `RimeEngineImpl` production wiring.

Design:
[`../assignments/t9-responsive-pipeline-001-r4-owner-design.md`](../assignments/t9-responsive-pipeline-001-r4-owner-design.md).

### R4-B — Real RIME integration — **authorized 2026-07-31**

- Config-only Sendable bootstrap for real `RimeEngineImpl` on the thread-affine
  owner thread
- Simulator / RimeBridge evidence on a short frozen sequence (content-free)
- Gate-off baseline: 26-key / direct path remains when responsive gate is off
- **Not** Extension production wiring, ADR Accept, Product Gate, or device A/B

Design:
[`../assignments/t9-responsive-pipeline-001-r4-b-design.md`](../assignments/t9-responsive-pipeline-001-r4-b-design.md).

### R5 — Human device A/B — **Closed 2026-07-31 direction FAIL**

- Design: [`../assignments/t9-responsive-pipeline-001-r5-formal-design.md`](../assignments/t9-responsive-pipeline-001-r5-formal-design.md)
- Evidence: [`../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md)
- A (gate-off): stall 2; KEY END ≥100 ms ×4; worst 215 ms
- B (dual-gate): KEY END ~1 ms but **freeze-then-burst** (stall 4); async SLOW RIME still ~160–207 ms
- Direction **FAIL**; KEY END not valid felt-latency proxy under dual-gate
- Product Gate / default-on / ADR Accept **not** claimed

### R5-Remediation — Rem-1+2 + Rem-Device Closed 2026-07-31 (published `main` @ `7665c64`)

Responds to Formal R5 dual-gate **freeze-then-burst** FAIL without rewriting it.

- Design: [`../assignments/t9-responsive-pipeline-001-r5-remediation-design.md`](../assignments/t9-responsive-pipeline-001-r5-remediation-design.md)
- Evidence Rem-1+2: [`../evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md)
- Evidence Rem-Device: [`../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md)
- **O1 / Rem-1** observability landed (`ACCEPT` / `VISIBLE` / `PUBLISH lagMs` / `BURST`)
- **O2 / Rem-2** dual-gate UI coalesce + true latestOnly + last-head R3 context; Arch P1-1 Closed
- **Rem-Device** direction **PASS** (key-feel better than gate-off; no freeze-burst; VISIBLE lag spikes remain; O2 coalesce barely exercised on that pair)
- **O3 / Rem-3** provisional L1 — design + Amendment A + implementation + Polish-2
  device direction evidence complete; P1-D2 Amendment B bounded implementation and
  final independent Architecture/Quality **Pass with conditions**. Current final
  slice is focused **16/0**, full **858/0**; P1-1/P1-2 are closed. The follow-up
  P2 Core regression subset is tracked separately; the earlier P1-D2 contract
  conflict is historical.
  ([design](../assignments/t9-responsive-pipeline-001-r5-rem-3-design.md),
  [Polish Arch](../assignments/t9-responsive-pipeline-001-r5-rem-3-polish-architecture-review.md),
  [Polish Quality](../assignments/t9-responsive-pipeline-001-r5-rem-3-polish-quality-review.md),
  [evidence](../evidence/t9-responsive-pipeline-r5-rem-3-polish-2026-08-01.md))
- Engine FIFO no-drop retained; dual-gate default-off retained
- Publication: PR #37 → preflight, PR #36 → `main` (`7665c64`); CI green on both heads

### P1-D2 Amendment B — Product-selected implementation slice (2026-08-01)

Product selected the stable-chrome alternative: retain the latest host-visible L2
marked text and append pending `·` slots for L1, while Candidate/Path chrome stays
visually stable and all related Core actions fail closed during `provisionalAhead`.
This slice is limited to the Proposed Amendment/design, KeyboardCore pure logic and
focused regression tests, followed by independent Architecture and Quality review.
It does not change the default-off gates, RIME/Extension wiring, ADR 0025 status,
Product Gate or Release policy.

Design authority: [`P1-D2 Amendment B`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md#13-proposed-amendment-b--p1-d2-visual-shadow-anchor-and-stable-stale-chrome)
and [`Rem-3 design Amendment B`](../assignments/t9-responsive-pipeline-001-r5-rem-3-design.md#d10--amendment-b-2026-08-01--visual-shadow-anchor-and-stable-stale-chrome).

Disposition: bounded **Pass with conditions** after final independent Architecture
and Quality re-review; focused **16/0**, full **858/0**; P1-1/P1-2 closed and
P2 follow-up matrix opened. No R6, ADR Accept, Product Gate or default-on.

### P2-Regression-Matrix-001 — Core subset Pass with conditions (2026-08-01)

This follow-up is test/evidence-only and does not change production behavior or
either default-off gate. It covers the stale-action matrix, settled stale-chrome
snapshot, and epoch/abandon `markedTextHistory` contracts.

- Assignment: [`P2-Regression-Matrix-001`](../assignments/t9-responsive-pipeline-001-p2-regression-matrix.md)
- Evidence: [`P2 regression matrix evidence`](../evidence/t9-responsive-pipeline-p2-regression-matrix-2026-08-01.md)
- Current result: focused **19/0**, full **861/0**; three-test repair rerun **3/0**;
  vendor verify and diff-check pass.
- Independent Architecture and Quality re-reviews: **Pass with conditions**;
  P2-EPC host-history count/empty assertion is closed at bounded Core/Fake-host
  scope.
- Still open: UIKit Extension candidate-prefetch no-op and real stale-chrome/owner-call
  observation; real librime/device subjective latency, queue/memory/jetsam and
  Release/Product Gate evidence.
- Stop point: no R6, ADR Accept or default-on claim; any UI/real-device matrix needs
  a separate Product authorization.

### P2-PERF-02 Canonical A/B — bounded device handoff (2026-08-03)

The Product-authorized canonical-fixture A/B was completed on the iPhone 13 Pro
and handed to independent Architecture and Quality review. This is a bounded
diagnostic observation, not a Product Gate or Release decision:

- Assignment: [`P2-PERF-02 canonical A/B`](../assignments/t9-responsive-pipeline-001-p2-perf-02-canonical-ab-20260803.md)
- Evidence: [`canonical A/B evidence`](../evidence/t9-responsive-pipeline-p2-perf-02-canonical-ab-2026-08-03.md)
- A sync: T9SEG total max `181.8ms`, RIME max `180.4ms`, Human `2/4`.
- B thread-affine: T9SEG immediate-path max `0.7ms`, owner `PUBLISH 39/39`,
  engine VISIBLE lag max `160ms`, Human `0.5/4`.
- Ordinary Release restore and one-key smoke passed; default gates remain false.
- Architecture: `Pass with conditions`; Quality: `Partial / bounded pass`;
  Pair remains `Partial` because Full Access/host provenance, normalized geometry,
  PAINT coalescing reason and repeated order-controlled samples remain open.

### P2-PERF-03 — replicated/reverse-order canonical A/B (reviewed, overall Partial)

Before any production-facing wiring or default decision, the recommended next
slice is two order-controlled pairs (`A→B` and `B→A`) on the same device, with a
content-free run manifest, normalized geometry digest, explicit PAINT coalescing
reason and protocol-adherence field. The Assignment is now **reviewed** as
evidence-only; it does not authorize production code or default-gate changes.

- Assignment: [`P2-PERF-03 replicated A/B`](../assignments/t9-responsive-pipeline-001-p2-perf-03-replicated-ab-proposal.md)
- Evidence: [`P2-PERF-03 replicated A/B evidence`](../evidence/t9-responsive-pipeline-p2-perf-03-replicated-ab-2026-08-03.md)
  and [content-free summary JSON](../evidence/t9-responsive-pipeline-p2-perf-03-replicated-ab-summary-2026-08-03.json)
- Independent reviews: [`Architecture`](../assignments/t9-responsive-pipeline-001-p2-perf-03-architecture-review.md)
  and [`Quality`](../assignments/t9-responsive-pipeline-001-p2-perf-03-quality-review.md)
- Four valid arms completed on the same iPhone 13 Pro: A1 `2.5/4`, B1 `1/4`,
  B2 `1/4`, A2 `3/4`; B lower stall score in both A→B and B→A orders. A sync
  T9SEG max `242.3/246.5ms`; B immediate T9SEG max `0.8/0.7ms`; B ACCEPT/PUBLISH
  `39/39` in both arms. B PAINT missing-reason and runtime tokenless geometry
  remain residual evidence debt.
- Ordinary Release restore and Human keyboard-switch smoke passed. Keep both gates
  default-off, ADR 0025 Proposed, and no Product Gate or Release claim pending
  a separate Product decision. Architecture review is `Pass with conditions`
  (`0/0/4/2`); Quality review is bounded condition pass but overall `Partial`
  (`0/0/4/3`).

### P3-D1-T02/T03 — Target lifecycle harness Product Hold (2026-08-03)

- Assignment: [`P3-D1-T02/T03 Lifecycle Harness`](../assignments/t9-responsive-pipeline-001-p3-d1-t02-t03-lifecycle-harness.md)
- Matrix: [`P3-D1 Runtime Lifecycle Evidence Matrix`](../assignments/t9-responsive-pipeline-001-p3-d1-runtime-lifecycle-matrix.md)
- Bounded result: harness-on/gate-off builds passed; Wire **10/0**, validator **6/0**,
  KeyboardCore full **901/0**; Architecture and Quality both **Pass with conditions**.
- Host result: T02/T03 **Blocked (host accessibility)** because the Simulator Messages host
  did not expose a provable system-keyboard activation boundary.
- Product disposition: Human Product Owner selected **Option 1 Hold**. No further code,
  test or device execution is authorized under this slice; reopening requires a new Product
  Assignment and fresh acknowledgement.

### R6 — Gates

- Independent Architecture Pass (ADR 0025 readiness, isolation, lifecycle)
- Independent Quality Pass (tests, builds, device evidence binding)
- Human Product Gate (Release default policy)

## Acceptance matrix

### Fixture

| Field | Value |
|---|---|
| Spelling | `jintiandetianqizhenbucuowomenchuquwanba` |
| Log identity | Fixed fixture ID (e.g. `T9RESP-FIX-001`), never raw spelling in prod logs |
| Host app (device) | Reminders |
| Operator | Human Product Owner |

### Automated minimum cases

1. 150 ms Fake RIME delay: entry accepts full sequence without per-key wait.
2. No drop / no duplicate / stable order.
3. Old revision cannot overwrite newer published state.
4. `sessionEpoch` change invalidates in-flight results and clears queue.
5. UI may publish only latest snapshot under burst input.
6. Delete, candidate, Path, reset ordering contracts.
7. Stale candidate reference → fail closed.
8. Marked text never contains internal T9 digits.
9. 26-key behavior unchanged with gate off.
10. Release default equals baseline before Product Gate.

### Metrics (collection only until Product locks budgets)

| Metric | Purpose |
|---|---|
| Action → local feedback latency | Prove responsiveness goal |
| Action → published snapshot latency | RIME lag visibility |
| Max revision lag | How far UI trails engine head |
| Max pending depth | Queue / memory risk |
| Discarded stale count | Coalesce health |
| Drop/dup/wrong-select/exit counts | Correctness incidents |
| `process_key` api/collect split | Engine cost still measurable |

Do **not** invent formal numeric SLOs in R0–R1.

## Risk register

| Risk | Mitigation |
|---|---|
| Race if any RIME API bypasses serial owner | Single entry type; tests that fail on off-owner use in debug |
| Marked text flicker / partial Path | Atomic publish rule |
| Delete vs pending keys | Strict ordered enqueue in v1; cancel protocol only with tests |
| Extension jetsam under deep queue | Measure depth; Product decides cap/drop later |
| ADR 0004 conflict | Keep 0004 Accepted; 0025 Proposed until review |
| Scope bleed into auto-anchor | Separate Assignment IDs; no S2.4 naming |
| Swift 6 isolation debt | Forbid `@unchecked Sendable`; prefer actor/serial executor |

## Recommended Product next step after R0 acceptance

Authorize **R1 only**:

```text
我作为 Human Product Owner / Product Lead，确认
T9-RESPONSIVE-PIPELINE-001 的 Assignment 与 Proposed ADR 已达到实现入口要求。

我授权 Grok 仅实施 Assignment 中的 R1：
使用可控延迟的 Fake RIME 建立响应式输入状态机和回归测试。
暂不迁移真实 librime session，暂不改变 Release 默认行为。

完成后停止，提交 changed files、测试结果、未执行验证和残余风险，
交给独立 Architecture 与 Quality 审查。
不得自行宣布 Product Gate 或独立审查通过。
```

## Discussion log

| Date | Note |
|---|---|
| 2026-07-30 | Product pivots from auto-anchor expansion to responsive serial pipeline after S2.3 direction FAIL; R0 design authored from baseline `dddbe61`. |
| 2026-07-30 | Human Product Owner authorized R1 only. `ResponsiveRimePipeline` + 17 focused tests landed; no real session migration; independent Arch/Quality review next. |
| 2026-07-30 | Independent Arch/Quality R1 reviews: Pass with conditions. P1-2/P1-3 freezes in ADR 0025 §§10–11; P1-1 code+tests remediated same day (applied/published split, catch-up, reset/recover epoch). Focused 23 / full 801 green. R2+ / Product Gate / ADR Accept not claimed. |
| 2026-07-30 | Human Product Owner authorized isolated Spike-P1-3 design + falsifiable thread-affine Fake proof only; real librime/R4, device/R5, ADR Accept and Product Gate remain closed. |
| 2026-07-30 | Independent Architecture/Quality reviews of `45c426f`: Fail on shared P1 (omitted shutdown orphans thread/engine). Remediation written; validation/re-review pending. |
| 2026-07-31 | Lifecycle P1 remediated (`requestStop` + deinit safety net; stall inside Fake `processKey`; lifecycle tests). Re-validated Spike 7/7 and KeyboardCore 823/823. Independent Architecture/Quality re-reviews: **Pass with conditions**. Arch residual P2 (factory / delivery FIFO / unbounded mailbox) remain for R4. ADR still Proposed; gate still off; R4 / Product Gate / device not claimed. |
| 2026-07-31 | Human Product Owner authorized **R4-Owner** (design → implement → dual review) to close Arch P2 owner residuals; R4-B real librime / R5 / R6 / ADR Accept / Product Gate remain closed. |
| 2026-07-31 | R4-Owner implemented (bootstrap + ordered delivery + bounded refuse-at-bound). Tests 10/10 focused, 826/826 full. Independent Arch/Quality: **Pass with conditions**. D1–D3 Closed in R4-Owner scope; R4-B / ADR Accept / Product Gate still closed. |
| 2026-07-31 | Human Product Owner authorized **R4-B** (real librime config-only bootstrap + Simulator/RimeBridge evidence; design→implement→dual review). Extension production wire / ADR Accept / Product Gate remain closed. |
| 2026-07-31 | R4-B implemented: `ThreadAffineRimeEngineImplBootstrap`, Simulator tests 2/2 (`R4B_REAL_ENGINE_RESULT passed=true`), KeyboardCore 10/826 green. Independent Arch/Quality: **Pass with conditions**. Real bootstrap proof Closed; Extension wire / ADR Accept / Product Gate still closed. |
| 2026-07-31 | R4-Wire dual-gate controller path (`be4c4ac`). R5-Preflight authorized: DEBUG App Group key / compile flag arms dual-gate + content-free `T9RESP` markers; Release default-off. Formal R5 A/B not claimed. |
| 2026-07-31 | R5-Preflight implemented (`87d3e7c`); dual Arch/Quality **Pass with conditions**. Physical iPhone 13 Pro path on (`thread-affine` Active=1 + READY + PUBLISH) / off (`sync` Active=0) **Pass**. **R5-Preflight Closed**. Formal R5 A/B / ADR Accept / Product Gate / default-on still not authorized. |
| 2026-07-31 | Human Product Owner authorized **formal R5**. Design freeze + A/B Debug packages built; Arm A installed on iPhone 13 Pro; Human A→B pair pending. |
| 2026-07-31 | Formal R5 pair complete: **direction FAIL** (B freeze-then-burst worse than A). Teardown gate-off. Remediation not authorized. |
| 2026-07-31 | Human authorized **R5-Remediation design only**. Freeze O1–O3 + Rem-1… phases; implementation still closed. |
| 2026-07-31 | Human authorized **R5-Rem-1+2** implement. Felt metrics + dual-gate UI coalesce + latestOnly; tests 841/0. Dual review pending; no Rem-3/device/Gate. |
| 2026-07-31 | Independent Arch + Quality subagents: **Pass with conditions**. Arch P1-1 presentation epoch gate after abandon; Quality re-run 48+841/0. No Gate / Rem-3 / device. |
| 2026-07-31 | Arch **P1-1 Closed**: presentation generation + live epoch gate + abandon coalesce test. Rem-Device next (Human auth). |
| 2026-07-31 | **R5-Rem-Device direction PASS**: dual-gate key-feel better than gate-off; no freeze-burst; VISIBLE lag spikes remain; not Product Gate. |
| 2026-07-31 | PR **#37** (rem) merge-commit into preflight `2e8c047`; PR **#36** merge into **`main` `7665c64`**. Feature branches `codex/t9-responsive-r5-preflight`, `codex/t9-responsive-r5-rem`, `codex/t9-auto-anchor-s5-checkpoint` safely deleted after reachability. |
| 2026-07-31 | Doc hygiene: Assignment/plan/PD/dashboard/index/changelog aligned to merge + Rem-Device Closed; **Rem-3 design** authored (implementation was still closed **at that point**). |
| 2026-08-01 | Rem-3-Device and Polish-2 device direction PASS; current-tip independent Arch/Quality review ran on `80ef54b` (focused 22/0, full 854/0) and found P1-D2: stable stale Candidate/Path chrome conflicts with frozen disabled/cleared affordance contract. Product/Architecture Amendment or implementation correction is required; dual-gate remains default-off. |
| 2026-08-01 | Product selected **P1-D2 Amendment B**: stable L2 marked text + pending `·` visual shadow, stable stale chrome, and fail-closed Candidate/Path/Space/paging/correction actions. Final bounded implementation/review is **Pass with conditions** (16/0 focused, 858/0 full); P1-1/P1-2 closed, four P2 evidence debts remain; gates remain default-off. |
| 2026-08-01 | **P2-Regression-Matrix-001** Core subset received independent Architecture/Quality re-review **Pass with conditions**; P2-EPC host-history count/empty assertion is closed at bounded Core/Fake-host scope. Focused 19/0, full 861/0, repair rerun 3/0; UIKit prefetch/real UI owner observation and real-device/performance evidence remain open. |
| 2026-08-03 | **P2-PERF-02 canonical A/B** completed on iPhone 13 Pro: A sync total max 181.8ms / Human 2/4; B thread-affine immediate T9SEG max 0.7ms, PUBLISH 39/39 / Human 0.5/4; ordinary restore smoke passed. Independent Architecture/Quality retained bounded `Partial`; no default-on, ADR Accept or Product Gate. |
| 2026-08-03 | **P2-PERF-03 replicated/reverse-order A/B** authorized and activated. It covers A→B and B→A evidence-only arms for order effects, normalized geometry and PAINT coalescing receipts; production code and default gates remain unchanged. |
| 2026-08-03 | **P2-PERF-03 four-arm execution complete** on the same iPhone 13 Pro: A1/B1/B2/A2 valid and token-bound, B lower subjective stall score in both orders, ordinary Release restored and smoke confirmed. Evidence is handed to independent Architecture / Quality; B PAINT missing-reason and runtime tokenless geometry remain open, with no ADR/Product Gate/default-on claim. |
| 2026-08-03 | **P2-PERF-03 independent reviews complete**: Architecture `Pass with conditions` (P0/P1/P2/P3 `0/0/4/2`), Quality bounded condition pass but overall `Partial` (`0/0/4/3`). Handoff stops at Product Lead; any production-shaped canary needs a new Assignment and explicit authorization. |
| 2026-08-04 | **CANARY-001 authorized** by Human Product Owner (`我授权你，接下来就在我的iPhone 13 Pro上进行测试吧！`); production-shaped default-off canary design freeze + implementation + run004 automated matrix complete. |
| 2026-08-04→05 | **CANARY-001 / DEVICE-001 pair-002 four-arm (A/B/K/O) execution complete** on iPhone 13 Pro: A sync stallScore `2.5`; B R5P provisional stallScore `0` at same slow-RIME positions (208–242ms); K kill-switch assert written/readback (`decision=kill`) with extension fail-closed to baseline and no canary ACCEPT after; O ordinary Release restored with matching hashes and clean Human smoke. Device evidence closed; independent Arch/Quality review pending. Not ADR 0025 acceptance, not Product Gate, not default-on. |
| 2026-08-05 | **CANARY-001 disposition = Stop/Retain** (Human Product Lead): device evidence archived under default-off; no further device evidence phase. Independent Arch (`Pass with conditions` 0/0/1/0) and Quality (`Pass with conditions` 0/0/5/3) recorded; most P2/P3 residuals closed, P2-04/P3-01/P3-02 stay open with honest attestation. ADR 0025 remains Proposed *at that time*; Product Gate / default-on then still closed. |
| 2026-08-06 | **ADR 0025 Accepted** (`ADR-0025-ACCEPT-001`); POST-ACCEPT hygiene; **ALL-LAYOUTS-001** L0 universal for Chinese 26-key + T9; **RESPONSIVE-DEFAULT-ON-001 Product Gate** — ordinary Release **requests dual-gate** by default with fail-closed ADR 0004 sync; Arch/Quality Pass with conditions; no SLO / no App Store claim by Gate alone. |
