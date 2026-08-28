# Evidence: TD-016-CI-TIERING-001 — CI 分级实现

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "EVIDENCE-TD-016-CI-TIERING-001-IMPLEMENTATION",
  "record_type": "evidence",
  "title": "Fail-closed CI tiering implementation evidence",
  "status": "current",
  "updated_at": "2026-08-28T20:15:00+08:00",
  "revalidation_triggers": ["implementation_changed", "hosted_run_available", "required_checks_changed", "classification_table_changed"],
  "evidence": {
    "provenance": "executor_recorded",
    "environment_id": "ENV.LOCAL_EXECUTOR",
    "assignment_ref": "TD-016-CI-TIERING-001",
    "operator_ref": "Current Codex session",
    "reviewer_ref": null,
    "coverage": "focused",
    "observed_at": "2026-08-28T20:15:00+08:00",
    "valid_until": null,
    "artifact_bindings": [
      {"kind": "file", "identity": ".github/workflows/swift6-quality.yml"},
      {"kind": "file", "identity": "scripts/ci/classify_changes.py"},
      {"kind": "file", "identity": "scripts/ci/run_lightweight_checks.sh"},
      {"kind": "file", "identity": "docs/CI_CHANGE_CLASSIFICATION.md"},
      {"kind": "commit", "identity": "8f5d76e"},
      {"kind": "commit", "identity": "b000c91"},
      {"kind": "commit", "identity": "0623e7c"},
      {"kind": "commit", "identity": "bd4b6eb"}
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
- **Coverage:** local deterministic checks, GitHub Actions full-path execution for implementation snapshot `8f5d76e`, evidence-sync snapshot `b000c91` and remediation snapshot `0623e7c`, plus hosted docs-only fixture `bd4b6eb` on temporary PR #88
- **Current conclusion:** hosted full-path and hosted docs-only skip paths are recorded. Independent Architecture/Quality revalidation remains required, so this evidence does not yet permit the fail-closed Claim, merge, required-check migration or Product acceptance

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
| Hosted remediation full path | `Executor-recorded` | Frozen implementation `0623e7c`; GitHub synthetic merge ref `5ac87db`; run [`33168928860`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33168928860) classified `full` (`requires_full=true`, 28 paths including workflow/scripts), passed lightweight checks, passed the complete `build-and-test` suite in 10m22s, and passed `final-quality-gate`. Branch head and GitHub synthetic merge ref remain distinct identities |
| Hosted docs-only fixture | `Executor-recorded` | Temporary Draft PR #88, branch head `bd4b6eb`, merge ref `216267b`, run [`33169007898`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33169007898): `{"classification": "docs_only", "requires_full": "false", "reason": "all_paths_in_lightweight_allowlist", "changed_count": "1", "base_sha": "0623e7c489679d42dbda2d8d612a5d16c19e88d1", "head_sha": "216267b3e886cb0e127b33e2869b06292d951b78", "full_required_paths": []}`; `classify-change` 4s success; `lightweight-checks` 6s success; `build-and-test` skipped; `final-quality-gate` 5s success. Fixture PR is evidence only and must be closed without merge |

## Pending Before Claim

- Independent Architecture and Quality revalidation of the remediation commit and hosted docs-only fixture.
- Human Product Owner decision on stacked PR disposition and merge.
- Required-check migration remains separately unauthorized.

## Local Environment Qualification

The local App test failure is not accepted as a green Gate and is not attributed to TD-016. TD-016
changes no Swift, project, test or product resource file. The same run repeatedly restarted the test
host after allocator crashes and reported that the iOS 26 simulator could not load the arm64 IOHID
plug-in supplied by the Xcode 27 beta host. Package/bridge tests and both product builds passed.
The stable GitHub `macos-26` run subsequently passed the complete App/Keyboard suite for `8f5d76e`,
`b000c91` and remediation `0623e7c`. This does not convert the crashed local run into a pass. The
hosted docs-only fixture is now recorded on PR #88 / run `33169007898`; that fixture is not merge
authority.

## Explicit Residual

The pinned Kit repository is private. No PAT or sibling-repository access assumption was added. Remote CI therefore reports that full KOS validation remains a local pre-merge requirement when governance records change. This is not a claim that JSON syntax equals `PASS KOS2000`.
