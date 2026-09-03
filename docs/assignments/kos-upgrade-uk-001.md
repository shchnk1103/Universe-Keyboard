# Assignment: KOS-UPGRADE-UK-001 — Adopt KOS 2.2 advisory

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "KOS-UPGRADE-UK-001",
  "record_type": "assignment",
  "title": "Adopt KOS Agent Kit v0.5.0 in advisory mode",
  "lifecycle": "reviewed",
  "current_phase": "Product Gate accepted; PR #84 merged as e7da77e; advisory adoption operational; TD-014 remains",
  "authorization_action": "adopt_kos_2_2_advisory",
  "updated_at": "2026-08-28T00:05:00+08:00",
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
| Lifecycle | reviewed |
| Current Phase | Product Gate accepted; PR #84 merged as e7da77e; advisory adoption operational; TD-014 remains |
| Material non-claims | Not required mode; not diagnostics implementation; not PR #83 merge |
| Next handoff / decision | Continue `v0.5.0` advisory; `v0.6.0` is Deferred via [`KOS-UPGRADE-UK-002`](kos-upgrade-uk-002.md) / PR #92 `cb49e62`; TD-014 remains |
| Residuals | [`residual table`](#residual-disposition) |

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

- Handoff Target: Human Product Owner after merge of PR #84; Envelope hygiene owner is Architecture & Knowledge Steward via TD-014.
- Required Handoff Content: kit tag, Profile, include glob, validator command and advisory output, first workflow record IDs, residual table.
- Revalidation Trigger: new Kit Release, mode change to `required`, include-glob expansion, or TD-014 close.

## Residual Disposition

| ID | Owner | Disposition | Pointer |
|---|---|---|---|
| A-P2-01 | Architecture & Knowledge Steward | `tech_debt:TD-014` | [`TD-014`](../TECH_DEBT.md#td-014-kos-22-auth-consumption_state-卫生) · AUTH `consumption_state` still `unconsumed` after bounded actions landed |
| A-P2-02 | Main App UI | `accept` | Open Gate may bind entry screenshots; closing it needs implementation evidence and an independent closure Decision |
| A-P2-03 | Architecture & Knowledge Steward | `accept` | `parent_refs` to the upgrade Assignment is lineage only, not implement authorization |
| A-P3-01 | Program Manager | `accept` | Dashboard 2026-08-24 `3/10` snapshot vs current Active Work; Dashboard is not SoT |
| A-P3-02 / Q-P3-01 | Environment Executor | `accept` | Validator evidence binds Kit commit + Profile, not UK `f580613`; Quality re-ran at that checkout |
| A-P3-03 | Architecture & Knowledge Steward | `accept` | Advisory Gate `evidence_reviewer` is the executor session; independence lives in the review files |
| Q-P3-02 | Architecture & Knowledge Steward | `accept` | Architecture/Quality review files are not in the include glob |

## History

- `2026-08-27 Asia/Shanghai`: Human Product Owner instructed completing Universe Keyboard 2.2 connection after Kit `v0.5.0`. Lifecycle `active` for advisory pin only.
- `2026-08-27 Asia/Shanghai`: Independent Architecture **Pass with conditions** (P0=0/P1=0) and Quality **Pass with conditions** (P0=0/P1=0) of `f580613`.
- `2026-08-27 Asia/Shanghai`: Human Product Owner accepted the advisory pin and authorized merge of PR #84, requiring P2 to be recorded first. A-P2-01 is `tech_debt:TD-014`; remaining P2/P3 are `accept`. Lifecycle `reviewed`. Merge does not enable `required` or diagnostics implementation.
- `2026-08-27 Asia/Shanghai`: PR #84 merged as `e7da77e`; advisory adoption became operational. Lifecycle remains `reviewed` because this record does not infer a separate formal Close decision. TD-014 remains; merge did not enable `required` or authorize product work.
