# T9-RESPONSIVE-PIPELINE-001 / R5-Rem-3 design — provisional L1 composition

**Status:** `Active — design freeze + Amendment A after dual design review; implementation still not authorized`  
**Date:** `2026-07-31 Asia/Shanghai`  
**Role author:** 🏛️ Architecture & Knowledge Steward  
**Product authorization:** Human Product Owner authorized **documentation hygiene**
then **Rem-3 design only** (this document). No implementation, device re-pair,
R6, ADR Accept, Product Gate or default-on.  
**Independent design reviews (tip `617773e`):**  
  Arch [`t9-responsive-pipeline-001-r5-rem-3-architecture-review.md`](t9-responsive-pipeline-001-r5-rem-3-architecture-review.md)
  — **Pass with conditions** (4× P1 blocked implement-auth recommendation)  
  Quality [`t9-responsive-pipeline-001-r5-rem-3-quality-review.md`](t9-responsive-pipeline-001-r5-rem-3-quality-review.md)
  — **Pass with conditions** (0 P0/P1; P2 progressive/metrics/coalesce)  
**Parent design:**  
[`t9-responsive-pipeline-001-r5-remediation-design.md`](t9-responsive-pipeline-001-r5-remediation-design.md)
(O3)  
**Predecessor evidence:**  
[`../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md)
— Rem-Device **direction PASS** (key-feel); residual VISIBLE lag spikes  
[`../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md)
— Formal R5 **direction FAIL** (historical freeze-then-burst)  
**Publication baseline:** design authored on `main` @ `617773e` (after #36/#37 @ `7665c64`)  
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

1. L2 wins when a **live** snapshot arrives under Rem-2/P1-1 gates **and** its
   `revision` is ≥ the MainActor **provisional watermark** (see D1 / D9). Matching
   epoch alone is **not** enough to paint an older L2 over newer L1.
2. L1 is **overwritten atomically** by such an L2; never merged field-by-field
   with a half-applied L2.
3. L1 must never `insertText` / commit host text.
4. While **provisionalAhead** (D4 / D9), **all** selection / Path / 选定 /
   Partial Commit **fail closed** — including taps that still carry an older
   published L2 identity.
5. Gate-off path remains L0+L2 synchronous (today’s ADR 0004 behaviour); **no L1**.

**Naming:** Rem-3 L1 is **responsive provisional composition**
(`ResponsiveProvisionalComposition` / `l1ProvisionalPreedit`). It must **not**
reuse T9 Path “provisional” / `provisionalPathID` APIs (ADR 0023 residual).

---

## 4. Frozen decisions

### D1 — When L1 may paint

L1 paints **only if all** hold:

| Check | Requirement |
|---|---|
| Dual-gate active | `isResponsiveRimePipelineEnabled && isThreadAffineRimeOwnerEnabled` (or equivalent live dual-gate path) |
| Action class | T9 letter-group / digit **processKey** accepts that extend the provisional raw ledger (D6); 26-key latin direct path: **no L1** |
| Not arming | Default: **T9 nine-key composition only** |
| Epoch + watermark | L1 tags current MainActor `sessionEpoch` and advances a MainActor **provisionalAcceptedCount / provisionalWatermark** (monotonic accept sequence within epoch). L2 may replace L1 only if: live epoch + presentation generation gates pass **and** `l2.revision ≥ lastPresentedOrProvisionalFloor` (same spirit as `isLivePresentationSnapshot`; never paint older revision over newer L1) |

### D2 — What L1 may show (v1 pure algorithm frozen)

**v1 host-visible L1 string (closed algorithm):**

1. Maintain MainActor **provisional raw ledger** = digit/key identity accepted
   under dual-gate that has not yet been covered by a live L2 apply (D6).
2. Map ledger length `N` to a **structure-only** marked string of length `N`
   using a single fixed non-digit, non-letter placeholder code point
   **U+00B7 MIDDLE DOT (`·`)** per accepted T9 key slot (example: 3 accepts →
   `···`). This is progressive **length authority**, not spelling or Chinese.
3. Never emit ASCII digits `0–9` or internal T9 raw into host marked text.
4. Never invent pinyin letters, Chinese characters, RIME top-candidate text,
   or Path stack labels in L1.
5. When last L2 exists and is still live for the same epoch, L2 atomic replace
   still uses **engine** composition text; do not blend L1 dots with L2 CJK
   mid-string.

**Why not group-first-letter (`2→a`)?** That guesses spelling and fights later
L2; **forbidden** in v1.

**Chrome while provisionalAhead (v1 required, not optional):**

- Candidate list and Path selection affordances are **disabled or cleared** so
  the user cannot tap stale L2 chrome against newer L1 length (closes Arch P1-4).
- No ranked “fake” engine list.

**Skip:** If builder cannot produce the v1 string (non-T9, empty ledger after
clear, etc.), emit `L1_SKIP` and wait for L2 — never digit flash.

**Flicker policy:** brief `···` → engine preedit replace is acceptable;
multi-second blank freeze without progressive length is the residual Rem-3
targets when stall is long.

### D3 — Delete / backspace (v1 path freeze)

**v1 choice A (default, narrow scope):**

1. Dual-gate **Delete** remains today’s `performOrderedNow` / ordered wait path
   (R4-Wire residual). MainActor may still block on delete drain; that is
   **out of Rem-3 scope** to re-architecture.
2. L1 delete mirror is **non-primary**: if Delete is synchronous to L2, rely on
   L2 shorten; provisional ledger is cleared/aligned from the returned L2.
3. If a future knife makes Delete fully async accept-like processKey, then and
   only then enable L1 length mirror on delete accept (same ledger rules).

**Not in v1:** expanding Rem-3 authorization to redesign Delete async solely
for L1 (would need explicit Product scope expansion).

### D4 — Selection and Partial Commit

Define **provisionalAhead** = provisional ledger non-empty **or** L1 active
flag **or** provisional watermark > last published L2 revision applied to UI.

| Action | provisionalAhead | After live L2 and not ahead |
|---|---|---|
| Candidate tap | **Fail closed** (even if old L2 identity still in state) | Existing bound-revision rules |
| Path tap / 选拼音 | **Fail closed** | Existing contracts |
| Space / 选定 first candidate | **Fail closed** | Existing |
| Partial Commit | **Fail closed** (require live L2 identity matching current composition authority) | Existing |
| Explicit reset / mode change | Clear L1 ledger + flags; epoch as today | Existing |

### D5 — Metrics (extend Rem-1; content-free)

Under dual-gate, retain ACCEPT / VISIBLE / PUBLISH lag / BURST and add:

| Marker field | Meaning |
|---|---|
| `VISIBLE … source=provisional` | This paint used L1 (structure-only); **first** progressive paint for that accept watermark when L1 succeeds |
| `VISIBLE … source=engine` | Paint used L2 with no active L1 for that accept, or L1 was skipped |
| `VISIBLE … source=engine` after L1 (required semantics) | When L2 replaces prior L1, emit a **second** VISIBLE (or retain dual line) so lag of L2 settle remains measurable; do **not** hide L2 behind first-only watermark without a content-free replace signal |
| `L1_SKIP reason=…` | Closed token set v1: `unsafe` \| `non_t9` \| `empty_ledger` \| `gate_off` \| `no_dual` |

Optional later: dedicated `source=replace` enum case — not required if dual
VISIBLE lines (provisional then engine) are frozen as above.

Device scoring for a future Rem-3 device knife (not authorized here):

- Subjective stall + key follow (primary)
- Share of accepts with `source=provisional` (descriptive)
- Under Fake ≥150 ms/key dual-gate: progressive bar in **D7** (not “≥1 total”)
- Zero host-digit incidents; zero selection success while provisionalAhead

### D6 — Implementation placement (when authorized)

Preferred shape (guidance, not a free refactor license):

1. MainActor **provisional raw ledger** + pure builder:  
   `(ledger, epoch) -> ProvisionalPresentation?` producing `·`×N or nil.
2. Dual-gate **processKey accept** path: after successful accept receipt, append
   ledger, paint L1, set provisionalAhead chrome disable, emit VISIBLE
   provisional.
3. Existing `applyResponsivePublishedSnapshot` / presentation generation: on
   **live** L2 with revision ≥ floor, clear ledger/L1 flags, atomic-apply L2,
   re-enable selection chrome under existing rules, emit VISIBLE engine.
4. No second live MainActor RIME session; no `@unchecked Sendable`.
5. Types/names must not collide with Path provisional APIs.

### D7 — Test minimum (when authorized)

| Case | Expectation |
|---|---|
| Fake ≥150 ms/key, dual-gate ON, N≥8 accepts before first L2 drain | **≥ ceil(N/2)** accepts show `source=provisional` **before** their matching L2 engine VISIBLE (progressive bar; not a single token success) |
| L2 replace after L1 | Host marked text becomes engine composition; no digit leakage; L2 VISIBLE still observable |
| Selection while provisionalAhead | Fail closed even with stale L2 candidates still in memory |
| Gate-off | No L1 markers; behaviour ≡ baseline |
| Delete v1 | Aligns with path A: L2-driven shorten; no double-shorten glitch |
| Abandon / epoch bump | Stale L1 and stale L2 both dropped |
| 26-key / non-composition | No L1 |
| Coalesce backlog + L1 | With pending≥ threshold, L1 still paints on accept; L2 latest-only still holds; no selection while ahead |
| Pure builder | Ledger length 0→empty; length k→k dots; never digits |

### D8 — Relationship to Rem-Device PASS

- Does **not** rewrite Rem-Device PASS or Formal R5 FAIL.
- Success criterion for a later device knife is **progressive length authority
  under lag** (`·`×N), not “librime got faster” or Chinese provisional text.
- If Product declines L1, residual VISIBLE spikes remain acceptable under the
  prior PASS caveats until a different product decision.

### D9 — Amendment A (2026-07-31) — closes Arch P1-1…P1-4

| Arch finding | Design close |
|---|---|
| **P1-1** revision order | D1 watermark + Rule 1: L2 needs `revision ≥` floor; not “same epoch always replaces” |
| **P1-2** thin builder | D6 provisional **ledger** + builder on ledger, not one-shot delta only |
| **P1-3** missing pure algorithm | D2 v1 = `·`×N structure-only; forbid letter-guess / Chinese |
| **P1-4** mixed stale L2 + L1 | D4 provisionalAhead fail-closed all selection; D2 required disable chrome |

Quality design P2 bindings absorbed into D5 dual VISIBLE, D7 progressive bar +
coalesce case, D3 Delete path A.

---

## 5. Risks

| Risk | Mitigation |
|---|---|
| `·`×N feels “wrong” vs Chinese preedit | Atomic L2 replace; Product may Hold if subjective reject |
| L1 flickers against L2 Chinese preedit | Structure-only L1; atomic replace |
| Digit leak to host | Builder never emits digits; unit matrix |
| Users try to select on stale L2 while ahead | provisionalAhead fail-closed + chrome disable |
| Scope creep into Delete async redesign | D3 path A freezes v1 |
| Double-apply races with coalesce | L2 presentation generation + revision floor |
| False confidence for Product Gate | Design forbids Gate/default-on claims |

---

## 6. Explicit non-claims

- Implementation is **not** authorized by acceptance of this design alone.
- Independent design reviews **do not** authorize implementation.
- Rem-Device PASS is not upgraded to Product Gate.
- ADR 0025 remains Proposed (L1 is an explicit dual-gate presentation exception
  relative to “only engine snapshot paints composition”, documented here).
- Dual-gate remains default-off.
- Auto-anchor Hold/harvest unchanged.
- No numeric SLO lock in this freeze.

---

## 7. Exit criteria — design freeze (this document)

- [x] Residual problem statement tied to Rem-Device evidence
- [x] L0/L1/L2 rules restated with selection/Delete/digit constraints
- [x] D1–D8 frozen
- [x] Independent Arch + Quality design reviews on tip `617773e`
- [x] Amendment A closes Arch P1-1…P1-4 + Quality P2 bindings (D9)
- [x] Metrics + test + risk + non-claims
- [x] Product implementation authorization template (updated)
- [x] Linked from Assignment / plan / PD / Knowledge Index / Dashboard

**Remaining before implement-auth recommendation:** optional Arch **re-review**
of Amendment A (Product may still authorize implement if they accept Amendment A
text as sufficient close without re-review).

---

## 8. Handoff

**Handoff target:** 🧭 Human Product Owner / Product Lead.

**After Amendment A, optional next Product moves (pick one):**

1. **Authorize Rem-3 implementation** (template below) — dual-gate L1 only.
2. **Hold L1** — keep dual-gate default-off; Rem-Device PASS stands.
3. **Switch program priority** to RELEASE-2026-0801 or 9KEY-PINYIN-002 Gate.

### Suggested Product instruction (implementation — not yet granted)

```text
我作为 Human Product Owner / Product Lead，确认
T9-RESPONSIVE-PIPELINE-001 的 R5-Rem-3 设计冻结（含 Amendment A）可接受。

我授权仅实施 R5-Rem-3：
dual-gate 下 MainActor provisional raw ledger + 结构-only L1（·×N）；
L2 仅在 live epoch/generation 且 revision≥watermark 时原子覆盖；
provisionalAhead 时候选/Path/选定/Partial Commit 一律 fail-closed；
VISIBLE source=provisional 与随后 engine；L1_SKIP 封闭 reason；
D7 progressive 条（Fake 150ms，N≥8 时 ≥ceil(N/2) provisional）；
Delete 保持 v1 path A；gate-off 不变。

不 default-on；不 Accept ADR 0025；不 Product Gate；不 R6；
不扩展 auto-anchor；不重写 Formal R5 FAIL / Rem-Device PASS 历史。

完成后停止，提交证据，交独立 Architecture / Quality 审查。
```

### Suggested device knife (only after implementation green)

```text
授权 R5-Rem-3-Device：同一 fixture 上 dual-gate+L1 vs gate-off A/B；
主评 progressive 体感 + VISIBLE source=provisional 分布；不 Product Gate。
```
