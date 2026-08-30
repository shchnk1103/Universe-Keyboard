# RIME-BUILTIN-LUNA-QUALITY-001 — Active Implementation Evidence

## Evidence Header

| Field | Value |
|---|---|
| Date | `2026-08-30 Asia/Shanghai` |
| Evidence level | `Executor-recorded` local implementation evidence |
| Initial implementation commit | `09659a70b6afa94dad16e9d45921ba3154a9fd57` |
| Findings-remediation commit | `1755006553037ab72fd175f65c2f9edfe62fc0a1` |
| Branch / worktree | `codex/f02-rime-builtin-quality-assignment` / `/tmp/universe-keyboard-f02-assignment` |
| Base governance commit | `83626fd` |
| Xcode / Swift | Xcode `27.0 (27A5252f)`; Apple Swift `6.4` |
| Representative runtime | iPhone 17 Pro Max Simulator, iOS `27.0 (24A5423a)`, arm64 |
| Deployment target observed in build | `arm64-apple-ios18.0-simulator` |
| Explicit exclusions | PR #91, Octagram model, third-party scheme behavior, merge, TestFlight and Release |

This record binds local evidence to the implementation commit above. It does
not replace independent review, hosted CI, physical-device evidence or the
Human Product Gate.

## Implemented Boundary

- The main App is the sole packaged owner of the immutable built-in closure.
  The Keyboard Extension no longer carries the old Luna/OpenCC resource copy.
- The closure contains 26 manifest entries and 34,104,314 payload bytes:
  official Luna, Essay, Prelude, Stroke, four OpenCC profiles, six OpenCC data
  artifacts and six generated RIME artifacts. No `.gram` is present.
- `RimeBuiltin.manifest.json` format v2 pins source revisions, generator
  identity and SHA-256, logical path, role, byte count and SHA-256. Generation
  ID is `luna-official-2026-08-30-v2`; manifest-file SHA-256 is
  `1715dc212b2f5190ac71563523ce93e953cb7bdb2ff8704a65b9956d2c47b8cf`.
- The generator performs two clean RIME/OpenCC generations, records the exact
  host and command, and requires both clean output-tree digests to equal
  `18642376d67f9bc74b42988262a2ce7815bee59a36b51dc0388006bc01c0adeb`
  before replacing the checked-in closure.
- Bundle validation reconstructs Xcode's flattened resources into logical
  paths and rejects missing, extra, ambiguous, non-regular, wrong-size or
  wrong-hash members before App Group mutation.
- Installation validates any prior receipt before it can authorize stale-path
  removal, stages the new generation, backs up only the immutable built-in
  paths, switches the built-in set transactionally, verifies final deployed
  bytes, then writes the resource receipt. A failed switch or rollback is
  reported explicitly rather than hidden by `try?`.
- Official Luna source remains unchanged. Universe behavior is a thin custom
  overlay for schema registration, simplification and managed fuzzy algebra.
- A separate overlay receipt binds both required Universe custom YAML files to
  the resource generation and manifest hash. Luna runtime smoke fails closed
  when either immutable-resource or overlay identity is absent or tampered.
- Receipt-gated runtime quality smoke fails on wrong Top-1 results for `ni`,
  `nihao`, `sanjiaoxing`, `jintiantianqihenhao` and `fanti`; it also verifies
  Stroke reverse lookup. The actual-bundle integration repeats two clean
  deployments with fuzzy pinyin off and two with it on, and directly exercises
  the linked OpenCC implementation for s2t, t2s, t2hk and t2tw.

## Resource And Artifact Receipts

| Check | Result | Exact evidence |
|---|---|---|
| Deterministic generation | `PASS` | `bash scripts/generate_builtin_rime_resources.sh /tmp/f02-rime-upstream.5ywEHF`; internal two-directory byte comparisons passed |
| Vendor inventory | `PASS` | `bash scripts/ensure_rime_vendor.sh verify`; 12 framework artifacts verified |
| Source closure vs manifest | `PASS` | all 26 files matched `byteCount` and SHA-256 |
| Release App vs manifest | `PASS` | all 26 flattened App files matched the same manifest bytes and SHA-256 |
| Extension duplicate scan | `PASS` | 0 Luna/Essay/Stroke/OpenCC/RIME-bin matches in `Keyboard.appex` |
| Release allocated size | `RECORDED` | App `67,608 KiB`; embedded `Keyboard.appex` `11,580 KiB` |
| Size delta / IPA size | `PENDING` | no accepted before/after archive pair; simulator filesystem size is not an IPA delta |

## Local Verification

| Gate | Destination / result | Evidence |
|---|---|---|
| Strict Swift format | all changed and new Swift files | `PASS`; no diagnostics |
| Diff whitespace | `git diff --check` | `PASS` |
| KeyboardCore | macOS SwiftPM | `1,068` tests, 0 failures |
| Installer fault/identity focus | iPhone 17 Pro Max Simulator, iOS 27.0 (`24A5423a`) | `1` focused suite, 0 failures; includes 26 switch-point rollback matrix; `/tmp/f02-derived-rime-focus/Logs/Test/Test-RimeBridgeTests-2026.08.30_14-45-05-+0800.xcresult` |
| RimeBridgeTests | iPhone 17 Pro Max Simulator, iOS 27.0 (`24A5423a`) | 83 total; 63 passed, 20 existing skips, 0 failures; `/tmp/f02-derived-rime-full-green/Logs/Test/Test-RimeBridgeTests-2026.08.30_14-47-49-+0800.xcresult` |
| Actual-bundle Luna closure integration | iPhone 17 Pro Max Simulator, iOS 27.0 (`24A5423a`) | 1 focused test, 0 failures; internally four clean deployments, six candidate/reverse vectors and four direct OpenCC vectors; `/tmp/f02-derived-app-remediation/Logs/Test/Test-Universe Keyboard-2026.08.30_14-27-34-+0800.xcresult` |
| App + Keyboard full suite | iPhone 17 Pro Max Simulator, iOS 27.0 (`24A5423a`) | `BLOCKED`, not pass: after 80 passed tests, existing `NineKeyEnableTransactionTests.testCancellingDownloadWaitingForNineKeyLeaseCannotCommitAfterRelease` waited indefinitely with simulator App Group entitlement failure; run was interrupted after 852.710 s; `/tmp/f02-derived-app-full-green/Logs/Test/Test-Universe Keyboard-2026.08.30_14-48-50-+0800.xcresult` |
| Debug build | iPhone 17 Pro Max Simulator, iOS 27.0 | `BUILD SUCCEEDED`; `/tmp/f02-derived-app-build-debug` |
| Release build | iPhone 17 Pro Max Simulator, iOS 27.0 | `BUILD SUCCEEDED`; `/tmp/f02-derived-app-build-release` |

The current findings-remediation full App suite is intentionally not reported
green. Its exact blocking test predates and is outside the F-02 implementation
boundary; the run log ends immediately after
`container_create_or_lookup_app_group_path_by_app_group_identifier: client is
not entitled`, while XCTest waits on that test's asynchronous expectation. F-02
does not modify the unrelated NineKey transaction implementation to manufacture
a green aggregate. The earlier `09659a7` full-suite result remains historical
evidence for that commit only and is not substituted for the current commit.

## Q-01–Q-10 Disposition

| Gate | Current disposition | Remaining closure requirement |
|---|---|---|
| Q-01 offline/App-only closure | `PARTIAL PASS` | bundle/Extension/isolated-container automation passed; physical fresh App Group plus airplane-mode first deployment remains Human evidence |
| Q-02 normal candidate quality | `PARTIAL PASS` | automated Top-1 and fuzzy off/on passed for the three defect vectors plus a representative sentence and common conversion term across four clean deployments; physical-device repetition remains pending |
| Q-03 OpenCC four outputs | `LOCAL PASS` | exact linked OpenCC passed s2t, t2s, t2hk and t2tw behavior vectors; physical release-candidate evidence remains pending |
| Q-04 Stroke reverse lookup | `PARTIAL PASS` | pinned reverse lookup vector passed in simulator; physical Full Access off/on and Extension lifecycle remain pending |
| Q-05 reproducibility | `LOCAL PASS` | two clean output-tree digests, exact generator hash/host/command and bundle/deployed identity passed; independent reviewer and hosted clean-checkout repetition remain pending |
| Q-06 fail-closed / last-good | `LOCAL PARTIAL PASS` | corrupt prior receipt, hidden extras, deployed tamper, overlay identity and all 26 switch interruption points fail closed with last-good restoration; device Extension consumption remains pending |
| Q-07 performance / size | `PENDING` | simulator allocated sizes and one integration duration are recorded but do not satisfy release-like physical samples, delta, median/worst or Product budget acceptance |
| Q-08 Full Access / lifecycle | `PENDING` | named physical iPhone 13 Pro / iOS 27 matrix with exact commit/build is required |
| Q-09 license / attribution | `ENGINEERING PARTIAL PASS` | offline files and catalog entries are implemented; independent inventory review and Human/legal sufficiency decision remain pending |
| Q-10 CI / release reproducibility | `BLOCKED` | format, KeyboardCore, full RimeBridge, focused actual-bundle integration and Debug/Release builds pass; full App aggregate is blocked by the named existing NineKey async test; hosted CI, exact archive and independent Quality sign-off remain pending |

## Stop / Handoff

Commit `1755006553037ab72fd175f65c2f9edfe62fc0a1` is ready for independent
Architecture and Quality re-review, not Assignment Exit. Reviewers must judge
the explicit aggregate-test blocker rather than treating focused green evidence
as a full gate. The next human dependency is a named physical-device matrix
only after review findings are resolved and an exact installable build is
prepared. No merge, TestFlight upload or release action is authorized by this
record.
