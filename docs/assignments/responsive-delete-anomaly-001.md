# Assignment: RESPONSIVE-DELETE-ANOMALY-001 — Dual-gate Delete stall / wipe

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Completed` — RC proven + fix + tests |
| **Phase** | Fix landed in Core bridges; awaiting device smoke confirmation |
| **Parent** | [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md) / Product Gate default-on |
| **Non-claims** | Not SLO; device reconfirm optional |
| **Next** | Human smoke on device after install; then Close |
| **Residuals** | Device reconfirm (`accept` for automated close; optional Human) |

### Root cause (proven)

Bridge `replaceInput` / select bound to `lastPublished` **before** draining deferred
`processKey` backlog. `performOrderedNow` then advanced revision; bound work
skipped as stale. Visible T9 Delete then saw mismatched raw and **fail-closed wipe**.
Same stale bind → silent restore full raw ≈ **Delete no-op / stuck**.

### Fix

`ResponsiveRimeEngineBridge` + `ThreadAffineRimeEngineBridge`:
`flushPending()` **before** capture binding / ordered Delete.

### Evidence

| Check | Grade | Result |
|---|---|---|
| `ResponsiveDeleteAnomalyTests` (3) | Executor-recorded | **3/0** |
| Full KeyboardCore | Executor-recorded | **918/0** |

---

**Task ID:** `RESPONSIVE-DELETE-ANOMALY-001`  
**Date / timezone:** `2026-08-06 Asia/Shanghai`  
**Repository Change Type:** `Evidence` + optional `Tests` (diagnosis); `Implementation` only after proven RC  
**Product Decision source:** Human report + Active parent responsive default-on; investigation authorized in-session under KOS 2.1  
**Architecture:** ADR 0025 Accepted; dual-gate request default-on  

## Authority

- **Assignment Authority:** Product Lead (Human in-session investigation request)  
- **Domain Owner:** 🧠 Input Intelligence / 🔧 RIME Platform (responsive delete path)  
- **Executor:** Current agent (diagnosis first)  
- **Architecture Reviewer:** Required before non-trivial design change  
- **Quality Reviewer:** Required for fix acceptance  

## Scope

1. Investigate two reported anomalies after a composition string:  
   - Delete appears stuck while new keys still type  
   - Few Delete presses clear entire composition  
2. Separate UI / KeyboardCore / dual-gate owner / host marked-text boundaries.  
3. Add failing regression tests if reproducible with Fake engine.  
4. Propose minimal fix only when RC is proven.  

## Non-goals

- Broad responsive redesign  
- Logging private host text  
- Claiming root cause from chat alone  

## Stop Conditions

- Speculative production fix without reproduction/evidence  
- Privacy-violating logs  

## Explicit non-claims

- Not confirmed RC yet  
