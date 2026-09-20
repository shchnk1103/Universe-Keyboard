# Evidence: test-contract/environment identity reconciliation

## Identity

| Field | Value |
|---|---|
| Assignment | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-001`](../assignments/typo-correction-002-recall-remediation-test-contract-environment-001.md) |
| Reconciliation Authorization | [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-RECONCILIATION-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-TEST-CONTRACT-ENVIRONMENT-RECONCILIATION-001.md) |
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001` |
| Branch | `codex/typo-correction-002-recall-preflight-001` |
| HEAD | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` |
| HEAD tree | `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |
| Reconciliation status | `Completed; publication-preflight still requires a new Authorization` |

## Authoritative test count

The retained result bundle is authoritative for execution totals:

- `totalTestCount=388`
- `passedTests=379`
- `skippedTests=9`
- `failedTests=0`

The raw XCTest log independently reconciles this as `UniverseKeyboardTests.xctest=377` plus `KeyboardTests.xctest=11`, for `388` total. The earlier XcodeBuildMCP outer summary of `389 discovered` is retained as a historical wrapper observation only; it is not used as the final execution total.

## Hash identity

The target test fixture has two different identities and they must not be called the same thing:

| Identity | Value |
|---|---|
| Previous Git blob | `55bd3e697da246ec2455deebb4c63dc364b40baa` |
| Current Git blob | `45c571adff9169331b8e43df7a900f5b8d613fa9` |
| Current file SHA-256 | `788d6fd0fc814a034a61873cda6ba67432e21042f7953c8849212f350e8066f9` |

## Child scope manifest

This is a child-scope manifest, not the final parent publication manifest. It intentionally includes only the test fixture changed under this child:

```text
UniverseKeyboardTests/RimeSettingsStoreTests.swift|git-blob=45c571adff9169331b8e43df7a900f5b8d613fa9|file-sha256=788d6fd0fc814a034a61873cda6ba67432e21042f7953c8849212f350e8066f9
```

Manifest SHA-256: `507e3ba431c2f64c0cdbd22d8eb1c1b03cc466ce3b3b12b1966538560b9d0c1a`.

The uncommitted KeyboardCore implementation/tests and other governance records remain outside this child scope. A later publication-preflight must create and bind its own complete allowlist rather than reusing this child manifest or treating the mixed worktree as a clean snapshot.

## Residuals and non-claims

- `107` `client is not entitled` messages remain associated with `CODE_SIGNING_ALLOWED=NO`; no entitlement or signing change is authorized.
- The reconciliation did not run tests, build, install, capture, or create a product/device Run.
- This evidence does not establish real RIME behavior, QA-001, INT-003, paired performance, 180 ms, Product/Quality/Release Gate, commit, push, PR, merge, TestFlight, Release, or parent/child closure.

## Next action

Request a new publication-preflight Authorization bound to the final parent source allowlist and this corrected identity record. That Authorization may rerun the complete CI-equivalent matrix; it does not itself authorize publication or merge.
