# RIME-BUILTIN-LUNA-QUALITY-001 — Active Implementation Evidence

## Evidence Header

| Field | Value |
|---|---|
| Date | `2026-08-30 Asia/Shanghai` |
| Evidence level | `Executor-recorded` local implementation evidence |
| Initial implementation commit | `09659a70b6afa94dad16e9d45921ba3154a9fd57` |
| Findings-remediation commit | `1755006553037ab72fd175f65c2f9edfe62fc0a1` |
| Review-conditions remediation commit | `85d0249d959803134a37c4a6f4442bf8d0cfe4b2` |
| Final atomicity/quality remediation commit | `fa5dbaf1fded3e25ac39a6c0c675cddc786f01bb` |
| Provenance implementation / Q-09 pin / normalized receipt | `6cb2fee90e9b0b7d603625b2bf9bca6798ae310e` / `3a9ce19c3303e639c78547dc7ce15eea51003336` / `7260ca292fb8226face92781cb1c335ad0f31d1b` |
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
- `RimeBuiltin.manifest.json` format v3 pins source repositories/revisions and
  20 exact source-input hashes, generator/toolchain versions and hashes,
  normalized replayable command arguments, host identity, explicit
  `payload-tree-excluding-manifest` digest scope, and each packaged entry.
  Generation ID is `luna-official-2026-08-31-v3`; manifest-file SHA-256 is
  `6aa2d28918b9146cdf417ddb369ba57907e5bbcc3e2ce2c9bc1280f1a6e7b233`
  (`13,582` bytes).
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
- Immutable resources and dynamic overlays now commit in one production
  recovery boundary. Overlay replacement stages and backs up the complete new
  artifact set plus its prior receipt; if overlay replacement or receipt
  creation fails, its rollback restores the prior overlay generation before
  the outer installer restores the prior immutable generation and receipt.
  Process-death atomicity remains the existing ADR 0006 / TD-001 residual
  rather than an F-02 overclaim.
- Keyboard Extension runtime directory resolution now requires a matching
  immutable-resource receipt plus generation-bound overlay receipt and hashes.
  It deliberately avoids hashing the complete 34 MB closure on keyboard
  startup; full closure validation remains main-App owned.
- Receipt-gated runtime quality smoke fails on wrong Top-1 results for `ni`,
  `nihao`, `sanjiaoxing`, `jintiantianqihenhao` and `fanti`; it verifies the
  exact first candidate page for every one of those vectors and Stroke reverse
  lookup, with the configuration-specific `sanjiaoxing` order frozen
  separately for fuzzy pinyin off and on.
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
| Production-sequence atomic rollback focus | iPhone 17 Pro Max Simulator, iOS 27.0 (`24A5423a`) | installer suite 17/17 passed, including overlay failure after a new immutable generation has been installed and complete restoration of the previous resource receipt, overlay receipt, 26 base files and overlays; `/tmp/f02-derived-rime-atomic-focus/Logs/Test/Test-RimeBridgeTests-2026.08.30_23-36-06-+0800.xcresult` |
| RimeBridgeTests | iPhone 17 Pro Max Simulator, iOS 27.0 (`24A5423a`) | 87 total; 67 passed, 20 existing skips, 0 failures; `/tmp/f02-derived-rime-full-final/Logs/Test/` final result at `2026-08-30 23:44 Asia/Shanghai` |
| Actual-bundle Luna closure integration | iPhone 17 Pro Max Simulator, iOS 27.0 (`24A5423a`) | 1 focused test, 0 failures; internally four clean deployments and exact complete first-page order for `ni`, `nihao`, `sanjiaoxing`, representative sentence, `fanti` and Stroke, plus post-Stroke pinyin isolation and four direct OpenCC vectors; `/tmp/f02-derived-app-strict-final/Logs/Test/Test-Universe Keyboard-2026.08.30_23-44-04-+0800.xcresult` |
| Deployment-related App focus | iPhone 17 Pro Max Simulator, iOS 27.0 (`24A5423a`) | SchemaManager + RimeSettingsStore 93/93 passed; `/tmp/f02-derived-app-strict-final/Logs/Test/Test-Universe Keyboard-2026.08.30_23-45-31-+0800.xcresult` |
| App + Keyboard aggregate | iPhone 17 Pro Max Simulator, iOS 27.0 (`24A5423a`) | `PASS`; 255 total, 252 passed, 3 physical-device-only skips, 0 failures; `/tmp/f02-derived-app-aggregate-final/Logs/Test/` final result at `2026-08-30 23:47 Asia/Shanghai` |
| Debug build | iPhone 17 Pro Max Simulator, iOS 27.0 | `BUILD SUCCEEDED`; `/tmp/f02-derived-debug-build-final` |
| Release build | iPhone 17 Pro Max Simulator, iOS 27.0 | `BUILD SUCCEEDED`; `/tmp/f02-derived-release-build-final` |

The unsigned Simulator still emits
`container_create_or_lookup_app_group_path_by_app_group_identifier: client is not entitled`
as an environment warning. It did not produce a failure in the final full
aggregate and therefore is recorded separately from the 255-test green result;
neither result is used as physical-device App Group evidence.

## Reviewer-condition disposition before final re-review

| Condition | Owner / disposition | Executor evidence for independent re-check |
|---|---|---|
| `F02-OVL-ATOMIC` | RIME Platform Maintainer / `fix` | closed in `fa5dbaf` by the nested production recovery boundary and full previous-generation rollback test |
| `F02-QUALITY-FIRSTPAGE` / `F02-Q02-REPORDER-001` | RIME Platform Maintainer + Quality / `fix` | closed in `fa5dbaf` by exact complete first-page assertions for all frozen vectors, twice per fuzzy configuration |
| `F02-Q10-AGG-001` | Executor + Quality / `fix` | final App aggregate is 255 total, 252 passed, 3 physical-only skips, 0 failures |
| ADR 0006 / `TD-001` process-death recovery | Architecture owner / `track` | remains outside F-02 synchronous-failure claim; no process-death atomicity is asserted |
| Physical-device / Full Access / lifecycle / performance / archive / hosted CI | Human Dependency + named gate owners / `fix before Exit` | still pending; no device handoff until final independent reviewers permit it |

## Q-01–Q-10 Disposition

| Gate | Current disposition | Remaining closure requirement |
|---|---|---|
| Q-01 offline/App-only closure | `PARTIAL PASS` | bundle/Extension/isolated-container automation passed; physical fresh App Group plus airplane-mode first deployment remains Human evidence |
| Q-02 normal candidate quality | `PARTIAL PASS` | automated exact complete first-page order for all frozen defect/representative vectors and fuzzy off/on passed across four clean deployments; true process cold starts and physical-device repetition remain pending |
| Q-03 OpenCC four outputs | `LOCAL PASS` | exact linked OpenCC passed s2t, t2s, t2hk and t2tw behavior vectors; physical release-candidate evidence remains pending |
| Q-04 Stroke reverse lookup | `PARTIAL PASS` | pinned full first-page reverse lookup vector and same-session return to ordinary pinyin passed in simulator; physical Full Access off/on and Extension lifecycle remain pending |
| Q-05 reproducibility | `LOCAL PASS` | two clean payload-tree digests, exact source-input/toolchain receipts, normalized replayable generator commands and strict template/digest-scope validation passed; independent re-review and hosted clean-checkout repetition remain pending |
| Q-06 fail-closed / last-good | `LOCAL PARTIAL PASS` | corrupt prior receipt, hidden/nested/lowercase-text extras, deployed tamper, overlay identity, all 26 switch interruption points and a production-sequence overlay failure restore the complete previous generation; Extension authorization is receipt-gated; process-death atomicity and physical Extension consumption remain pending |
| Q-07 performance / size | `PENDING` | simulator allocated sizes and one integration duration are recorded but do not satisfy release-like physical samples, delta, median/worst or Product budget acceptance |
| Q-08 Full Access / lifecycle | `PENDING` | named physical iPhone 13 Pro / iOS 27 matrix with exact commit/build is required |
| Q-09 license / attribution | `ENGINEERING PASS; HUMAN PENDING` | Luna/Essay/Prelude/Stroke/OpenCC offline documents are mapped and bundled; OpenCC AUTHORS exactly matches the accepted 277-byte upstream pin and hash. Human/legal sufficiency remains a separate decision. |
| Q-10 CI / release reproducibility | `LOCAL PASS` | on the latest remediation chain: format/diff checks, KeyboardCore 1,068/1,068, RimeBridge 93 total with 20 existing conditional skips, App + Keyboard 256 total with 3 physical-only skips, and Debug/Release builds pass; hosted CI, exact archive and independent Quality sign-off remain pending |

## Provenance and Q-09 closure checkpoint — 2026-08-31

| Item | Bound result |
|---|---|
| Runtime payload | All 26 runtime resource files remain byte-identical to the previously reviewed closure; only the manifest receipt changed. |
| Source/generator receipt | Manifest v3 records five pinned repositories, 20 source inputs, six toolchain entries, generator identity, normalized command templates and exact entry hashes. Runtime validation rejects missing/tampered source inputs, tools, commands, digest scope and directly packaged source hashes. |
| Reproducibility boundary | Both clean runs produced payload-tree SHA-256 `18642376d67f9bc74b42988262a2ce7815bee59a36b51dc0388006bc01c0adeb`; `digestScope` explicitly excludes the receipt manifest itself. |
| OpenCC inventory | `OPENCC-Apache-2.0.txt` and `OPENCC-AUTHORS.txt` are both required by the catalog. AUTHORS is 277 bytes with SHA-256 `cb34e252fa994679bcbfc8355581e821ceda44bd857875e2cfe15b7ec4eec006`, exactly matching the accepted upstream pin. |
| Focused evidence | Installer provenance 23/23: `/tmp/f02-derived-provenance-normalized/Logs/Test/Test-RimeBridgeTests-2026.08.31_10-55-07-+0800.xcresult`; license bundle 2/2: `/tmp/f02-derived-q09-exact/Logs/Test/Test-Universe Keyboard-2026.08.31_10-50-08-+0800.xcresult`. |
| Full affected gates | RimeBridge 93 total / 20 existing skips / 0 failures: `/tmp/f02-derived-final-rime/Logs/Test/Test-RimeBridgeTests-2026.08.31_10-55-46-+0800.xcresult`; App 245 total / 3 physical-only skips plus Keyboard 11/11, 0 failures: `/tmp/f02-derived-final-app/Logs/Test/Test-Universe Keyboard-2026.08.31_10-56-17-+0800.xcresult`; Debug and Release builds succeeded under `/tmp/f02-derived-final-debug` and `/tmp/f02-derived-final-release`. |
| Non-claim | Human/legal sufficiency, hosted CI, archive, physical device, install, Product Gate, merge, TestFlight and Release remain pending/unauthorized. |

Independent Architecture and Quality re-review of exact evidence HEAD
`bb43c5f` both returned `Pass with conditions`, with no P0/P1. Architecture
accepted `F02-A-P2-PROVENANCE-001` and the old-candidate supersede; Quality
closed engineering Q-09/inventory while retaining Human/legal sufficiency as
P2 pending. Both permit preparation of a clean replacement signed candidate,
not installation or physical execution.

## Stop / Handoff

Implementation chain through `7260ca292fb8226face92781cb1c335ad0f31d1b` plus
this evidence checkpoint is ready for independent Architecture and Quality
re-review, not Assignment Exit. The former `d4572d9` signed candidate is
superseded. A replacement may be frozen only after the review findings are
resolved; installation and the named physical-device matrix still require
Human authorization. No merge, TestFlight upload or release action is
authorized by this record.

## Final independent re-review and handoff — 2026-08-31

Architecture and Quality independently returned `Pass with conditions` for
implementation `fa5dbaf1fded3e25ac39a6c0c675cddc786f01bb` and evidence
`786f4c720949784f4f66515228778bf6a012b952`; both reported no P0/P1 and permit
preparation of an exact installable build plus physical-device matrix. Their
full residual dispositions are recorded in the bound review documents.

Architecture's lifecycle-document drift finding is closed by synchronizing the
shared-container document with the implemented bounded resource/overlay receipt
authorization. Complete generator provenance remains `fix`, and process-death
whole-tree atomicity remains `tech_debt:TD-001`.

The [physical-device handoff packet](rime-builtin-luna-quality-f02-device-handoff-2026-08-31.md)
retains the old `d4572d93bb9da269cb68051c941099a1e1dec808` identity only as
historical evidence. Manifest/runtime validation changed afterward, so that
candidate is superseded and must not be installed. A replacement candidate is
not yet frozen.

The handoff remains explicitly `HOLD` before installation: installed receipt,
Human device authorization and all physical observations are absent. Assignment
Exit, PR, merge, TestFlight and Release remain unauthorized.
