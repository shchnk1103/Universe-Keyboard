# Authorization: AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001

| Field | Value |
|---|---|
| Status | `live / consumed` — Human set live `2026-09-22T18:40:00+08:00`; execution started |
| Target Assignment | [`TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001`](../assignments/typo-correction-002-qa001-revalidation-08-fresh-package-001.md) |
| Issuer | Human Product Owner / Product Lead, `2026-09-22 Asia/Shanghai` |
| Consumer (when live) | Grok (iOS开发大师) |
| Install source tip | `e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00` |
| CI binding **A** | Push run [`35715351145`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/35715351145) · headSha `e1b28ae…` · conclusion `success` (includes `final-quality-gate`) |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001",
  "record_type": "authorization",
  "title": "Fresh-package QA-001 candidate observation on merge tip e1b28ae (binding A)",
  "status": "active",
  "updated_at": "2026-09-22T18:40:00+08:00",
  "revalidation_triggers": [
    "install_source_tip_changed",
    "hosted_CI_binding_A_invalidated",
    "simulator_or_host_identity_changed",
    "same_package_reuse_attempted",
    "executor_identity_changed",
    "authority_revoked"
  ],
  "authorization": {
    "action": "observe_qa001_target_candidate_on_fresh_package",
    "target": "TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001",
    "scope": "Only after Human marks this Authorization live: build and freshly install from e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00 onto Simulator UDID 06C5BC3E-7599-4761-A1A2-71DAEA991474 (iPhone 17 Pro Max / iOS 27); mint a new Run ID TC2-SIM-*-QA001-REVAL-08; record new package hash and RIME provenance; in Messages host +1 (888) 555-1212 enter wimenjintianquhongyuan via the real keyboard; obtain Human eye observation for 「我们今天去公园」; write Executor evidence. Absent target => inconclusive, not a general product-failure claim.",
    "allowed_paths": [
      "read-only checkout at e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00",
      "Simulator install/capture artifacts outside git as needed for the Run",
      "docs/evidence/typo-correction-002-sim-run-*-qa001-reval-08*.md",
      "docs/assignments/typo-correction-002-qa001-revalidation-08-fresh-package-001.md",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-08-FRESH-PACKAGE-001.md",
      "docs/ACTIVE_WORK.md"
    ],
    "required_evidence": [
      "install tip e1b28ae… and CI binding A (run 35715351145 success) recorded",
      "new Run ID and new package hash/provenance",
      "Simulator UDID and Messages host binding",
      "Human attestation of target candidate visibility/selectability or inconclusive",
      "explicit non-claims"
    ],
    "exclusions": [
      "reuse_reval07_package_3f9f2652_or_run_TC2-SIM-20260920-224421-QA001-REVAL-07",
      "FakeCandidateProvider",
      "old_Ice_directory_as_real_RIME",
      "typeText_clipboard_or_host_injection",
      "INT-003",
      "paired_performance_or_180_ms_claim",
      "Swift_test_vendor_schema_or_project_edit",
      "commit_or_push",
      "PR_open_or_modify",
      "merge",
      "TestFlight_or_Release",
      "Product_Quality_or_Release_Gate",
      "parent_or_assignment_close",
      "Architecture_or_Quality_review_without_new_AUTH",
      "bind_CI_run_35706026531_as_same_head_as_e1b28ae"
    ],
    "issuer_role": "Human Product Owner / Product Lead",
    "decision_source": "current task instruction: 那就选A吧，并允许你把草稿写入仓库docs",
    "issued_at": "2026-09-22T18:35:00+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-22T18:40:00+08:00",
    "consumed_by": "Grok (iOS开发大师)",
    "consumption_record": "Human Product Owner instruction: AUTH live；execution evidence under docs/evidence/typo-correction-002-sim-run-*-qa001-reval-08*",
    "live_state": "live"
  }
}
```

## Binding A (explicit)

| Item | Value |
|---|---|
| Install / observation source tip | `e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00` |
| Hosted CI | [`35715351145`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/35715351145) |
| CI headSha | `e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00` (same head) |
| CI conclusion at draft time | `success` (classify-change, lightweight-checks, format-swift, test-keyboardcore, test-rimebridge, test-app-keyboard, build-release, final-quality-gate) |
| Not bound | Run `35706026531` / tip `589deab4…` (pre-squash PR tip only) |

## Live gate

Human Product Owner set this Authorization **live** at `2026-09-22T18:40:00+08:00` via 「AUTH live」. Executor may now perform the bounded fresh-package observation scope only.
