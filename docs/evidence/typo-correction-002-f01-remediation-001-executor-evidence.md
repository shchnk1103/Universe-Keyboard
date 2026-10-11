# TYPO-CORRECTION-002 F-01 remediation — executor evidence

**Assignment:** `TYPO-CORRECTION-002-F01-REMEDIATION-001`
**Authorization:** `AUTH-TYPO-CORRECTION-002-F01-REMEDIATION-001`
**Evidence class:** Executor evidence; not an independent Quality, Product, or Release receipt
**Recorded:** `2026-09-18 Asia/Shanghai`
**Receipt state:** Regenerated after the Assignment-to-evidence and Active Work mirror links were added

## Scope and candidate binding

This receipt covers only the bounded remediation for unavailable librime
identity values. It does not cover the parent Assignment's sidecar query,
typo-correction quality, schema/archive provenance, device acceptance,
performance, `INT-003`, `QA-001`, Product Gate, Release, or merge.

The parent Assignment remains Active. No commit, push, PR, merge, branch
cleanup, or external publication was performed or authorized.

| Field | Value |
|---|---|
| Base commit | `409eeab8ad4f1dd66f0139b5d1c561dc927316ce` |
| Base tree | `7d2e3b212daa7c8dc36d82d629e5ee15313b34bf` |
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-f01-remediation-001` |
| Branch | `codex/typo-correction-002-f01-remediation-001` |
| Candidate state | Base commit plus the five tracked files below; uncommitted working tree. The three untracked Assignment/Authorization/evidence records are governance evidence, not part of the implementation patch digest. |
| Tracked candidate diff SHA-256 | `bd9ffb393d6141773d3ad458686f4d0a139f958b18e5dc2c1bf111afbfa6421a` |
| Four-file implementation patch SHA-256 | `ca21cbc4b3296669d9aaeba7e40c21c84c355c7ae39241c1207241e290103a2b` |
| Vendor verification | `bash scripts/ensure_rime_vendor.sh verify` passed; 12 framework artifacts structurally verified |

The patch digest above covers only these four tracked files and is intentionally
separate from the untracked governance/evidence records:

| File | SHA-256 |
|---|---|
| `Packages/RimeBridge/Sources/RimeBridge/RimeDeploymentService.swift` | `3b69b474f749c2c28cf0c91c11de668f36f632f2d8644368b5f12b76d9d4efd8` |
| `Universe Keyboard/Services/SchemaManager+Deployment.swift` | `59556bc04be0c3ecad4b05e6cd359a374efd34f7b4139841586d5c22032d8e71` |
| `Packages/RimeBridge/Tests/RimeBridgeTests/RimeEngineContractTests.swift` | `bb5a641db8dae7bc19546e7bab63a8bb832c0b97e28480bd36bb741f78b1b395` |
| `UniverseKeyboardTests/SchemaManagerTests.swift` | `803125825b24a8a8fa3f90aedb3b7f0da44144c324d7e9285fb339a363dca7f5` |
| `docs/ACTIVE_WORK.md` | `96980f597d037a045cdc65502ff4956fdc5a257c5ac41b9338b8dca61ebdc7a0` |

The tracked candidate digest above is the SHA-256 of `git diff --binary` for
all five tracked paths, including the Active Work mirror update. The
Assignment and Authorization records are bound separately by their exact
paths and hashes; this executor receipt intentionally does not include a
self-hash.

| Governance record | SHA-256 |
|---|---|
| `docs/assignments/typo-correction-002-f01-remediation-001.md` | `8d51651058fa4b4dab58ba779d8f614d8e295cff187442ff13882aa23a6ef09a` |
| `docs/authorizations/AUTH-TYPO-CORRECTION-002-F01-REMEDIATION-001.md` | `cb16ebbc6bc2f5e9db0922f1e7450adf9010d9c66814afff7bc7bc73538ee926` |

## Implementation result

1. Added `RimeDeploymentIdentity.normalizedVersion(from:)` at the production
   RIME bridge boundary. It trims bounded whitespace, rejects nil/blank values,
   and rejects the bridge sentinels `(no api)` and `(unknown)` case-insensitively.
2. The production `RimeDeploymentService` now forwards only a usable identity
   and cannot report full-check success when the identity is unavailable.
3. `SchemaManager` applies the same fail-closed normalization before setting
   `rime_deployed`, so an injected or future service result cannot bypass the
   Main-App deployment gate.
4. Added direct coverage for nil, blank/whitespace, both sentinels, valid-version
   trimming, and service-level negative forwarding. Added Main-App regression
   coverage for both sentinels remaining pending.

No Objective-C vendor source, RIME schema, user dictionary, archive, fixture, or
typo-correction path was changed.

## Validation matrix

All commands ran from the remediation worktree. iOS Simulator commands used
iPhone 17 Pro Max, iOS 27.0, UDID
`06C5BC3E-7599-4761-A1A2-71DAEA991474`, with separate DerivedData directories.

| Run ID | Command / environment | Result |
|---|---|---|
| `TC2-F01-REM-20260918-2218-KCORE-01` | `swift test --package-path Packages/KeyboardCore` | Pass — 1125 tests, 0 failures |
| `TC2-F01-REM-20260918-2220-RIME-01` | `xcodebuild ... -scheme RimeBridgeTests ... -destination id=06C5BC3E-7599-4761-A1A2-71DAEA991474 ... test` | Pass — 103 tests, 20 existing conditional skips, 0 failures. Result bundle: `/private/tmp/universe-keyboard-typo-correction-002-f01-remediation-001-derived-rime/Logs/Test/Test-RimeBridgeTests-2026.09.18_22-20-44-+0800.xcresult` |
| `TC2-F01-REM-20260918-2221-APP-01` | `xcodebuild ... -scheme Universe Keyboard ... -destination id=06C5BC3E-7599-4761-A1A2-71DAEA991474 ... test` | Pass — `UniverseKeyboardTests` 377 tests / 9 existing conditional skips / 0 failures; `KeyboardTests` 11 tests / 0 failures. Result bundle: `/private/tmp/universe-keyboard-typo-correction-002-f01-remediation-001-derived-app/Logs/Test/Test-Universe Keyboard-2026.09.18_22-21-19-+0800.xcresult` |
| `TC2-F01-REM-20260918-2223-REL-01` | `xcodebuild ... -scheme Universe Keyboard -configuration Release ... -destination id=06C5BC3E-7599-4761-A1A2-71DAEA991474 ... build` | Pass — `** BUILD SUCCEEDED **` |
| `TC2-F01-REM-20260918-2218-FMT-01` | `xcrun swift-format format --in-place --configuration .swift-format` and `lint --strict` on all four Swift files | Pass |

The first attempted `iPhone 17 Pro` destination was unavailable on iOS 27.0;
that attempt stopped before compilation. The successful runs are bound to the
listed iPhone 17 Pro Max UDID. The initial SwiftPM sandbox/cache attempts also
stopped before test execution; the successful run used the isolated cache path
and approved local build environment.

## Independent-review handoff

The candidate is ready for a fresh independent Architecture/Quality review of
this bounded F-01 slice only. Reviewers must inspect the exact uncommitted
candidate binding above, or a separately authorized commit if one is created;
the prior `409eeab` receipts must not be relabeled for this candidate.

This receipt does not assert that F-01 is accepted, that the parent Assignment
is complete, or that any Product/Quality/Release Gate is closed.
