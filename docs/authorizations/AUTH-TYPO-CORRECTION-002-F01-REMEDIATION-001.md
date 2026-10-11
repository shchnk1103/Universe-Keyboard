# Authorization: AUTH-TYPO-CORRECTION-002-F01-REMEDIATION-001 — bounded sentinel remediation

## Current Status

| Field | Value |
|---|---|
| Status | active |
| Consumption | consumed by establishing and executing this bounded F-01 remediation; it does not authorize publication or parent-Assignment closure |

Human Product Owner, current session `2026-09-18 Asia/Shanghai`: “先建立新的
bounded F-01 remediation Assignment/Authorization，再修复；暂时不要把当前分支
开成可合并 PR，也不要关闭当前 Assignment。”

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-TYPO-CORRECTION-002-F01-REMEDIATION-001",
  "record_type": "authorization",
  "title": "Authorize bounded F-01 RIME identity sentinel fail-closed remediation",
  "status": "active",
  "updated_at": "2026-09-18T22:12:27+08:00",
  "revalidation_triggers": [
    "scope_changed",
    "authority_revoked",
    "base_commit_changed",
    "review_finding",
    "rime_bridge_identity_contract_changed",
    "candidate_commit_created",
    "device_or_performance_evidence_requested",
    "publication_or_parent_closure_requested"
  ],
  "parent_refs": [
    "TYPO-CORRECTION-002",
    "TYPO-CORRECTION-002-F01-REVIEW-QUALITY-HOLD"
  ],
  "authorization": {
    "action": "remediate_typo_correction_002_f01_identity_sentinels",
    "target": "TYPO-CORRECTION-002-F01-REMEDIATION-001",
    "artifact_bindings": [
      {"kind": "base_commit", "identity": "409eeab8ad4f1dd66f0139b5d1c561dc927316ce"},
      {"kind": "branch", "identity": "codex/typo-correction-002-f01-remediation-001"},
      {"kind": "worktree", "identity": "/private/tmp/universe-keyboard-typo-correction-002-f01-remediation-001"},
      {"kind": "file", "identity": "Packages/RimeBridge/Sources/RimeBridge/RimeDeploymentService.swift"},
      {"kind": "file", "identity": "Universe Keyboard/Services/SchemaManager+Deployment.swift"},
      {"kind": "test", "identity": "Packages/RimeBridge/Tests/RimeBridgeTests/RimeEngineContractTests.swift"},
      {"kind": "test", "identity": "UniverseKeyboardTests/SchemaManagerTests.swift"}
    ],
    "scope": "From exact base 409eeab8ad4f1dd66f0139b5d1c561dc927316ce, make the smallest fail-closed F-01 correction for unavailable production librime identity values, including (no api) and (unknown), add direct bounded tests, and produce exact-candidate executor evidence for independent review.",
    "exclusions": [
      "parent TYPO-CORRECTION-002 closure or scope migration",
      "typo algorithm, sidecar query, candidate ranking, AI/model, input history or latency policy",
      "RIME schema, user dictionary, vendor archive, fixture package or deployment provenance changes",
      "Device Hub, real-device, Simulator capture, INT-003, QA-001, paired performance or TestFlight",
      "Product, Quality, Release or merge conclusion",
      "commit, push, pull request, merge, tag, branch deletion or external publication",
      "changes to the user's dirty main checkout or broad provenance/sidecar worktree"
    ],
    "issuer_role": "Human Product Owner acting as Product Lead",
    "decision_source": "in-session 2026-09-18 Asia/Shanghai instruction to establish a new bounded F-01 remediation Assignment/Authorization and fix it without opening a merge-ready PR or closing the current Assignment",
    "issued_at": "2026-09-18T22:12:27+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

## Authorized actions

1. Inspect the exact `409eeab8...316ce` F-01 implementation and its test seams.
2. Implement only the bounded fail-closed sentinel correction in the named
   production/test surface, preserving the normal valid-version path.
3. Add direct negative coverage for nil, blank/whitespace, `(no api)`, and
   `(unknown)`, and add direct forwarding/normalization coverage where the
   existing injection seam permits it.
4. Run the required local checks and write an executor evidence record bound to
   the exact candidate tree, commands, environment, results, and non-claims.
5. Request independent Architecture/Quality review. Keep Product, Release,
   device, performance, commit, push, PR, merge, and parent-Assignment closure
   decisions outside this Authorization.

## Human authority boundary

This Authorization does not permit the Executor to infer that F-01, the parent
Assignment, or any Product/Quality/Release Gate has passed. It does not permit
changing RIME source ownership, App Group ownership, schema/fixture identity,
or the parent Assignment's status. It does not authorize commit, push, PR,
merge, TestFlight, App Store, Release, or branch cleanup.

## Revalidation

This Authorization becomes invalid for continued work if the exact base,
artifact surface, identity contract, scope, reviewer independence, or requested
external action changes. A new authorization is required before any such change.
