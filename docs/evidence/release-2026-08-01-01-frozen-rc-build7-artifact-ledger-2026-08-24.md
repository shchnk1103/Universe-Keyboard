# RELEASE-2026-0801-01 — 冻结 RC Build 7 artifact ledger

> **Evidence grade:** `Executor-recorded`
> **Collected:** `2026-08-24 Asia/Shanghai`
> **Frozen source:** `testflight-v1.0-rc1-build7` → `244b32df38cff7ce3d8e56d78a80d4504cc6f073`
> **Cloud build:** `Archive Pilot (No Distribution)` Build 7
> **Assignment:** [`RELEASE-2026-0801-01`](../assignments/release-2026-08-01-01-stable-archive.md)

## Scope and authority

The Human Product Owner separately authorized two actions in the active Codex
task: first, freeze the exact RC identity; second, run one no-distribution Xcode
Cloud Archive for that identity. The annotated tag
`testflight-v1.0-rc1-build7` was created and pushed at exact commit
`244b32df38cff7ce3d8e56d78a80d4504cc6f073`. No TestFlight upload,
distribution, group assignment or Beta Review submission was authorized or
performed.

Build 7 used the existing manual `main`-only workflow `Archive Pilot (No
Distribution)`, whose Distribution Preparation is `None` and which has no
post-actions. The Cloud summary and downloaded artifacts bind the run to commit
`244b32d`; the immutable tag above supplies the full source identity.

## Cloud result

| Check | Result | Grade |
|---|---|---|
| Workflow/action | `Archive - iOS` succeeded | `Executor-recorded` |
| Source identity | Build 7 / `244b32d`; exact tag resolves to `244b32df38cff7ce3d8e56d78a80d4504cc6f073` | `Executor-recorded` |
| Stable toolchain | Xcode `26.6 (17F113)` / macOS Tahoe `26.6.2 (25G83)` | `Executor-recorded` |
| XCResult | action status `succeeded`; build status `succeeded`; top/action/build issue summaries empty | `Executor-recorded` |
| Archive timing | `2026-08-24T04:49:35.449-0700` → `2026-08-24T04:51:29.674-0700` | `Executor-recorded` |
| Destination / SDK | `Any iOS Device`; `iphoneos26.5` | `Executor-recorded` |
| Distribution | No post-action and no upload; TestFlight state was not changed by this run | `Executor-recorded` |

Build record:
[`Xcode Cloud Build 7`](https://appstoreconnect.apple.com/teams/82c0e48e-c8bf-442c-9db9-19ed80ce4d87/apps/6804236252/ci/builds/f4d5e868-d85d-437f-998a-e30300b1c611/summary).

The raw archive log ends with `ARCHIVE SUCCEEDED`. It also contains two
AppIntents metadata-extraction warnings stating that extraction was skipped
because the targets do not link `AppIntents.framework`. The app does not ship
App Intents; these warnings do not alter the App/Keyboard archive, entitlements,
privacy manifests or exported packages. They are retained here rather than
being rewritten as “zero log warnings.”

## Downloaded artifact ledger

The Human Product Owner manually downloaded the following retained artifacts.
Directory hashes below are deterministic SHA-256 hashes of the sorted relative
file-path/SHA-256 manifest; they are not hashes of filesystem metadata.

For reproducibility, from the artifact's parent directory let `name` be the
artifact directory basename, then run:

```bash
find "$name" -type f -print0 \
  | LC_ALL=C sort -z \
  | xargs -0 shasum -a 256 \
  | shasum -a 256
```

The inner stream is the concatenated standard `shasum` output in byte-sorted
path order: lowercase hex digest, two ASCII spaces, path relative to the parent
(including the top-level `name`), and `LF` after every file. The outer digest is
the first field of the last line. Empty directories and filesystem metadata are
intentionally excluded.

| Artifact | Files / bytes | SHA-256 |
|---|---:|---|
| `Universe Keyboard Build 7 Archive for Universe Keyboard on iOS.xcarchive` | `68` / `58,839,040` | manifest `17c4e9782bf119e96edf6581f1c361673dd349d45f0a862d5140164ce06ca19b` |
| `Universe Keyboard Build 7 Logs for Universe Keyboard archive` | `24` / `7,233,536` | manifest `e7a90f1dd4a5622447003f18319722232e20c2244441fa518d55231e37ff5b30` |
| `Universe Keyboard Build 7 XCResult for Universe Keyboard archive.xcresult` | `7` / `77,824` | manifest `29d0c5878200e7aa3ad30709e9c0b30a8a702795c75d8b5fc36f64bb2c24584a` |
| `Universe Keyboard 1.0 app-store` | `4` / `18,808,832` | manifest `69b7bfa0ac88d24c3b268c04967edb00a127da5c3bdf1b61382806a9befa26b2` |
| App Store `Universe Keyboard.ipa` | `18,680,731` bytes | `b9baf3620be8fedd2754ce452edbed7ada0d07b67e44514666be3c8da58984aa` |
| App Store `Packaging.log` / `ExportOptions.plist` / `DistributionSummary.plist` | `118,614` / `666` / `3,286` bytes | `13687be3b970db48126ce4ac228f603916ec6537344b97abcd054fe6bf8ba3a7` / `9cb71a895d54716603151f5c6ce91d6552767b787dd4b5fdef6e11325a32e218` / `513226e3207c991d1a2bd6b6884082f80b1f8199ba0ae1648cd27d91ccfa5092` |
| `Universe Keyboard 1.0 ad-hoc` | `4` / `15,155,200` | manifest `1267b28a58e05181f6ec936234233f70c58d76a31d72d1e8700fcaedde8f8846` |
| Ad hoc `Universe Keyboard.ipa` | `15,031,438` bytes | `c63d3efe649292d36535e74fd20a8fbe7c99bc8757d37bfb9ef9afbcaa4d00f2` |
| Ad hoc `Packaging.log` / `ExportOptions.plist` / `DistributionSummary.plist` | `112,119` / `526` / `3,120` bytes | `92a7d4fbd22da494ac11f7b3361742f6cdea1122cee98226516934a2af3cebad` / `614d51ef69de529a8054236691dfb630c59fb1c442ee3e47b5c4d881c53c5c3d` / `79ec3bbdedf2fca1208a195c05edabcdf6a188e16b320c85e78ce60171847cbf` |

Local paths are under `/Users/doubleshy0n/Downloads/`. They are an operator
working copy, not the sole durable archive. Cloud retention plus this ledger
preserves the retrieval and integrity contract; moving the local downloads does
not change the hashes.

## Archive, dSYM and export mapping

| Item | Result | Grade |
|---|---|---|
| App archive Mach-O UUID | `3AC2D57A-F20A-3B1F-A4C3-37DFA2F619D2` | `Executor-recorded` |
| App dSYM UUID | exact match: `3AC2D57A-F20A-3B1F-A4C3-37DFA2F619D2` | `Executor-recorded` |
| Keyboard archive Mach-O UUID | `08834E19-48AC-3A9C-AE0C-F53EBE94D720` | `Executor-recorded` |
| Keyboard dSYM UUID | exact match: `08834E19-48AC-3A9C-AE0C-F53EBE94D720` | `Executor-recorded` |
| App dSYM DWARF SHA-256 | `d093e1e999c0c4540e28243cb1e5ff7208de16b5515117e00b8cee9b588cf464` | `Executor-recorded` |
| Keyboard dSYM DWARF SHA-256 | `63ed475f2b5b65433513074192b17a400cd34bdb2a29bcfa92e334b4c2fcc3c8` | `Executor-recorded` |
| App Store exported App/Keyboard UUIDs | exact matches to the two archive/dSYM UUIDs above | `Executor-recorded` |
| Ad hoc exported App/Keyboard UUIDs | exact matches to the two archive/dSYM UUIDs above | `Executor-recorded` |

The pre-export `.xcarchive` Info.plists retain source version `1.0 (1)`. Xcode
Cloud export explicitly overrides the build number to `7`; both exported IPAs
therefore contain App and Keyboard version `1.0 (7)`. This is an expected export
transformation, not a source/artifact mismatch.

Both exports are arm64 with minimum iOS `18.0`, Team ID `C33N6HTS9N`, expected
App Group `group.com.DoubleShy0N.Universe-Keyboard`, `get-task-allow = false`,
`ITSAppUsesNonExemptEncryption = false`, and App plus Keyboard
`PrivacyInfo.xcprivacy` files.

## Distribution metadata

The App Store export records:

- method `app-store-connect`;
- build number `7`;
- automatic Cloud signing with Team `C33N6HTS9N`;
- `testFlightInternalTestingOnly = false`;
- `uploadSymbols = true`;
- Cloud Managed Apple Distribution and Store profiles for both bundles;
- `beta-reports-active = true` for App and Keyboard;
- `EXPORT SUCCEEDED`.

Before the successful package export, the retained Store log records that the
Cloud `Session Proxy Provider` could not authenticate an App Store Connect
request used to fetch store configuration. It also reports Apple's deprecated
internal command-line name `app-store`, while the retained Export Options use
the current `app-store-connect` method. Because the export ends with
`EXPORT SUCCEEDED`, this does not invalidate the package. It does mean the
artifact run did not validate the future online upload/authentication path;
that path must be checked only under separate upload authorization.

The ad hoc export records method `release-testing`, build number `7`, automatic
Cloud signing and Ad Hoc profiles. It also ends with `EXPORT SUCCEEDED`. It is
the installable package intended for the named physical-device TD-003/004/005
matrix; it is not an uploaded TestFlight build. Its App provisioning profile
contains both currently registered physical-device identifiers
`00008110-000A08440198801E` and `00008103-000479392ED9001E` (plus the registered
Mac identifier), so the offline device enumeration is not a provisioning gap.

Local `codesign --verify --deep --strict` on the App Store export reached
`CSSMERR_TP_NOT_TRUSTED` because the beta-host keychain does not trust the
Cloud-managed distribution chain. This is not treated as a signature failure or
a local trust pass. Identity is corroborated by Team ID, entitlements, embedded
profiles, Distribution Summary and successful Cloud export logs.

## Upload-only preflight — 2026-08-24

No upload or workflow mutation occurred during this read-only preflight.

| Check | Result | Grade |
|---|---|---|
| Remote frozen identity | Live `git ls-remote` shows `origin/main` and annotated tag `testflight-v1.0-rc1-build7^{}` both resolve to `244b32df38cff7ce3d8e56d78a80d4504cc6f073` | `Executor-recorded` |
| Retained artifact bytes | All five directory-manifest SHA-256 values rehash exactly to this ledger; Store IPA and the three Store sidecar hashes also match | `Executor-recorded` |
| Store eligibility | Export remains `1.0 (7)`, method `app-store-connect`, `testFlightInternalTestingOnly = false`, `uploadSymbols = true`; App and Keyboard remain Store-profiled with `beta-reports-active = true` | `Executor-recorded` |
| App Store Connect TestFlight state | Signed-in read-only inspection shows “无构建版本” | `Executor-recorded` |
| Build 7 page | Build succeeded at exact commit `244b32d`; only “重建” is offered, with no existing-build distribution action | `Executor-recorded` |
| Cloud workflow | `Archive Pilot (No Distribution)` still uses Distribution Preparation `None` and has no post-actions | `Executor-recorded` |
| Local delivery tool | At preflight time Apple Transporter was not installed. It was subsequently installed from Apple's Mac App Store and used for the separately authorized upload below; no credentialed `altool` path was used | `Executor-recorded` |

Apple documents uploading an existing app binary with Xcode, `altool` or
[Transporter](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/).
Apple's Xcode Cloud distribution flow archives and uploads as part of a workflow
build; changing the no-distribution workflow and rebuilding would therefore
create a new Cloud build identity rather than upload the already frozen Build 7
package. At this preflight point, preserving `1.0 (7)` required a separate Human
authorization to upload the retained Store `Universe Keyboard.ipa` with a
supported Apple upload tool. Installing/signing into Transporter, validating,
uploading, waiting for processing, assigning a tester group and submitting Beta
Review were kept as separate actions. The next section supersedes only the
preflight's upload-pending state.

## Separately authorized upload result — 2026-08-24

> **Superseded for current distribution state:** on `2026-08-25`, the Human
> Product Owner created internal group `Build 7 Internal Smoke`, attached one
> build and invited two internal testers. The table below remains the exact
> upload-time receipt; see [`RELEASE-2026-0801-11`](../assignments/release-2026-08-01-11-internal-testflight-feedback.md)
> for the current internal-feedback state.

The Human Product Owner explicitly authorized uploading only the exact retained
Store IPA to App Store Connect App `6804236252`, version `1.0`, build `7`, then
waiting for processing. The authorization explicitly excluded group assignment,
internal/external distribution and Beta Review submission.

| Check | Result | Grade |
|---|---|---|
| Final local package identity | `Universe Keyboard.ipa`, `18,680,731` bytes, SHA-256 `b9baf3620be8fedd2754ce452edbed7ada0d07b67e44514666be3c8da58984aa` | `Executor-recorded` |
| Transporter package recognition | `Universe Keyboard`, version `1.0`, build `7`, Apple ID `6804236252` | `Executor-recorded` |
| Delivery | Transporter `26.30.2 (173002)` displayed green `已交付` at `2026-08-24 22:46 Asia/Shanghai` | `Executor-recorded` |
| App Store Connect processing | Upload row appeared as `1.0 (7)` / `正在处理`, then completed as TestFlight build `7` / `准备提交` with 90-day expiry | `Executor-recorded` |
| Binary metadata | Binary status `已验证`; build string `7`; minimum iOS `18.0`; arm64; iPhone/iPad; symbols included; non-exempt encryption `否`; App/Keyboard entitlements retain `beta-reports-active`, Team ID and expected App Group | `Executor-recorded` |
| Distribution boundary | Groups `0`; individual testers `0`; build-specific What to Test is blank; no internal/external distribution or Beta Review submission occurred | `Executor-recorded` |

TestFlight build detail:
[`Universe Keyboard 1.0 (7)`](https://appstoreconnect.apple.com/teams/82c0e48e-c8bf-442c-9db9-19ed80ce4d87/apps/6804236252/testflight/ios/ff76d44e-547a-4b2c-8241-c80ec0778de6).
The previous online-authentication residual is now exercised successfully for
this exact package. This does not close Task04, TD-003/004/005, TestFlight smoke
or external-candidate release gates.

## Conclusion and residuals

**Executor conclusion:** the frozen RC source, Build 7 archive, both dSYMs,
XCResult, logs, non-Internal-Only App Store package and ad hoc package form one
internally consistent artifact set. Under the later, exact upload-only Human
authorization, that same Store package was delivered and processed as TestFlight
`1.0 (7)`. No tester or review action was part of that upload-only execution;
the later Human-operated internal group is recorded separately.

This evidence does **not** close the external-candidate Gate by itself:

- independent Quality artifact review is recorded as `Pass with conditions`;
  its accepted residuals are package-level only and do not close the release;
- `RELEASE-2026-0801-04` and TD-003/004/005 still require the named iPhone 13 Pro
  / iOS 27 physical-device matrix using this exact Build 7 ad hoc package;
- internal preflight, tester-group assignment, distribution and Beta Review
  submission remain separate Human-authorized actions;
- any candidate-changing source change requires a new commit/tag/build and
  invalidates this artifact mapping.

Independent review:
[`Build 7 Quality review`](release-2026-08-01-01-frozen-rc-build7-independent-quality-review-2026-08-24.md).
