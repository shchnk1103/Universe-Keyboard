# T9-RESPONSIVE-PIPELINE-001 / Formal R5 design

**Status:** `Closed — Formal R5 direction FAIL (1 pair A→B freeze-then-burst on dual-gate)`  
**Date:** `2026-07-31 Asia/Shanghai`  
**Role author:** 🏛️ Architecture & Knowledge Steward  
**Product:** Formal R5 authorized by Human Product Owner instruction  
  「根据KOS2.0设定完成R5工作吧」  
**Predecessor:** R5-Preflight Closed (`87d3e7c` + device path on/off)  
**Implementation tip:** `87d3e7c` (same tree; A/B differ only by dual-gate arm)  
**Evidence:** [`../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md`](../evidence/t9-responsive-pipeline-r5-formal-2026-07-31.md)  
**ADR 0025:** remains **Proposed**

---

## 1. Boundary

### In scope

| Item | Decision |
|---|---|
| Host | Reminders, new empty title per arm |
| Device | Same iPhone 13 Pro used for Preflight |
| Layout | Universe Keyboard Chinese nine-key, portrait |
| Fixture spelling (Human only) | `jintiandetianqizhenbucuowomenchuquwanba` |
| Log identity | `T9RESP-R5` (path/publish still may show `T9RESP-R5P` fixture token from preflight code — evidence maps arm by PATH/dualGate, not spelling) |
| Arm A | Debug, dual-gate **OFF** (no preflight compile flag; `dualGate=false`) |
| Arm B | Debug, dual-gate **ON** (`-DT9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` + `dualGate=true`) |
| Install | Replacement only; no uninstall / container wipe / userdb reset |
| Operator | Human Product Owner types; Environment Executor installs |
| Logs | Content-free App diagnostics only (`T9RESP`, `KEY END`, `SLOW KEY`/`SLOW RIME`, `T9SEG` totals) |
| Matrix | Stop-fast **1 valid pair** first; expand to 3 only if direction unclear |
| Order | Pair 1: **A → B** |

### Out of scope / non-claims

- Product Gate / Release default-on / ADR 0025 Accept
- Numeric product SLO lock
- Coordinate XCTest / Computer Use typing
- Multi-device matrix
- Claiming Release-like product conclusion (both arms are **Debug** with equal instrumentation cost; Product Gate later may require Release-like measurement surface)
- Auto-anchor expansion

---

## 2. Frozen decisions

### D1 — Arm identity

- **A (baseline):** path must be `sync` or non-thread-affine with `dualGateActive=0`.
- **B (responsive dual-gate):** path must be `thread-affine` with `dualGateActive=1` + READY.

Invalid arm if wrong PATH/dualGate, wrong layout, non-empty start composition, mid-arm Path/candidate/Space/Delete/Return, interruption, or keyboard exit.

### D2 — Interaction contract

- Letter-group keys only for the fixture length.
- No Path / candidates / Space / Delete / Return mid-arm.
- Wait ≥2 s after last key before ending arm.
- New empty Reminders title each arm.

### D3 — Content-free metrics (export)

From diagnostics (no raw spelling / pinyin / candidates / host text):

| Metric | Source |
|---|---|
| Path identity | `T9RESP marker=PATH …` |
| Publish presence (B) | `T9RESP marker=PUBLISH …` count / max rev |
| Per-key `KEY END total` | `PERF KEY END` lines |
| Count of keys with `total ≥ 100 ms` | derived |
| Worst `KEY END total` | derived |
| Cold first-key RIME | first `SLOW RIME` / bridge ms if present |
| Integrity | Human: missing/dup input, digit leak, candidate disappearance, keyboard exit, unexpected commit |

### D4 — Subjective score (Human, immediate)

Stall severity 0–4 (same scale as auto-anchor manual observation):

| Score | Meaning |
|---|---|
| 0 | none noticed |
| 1 | slight, does not disturb typing |
| 2 | clearly noticeable |
| 3 | repeated pauses / catch-up |
| 4 | impractical / input lost |

Also note: key highlight follows finger (Y/N); composition freezes then bursts (Y/N).

### D5 — Direction gate (Quality, formal R5 only)

Relative **B vs A** on the same pair:

1. **Integrity:** B must not introduce missing/dup/digit/exit/wrong-commit.
2. **Latency direction (soft, content-free):** B should not increase (a) count of `KEY END total ≥ 100 ms` **and** (b) worst `KEY END total` vs A. Prefer reduction of (a) or (b).
3. **Subjective:** B stall severity ≤ A; product north-star is B feels less frozen under continuous typing.

**Pass:** integrity OK **and** (latency direction improves **or** subjective improves without latency regression on both (a) and (b)).  
**Fail:** integrity regression **or** both latency metrics worse **or** subjective worse with no latency improvement.  
**Inconclusive:** mixed signals after 1 pair → run pairs 2–3 (order B→A, A→B) before Product disposition.

This gate is **not** Product Gate and does **not** lock numeric SLOs.

---

## 3. Environment procedure

1. Confirm tip `87d3e7c` (or document rebuild tip if docs-only commits intervene).
2. Build A: Debug, no preflight define → install → `dualGate=false` → recycle keyboard.
3. Human: arm A fixture + export logs + scores.
4. Build B: Debug + `-DT9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` → install → `dualGate=true` → recycle keyboard.
5. Human: arm B fixture + export logs + scores.
6. Teardown: reinstall A or ordinary gate-off Debug; `dualGate=false`.
7. Quality extracts content-free table; Architecture confirms path identities; Product records R5 disposition.

---

## 4. Evidence package

- This design
- Device run header (device/OS/host/schema/access/tip/hashes)
- A/B marker excerpts + derived latency table
- Human subjective scores
- Direction verdict + non-claims
- Optional: Extension binary SHA256 per arm

---

## 5. Stop conditions

Stop and escalate if:

- dual-gate fails to arm on B or fails to stay off on A;
- logging cannot capture `KEY END` / `T9RESP`;
- Human cannot complete fixture without mid-arm controls;
- work would require Release default-on or ADR Accept.
