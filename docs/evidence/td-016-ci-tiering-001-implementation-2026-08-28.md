# Evidence: TD-016-CI-TIERING-001 — CI 分级实现

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "EVIDENCE-TD-016-CI-TIERING-001-IMPLEMENTATION",
  "record_type": "evidence",
  "title": "Fail-closed CI tiering implementation evidence",
  "status": "current",
  "updated_at": "2026-08-28T19:43:00+08:00",
  "revalidation_triggers": ["implementation_changed", "hosted_run_available", "required_checks_changed", "classification_table_changed"],
  "evidence": {
    "provenance": "executor_recorded",
    "environment_id": "ENV.LOCAL_EXECUTOR",
    "assignment_ref": "TD-016-CI-TIERING-001",
    "operator_ref": "Current Codex session",
    "reviewer_ref": null,
    "coverage": "focused",
    "observed_at": "2026-08-28T19:43:00+08:00",
    "valid_until": null,
    "artifact_bindings": [
      {"kind": "file", "identity": ".github/workflows/swift6-quality.yml"},
      {"kind": "file", "identity": "scripts/ci/classify_changes.py"},
      {"kind": "file", "identity": "scripts/ci/run_lightweight_checks.sh"},
      {"kind": "file", "identity": "docs/CI_CHANGE_CLASSIFICATION.md"},
      {"kind": "commit", "identity": "8f5d76e"},
      {"kind": "commit", "identity": "b000c91"}
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
- **Coverage:** local deterministic checks and GitHub Actions full-path execution for implementation snapshot `8f5d76e` and evidence-sync snapshot `b000c91`
- **Current conclusion:** hosted full-path behavior is verified; independent reviews returned `Pass with conditions` and remediation is in progress. Docs-only hosted behavior and reviewer revalidation remain required, so this evidence does not yet permit the fail-closed Claim

## Results So Far

| Check | Grade | Result |
|---|---|---|
| Classifier/link-checker unit tests | `Executor-recorded` | Pass: 12 tests, including source-to-docs rename and invalid base/head/non-commit fail-closed fixtures |
| Final Gate result matrix | `Executor-recorded` | Pass: full success, docs-only skipped, and five contradictory/error states rejected |
| KOS trigger-path fixture | `Executor-recorded` | Pass: `.kos`, `UPGRADE_STATUS.md` and `upgrade-records/**` remain validator triggers |
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
| Hosted classifier | `Executor-recorded` | Pass in 6s; the implementation diff selected `full` |
| Hosted lightweight checks | `Executor-recorded` | Pass in 4s |
| Hosted full Swift gate | `Executor-recorded` | Pass in 8m22s; vendor, format, KeyboardCore, RimeBridge, App/Keyboard tests, Debug and Release all green |
| Hosted final Gate | `Executor-recorded` | Pass in 5s; run [`33165797218`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33165797218) |
| Hosted current-snapshot full path | `Executor-recorded` | `b000c91` merge-ref run [`33166502457`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33166502457) passed all four jobs; branch head and GitHub synthetic merge ref remain distinct identities |
| Review-remediation local full path | `Executor-recorded` | KeyboardCore 1056/0, RimeBridge exit 0, Debug/Release build exit 0; Xcode 27 beta App test host did not finish crashed-worker restart cleanup and was interrupted after a bounded wait, so hosted `macos-26` remains required |

## Pending Before Claim

- Review remediation must pass local and hosted full-path checks at its frozen implementation commit.
- A docs-only hosted fixture is still required before any future required-check migration.
- Independent Architecture and Quality revalidation remain pending after remediation.

## Local Environment Qualification

The local App test failure is not accepted as a green Gate and is not attributed to TD-016. TD-016
changes no Swift, project, test or product resource file. The same run repeatedly restarted the test
host after allocator crashes and reported that the iOS 26 simulator could not load the arm64 IOHID
plug-in supplied by the Xcode 27 beta host. Package/bridge tests and both product builds passed.
The stable GitHub `macos-26` run subsequently passed the complete App/Keyboard suite. This resolves
the local environment uncertainty for commit `8f5d76e`; it does not convert the crashed local run
into a pass or substitute for the still-pending docs-only hosted fixture.

## Explicit Residual

The pinned Kit repository is private. No PAT or sibling-repository access assumption was added. Remote CI therefore reports that full KOS validation remains a local pre-merge requirement when governance records change. This is not a claim that JSON syntax equals `PASS KOS2000`.
