# T9-RESPONSIVE-PIPELINE-001 / R5-Rem-3-Device design

**Status:** `Historical device-knife close — direction PASS (key-follow + L1) with
residual P1 chrome flicker before Polish-2; Polish-2 is tracked separately`
**Date:** `2026-08-01 Asia/Shanghai`  
**Product:** Human Product Owner authorized Rem-3-Device progressive A/B  
**Code tip:** `8169f64` (Rem-3 L1 + P1 remediation on main)  
**Evidence:** [`../evidence/t9-responsive-pipeline-r5-rem-3-device-2026-08-01.md`](../evidence/t9-responsive-pipeline-r5-rem-3-device-2026-08-01.md)  
**Predecessor:** Rem-Device key-feel PASS; Rem-3 implementation dual review + P1 close  
**Non-claims:** Product Gate / ADR Accept / default-on / Formal R5 rewrite **not** claimed

## 1. Goal

Score **progressive composition authority** under dual-gate + L1 (`·`×N) vs gate-off,
on the same Human fixture and device class as Rem-Device.

Primary: subjective progressive feel (do characters/length advance without freeze).  
Secondary: content-free `VISIBLE source=provisional|engine`, ACCEPT, PUBLISH lag, BURST.  
**Not primary:** KEY END alone.

## 2. Arms

| Arm | Binary | dual-gate | L1 |
|---|---|---|---|
| **A** | Debug, **no** `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` | off | off |
| **B** | Debug + `OTHER_SWIFT_FLAGS=$(inherited) -DT9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` | on | on (T9 digits) |

Compile flag alone arms dual-gate (preflight D1). App Group key optional reinforcement.

## 3. Protocol (stop-fast 1 pair A→B)

1. Logging on (engine + performance).
2. Host: Reminders, empty title per arm.
3. Layout: Chinese nine-key.
4. Fixture (Human only): `jintiandetianqizhenbucuowomenchuquwanba`
5. Arm A install → Human types fixture → export diagnostics (full buffer).
6. Arm B install → open keyboard once for PATH/READY → Human types fixture.
7. Human scores: stall 0–4; progressive length (yes/no); freeze-burst (yes/no); L1 dots seen (yes/no/unsure).
8. Teardown: reinstall Arm A / disarm flag; dualGate off.

## 4. Direction gate (Rem-3-Device)

| Check | Pass if |
|---|---|
| Integrity | no digit leak / crash / missing keyboard |
| Progressive | B shows progressive authority better or equal than A under lag |
| Freeze-burst | B does not regress Formal-R5-style freeze-then-burst |
| Markers (B) | PATH thread-affine Active=1; some `source=provisional` **or** honest skip reason if none |
| Subjective | Human stall score B ≤ A |

**PASS** = progressive/key-feel supports L1+dual-gate on this pair.  
**FAIL** = B worse freeze / no progressive benefit / integrity fail.  
Not Product Gate.

## 5. Roles

- **Environment Executor:** build/install/teardown, log pull
- **Human Product Owner:** typing + subjective scores + export
