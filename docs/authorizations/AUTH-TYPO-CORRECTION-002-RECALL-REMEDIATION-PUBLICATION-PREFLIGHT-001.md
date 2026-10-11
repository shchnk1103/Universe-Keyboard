# Authorization: AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001

## Current Status

| Field | Value |
|---|---|
| Status | `consumed` |
| Assignment | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001`](../assignments/typo-correction-002-recall-remediation-publication-preflight-001.md) |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai` |
| Consumer | Current Codex executor |
| Purpose | Run the local CI-equivalent publication preflight for the exact pure KeyboardCore remediation snapshot |

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001",
  "record_type": "authorization",
  "title": "Publication preflight for recall core contract remediation",
  "status": "consumed",
  "updated_at": "2026-09-20T11:21:47+08:00",
  "revalidation_triggers": [
    "snapshot_manifest_changed",
    "source_or_package_identity_changed",
    "scope_changed",
    "new_run_requested",
    "authority_revoked"
  ],
  "authorization": {
    "action": "run_local_ci_equivalent_publication_preflight",
    "target": "TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001",
    "scope": "Run formatting, KeyboardCore, RimeBridgeTests, app and keyboard Debug tests, Release build, diff checks, and write one docs-only preflight evidence record for the frozen pure-Core remediation snapshot.",
    "decision_source": "current task instruction: 按照建议继续进行下一步",
    "snapshot": {
      "worktree": "/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001",
      "branch": "codex/typo-correction-002-recall-preflight-001",
      "head": "d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "head_tree": "27ae44bec1b157e391ef1e0b859db3a068e21ba8",
      "package_manifest": "Packages/KeyboardCore/Package.swift",
      "package_manifest_sha256": "9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764",
      "snapshot_manifest_sha256": "c135c78b435fb2278fc734ed354bbf9e396266cdfffe878aef8a887b22c30ac0",
      "manifest_rule": "sha256 lines for the 21 listed artifacts, sorted by path and joined with newlines, then hashed with SHA-256"
    },
    "artifacts": [
      "Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift",
      "Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift",
      "Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift",
      "docs/assignments/typo-correction-002-recall-remediation-core-contract-001.md",
      "docs/assignments/typo-correction-002-recall-remediation-implementation-preflight-001.md",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-001.md",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-ARCHITECTURE-001.md",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-PRODUCT-DECISION-001.md",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-QUALITY-001.md",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-001.md",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-ARCHITECTURE-001.md",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-PRODUCT-DECISION-001.md",
      "docs/authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-QUALITY-001.md",
      "docs/evidence/typo-correction-002-recall-remediation-core-contract-001.md",
      "docs/evidence/typo-correction-002-recall-remediation-implementation-preflight-001.md",
      "docs/product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-CORE-CONTRACT-BOUNDED-DECISION-2026-09-20.md",
      "docs/product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-BOUNDED-DECISION-2026-09-20.md",
      "docs/reviews/typo-correction-002-recall-remediation-core-contract-architecture-review-2026-09-20.md",
      "docs/reviews/typo-correction-002-recall-remediation-core-contract-quality-review-2026-09-20.md",
      "docs/reviews/typo-correction-002-recall-remediation-implementation-preflight-architecture-review-2026-09-20.md",
      "docs/reviews/typo-correction-002-recall-remediation-implementation-preflight-quality-review-2026-09-20.md"
    ],
    "allowed_external_effects": [
      "read_only_source_and_git_identity_checks",
      "run_local_swift_format_and_tests",
      "run_local_xcodebuild_simulator_tests_and_release_build",
      "write_one_docs_only_publication_preflight_evidence_record"
    ],
    "required_checks": [
      "strict Swift format and lint for the three changed Swift files",
      "swift test --package-path Packages/KeyboardCore",
      "RimeBridgeTests on iPhone 17 Pro iOS 26.0",
      "Universe Keyboard Debug tests on iPhone 17 Pro iOS 26.0",
      "Universe Keyboard Release build on iPhone 17 Pro iOS 26.0",
      "git diff --check and final provenance capture"
    ],
    "exclusions": [
      "Swift_or_test_source_change",
      "runtime_scheduler_or_controller_change",
      "RimeBridge_or_RIME_deployment_or_query",
      "Simulator_or_device_evidence_capture",
      "QA-001",
      "INT-003",
      "paired_performance_or_180_ms",
      "Product_Gate_or_Quality_Gate_or_Release_Gate",
      "commit_or_push",
      "PR_or_merge",
      "parent_or_child_close",
      "TestFlight_or_Release"
    ],
    "consumption_rule": "Bind every result to the frozen snapshot; if source bytes or the manifest change, stop and establish a new Authorization. A green preflight does not authorize publication.",
    "issuer_role": "Human Product Owner / Product Lead",
    "issued_at": "2026-09-20T11:21:47+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed",
    "consumed_at": "2026-09-20T11:21:47+08:00",
    "consumed_artifacts": [
      "head:d0df9a6342d8209b5aa7f9826541d0b430b9da04",
      "tree:27ae44bec1b157e391ef1e0b859db3a068e21ba8",
      "package-sha256:9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764",
      "snapshot-manifest:c135c78b435fb2278fc734ed354bbf9e396266cdfffe878aef8a887b22c30ac0"
    ]
  }
}
```

本授权不允许修改 Swift/测试源，不允许 commit、push、PR、merge、部署、设备/性能/QA-001/INT-003 取证，也不允许关闭任何 Assignment。
