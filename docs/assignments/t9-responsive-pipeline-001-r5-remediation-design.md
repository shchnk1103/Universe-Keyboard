# T9-RESPONSIVE-PIPELINE-001 / R5-Remediation design

**Status:** `Closed as parent design — Rem-1+2 + Rem-Device executed; O3/Rem-3 carried in successor design`  
**Date:** `2026-07-31 Asia/Shanghai`  
**Role author:** 🏛️ Architecture & Knowledge Steward  
**Product:** Human Product Owner authorized remediation **design**, then Rem-1+2,
  then Rem-Device (direction PASS); published to `main` @ `7665c64`  
**Predecessor evidence:**  
  [`../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md)  
  Formal R5 **direction FAIL** — dual-gate freeze-then-burst worse than gate-off  
**Follow-on:**  
  Rem-1+2 [`../evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md)  
  Rem-Device [`../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md)  
  Rem-3 design [`t9-responsive-pipeline-001-r5-rem-3-design.md`](t9-responsive-pipeline-001-r5-rem-3-design.md)  
**Implementation tip baseline (Rem-1+2):** parent of `87d3e7c` → published via #36/#37  
**ADR 0025:** remains **Proposed** (this knife does not Accept)

---

## 1. Problem statement (from Formal R5)

| Arm | Felt experience | Content-free notes |
|---|---|---|
| A gate-off | Stall severity **2**; usable continuous typing | KEY END includes RIME; ≥100 ms ×4; worst ~215 ms |
| B dual-gate | Stall severity **4**; mid-run **freeze**, then **catch-up burst** | KEY END ~1 ms (misleading); async BRIDGE still ~160–207 ms; idle gap ~5 s; many PUBLISH in &lt;50 ms |

**Product failure (north-star):**  
“Keys must not wait for RIME” was satisfied on the **handle return path**, but **composition / marked text / candidates** still lagged until the owner drained a backlog, then flooded the UI. Humans perceive that as **worse** than synchronous stalls.

**Metric failure:**  
`KEY END total` under dual-gate is **not** a felt-latency proxy. Formal R5 D5’s soft latency counters are insufficient alone.

---

## 2. Boundary

### In scope (this design freeze)

1. Root-cause decomposition of freeze-then-burst on dual-gate.
2. Content-free **felt-latency** measurement contract (what to log / test).
3. Frozen remediation **options** ranked; recommended product policy choices.
4. Phased implementation knives (R5-Rem-1 …) with entry/exit and non-claims.
5. Relationship to ADR 0025 §§3–5 (ordered input; optional publish coalesce; atomic snapshot).

### Out of scope / not authorized by this design alone

- Any production code change
- Default-on dual-gate / ADR Accept / Product Gate / R6
- Auto-anchor expansion
- Dropping or reordering RIME session actions to “catch up”
- Inventing numeric SLOs without a new measurement baseline
- Coordinate XCTest / Computer Use typing

---

## 3. Root-cause freeze

### RC1 — Presentation authority lags engine accept

On dual-gate:

1. MainActor **accepts** keys immediately (KEY END ~1 ms).
2. Owner thread runs librime **FIFO** (still ~tens–hundreds ms under long composition).
3. UI composition updates only when `applyResponsivePublishedSnapshot` runs after delivery.
4. When owner is slow, **no progressive composition update** → Human “卡死”.
5. When owner catches up, **many publishes land in a short window** → “瞬间出现所有字”.

Gate-off instead folds RIME into KEY END: painful spikes, but **per-key** composition advances with the finger.

### RC2 — UI publish policy is effectively `.everyResult` on controller rebuild

`KeyboardController.rebuildResponsiveRimeCoordinatorIfNeeded` maps requested
`.latestOnly` to **`.everyResult`** so R3 `responsiveKeyApplyContexts` stay 1:1
with processKey publishes.

Consequence under dual-gate backlog:

- Every drained key attempts a full MainActor presentation (`syncUI`, candidate
  bar, Path post-process context).
- Catch-up becomes a **publish storm**, not a single latest snapshot.

This is a **presentation vs engine-apply coupling** defect relative to ADR 0025 §3
(“UI may coalesce to latest under burst typing”).

### RC3 — Missing felt-latency diagnostics

Existing markers:

| Marker | Measures | Blind spot |
|---|---|---|
| `KEY END total` | handle return | Dual-gate always “fast” |
| `SLOW RIME` / BRIDGE | owner/librime | Not tied to visible composition |
| `T9RESP PUBLISH` | snapshot delivery | Not accept→visible lag |
| `pendingDepth` (pipeline diagnostics) | queue | Not exported on device path as first-class T9RESP |

No content-free **accept → first visible composition update** or **publish lag**
line was available for Formal R5 scoring.

### RC4 — What is *not* the primary RC

- Dual-gate arming itself (path on/off preflight **Pass**).
- librime still being slow (expected; product accepted lag).
- Human mid-arm Path/candidate taps (not used in the FAIL pair).

---

## 4. Design goals

| ID | Goal |
|---|---|
| G1 | Keep: MainActor must not **block** on librime for key accept. |
| G2 | Fix: Continuous typing must show **progressive composition authority** (even if provisional) without multi-second blank freeze. |
| G3 | Fix: Catch-up must not **flood** MainActor with N full UI publishes; prefer **latest coherent** presentation under lag. |
| G4 | Keep: No drop/reorder of RIME session actions; no dual live MainActor+owner session. |
| G5 | Keep: Host never shows internal T9 digits; Path/Partial Commit contracts intact. |
| G6 | Measure: Felt lag with content-free metrics that work on dual-gate. |

---

## 5. Frozen decisions

### D1 — Split three layers (mandatory conceptual model)

| Layer | Responsibility | Isolation |
|---|---|---|
| **L0 Immediate feedback** | Key chrome, click/haptics | MainActor; never waits on RIME |
| **L1 Local composition authority (new)** | Progressive, digit-safe **provisional** preedit the user can see while RIME lags | MainActor pure state; **no** librime |
| **L2 Engine snapshot authority** | Ordered RIME results; Path/candidates; commit-safe selection | Owner serial + MainActor apply |

Today dual-gate has L0 + L2 only. Freeze-then-burst is **L1 missing** + **L2 publish storm**.

**Rule:** L2 always wins when a valid snapshot arrives (epoch/revision). L1 is
**overwritten** atomically by L2; L1 must never commit host text or enable
candidate selection as if it were RIME authority.

### D2 — Presentation policy independent of engine apply policy

| Concern | Policy |
|---|---|
| Engine apply | **Every** enqueued session action still runs in order on the owner (ADR 0025 §3 input). |
| UI presentation under dual-gate lag | Default **latest-only** for composition/Path/candidates once lag exceeds a **design threshold** or pending depth ≥ N. |
| R3 context FIFO | Must be redesigned so Path/auto-anchor post-process does **not** require `.everyResult` UI publish for every key. Contexts bind to **applied revision**, not every intermediate UI paint. |

**Forbidden:** Dropping session actions to empty the queue.  
**Allowed:** Skipping intermediate **UI paints** while still applying engine state and retaining the latest snapshot for the next paint.

### D3 — Content-free felt metrics (device + unit)

New/extended markers (names frozen; values content-free):

```text
T9RESP marker=ACCEPT action=k rev=<n> pending=<d> epoch=<e>
T9RESP marker=VISIBLE lagMs=<ms> rev=<n> source=provisional|engine
T9RESP marker=PUBLISH lagMs=<ms> rev=<n> pendingAfter=<d> coalesced=<0|1>
T9RESP marker=BURST count=<n> windowMs=<ms>   # optional, when ≥K publishes in W ms
T9RESP marker=PATH … (existing)
```

| Metric | Definition |
|---|---|
| `accept→visible lag` | Wall time from key accept to first MainActor update of composition presentation inputs (L1 or L2) |
| `accept→engine publish lag` | Wall time from key accept to L2 snapshot for that action’s revision (or superseded by newer) |
| `pending depth` | Owner/pipeline queue depth after accept |
| `coalesced` | 1 if intermediate UI paints were skipped for this publish |
| `burst count` | Number of L2 UI applies in a short window (detect catch-up storms) |

**Formal R5 lesson:** Direction gates for dual-gate **must** use
`accept→visible` (and subjective), **not** `KEY END total` alone.

### D4 — Remediation option set (ranked)

Product may authorize implementation knives for any subset; default **recommended
sequence** is O1 → O2 → O3.

#### O1 — Observability first (low risk)

- Emit D3 markers on dual-gate (and optionally MainActor-responsive) DEBUG/preflight.
- Unit tests for lag computation and coalesce counters.
- No UX change claim.

**Exit:** Device pair can score `accept→visible` / burst without full log archaeology.

#### O2 — Presentation coalesce under lag (medium risk)

- Dual-gate UI path: **latest-only presentation** when `pendingDepth ≥ P` or
  `accept→engine lag` of head exceeds soft budget B (B is **measurement-only**
  until Product locks a number; implementation uses a named constant
  `presentationCoalescePendingThreshold` default **2** and does not claim SLO).
- Catch-up applies **one** atomic L2 snapshot (latest revision) + single `syncUI`,
  not N× full paints.
- Refactor R3 apply contexts: post-process runs against **underlying** engine at
  applied head; UI paint is not the coupling point.

**Exit:** Under Fake 150 ms/key burst, UI publish count ≪ key count; no multi-second
zero-update window solely due to paint storm after drain (engine lag may remain).

#### O3 — Local provisional composition L1 (higher risk, highest UX leverage)

- On each T9 letter-group key accept under dual-gate, update **provisional**
  composition presentation without waiting for RIME:
  - Digit-safe only (never raw schema digits in host marked text).
  - Prefer reusing existing T9 raw/group display building blocks where they are
    pure and MainActor-safe.
  - Candidates/Path chrome may show “pending engine” empty/stale **fail-closed**
    selection until L2 arrives (no selection against provisional).
- When L2 arrives: atomic replace provisional with engine snapshot (existing
  atomic publish rule).
- Delete/backspace on provisional must stay ordered with enqueued RIME deletes
  (same FIFO; provisional mirror of raw length).

**Exit:** Fake stall ≥150 ms: Human/unit sees progressive provisional updates;
L2 never commits wrong host text; gate-off path unchanged.

#### O4 — Optional later (not in first remediation package)

- Bound owner mailbox already refuses-at-bound; expose depth to UI chrome.
- Adaptive key-repeat / input rate is **out** (product anti-goal: don’t slow the user).
- Release-like measurement surface for Product Gate (separate auth).

### D5 — Product policy freezes for remediation

| Topic | Decision |
|---|---|
| Input drop/merge | **Forbidden** (unchanged) |
| UI paint coalesce | **Allowed and required** under lag (O2) |
| Provisional L1 | **Allowed** under dual-gate only; never gate-off default |
| Candidate select on provisional | **Forbidden** until L2 revision matches |
| Dual-gate default | Remains **off** until later Product Gate |
| Auto-anchor | No expansion |
| Formal R5 FAIL | **Not rewritten** as success; remediation is a successor knife |

### D6 — Implementation phases (authorization units)

| Phase | Work | Code? | Needs separate Product “go implement”? |
|---|---|---|---|
| **R5-Rem-Design** | This document | No | **Done** (design auth) |
| **R5-Rem-1** | O1 observability + tests | Yes | Yes |
| **R5-Rem-2** | O2 presentation coalesce + R3 context decoupling | Yes | Yes (after Rem-1 green or combined auth) |
| **R5-Rem-3** | O3 provisional L1 | Yes | Yes |
| **R5-Rem-Device** | Human A/B re-run vs gate-off with new metrics | Device | Yes |

Recommended Product path after accepting this freeze:

1. Authorize **R5-Rem-1 + R5-Rem-2** together (observability + coalesce) as the
   minimum fix for publish storm.
2. Authorize **R5-Rem-3** if device still shows blank freeze when owner is slow
   but paints are already coalesced.
3. Re-run formal-style device pair only after Rem-2 (or Rem-3).

---

## 6. Architecture constraints (non-negotiable)

1. No `@unchecked Sendable`; no second live librime session on MainActor when
   dual-gate is active.
2. ADR 0004 remains production default until ADR 0025 Accepted + Product Gate.
3. Atomic L2 publish still updates composition + Path + candidates together.
4. Content-free logs only.
5. Fail closed on stale selection (published L2 identity only).

---

## 7. Evidence plan (when implementation is authorized)

| Layer | Evidence |
|---|---|
| Unit | Fake 150 ms/key: accept N keys; UI paint count ≤ f(N); provisional then L2 replace |
| Unit | lagMs monotonic; coalesce flag; burst detector |
| Device | Dual-gate vs gate-off; score accept→visible p50/p95 (descriptive); subjective stall; **no** KEY END-only claims |
| Non-claim | Product Gate / default-on / ADR Accept |

---

## 8. Risks

| Risk | Mitigation |
|---|---|
| Provisional L1 contradicts later L2 (flicker) | Atomic L2 replace; minimize L1 to length/group chrome not full candidates |
| R3 context decoupling regresses Path/auto-anchor | Focused parity tests; gate-off unchanged |
| Coalesce hides bugs | Keep engine apply everyResult; diagnostics show applied vs painted revision |
| Over-scoping into full chrome rewrite | Rem-2 limited to dual-gate presentation path |

---

## 9. Explicit non-claims

- Formal R5 FAIL is not overturned by this design alone.
- No claim that coalesce or provisional makes librime faster.
- No Release default-on.
- No ADR 0025 Accept.
- No numeric product SLO lock in this freeze.

---

## 10. Handoff

**Handoff target:** 🧭 Product Lead for implementation authorization text.

**Suggested Product instruction (Rem-1+2):**

```text
我作为 Human Product Owner / Product Lead，确认
T9-RESPONSIVE-PIPELINE-001 的 R5-Remediation 设计冻结可接受。

我授权仅实施 R5-Rem-1 + R5-Rem-2：
content-free accept→visible / publish-lag / pending / burst 标记与测试；
dual-gate 下 UI latest-only 呈现与 R3 context 解耦（引擎仍 FIFO 全量执行）。
不实施 provisional L1（Rem-3）；不 default-on；不 Accept ADR；不 Product Gate。

完成后停止，提交证据，交独立 Architecture / Quality 审查。
```

**Suggested follow-up (Rem-3)** only if Rem-2 device still freezes without paint:

```text
授权 R5-Rem-3：dual-gate 本地 provisional 组字（L1），L2 原子覆盖；
选择/上屏仍仅绑定 L2；gate-off 不变。
```
