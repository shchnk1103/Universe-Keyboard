# Quality Review: R5-Rem-3 design freeze (provisional L1 composition)

| Field | Value |
|---|---|
| Reviewer role | 🧪 Quality, Performance & Release Maintainer（**independent** reviewer） |
| Date | 2026-07-31 Asia/Shanghai |
| Assignment | [`t9-responsive-rime-pipeline-001.md`](t9-responsive-rime-pipeline-001.md) |
| Design freeze under review | [`t9-responsive-pipeline-001-r5-rem-3-design.md`](t9-responsive-pipeline-001-r5-rem-3-design.md) |
| Parent remediation (O3) | [`t9-responsive-pipeline-001-r5-remediation-design.md`](t9-responsive-pipeline-001-r5-remediation-design.md) §O3 / D1 / D3 / D5 |
| Predecessor device evidence | [`../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md) — direction **PASS** (key-feel); residual VISIBLE lag |
| Formal R5 baseline | [`../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md) — **FAIL** remains historical |
| Felt metrics baseline (read-only) | `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimeFeltMetrics.swift` |
| Product authority | Human Product Owner authorized **Rem-3 design only**（implementation / device re-pair / R6 / ADR Accept / Product Gate / default-on **not** granted） |
| Scope | **Design readiness only** — falsifiability of D5 metrics + D7 test matrix; evidence honesty plan for a future knife; non-claims. **No** implementation review. **No** Architecture Pass. |
| Bound tip SHA | **`617773e`**（docs: align R5-Rem publication hygiene and freeze Rem-3 design） |
| Verdict | **Pass with conditions** |

**P0: 0**  
**P1: 0**  
**P2: 4**（at tip `617773e` pre-Amendment A — see Addendum A）  
**P3: 4**

---

## Scope

Independent Quality review of the **R5-Rem-3 design freeze** against:

1. **D5 metrics** — content-free, falsifiable, extend Rem-1 without inventing SLOs  
2. **D7 test matrix** — sufficient minimum for a future implementation knife to be *honestly* green or red  
3. **Evidence honesty plan** — what a future Executor/Quality must re-run; what is *insufficient* for progressive-authority or Product claims  
4. **Non-claims** — design must not open a false path to Product Gate / ADR Accept / default-on / Rem-Device rewrite  

This review is **documentation-only**. It does **not**:

- authorize or implement Rem-3 code  
- re-run KeyboardCore full suite（no Rem-3 code at tip; baseline green already established on Rem-1+2+P1-1 / publication stack — skipped as optional）  
- re-install device arms or re-type fixtures  
- claim Architecture Pass, implementation Pass, device Pass, or Product Gate  

**Optional suite skip reason:** tip `617773e` is a **docs freeze**. Re-running 840+ KeyboardCore tests would only re-confirm the Rem-Device/Rem-1+2 baseline, not falsify this design document. Independent suite re-run is **mandatory** for a future Rem-3 *implementation* Quality review.

---

## Verdict summary

| Axis | Result | Notes |
|---|---|---|
| 1. D5 metrics falsifiable | **Held with gaps** | `source=provisional|engine` + `L1_SKIP` are content-free and unit/device scorable; optional `source=replace` + dual-emission vs current tracker need implement binding |
| 2. D7 matrix sufficient for knife | **Held with conditions** | Core safety paths covered; progressive bar weaker than parent O3 “progressive updates”; coalesce+L1 missing |
| 3. Evidence honesty plan | **Partial in design; completed in this review** | Device template is directionally correct; insufficient claims must be frozen before device knife |
| 4. Non-claims / Gate resistance | **Held** | Design forbids implement-by-design-alone, Gate, ADR Accept, default-on, Formal/Rem-Device rewrite, numeric SLO |
| 5. Product Gate false-claim path | **Closed** | No design exit claims Gate; residual P2s cannot become Gate without separate Product auth |

### **Pass with conditions**

Rem-3 design freeze is **ready enough** for Human Product Owner to accept the freeze and *optionally* authorize implementation **if** the conditions in § Conditions are acknowledged. It is **not** implementation green, device Pass, Product Gate, or ADR Accept.

---

## Documents / surfaces read

| Artifact | Path |
|---|---|
| Rem-3 design | `docs/assignments/t9-responsive-pipeline-001-r5-rem-3-design.md` |
| Parent remediation O3 | `docs/assignments/t9-responsive-pipeline-001-r5-remediation-design.md` |
| Rem-Device evidence | `docs/evidence/t9-responsive-pipeline-r5-rem-device-2026-07-31.md` |
| Assignment lifecycle | `docs/assignments/t9-responsive-rime-pipeline-001.md` |
| Sample Quality style | `docs/assignments/t9-responsive-pipeline-001-r5-rem-1-2-quality-review.md`；Rem-Device / Preflight Quality |
| Felt metrics (read-only) | `Packages/KeyboardCore/Sources/KeyboardCore/ResponsiveRimeFeltMetrics.swift` |
| Current paint path | `KeyboardController.performResponsivePresentationApply` — fixed `source=.engine` today |

---

## 1. Residual problem ↔ design target (honesty)

Rem-Device direction **PASS** already closed Formal-R5-style freeze-then-burst on the documented pair, with honest caveats:

| Residual (Rem-Device) | Rem-3 design response | Quality read |
|---|---|---|
| VISIBLE lag spikes ~190–246 ms on slow librime keys | L1 provisional paint before L2 | Correct target; **not** “make librime faster” |
| L1 missing (L0+L2 only) | Full L0/L1/L2 layer freeze | Matches parent D1 / O3 |
| `coalesced=0` / `pending≤1` on PASS pair | “must not assume coalesce always active” | **Held** — Rem-3 must not free-ride O2 |
| Single Debug pair | Design non-claims + optional Hold L1 | **Held** — Rem-3 optional leverage |

**Quality endorse:** residual problem statement is **honest** relative to Rem-Device evidence and does **not** rewrite Formal R5 FAIL or upgrade Rem-Device PASS to Gate.

---

## 2. D5 metrics assessment

### 2.1 Contract vs Rem-1 baseline

Parent D3 / Rem-1 already freezes:

```text
T9RESP marker=ACCEPT …
T9RESP marker=VISIBLE lagMs=<ms> rev=<n> source=provisional|engine
T9RESP marker=PUBLISH lagMs=… pendingAfter=… coalesced=…
T9RESP marker=BURST …
```

Current code (`ResponsiveRimeFeltMetrics.VisibleSource`) already has `.provisional` and `.engine`, but **paint path only emits `.engine`**. Rem-3 D5 correctly treats provisional as the *live* extension of that reserved enum.

| D5 field | Falsifiable? | Sufficiency for knife |
|---|---|---|
| `VISIBLE source=provisional` | **Yes** — unit: Fake stall → first paint line contains `source=provisional`; device: share of accepts | Primary progressive signal |
| `VISIBLE source=engine` | **Yes** — first paint was L2 (no prior L1 / L1 skipped) | Baseline / skip path |
| `VISIBLE source=replace`（optional） | **Partially** — not in current enum; dual-emission semantics not frozen | Useful but optional; see P2-2 |
| `L1_SKIP reason=…` | **Yes if** reasons are closed tokens, content-free | Explains low provisional share without inventing Chinese text |
| Retain ACCEPT / PUBLISH lag / BURST | **Yes** — already unit-tested | Must remain; KEY END stays secondary |

Device scoring bullets in D5:

| Bullet | Quality read |
|---|---|
| Subjective stall + key follow primary | **Correct** — continues Rem-Device / Formal R5 lesson |
| Share of accepts with `source=provisional` descriptive | **Correct** — not an SLO |
| Provisional VISIBLE lag ≪ engine-only under Fake stall | **Unit-falsifiable**; **not** product SLO |
| Zero host-digit; zero selection-on-provisional success | **Falsifiable** safety exits |

**No numeric product SLO invented** — aligns with non-claims and parent D5 policy.

### 2.2 Observability gaps (not design-blocking)

1. **First-visible lag definition under dual paint**  
   Parent: `accept→visible` = first MainActor composition presentation (L1 **or** L2).  
   Rem-3 D5 correctly maps first paint to `provisional` vs `engine`.  
   Optional `replace` is a *second* VISIBLE for the same accept lineage. Current tracker:

   ```swift
   if revision < lastVisibleRevision { return nil }
   lastVisibleRevision = revision
   ```

   Same `revision` may emit again (`==` not blocked). Older revs are dropped.  
   **Gap:** design does not freeze whether L2-after-L1 must emit `source=replace`, `source=engine`, or only PUBLISH without a second VISIBLE. Without that, Executor and Quality can disagree on “first paint” arithmetic.

2. **`L1_SKIP` grammar** not yet in parent D3 sample block — acceptable as Rem-3 extension, but implement must keep reasons **token-only** (`unsafe` / `non_t9` / `no_mirror` / …), no raw key / digit string / preedit text.

3. **Revision identity for L1**  
   D1 tags L1 with accept-time `sessionEpoch`; D5 VISIBLE uses `rev=`. Design assumes L1 paint can share the accept revision bookkeeping already used by `recordAccept`. Implement must not invent a parallel revision space that breaks lag join ACCEPT↔VISIBLE.

### 2.3 D5 verdict

**Falsifiable and sufficient** for a future knife **if** implement binds:

- first paint → exactly one of `provisional|engine` per accept (or documented skip + no VISIBLE);  
- optional `replace` either implemented with dual-emission contract **or** deferred with explicit non-claim;  
- `L1_SKIP` content-free tokens only.

Does **not** create a Product Gate false path by itself (descriptive shares + subjective primary).

---

## 3. D7 test matrix assessment

### 3.1 Coverage map vs O3 / D1–D4

| D7 case | Maps to | Falsifiable expectation | Quality note |
|---|---|---|---|
| Fake ≥150 ms/key, dual-gate ON | O3 exit; D5 provisional lag | N accepts → **≥1** provisional VISIBLE before matching L2 | **Weak progressive bar** — see P2-1 |
| L2 replace | D2 atomic overwrite; digit safety | Host marked text = engine composition; no digits | **Held** as safety core |
| Selection during L1-only | D4 fail closed | No host commit | **Held**; expand to Space / Partial Commit as P3/P2 |
| Gate-off | D1 no L1 | No L1 markers; ≡ baseline | **Held** |
| Delete during lag | D3 mirror | Provisional shortens with accept; L2 matches later | **Held** |
| Abandon / epoch bump | D1 epoch + P1-1 generation | Stale L1 and L2 dropped | **Held** (builds on Arch P1-1) |
| 26-key / non-composition | D1 T9-only | No L1 | **Held** |

Parent O3 exit text: *“Human/unit sees **progressive** provisional updates”*.  
D7 table reduces that to *“≥1 provisional VISIBLE … for slow keys”*.

| Bar | Pass condition | Risk |
|---|---|---|
| D7 as written | One provisional paint in a burst of N | Mostly-`L1_SKIP` builder can unit-green while progressive authority is absent |
| O3 progressive | Multiple accepts under stall show L1 before L2 | Matches Rem-3 product north-star |

This is **not** “untestable” and **not** a Product Gate open door (Gate still separately forbidden). It **is** a knife-edge weakness: future implementation Quality could be forced to Pass a hollow L1 unless Product/implement auth binds a stronger progressive criterion.

### 3.2 Missing cases (ranked)

| ID | Severity | Gap | Why it matters |
|---|---|---|---|
| P2-1 | **P2** | Progressive criterion too weak vs O3 | Hollow L1 unit green → overstated progressive UX on implement review |
| P2-2 | **P2** | L1 then L2 dual VISIBLE / `source=replace` not frozen | Lag stats and “first paint” disagree between Executor and Quality |
| P2-3 | **P2** | Coalesce (`pending≥2`) + L1 concurrent path absent from D7 | Rem-Device barely exercised O2; L1 must still paint **per accept** while L2 may coalesce |
| P2-4 | **P2** | Device evidence honesty only a short Product template | Without frozen “insufficient claims”, device re-pair can regress to KEY END-only or single-pair Gate language |
| P3-1 | **P3** | Pure builder digit-safety matrix not in D7 table (only D6 shape) | Digit leak is P0-class *product* risk; unit surface should be mandatory at implement |
| P3-2 | **P3** | Partial Commit / Space / 选定 during L1 only in D4 table | Selection case is close but not full D4 |
| P3-3 | **P3** | `L1_SKIP` reason vocabulary open-ended | Prefer closed enum for content-free + tests |
| P3-4 | **P3** | Felt tracker session-reset residual (inherited Rem-1+2) | Shared tracker may retain accepts across keyboard sessions if not reset — lag noise, not L1-specific |

### 3.3 D7 verdict

**Sufficient as a minimum safety net** (gate-off, digit, selection fail-closed, abandon, delete mirror, T9-only).  
**Not yet sufficient alone as progressive-authority proof** without strengthening P2-1 (condition, not Fail).

No D7 case invents numeric product SLOs. Fake 150 ms remains experimental falsification, consistent with prior Spike/R4-Owner Quality language.

---

## 4. Evidence honesty plan (future knives)

Design §8 templates authorize implement then optional Rem-3-Device. Quality freezes the honesty plan below as **conditions for future reviews** (not new Product authority).

### 4.1 Rem-3 implementation knife — Executor **must** re-run / produce

| Layer | Required evidence | Insufficient if… |
|---|---|---|
| Unit focused | New L1 / provisional builder / selection-fail-closed / gate-off / delete-mirror / abandon tests; plus existing felt / dual-gate wire / R2 | Only marker string tests without Fake stall progressive path |
| Unit full | Full `Packages/KeyboardCore` suite green | Focused-only green |
| Independent Quality | **Re-run** focused + full; do not trust Executor counts alone | Copy-paste Executor arithmetic without re-run |
| Content-free scan | Marker builders reject host text / pinyin / digits / candidates | Logs that embed preedit or raw keys |
| Isolation | No `@unchecked Sendable`; no second live MainActor librime session under dual-gate | Isolation bypass “to make L1 easier” |
| Gates | dual-gate / responsive remain default **false**; no settings UI default-on | Silent default-on |
| Non-claims in evidence | No Product Gate / ADR Accept / Rem-Device rewrite / Formal FAIL erase | Marketing language in evidence status |

### 4.2 Rem-3-Device knife (only after implement Quality Pass) — must score

| Primary | Secondary | Forbidden as primary Pass basis |
|---|---|---|
| Subjective progressive composition / key follow under dual-gate+L1 | `VISIBLE source=provisional` share (descriptive) | **KEY END only** |
| Integrity (no digit / no missing-dup host commit from L1) | PUBLISH lag / SLOW RIME (engine still slow is OK) | Single metric cherry-pick |
| No Formal-R5-style multi-second freeze-then-burst regression | BURST count vs Formal FAIL | “keys return in 1 ms ⇒ product done” |

### 4.3 Explicitly **insufficient** evidence (freeze)

These claims are **not** enough for progressive-authority Pass, direction upgrade, or any Gate language:

1. **KEY END only** — dual-gate always looks “fast”; Formal R5 / Rem-Device already proved this blind spot.  
2. **Single pair → Product Gate** or multi-device robustness.  
3. **`source=provisional` count = 0` + subjective “feels fine”** presented as Rem-3 L1 success (that is Rem-Device residual, not L1 delivery).  
4. **One provisional VISIBLE in an entire fixture** as sole unit progressive proof (P2-1).  
5. **`coalesced` unobserved** yet claiming O2+L1 interaction proven.  
6. **Debug-only arms** as Release-like product conclusion.  
7. **Log truncation** that drops early ACCEPT/VISIBLE without stating incompleteness.  
8. **Trust Executor suite counts** without independent Quality re-run.  
9. **Rewriting** Formal R5 FAIL or Rem-Device PASS history via Rem-3 evidence.  
10. **Numeric SLO lock** from descriptive lag tables.

### 4.4 What Quality will re-run on implement review (preview)

```bash
# Focused (expected filter names are illustrative; final names follow implement)
swift test --package-path Packages/KeyboardCore \
  --filter 'ResponsiveRimeFeltMetricsTests|…L1…|ThreadAffineRimeWireTests|ResponsiveRimeR2CoordinatorTests'

# Full
swift test --package-path Packages/KeyboardCore
```

Plus structural scans: `VisibleSource` usage, L1 paint call sites, gate defaults, `@unchecked Sendable`, content-free marker builders.

Device re-measure is **not** assumed for implement Quality unless Product authorizes Rem-3-Device.

---

## 5. Layer / safety rules (testability skim)

| Rule | Design locus | Unit-testable without device? |
|---|---|---|
| L2 wins; atomic overwrite | §3, D2 | Yes — Fake L2 after L1 clears provisional flag |
| L1 never insertText / commit | §3, D2 | Yes — selection / space / PC fail closed |
| Selection binds L2 identity only | D4 | Yes |
| Digit-safe or skip L1 | D2 flicker policy | Yes — pure builder nil + host assertion |
| Gate-off no L1 | D1, D7 | Yes |
| No second MainActor RIME | D6 | Structural + dual-gate tests |
| No `@unchecked Sendable` | D6 | Scan |

**Quality endorse:** ownership model is **testable in-process** with Fake owner stall ≥150 ms; does not require Coordinate XCTest typing (correctly out of scope).

---

## 6. Findings

### P0

*None.* Design is not untestable; non-claims block Product Gate / ADR Accept / default-on false paths.

### P1

*None under the design-readiness rubric* (untestable **or** open false Product Gate path).  
Progressive-bar weakness is real but classified **P2-1** (hollow implement green risk, not Gate).

### P2

#### P2-1 — D7 progressive bar weaker than parent O3 exit

- **Issue:** D7 requires only **≥1** provisional VISIBLE for N slow accepts; O3 requires **progressive** provisional updates.  
- **Risk:** Implement can ship high `L1_SKIP` rate, one lucky provisional paint, unit-green, then over-claim Rem-3 progressive authority.  
- **Condition for implement auth / implement exit:** bind a stronger progressive criterion, e.g. under Fake ≥150 ms/key dual-gate:  
  - for a burst of **N≥5** letter-group accepts with owner still behind, **majority** (or ≥k consecutive) accepts emit `source=provisional` **before** matching L2 for those revs; **and**  
  - provisional `lagMs` distribution is clearly below engine-only lag on the same Fake stall.  
  Exact N/k may be named constants in tests — **not** product SLOs.

#### P2-2 — Dual VISIBLE / `source=replace` semantics not frozen

- **Issue:** Optional `replace` + first-paint rules leave lag arithmetic ambiguous.  
- **Condition:** Implement design note or evidence must freeze one of:  
  - (A) first VISIBLE `provisional`, second VISIBLE `replace` for same rev lineage; or  
  - (B) first only `provisional`, L2 emits PUBLISH without second VISIBLE; `replace` deferred.  
  Do not emit ambiguous double `source=engine` for L1-then-L2.

#### P2-3 — Coalesce + L1 interaction missing from D7

- **Issue:** Rem-Device pair had `pending≤1`, `coalesced=0`. L1 must not depend on that luck.  
- **Condition:** At least one unit case with Fake backlog `pendingDepth ≥ presentationCoalescePendingThreshold` asserting **L1 paints on accept** while L2 presentation may coalesce (engine FIFO unchanged).

#### P2-4 — Device honesty plan only a short template in design §8

- **Issue:** Suggested device instruction is one paragraph; insufficient-claim list lives only in this Quality review unless Product/Assignment links it.  
- **Condition:** Future Rem-3-Device evidence **must** follow §4.2–4.3 of this review (or equivalent frozen list). KEY END-only / single-pair Gate language = automatic Fail.

### P3

| ID | Item |
|---|---|
| P3-1 | Add pure builder digit-safety / nil-on-unsafe cases to D7 minimum at implement (D6 already implies surface). |
| P3-2 | Explicit unit cases for Space / 选定 / Partial Commit during L1-only (D4 already forbids). |
| P3-3 | Close `L1_SKIP` reason token set in code enum; test unknown reasons rejected or mapped. |
| P3-4 | Session/reset hygiene for `ResponsiveRimeFeltMetricsTracker` (inherited Rem-1 residual). |

---

## 7. Conditions for this Pass (design readiness)

This **Pass with conditions** holds only if:

1. **Design freeze scope remains design-only** — accepting this review does **not** authorize code.  
2. **Product implementation authorization** (if granted later) acknowledges **P2-1…P2-3** as implement-exit requirements (or strengthens D7 in an addendum before code).  
3. **Non-claims remain absolute** — no reading of this Pass as implementation green, device Pass, Product Gate, ADR 0025 Accept, Release default-on, R6, Formal R5 rewrite, or Rem-Device PASS upgrade.  
4. **Evidence honesty** for future knives follows §4 of this document.  
5. **Bound tip** for this design freeze review is **`617773e`**. Material changes to D5/D7/non-claims after that tip **invalidate** this Pass until re-review.

**Does not block design acceptance:** P3 items; optional Product choice to **Hold L1** entirely (design §8 option 2).

---

## 8. Explicit non-claims (this review)

| Claim | Status |
|---|---|
| Rem-3 **implementation** green | **Not claimed** — no code knife |
| Rem-3-Device / any device Pass | **Not claimed** |
| Product Gate / Release default-on | **Not claimed** |
| ADR 0025 Accept | **Not claimed** — remains Proposed |
| Formal R5 FAIL rewritten | **Not claimed** — FAIL remains historical |
| Rem-Device PASS upgraded / multi-pair robust | **Not claimed** |
| Numeric product SLO locked | **Not claimed** |
| Architecture Pass on L1 placement | **Not claimed** — out of scope |
| KeyboardCore suite re-run at this tip | **Not executed** (design-only; skip reason in Scope) |

---

## 9. Comparison to prior Quality language

| Prior knife | This Rem-3 design review |
|---|---|
| Rem-1+2 Quality: re-ran suites; Pass with conditions on **code** | **No** suite re-run; Pass with conditions on **design falsifiability** |
| Rem-Device Quality: audited device honesty + unit green | Device residual **inputs** design; does not re-score device |
| Preflight/R4 design freezes: implement evidence matrices | Here matrix is **forward-looking** D5/D7 readiness |

---

## 10. Disposition by role

| Role | Judgment |
|---|---|
| 🧪 Quality | **Pass with conditions** — D5/D7 falsifiable enough for a future knife; P2-1…P2-4 must bind implement/device honesty; **0 P0 / 0 P1** |
| 🏛️ Architecture | Not this review; structural L1 placement / pure-builder boundary still need Arch review on implement |
| 🧭 Product | May **accept design freeze**; may **Hold L1** or authorize implement template in design §8 **with** P2 conditions; **must not** treat this as Gate / default-on / ADR Accept |
| Executor (future) | Do not start Rem-3 code until Product auth; plan tests for progressive bar + coalesce+L1 + digit builder |

---

## 11. Must-fix before implement authorization?

| Item | Must-fix *document* before auth? | Must-fix *in implement exit*? |
|---|---|---|
| P2-1 progressive bar | **Recommended** addendum or Product auth text citing stronger bar | **Yes** — implement Quality should Fail hollow ≥1-only progressive claim |
| P2-2 replace / dual VISIBLE | Optional freeze in auth / implement design note | **Yes** — pick A or B |
| P2-3 coalesce+L1 test | No separate design edit required if auth cites this review | **Yes** — unit required |
| P2-4 device honesty list | No — this review is enough if linked from device evidence | **Yes** at Rem-3-Device |
| P3-* | No | Nice-to-have at implement |

**Quality recommendation to Product:**  
Design freeze may be **accepted now**. If authorizing implement in the same breath, append one sentence to the Product instruction:

```text
实现退出须满足 Rem-3 Quality review P2-1…P2-3：
Fake≥150ms 下 progressive provisional（非单次≥1）、
L1→L2 VISIBLE 语义钉死、coalesce backlog 下 L1 仍按 accept 上色；
证据诚实遵循该 review §4；不 Product Gate / 不 ADR Accept / 不 default-on。
```

Without that sentence, implement auth is still *allowed* by design §8 template, but implement Quality will apply P2-1…P2-3 as **conditions** and may Fail over-claim.

---

## 12. Final verdict

### **Pass with conditions** — design readiness only

| Counts | Value |
|---|---|
| P0 | **0** |
| P1 | **0** |
| P2 | **4** |
| P3 | **4** |

**Bound tip:** `617773e`  
**Review path:** [`docs/assignments/t9-responsive-pipeline-001-r5-rem-3-quality-review.md`](t9-responsive-pipeline-001-r5-rem-3-quality-review.md)

Rem-3 design freeze is **honest**, **mostly falsifiable**, and **Gate-safe**. It is ready for Product design acceptance and optional implement authorization **under the conditions above**. It is **not** a green light for code claims, device Pass, Product Gate, or ADR Accept.

---

## Addendum A — Design Amendment A disposition (same day)

**Date:** `2026-07-31 Asia/Shanghai`  
**Patched design:** D5 dual VISIBLE, D7 progressive bar `≥ ceil(N/2)` for N≥8 Fake
150 ms, coalesce+L1 case, closed `L1_SKIP` reasons, pure builder digit matrix row.  

| Quality P2 (at `617773e`) | Amendment A |
|---|---|
| P2-1 progressive bar weak | **D7** progressive bar frozen |
| P2-2 dual VISIBLE / replace | **D5** second engine VISIBLE after L1 required |
| P2-3 coalesce + L1 | **D7** coalesce backlog + L1 case |
| device honesty wording | Unchanged — still mandatory at device knife |

This addendum does **not** re-run suites (still no Rem-3 code). Implementation
Quality review remains mandatory after any code knife.
