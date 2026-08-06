# Assignment: RESPONSIVE-DEFAULT-ON-001 — Product Gate / dual-gate Release default-on

Policy version: 1.0.0

**Task ID:** `RESPONSIVE-DEFAULT-ON-001`  
**Lifecycle status:** `Reviewed — Product Gate dual-gate default-on implemented; Arch Pass with conditions (remediated); Quality Pass with conditions; residuals visible`  
**Date / timezone:** `2026-08-06 Asia/Shanghai`  
**Repository Change Type:** `Implementation` + `Tests` + `Contract` + `Documentation`  
**Product Decision:**
[`PD-RESPONSIVE-DEFAULT-ON-001`](../product-decisions/RESPONSIVE-DEFAULT-ON-001-authorization.md)  
**Architecture:** [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)  
**Parent:** [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)

## Authority

- **Assignment Authority:** Product Lead  
- **Decision Source / Date:** PD-RESPONSIVE-DEFAULT-ON-001; Human Product Gate
  authorization 2026-08-06 Asia/Shanghai  
- **Product Approver:** Human Product Owner  

## Boundary

### Scope

1. Product Gate record: dual-gate is ordinary Release **default request**.  
2. Implement arming: ordinary builds request dual-gate without Debug-only /
   UserDefaults-only / canary-only paths.  
3. Preserve **fail-closed** install → ADR 0004 sync path.  
4. Preserve CANARY_INTERNAL compile path independence.  
5. Update ADR 0025 §8 gate contract + ADR 0004 cross-link language.  
6. Automated tests for arming policy + existing Core suites green.  
7. Independent Architecture + Quality reviews.  
8. Dashboard / Index / parent lifecycle sync.

### Non-goals

- Numeric SLO lock  
- New user-facing settings screen  
- Multi-device re-canary  
- English-layout claims  
- Auto-anchor expansion  
- Weakening isolation / `@unchecked Sendable`  

### Required Inputs

- ADR 0025 Accepted; ALL-LAYOUTS-001; CANARY Stop/Retain; PERF directional stack  
- Existing dual-gate install + fail-closed in Extension bootstrap  

## Assignment

- **Domain Owner:** 🔧 RIME Platform Maintainer (session ownership / Release path)  
- **Executor:** Current Grok primary agent  
- **Environment Executor:** Local KeyboardCore `swift test` (and Extension unit
  tests if touched); no new physical-device campaign required by PD  
- **Human Dependency:** Product Lead (Gate already authorized)  
- **Architecture Reviewer:** Independent 🏛️ Architecture review required before
  treating Gate as closed  
- **Quality Reviewer:** Independent 🧪 Quality review required for evidence +
  test integrity  

## Gates

### Entry Criteria

- [x] Explicit Product Decision for default-on  
- [x] ADR 0025 Accepted; ALL-LAYOUTS L0 universal  
- [x] Responsibilities assigned  

### Exit Criteria

- [x] Arming policy implemented + tests  
- [x] ADR §8 / 0004 language updated for Product Gate default  
- [x] KeyboardCore **915/0** (Executor-recorded)  
- [x] Independent Architecture review:
      [`responsive-default-on-001-architecture-review.md`](responsive-default-on-001-architecture-review.md)
      — Pass with conditions; P1 fail-closed teardown remediated  
- [x] Independent Quality review:
      [`responsive-default-on-001-quality-review.md`](responsive-default-on-001-quality-review.md)
      — Pass with conditions  
- [x] Navigation synced; residuals visible  

### Stop Conditions

- Install path loses fail-closed fallback  
- Dual-entry into live librime under default-on  
- Claiming SLO or erasing Formal R5 FAIL  
- `@unchecked Sendable`  

## Handoff

- **Handoff Target:** Product Lead after Arch/Quality; optional App Store release
  remains a separate RELEASE Assignment  
- **Revalidation Trigger:** dual-gate install redesign; new isolation model  

## Explicit non-claims

- Not App Store submission by itself  
- Not performance SLO  
- Not English layouts  
