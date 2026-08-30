# RIME-BUILTIN-LUNA-QUALITY-001 — Active Implementation Evidence

## Evidence Header

| Field | Value |
|---|---|
| Date | `2026-08-30 Asia/Shanghai` |
| Evidence level | `Executor-recorded` local implementation evidence |
| Initial implementation commit | `09659a70b6afa94dad16e9d45921ba3154a9fd57` |
| Findings-remediation commit | `1755006553037ab72fd175f65c2f9edfe62fc0a1` |
| Review-conditions remediation commit | `85d0249d959803134a37c4a6f4442bf8d0cfe4b2` |
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
  paths and recursively rejects missing, extra, nested, ambiguous,
  non-regular, wrong-size or wrong-hash runtime members, including lowercase
  `.txt` resources, before App Group mutation. Uppercase notice `.txt` files
  remain outside the immutable runtime closure.
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
- Dynamic overlay replacement stages and backs up the complete new artifact
  set plus its prior receipt. A normal write/replace/receipt failure restores
  the coherent previous files and receipt; process-death atomicity remains the
  existing ADR 0006 / TD-001 residual rather than an F-02 overclaim.
- Receipt-gated runtime quality smoke fails on wrong Top-1 results for `ni`,
  `nihao`, `sanjiaoxing`, `jintiantianqihenhao` and `fanti`; it also verifies
  the exact first candidate page for `ni`, `nihao` and Stroke reverse lookup.
  After Stroke, the same session must return to the ordinary `ni` first page.
  The actual-bundle integration repeats two clean deployments with fuzzy
  pinyin off and two with it on, and directly exercises the linked OpenCC
  implementation for s2t, t2s, t2hk and t2tw.

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
| KeyboardCore | macOS SwiftPM | `1,068` tests, 0 failures; final run completed `2026-08-30 19:27 Asia/Shanghai` |
| Installer fault/identity focus | iPhone 17 Pro Max Simulator, iOS 27.0 (`24A5423a`) | `1` focused suite, 0 failures; includes 26 switch-point rollback matrix; `/tmp/f02-derived-rime-focus/Logs/Test/Test-RimeBridgeTests-2026.08.30_14-45-05-+0800.xcresult` |
| RimeBridgeTests | iPhone 17 Pro Max Simulator, iOS 27.0 (`24A5423a`) | 86 total; 66 passed, 20 existing skips, 0 failures; `/tmp/f02-derived-rime-full-final/Logs/Test/Test-RimeBridgeTests-2026.08.30_19-24-20-+0800.xcresult` |
| Actual-bundle Luna closure integration | iPhone 17 Pro Max Simulator, iOS 27.0 (`24A5423a`) | 1 focused test, 0 failures; internally four clean deployments, exact `ni`/`nihao`/Stroke first-page order, post-Stroke pinyin isolation, representative vectors and four direct OpenCC vectors; `/tmp/f02-derived-app-final-order/Logs/Test/Test-Universe Keyboard-2026.08.30_19-23-27-+0800.xcresult` |
| App + Keyboard aggregate | iPhone 17 Pro Max Simulator, iOS 27.0 (`24A5423a`) | `BLOCKED`, not pass. The original full run stopped after 80 passes in the named NineKey async test. A diagnostic rerun explicitly skipped only that case and still produced 254 total: 236 passed, 3 skipped, 15 failed; all listed failures followed `container_create_or_lookup_app_group_path_by_app_group_identifier: client is not entitled`, and one RimeSettingsStore test crashed/restarted the runner. `/tmp/f02-derived-app-minus-known-blocker/Logs/Test/Test-Universe Keyboard-2026.08.30_19-26-50-+0800.xcresult` |
| Debug build | iPhone 17 Pro Max Simulator, iOS 27.0 | `BUILD SUCCEEDED`; `/tmp/f02-derived-build-debug-final` |
| Release build | iPhone 17 Pro Max Simulator, iOS 27.0 | `BUILD SUCCEEDED`; `/tmp/f02-derived-build-release-final` |

The App aggregate is intentionally not reported green. The second run proves
the blocker is broader than one NineKey case: simulator tests which expect the
real App Group deployment path fail before their injected deployment service is
called when the unsigned test host cannot resolve the App Group. This is a
test-environment/dependency-seam blocker shared by NineKey, SchemaManager and
RimeSettingsStore paths; it is not evidence that the focused Luna runtime
closure failed. F-02 does not modify those unrelated ownership paths merely to
manufacture a green aggregate. A separate scoped owner decision is required if
the App aggregate infrastructure is to be repaired.

## Q-01–Q-10 Disposition

| Gate | Current disposition | Remaining closure requirement |
|---|---|---|
| Q-01 offline/App-only closure | `PARTIAL PASS` | bundle/Extension/isolated-container automation passed; physical fresh App Group plus airplane-mode first deployment remains Human evidence |
| Q-02 normal candidate quality | `PARTIAL PASS` | automated exact first-page order for `ni` / `nihao`, Top-1 for the three defect vectors, representative sentence/common conversion term and fuzzy off/on passed across four clean deployments; true process cold starts and physical-device repetition remain pending |
| Q-03 OpenCC four outputs | `LOCAL PASS` | exact linked OpenCC passed s2t, t2s, t2hk and t2tw behavior vectors; physical release-candidate evidence remains pending |
| Q-04 Stroke reverse lookup | `PARTIAL PASS` | pinned full first-page reverse lookup vector and same-session return to ordinary pinyin passed in simulator; physical Full Access off/on and Extension lifecycle remain pending |
| Q-05 reproducibility | `LOCAL PASS` | two clean output-tree digests, exact generator hash/host/command and bundle/deployed identity passed; independent reviewer and hosted clean-checkout repetition remain pending |
| Q-06 fail-closed / last-good | `LOCAL PARTIAL PASS` | corrupt prior receipt, hidden/nested/lowercase-text extras, deployed tamper, overlay identity, overlay write rollback and all 26 switch interruption points fail closed with last-good restoration; process-death atomicity and device Extension consumption remain pending |
| Q-07 performance / size | `PENDING` | simulator allocated sizes and one integration duration are recorded but do not satisfy release-like physical samples, delta, median/worst or Product budget acceptance |
| Q-08 Full Access / lifecycle | `PENDING` | named physical iPhone 13 Pro / iOS 27 matrix with exact commit/build is required |
| Q-09 license / attribution | `ENGINEERING PARTIAL PASS` | offline files and catalog entries are implemented; independent inventory review and Human/legal sufficiency decision remain pending |
| Q-10 CI / release reproducibility | `BLOCKED` | format, KeyboardCore, full RimeBridge, focused actual-bundle integration and Debug/Release builds pass; full App aggregate is blocked by the named existing NineKey async test; hosted CI, exact archive and independent Quality sign-off remain pending |

## Stop / Handoff

Commit `85d0249d959803134a37c4a6f4442bf8d0cfe4b2` is ready for independent
Architecture and Quality re-review, not Assignment Exit. Reviewers must judge
the explicit aggregate-test blocker rather than treating focused green evidence
as a full gate. The next human dependency is a named physical-device matrix
only after review findings are resolved and an exact installable build is
prepared. No merge, TestFlight upload or release action is authorized by this
record.
