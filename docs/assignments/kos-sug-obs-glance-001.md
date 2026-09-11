# Assignment: KOS-SUG-OBS-GLANCE-001 — SUG-07 真机 glance（RTRD-01 UI）

Policy version: `1.0.0`

## Current Status

| Field | Value |
|---|---|
| Lifecycle | `Closed` |
| Current phase | Published: PR [#112](https://github.com/shchnk1103/Universe-Keyboard/pull/112) merged `7caec79`; head `58179da`; hosted CI same-head green; remote feature branch deleted |
| Non-claims | No SUG-08; no Product Gate / TestFlight / Release; does not close DEVICE-001; no elapsed numbers recorded |
| Next handoff / decision | None for this slice. `RTRD-02` is [`SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001`](scheme-delivery-runtime-route-elapsed-001.md) |
| Residuals | None for this glance |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [PD](../product-decisions/KOS-SUG-OBS-GLANCE-001-authorization.md), `2026-09-10 Asia/Shanghai`
- **Product Approver:** Human Product Owner
- **Authorization:** [AUTH-KOS-SUG-OBS-GLANCE-001](../authorizations/AUTH-KOS-SUG-OBS-GLANCE-001.md) · [AUTH-…-DEBUG-INSTALL](../authorizations/AUTH-KOS-SUG-OBS-GLANCE-001-DEBUG-INSTALL.md)

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Adopted | Source-audit of post-#110 list/sheet keys; later device yes/no are separate claims |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment → Authorization → Product Decision |
| P-01 publication facts | Adopted | PR [#112](https://github.com/shchnk1103/Universe-Keyboard/pull/112) merged `7caec79`; head `58179da` |
| D-01 final-documentation receipt | Not applicable | Hosted docs-only CI is not this packet's D-01 receipt until after the last Markdown edit |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| SUG-07 preflight fill | Authorized | Record post-#110 list/copy/sheet readability for allowlisted runtime-route keys | This Assignment → [AUTH](../authorizations/AUTH-KOS-SUG-OBS-GLANCE-001.md) → [PD](../product-decisions/KOS-SUG-OBS-GLANCE-001-authorization.md) |
| One on-device glance | Authorized | Main App 设置 → 诊断 → 查看记录; look at existing `runtime_route.phase_changed` lines only | Human: “批准真机glance” |
| Install / rebuild | Authorized | One signed Debug install of `origin/main` `36b63c7` onto iPhone 13 Pro `00008110-000A08440198801E` | Human: “批准先装Debug” |
| Human-operated uninstall observation | Authorized | Completed: Human uninstall + yes on seven keys and tap sheet | Human: “然后我会尝试卸载一个方案，到时候给你反馈” |
| SUG-08 raw-file read | Not authorized | Read a named JSONL file | New Assignment + Human authorization |
| Push / PR of this glance packet | Authorized | Branch `docs/rtrd-01-glance` | Human: “批准 push 这份 glance 包并 Close” |
| Merge of #112 | Authorized | Consumed: PR [#112](https://github.com/shchnk1103/Universe-Keyboard/pull/112) merged `7caec79` | Human: “批准合并 #112” |

## Boundary

### Objective

Confirm on one Human round whether the privacy-safe diagnostics **list/copy line
and tap sheet** show the finite runtime-route keys shipped in PR #110. Do not
uninstall, do not type into a host, and do not open a raw diagnostics directory.

### Scope

1. Adopt [SUG-07 preflight](../kos/universe-keyboard-human-operated-evidence-profile.md#observability-preflight-kos-sug-07-opt-in).
2. Fill the table from `origin/main` `36b63c7` (contains #110 `8a3f05c`).
3. One operator glance on iPhone 13 Pro `00008110-000A08440198801E`.
4. Record binary present/absent for allowlisted keys. Do not copy user content.

### Non-goals

- Uninstall, candidate observation, or new `ni` input.
- Generating a new route event if no `runtime_route.phase_changed` line exists.
- SUG-08, journal schema change, Swift, Product Gate, TestFlight, Release.
- Closing [DEVICE-001](scheme-delivery-runtime-route-device-001.md).
- Completing `RTRD-02` elapsed comparison.

### Required Inputs

- [SUG-07 profile](../kos/universe-keyboard-human-operated-evidence-profile.md)
- Closed [RTRD-01 UI Assignment](scheme-delivery-runtime-route-diagnostics-ui-001.md)
- `Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift` on `36b63c7`
- iPhone 13 Pro `00008110-000A08440198801E` (paired)

## Assignment

- **Domain Owner:** Main App UI (diagnostics surface)
- **Executor:** Current Grok session — preflight, operator instructions, evidence record
- **Environment Executor:** Current session — one signed Debug build+install of `origin/main` onto the named iPhone. No uninstall command.
- **Human Dependency:** Keep the iPhone unlocked during install; after install, uninstall one scheme in the Main App UI; reopen 设置 → 诊断 → 查看记录 and report keys. No Files/App Group.
- **Architecture Reviewer:** independent runtime, lane `KOS-SUG-OBS-GLANCE-001/document-architecture` after evidence
- **Quality Reviewer:** independent runtime, lane `KOS-SUG-OBS-GLANCE-001/document-quality` after evidence
- **Handoff Target:** Human Product Owner

## Gates

### Entry Criteria

- [x] Product Decision and Authorization resolve to one glance, no uninstall.
- [x] SUG-07 preflight has no `not-checked` row.
- [x] No `UNKNOWN` responsibility.
- [x] Named device is paired/available.

### Exit Criteria

- [x] Operator reported whether 查看记录 opened.
- [x] For each allowlisted key, a yes/no (or “no matching line”) is recorded.
- [x] Missing line on the pre-install app did **not** trigger Executor uninstall or SUG-08. Human later authorized one uninstall; keys were then reported present.

### Stop Conditions

- Any request to uninstall, type into a host, or open a raw diagnostics directory.
- Treating event-code presence as UUID/phase/elapsed proof without the keys.
- Treating this glance as Product Gate, Device-attested CS09-10-02 refresh, or `RTRD-02` close.

## Handoff

- **Required Handoff Content:** preflight table; operator yes/no; explicit non-claims.
- **Revalidation Trigger:** diagnostics formatter/UI change; new install; additional uninstall round.

## Evidence

- [SUG-07 preflight](../evidence/kos-sug-obs-glance-001-preflight-2026-09-10.md)
- [2026-09-11 device glance](../evidence/kos-sug-obs-glance-001-device-2026-09-11.md)

## History

- `2026-09-10 Asia/Shanghai` — Human: “批准真机glance”.
- `2026-09-10 Asia/Shanghai` — Glance found no `runtime_route.phase_changed` line on the previously installed app.
- `2026-09-10 Asia/Shanghai` — Human: “批准先装Debug，然后我会尝试卸载一个方案，到时候给你反馈”.
- `2026-09-11 Asia/Shanghai` — Human: all seven keys `是`; tap sheet `是`. Evidence: [`kos-sug-obs-glance-001-device-2026-09-11.md`](../evidence/kos-sug-obs-glance-001-device-2026-09-11.md).
- `2026-09-11 Asia/Shanghai` — Human: “批准 push 这份 glance 包并 Close，以及开始 RTRD-02”. This Assignment Closes.
