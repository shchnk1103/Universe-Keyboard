# Plan: T9 responsive RIME input pipeline

| Field | Value |
|---|---|
| Status | **Active — R5-Rem-Device direction PASS (key-feel); Formal R5 FAIL historical; Rem-3/R6/ADR Accept/Product Gate not claimed** |
| Created | 2026-07-30 |
| Product lock | 2026-07-30 (direction); phase implementation locks later |
| Work item | [`T9-RESPONSIVE-PIPELINE-001`](../assignments/t9-responsive-rime-pipeline-001.md) |
| Product direction | [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md) |
| Architecture | [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) (**Proposed**) |
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

### R5-Remediation — Rem-1+2 Executor complete 2026-07-31 (dual review pending)

Responds to Formal R5 dual-gate **freeze-then-burst** FAIL without rewriting it.

- Design: [`../assignments/t9-responsive-pipeline-001-r5-remediation-design.md`](../assignments/t9-responsive-pipeline-001-r5-remediation-design.md)
- Evidence: [`../evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md)
- **O1 / Rem-1** observability landed (`ACCEPT` / `VISIBLE` / `PUBLISH lagMs` / `BURST`)
- **O2 / Rem-2** dual-gate UI coalesce + true latestOnly + last-head R3 context
- **O3 / Rem-3** provisional L1 — **not authorized**
- Engine FIFO no-drop retained; dual-gate default-off retained
- Full KeyboardCore **841 / 0**

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
