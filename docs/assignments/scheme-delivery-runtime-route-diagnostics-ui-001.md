# Assignment: SCHEME-DELIVERY-RUNTIME-ROUTE-DIAGNOSTICS-UI-001 — RTRD-01

Policy version: `1.0.0`

## Current Status

| Field | Value |
|---|---|
| Lifecycle | `Closed` |
| Current phase | Published: PR [#110](https://github.com/shchnk1103/Universe-Keyboard/pull/110) merged `4e4164f`; engineering head `8a3f05c`; hosted CI same-head green; remote feature branch deleted |
| Non-claims | No uninstall device round; no SUG-08; no journal schema change; no Product Gate / TestFlight / Release; merge does not obtain `RTRD-02` elapsed comparison |
| Next handoff / decision | None for this slice |
| Residuals | `RTRD-02` same-field gap is `accept` on [DEVICE-001](scheme-delivery-runtime-route-device-001.md) |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner, `2026-09-10 Asia/Shanghai`, after SUG-07 preflight: “之后开始RTRD-01”
- **Product Approver:** Human Product Owner

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | Implementation slice; device claims stay on later evidence. |
| A-01 / B-01 authorization chain and briefing | Adopted | This Assignment was the RTRD-01 UI slice; it is now Closed. |
| P-01 publication facts | Adopted | PR [#110](https://github.com/shchnk1103/Universe-Keyboard/pull/110) merged `4e4164f`; head `8a3f05c` |
| D-01 final-documentation receipt | Not applicable | Hosted lightweight/full CI on #110 is not this M-02 packet's D-01 receipt |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current RTRD-01 UI | Authorized | Completed: finite `runtimeRoutePayload` keys in list/copy and a bottom sheet on `main` | This Assignment; DEVICE-001 residual `RTRD-01` |
| Push / PR / merge of #110 | Authorized | Consumed: PR [#110](https://github.com/shchnk1103/Universe-Keyboard/pull/110) merged `4e4164f` | Human: push + PR; CI green may merge; then this post-merge M-02 |
| SUG-07 uninstall round | Not authorized | Human Device Operator uninstall | New authorization |
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
- **Exit:** List/copy expose the finite keys; tap sheet shows the same allowlist; tests cover no user-content leakage. Met on engineering head `8a3f05c` / merge `4e4164f`.
- **Stop:** Any request to log input/candidates, read App Group files, or change route policy.

## History

- `2026-09-10 Asia/Shanghai` — Human: push SUG-07 device docs then “之后开始RTRD-01”.
- `2026-09-10 Asia/Shanghai` — Human: “批准 push `codex/rtrd-01-diagnostics-ui` 并开 PR，CI 全绿后可允许合并，然后做 M-02”. PR #110 merged `4e4164f`. This M-02 Closes the Assignment.
