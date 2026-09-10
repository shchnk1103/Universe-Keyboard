# Assignment: SCHEME-DELIVERY-RUNTIME-ROUTE-DIAGNOSTICS-UI-001 — RTRD-01

Policy version: `1.0.0`

## Current Status

| Field | Value |
|---|---|
| Lifecycle | `Active` |
| Current phase | Implement privacy-safe runtime-route fields in diagnostics list, copy, and tap-detail sheet |
| Non-claims | No uninstall device round; no SUG-08; no journal schema change; no Product Gate / TestFlight / Release |
| Next handoff / decision | Tests + Human publication |
| Residuals | `RTRD-02` elapsed comparison remains on DEVICE-001 |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner, `2026-09-10 Asia/Shanghai`, after SUG-07 preflight: “之后开始RTRD-01”
- **Product Approver:** Human Product Owner

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | Implementation slice; device claims stay on later evidence. |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment is the current slice. |
| P-01 publication facts | Not applicable | Push/PR not yet authorized. |
| D-01 final-documentation receipt | Not applicable | |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current RTRD-01 UI | In progress | Show finite `runtimeRoutePayload` keys in list/copy and a bottom sheet | This Assignment; DEVICE-001 residual `RTRD-01` |
| Push / PR / merge | Not authorized | Publication | New Human authorization |
| SUG-07 uninstall round | Not authorized | Human Device Operator uninstall | New authorization after fields are readable |
| SUG-08 | Not authorized | Raw file read | New Assignment |

## Boundary

- **Scope:** Main App diagnostics presentation only. List/copy line and tap sheet show `operation`, `phase`, `result`, `schema`, `layout`, `state`, `elapsed_ms`.
- **Non-goals:** Journal writer/schema, RIME routing, uninstall evidence, SUG-08, keyboard extension UI, Product Gate.

## Assignment

- **Domain Owner:** Main App UI
- **Executor:** Current Grok session
- **Environment Executor:** Current session for Simulator tests
- **Human Dependency:** Not Applicable for this implementation slice
- **Architecture Reviewer:** independent review of privacy field allowlist
- **Quality Reviewer:** UniverseKeyboardTests for formatter/detail parsing
- **Handoff Target:** Human Product Owner

## Gates

- **Entry:** Human authorized start of RTRD-01 after #109 merge.
- **Exit:** List/copy expose the finite keys; tap sheet shows the same allowlist; tests cover no user-content leakage.
- **Stop:** Any request to log input/candidates, read App Group files, or change route policy.

## History

- `2026-09-10 Asia/Shanghai` — Human: push SUG-07 device docs then “之后开始RTRD-01”.
