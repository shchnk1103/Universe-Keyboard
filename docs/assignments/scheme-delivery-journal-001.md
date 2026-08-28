# Assignment: SCHEME-DELIVERY-JOURNAL-001 — 方案交付日志进入诊断 v1

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "SCHEME-DELIVERY-JOURNAL-001",
  "record_type": "assignment",
  "title": "Write scheme-delivery events into diagnostics v1",
  "lifecycle": "active",
  "current_phase": "Formalizing PR #83 v1 scheme_delivery path after main merge",
  "authorization_action": "implement_scheme_delivery_journal",
  "updated_at": "2026-08-28T21:10:00+08:00",
  "revalidation_triggers": ["diagnostic_protocol_changed", "scheme_delivery_contract_changed"],
  "authorization_refs": ["AUTH-SCHEME-DELIVERY-JOURNAL-001"],
  "parent_refs": ["RIME-SCHEME-DELIVERY-INTEGRITY-001", "DIAGNOSTICS-VIEWER-LOAD-001"],
  "responsibilities": {
    "domain_owner": "Main App UI",
    "executor": "Current Grok session",
    "environment_executor": "Current Grok session for local tests; GitHub Actions after push",
    "human_dependency": "Human Product Owner for v1 journal retest of Wanxiang download",
    "architecture_reviewer": "Independent Architecture and Knowledge Steward reviewer after implementation",
    "quality_reviewer": "Independent Quality, Performance and Release reviewer after implementation",
    "product_approver": "Human Product Owner"
  }
}
```

**Policy version:** `1.0.0`

**Repository Change Type:** `Implementation` + `Documentation`

**Debt:** [`TD-015`](../TECH_DEBT.md#td-015-方案交付日志未进入诊断-v1-journal)

## Current Status

| Field | Value |
|---|---|
| Lifecycle | active |
| Current Phase | Formalizing PR #83 v1 scheme_delivery path after main merge |
| Material non-claims | No merge of #83; no high-fidelity change; no legacy Logger bridge into v1; no integrity weakening |
| Next handoff / decision | Local/hosted tests, then Human retest searching `scheme_delivery` / `wanxiang` |
| Residuals | [`TD-015`](../TECH_DEBT.md#td-015-方案交付日志未进入诊断-v1-journal) |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-SCHEME-DELIVERY-JOURNAL-001`](../product-decisions/SCHEME-DELIVERY-JOURNAL-001-authorization.md), `2026-08-28 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead

## Boundary

- **Scope:** keep download / archive integrity / install / deploy / terminal events as typed ADR 0027 v1 payloads; prove journal persistence and searchable display; update TD-015.
- **Non-goals:** merge #83; Release/TestFlight; high-fidelity probes; bridging `rime_diag_log` into v1; changing checksums or source URLs.
- **Required Inputs:** ADR 0027, ADR 0032, INTEGRITY-001, #85 viewer, TD-015 evidence `2026-08-27`.

## Assignment

- **Domain Owner:** Main App UI — scheme download/install/deploy orchestration.
- **Executor:** Current Grok session.
- **Environment Executor:** Current Grok session for tests; GitHub Actions after publication.
- **Human Dependency:** Human Product Owner retests Wanxiang download on this branch and reports whether v1 shows `scheme_delivery` rows with logging and DEPLOY enabled, high-fidelity off.
- **Architecture Reviewer:** Independent Architecture reviewer after this slice.
- **Quality Reviewer:** Independent Quality reviewer after this slice.

## Gates

- **Entry Criteria:** #83 merged current `main`; ADR numbering collision resolved; Product authorized this sequence.
- **Exit Criteria:** v1 records `scheme_delivery.*` for download, integrity, install, deploy and terminal; display is searchable without paths/URLs; tests recorded; Human retest recorded.
- **Stop Conditions:** journal writes block delivery; free-text/PII enters v1; high-fidelity is changed to unhide events; merge is requested without a new AUTH.

## Handoff

- **Handoff Target:** Human Product Owner for retest, then independent reviewers, then a later merge decision.
- **Revalidation Trigger:** DiagnosticEvent schema, delivery phases, or logging category contract changes.

## History

- `2026-08-28 Asia/Shanghai`: Human authorized rebase → TD-015 journal → Human retest. This Assignment captures the existing #83 v1 payload path instead of inventing a second logger.
