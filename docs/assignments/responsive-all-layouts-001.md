# Assignment: RESPONSIVE-ALL-LAYOUTS-001 — 全中文布局响应式 RIME（default-off）

Policy version: 1.0.0

**Task ID:** `RESPONSIVE-ALL-LAYOUTS-001`  
**Lifecycle status:** `Completed — L0 layout-universal locked; 26-key automated suite 8/0; full KeyboardCore 914/0; Product Gate / default-on not claimed`  
**Date / timezone:** `2026-08-06 Asia/Shanghai`  
**Repository Change Type:** `Documentation` + `Tests` (+ `Implementation` if
inventory finds Core holes)  
**Product Decision:**
[`PD-RESPONSIVE-ALL-LAYOUTS-001`](../product-decisions/RESPONSIVE-ALL-LAYOUTS-001-authorization.md)  
**Architecture:** [`ADR 0025 Accepted`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)  
**Parent:** [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)

## Authority

- **Assignment Authority:** Product Lead  
- **Decision Source / Date:** PD-RESPONSIVE-ALL-LAYOUTS-001; Human authorization
  2026-08-06 Asia/Shanghai  
- **Product Approver:** Human Product Owner  

## Boundary

### Scope

1. Lock product/architecture language: responsive **L0** is layout-universal for
   Chinese RIME; **L1 provisional dots** remain T9-only.  
2. Automated KeyboardCore proof that with `usesT9InputSemantics == false` and
   gate-on:  
   - composition keys enqueue without waiting on Fake RIME delay  
   - ordered Delete / candidate select / gate-off restore work  
   - **no** provisional L1 `·` ahead state  
3. Automated proof that T9 dual-gate L1 still requires T9 semantics (no
   regression).  
4. Layout-flag switch (non-T9 ↔ T9) does not leave dual-entry or stuck L1.  
5. Code fix only if tests expose a real 26-key hole.  
6. Dashboard / Index / ADR short amendment note.

### Non-goals

- Release default-on / Product Gate / SLO  
- English / emoji layout claims  
- Multi-device canary reopen  
- New 26-key provisional UX  
- Auto-anchor expansion  
- Extension UIKit device matrix  

### Required Inputs

- ADR 0025 Accepted + POST-ACCEPT-001 hygiene  
- Existing Responsive* suites  
- `usesT9InputSemantics` vs gate separation in `KeyboardController`  

## Assignment

- **Domain Owner:** 🧠 Input Intelligence Maintainer  
- **Executor:** Current Grok primary agent  
- **Environment Executor:** Local `swift test` on KeyboardCore  
- **Human Dependency:** `Not Applicable` (no device this phase)  
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward (required if
  Decision/ADR surface changes beyond short amendment)  
- **Quality Reviewer:** 🧪 Quality Maintainer (required for residual-close /
  new contract tests)

## Gates

### Entry Criteria

- [x] Product Decision recorded  
- [x] ADR 0025 Accepted; default-off locked  
- [x] Responsibilities assigned  

### Exit Criteria

- [x] ADR short layout-universal amendment note (§0)  
- [x] 26-key (non-T9) responsive L0 automated suite green (`ResponsiveRimeAllLayoutsTests` **8/0**)  
- [x] T9 L1 remains T9-only (regression in same suite)  
- [x] Full KeyboardCore **914/0**  
- [x] Explicit non-claims retained  
- [x] Navigation state synced  

### Stop Conditions

- Attempt to default-on or claim Product Gate  
- Forcing T9 L1 onto 26-key  
- `@unchecked Sendable`  
- Scope expansion to English layouts  

## Handoff

- **Handoff Target:** Product Lead; next Product Gate only under new Decision  
- **Required Handoff Content:** test counts, any code fixes, open residuals  
- **Revalidation Trigger:** default-on Decision; new Chinese layout schema  

## Explicit non-claims

- Not Product Gate  
- Not default-on  
- Not SLO  
- Not English-layout coverage  
