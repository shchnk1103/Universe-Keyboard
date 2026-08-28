# Evidence: TD-016-CI-TIERING-001 — CI 分级实现

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "EVIDENCE-TD-016-CI-TIERING-001-IMPLEMENTATION",
  "record_type": "evidence",
  "title": "Fail-closed CI tiering implementation evidence",
  "status": "current",
  "updated_at": "2026-08-28T19:03:00+08:00",
  "revalidation_triggers": ["implementation_changed", "hosted_run_available", "required_checks_changed", "classification_table_changed"],
  "evidence": {
    "provenance": "executor_recorded",
    "environment_id": "ENV.LOCAL_EXECUTOR",
    "assignment_ref": "TD-016-CI-TIERING-001",
    "operator_ref": "Current Codex session",
    "reviewer_ref": null,
    "coverage": "focused",
    "observed_at": "2026-08-28T19:03:00+08:00",
    "valid_until": null,
    "artifact_bindings": [
      {"kind": "file", "identity": ".github/workflows/swift6-quality.yml"},
      {"kind": "file", "identity": "scripts/ci/classify_changes.py"},
      {"kind": "file", "identity": "scripts/ci/run_lightweight_checks.sh"},
      {"kind": "file", "identity": "docs/CI_CHANGE_CLASSIFICATION.md"}
    ],
    "permits_claim_ids": [],
    "prohibits_claim_ids": ["CLAIM.CI.TIERING_FAIL_CLOSED"]
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | current |

---

- **Evidence grade:** `Executor-recorded`
- **Coverage:** local classifier/checker fixtures, pinned KOS validation, package/bridge tests and Debug/Release builds
- **Current conclusion:** implementation and deterministic local checks are complete; hosted workflow behavior and independent reviews remain required, so this evidence does not yet permit the fail-closed Claim

## Results So Far

| Check | Grade | Result |
|---|---|---|
| Classifier/link-checker unit tests | `Executor-recorded` | Pass: 11 tests, including source-to-docs rename fail-closed fixture |
| Final Gate result matrix | `Executor-recorded` | Pass: full success, docs-only skipped, and five contradictory/error states rejected |
| Python bytecode compilation | `Executor-recorded` | Pass |
| Workflow YAML parse | `Executor-recorded` | Pass via Ruby YAML parser |
| Historical docs-only diff `8e8ab1e..6bf7017` | `Executor-recorded` | `docs_only`, `requires_full=false`, 14 paths |
| `.kos/project.json` JSON parse | `Executor-recorded` | Pass |
| Pinned KOS Kit validator | `Executor-recorded` | `PASS KOS2000` in advisory mode using local `kos-agent-kit@v0.5.0` |
| RIME vendor inventory | `Executor-recorded` | Pass: 12 pinned artifacts verified |
| KeyboardCore | `Executor-recorded` | Pass: 1056 tests, 0 failures |
| RimeBridgeTests | `Executor-recorded` | Pass: 68 tests, 20 skipped, 0 failures on iPhone 17 Pro / iOS 26.0 simulator |
| App + Keyboard tests | `Executor-recorded` | Environment-blocked: KeyboardTests passed 11/11; 13 main-App tests were interrupted by repeated Xcode 27 beta simulator host crashes (`pointer being freed was not allocated`) and an incompatible IOHID simulator plug-in; xcresult: `Test-Universe Keyboard-2026.08.28_18-57-38-+0800.xcresult` |
| Debug simulator build | `Executor-recorded` | Pass with Swift 6 strict concurrency and warnings-as-errors |
| Release simulator build | `Executor-recorded` | Pass with Swift 6 strict concurrency and warnings-as-errors |

## Pending Before Claim

- Actual TD-016 committed diff must classify `full` because it changes workflow and `scripts/ci/**`.
- The common lightweight runner must pass against the committed diff with the pinned local KOS validator.
- GitHub hosted run must show classifier/lightweight/full/final results on the implementation PR.
- A docs-only hosted fixture is still required before any future required-check migration.
- Independent Architecture and Quality review remain pending.

## Local Environment Qualification

The local App test failure is not accepted as a green Gate and is not attributed to TD-016. TD-016
changes no Swift, project, test or product resource file. The same run repeatedly restarted the test
host after allocator crashes and reported that the iOS 26 simulator could not load the arm64 IOHID
plug-in supplied by the Xcode 27 beta host. Package/bridge tests and both product builds passed.
Therefore the local App suite remains explicitly unresolved, while the stable GitHub `macos-26`
hosted run is the required environment evidence before review can advance.

## Explicit Residual

The pinned Kit repository is private. No PAT or sibling-repository access assumption was added. Remote CI therefore reports that full KOS validation remains a local pre-merge requirement when governance records change. This is not a claim that JSON syntax equals `PASS KOS2000`.
