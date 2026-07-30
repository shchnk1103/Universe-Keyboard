# Product Decision: T9-RESPONSIVE-PIPELINE-001 — 九宫格响应式 RIME 输入管线

**Decision ID:** `PD-T9-RESPONSIVE-PIPELINE-001`  
**Lifecycle status:** `Recorded — R0/R1 done; R2 authorized and implemented (default-off serial owner + deferred key path); R3+ / Release default / ADR Accept / Product Gate not authorized`  
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

## Not authorized now

- Changing Release default input path or user-facing settings
- R3–R6, ADR 0025 Accept, Product Gate
- Declaring Architecture / Quality / Product Gate pass for R2
- Expanding T9 auto-anchor

## Phased product view (summary)

| Phase | Intent | Mutation |
|---|---|---|
| R0 | Design + content-free measurement method | Docs only (this Decision) |
| R1 | Fake RIME delayed serial pipeline + tests | Test/Debug state machine only |
| R2 | Dedicated serial RIME owner behind gate | Default-off production path |
| R3 | revision / sessionEpoch / Delete / candidate contracts | Default-off |
| R4 | Simulator + real RIME integration | Default-off |
| R5 | Human Reminders A/B on device | Evidence only |
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
