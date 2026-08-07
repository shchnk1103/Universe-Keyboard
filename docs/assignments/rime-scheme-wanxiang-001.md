# Assignment: RIME-SCHEME-WANXIANG-001 — Support 万象拼音 scheme

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Assignment Pending` |
| **Phase** | Direction recorded; freeze Q1–Q5 before Ready |
| **Parent PD** | [`PD-RIME-SCHEME-WANXIANG-001`](../product-decisions/RIME-SCHEME-WANXIANG-001-authorization.md) |
| **Non-claims** | Implementation not authorized until Ready; not T9 mixed-candidate work |
| **Next** | Product/Architecture freeze upstream package + schema ID + size budget |
| **Residuals** | None |

---

**Task ID:** `RIME-SCHEME-WANXIANG-001`  
**Date / timezone:** `2026-08-07 Asia/Shanghai`  
**Repository Change Type:** `Product` → later `Implementation` when Ready  
**Product Decision source:** PD above  

## Authority

- Assignment Authority: Product Lead  
- Decision Source / Date: PD; 2026-08-07 Asia/Shanghai  
- Product Approver: Human Product Lead  

## Boundary

### Scope (when Ready)

1. Add 万象拼音 to main-App scheme catalog (download / install / uninstall / set current) using existing list-and-detail model.  
2. Main-App full deploy; Extension only sessions on prepared data (ADR 0001).  
3. Smoke: select schema, type synthetic input, candidates non-empty; no private text logs.  
4. Docs: `RIME_SCHEME_MANAGEMENT.md`, changelog, capability matrix (Lua/advanced input).  

### Non-goals

- T9 first-key Apple-like union  
- Extension-side download  
- All 万象 double-pinyin variants in first slice (unless Product freezes them in)  

## Assignment

- Domain Owner: 🔧 RIME Platform / Main App scheme management  
- Executor: UNKNOWN until Ready  
- Environment Executor: UNKNOWN (device install smoke later)  
- Human Dependency: Product freeze of upstream asset + license acceptance copy  
- Architecture Reviewer: Required before production install path  
- Quality Reviewer: Required before acceptance  

## Gates

### Entry Criteria (Ready)

- [ ] Q1–Q5 in PD answered or explicitly deferred with Owner  
- [ ] No blocking UNKNOWN for Domain Owner / Executor / reviewers  
- [ ] Active Work capacity if activated (≤10)  

### Exit Criteria

- TBD after scope freeze  

### Stop Conditions

- Shipping incomplete catalog that leaves Extension on missing files  
- Treating chat as license or size evidence  
- Coupling to closed mixed-candidate PD  

## Handoff

- Handoff Target: Product Lead → Architecture → Executor  
- Required Handoff Content: frozen upstream ref, schema IDs, install plan, size budget  
- Revalidation Trigger: upstream major release layout change  

## History

- 2026-08-07: Opened Assignment Pending after Product direction to support 万象拼音.
