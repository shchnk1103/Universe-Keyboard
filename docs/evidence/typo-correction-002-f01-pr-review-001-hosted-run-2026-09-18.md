# TYPO-CORRECTION-002 F-01 PR review — hosted run evidence

**PR:** [#139](https://github.com/shchnk1103/Universe-Keyboard/pull/139)
**Run:** [Swift 6 Quality #35360577049](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/35360577049)
**Head under test:** `8386a9039a952858cf7a7e0349bbc1e916e21c10`
**Base:** `9eb83158e49218c1e8f75dbe7dd9e0390db81409`
**Recorded:** `2026-09-18 Asia/Shanghai`
**Evidence class:** Hosted CI fact record; not a Product, Quality, Release, merge, or Assignment-closure decision

## Result matrix

| Job | Result | Observation |
|---|---|---|
| `classify-change` | Pass | Classified the PR as full; Swift paths require the full gate |
| `lightweight-checks` | Pass | Markdown links, CI tests, final-gate matrix, and KOS trigger paths passed |
| `format-swift` | Pass | All Swift files changed relative to `main` passed strict format lint |
| `test-keyboardcore` | Pass | Hosted KeyboardCore test job passed |
| `test-rimebridge` | Pass | Hosted RimeBridge test job passed |
| `build-release` | Pass | Hosted Release build passed |
| `test-app-keyboard` | **Blocked / failed before compilation** | `xcodebuild` exit 70: hosted runner had no matching `iPhone 17 Pro` Simulator destination |
| `final-quality-gate` | Failed as derived | Correctly rejected the failed required App/Keyboard job |
| GitGuardian | Pass | Security check passed |

## Failure boundary

The failed job requested:

```text
platform=iOS Simulator,name=iPhone 17 Pro
```

The runner reported no available device matching that destination and exited
before compilation or test execution. The available-destination listing did
not contain an iPhone 17 Pro Simulator. Therefore this run does not provide a
test failure or a source regression signal for F-01; it provides an
environment-availability failure for the hosted CI matrix.

The local executor previously used the available iPhone 17 Pro Max / iOS 27.0
UDID and completed the required test/build commands. That local result does
not turn the hosted environment failure green, and no CI workflow change is
authorized by this evidence record.

## Disposition and non-claims

**Disposition:** Hosted PR review is blocked pending a Product-authorized
environment decision: provide the required hosted Simulator, or separately
authorize a CI destination/workflow change. This record does not choose either
option.

The draft PR remains open. This is not a merge authorization, Product Accept,
Quality Gate pass, Release pass, device/performance acceptance, `INT-003`,
`QA-001`, child Assignment closure, or parent `TYPO-CORRECTION-002` closure.
