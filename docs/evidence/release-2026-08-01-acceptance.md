# RELEASE-2026-0801 Release Evidence And Acceptance Record

> **Status:** Active evidence ledger; no release conclusion yet
> **Target availability:** `2026-08-26 Asia/Shanghai` (historical: `2026-08-01`; redate [`PD-RELEASE-2026-0801-TARGET-REDATE`](../product-decisions/RELEASE-2026-0801-target-redate.md))
> **Authority:** [`RELEASE-2026-0801`](../assignments/release-2026-08-01.md)
> **Evidence rule:** A historical or preliminary result is not final release evidence until it maps to the frozen release commit and archive.
> **Current channel decision:** Build 55 public external-testing exception accepted under [`Build 55 public external-testing exception`](../product-decisions/RELEASE-2026-09-13-build55-limited-external-trial-exception-proposal.md); App Store Connect group and public link are configured, Beta Review is pending, and formal Release remains open

## Latest candidate update — Build 55 physical Product Gate

On `2026-09-12 Asia/Shanghai`, the exact Xcode Cloud Build 55 archive/export from
`main` commit `b8175129f26f787a6c7fee0be5977ebec46edf60` was installed by
replacement on the designated iPhone 13 Pro / iOS 27.0. The Human Product Owner
completed the declared keyboard-enable and functional smoke sequence and returned
`通过，没有任何异常。` The bounded result is **Human Product Gate Pass for
functional smoke**. It does not close the performance, Full Access off/on,
crash/Jetsam/symbolication or fresh-install boundaries, and it does not authorize
TestFlight distribution or release. Full record:
[`Build 55 physical Product Gate`](release-2026-09-12-build55-physical-product-gate.md).

## Latest external-testing execution — Build 55 public link

On `2026-09-13 Asia/Shanghai`, the Human Product Owner authorized the public external-testing exception and its
App Store Connect execution. External group `Build 55 Public Beta` was created, Store export `1.0 (55)` was added,
the no-login Beta Review form was submitted with the bounded Build 55 `What to Test` text, and a public link was created
as `Open to Anyone` without a tester limit: <https://testflight.apple.com/join/t48JR3Q3>.
App Store Connect currently reports the build as `Waiting for Review` and `Expires in 90 days`; it states that testers
cannot join until the build is approved. Current testers, invites, installs, sessions and feedback are all zero.
This channel exception does not change the independent Quality/Release `Blocked` conclusion or authorize App Store
production release.

## Latest diagnostic revalidation — Build 55 / Xcode 27 RC

On `2026-09-12 Asia/Shanghai`, Human Product Owner authorized one bounded retry after confirming that only
Xcode `27.0 RC (27A266a)` remained available. The exact Build 55 install was confirmed by `devicectl` as
version `1.0` / bundle version `55`. The all-processes Time Profiler retained a `61.170705 s` physical-device
window to its time limit and sampled both `Universe Keyboard` and `Keyboard` processes. The exported potential-hangs
table contained no row for either product process. This is valid collector/process diagnostic evidence, not a
numeric TD-003 baseline or a TD-004/TD-005 closure. Full receipt:
[`Build 55 Xcode 27 RC diagnostic capture`](release-2026-09-12-build55-td003-xcode27rc-diagnostic.md).

## Latest TD-003 follow-up — Build 55 / Xcode 27 RC

On `2026-09-13 Asia/Shanghai`, a separate `151.239897 s` physical-device Time Profiler follow-up completed normally at
the requested time limit. `48/48` read-only snapshots observed both Build 55 product processes, while the exported table
contained `3,625` Keyboard rows and no Main App rows. Potential-hangs rows belonged only to Reminders and WeChat. This
advances collector/process evidence only; TD-003 remains without a controlled cold/warm or numeric baseline. Full receipt:
[`Build 55 TD-003 cold/warm diagnostic`](release-2026-09-13-build55-td003-cold-warm-diagnostic.md).

## Latest TD-004 matrix — Build 55 Full Access off/on

On `2026-09-13 Asia/Shanghai`, a current Build 55 / iOS 27 physical off/on matrix was completed with a fresh Keyboard
Extension session for each arm. Human-attested behavior was identical for basic input and candidate commit; haptics were
absent with Full Access off and present with it on, while sound remained present in both arms. No degradation prompt appeared
in either arm. This supports the narrower haptic dependency but does not close the shared-capability or self-diagnosing matrix.
Full receipt: [`Build 55 TD-004 matrix`](release-2026-09-13-build55-td004-full-access-matrix.md).

## Latest TD-005 query — Build 55 systemCrashLogs

On `2026-09-13 Asia/Shanghai`, a read-only query of the designated iPhone's `systemCrashLogs` surface confirmed the
installed app remained Build `55`. It found one `Universe Keyboard` crash report from Build `1`, which is excluded by
version/UUID, and four Jetsam snapshots. Three snapshots contain the Build 55 App/Keyboard UUIDs but no victim,
jettisoned, killed or process-level reason marker; they therefore remain `unclassified` and do not close TD-005.
Full receipt: [`Build 55 TD-005 query`](release-2026-09-13-build55-td005-system-crash-query.md).

The authorized read-only classification follow-up reconfirmed the report hashes and the App/Keyboard UUID-to-dSYM
mapping across the retained Archive and Store/Ad Hoc exports. It also found that the Archive and dSYM metadata report
`CFBundleVersion=1`, while the exported packages and export summaries report Build `55`. The subsequent Archive ↔ export
reconciliation confirmed the code-image lineage and export-stage Build 55 provenance, while retaining the metadata
difference explicitly. The three UUID-bearing Jetsam rows still have no victim marker and remain `unclassified`.
Full receipts: [`Build 55 TD-005 classification follow-up`](release-2026-09-13-build55-td005-classification-follow-up.md) ·
[`Build 55 Archive ↔ export reconciliation`](release-2026-09-13-build55-archive-export-reconciliation.md).

## Latest Quality/Release re-review — Build 55

The independent Quality/Release re-review accepted the Archive ↔ export relationship only conditionally: the retained
Archive/dSYM metadata is `1.0 (1)`, while the export records and packages are `1.0 (55)`; UUID/dSYM mappings and the
non-identity resource manifest align. It did not require a true `CFBundleVersion=55` Archive/dSYM for that bounded
candidate relationship, but kept TD-003, TD-004, TD-005, clean App Group and the overall public-test Release Gate
**Blocked**. A true `55` Archive/dSYM remains necessary only if Release/Artifact policy requires an exact Archive identity
claim. Full receipt: [`Build 55 Quality/Release re-review`](../reviews/release-2026-09-13-build55-quality-release-re-review.md).

## Latest fresh-install boundary — Build 55

On `2026-09-13 Asia/Shanghai`, Human Product Owner authorized a bounded fresh-install round on the designated iPhone 13 Pro.
Only `com.DoubleShy0N.Universe-Keyboard` was uninstalled; the post-uninstall App and Keyboard process listings were empty.
The locally retained Build 55 Ad Hoc `.app` was then installed successfully and rechecked as `1.0 (55)` with the frozen App and
Keyboard executable UUIDs. On first main-App open, Human reported that the first-launch guide directed the user to iOS Settings
to add the keyboard, matching the documented J1 scenario. Human then reported `已添加` and `完全访问已开启`, so J1 and J2 are
complete. The J3 resource view subsequently showed built-in Luna as default while downloadable 雾凇/万象 were not installed. Human then
clarified that the main App already showed RIME as `已部署` automatically; no manual deployment tap or third-party download
occurred. J3 is therefore recorded complete for this progress run. Human then reported normal output with the default Luna
26-key layout, which records basic J4 first-input success. Because 雾凇/万象 were not downloaded, no nine-key/T9 or
downloadable-scheme behavior is claimed from the Luna arm alone; this is not yet a complete activation result. Human later
completed a separately authorized Build 55 雾凇 download/deployment and nine-key gate: the keyboard stayed selected,
candidates appeared and committed normally, sound was present, and no degradation prompt appeared. Haptics were reported off
in that arm because they require Full Access. This scoped nine-key gate passed; it does not close the remaining physical or
shared-container gates.

The run did not read or manually clear App Group, RIME or user-dictionary contents. Therefore it is valid evidence for the
installed-App boundary, first-launch guide, J1/J2/J3 completion, basic Luna 26-key J4 output and the no-download resource
choice only; a clean shared-container state remains `UNKNOWN`. Full receipt:
[`Build 55 fresh-install boundary`](release-2026-09-13-build55-fresh-install-boundary.md). The post-gate review handoff is
[`Build 55 public-beta readiness`](release-2026-09-13-build55-public-beta-readiness-handoff.md).

## Build 55 Store upload package preflight

On `2026-09-13 Asia/Shanghai`, the retained Build 55 Archive was checked against its Store export. The package metadata
reports `1.0 (55)`, `app-store-connect` export, `testFlightInternalTestingOnly=false`, Store provisioning profiles,
`beta-reports-active=true` and `get-task-allow=false`. The exact Store IPA SHA-256 is
`b178c05530b92a207eb8aaf4e701c1db803fec728c3df702424c89944ee1c6fd`; App/Keyboard executable UUIDs match the retained
dSYMs. This is an artifact-level upload preflight, not ASC processing or external-test readiness. Full receipt:
[`Build 55 Store upload package preflight`](release-2026-09-13-build55-store-upload-package.md).

The formal Release Identity table below remains Build 7 until a separate Human/Product candidate re-freeze is recorded.

## Release Identity

| Field | Current value |
|---|---|
| Release commit/tag | `testflight-v1.0-rc1-build7` → `244b32df38cff7ce3d8e56d78a80d4504cc6f073` |
| Marketing version/build | `1.0 (7)` in both exported App and Keyboard bundles |
| Stable Xcode/SDK | Xcode `26.6 (17F113)` / iPhoneOS SDK `26.5`; Cloud host macOS Tahoe `26.6.2 (25G83)` |
| Signed archive | Xcode Cloud `Archive Pilot (No Distribution)` Build 7 succeeded; App Store and ad hoc exports retained |
| dSYM retention | App + Keyboard dSYMs retained; both UUIDs exactly match Archive and exported IPA binaries |
| TestFlight/App Store build | TestFlight `1.0 (7)`; Human-created internal group `Build 7 Internal Smoke`, one build, two invited internal testers, at least one invitation received; exact What to Test online value `UNKNOWN`; no external group or review submission |
| Intended final build environment | Apple Developer Program active; Xcode Developer Team `chenkai shen` verified with Admin role; Xcode Cloud connected to GitHub. App Record `6804236252` verified. Frozen RC Build 7 produced the retained final Archive/dSYM/export artifact set under Xcode 26.6, and the exact Store IPA was subsequently delivered by Transporter under separate upload-only authorization. |
| Pre-external device matrix | Physical iPhone 13 Pro / iOS 27 for Extension lifecycle/performance/Full Access; iOS 18 iPhone + iPad Simulator for minimum-OS compatibility. Simulator is not physical-device evidence. |
| Supported devices/OS | iPhone and iPad; **iOS 18.0+** by [`PD-RELEASE-2026-0801-MINIMUM-OS-IOS18`](../product-decisions/RELEASE-2026-0801-minimum-os-ios18.md). Narrowed iOS 18 Phase 2 is Human-accepted ([evidence](release-2026-0801-10-ios-18-phase2-human-evidence.md)); this is not a release device matrix. |
| Included schemas/features | Existing baseline input; Chinese nine-key; precise-pinyin selection; post-commit continuation; kaomoji content; and a local basic Home input-count display. No schema expansion is authorized. Advanced Typing Intelligence and contextual typo correction are excluded from launch claims. |

## Child Gate Status

| Assignment | Status | Evidence / blocker |
|---|---|---|
| Stable archive | `Reviewed — Quality Pass with conditions; exact upload processed` | Exact RC tag/commit, Build 7 Archive/dSYMs/exports and Store IPA are retained and independently mapped. Separately authorized Transporter upload succeeded; ASC validated and processed TestFlight `1.0 (7)` to `准备提交`. No groups/distribution/review. [Build 7 ledger](release-2026-08-01-01-frozen-rc-build7-artifact-ledger-2026-08-24.md) · [Quality review](release-2026-08-01-01-frozen-rc-build7-independent-quality-review-2026-08-24.md) |
| Scope freeze | `Reviewed — Architecture and Quality conclusions recorded; no release conclusion` | Product scope is unchanged; exact release identity is now frozen by subsequent Human authorization. Minimum OS is iOS 18.0; 08 is Closed; 07 physical-iPad residual is deferred to targeted external testing |
| iOS 26.0 target | `Superseded by RELEASE-2026-0801-10` | 26.0-only path closed by [`PD-RELEASE-2026-0801-MINIMUM-OS-IOS18`](../product-decisions/RELEASE-2026-0801-minimum-os-ios18.md) |
| iOS 18.0 target | `Reviewed` — Phase 1 Quality `Pass with conditions`; narrowed Phase 2 Human-accepted | [Quality](../assignments/release-2026-08-01-10-quality-review.md) · [Phase 2 Human](release-2026-0801-10-ios-18-phase2-human-evidence.md). Not Archive/release |
| iPad support | `Active — iOS 18 Simulator matrix complete; release-toolchain runtime gate pending` | [iOS 18 iPad Simulator preflight](release-2026-08-01-07-ios18-ipad-simulator-preflight-2026-08-21.md): mini / 10th-gen / 13-inch M4 critical matrix complete. Physical iPad remains deferred; this is not an App Store iPad compatibility claim |
| Kaomoji content | `Closed` | PR [#80](https://github.com/shchnk1103/Universe-Keyboard/pull/80) merged at `54ce3bd`; Human Product Gate passed and Assignment closed. This is feature evidence, not RC/TestFlight authorization |
| Onboarding / Full Access | `Closed — Conditional Product Gate accepted` | Device matrix [`release-2026-08-01-03-physical-device-fa-matrix.md`](release-2026-08-01-03-physical-device-fa-matrix.md); gate [`../assignments/release-2026-08-01-03-product-gate.md`](../assignments/release-2026-08-01-03-product-gate.md); Human confirmed `2026-07-20`; TD-004 residual in `TECH_DEBT.md` |
| Device / performance | `Partially revalidated — Build 55 diagnostics, TD-004/TD-005, fresh-install J1/J2/J3/J4 and scoped 雾凇九宫格 gate recorded; full Gate open` | Historical Build 7 P4 traces remain excluded after `Device disconnected`; Build 55 now has two retained diagnostics, a current Full Access off/on matrix, a bounded crash-log query and read-only classification follow-up, a fresh App uninstall/reinstall plus first-launch guide/J1/J2 observation, automatic J3 deployment state, basic Luna 26-key J4 output and a scoped 雾凇 nine-key gate. The matrix supports basic input/candidate commit in both states and a haptic difference, but does not establish shared-capability completeness or self-diagnosing recovery. The TD-003 follow-up lacks a controlled cold/warm/numeric baseline; the three UUID-bearing Jetsam rows remain unclassified without a victim marker; Archive/dSYM metadata reports build `1` while exported packages/summaries report Build `55`, with code-image and export provenance conditionally reconciled; App Group clean-state, remaining physical evidence and full fresh-install boundary remain open. TD-003/004/005 and the overall Gate remain open. [P4 evidence](release-2026-08-01-04-build7-device-run-p4-2026-08-24.md) · [Build 55 receipt](release-2026-09-12-build55-td003-xcode27rc-diagnostic.md) · [TD-003 follow-up](release-2026-09-13-build55-td003-cold-warm-diagnostic.md) · [TD-004 matrix](release-2026-09-13-build55-td004-full-access-matrix.md) · [TD-005 query](release-2026-09-13-build55-td005-system-crash-query.md) · [TD-005 classification follow-up](release-2026-09-13-build55-td005-classification-follow-up.md) · [Archive ↔ export reconciliation](release-2026-09-13-build55-archive-export-reconciliation.md) · [Fresh-install boundary](release-2026-09-13-build55-fresh-install-boundary.md) · [雾凇九宫格 gate](release-2026-09-13-build55-rime-ice-nine-key-gate.md) · [Quality/Release re-review](../reviews/release-2026-09-13-build55-quality-release-re-review.md) |
| App Store materials | `Active` | Contacts/privacy/export/age and disclosure work complete; Phase A receipts accepted; content rights/categories and store copy are Human-reported saved. Build 55 public external group, no-login Beta Review submission and public link are recorded; screenshots remain deferred. [Copy handoff](release-2026-08-01-05-store-copy-and-what-to-test-2026-08-24.md) · [Public-testing exception](../product-decisions/RELEASE-2026-09-13-build55-limited-external-trial-exception-proposal.md) |
| Product polish | `Active — Full Access deferral remediation verified; other polish residuals remain` | Candidate VoiceOver role/hint and J2 “稍后再开启” are remediated; complete accessibility and physical-device visual Gate remain open. Evidence in [`iPad preflight`](release-2026-08-01-07-ios18-ipad-simulator-preflight-2026-08-21.md) |
| Internal TestFlight feedback | `Assignment Pending` | Three Build 7 findings captured; reproduction and implementation roles remain incomplete. F-03 cross-region download is Product-prioritized urgent and blocks broader external testing. [Task11](../assignments/release-2026-08-01-11-internal-testflight-feedback.md) · [intake](release-2026-08-01-11-internal-testflight-feedback-2026-08-25.md) |

## Preliminary Repository Audit Snapshot

This section records preparation evidence only. It expires when the release commit changes or the final archive is produced.

- **Collected:** `2026-07-20 Asia/Shanghai`
- **Base:** repository `main` at `9f5ed24`; clean against `origin/main` at collection time
- **Observed passed preparation checks:** repository whitespace check; pinned RIME vendor structural verification; current KeyboardCore, main-App/Extension and RimeBridge automated suites; beta-toolchain Debug/Release simulator and generic-device compilation
- **Observed limitations:** fixture-gated RimeBridge cases skipped; no stable-toolchain signed archive; no final physical-device matrix; no final performance/jetsam baseline; no App Store Connect state verification
- **Exploratory device availability:** Device Hub observed a connected iPhone 13 Pro and iPad Pro (11-inch, 3rd generation). The iPad reports a user-deployed `Universe Keyboard` version `1.0` / build `1`; no interaction or release conclusion is recorded from this observation.
- **Expiry:** any release-candidate commit, toolchain, artifact, feature scope or support-matrix change

Do not copy preliminary test counts into current product or release claims. Preserve exact command output in the child evidence handoff when those checks are repeated for the final candidate.

## Xcode Cloud Repository Preflight Snapshot

This section combines the repository preflight with the subsequently authorized no-distribution Cloud Build pilot. It is not archive, signing, upload or distribution evidence.

- **Collected:** `2026-08-21 Asia/Shanghai`
- **Code base:** repository preflight began from `0de510d`; the executed Cloud pilot is exactly feature-branch commit `cdc6bfe`. The evidence updates written after completion are not part of Build 1.
- **Ready in repository:** `Universe Keyboard` is a shared scheme and its Archive action uses `Release`; the App target is enabled for archiving; local package references resolve to `Packages/KeyboardCore` and `Packages/RimeBridge`
- **Implemented repository input:** executable `ci_scripts/ci_post_clone.sh` resolves `CI_PRIMARY_REPOSITORY_PATH` and invokes `scripts/ensure_rime_vendor.sh fetch`. The existing fetch contract downloads the immutable manifest-pinned archive, verifies SHA-256, stages it and verifies the expected framework inventory.
- **Local verification:** shell syntax passed; explicit Cloud-style repository root and local fallback both verified the installed 12-framework inventory; an invalid repository root failed closed. A temporary checkout without `Vendor` entered the real pinned download path, but the current execution environment could not resolve `release-assets.githubusercontent.com`; all retries failed nonzero and no artifact was installed. `shellcheck` was unavailable.
- **Cloud Build pilot (`2026-08-21`):** manual workflow `Default`, Build 1, branch `codex/external-testflight-cloud-prep`, commit `cdc6bfe` (`chore: record Xcode Cloud onboarding`). Environment: Xcode 26.6 (`17F113`) on macOS Tahoe 26.6.2 (`25G83`). The build queued for 12 seconds and ran for 2 minutes.
- **Bootstrap proof:** `ci_post_clone.sh` completed successfully in 2.7 seconds; its log recorded the manifest-pinned RIME preparation, structural verification of 12 framework artifacts under the clean Cloud checkout, and `RIME artifacts are ready`. Package resolution and `xcodebuild build` then succeeded; the action completed with `No Issues`.
- **Remaining boundary:** this Build action proves Cloud repository/network access, stable toolchain, shared scheme discovery and the RIME bootstrap. It does not prove signing, Archive, dSYM/artifact retention or artifact download. TestFlight/App Store distribution remains unauthorized.
- **Account observation (`2026-08-21`):** Human Product Owner reports Apple Developer Program activation complete. Xcode 27 beta 5 verified Developer Team `chenkai shen`, Admin role, Certificates/Identifiers/Profiles access and three provisioned devices. `/Applications/Xcode.app` is Xcode 26.6 (`17F113`) but macOS 27 rejects launching it as incompatible; Xcode 27 beta is only the configuration client.
- **Cloud connection (`2026-08-21`):** Xcode Cloud successfully connected to the GitHub source repository and created workflow `Default`. Its current action is `Build - iOS`, and it has no TestFlight post-action. Xcode created `xcshareddata/xcodecloud/manifest.json` with Cloud product/target identifiers only; no credential or secret is present. The feature branch was pushed before Build 1; no build was started against `main`.
- **Remaining pilot proof:** signing, Archive, dSYM/artifact retention and artifact download against a future frozen candidate
- **Expiry:** vendor manifest/script, ignore rules, package graph, scheme, Cloud workflow or release commit change

## Xcode Cloud Archive/Signing Pilot Snapshot

This section is later than the repository preflight above and supersedes only its “Archive/signing unverified” pilot statement. It does not become final release evidence.

- **Collected:** `2026-08-22 Asia/Shanghai`
- **App Record:** `Universe Keyboard`, Apple ID `6804236252`, Bundle ID `com.DoubleShy0N.Universe-Keyboard`, primary language Simplified Chinese.
- **Workflow:** `Archive Pilot (No Distribution)`; manual `main` only; Xcode/macOS `Latest Release`; action `Archive - iOS`; Distribution Preparation `None`; no post-actions.
- **Build:** Build 3, commit `4fd3ce70d9acfc54472923fb7d66ff0589e11f6d`, Xcode 26.6 (`17F113`), macOS Tahoe 26.6.2 (`25G83`). Queue 9 seconds; about 2 minutes duration / 3 minutes usage.
- **Result:** `Archive - iOS` succeeded. The action reached and completed “Code signing app for app-store distribution”. [Build record](https://appstoreconnect.apple.com/teams/82c0e48e-c8bf-442c-9db9-19ed80ce4d87/apps/6804236252/ci/builds/6aec0bbf-6bbe-4cd3-81b5-8382f2d3898d/summary).
- **Distribution check:** TestFlight still showed no build after completion; no upload/distribution was configured or performed.
- **Evidence grade:** `Executor-recorded`.
- **2026-08-24 supersession:** artifact and dSYM retention/download are now verified at pilot grade, including exact App/Keyboard UUID mapping and a non-Internal-Only App Store export. [Evidence](release-2026-08-01-01-cloud-artifact-retention-pilot-2026-08-24.md).
- **Remaining boundary:** current commit is not frozen RC; the final candidate must repeat artifact retention and independent review. No upload, TestFlight processing, smoke, external group or Beta Review occurred.
- **Expiry:** release commit/build, signing entitlements, scheme, workflow, toolchain, privacy manifest, vendor/bootstrap or Apple upload requirements change.

## External TestFlight Metadata Snapshot

- **Collected:** `2026-08-22 Asia/Shanghai`
- **Online write:** Beta App Description and Beta Review Notes saved; login remains not required.
- **Open Human Input Gate:** final build-specific What to Test approval after RC freeze/upload. License-disclosure UI was Human-confirmed separately. Content rights and categories are Human-reported saved (primary `工具`, secondary `效率`).
- **Build-specific boundary (snapshot at collection time):** What to Test was prepared only as a template because no TestFlight build existed on `2026-08-22`. This state is superseded by processed Build 7; the field is now bindable but remains blank and separately unauthorized for write.
- **Canonical evidence/handoff:** [`release-2026-08-01-05-testflight-metadata-audit-2026-08-22.md`](release-2026-08-01-05-testflight-metadata-audit-2026-08-22.md).

### Subsequent update — 2026-08-23

- Human Product Owner confirmed feedback/review contacts were saved and App Privacy `No data collected` was published with the public privacy URL; personal values are not recorded.
- Export-compliance audit found only Apple-OS-provided CryptoKit `ChaChaPoly`, URLSession/TLS and Keychain encryption plus SHA-256 digests. After explicit authorization, `config/Info.plist` now declares `ITSAppUsesNonExemptEncryption = NO`; source validation and an Xcode 27 beta Release Simulator integration build passed, with no encryption-document upload.
- Possible U.S. year-end self-classification remains a Human legal obligation. The age questionnaire is Human-confirmed complete. Phase A derived receipts were accepted as an external-candidate residual. Human Product Owner later reported saving content rights “Yes”, primary category `工具` and secondary category `效率`; the executor did not independently verify App Store Connect.

## Final Evidence Matrix

| Area | Required environment/artifact | Result | Evidence location | Reviewer | Expiry/revalidation |
|---|---|---|---|---|---|
| Repository/artifact integrity | Frozen release commit | Reviewed | [Build 7 ledger](release-2026-08-01-01-frozen-rc-build7-artifact-ledger-2026-08-24.md) | Quality-reverified artifact review | Commit/artifact change |
| Stable signed archive/validation | Final archive | Reviewed — Pass with conditions; uploaded package processed | [Build 7 ledger](release-2026-08-01-01-frozen-rc-build7-artifact-ledger-2026-08-24.md) | Quality-reverified artifact review + Executor-recorded upload | Archive/toolchain/package change |
| Automated tests/builds | Frozen commit, stable toolchain | Pending | — | — | Relevant diff/toolchain change |
| RIME/Lua/OpenCC runtime | Final deployed schemas | Pending | — | — | Artifact/schema/config change |
| Full Access off/on | Physical device | Partially observed — not closed | [Build 55 TD-004 matrix](release-2026-09-13-build55-td004-full-access-matrix.md) | Human-attested off/on behavior; independent Quality/Release conclusion remains Blocked | Access/onboarding/fallback change |
| Keyboard host/device matrix | Physical device, Release build | Pending | — | — | UI/Core/RIME/support change |
| Performance/memory/jetsam | Physical device, Release build | Pending | — | — | Performance-sensitive change |
| Accessibility/appearance | Supported devices/layouts | Pending | — | — | UI/support change |
| Privacy/security/licenses | Final binary and public policy | Pending | — | — | Binary/policy/dependency change |
| App Store metadata/screenshots | Final supported scope | Pending | — | — | Scope/copy/screenshot change |
| TestFlight upload/processing | Exact Store IPA | Passed — `1.0 (7)` ready to submit; no distribution | [Build 7 ledger](release-2026-08-01-01-frozen-rc-build7-artifact-ledger-2026-08-24.md) | Executor-recorded | Uploaded build change |
| TestFlight smoke | Uploaded build | In progress — internal invitations delivered; findings open; no Pass | [Task11 intake](release-2026-08-01-11-internal-testflight-feedback-2026-08-25.md) | Device-attested intake; Quality not assigned | Build/fix/environment change |

## Failed Or Skipped Gates

No skipped release gate is accepted by default. Add one row for every failure or skip.

| Gate | Failed/skipped reason | Impact | Owner | Product decision | Expiry/follow-up |
|---|---|---|---|---|---|
| `RELEASE-2026-0801-04` physical-device performance / memory / termination | Historical P4 initial machine arm and sole authorized machine re-arm both ended at about `1.3 s` with `Device disconnected` before any Human instruction; both traces are permanently excluded. Later Build 55 diagnostics, a TD-004 off/on matrix and a TD-005 query were recorded separately | Historical P4 still provides no performance, memory, crash/Jetsam or termination conclusion; current TD-003/004/005 evidence remains partial and the external-candidate release Gate remains open. This does not block a separately authorized upload-only action | Test/release evidence environment; Product Lead owns the next environment decision | [`PD-RELEASE-2026-0801-04-BUILD7-BOUNDED-EVIDENCE-EXCEPTION`](../product-decisions/RELEASE-2026-0801-04-build7-bounded-evidence-exception.md); no skipped-gate/risk acceptance | TD-003/004/005 follow-up receipts; current P4 may not be retried |
| `RELEASE-2026-0801-11` internal TestFlight feedback | First-time user confusion, unexplained builtin multi-character failure and no-VPN scheme-download failure | Build 7 has no smoke Pass; F-02 may invalidate the external candidate; F-03 blocks broader external testing pending fix or explicit Product decision | `UNKNOWN` until Product Lead assigns/splits domain ownership | Product Lead advanced F-03 priority only; no implementation/risk acceptance | Capture exact reproduction headers and create named fix Assignments |

## External Action Log

| Time | Action | Explicit authorization source | Actor/account boundary | Result/artifact |
|---|---|---|---|---|
| `2026-08-21 Asia/Shanghai` | Apple Developer Program activation | Human Product Owner reported completion in active Codex task | Human Product Owner; Codex performed read-only Xcode observation only | Human-attested active membership; Xcode account visible; team/access were still `UNKNOWN` at this observation and were subsequently verified below |
| `2026-08-21 Asia/Shanghai` | Connect Xcode Cloud to GitHub and create first workflow | Human Product Owner replied `继续` after Codex identified the persistent repository-access boundary | Xcode Cloud / GitHub; current repository only | Connection succeeded; Developer Team `chenkai shen` / Admin; workflow `Default` created with `Latest Release`; no build or distribution started |
| `2026-08-21 Asia/Shanghai` | Run no-distribution Cloud Build pilot | Same bounded authorization; Human Product Owner supplied a temporary proxy and asked Codex to continue | Xcode Cloud workflow `Default`; feature branch only | Build 1 on `cdc6bfe` passed with Xcode 26.6 / macOS Tahoe 26.6.2; post-clone RIME bootstrap verified 12 artifacts; iOS build completed with no Issues; no Archive or distribution |
| `2026-08-22 Asia/Shanghai` | Create/configure no-distribution Archive pilot and run one manual `main` build | Human Product Owner separately replied `授权` after Codex stated the workflow and no-distribution boundary, then separately authorized starting one pilot | Xcode Cloud workflow `Archive Pilot (No Distribution)`; App Store Connect App `6804236252` | Build 3 on `4fd3ce7` archived and completed App Store distribution signing with Xcode 26.6 / macOS 26.6.2; TestFlight remained empty; no post-action/upload |
| `2026-08-22 Asia/Shanghai` | Audit and partially complete external TestFlight test information | Human Product Owner requested read-only audit, metadata/compliance/test-copy completion and KOS handoff updates | App Store Connect TestFlight Test Information; current Codex task | Beta description and Review Notes saved; login off. Human/compliance fields remain open; no build/group/tester/review submission |
| `2026-08-23 Asia/Shanghai` | Add the repository-supported exempt-encryption declaration | Human Product Owner explicitly replied `授权` after the exact `ITSAppUsesNonExemptEncryption = NO` change and validation boundary were stated | `config/Info.plist`; local Xcode 27 beta Release Simulator integration build | Source and built App plist both resolve to `false`; build passed. No document/build upload, review submission, RC freeze or legal-risk acceptance |
| `2026-08-24 Asia/Shanghai` | Freeze exact RC tag | Human Product Owner explicitly authorized the exact freeze after the pre-freeze review and Build 6 were reported | Git tag on `origin`; no App Store Connect mutation | `testflight-v1.0-rc1-build7` → `244b32df38cff7ce3d8e56d78a80d4504cc6f073` |
| `2026-08-24 Asia/Shanghai` | Run one no-distribution final Archive | Human Product Owner separately replied `授权` after the workflow/no-upload boundary was restated | Xcode Cloud `Archive Pilot (No Distribution)` | Build 7 Archive/export succeeded and artifacts were downloaded/mapped; no upload or distribution |
| `2026-08-24 Asia/Shanghai` | Build 7 upload-only read-only preflight | Human Product Owner accepted separating upload from external distribution and authorized documentation repair plus preflight, but not upload | Local retained artifacts, GitHub refs and signed-in App Store Connect read-only inspection | Remote tag/main and retained artifact hashes match; Store package remains external-eligible; TestFlight still has no build; Cloud workflow remains no-distribution. Stopped at separate Human upload authorization Gate |
| `2026-08-24 22:45–22:47 Asia/Shanghai` | Upload exact Build 7 Store IPA and wait for processing | Human Product Owner explicitly authorized exact path, App, version/build and upload-only boundary; no groups/distribution/Beta Review | Apple Transporter → App Store Connect App `6804236252`; exact SHA-256 `b9baf362…` package | Transporter `26.30.2` delivered successfully; ASC processed TestFlight `1.0 (7)` to `准备提交`, binary `已验证`, symbols included, non-exempt encryption `否`; groups/testers `0`, What to Test blank |
| `2026-08-25 Asia/Shanghai` | Human-operated Build 7 internal group and tester invitations | Human Product Owner performed the account actions and reported/supplied screenshot evidence | App Store Connect internal group `Build 7 Internal Smoke` | One build, two invited internal testers; at least one invitation received. Initial feedback recorded in Task11; no external group/Beta Review |
| `2026-09-12 Asia/Shanghai` | Run one bounded Build 55 / Xcode 27 RC physical Time Profiler diagnostic capture | Human Product Owner authorized a retry after the toolchain availability was clarified; authorization covered this capture only | Connected iPhone 13 Pro / iOS 27; `xcrun xctrace` all-processes; no App Store Connect mutation | Trace ended at the 60-second limit; Main App `774` sample rows and Keyboard `3,238`; no product row in potential-hangs export. No memory/crash/Jetsam/fresh-install conclusion; no upload or distribution |
| `2026-09-13 Asia/Shanghai` | Run Build 55 Full Access off/on physical matrix | Human Product Owner replied `继续进入 TD-004`, then attested `OFF 完成` and `ON 完成` after the bounded instructions | Connected iPhone 13 Pro / iOS 27; two fresh Keyboard sessions; no App Store Connect mutation | Basic input and candidate commit worked in both arms; haptics absent off/present on; sound present in both; no degradation prompt; 90/90 process snapshots succeeded per arm. TD-004 remains open; no upload or distribution |
| `2026-09-13 Asia/Shanghai` | Run Build 55 fresh-install boundary, first-launch/J1/J2/J3/J4 observation and scoped 雾凇 nine-key gate | Human Product Owner explicitly approved entering the fresh-install boundary and later authorized the 雾凇 download/deployment and nine-key gate; then reported the first-launch guide, `已添加`, `完全访问已开启`, J3 state, Luna 26-key output and 雾凇 nine-key result | Connected iPhone 13 Pro / iOS 27; target App only; no App Store Connect mutation | Target App uninstall and reinstall succeeded; post-uninstall App/process listings were empty; first-launch guide directed to Settings and Human confirmed J1/J2 complete. Initial J3 view showed built-in Luna default and main App `已部署` automatically; later authorized 雾凇 download/deployment succeeded. Human reported the keyboard stayed selected, candidates appeared and committed normally, sound was present and no degradation prompt appeared; haptics were off in that arm due to the Full Access requirement. App Group clean state and remaining physical evidence remain open; no upload or distribution |

## Release Decision

- **Quality conclusion:** Pending
- **Architecture/privacy conclusion:** Pending where applicable
- **Product Gate:** Pending
- **App Store submission authorization:** Not granted by this record
- **Manual release authorization:** Not granted by this record
- **Residual risks:** Pending final evidence
