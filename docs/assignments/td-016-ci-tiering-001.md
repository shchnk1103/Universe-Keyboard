# Assignment: TD-016-CI-TIERING-001 — CI 变更分级与文档快速门禁

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TD-016-CI-TIERING-001",
  "record_type": "assignment",
  "title": "Fail-closed CI change classification and stable final gate",
  "lifecycle": "active",
  "current_phase": "Implementation and hosted full-path validation complete; awaiting docs-only fixture and independent reviews",
  "authorization_action": "implement_ci_tiering",
  "updated_at": "2026-08-28T19:15:00+08:00",
  "revalidation_triggers": ["scope_changed", "workflow_contract_changed", "required_checks_changed", "kos_kit_distribution_changed"],
  "authorization_refs": ["AUTH-TD-016-CI-TIERING-001"],
  "parent_refs": ["KOS-2-2-DOC-ALIGN-001"],
  "responsibilities": {
    "domain_owner": "Quality, Performance and Release Maintainer",
    "executor": "Current Codex session",
    "environment_executor": "Current Codex session locally and GitHub Actions hosted runner after publication",
    "human_dependency": "Human Product Owner for PR review, merge and any future branch-protection or required-check migration",
    "architecture_reviewer": "Independent Architecture and Knowledge Steward reviewer after implementation",
    "quality_reviewer": "Independent Quality, Performance and Release reviewer after implementation",
    "product_approver": "Human Product Owner"
  }
}
```

**Policy version:** `1.0.0`

**Repository Change Type:** `Implementation` + `Procedure` + `Documentation`

## Current Status

| Field | Value |
|---|---|
| Lifecycle | active |
| Current Phase | Implementation and hosted full-path validation complete; awaiting docs-only fixture and independent reviews |
| Material non-claims | No weakened full gate; no branch-protection/required-check mutation; no secret; no KOS required; no merge; no automatic inclusion in PR #86 |
| Next handoff / decision | Independent Architecture and Quality review, then Human decides stacked PR disposition and merge |
| Residuals | Private KOS Kit distribution prevents reliable remote full validator without a new distribution/credential decision; local pinned validator remains required for KOS-governance changes |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-TD-016-CI-TIERING-001`](../product-decisions/TD-016-CI-TIERING-001-authorization.md), `2026-08-28 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead

## Boundary

- **Scope:** classify PR/push diffs, run always-on lightweight checks, conditionally run the unchanged heavy Swift 6 suite, aggregate a stable final result, cancel stale runs, add tests and update owning documentation.
- **Non-goals:** change product code, test semantics, RIME artifacts, Xcode project, GitHub protection settings, KOS mode, account credentials or Release state.
- **Required Inputs:** TD-016, current workflow, AGENTS local CI gate, Release Checklist, Test/Release playbook, KOS 2.2 advisory Profile, current branch-protection observation.

## Assignment

- **Domain Owner:** Quality, Performance & Release Maintainer.
- **Executor:** Current Codex session.
- **Environment Executor:** Current Codex session for deterministic tests; GitHub Actions hosted runner after publication.
- **Human Dependency:** Human Product Owner reviews PR packaging and authorizes any merge or future required-check change.
- **Architecture Reviewer:** Independent Architecture & Knowledge Steward reviewer; reviews classification authority, stable Gate semantics and KOS boundary without editing implementation.
- **Quality Reviewer:** Independent Quality, Performance & Release reviewer; reviews path fixtures, skip/full behavior and workflow results without editing implementation.

## Gates

- **Entry Criteria:** Product Decision accepted; no `UNKNOWN`; current workflow and branch protection audited; isolated branch created from #86 tip.
- **Exit Criteria:**
  - docs/governance-only fixture selects light path;
  - Swift, test, project, package, RIME/Lua/dictionary, asset, script, workflow and unknown fixtures select full path;
  - empty/invalid comparison fails closed;
  - lightweight checks always run and heavy suite remains semantically unchanged when required;
  - final Gate fails unless classification/light checks pass and heavy result matches classification;
  - concurrency cancels stale same-PR runs;
  - local tests, workflow syntax review and first GitHub run are recorded;
  - Architecture and Quality reviews are handed off before Product acceptance.
- **Stop Conditions:** path rule could hide a sensitive/unknown change; existing tests are weakened; required check is made permanently pending; KOS validation requires secret insertion or unreviewed tool vendoring; merge/branch protection is requested without separate authority.

## Handoff

- **Handoff Target:** Independent Architecture reviewer, then independent Quality reviewer, then Human Product Owner.
- **Required Handoff Content:** frozen classification table, classifier tests, workflow job graph, local/remote results, skipped checks, private-Kit residual, PR topology recommendation and rollback.
- **Revalidation Trigger:** allowed path set, workflow/job names, branch protection, required checks, KOS Kit distribution, Xcode target or release-gate contract changes.

## History

- `2026-08-28 Asia/Shanghai`: Human Product Owner authorized TD-016 implementation and requested a later decision about PR #86 packaging. Branch-protection read-only audit returned no protection on `main`; KOS Kit repository visibility is private. Assignment entered `Active` on an isolated stacked branch.
- `2026-08-28 Asia/Shanghai`: Classifier, lightweight checks, conditional heavy job and stable final Gate were implemented. Deterministic script tests, KeyboardCore, RimeBridge and Debug/Release builds passed locally. The Xcode 27 beta/iOS 26 simulator App test host crashed repeatedly with an allocator/IOHID compatibility error; hosted CI remains the decisive full-path environment.
- `2026-08-28 Asia/Shanghai`: GitHub Actions run [`33165797218`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33165797218) passed `classify-change`, `lightweight-checks`, the complete `build-and-test` suite and `final-quality-gate`. The hosted App/Keyboard suite passed, resolving the local beta-simulator uncertainty for this commit. Docs-only hosted fixture and independent reviews remain pending.
