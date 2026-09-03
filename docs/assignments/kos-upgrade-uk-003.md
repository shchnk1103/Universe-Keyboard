# Assignment: KOS-UPGRADE-UK-003 — Adopt KOS Agent Kit v0.6.0 (advisory)

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "KOS-UPGRADE-UK-003",
  "record_type": "assignment",
  "title": "Adopt KOS Agent Kit v0.6.0 in advisory mode",
  "lifecycle": "active",
  "current_phase": "Human authorized Adopt v0.6.0 advisory pin; required remains unauthorized",
  "authorization_action": "adopt_kos_kit_v0.6.0",
  "updated_at": "2026-09-03T20:30:00+08:00",
  "revalidation_triggers": ["kit_release_changed", "mode_changed", "scope_changed"],
  "authorization_refs": ["AUTH-KOS-UPGRADE-UK-003"],
  "responsibilities": {
    "domain_owner": "Architecture and Knowledge Steward",
    "executor": "Current Grok session",
    "environment_executor": "Current Grok session",
    "human_dependency": "Human Product Owner for required-mode",
    "architecture_reviewer": "Independent Architecture note in this packet",
    "quality_reviewer": "Independent Quality note in this packet",
    "product_approver": "Human Product Owner"
  }
}
```

**Policy version:** `1.0.0`
**Parent:** [`KOS-UPGRADE-UK-001`](kos-upgrade-uk-001.md)
**Supersedes (Adopted pin only):** [`KOS-UPGRADE-UK-002`](kos-upgrade-uk-002.md) Deferred disposition for kit `v0.6.0`

## Current Status

| Field | Value |
|---|---|
| Lifecycle | active |
| Current Phase | Human authorized Adopt v0.6.0 advisory pin; required remains unauthorized |
| Material non-claims | Not required mode; not bulk Envelope migration; not Active Assignment migration; not orchestration plan instantiation; not TestFlight / Release |
| Next handoff / decision | Merge the pin PR, run M-02, close this Assignment |
| Residuals | [`TD-014`](../TECH_DEBT.md#td-014-kos-22-auth-consumption_state-卫生) · [`upgrade record`](../kos/upgrade-records/KOS-UPGRADE-UK-003-v0.6.0.md) |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner in-session `2026-09-03 Asia/Shanghai` instruction “Adopt v0.6.0”
- **Product Approver:** Human Product Owner
- **Accepted Product Decision:** [`PD-KOS-UPGRADE-UK-003`](../product-decisions/KOS-UPGRADE-UK-003-authorization.md)

## Boundary

- **Scope:** pin Adopted kit to `v0.6.0` (`a16c932`) while keeping `record_envelopes.mode: advisory`; update SoT, Profile extension, and progressive onboarding of this Assignment; run read-only validator against the pinned tag.
- **Non-goals:** `required` mode; bulk Envelope migration; rewriting KOS 2.0; adding `ORCHESTRATION_PLAN.md` or starting a multi-agent workflow; migrating Active Assignments; TestFlight / Release; product Swift.
- **Required Inputs:** Kit Release [`v0.6.0`](https://github.com/shchnk1103/kos-agent-kit/releases/tag/v0.6.0); [`KOS-UPGRADE-UK-002`](kos-upgrade-uk-002.md) Deferred check; this Product Decision.

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** Current Grok session
- **Environment Executor:** Current Grok session — local read-only validator at `/tmp/kos-agent-kit-v0.6.0`
- **Human Dependency:** Human Product Owner for any later `required` cutover
- **Architecture Reviewer / Quality Reviewer:** independent notes in this packet
- **Product Approver:** Human Product Owner

## Entry / Exit / Stop

- **Entry:** Kit `v0.6.0` published; Human authorized Adopt (not `required`); UK-002 already recorded the check.
- **Exit:** `UPGRADE_STATUS.md` Adopted = `v0.6.0` advisory; Profile pin matches `a16c932`; advisory validator run recorded; Human Product Gate recorded; Assignment Closed after merge.
- **Stop:** enabling `required`; rewriting frozen 2.0; treating validator green as merge/Release; retrofitting Active Assignments onto the orchestration contract.

## History

- `2026-09-02` — UK-002 Deferred the *check* of `v0.6.0` (no current orchestration workflow).
- `2026-09-03 Asia/Shanghai` — Human Product Owner authorized Adopt `v0.6.0` as the advisory pin. Orchestration remains unused until a future Assignment needs it.
