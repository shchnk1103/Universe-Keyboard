# Assignment: KOS-UPGRADE-UK-001 — Adopt KOS 2.2 advisory

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "KOS-UPGRADE-UK-001",
  "record_type": "assignment",
  "title": "Adopt KOS Agent Kit v0.5.0 in advisory mode",
  "lifecycle": "active",
  "current_phase": "Advisory Profile and first enveloped workflow recorded; required mode not authorized",
  "authorization_action": "adopt_kos_2_2_advisory",
  "updated_at": "2026-08-27T19:50:00+08:00",
  "revalidation_triggers": ["kit_release_changed", "mode_changed", "scope_changed"],
  "authorization_refs": ["AUTH-KOS-UPGRADE-UK-001"],
  "responsibilities": {
    "domain_owner": "Architecture and Knowledge Steward",
    "executor": "Current Grok session",
    "environment_executor": "Current Grok session",
    "human_dependency": "Human Product Owner for required-mode and merge decisions",
    "architecture_reviewer": "Independent architecture_review subagent after this pin",
    "quality_reviewer": "Independent quality_review subagent after this pin",
    "product_approver": "Human Product Owner"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Lifecycle | active |
| Current Phase | Advisory Profile and first enveloped workflow recorded; required mode not authorized |
| Material non-claims | Not required mode; not Universe Keyboard product-code change; not PR #83 merge |
| Next handoff / decision | Independent review of this advisory pin; diagnostics implementation remains a separate authorization |
| Residuals | Historical Markdown without envelopes stays outside the include glob |

---

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: [`PD-KOS-UPGRADE-UK-001`](../product-decisions/KOS-UPGRADE-UK-001-authorization.md), `2026-08-27 Asia/Shanghai`
- Product Approver: Human Product Owner

## Boundary

- Scope: pin `kos-agent-kit@v0.5.0`; add `.kos/project.json` in `advisory`; envelope one complete open workflow (`DIAGNOSTICS-VIEWER-LOAD-001`); record upgrade status; run read-only validator.
- Non-goals: `required` mode; bulk Envelope migration; rewriting KOS 2.0; H-01 template replacement of the existing human-device profile; G-01 template fill; product Swift; merge PR #83.
- Required Inputs: Kit Release `v0.5.0`, [`docs/kos-2.2-adoption.md`](https://github.com/shchnk1103/kos-agent-kit/blob/v0.5.0/docs/kos-2.2-adoption.md), this Product Decision.

## Assignment

- Domain Owner: Architecture and Knowledge Steward
- Executor: Current Grok session
- Environment Executor: Current Grok session — local read-only validator
- Human Dependency: Human Product Owner for required-mode and merge decisions
- Architecture Reviewer: Independent architecture_review subagent after this pin
- Quality Reviewer: Independent quality_review subagent after this pin
- Product Approver: Human Product Owner

## Gates

- Entry Criteria: Kit `v0.5.0` published; Human authorized connecting Universe Keyboard to 2.2; no `UNKNOWN` on this Assignment.
- Exit Criteria: Profile exists; UPGRADE_STATUS records Adopted advisory; one Authorization-Assignment-Evidence-Gate-Decision workflow validates in advisory; validator remains read-only.
- Stop Conditions: enabling `required`; covering legacy records without exemptions; changing product conclusions; mixing this work into PR #83.

## Handoff

- Handoff Target: Architecture Reviewer, then Quality Reviewer, then Human Product Owner.
- Required Handoff Content: kit tag, Profile, include glob, validator command and advisory output, first workflow record IDs.
- Revalidation Trigger: new Kit Release, mode change to `required`, or include-glob expansion.

## History

- `2026-08-27 Asia/Shanghai`: Human Product Owner instructed completing Universe Keyboard 2.2 connection after Kit `v0.5.0`. Lifecycle `active` for advisory pin only.
