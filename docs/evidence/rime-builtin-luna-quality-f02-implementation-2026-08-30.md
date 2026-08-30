# RIME-BUILTIN-LUNA-QUALITY-001 — Active Implementation Evidence

## Evidence Header

| Field | Value |
|---|---|
| Date | `2026-08-30 Asia/Shanghai` |
| Evidence level | `Executor-recorded` local implementation evidence |
| Implementation commit | `09659a70b6afa94dad16e9d45921ba3154a9fd57` |
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
- `RimeBuiltin.manifest.json` pins source revisions, generator identity, logical
  path, role, byte count and SHA-256. Generation ID is
  `luna-official-2026-08-29-v1`; manifest SHA-256 is
  `93197b92e01c2c93e3bb4919f9eb8a644e12120ee9e3bb3e641ed917dc581a6f`.
- The generator performs two clean RIME generations and two clean OpenCC
  generations, then byte-compares the outputs before replacing the checked-in
  closure.
- Bundle validation reconstructs Xcode's flattened resources into logical
  paths and rejects missing, extra, ambiguous, non-regular, wrong-size or
  wrong-hash members before App Group mutation.
- Installation stages the new generation, backs up only the immutable built-in
  paths, preserves user and third-party files, switches the built-in set, writes
  a receipt, and rolls back on a failed switch.
- Official Luna source remains unchanged. Universe behavior is a thin custom
  overlay for schema registration, simplification and managed fuzzy algebra.
- Receipt-gated runtime quality smoke fails on wrong Top-1 results for `ni`,
  `nihao` and `sanjiaoxing`; it also exercises bundled t2s OpenCC and Stroke
  reverse lookup. The integration test repeats deployment with fuzzy pinyin off
  and on against the actual App bundle and pinned iOS librime.

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
| RimeBridgeTests | iPhone 17 Pro Simulator, iOS 26.0 | 75 total; 55 passed, 20 existing skips, 0 failures; `/tmp/f02-derived-rime/Logs/Test/Test-RimeBridgeTests-2026.08.30_08-32-39-+0800.xcresult` |
| Actual-bundle Luna closure integration | iPhone 17 Pro Max Simulator, iOS 27.0 | focused test passed for fuzzy off/on; 1 test, 0 failures, 1.334 s; `/tmp/f02-derived-app-integration/Logs/Test/Test-Universe Keyboard-2026.08.30_08-46-05-+0800.xcresult` |
| App + Keyboard full suite | iPhone 17 Pro Max Simulator, iOS 27.0 | 255 total; 252 passed, 3 existing skips, 0 failures; `/tmp/f02-derived-app-full/Logs/Test/Test-Universe Keyboard-2026.08.30_08-52-44-+0800.xcresult` |
| Debug build | iPhone 17 Pro Max Simulator, iOS 27.0 | `BUILD SUCCEEDED`; `/tmp/f02-derived-build-debug` |
| Release build | iPhone 17 Pro Max Simulator, iOS 27.0 | `BUILD SUCCEEDED`; `/tmp/f02-derived-build-release` |

The first attempt to start the final full suite from the restricted sandbox
lost its CoreSimulator connection and could not write SwiftPM caches. The same
command was rerun with host CoreSimulator access and passed. This is environment
evidence, not a product test failure. iOS 27 beta also emitted IOHID and unsigned
simulator App Group entitlement messages; no test failed and these messages are
not treated as device evidence.

## Q-01–Q-10 Disposition

| Gate | Current disposition | Remaining closure requirement |
|---|---|---|
| Q-01 offline/App-only closure | `PARTIAL PASS` | bundle/Extension/isolated-container automation passed; physical fresh App Group plus airplane-mode first deployment remains Human evidence |
| Q-02 normal candidate quality | `PARTIAL PASS` | automated Top-1 and fuzzy off/on passed for the three defect vectors; reviewed representative sentence set and physical-device repetition remain pending |
| Q-03 OpenCC four outputs | `PARTIAL PASS` | t2s runtime and all profile files/hashes passed; s2t/t2hk/t2tw behavior vectors remain pending |
| Q-04 Stroke reverse lookup | `PARTIAL PASS` | pinned reverse lookup vector passed in simulator; physical Full Access off/on and Extension lifecycle remain pending |
| Q-05 reproducibility | `LOCAL PASS` | double-generation and byte identity passed; independent reviewer and hosted clean-checkout repetition remain pending |
| Q-06 fail-closed / last-good | `PARTIAL PASS` | installer unit faults cover membership/hash/staging/rollback boundaries; device Extension consumption of last-good at every frozen interruption point remains pending |
| Q-07 performance / size | `PENDING` | simulator allocated sizes and one integration duration are recorded but do not satisfy release-like physical samples, delta, median/worst or Product budget acceptance |
| Q-08 Full Access / lifecycle | `PENDING` | named physical iPhone 13 Pro / iOS 27 matrix with exact commit/build is required |
| Q-09 license / attribution | `ENGINEERING PARTIAL PASS` | offline files and catalog entries are implemented; independent inventory review and Human/legal sufficiency decision remain pending |
| Q-10 CI / release reproducibility | `PARTIAL PASS` | local format/tests/builds pass; hosted CI, exact archive and independent Quality sign-off remain pending |

## Stop / Handoff

The implementation is ready for independent Architecture and Quality review,
not Assignment Exit. The next human dependency is a named physical-device
matrix after review findings are resolved and an exact installable build is
prepared. No merge, TestFlight upload or release action is authorized by this
record.
