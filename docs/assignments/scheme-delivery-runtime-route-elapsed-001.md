# Assignment: SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001 — RTRD-02

Policy version: `1.0.0`

## Current Status

| Field | Value |
|---|---|
| Lifecycle | `Active` |
| Current phase | SUG-07 preflight filled. Same-field ordinary Luna `elapsed_ms` is `unreadable`. No operator round started |
| Non-claims | No performance pass/fail; no Product Gate / TestFlight / Release; no SUG-08; no Swift; does not close DEVICE-001 |
| Next handoff / decision | Human: accept this measurement gap, or authorize a new diagnostic for ordinary Luna deploy elapsed |
| Residuals | Ordinary Luna deploy does not emit `runtime_route.phase_changed` |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [PD](../product-decisions/SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001-authorization.md), `2026-09-11 Asia/Shanghai`
- **Product Approver:** Human Product Owner
- **Authorization:** [AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001](../authorizations/AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001.md)

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Adopted | Source-audit of whether comparable elapsed fields exist in the privacy-safe UI |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment → Authorization → Product Decision |
| P-01 publication facts | Adopted | Lands with the glance Close packet on `docs/rtrd-01-glance` |
| D-01 final-documentation receipt | Not applicable | |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| SUG-07 preflight for comparable elapsed | Authorized | Record whether ordinary Luna and fallback expose the same `elapsed_ms` in diagnostics UI | This Assignment → [AUTH](../authorizations/AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001.md) |
| Operator uninstall / Luna deploy round | Not authorized | Another Human uninstall or schema switch to collect numbers | New Human authorization **after** both arms are `readable` |
| New Swift elapsed producer | Not authorized | Emit ordinary Luna deploy elapsed in privacy-safe UI | New Assignment |
| SUG-08 | Not authorized | Raw JSONL read | New Assignment |
| Product Gate / Release | Not authorized | | New Human authorization |

## Boundary

### Objective

DEVICE-001 residual `RTRD-02`: compare ordinary Luna deploy `elapsed_ms` with fallback Luna deploy `elapsed_ms`, as observations only, from the privacy-safe diagnostics UI. Do not invent a regression threshold.

### Scope

1. Adopt SUG-07 for this comparison.
2. Record from source whether both arms exist on the same event code and the same elapsed definition.
3. Stop operator collection while either arm is `unreadable`.

### Non-goals

- Declaring fallback deploy faster/slower than ordinary Luna.
- SUG-08, journal schema change, Swift, Product Gate, TestFlight, Release.
- Closing DEVICE-001.
- Copying UUID or elapsed **numbers** into chat unless a later operator round is authorized and the protocol asks only for integers already shown in the UI.

### Required Inputs

- [DEVICE-001](scheme-delivery-runtime-route-device-001.md) residual `RTRD-02`
- [Glance](kos-sug-obs-glance-001.md) (keys are visible on uninstall events)
- `SchemaManager+Installation.swift` `recordActiveUninstallRoutePhase`
- `DiagnosticEvent.RuntimeRoutePhaseEvent.elapsedMilliseconds` comment: time since the owning **uninstall** began

## Assignment

- **Domain Owner:** Main App UI / Diagnostics
- **Executor:** Current Grok session — preflight and measurement-contract record
- **Environment Executor:** Not Applicable this slice (no build/install)
- **Human Dependency:** Not Applicable this slice (no operator uninstall)
- **Architecture Reviewer:** independent runtime, lane `RTRD-02/document-architecture`
- **Quality Reviewer:** independent runtime, lane `RTRD-02/document-quality`
- **Handoff Target:** Human Product Owner

## Gates

### Entry Criteria

- [x] Human started RTRD-02.
- [x] Glance showed uninstall-path keys including `elapsed_ms`.
- [x] No `UNKNOWN` responsibility.

### Exit Criteria

- Comparable same-field pair recorded **or** preflight shows ordinary Luna arm `unreadable` and Human accepts that gap / authorizes Swift.
- No invented threshold.

### Stop Conditions

- Asking the operator to uninstall to chase an ordinary-Luna `runtime_route` line that the producer cannot emit.
- Mixing `schemeDelivery` lines with `runtime_route.elapsed_ms` and calling them the same measurement.
- SUG-08 or Product Gate.

## History

- `2026-09-11 Asia/Shanghai` — Human: “开始 RTRD-02”.
