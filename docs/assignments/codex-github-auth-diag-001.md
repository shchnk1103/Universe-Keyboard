# Assignment: CODEX-GITHUB-AUTH-DIAG-001 — GitHub CLI 双环境诊断手册

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "CODEX-GITHUB-AUTH-DIAG-001",
  "record_type": "assignment",
  "title": "Document Codex GitHub CLI sandbox false-negative diagnosis",
  "lifecycle": "completed",
  "current_phase": "Privacy-safe dual-environment runbook and evidence recorded; awaiting Human Product Review",
  "authorization_action": "document_codex_github_auth_diagnosis",
  "updated_at": "2026-08-28T18:45:00+08:00",
  "revalidation_triggers": ["diagnostic_behavior_changed", "codex_sandbox_changed", "github_cli_changed"],
  "authorization_refs": ["AUTH-CODEX-GITHUB-AUTH-DIAG-001"],
  "parent_refs": ["KOS-2-2-DOC-ALIGN-001"],
  "responsibilities": {
    "domain_owner": "Architecture and Knowledge Steward",
    "executor": "Current Codex session",
    "environment_executor": "Current Codex session in restricted sandbox and user-authorized host environments",
    "human_dependency": "Human Product Owner for authentication, proxy, account or publication authority beyond this docs-only scope",
    "architecture_reviewer": "Architecture and Knowledge Steward conformance review within this docs-only assignment",
    "quality_reviewer": "Not Applicable - documentation and observed environment classification only",
    "product_approver": "Human Product Owner"
  }
}
```

**Policy version:** `1.0.0`

**Repository Change Type:** `Documentation` + `Procedure`

## Current Status

| Field | Value |
|---|---|
| Lifecycle | completed |
| Current Phase | Privacy-safe dual-environment runbook and evidence recorded; awaiting Human Product Review |
| Material non-claims | No token expiry claim from sandbox alone; no secret capture; no proxy/account mutation; no merge/Release authority |
| Next handoff / decision | Human Product Owner reviews the runbook; future agents follow it before asking for reauthentication |
| Residuals | Sandbox internal mechanism may be keyring visibility, network restriction, or both; no further invasive distinction is required for the safe decision path |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-CODEX-GITHUB-AUTH-DIAG-001`](../product-decisions/CODEX-GITHUB-AUTH-DIAG-001-authorization.md), `2026-08-28 Asia/Shanghai`
- **Product Approver:** Human Product Owner

## Boundary

- **Scope:** Record the observed sandbox/host mismatch, publish a deterministic decision tree, add navigation, validate and update the existing Draft PR.
- **Non-goals:** Secret collection; proxy/account mutation; definitive attribution between sandbox keyring and network internals; product code; CI workflow; merge or Release.
- **Required Inputs:** [`runbook`](../kos/codex-github-cli-auth-troubleshooting.md), sandbox evidence, host-authorized evidence, existing KOS 2.2 advisory Profile.

## Assignment

- **Domain Owner:** Architecture & Knowledge Steward
- **Executor:** Current Codex session
- **Environment Executor:** Current Codex session in restricted sandbox and authorized host contexts
- **Human Dependency:** Human Product Owner only for actions outside the docs-only scope
- **Architecture Reviewer:** Architecture & Knowledge Steward conformance review; not independent
- **Quality Reviewer:** Not Applicable — no product Quality claim

## Gates

- **Entry Criteria:** Human authorized documentation; both observations are available; no secret needs to be read.
- **Exit Criteria:** Runbook distinguishes three failure classes, contains a retry budget and privacy stops, is discoverable, and KOS/link/format checks pass.
- **Stop Conditions:** A step would expose secret material, mutate proxy/account state without authorization, or infer token expiry from sandbox-only output.

## Handoff

- **Handoff Target:** Human Product Owner
- **Required Handoff Content:** confirmed facts, bounded inference, runbook path, validation, PR update and remaining unknown.
- **Revalidation Trigger:** Codex sandbox/keyring behavior, GitHub CLI semantics, authentication provider or network architecture changes.

## History

- `2026-08-28 Asia/Shanghai`: Sandbox `gh auth status` reported invalid immediately after Human browser login; the same command in the user-authorized host environment confirmed keyring authentication, and push/PR operations succeeded. Human requested a KOS 2.2 record to prevent repeated trial and error.
- `2026-08-28 Asia/Shanghai`: Dual-environment evidence and runbook recorded. Assignment `Completed`; waiting Human Product Review.
