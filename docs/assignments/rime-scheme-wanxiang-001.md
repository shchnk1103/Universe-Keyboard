# Assignment: RIME-SCHEME-WANXIANG-001 — Support 万象拼音 + layout-bound scheme choice

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Assignment Pending` |
| **Phase** | Product freezes in; Architecture (ADR 0018) + Q1/Q2/Q4 still block Ready |
| **Parent PD** | [`PD-RIME-SCHEME-WANXIANG-001`](../product-decisions/RIME-SCHEME-WANXIANG-001-authorization.md) |
| **Non-claims** | Implementation not authorized until Ready |
| **Next** | Architecture Accept [`ADR 0026`](../architecture/decisions/0026-layout-bound-rime-scheme-selection.md); freeze 万象 upstream asset |
| **Residuals** | None |

---

**Task ID:** `RIME-SCHEME-WANXIANG-001`  
**Date / timezone:** `2026-08-07 Asia/Shanghai`  
**Repository Change Type:** `Product` → later `Implementation` when Ready  
**Product Decision source:** PD above (incl. freeze addendum)  

## Authority

- Assignment Authority: Product Lead  
- Decision Source / Date: PD; freezes 2026-08-07 Asia/Shanghai  
- Product Approver: Human Product Lead  

## Boundary

### Scope (when Ready) — expected work packages

**A. 万象拼音（全拼）目录项**

1. Catalog entry: download / install / uninstall / set as a selectable scheme.  
2. Main-App deploy; Extension session-only (ADR 0001).  
3. Smoke: select 万象全拼, synthetic typing, non-empty candidates.  
4. Docs: scheme management, capability matrix, size notes.

**B. 布局绑定方案选择（产品硬需求）**

1. Keyboard **layout** settings: for **26 键** and **九宫格**, user picks **which installed scheme** that layout uses.  
2. Runtime uses **layout’s scheme**, not only global `rime_active_schema` + automatic `t9` rewrite.  
3. Nine-key picker only lists schemes **capable** of nine-key (e.g. fog-song `t9`); 26-key picker lists 26-key schemes (fog-song, 万象全拼, luna, …).  
4. Migration: document default when per-layout scheme unset (Architecture).

### Product freezes already in PD

- 万象 V1 = **全拼**; 双拼 later  
- Large package **acceptable in principle**  
- **Disagree** with “万象 never on nine-key / nine-key always fog-only” as permanent product rule — **picker required**; 万象 appears on nine-key **only if** a nine-key-capable artifact exists  

### Non-goals

- 万象 V1 双拼矩阵  
- T9 mixed-candidate union  
- Extension download  

## Assignment

- Domain Owner: 🔧 RIME Platform + Main App settings (layout × scheme)  
- Executor: UNKNOWN until Ready  
- Environment Executor: UNKNOWN  
- Human Dependency: license copy; optional size acceptance on device  
- Architecture Reviewer: **Required** (ADR 0018 amendment)  
- Quality Reviewer: Required before acceptance  

## Gates

### Entry Criteria (Ready)

- [x] Product: 全拼 V1 / size / layout-bound picker freezes recorded  
- [ ] Architecture: [`ADR 0026`](../architecture/decisions/0026-layout-bound-rime-scheme-selection.md) Accepted or Conditional Accept  
- [ ] Q1–Q2 frozen (upstream asset + schema ID for 万象全拼)  
- [ ] Executor + reviewers named (no blocking UNKNOWN)  
- [ ] Active Work capacity if activated  

### Exit Criteria

- TBD after Ready  

### Stop Conditions

- Implementing layout picker by silently breaking nine-key algebra  
- Shipping 万象 without deploy/readiness  
- Reopening mixed-candidate PD  

## Handoff

- Handoff Target: Architecture (ADR 0018) → Product reconfirm → Executor  
- Required Handoff Content: amended ADR draft, migration table, 万象 asset pin  
- Revalidation Trigger: upstream 万象 layout change; new nine-key-capable scheme  

## History

- 2026-08-07: Opened Assignment Pending.  
- 2026-08-07: Product freezes — 全拼 V1; accept large size; layout-page scheme choice required (ADR 0018 conflict noted).
