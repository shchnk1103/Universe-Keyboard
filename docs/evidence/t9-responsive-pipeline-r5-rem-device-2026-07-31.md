# T9 responsive pipeline R5-Rem-Device — Human A/B evidence — 2026-07-31

**Status:** `Closed — Rem-Device direction PASS (1 pair A→B, key-feel only); Formal R5 FAIL remains historical; Product Gate / ADR Accept / default-on not claimed`  
**Product:** Rem-Device authorized after Arch P1-1 close  
**Code tree:** dirty worktree Rem-1+2+P1-1 on tip parent `87d3e7c`  
**Predecessor Formal R5 FAIL:** [`t9-responsive-pipeline-r5-formal-2026-07-31.md`](t9-responsive-pipeline-r5-formal-2026-07-31.md)  
**Rem-1+2 evidence:** [`t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md`](t9-responsive-pipeline-r5-rem-1-2-2026-07-31.md)

## Device run header

| Field | Value |
|---|---|
| Device | iPhone 13 Pro `DoubleShy0N` / `iPhone14,2` |
| UDID | `00008110-000A08440198801E` |
| Host | Reminders (empty title per arm) |
| Layout | Chinese nine-key |
| Fixture (Human only) | `jintiandetianqizhenbucuowomenchuquwanba` |
| Logging | on; engine + perf (buffer may truncate oldest ~500 lines) |
| Direction metrics | ACCEPT / VISIBLE lagMs / PUBLISH lagMs / BURST + subjective; **not KEY END alone** |

### Arms

| Arm | Build | Extension SHA256 | dualGate |
|---|---|---|---|
| **A** | Debug, no preflight flag | `81909d3ab993c46d…689431a5` | false |
| **B** | Debug + `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` | `86fadce30b0cac60…be49c458` | true |

## Install ledger

| Step | Result |
|---|---|
| Build A/B | **BUILD SUCCEEDED** |
| Install A | **Done** |
| Human A | **Done** ~13:43 |
| Install B | **Done** ~13:44 |
| Human B | **Done** ~13:45 |
| Teardown gate-off | **Done** ~13:47 (`dualGate=false` + Arm A binary) |

---

## Arm A (gate-off)

| Field | Value |
|---|---|
| Path | Gate-off sync (truncated paste; KEY END includes RIME; session `4415749144` valid) |
| Rem-1 markers | **N/A** (not emitted on gate-off) |
| KEY END sample | #6–#39 (34) |
| KEY END ≥100 ms | **4** (184.8 / 171.2 / **211.1** / 175.2) |
| Worst KEY END | **211.1 ms** |
| Mean KEY END | ~34 ms |
| Integrity | OK; committed=false; cands=12 |
| Subjective stall | **~2** — 有一些卡顿/按键不跟手 |

---

## Arm B (dual-gate + Rem-1/2)

| Field | Value |
|---|---|
| Path | dual-gate live: continuous `ACCEPT` / felt `PUBLISH` / `VISIBLE` / preflight `PUBLISH epoch/rev`; `sessionBefore=0` bridge pattern; PATH line missing in truncated head but path proven by markers + install |
| ACCEPT | **24** observed in paste (rev up to 39; early lines truncated); max **pending=1** |
| VISIBLE lagMs (n=25) | mean **50.5** · p50 **11** · p95 **202** · worst **246** · ≥100 ms **5** · ≥50 ms **6** |
| PUBLISH lagMs (n=25) | mean **50.4** · p50 **11** · p95 **202** · worst **246** · ≥100 ms **5** |
| High lag revs (felt) | rev16=190, rev17=92, rev25=211, rev33=246, rev34=147, rev35=202 |
| BURST | **1** line (`count=3 windowMs=50`) |
| coalesced=1 | **0** (all observed paints `coalesced=0`; pending rarely ≥2 long enough at paint time) |
| KEY END (context only) | n=25 · **ge100=0** · worst **2.3 ms** · mean ~1.3 ms |
| SLOW RIME (async bridge) | **4** peaks ~190 / 211 / 246 / 202 ms — cost still exists off KEY END |
| Large idle / freeze-burst | **Not observed** (no multi-second idle; no catch-up flood like Formal R5 FAIL) |
| Integrity | OK; no missing/dup/digit/exit reported |
| Subjective stall | **~0–1** — Human: 比 A 好很多；几乎没有按键卡顿不跟手；候选出现及时 |

---

## Direction gate (Rem-Device)

| Check | A | B | Result |
|---|---|---|---|
| Integrity | OK | OK | Pass |
| Key feel (subjective) | stall ~2 | stall **~0–1** | **B better** |
| Freeze-then-burst | no | **no** (vs Formal R5 B severity 4) | **B improved vs Formal FAIL** |
| KEY END ≥100 | 4 | 0 | B “better” (expected dual-gate; not primary) |
| VISIBLE lag ≥100 | n/a | 5 spikes (max 246 ms) | Result lag remains; **progressive** not freeze |
| Product north-star | keys wait on RIME spikes | keys return ~1 ms; composition lags briefly | **Direction supports dual-gate** |

### **Rem-Device direction: PASS**

Relative to gate-off A on this pair: Human reports **clearly better key follow**; no freeze-then-burst regression of Formal R5 dual-gate FAIL.

Honest caveats:

1. **Result lag still real** — VISIBLE lag still hits ~190–246 ms on some keys (librime still slow); product accepts lag if keys do not freeze.
2. **Log truncation** — diagnostics ~500 lines; early PATH/ACCEPT may be missing.
3. **coalesced=0** almost always — typing pace + pending≤1 meant O2 threshold rarely engaged; win may be largely dual-gate accept-without-wait + no storm (Formal fail was storm/freeze).
4. **Single pair** stop-fast; not multi-pair robust Product Gate.
5. **Debug only** — not Release-like Product conclusion.

---

## Comparison to Formal R5 FAIL (same device/fixture family)

| | Formal R5 B (pre Rem) | Rem-Device B (Rem-1+2+P1-1) |
|---|---|---|
| Subjective | stall **4** freeze-then-burst | stall **~0–1** progressive |
| KEY END | ~1 ms | ~1 ms |
| Catch-up burst | severe | not observed |
| VISIBLE lag markers | n/a | present; spikes still map to SLOW RIME |

Formal R5 FAIL remains **historical** for the pre-Rem dual-gate build; this successor knife shows dual-gate *after* Rem-1+2 is **viable for key-feel direction only**, without claiming Product Gate or rewriting Formal FAIL as success.

---

## Role disposition

| Role | Judgment |
|---|---|
| 🧪 Quality | Pair bound; metrics extracted; direction **PASS** with caveats above |
| 🏛️ Architecture | Path dual-gate active; felt markers working; O2 coalesce little exercised this pair; L1 still absent but not blocking key-feel here |
| 🧭 Product Lead | Rem-Device **Closed direction PASS**; **not** Product Gate / default-on / ADR Accept; next: dual review of device evidence optional; Rem-3 only if product wants zero blank lag under stall |
| Device | Restored **gate-off** Debug + `dualGate=false` |

## Non-claims

- Product Gate / Release default-on / ADR 0025 Accept / R6  
- Numeric product SLO lock  
- Multi-device / multi-pair robustness  
- Rem-3 provisional L1 complete  
- “VISIBLE lag always low” (spikes remain)  
