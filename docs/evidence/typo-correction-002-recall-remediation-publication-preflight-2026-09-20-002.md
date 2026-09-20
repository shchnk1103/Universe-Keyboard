# Evidence: TYPO-CORRECTION-002 recall remediation publication preflight 002

## Identity

| Field | Value |
|---|---|
| Assignment | [`TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-001`](../assignments/typo-correction-002-recall-remediation-publication-preflight-001.md) |
| Authorization | [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-002`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-002.md) |
| Preflight ID | `TC2-RECALL-PREFLIGHT-20260920-002` |
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001` |
| Branch | `codex/typo-correction-002-recall-preflight-001` |
| HEAD | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` |
| HEAD tree | `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |
| Simulator | `iPhone 17 Pro / iOS 26.0 / 8C2943AC-AC97-432F-ACEE-BE3DA2B9ACB2` |
| DerivedData | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-002-app-derived`, plus scheme-specific paths below |
| Result | `Local CI-equivalent preflight passed with retained residuals` |

This is a build/test preflight receipt, not a Product Gate, Quality Gate, Release Gate, product Run, device acceptance, publication, or merge receipt.

## Frozen source allowlist

The five source/package artifacts were unchanged throughout the preflight:

| Path | SHA-256 |
|---|---|
| `Packages/KeyboardCore/Package.swift` | `9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764` |
| `Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift` | `9fb3fdc9c4cb809cf08b098bd882226e74a1a74eef23a043bba261d017216b57` |
| `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift` | `e05488596a044e199b30fb3f262f72877ff31b172ba98638091b44ce7b030c9d` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift` | `9147004b425c19f2326292358f13e6db90c4d3969f2e4fb758841119991f3fd6` |
| `UniverseKeyboardTests/RimeSettingsStoreTests.swift` | `788d6fd0fc814a034a61873cda6ba67432e21042f7953c8849212f350e8066f9` |

Sorted `path|sha256` manifest digest: `bcbabcb7c7870b90691422ab7fd65f028f348921e64fc39ebaf5db94038d2e3e`.

Vendor provenance remained fixed and verified:

- Archive SHA-256: `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`
- Materialized vendor tree SHA-256: `d446b0a4cdd40d42f53359ba8a7677d625ac8461c60ecfe92f90ca73e8df14fd`
- `bash scripts/ensure_rime_vendor.sh verify`: passed; 12 framework artifacts verified.

## Required checks

| Check | Result | Artifact / note |
|---|---|---|
| Swift strict lint | Passed | Four changed Swift files; no source bytes changed. |
| KeyboardCore | `1143 passed / 0 failed` | `swift test --disable-sandbox --package-path Packages/KeyboardCore`; isolated Swift/Clang caches. The initial cache and SwiftPM sandbox attempts were environment-blocked and are retained as diagnostics, not test failures. |
| RimeBridgeTests | `105 total / 85 passed / 20 skipped / 0 failed` | Result: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-20T05-10-38-032Z_pid25092_f7a8afdc.xcresult`; log: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-20T05-10-38-032Z_pid25092_9dec0c2e.log`. |
| Universe Keyboard Debug | `388 total / 379 passed / 9 skipped / 0 failed` | Result: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-20T05-11-15-269Z_pid25092_dc045218.xcresult`; log: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-09-20T05-11-15-269Z_pid25092_79d86b98.log`. XcodeBuildMCP outer summary also said `389 discovered`; authoritative xcresult remains `388 total`, consistent with the earlier reconciliation. |
| Universe Keyboard Release build | Passed: `BUILD SUCCEEDED` | Log: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/build_sim_2026-09-20T05-12-19-350Z_pid25092_463af7a8.log`. |
| Diff/provenance | Passed | `git diff --check`, HEAD/package/source/vendor identities captured. |
| Governance validators | Passed | `python3 -m unittest discover -s scripts/ci/tests -p 'test_*.py'` = `12/12`; `test_verify_final_gate.sh` passed; `test_kos_trigger_paths.sh` passed. |

Scheme-specific DerivedData paths:

- RimeBridgeTests: `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-002-rimebridge-derived`
- Universe Keyboard Debug: `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-002-app-derived`
- Universe Keyboard Release: `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-002-release-derived`

## Residuals

- The Debug log contains `107` `client is not entitled` messages because the invocation uses `CODE_SIGNING_ALLOWED=NO`. No checked-in entitlement or signing configuration was changed.
- Nine App + Keyboard tests remain skipped according to the retained xcresult; their original skip reasons remain part of the test artifact.
- Release build logs contain the existing AppIntents metadata extraction warning; the build still completed successfully.
- The outer `389 discovered` number is retained as an executor-wrapper observation only; it is not used as the authoritative test total.

## Non-claims

This preflight does not prove production runtime behavior, real RIME deployment or sidecar behavior, device acceptance, INT-003, QA-001, paired performance, 180 ms, Product/Quality/Release Gate, hosted CI, commit, push, PR, merge, TestFlight, Release, or parent/child closure.

## Handoff

The local CI-equivalent preflight is complete for this exact manifest. Next step is an independent Architecture/Quality read-only review of this receipt and then a bounded Product/publication decision. A separate publication Authorization is required before any commit, push or PR; this preflight Authorization does not grant those actions.
