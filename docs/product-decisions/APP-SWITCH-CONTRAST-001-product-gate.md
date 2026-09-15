# Product Decision: APP-SWITCH-CONTRAST-001 — Human Product Gate

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-APP-SWITCH-CONTRAST-001-PRODUCT-GATE",
  "record_type": "decision",
  "title": "Accept APP-SWITCH-CONTRAST-001 main-App switch contrast",
  "status": "accepted",
  "updated_at": "2026-09-15T20:27:33+08:00",
  "revalidation_triggers": ["scope_changed", "contrast_contract_changed", "new_main_app_switch_surface"],
  "parent_refs": ["APP-SWITCH-CONTRAST-001", "PD-APP-SWITCH-CONTRAST-001"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "In-session 2026-09-15 Asia/Shanghai explicit Product Gate authorization",
    "scope": "Human Product Gate for the APP-SWITCH-CONTRAST-001 main-App switch contrast contract. Accept the existing Quality residuals and the bounded Human-attested observation. Close the Assignment.",
    "outcome": "Human Product Gate passed with accepted evidence conditions; Assignment Closed; publication and release actions remain unauthorized",
    "expires_at": null
  }
}
```

- **Decision ID:** `PD-APP-SWITCH-CONTRAST-001-PRODUCT-GATE`
- **Lifecycle status:** `Accepted`
- **Date / timezone:** `2026-09-15 Asia/Shanghai`
- **Assignment:** [`APP-SWITCH-CONTRAST-001`](../assignments/app-switch-contrast-001.md) — **Closed**
- **Authorization:** [`AUTH-APP-SWITCH-CONTRAST-001-PRODUCT-GATE`](../authorizations/AUTH-APP-SWITCH-CONTRAST-001-PRODUCT-GATE.md)
- **Contract source:** [`PD-APP-SWITCH-CONTRAST-001`](APP-SWITCH-CONTRAST-001-authorization.md)
- **Quality:** [`app-switch-contrast-001-quality-review.md`](../reviews/app-switch-contrast-001-quality-review.md) — Pass with conditions; new-SHA incremental check recorded
- **Human observation:** [`app-switch-contrast-001-human-attested-observation-2026-09-15.md`](../evidence/app-switch-contrast-001-human-attested-observation-2026-09-15.md)

## Current Status

| Field | Value |
|---|---|
| Status | accepted |
| Phase | Human Product Gate **Passed with accepted evidence conditions**；Assignment `Closed` |
| Evidence | Implementation `5d3880b`; Simulator App + Keyboard `UniverseKeyboardTests 361 / 9 skipped`, `KeyboardTests 11`; iPhone 13 Pro / iOS 27 Human-attested four-state observation |
| Non-claims | Not Device-attested; not a Quality-reverified physical-device result; not push / PR / merge / TestFlight / App Store Connect / Release |
| Next | None for this Assignment; any publication or release gate requires separate authorization |

## Decision

Human Product Owner accepted the main-App switch contrast Product Gate for the
locked contract:

- 浅色开启：黑槽 + 白点
- 深色开启：白槽 + 黑点
- 浅色关闭：浅槽 + 白点
- 深色关闭：深槽 + 白点

The accepted evidence is bounded to:

1. Shared `AppSwitch` / system `UISwitch` implementation at `5d3880b`.
2. New-SHA incremental Quality check: strict Swift lint passed; App + Keyboard
   Debug test passed with `UniverseKeyboardTests` 361 executed, 9 skipped,
   `KeyboardTests` 11 executed, and 0 failures.
3. Human Product Owner observation on iPhone 13 Pro / iOS 27 covering Settings
   home, Diagnostics, and the fuzzy-pinyin Form in light/dark × on/off states;
   all four states were reported readable.

## Accepted residuals and boundaries

| Residual | Gate disposition |
|---|---|
| `ASC-01` — no Device-attested UUID/SHA-256/dSYM/frozen manifest | `accept` — Human-attested observation is sufficient for this bounded Product Gate; no Device-attested claim is made |
| `ASC-02` — dirty-tree separation / frozen implementation identity | `accept` — implementation `5d3880b` and the docs-only provenance chain are recorded; no push or merge is authorized |
| `ASC-03` — chrome unit tests do not cover the full `UIViewRepresentable` path | `accept` — existing Quality disposition remains accepted |
| `ASC-04` — off-track color remains system `UISwitch` delegated | `accept` — consistent with the locked system-chrome contract |
| `ASC-05` — `colorScheme` / `traitCollection` source split | `accept` — existing Quality disposition remains accepted |

This Gate closes only the **main-App switch contrast product acceptance**. It does
not close or authorize any CI, ReleaseEvidence, ADR 0035, publication, TestFlight,
App Store or general Release work.
