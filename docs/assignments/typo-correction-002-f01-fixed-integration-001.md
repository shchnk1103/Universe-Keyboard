# typo-correction-002-f01-fixed-integration-001

Policy version 1.0.0

```kos-record
{
  "schema_version": {
    "major": 1,
    "minor": 0
  },
  "updated_at": "2026-10-11",
  "record_id": "typo-correction-002-f01-fixed-integration-001",
  "record_type": "assignment",
  "title": "PR139 fixed-baseline source integration and one local CI",
  "decision_source": "Human continue preceding fixed integration/validation recommendation; current Human confirms 405D exclusive for this CI",
  "lifecycle": "completed",
  "current_phase": "Completed: source5 sealed, once full CI passed, source/status stable; independent delta review and publishing remain separate",
  "parent_refs": [
    "TYPO-CORRECTION-002"
  ],
  "authorization_refs": [
    "AUTH-TYPO-CORRECTION-002-F01-FIXED-INTEGRATION-001"
  ],
  "responsibilities": {
    "assignment_authority": "Human Product Lead",
    "domain_owner": "RIME Platform Maintainer",
    "executor": "Codex /root in isolated F01 writer",
    "environment_executor": "Codex /root: bounded CI on exclusive 405D only",
    "human_dependency": "Human: publishing/PR139 update/merge/parent Gate require separate approval",
    "architecture_reviewer": "Architecture & Knowledge Steward: later independent delta review, not assigned yet",
    "quality_reviewer": "Quality, Performance & Release Maintainer: later independent delta review, not assigned yet",
    "product_approver": "Human Product Lead"
  },
  "scope": "Freeze main a44f850; mechanically integrate five PR139 source/test paths from e20e7c8; seal candidate then once full local CI",
  "non_goals": "No RimeRuntimeProvenance, query algorithm, Extension deployment, Vendor upgrade, performance capture, source commit/push/PR update/merge/parent Gate/Close/ADR/Release",
  "required_inputs": [
    "exact PR139 source5 patch",
    "main a44f850",
    "current 405D exclusive Human receipt",
    "sealed candidate and exact command binding before tests"
  ],
  "entry_criteria": [
    "isolated writer",
    "independent AUTH recorded before further mutations",
    "source5 only",
    "candidate/commands frozen before tests"
  ],
  "exit_criteria": [
    "integration/source hashes",
    "once full CI counts with skips retained",
    "source/status stable; handoff independent review and publishing approval"
  ],
  "stop_conditions": [
    "main movement does not cause rebase or retry",
    "first validation failure stops",
    "outside-five source changes stop",
    "device reservation/identity mismatch stops",
    "free disk under 8GiB stops"
  ],
  "revalidation_triggers": [
    "source/command/environment/authority changes"
  ],
  "handoff_target": "Human: independent bounded delta review; then source publication approval",
  "fixed_identity": {
    "base": "a44f850d638204aa5c992ac13fb71f5f5424734c",
    "old_head": "e20e7c8a3a48822e2e712d36453e2cf574088e87",
    "old_base": "9eb83158e49218c1e8f75dbe7dd9e0390db81409",
    "source_paths": [
      "Packages/RimeBridge/Sources/RimeBridge/RimeDeploymentService.swift",
      "Packages/RimeBridge/Tests/RimeBridgeTests/RimeEngineContractTests.swift",
      "Universe Keyboard/Services/SchemaManager+Deployment.swift",
      "UniverseKeyboardTests/RimeSettingsStoreTests.swift",
      "UniverseKeyboardTests/SchemaManagerTests.swift"
    ],
    "writer": "/Users/doubleshy0n/.codex/worktrees/typo-f01-fixed-integration/Universe Keyboard"
  },
  "budget": "One mechanical integration; each CI stage once, 45min total/30min per stage; no main chasing",
  "side_effects": "Required Xcode/SwiftPM cache/temp operations; isolated /private/tmp/uk-f01ci-a44-001 outputs; pinned Vendor fetch/verify; private fixture operations; signed unique Keychain test item read/write/delete; exclusive 405D test hosts only",
  "preparation_incident": "Authority record Python encoding failure occurred before file creation. Dependent patch command was mistakenly started under valid Human task authorization before the standalone record existed. Four source paths applied cleanly; one test conflict. Further source actions stopped until this actual-time record. No backdating or claim of prior consumption. No tests/publication happened.",
  "evidence_refs": [
    "docs/evidence/typo-correction-002-f01-fixed-integration-001.md"
  ]
}
```
