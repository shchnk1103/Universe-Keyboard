# TYPO-CORRECTION-002 F-01 commit revalidation — independent review handoff

**Assignment:** `TYPO-CORRECTION-002-F01-REMEDIATION-001`
**Authorization:** `AUTH-TYPO-CORRECTION-002-F01-COMMIT-REVALIDATION-001`
**Evidence class:** Exact-commit revalidation evidence plus independent local review result; not a Product, Release, merge, or parent-closure receipt
**Recorded:** `2026-09-18 Asia/Shanghai`
**Review result:** `Pass with conditions`

## Scope and exact candidate binding

This record revalidates the already-pushed F-01 candidate. It does not relabel
the pre-commit executor receipt as evidence for this commit. The independent
reviewer inspected the exact commit with `git show` and `git diff`, while the
current worktree's uncommitted governance updates were excluded from the
candidate under review.

| Field | Value |
|---|---|
| Base commit | `409eeab8ad4f1dd66f0139b5d1c561dc927316ce` |
| Candidate commit | `781ba235009e19a0be8b810a3441647dbcc23eb0` |
| Candidate tree | `25f589b8633ae95dfdb5c1f60d1e9e7d55ecb3a4` |
| Branch | `codex/typo-correction-002-f01-remediation-001` |
| Remote-tracking ref observed | `origin/codex/typo-correction-002-f01-remediation-001` at `781ba235009e19a0be8b810a3441647dbcc23eb0` |
| Exact commit patch SHA-256 | `f3eaefaba629407c09033fa113abca133adfeaf7f9fa51ec04f5dc08535ec691` |
| Four-file implementation patch SHA-256 | `ca21cbc4b3296669d9aaeba7e40c21c84c355c7ae39241c1207241e290103a2b` |

The executor confirmed the published branch SHA immediately after push. The
independent reviewer's live `git ls-remote` attempt was unavailable because of
a transient network restriction, so that reviewer treated the local
remote-tracking ref as local evidence. A supplemental executor read-only check
at `2026-09-18T22:53:49+08:00` returned the same SHA from the live remote:
`781ba235009e19a0be8b810a3441647dbcc23eb0`.

### Implementation/test file hashes in the exact commit

| File | SHA-256 |
|---|---|
| `Packages/RimeBridge/Sources/RimeBridge/RimeDeploymentService.swift` | `3b69b474f749c2c28cf0c91c11de668f36f632f2d8644368b5f12b76d9d4efd8` |
| `Universe Keyboard/Services/SchemaManager+Deployment.swift` | `59556bc04be0c3ecad4b05e6cd359a374efd34f7b4139841586d5c22032d8e71` |
| `Packages/RimeBridge/Tests/RimeBridgeTests/RimeEngineContractTests.swift` | `bb5a641db8dae7bc19546e7bab63a8bb832c0b97e28480bd36bb741f78b1b395` |
| `UniverseKeyboardTests/SchemaManagerTests.swift` | `803125825b24a8a8fa3f90aedb3b7f0da44144c324d7e9285fb339a363dca7f5` |

## Independent review

The independent reviewer inspected:

- `git show 781ba235009e19a0be8b810a3441647dbcc23eb0`;
- `git diff 781ba235009e19a0be8b810a3441647dbcc23eb0^ 781ba235009e19a0be8b810a3441647dbcc23eb0`;
- all four implementation/test files and their exact hashes;
- the committed Assignment, prior Authorization, and pre-commit executor
  evidence;
- repository instructions, branch/tree/object identity, and `git diff --check`.

### Passed

- `nil`, blank/whitespace, `(no api)`, and `(unknown)` are rejected after
  bounded normalization, while a valid version such as `1.8.1` remains valid.
- Production `RimeDeploymentService` requires deployment success, runtime
  smoke success, and a usable librime identity before reporting full-check
  success.
- `SchemaManager` repeats the identity guard before setting `rime_deployed`;
  sentinel inputs remain pending.
- Direct negative and valid-path tests are present and bound to the exact
  commit's test files.
- The exact commit stays within the bounded F-01 implementation/test and
  governance scope; no typo algorithm, sidecar, schema/vendor, device,
  performance, `INT-003`, `QA-001`, Product, or Release path was introduced.

### Conditions and residuals

- The pre-commit executor receipt is not itself commit/tree-bound. This new
  record closes that provenance gap for the candidate identity, but the test
  results below are explicitly marked as reused rather than independently
  rerun after the commit.
- The independent reviewer did not live-confirm the remote branch because
  network access was unavailable during its run. A later supplemental
  executor `git ls-remote` check did confirm the live remote SHA; this does not
  retroactively turn that check into an independent reviewer action.
- `RimeEngineImpl`'s ordinary diagnostic path still records the raw bridge
  version; this remediation proves the deployment success gate only, not a
  global identity-normalization contract.

## Validation provenance

No SwiftPM, xcodebuild, Release build, format, or vendor check was rerun by
the independent reviewer. The executor results below are reused because the
four implementation/test file hashes in the exact commit are identical to the
files used by those runs; the commit introduced no later implementation/test
byte changes. This is an equivalence statement, not an independent rerun.

| Run ID | Result reused from executor evidence |
|---|---|
| `TC2-F01-REM-20260918-2218-KCORE-01` | KeyboardCore: 1125 tests, 0 failures |
| `TC2-F01-REM-20260918-2220-RIME-01` | RimeBridgeTests: 103 tests, 20 existing conditional skips, 0 failures |
| `TC2-F01-REM-20260918-2221-APP-01` | UniverseKeyboardTests: 377 tests, 9 existing conditional skips, 0 failures; KeyboardTests: 11 tests, 0 failures |
| `TC2-F01-REM-20260918-2223-REL-01` | Release build: `BUILD SUCCEEDED` |
| `TC2-F01-REM-20260918-2218-FMT-01` | Strict Swift format/lint passed for all four Swift files |

## Bounded verdict and non-claims

**Bounded F-01 verdict: Pass with conditions.** No blocking code defect was
found in the exact commit. The remaining conditions are evidence/provenance
and remote-observation limitations described above, not authorization to
expand scope.

This record is not a Product Accept, Quality Gate closure, Release Pass,
merge authorization, PR authorization, device/performance result, `INT-003`
or `QA-001` result, parent Assignment closure, or formal KOS receipt.

The parent `TYPO-CORRECTION-002` remains Active. The next decision belongs to
Product Lead: whether to authorize a separate PR/review lane after these
conditions are addressed; no such action is authorized here.
