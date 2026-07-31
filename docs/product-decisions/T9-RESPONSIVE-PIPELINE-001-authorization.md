# Product Decision: T9-RESPONSIVE-PIPELINE-001 — 九宫格响应式 RIME 输入管线

**Decision ID:** `PD-T9-RESPONSIVE-PIPELINE-001`  
**Lifecycle status:** `Recorded — R5-Rem-Device Closed direction PASS 2026-07-31; Formal R5 FAIL historical; code published to main via #36/#37 @ 7665c64 (default-off dual-gate retained); Rem-3 design next; R6 / ADR Accept / Product Gate / default-on not authorized`
**Date / timezone:** `2026-07-30 Asia/Shanghai`  
**Decision source:** Human Product Owner direction in Codex task
`019f9dac-ff8d-7872-a913-d5dd3f930dc1`, resumed and design-phase-started in the
active Grok session on `2026-07-30 Asia/Shanghai`  
**Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](../assignments/t9-responsive-rime-pipeline-001.md)  
**Plan:** [`t9-responsive-rime-pipeline-plan.md`](../plans/t9-responsive-rime-pipeline-plan.md)  
**Architecture (Proposed):** [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)  
**Predecessor (Hold/harvest):** [`PD-T9-AUTO-ANCHOR-001`](T9-AUTO-ANCHOR-001-authorization.md),
[`T9-AUTO-ANCHOR-001`](../assignments/t9-auto-anchor-001.md)

## Authority

- **Product Approver / Decision maker:** Human Product Owner acting as Product Lead
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)
- **Domain Owner:** 🧠 Input Intelligence Maintainer
- **Executor (this design phase):** Current Grok session, limited to KOS
  governance, read-only architecture audit and implementable design documents
- **Architecture / Quality review:** Required before any R1+ production-facing
  implementation; self-review by the Executor is not independent Architecture
  or Quality authority

## Product problem

On Chinese nine-key, long uninterrupted composition (frozen sequence
`jintiandetianqizhenbucuowomenchuquwanba` / 38 T9 slots) still feels laggy even
after schema knobs, idle Path education and default-off auto-anchor experiments.

Repository evidence attributes the dominant cost to librime `process_key`
(`api`), not to local Path catalog math. Under the current model, touch handling
waits for RIME before marked text, Path and candidates can refresh, so engine
spikes become **felt key latency**.

Native and third-party nine-key keyboards feel responsive under the same
subjective long-sentence test. Product therefore prioritizes **subjective
non-stutter** over zero RIME result lag.

## Product direction (locked)

Stop expanding `T9-AUTO-ANCHOR-001` S2.x automatic-anchor count or aggressiveness.
Retain the default-off S2.1–S2.3 stack and its evidence. The new primary direction
is:

> Key input and visual/haptic feedback must not wait for RIME.
> RIME runs in a dedicated serial execution context.
> Composition/candidate results may appear slightly later.

This is an architecture/product pivot from “shorten the ambiguity graph so
`process_key` is faster” to “decouple key responsiveness from engine wall time”.
It is **not** a rebrand of S2.4 or Stage 3 of the auto-anchor plan (those names
already mean other things).

## Bound product decisions

### 1. Responsiveness over zero result lag

1. Immediate key press feedback (visual, system click, haptics per existing
   feedback settings) must not be gated on `process_key` completion.
2. A short delay before marked text / Path / candidates settle is acceptable if
   keys never feel frozen, lost, duplicated or reordered.
3. Formal numeric SLOs are **not** set in this Decision. Define measurement
   methods and experiment budgets first; Product Lead locks thresholds later
   from real-device baselines.

### 2. Preserve ordering; allow UI snapshot coalesce only

1. Every user key/action that enters the RIME pipeline must be preserved in
   order. First implementation must not drop, merge or reorder RIME input events
   to “catch up”.
2. UI may publish only the latest coherent snapshot while older in-flight results
   are discarded as stale.
3. Coalescing is a **publish** concern, not an **input** concern.

### 3. Fail closed on stale interaction

1. Candidate taps, Path taps and other snapshot-bound actions that reference an
   expired revision must fail closed (no host commit, no silent wrong selection).
2. Delete, schema change, visibility change, session recovery and process restart
   must invalidate in-flight work coherently (see Assignment state model).

### 4. Unchanged product contracts

The following remain binding and are non-negotiable for this work item unless a
later Product Decision amends them:

- 26-key / `rime_ice` behavior unchanged unless separately authorized
- Host-facing T9 marked text never shows internal digits
- Path authorization and ADR 0020–0023 contracts
- Partial Commit ownership and Delete composition-first rules
- User dictionary / learning privacy boundaries
- Main App deploys; Extension runtime is session-only (ADR 0001–0003)
- Content-free diagnostics only (no raw input / pinyin / candidate / host text
  in logs)

### 5. Relationship to auto-anchor

1. `T9-AUTO-ANCHOR-001` remains **Hold/harvest** after S2.3 direction FAIL.
2. Default-off S2.1–S2.3 code and evidence stay; do not rewrite S2.3 as success.
3. Do not reuse auto-anchor Product Gate or stage authorization for this work.
4. Future interaction between auto-anchor and a responsive pipeline requires a
   separate Product Decision after the responsive path has independent evidence.

### 6. Release default

1. Until Product Gate, Release default behavior must remain equivalent to today
   (feature behind explicit Debug/internal gate as designed in phases).
2. Shipping enablement requires independent Architecture Pass, Quality Pass and
   Human Product Gate.

## Authorized now

### R0 (design) — completed

- KOS 2.0 Product Decision, Assignment, plan and Proposed ADR records
- Read-only architecture audit against current sources
- Acceptance matrix and phased plan (R0–R6 design)
- Navigation updates that link the new work item and successor relationship

### R1 (2026-07-30 Human Product Owner authorization) — implemented

- Controllable-delay Fake RIME + pure KeyboardCore responsive state machine
- Focused regression tests proving accept-without-wait, ordering, revision /
  epoch, coalesce publish, fail-closed selection, and default-path isolation
- Documentation updates for R1 status

### R2 (2026-07-30 Human Product Owner authorization) — implemented

- Default-off `isResponsiveRimePipelineEnabled` on `KeyboardController`
- `SerialRimeSessionOwner` + `ResponsiveRimeSessionCoordinator` (single-consumer
  MainActor owner; deferred drain so `handle` returns before librime for keys)
- Hot-path gate: Chinese composition `processKey` via `scheduleProcessKey` when
  enabled; Release default remains ADR 0004 synchronous path
- Visibility abandon bumps pipeline epoch when gate on
- R2 coordinator tests; no Release default-on; no ADR 0025 Accept

**R2 isolation note (honest):** Swift 6 region isolation cannot move non-Sendable
`RimeEngine` off MainActor without forbidden `@unchecked Sendable` shuttling.
R2 therefore uses a single-consumer **MainActor** owner with deferred drain
rather than a background actor holding librime. Off-main librime remains an
Architecture residual for a later authorized design.

### Phase A freeze (2026-07-30)

Product chose: **stabilize docs/PR first**, then implement **R3** under explicit auth.
See [`t9-responsive-pipeline-001-phase-a-freeze-2026-07-30.md`](../assignments/t9-responsive-pipeline-001-phase-a-freeze-2026-07-30.md).

### R3 (2026-07-30 Human Product Owner authorization) — implementing

**Allowed (default-off only):**

- Gate-on **behavior parity** for Path / auto-anchor post-processing after deferred publish
- `handle`-level multi-action order tests (e.g. key → delete)
- Extension chrome resolve underlying engine through bridge (no bare `as? RimeEngineImpl` only)
- Optional: symbol-page replace scheduling cleanup without Release default-on
- Docs/evidence; no ADR 0025 Accept; no Product Gate self-claim

**Forbidden:**

- Release default-on / user settings
- Off-main librime spike (Arch P1-3) unless later separate auth
- Expanding T9 auto-anchor
- `@unchecked Sendable` isolation bypass

### Spike-P1-3 (2026-07-30 Human Product Owner authorization) — authorized

**Allowed:**

- Proposed thread-affine single-consumer design beside ADR 0025;
- a default-disconnected dedicated-thread owner created only for the Spike;
- Fake/controlled-delay proof that MainActor accept continues during a 150 ms+
  owner stall;
- FIFO/no-drop proof, revision/sessionEpoch MainActor validation, gate-off
  equivalence tests and content-free evidence;
- independent Architecture and Quality review after the Executor freezes the
  Spike evidence, followed by in-scope remediation/re-review.

**Required isolation shape:**

- the non-Sendable engine is created, used and released inside the owner thread;
- only Sendable work descriptors enter and Sendable snapshots leave;
- no `@unchecked Sendable` or unsafe isolation bypass.

**Not authorized by this Spike:**

- real `RimeEngineImpl` production wiring or R4 matrix;
- R5 device A/B, R6 Product Gate, ADR 0025 acceptance or Release default-on;
- dropping/coalescing input events or expanding auto-anchor.

Design:
[`t9-responsive-pipeline-001-spike-p1-3-design.md`](../assignments/t9-responsive-pipeline-001-spike-p1-3-design.md).

### R4-Owner (2026-07-31 Human Product Owner authorization) — authorized

Human Product Owner instruction: design → implement → independent review,
with KOS 2.0 role separation. Product Lead names this knife **R4-Owner**.

**Product intent:** close Spike-P1-3 Architecture residual **P2** items that
block any future off-main production owner, without claiming real-librime
device readiness or Release enablement.

**Allowed (default-off, disconnected owner only):**

1. **Architecture design freeze** for the three Arch P2 residuals:
   - concrete Sendable bootstrap / config-only engine construction;
   - ordered MainActor delivery channel + terminal acknowledgement;
   - bounded mailbox / backlog / refuse-at-bound policy that does **not** drop
     already-accepted input and does **not** reorder process-key FIFO.
2. **KeyboardCore implementation** of that owner contract on the thread-affine
   path (Fake/probe engines allowed and preferred for focused tests).
3. Focused + full KeyboardCore regression evidence.
4. Independent Architecture and Quality review of design+implementation; in-scope
   remediation + re-review only inside this boundary.

**Product policy freezes for R4-Owner (binding):**

| Topic | Decision |
|---|---|
| Input drop/merge/reorder | **Forbidden** for accepted process-key work |
| Mailbox at capacity | **Refuse new accept** (return nil / rejected); never drop accepted FIFO items |
| Control ops (stop / epoch) | May use a **control priority lane** that does not reorder process-key relative to process-key |
| Stale post-epoch work | May skip execution and count as discard (not an input drop) |
| Gate / ADR / Release | Stay **off / Proposed / unchanged** |
| Extension / `RimeEngineImpl` production wire | **Not** in R4-Owner |

**Not authorized by R4-Owner (deferred as R4-B / later):**

- real `RimeEngineImpl` Simulator matrix, gate-off vs gate-on content-free
  comparison, or Extension production path migration;
- R5 device A/B, R6 Product Gate, ADR 0025 Accept, Release default-on;
- full RimeEngine API surface (Delete / Path / select / page / recover) production
  wiring — design may **name** how they enter the same owner later, but R4-Owner
  implementation may stay processKey-first if needed to keep the knife small;
- expanding T9 auto-anchor.

Design (Architecture-owned once written):
[`t9-responsive-pipeline-001-r4-owner-design.md`](../assignments/t9-responsive-pipeline-001-r4-owner-design.md).

### R4-B (2026-07-31 Human Product Owner authorization) — authorized

Human Product Owner instruction: continue under KOS 2.0 and complete **R4-B**.

**Product intent:** prove that the R4-Owner thread-affine contract can host a
**real** `RimeEngineImpl` built only from Sendable path configuration on the
owner thread, with Simulator/RimeBridge evidence — without shipping gate-on or
Extension production migration.

**Allowed (default-off; no Product Gate):**

1. Architecture design freeze for real-librime bootstrap + evidence matrix.
2. RimeBridge (and minimal KeyboardCore availability fixes if required for iOS):
   - Sendable config-only bootstrap (`sharedDataDir` / `userDataDir` strings);
   - dedicated-thread create / processKey / destroy with real librime;
   - short frozen sequence / content-free ordering proof;
   - gate-off baseline: 26-key / direct engine path remains available when
     responsive gate is off (no Release default change).
3. Isolated runtime fixture harness (env-dir or scripted copy; never mutate the
   user's formal App Group as the only runtime).
4. Independent Architecture and Quality review; in-scope remediation only.

**Forbidden / not claimed by R4-B:**

- Extension / `KeyboardController` production wire of the thread-affine owner;
- Release default-on or user-facing settings;
- ADR 0025 Accept, Product Gate, R5 device A/B, R6;
- Full session API production routing (Delete/Path/select/page may remain out
  of this knife if processKey proof is the minimum real-librime claim);
- Expanding T9 auto-anchor;
- Claiming subjective non-stutter on device.

Design (Architecture-owned once written):
[`t9-responsive-pipeline-001-r4-b-design.md`](../assignments/t9-responsive-pipeline-001-r4-b-design.md).

### R4-Wire (2026-07-31 Human Product Owner authorization) — authorized

Human Product Owner: complete **接线** under KOS 2.0.

**Product intent:** connect the R4-Owner / R4-B thread-affine owner into the
`KeyboardController` responsive path so gate-on processKey no longer runs
librime on MainActor — while **both gates remain default-off**.

**Allowed:**

1. Architecture design freeze for dual-gate wire (`isResponsiveRimePipelineEnabled`
   + `isThreadAffineRimeOwnerEnabled`, both default `false`).
2. Expand thread-affine owner work surface to full `ResponsiveRimeWork`.
3. Controller rebuild installs thread-affine coordinator + bridge when **both**
   gates are on and a Sendable bootstrap is provided.
4. Visibility suspend/finalize uses explicit stop/epoch (not deinit-only).
5. KeyboardCore + optional RimeBridge tests; default-off path unchanged.
6. Independent Architecture and Quality review.

**Forbidden / not claimed:**

- Release default-on or flipping either gate true by default;
- ADR 0025 Accept, Product Gate, R5 device A/B;
- Claiming subjective non-stutter on device;
- Dual-entry: live MainActor engine **and** owner engine for the same session;
- Expanding T9 auto-anchor.

Design: [`t9-responsive-pipeline-001-r4-wire-design.md`](../assignments/t9-responsive-pipeline-001-r4-wire-design.md).

### R5-Preflight (2026-07-31 Human Product Owner authorization) — Closed

Human Product Owner authorized continuation after R4-Wire: prepare **device
preflight diagnostics**, not formal R5 Product Gate.

**Allowed (completed):**

1. Debug / explicit compile-flag arming of dual-gate (`responsive` +
   `threadAffine`) via App Group UserDefaults and/or
   `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` (never project Release default).
2. Extension install of `ThreadAffineRimeEngineImplBootstrap` from already-known
   runtime directories when dual-gate is armed.
3. Content-free diagnostic markers/logs (path mode, fixture ID, revision/epoch,
   accept/publish timing counters — **no** raw input / pinyin / candidates /
   host text).
4. KeyboardCore unit tests for default-off + arm resolution.
5. Independent Architecture / Quality review of preflight-only scope.
6. Optional physical on/off path verification (Human + Environment Executor) —
   **completed 2026-07-31** on iPhone 13 Pro
   ([evidence](../evidence/t9-responsive-pipeline-r5-preflight-2026-07-31.md)).

**Close decision (Product Lead, 2026-07-31):** R5-Preflight **Closed** after
unit evidence, dual independent review Pass with conditions, and device path
on/off matrix. Does **not** open formal R5, R6, ADR Accept, Product Gate or
Release default-on.

**Forbidden / still not claimed by this close:**

- Formal R5 Human A/B conclusion or Product Gate;
- Release default-on either gate;
- ADR 0025 Accept;
- User-facing settings UI for the dual-gate (Debug App Group keys / compile flags only);
- Claiming subjective non-stutter from preflight logs alone.

### Formal R5 (2026-07-31 Human Product Owner authorization) — Closed direction FAIL

Human Product Owner instruction: 「根据KOS2.0设定完成R5工作吧」.

**Product intent:** complete formal R5 Human device A/B for the dual-gate
thread-affine path vs gate-off baseline, using content-free diagnostics and
subjective non-stutter scores. **Not** Product Gate / ADR Accept / default-on.

**Outcome (2026-07-31):** One stop-fast A→B pair on iPhone 13 Pro.
Gate-off A: stall severity 2 with mid/late KEY END spikes (~175–215 ms).
Dual-gate B: KEY END ~1 ms but Human **freeze-then-burst** mid composition
(severity 4), worse than A. Direction gate **FAIL**.
Evidence: [`../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md).

**Product disposition:** Formal R5 **Closed as direction FAIL**. Do not enable
dual-gate for product use. Do not claim Product Gate / ADR Accept / default-on.
Remediation (publish-lag / backlog / provisional composition metrics) requires
a **new** Product authorization.

**Forbidden / still not claimed:**

- Product Gate, Release default-on, ADR 0025 Accept, R6;
- Coordinate XCTest / Computer Use typing;
- Inventing numeric SLOs;
- Claiming Release-like Product conclusion from Debug arms alone;
- Expanding auto-anchor.

### R5-Remediation design (2026-07-31 Human Product Owner authorization) — Closed design

Human Product Owner instruction: 「我更想要授权 remediation 设计」.

**Product intent:** freeze Architecture design for fixing Formal R5 dual-gate
**freeze-then-burst** without claiming Product Gate or default-on.

Design freeze:
[`r5-remediation-design`](../assignments/t9-responsive-pipeline-001-r5-remediation-design.md).

### R5-Rem-1 + R5-Rem-2 implementation (2026-07-31 Human Product Owner authorization) — Closed Executor + dual review + P1-1

Human Product Owner instruction: implement Rem-1 + Rem-2 only — felt metrics +
dual-gate UI latest-only / R3 context decoupling; no Rem-3; no default-on; no
ADR Accept; no Product Gate.

**Closed outcomes:**

1. O1 content-free accept→visible / publish-lag / pending / burst markers + tests.
2. O2 dual-gate UI latest-only under lag; MainActor R2 true latestOnly; R3
   contexts bind to applied head (not everyResult paint).
3. Independent Architecture + Quality **Pass with conditions**; Arch **P1-1**
   presentation generation / live epoch gate Closed.

Evidence:
[`../evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md).

### R5-Rem-Device (2026-07-31 Human Product Owner authorization) — Closed direction PASS

Human Product Owner authorized **Rem-Device** Human A/B on iPhone 13 Pro after
Arch P1-1 close.

**Outcome:** One A→B pair. Gate-off A: stall ~2, KEY END ≥100 ×4 (worst ~211 ms).
Dual-gate B (Rem-1+2): KEY END ~1 ms; VISIBLE lag p50 ~11 ms with residual
spikes ~190–246 ms; Human stall ~0–1 — **clearly better key follow**, no
freeze-then-burst (unlike Formal R5 dual-gate FAIL). Direction **PASS** for
key-feel; **not** Product Gate / default-on / ADR Accept.

Evidence:
[`../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md).

### Publication (2026-07-31) — Closed on `main`

- PR [#37](https://github.com/shchnk1103/Universe-Keyboard/pull/37) merged into
  `codex/t9-responsive-r5-preflight` (`2e8c047`).
- PR [#36](https://github.com/shchnk1103/Universe-Keyboard/pull/36) merged into
  `main` (`7665c64`) including Rem-1+2 + Rem-Device docs + Sendable fix.
- Feature branches deleted after `origin/main` reachability checks.
- Dual-gate remains **Debug/preflight default-off** on Release paths.

### R5-Rem-3 (2026-07-31) — Design freeze + dual review + Amendment A; implementation not authorized

Human Product Owner authorized **documentation hygiene** then **Rem-3 design
only** (provisional L1). Independent Architecture + Quality design reviews on tip
`617773e`: both **Pass with conditions**. Design **Amendment A** closed Arch
P1-1…P1-4 (revision watermark, provisional ledger, `·`×N algorithm,
provisionalAhead fail-closed) and Quality progressive/metric conditions.

Implementation, device re-pair, R6, ADR Accept, Product Gate and default-on remain
closed until a later explicit instruction.

Design:
[`t9-responsive-pipeline-001-r5-rem-3-design.md`](../assignments/t9-responsive-pipeline-001-r5-rem-3-design.md)  
Arch review:
[`t9-responsive-pipeline-001-r5-rem-3-architecture-review.md`](../assignments/t9-responsive-pipeline-001-r5-rem-3-architecture-review.md)  
Quality review:
[`t9-responsive-pipeline-001-r5-rem-3-quality-review.md`](../assignments/t9-responsive-pipeline-001-r5-rem-3-quality-review.md).

## Not authorized now

- Changing Release default input path or user-facing settings
- R5-Rem-3 **implementation** (design only is open)
- R6, ADR 0025 Accept, Product Gate, shipping dual-gate default-on
- Expanding T9 auto-anchor
- Rewriting Formal R5 FAIL as Product success

## Phased product view (summary)

| Phase | Intent | Mutation |
|---|---|---|
| R0 | Design + content-free measurement method | Docs only (this Decision) |
| R1 | Fake RIME delayed serial pipeline + tests | Test/Debug state machine only |
| R2 | Dedicated serial RIME owner behind gate | Default-off production path |
| R3 | revision / sessionEpoch / Delete / candidate contracts | Default-off |
| Spike-P1-3 | Thread-affine Fake isolation proof | Disconnected Spike only |
| R4-Owner | Close Arch P2 owner-contract residuals | Disconnected owner upgrade; default-off |
| **R4-B** | Simulator + real RIME bootstrap evidence | Default-off; disconnected real-engine proof |
| R5 | Human Reminders A/B on device | Evidence only (Formal FAIL; historical) |
| R5-Rem | Felt metrics + UI coalesce + Rem-Device | Closed direction PASS; default-off |
| R5-Rem-3 | Provisional L1 composition | **Design only** open; implementation closed |
| R6 | Independent Architecture, Quality, Product Gate | Shipping decision |

Detailed Exit Criteria live on the Assignment and plan.

## Deferred decisions

Require later Product (and often Architecture) amendment:

- Formal latency / queue-depth SLO numbers
- Whether provisional local T9 display may show before RIME returns
- Interaction with default-off auto-anchor if both are ever considered together
- User-visible “engine busy” affordance (default: none for v1)
- Any Release default-on policy

## Decision source binding

Human Product Owner confirmed (session chain ending 2026-07-30):

1. Subjective non-stutter is more important than zero RIME lag.
2. Auto-anchor expansion stops after S2.3 direction FAIL (Hold/harvest).
3. Next primary track is responsive / serial RIME pipeline, not more anchor knives.
4. Grok may run design-only R0; implementation requires a later explicit
   authorization (recommended first implementation slice: R1 Fake RIME only).
