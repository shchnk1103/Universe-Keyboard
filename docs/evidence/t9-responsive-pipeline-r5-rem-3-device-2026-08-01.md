# T9 responsive pipeline R5-Rem-3-Device — Human progressive A/B — 2026-08-01

**Status:** `Closed — direction PASS (key-follow + L1 provisional markers) with residual P1 chrome flicker; not Product Gate`  
**Product:** Rem-3-Device authorized 2026-08-01  
**Design:** [`../assignments/t9-responsive-pipeline-001-r5-rem-3-device-design.md`](../assignments/t9-responsive-pipeline-001-r5-rem-3-device-design.md)  
**Code tip:** `8169f64`  
**Non-claims:** Product Gate / ADR Accept / default-on / Formal R5 rewrite **not** claimed

## Device run header

| Field | Value |
|---|---|
| Device | iPhone 13 Pro `DoubleShy0N` / `iPhone14,2` |
| UDID | `00008110-000A08440198801E` |
| OS | iOS 27.0 (24A5390f) |
| Host | Reminders (empty title per arm) |
| Layout | Chinese nine-key |
| Fixture (Human only) | `jintiandetianqizhenbucuowomenchuquwanba` |
| Logging | on; engine + performance (export truncated mid-buffer; tail metrics used) |
| Primary metrics | progressive feel; `VISIBLE source=provisional\|engine`; ACCEPT; PUBLISH lag; BURST; subjective — **not KEY END alone** |

### Arms

| Arm | Build | Extension SHA256 (prefix) | dualGate / L1 |
|---|---|---|---|
| **A** | Debug, no preflight flag | `cb2ffc391213fad0…` | off / off |
| **B** | Debug + `-DT9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` | `77e6a95d814b4b0e…` | on / on |

### Install ledger

| Step | Result |
|---|---|
| Build A / B | **BUILD SUCCEEDED** |
| Install A | **Done** |
| Human A | **Done** ~13:26 |
| Install B | **Done** |
| Human B | **Done** ~13:28–13:29 |
| Teardown | **Done** — reinstalled Arm A gate-off (`cb2ffc39…`) |

---

## Arm A (gate-off)

| Field | Value |
|---|---|
| Path | Sync — no `T9RESP`; `RIME BRIDGE` on handle; session `4423908184` |
| KEY END | #6–#39 (**34**); mean **~30.2 ms**; ≥100 ms **4** (worst **163 ms**) |
| SLOW RIME | **5** peaks (~32–161 ms) |
| T9RESP felt | **N/A** |
| Integrity | `committed=false`; cands≈12 |
| Subjective | 仍有部分延迟，略好一点（相对既往） |

---

## Arm B (dual-gate + Rem-3 L1)

| Field | Value |
|---|---|
| Path identity | dual-gate live: `ACCEPT` + async `RIME BRIDGE` + `PUBLISH` + `VISIBLE`; `sessionBefore=0` / `pending=1` pattern (PATH/READY lines missing from truncated paste; path proven by markers + install) |
| ACCEPT (in paste) | **18** revs 22–39; pending max **1** |
| VISIBLE provisional | **18**; lagMs all **0** |
| VISIBLE engine | **17**; lagMs p50 **14** · mean **~24** · worst **177** · ≥100 **1** |
| Dual provisional→engine same rev | **≥16** revs in paste |
| PUBLISH | **17**; p50 **14** · max **177** · `coalesced=1` **0** |
| BURST | **0** |
| SLOW RIME (async) | **3** (~184 / 192 / 177 ms) — still off KEY END |
| KEY END (context) | #21–#39 (**19** in paste); mean **~4.0 ms**; ≥100 **0**; worst **5.7 ms** |
| L1_SKIP | **0** in paste |
| Integrity | `committed=false`; no digit-leak markers in paste |
| Subjective | **比 A 更跟手一点**；**候选栏 + Path bar 同步闪烁**（Human 判为 bug） |

### Flicker root cause (structure, from log)

Every key under L1 shows a **double paint**:

1. **L1:** `source=provisional` → clear Path/candidates → `fillCandidateBar items=1` → KEY END ~5 ms  
2. **L2:** async RIME → `source=engine` → `fillCandidateBar items=12` + Path refresh  

This matches Human “打字时键盘闪烁，尤其是候选栏和 path bar”. Rem-3 design required chrome disable while ahead; implementation clears then re-fills on every L2 — visible thrash under normal typing pace.

---

## Direction gate (Rem-3-Device)

| Check | A | B | Result |
|---|---|---|---|
| Integrity | OK | OK | Pass |
| Key follow (subjective) | partial delay | **更跟手** | **B better** |
| Progressive L1 markers | n/a | provisional lag=0 then engine | **Pass** |
| Freeze-then-burst | no | no | Pass |
| KEY END ≥100 | 4 | 0 | B “better” (expected dual-gate; secondary) |
| Chrome stability | stable | **flicker bug** | **Residual FAIL / open defect** |

### **Rem-3-Device direction: PASS (key-follow + L1 progressive), with residual P1 chrome flicker**

- **Closed for knife goal:** dual-gate + L1 proves progressive accept-time paint (`source=provisional`) and better key follow than gate-off on this pair.  
- **Not closed:** candidate/Path **double-paint flicker** is Product-visible and should block any narrative of “ready for Gate / polish complete”.  
- **Not Product Gate / default-on / ADR Accept.**

### Honest caveats

1. Log paste truncated — early PATH/READY/ACCEPT may be missing; mid-run markers sufficient for path identity.  
2. Single pair stop-fast.  
3. Debug-only compile-flag arm.  
4. RIME still slow off KEY END (SLOW ~180–190 ms).  
5. Flicker is implementation residual, not “Human error”.

---

## Recommended Product next (optional)

1. **Rem-3-Polish / P1:** avoid full candidate/Path chrome tear-down on every L1 tick; keep stable empty/disabled chrome until L2; or coalesce L1 UI with L2 if engine returns within N ms.  
2. Hold dual-gate default-off until flicker closed.  
3. Do **not** open Product Gate on this evidence alone.

## Teardown

- Reinstalled Arm A (gate-off) Debug binary on device.  
- Human should fully reload keyboard once more if still on dual-gate session.  
