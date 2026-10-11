# RIME-SYNC-001 Simulator Evidence — Independent Quality Review

| Field | Value |
|---|---|
| Review date | 2026-09-23 |
| Reviewer | Independent Quality reviewer runtime `Hegel` (`01a0cdf6-2f4c-76d2-bf91-78286fa38d0c`) |
| Review mode | Read-only; no files changed and no tests/devices/simulators operated by reviewer |
| Reviewed baseline | `4a51228fc8e435d538e9a5f7342ae325502e1e66` plus the exact uncommitted files below |
| Verdict | `Blocked` |
| Scope | This round's Simulator UI/Keychain evidence and directly related test seams only; not parent closure |

## Reviewed identity

The reviewer verified these SHA-256 values against the authorized working-tree
inputs:

| File | SHA-256 |
|---|---|
| `docs/evidence/rime-sync-v1-closure-readiness-2026-09-23.md` | `9eff412e01a48311b79d22f1bccda8b297434356f941521c023a6a3b6b75a97b` |
| `Universe Keyboard/Models/RimeSyncUITestFixture.swift` | `7f6735bcfeeec215a7d0edb6f77e45b07e9d30770fb538ad1a0cd1011fc16867` |
| `Universe Keyboard/Views/Settings/RimeSyncSettingsView.swift` | `beb774914813c717c71c576d33590f84b53c7b5b39357b97f314d7734e6eea0d` |
| `UniverseKeyboardUITests/RimeSyncSettingsUITests.swift` | `c6fe7b995d7d6f03a03648414121e37f84ec26f58b2699b103813f7cea51fd2d` |
| `UniverseKeyboardTests/RimeSyncTests.swift` | `66dcd3fe42586adcc5e279a94ce02b7d956175887d2624b587fec6d908e67f88` |

## Evidence matrix

| Evidence | Result | Boundary |
|---|---|---|
| UI tests on iPhone 18 Pro / iOS 27.0 Simulator | First run: 6 passed, 2 failed; focused rerun: 2 passed | All 8 test cases have passing evidence across the two runs, but this is not one 8/8 run. Initial failures and their selector/assertion corrections must remain visible. |
| Signed Simulator Keychain integration test | 1 passed, 0 failed | Production `RimeSyncSecretStore` used Security.framework with a unique UUID account and dummy values for add/read/update/delete. No physical-device Keychain claim. |
| Signed App + Keyboard full test | 385 passed, 0 failed, 9 skipped; xcresult total 394 | Simulator engineering evidence only; skipped tests are not passes. |
| Unsigned App + Keyboard full test | 384 passed, 1 failed, 9 skipped; xcresult total 394 | The failure was the Keychain integration test returning `accessDenied` in an unsigned host. |

Result bundles:

- Signed Keychain: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T10-56-10-543Z_pid5815_2fdab9d2.xcresult`
- Initial UI run: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T10-57-40-927Z_pid5815_76c4267e.xcresult`
- Focused UI rerun: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T11-02-41-836Z_pid5815_203b3794.xcresult`
- Unsigned full suite: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T11-04-34-340Z_pid5815_6eba3809.xcresult`
- Signed full suite: `~/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/result-bundles/test_sim_2026-09-23T11-05-46-919Z_pid5815_cc33d099.xcresult`

## Findings

### P0 — CI unsigned lane fails the real Keychain integration test

The repository App + Keyboard CI test command uses `CODE_SIGNING_ALLOWED=NO`.
The observed unsigned full-suite result fails the new production Keychain test
with `accessDenied`; a separate signed Simulator run passes. Therefore the
signed result is useful bounded evidence, but the current unsigned CI lane is
not compatible with this test and cannot be called green for this change.

Before merge/CI acceptance, either add a signed Simulator Keychain lane or
separate this integration test from the unsigned lane while retaining explicit
signed-lane coverage. Do not convert the observed unsigned failure into a
passing result by suppressing the error.

### P1 — UI test fixture does not isolate existing credentials/defaults

`RimeSyncSettingsView` calls production `model.loadSecrets()` before applying
the status fixture. The UI process uses the production secret store and the
fixture does not isolate its Keychain namespace. Existing same-Bundle-ID
Simulator credentials could therefore be read into the view model. The
configuration fixture also writes/removes sync keys in `UserDefaults.standard`
rather than an isolated suite.

No network/sync invocation is present in the fixture and no external exposure
was observed. However, the seam does not prove non-access to pre-existing
Simulator credentials or settings. Use an isolated test secret store and
dedicated defaults suite before claiming that guarantee.

### P2 — Total-count mismatch in the full-suite record

The signed xcresult summary reports `totalTestCount = 394`, with 385 passed,
0 failed, and 9 skipped. The MCP discovery output said 395 discovered. The
readiness evidence currently says “395 discovered” alongside the xcresult
counts; use the authoritative xcresult total (394) and explain the discovery
count separately if retained.

## Confirmed and unverified scope

Confirmed: DEBUG-only status fixture; injection after secret loading; UI
assertions for success/conflict/corruption copy and recovery-code affordance;
random Keychain account and dummy values with cleanup attempt; fixture does not
invoke transport, synchronization or shared-folder writes.

Not covered: iPhone 13 Pro Keychain behavior, authentication failure,
wrong-key recovery, provider-side deletion result, completed disconnect, or
parent lifecycle/Product/Architecture/Release decisions. This review does not
change CloudKit deferral or retained technical-debt dispositions.
