# T9-RESPONSIVE-PIPELINE-001 / R5-Rem-3 design — provisional L1 composition

**Status:** `Active — design freeze only; implementation not authorized`  
**Date:** `2026-07-31 Asia/Shanghai`  
**Role author:** 🏛️ Architecture & Knowledge Steward  
**Product authorization:** Human Product Owner authorized **documentation hygiene**
then **Rem-3 design only** (this document). No implementation, device re-pair,
R6, ADR Accept, Product Gate or default-on.  
**Parent design:**  
[`t9-responsive-pipeline-001-r5-remediation-design.md`](t9-responsive-pipeline-001-r5-remediation-design.md)
(O3)  
**Predecessor evidence:**  
[`../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md)
— Rem-Device **direction PASS** (key-feel); residual VISIBLE lag spikes  
[`../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md)
— Formal R5 **direction FAIL** (historical freeze-then-burst)  
**Publication baseline:** `main` @ `7665c64` (PR #36/#37)  
**ADR 0025:** remains **Proposed**

---

## 1. Why Rem-3 now

### 1.1 What Rem-1+2 + Rem-Device closed

| Outcome | Status |
|---|---|
| Publish storm / freeze-then-burst | Closed on Rem-Device pair (no Formal-R5-style flood) |
| Felt metrics | ACCEPT / VISIBLE / PUBLISH lag / BURST live under dual-gate |
| UI latest-only + P1-1 epoch gate | Closed |
| Key accept without waiting for RIME | Closed (KEY END ~1 ms) |
| Human key-feel vs gate-off | **Direction PASS** (stall ~0–1 vs ~2) |

### 1.2 Residual problem Rem-3 targets

Rem-Device honest caveats still hold:

1. **Result lag is real** — VISIBLE lag p95/worst still ~200–246 ms on slow
   librime keys. Keys do not freeze, but composition authority still **waits for
   L2 (engine snapshot)** before progressive character-level feedback when
   owner is behind.
2. **L1 is still missing** — dual-gate has L0 (accept) + L2 (engine publish).
   Parent remediation D1 named L1 as “local provisional composition authority”.
3. **O2 coalesce was barely exercised** on the PASS pair (`pending≤1`,
   `coalesced=0`). Rem-3 must not assume coalesce is always active.

Product north-star remains: continuous typing must feel progressive; a short
result lag is acceptable if the UI never looks “stuck on the previous
composition for a long silent gap” solely because RIME has not returned.

Rem-3 is **optional leverage**, not a rewrite of Rem-Device PASS. Product may
still choose to Hold L1 and move to measurement / R6 readiness instead.

---

## 2. Boundary

### In scope (this design freeze)

1. Freeze provisional **L1** composition presentation under dual-gate only.
2. Freeze L1 ↔ L2 ownership, digit safety, selection fail-closed, Delete ordering.
3. Freeze content-free metrics / tests / device scoring additions for L1.
4. Implementation phase map, non-claims, Product authorization template.

### Out of scope / not authorized by this design alone

- Any production code change
- Default-on dual-gate / ADR 0025 Accept / Product Gate / R6
- Auto-anchor expansion
- Dropping, merging or reordering RIME session actions
- Inventing numeric product SLOs
- Candidate ranking or Path authority on provisional text
- Main App settings UI for dual-gate
- Coordinate XCTest / Computer Use typing

---

## 3. Layer model (frozen from parent D1, restated)

| Layer | Name | Responsibility | Isolation |
|---|---|---|---|
| **L0** | Accept | Enqueue user action; never block on librime | MainActor |
| **L1** | Provisional composition | Digit-safe progressive preedit the user can **see** while RIME lags | MainActor pure / existing Core pure helpers only; **no librime** |
| **L2** | Engine snapshot | Atomic composition + Path + candidates from serial owner | Owner thread apply → MainActor publish |

**Rules:**

1. L2 always wins when a valid snapshot arrives (matching epoch; presentation
   generation / live-epoch gates from Rem-2+P1-1 still apply).
2. L1 is **overwritten atomically** by L2; never merged field-by-field with a
   half-applied L2.
3. L1 must never `insertText` / commit host text.
4. Selection (candidate / Path / 选定) binds only to **published L2** identity
   (`sessionEpoch` + `revision`). Interaction against provisional-only state
   **fails closed**.
5. Gate-off path remains L0+L2 synchronous (today’s ADR 0004 behaviour); **no L1**.

---

## 4. Frozen decisions

### D1 — When L1 may paint

L1 paints **only if all** hold:

| Check | Requirement |
|---|---|
| Dual-gate active | `isResponsiveRimePipelineEnabled && isThreadAffineRimeOwnerEnabled` (or equivalent live dual-gate path) |
| Action class | Letter-group / digit-key process that extends or shortens composition raw identity; same class as enqueued `processKey` / ordered delete that already goes through the responsive coordinator |
| Not arming | No L1 on 26-key latin direct path unless Product later expands (default: **T9 nine-key composition only**) |
| Epoch | L1 tags the **current** MainActor sessionEpoch at accept time; L2 with older epoch must not paint over newer L1; L2 with matching epoch always replaces |

### D2 — What L1 may show (minimal chrome, maximum safety)

**Allowed (v1 provisional):**

1. **Length-faithful, digit-safe provisional preedit** derived only from:
   - already-known pure MainActor / KeyboardCore pure functions, and/or
   - last good L2 snapshot’s raw/composition scaffolding extended by the
     accepted key count that has not yet received L2.
2. Prefer **group-letter or comment-safe placeholders** already used elsewhere
   for T9 display when pure helpers exist — **never** internal T9 digit strings
   in host marked text (existing host-digit safety contracts).
3. Optional content-free “pending engine” candidate/Path chrome (empty list,
   disabled selection affordance) — not a ranked engine list.

**Forbidden (v1):**

1. Guessing Chinese characters or RIME top-candidate text in L1.
2. Replaying or inventing Path stack selections.
3. Calling `RimeEngine` / bridge / owner from the L1 paint path.
4. Persisting L1 into Partial Commit / auto-anchor ownership ledgers.
5. Host commit from L1.

**Flicker policy:** brief L1→L2 replacement is acceptable; multi-second blank
or digit flash is not. If a pure digit-safe provisional string cannot be built
for a given accept, **skip L1** for that key (L0 still accepts; wait for L2)
rather than paint digits.

### D3 — Delete / backspace

1. User delete enqueues RIME delete on the owner **in order** (unchanged FIFO).
2. L1 length/content must **mirror accepted raw length** after the delete accept
   (provisional mirror), not wait for L2 to shorten the visible preedit when a
   safe mirror exists.
3. If L1 cannot safely mirror, clear provisional to last L2 or empty and wait
   for L2 (fail closed on display, not on enqueue).

### D4 — Selection and Partial Commit

| Action | L1-only composition | After valid L2 |
|---|---|---|
| Candidate tap | **Fail closed** | Existing bound-revision rules |
| Path tap / 选拼音 | **Fail closed** | Existing contracts |
| Space / 选定 first candidate | **Fail closed** if no L2 identity | Existing |
| Partial Commit | **Fail closed** or require L2 | Existing |
| Explicit reset / mode change | Clear L1; bump epoch as today | Existing |

### D5 — Metrics (extend Rem-1; content-free)

Under dual-gate, retain ACCEPT / VISIBLE / PUBLISH lag / BURST and add:

| Marker field | Meaning |
|---|---|
| `VISIBLE … source=provisional` | First paint for this accept used L1 |
| `VISIBLE … source=engine` | First paint for this accept used L2 (no prior L1, or L1 skipped) |
| `VISIBLE … source=replace` | L2 replaced prior L1 for same accept/rev lineage (optional) |
| `L1_SKIP reason=…` | Content-free skip (`unsafe`, `non_t9`, `no_mirror`, …) |

Device scoring for a future Rem-3 device knife (not authorized here):

- Subjective stall + key follow (primary)
- Share of accepts with `source=provisional` before engine (descriptive)
- VISIBLE lag when source=provisional should be ≪ engine-only lag under Fake
  stall tests
- Zero host-digit incidents; zero selection-on-provisional successes

### D6 — Implementation placement (when authorized)

Preferred shape (guidance, not a free refactor license):

1. **Pure** provisional builder in KeyboardCore (unit-testable):  
   `(lastL2Snapshot?, acceptedRawDelta) -> ProvisionalPresentation?`
2. Dual-gate accept path on MainActor: after successful enqueue/accept receipt,
   if builder returns non-nil, apply L1 marked-text / state flags and emit
   VISIBLE provisional.
3. Existing `applyResponsivePublishedSnapshot` / presentation generation: on
   valid L2, **clear L1 flag** and atomic-apply L2 (existing P1-1 gates).
4. No second live MainActor RIME session; no `@unchecked Sendable`.

### D7 — Test minimum (when authorized)

| Case | Expectation |
|---|---|
| Fake ≥150 ms/key, dual-gate ON | N accepts → ≥1 provisional VISIBLE before matching L2 for slow keys |
| L2 replace | Host marked text becomes engine composition; no digit leakage |
| Selection during L1-only | Fail closed; no host commit |
| Gate-off | No L1 markers; behaviour ≡ baseline |
| Delete during lag | Provisional shortens with accept; L2 eventually matches |
| Abandon / epoch bump | Stale L1 and stale L2 both dropped (generation/epoch gates) |
| 26-key / non-composition | No L1 |

### D8 — Relationship to Rem-Device PASS

- Does **not** rewrite Rem-Device PASS or Formal R5 FAIL.
- Success criterion for a later device knife is **progressive authority under
  lag**, not “librime got faster”.
- If Product declines L1, residual VISIBLE spikes remain acceptable under the
  prior PASS caveats until a different product decision.

---

## 5. Risks

| Risk | Mitigation |
|---|---|
| L1 flickers against L2 Chinese preedit | Keep L1 non-Chinese / structure-only; atomic replace |
| Digit leak to host | Builder returns nil unless digit-safe proof; reuse Partial Commit digit bans |
| Users try to select on provisional | Fail closed + disabled chrome |
| Scope creep into full chrome rewrite | D2 minimal surface; dual-gate only |
| Double-apply races with coalesce | L2 still single presentation generation; L1 is pre-L2 only |
| False confidence for Product Gate | Design forbids Gate/default-on claims |

---

## 6. Explicit non-claims

- Implementation is **not** authorized by acceptance of this design alone.
- Rem-Device PASS is not upgraded to Product Gate.
- ADR 0025 remains Proposed.
- Dual-gate remains default-off.
- Auto-anchor Hold/harvest unchanged.
- No numeric SLO lock in this freeze.

---

## 7. Exit criteria — design freeze (this document)

- [x] Residual problem statement tied to Rem-Device evidence
- [x] L0/L1/L2 rules restated with selection/Delete/digit constraints
- [x] D1–D8 frozen
- [x] Metrics + test + risk + non-claims
- [x] Product implementation authorization template
- [x] Linked from Assignment / plan / PD / Knowledge Index / Dashboard

---

## 8. Handoff

**Handoff target:** 🧭 Human Product Owner / Product Lead.

**After design acceptance, optional next Product moves (pick one):**

1. **Authorize Rem-3 implementation** (template below).
2. **Hold L1** — keep dual-gate default-off; treat Rem-Device PASS as enough
   direction evidence for now; optional R6 readiness discussion later.
3. **Switch program priority** to RELEASE-2026-0801 or 9KEY-PINYIN-002 Gate.

### Suggested Product instruction (implementation — not yet granted)

```text
我作为 Human Product Owner / Product Lead，确认
T9-RESPONSIVE-PIPELINE-001 的 R5-Rem-3 设计冻结可接受。

我授权仅实施 R5-Rem-3：
dual-gate 下 MainActor 本地 provisional 组字（L1），digit-safe；
L2 引擎快照原子覆盖 L1；候选/Path/上屏仅绑定 L2；
content-free VISIBLE source=provisional|engine 与 L1_SKIP；
聚焦 + 全量 KeyboardCore 测试；gate-off 路径不变。

不 default-on；不 Accept ADR 0025；不 Product Gate；不 R6；
不扩展 auto-anchor；不重写 Formal R5 FAIL / Rem-Device PASS 历史。

完成后停止，提交证据，交独立 Architecture / Quality 审查。
```

### Suggested device knife (only after implementation green)

```text
授权 R5-Rem-3-Device：同一 fixture 上 dual-gate+L1 vs gate-off A/B；
主评 progressive 体感 + VISIBLE source 分布；不 Product Gate。
```
