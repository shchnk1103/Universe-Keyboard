# Assignment: T9-SINGLE-KEY-MIXED-CANDIDATES-001 — Apple-like first-key mixed candidates

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Assignment Pending` — goal recorded; Entry not met for Ready |
| **Phase** | Product approach Gate; no implementation |
| **Parent PD** | [`PD-T9-SINGLE-KEY-MIXED-CANDIDATES-001`](../product-decisions/T9-SINGLE-KEY-MIXED-CANDIDATES-001-authorization.md) |
| **Non-claims** | Not dual-gate bugfix; not authorized to change ADR 0021 yet |
| **Next** | Product Lead pick approach band A–D; Architecture review of ownership |
| **Residuals** | None |

---

**Task ID:** `T9-SINGLE-KEY-MIXED-CANDIDATES-001`  
**Date / timezone:** `2026-08-07 Asia/Shanghai`  
**Repository Change Type:** `Product` (goal only); `Implementation` blocked  
**Product Decision source:** [`PD-T9-SINGLE-KEY-MIXED-CANDIDATES-001`](../product-decisions/T9-SINGLE-KEY-MIXED-CANDIDATES-001-authorization.md)  
**Architecture:** Requires ADR 0021 amendment or superseding ADR before production code  

## Authority

- Assignment Authority: Product Lead  
- Decision Source / Date: PD above; 2026-08-07 Asia/Shanghai  
- Product Approver: Human Product Lead  

## Boundary

### Scope (when later Ready)

1. Deliver north star in PD: unresolved single T9 digit → mixed Chinese candidates for that key’s letter group (Apple-like first-key spirit).  
2. Tests + device comparison evidence as Gate requires.  
3. ADR / docs sync.

### Non-goals

- Bundling with `RESPONSIVE-CANDIDATE-ANOMALY-001`  
- Full Apple multi-key LM parity  
- Speculative production merge without Product Gate  

## Assignment

- Domain Owner: 🧠 Input Intelligence (T9 presentation + RIME Chinese candidates)  
- Executor: UNKNOWN until Ready  
- Environment Executor: UNKNOWN (device compare later)  
- Human Dependency: Product Lead approach choice; optional Apple vs UK screenshots  
- Architecture Reviewer: Required before implementation  
- Quality Reviewer: Required before acceptance  

## Gates

### Entry Criteria (for Ready)

- [ ] Product selects approach band (or revised north star)  
- [ ] Architecture path for ADR 0021 conflict is named  
- [ ] No UNKNOWN fields that block Ready  
- [ ] Active Work capacity if activated  

### Exit Criteria

- TBD after approach freeze  

### Stop Conditions

- Implementing under dual-gate anomaly Assignment  
- Shipping letter probes without session restore / dual-gate FIFO analysis  
- Claiming Apple full parity without evidence  

## Handoff

- Handoff Target: Product Lead → Architecture → Executor  
- Required Handoff Content: chosen band, non-claims, ADR plan  
- Revalidation Trigger: dictionary/schema major change; dual-gate owner contract change  

## History

- 2026-08-07: Opened Assignment Pending after PD goal record; anomaly fix shipped separately.
