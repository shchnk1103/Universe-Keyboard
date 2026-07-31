# T9 responsive pipeline Formal R5 — device A/B evidence — 2026-07-31

**Status:** `Closed — Formal R5 direction FAIL (1 pair A→B); Product Gate not claimed`  
**Design:** [`r5-formal-design`](../assignments/t9-responsive-pipeline-001-r5-formal-design.md)  
**Product:** Formal R5 authorized 2026-07-31  
**Source tip:** `87d3e7c`  
**Product Gate / ADR Accept / Release default-on:** **not claimed**

## Device run header

| Field | Value |
|---|---|
| Device | iPhone 13 Pro `DoubleShy0N` / `iPhone14,2` |
| UDID | `00008110-000A08440198801E` |
| OS | iOS 27.0 (`24A5390f`) |
| Host | Reminders, new empty title per arm |
| Layout | Universe Keyboard Chinese nine-key, portrait |
| Fixture (Human only) | `jintiandetianqizhenbucuowomenchuquwanba` |
| Interaction | letter-group keys only (contract); mid-arm controls not used |
| Access | Full Access expected |
| Logging | `logging_enabled=true`; engine + perf categories |
| Matrix | Stop-fast **1 valid pair A→B** (direction obvious; pairs 2–3 not required) |

### Arm identities (Debug, replacement install)

| Arm | Configuration | Extension SHA256 (Keyboard binary) |
|---|---|---|
| **A** (baseline) | Debug, no preflight define, `dualGate=false` | `2dc1e0fa5025c46564230ce5ab7ae382819f33554aca89a7ef96f2144c99e2d8` |
| **B** (dual-gate) | Debug + `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`, `dualGate=true` | `84eec764a9a5fe44b833f74ec24003a0d7ba6e4449e727d16d2c8a8ed7e39d3f` |

Local DerivedData:

- A: `build/r5-formal/DerivedData-A`
- B: `build/r5-formal/DerivedData-B`

## Install ledger

| Step | Time (local) | Result |
|---|---|---|
| Build A / B | 2026-07-31 | **BUILD SUCCEEDED** both |
| Install A | ~13:13 | Done |
| Human Arm A | ~13:14 | Logs + subjective |
| Install B | ~13:16 | Done |
| Human Arm B | ~13:17–13:18 | Logs + freeze-then-burst subjective |
| Teardown gate-off | ~13:19 | **Done** — Arm A binary + `dualGate=false` |

---

## Pair 1 — Arm A (gate-off)

| Field | Value |
|---|---|
| Path identity | Gate-off sync (paste truncated before PATH; KEY END includes engine/rime; `validBefore=true`) |
| KEY END sample | **#6–#39** (34; missing #1–#5 in paste) |
| KEY END ≥100 ms | **4** (#16=205.4, #25=182.7, #33=215.1, #35=175.5) |
| Worst KEY END | **215.1 ms** |
| Mean KEY END (34) | ~36.5 ms |
| SLOW RIME peaks | 203.4 / 180.6 / 212.9 / 173.4 ms |
| Integrity | Session stable; `committed=false`; cands=12; no exit |
| Stall severity | **2** (有卡顿；按键有时不跟手) |
| Relative note | Mid/late spikes hurt, but continuous typing still possible |

---

## Pair 1 — Arm B (dual-gate on)

| Field | Value |
|---|---|
| Path identity | **thread-affine dual-gate** (PUBLISH `T9RESP-R5P` rev 7→34 continuous; KEY END ~1 ms; `sessionBefore=0 validBefore=false` bridge pattern). PATH/READY lines not in truncated paste head; path proven by PUBLISH + install identity + preflight precedent. |
| KEY END sample | **#8–#39** (32; paste truncated early keys) |
| KEY END ≥100 ms | **0** |
| Worst KEY END | **3.1 ms** |
| Mean KEY END (32) | ~1.1 ms |
| PUBLISH | 28 lines observed; max **rev=34** |
| SLOW RIME (async bridge) | peaks **179.2 / 156.9 / 198.5 / 207.0 ms** (still present off KEY END path) |
| Large idle gap | **idleMs ≈ 5025 ms** mid-run (Human freeze window) |
| Burst publish cluster | ~13:17:53.6 many PUBLISH rev 16–32 in &lt;50 ms after multi-second stall |
| Integrity / UX | **Regression:** mid-composition **freeze**, then **catch-up burst** of all typed keys |
| Stall severity | **4** (impractical mid-arm freeze; worse than A) |
| Human quote (paraphrase) | 打到一半卡死；比 A 更夸张；停顿后瞬间出现卡顿期间所打的字 |

---

## Direction gate (D5)

| Check | A | B | Result |
|---|---:|---:|---|
| Integrity | OK continuous | **Freeze-then-burst** | **B worse (Fail)** |
| KEY END ≥100 ms count | 4 | 0 | B “better” on this counter only |
| Worst KEY END | 215.1 | 3.1 | B “better” on this counter only |
| Subjective stall | 2 | **4** | **B worse (Fail)** |
| Async RIME still slow | yes (in KEY END) | yes (BRIDGE, not KEY END) | Cost moved, not removed |

### Metric honesty (Architecture note)

On dual-gate arm, **`KEY END total` is not a valid proxy for felt latency**: MainActor returns before owner-thread `processKey`. Arm B’s ge100=0 / worst=3.1 **must not** be read as smoother typing. Felt freezes align with **queue backlog + SLOW RIME BRIDGE + multi-second idle + burst PUBLISH**.

### **Formal R5 direction: FAIL**

Per design D5: subjective much worse **and** composition UX integrity regression (freeze-then-burst), despite misleading KEY END improvement.

Stop-fast: **do not** run pairs 2–3 for direction; evidence is sufficient for FAIL disposition.

---

## Role disposition

| Role | Judgment |
|---|---|
| 🧪 Quality | Pair bound to tip `87d3e7c` A/B hashes; direction **FAIL**; KEY END metric insufficient alone for dual-gate |
| 🏛️ Architecture | Dual-gate path is live on device; product failure mode is **result lag / backlog burst**, not “keys wait on RIME on MainActor”. Residual: need action→first-visible-composition / pending-depth / publish-lag markers before next device claim; ADR 0025 remains Proposed |
| 🧭 Product Lead | **Formal R5 Closed as direction FAIL**. No Product Gate. No Release default-on. No ADR Accept. Parent Assignment stays Active under Hold for responsive pipeline until a new knife addresses backlog/UI lag |
| 📋 Program Manager | Device restored gate-off; next work needs Product auth (e.g. R5-remediation design for publish lag / pending depth / local feedback without freeze-burst) |

## Explicit non-claims

- Product Gate / Release default-on / ADR 0025 Accept / R6
- Numeric product SLO
- Release-like measurement surface
- Multi-device generality
- “KEY END fast ⇒ not stuttery” on dual-gate

## Recommended next Product options (not authorized here)

1. **Hold** formal R5 FAIL evidence; do not arm dual-gate on device for daily use.
2. Authorize **R5-remediation design** only: content-free publish-lag / pending-depth / first-visible composition metrics + backlog policy (coalesce already exists; freeze-burst may need local provisional composition or bound UI backlog).
3. Do **not** interpret this FAIL as reopening auto-anchor expansion.
