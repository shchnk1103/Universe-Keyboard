# Assignment: KOS-SUG-OBS-DEVICE-001 — SUG-07 真机可观测性 preflight

Policy version: `1.0.0`

## Current Status

| Field | Value |
|---|---|
| Lifecycle | `Active` |
| Current phase | Preflight filled; Architecture and Quality **Pass**; uninstall operator round **not** started |
| Non-claims | No uninstall; no SUG-08; no RTRD-01 Swift; no Product Gate / TestFlight / Release |
| Next handoff / decision | Human publication (push/PR) and/or next gated slice: RTRD-01 UI, optional glance, or stop |
| Residuals | Trace fields `unreadable` in privacy-safe UI — `RTRD-01` remains `fix` on [DEVICE-001](scheme-delivery-runtime-route-device-001.md) |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [PD](../product-decisions/KOS-SUG-OBS-DEVICE-001-authorization.md), `2026-09-10 Asia/Shanghai`
- **Product Approver:** Human Product Owner
- **Authorization:** [AUTH-KOS-SUG-OBS-DEVICE-001](../authorizations/AUTH-KOS-SUG-OBS-DEVICE-001.md)

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Adopted | Source-audit claims about UI field visibility only. |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment → Authorization → Product Decision. |
| P-01 publication facts | Not applicable | No push/PR authorized. |
| D-01 final-documentation receipt | Not applicable | Local docs-only checks are not a publication receipt. |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| SUG-07 preflight fill | In progress | Record readability of UUID / phase / elapsed in privacy-safe diagnostics UI | This Assignment → [AUTH](../authorizations/AUTH-KOS-SUG-OBS-DEVICE-001.md) → [PD](../product-decisions/KOS-SUG-OBS-DEVICE-001-authorization.md) |
| Active-uninstall operator round | Not authorized | Ice/Wanxiang uninstall + `ni` candidate observation | New Human authorization **after** trace preflight is `readable`, or an explicit functional-only round |
| RTRD-01 diagnostics UI | Not authorized | Render `runtimeRoutePayload` in the privacy-safe list/detail | New Main App UI Assignment |
| SUG-08 raw-file read | Not authorized | Read a named JSONL file | New Assignment + Human authorization |
| Push / PR / merge / Release | Not authorized | Publication or Release | New Human authorization |

## Boundary

### Objective

Use the adopted SUG-07 table **before** asking a Human Device Operator to
uninstall again. If required trace fields are not visible in a privacy-safe UI
or export, mark them `unreadable` and **do not** spend a human uninstall round
to chase traces.

### Scope

1. Adopt [SUG-07 preflight](../kos/universe-keyboard-human-operated-evidence-profile.md#observability-preflight-kos-sug-07-opt-in).
2. Fill the table for active-uninstall **functional** vs **trace** claims from
   current `DiagnosticsEventDisplayFormatter` source on `origin/main`.
3. Record E-01 outcomes for those visibility claims. Do not instruct uninstall.

### Non-goals

- A new uninstall / candidate round.
- Implementing `RTRD-01` Swift or changing production log schema.
- SUG-08 directory or file reads.
- Product Gate, TestFlight, Release, ADR Accept.
- Push / PR.

### Required Inputs

- [SUG-07 profile](../kos/universe-keyboard-human-operated-evidence-profile.md)
- [DEVICE-001](scheme-delivery-runtime-route-device-001.md) residuals `RTRD-01` / `RTRD-02`
- `Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift`

## Assignment

- **Domain Owner:** Main App UI (diagnostics surface)
- **Executor:** Current Grok session — source-audit preflight only
- **Environment Executor:** Not Applicable — no build/install/device command in this slice
- **Human Dependency:** Not Applicable for uninstall. An optional on-device glance is a **separate** Human round and is not authorized here.
- **Architecture Reviewer:** independent runtime, lane `KOS-SUG-OBS-DEVICE-001/document-architecture`
- **Quality Reviewer:** independent runtime, lane `KOS-SUG-OBS-DEVICE-001/document-quality`
- **Handoff Target:** Human Product Owner

## Gates

### Entry Criteria

- [x] Product Decision and Authorization resolve to preflight-only execution.
- [x] SUG-07 template is on `main` (`KOS-SUG-OBS-PREFLIGHT-001` Closed).
- [x] No `UNKNOWN` responsibility.

### Exit Criteria

- [x] Preflight table has no `not-checked` row.
- [x] Trace `unreadable` rows do not trigger uninstall instructions.
- [x] Independent Architecture and Quality reviews of SHA `708cda81` **Pass** (`0/0/0/0`); addenda land with this packet.

### Stop Conditions

- Any request to uninstall, type into a host, or open a raw diagnostics directory.
- A proposal to treat event-code presence as UUID/phase/elapsed proof.
- Missing independent review before Close.

## Handoff

- **Required Handoff Content:** filled preflight table; E-01 visibility claims; explicit next gated slice (RTRD-01 UI vs optional glance vs stop).
- **Revalidation Trigger:** diagnostics formatter/UI change; Human authorizes uninstall or SUG-08.

## History

- `2026-09-10 Asia/Shanghai` — Human said “批准继续SUG-07 真机执行”. This Assignment interprets that as **running the SUG-07 preflight**, not repeating CS09-10-02 uninstall while trace fields are unreadable.
- `2026-09-10 Asia/Shanghai` — Architecture and Quality reviews of `708cda81` both **Pass** (`0/0/0/0`). Push/PR still unauthorized.
