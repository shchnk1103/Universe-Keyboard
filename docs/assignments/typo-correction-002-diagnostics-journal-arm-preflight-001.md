# Assignment: TYPO-CORRECTION-002-DIAGNOSTICS-JOURNAL-ARM-PREFLIGHT-001 — Diagnostics Journal arm/preflight + one-key smoke

Policy version: 1.0.0

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "TYPO-CORRECTION-002-DIAGNOSTICS-JOURNAL-ARM-PREFLIGHT-001",
  "record_type": "assignment",
  "title": "Diagnostics Journal arm/preflight and optional one-key smoke",
  "lifecycle": "active",
  "current_phase": "Execution complete for this Run — prefs armed; Human one-key attested; Diagnostics JSONL absent; stopped without writer changes",
  "authorization_action": "arm_diagnostics_journal_and_optional_one_key_smoke",
  "updated_at": "2026-09-22T22:17:41+08:00",
  "revalidation_triggers": [
    "source_or_package_identity_changed",
    "simulator_host_schema_or_provenance_changed",
    "diagnostics_arm_method_changed",
    "build_install_restart_or_run_restarted",
    "scope_or_authority_changed",
    "executor_changed"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-DIAGNOSTICS-JOURNAL-ARM-PREFLIGHT-001"
  ],
  "parent_refs": [
    "TYPO-CORRECTION-002"
  ],
  "responsibilities": {
    "domain_owner": "Input Intelligence Maintainer",
    "executor": "Grok Bot iOS开发大师",
    "environment_executor": "Grok Bot — clean tip worktree prefs arm, Simulator Diagnostics search, optional one-key",
    "human_dependency": "Human Product Owner — set Authorization live; assist Keyboard Extension appear and one visible-key tap when automation cannot",
    "architecture_reviewer": "Independent Architecture & Knowledge Steward",
    "quality_reviewer": "Independent Quality, Performance & Release Maintainer",
    "product_approver": "Human Product Owner / Product Lead"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | Active |
| **Phase** | Execution complete — armed prefs + Human one-key; independent Diagnostics JSONL absent |
| **Next** | Preserve this bounded evidence. Follow-on writer-path Assignment/AUTH required before any journal-writer investigation or code change. |
| **Non-claims** | No INT-003 pass/fail, no 180 ms claim, no candidate selection, no QA-001 claim, no Product/Quality/Release Gate, no parent Close, no commit/push/PR/merge, no RimeRuntimeProvenance restoration. |

## Authority and inputs

- **Parent Assignment:** [TYPO-CORRECTION-002](typo-correction-002.md) — remains **Active**.
- **Matching Authorization:** [AUTH-TYPO-CORRECTION-002-DIAGNOSTICS-JOURNAL-ARM-PREFLIGHT-001](../authorizations/AUTH-TYPO-CORRECTION-002-DIAGNOSTICS-JOURNAL-ARM-PREFLIGHT-001.md).
- **Prior context:** INT-003 controlled capture Run `TC2-SIM-20260922-202125-INT003-CONTROLLED-001` was **Inconclusive** (UI one-key OK; no independent Keyboard Extension Diagnostics JSONL). That Capture/Architecture/Quality AUTH set is **consumed** and must not be reused.
- **Baseline:** tip `e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00`; docs merge SHA `e943bbf894dd379e7b193650899d4e3e93cf80a9` is historical context only.

## Designated environment

| Item | Value |
|---|---|
| **Simulator** | iPhone 17 Pro Max / iOS 27 |
| **UDID** | 06C5BC3E-7599-4761-A1A2-71DAEA991474 |
| **Worktree** | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-int003-controlled-capture-001/Universe Keyboard` @ `e1b28ae…` |
| **Run ID** | TC2-SIM-20260922-221630-DIAG-JOURNAL-ARM-001 |

## Scope

After the matching Authorization is live:

1. Confirm/enable `logging_enabled` via Main App diagnostics settings keys (App Group suite).
2. Confirm display category enabled (`log_category_disp`; absent defaults to enabled).
3. Enable first-screen high-fidelity diagnostics (`diagnostics_high_fidelity_expiration`) and re-enter Keyboard Extension so `viewWillAppear` refreshes config.
4. Record content-free config: switches, expiry, generation, writer-visible state.
5. Search **dynamic** JSONL names `keyboard_extension-<processInstanceID>-<hour>-<part>.jsonl` under Diagnostics (`gN/open`, `gN/sealed`, etc.); do not rely only on fixed `keyboard_extension.jsonl`.
6. If JSONL exists: record path, origin, processInstanceID, generation, SHA-256.
7. Optional: exactly one UI-layer visible key tap — no real phrase, typeText, clipboard, host injection, or candidate select.
8. If armed but still no JSONL: **stop**; write diagnostic evidence; **do not** change writer code under this AUTH.

## Non-goals and stop conditions

- No production Swift/ObjC/RIME changes; no restore of `RimeRuntimeProvenance.swift`.
- No reuse of consumed INT-003 Capture/Architecture/Quality AUTHs.
- No claims of INT-003, 180 ms, candidate select, QA-001, Release, or parent Close.
- Do not modify dirty home main or overwrite reval-08-docs uncommitted INT-003 package.
- No commit/push/merge/Close/Gates under this Assignment.
