# RELEASE-2026-0801 Release Evidence And Acceptance Record

> **Status:** Active evidence ledger; no release conclusion yet
> **Target availability:** `2026-08-26 Asia/Shanghai` (historical: `2026-08-01`; redate [`PD-RELEASE-2026-0801-TARGET-REDATE`](../product-decisions/RELEASE-2026-0801-target-redate.md))
> **Authority:** [`RELEASE-2026-0801`](../assignments/release-2026-08-01.md)
> **Evidence rule:** A historical or preliminary result is not final release evidence until it maps to the frozen release commit and archive.
> **Current channel decision:** external TestFlight candidate under [`PD-RELEASE-2026-0801-EXTERNAL-TESTFLIGHT-CANDIDATE`](../product-decisions/RELEASE-2026-0801-external-testflight-candidate.md); no upload authorization

## Release Identity

| Field | Current value |
|---|---|
| Release commit/tag | `UNKNOWN — freeze under RELEASE-2026-0801-02` |
| Marketing version/build | `UNKNOWN — confirm under RELEASE-2026-0801-01` |
| Stable Xcode/SDK | `UNKNOWN — verify under RELEASE-2026-0801-01` |
| Signed archive | `UNKNOWN` |
| dSYM retention | `UNKNOWN` |
| TestFlight/App Store build | `UNKNOWN` |
| Intended final build environment | Apple Developer Program active; Xcode Developer Team `chenkai shen` verified with Admin role; Xcode Cloud connected to GitHub. Default workflow Build 1 passed on Xcode 26.6 / macOS Tahoe 26.6.2. App Store Connect App Record identity, Cloud Archive/signing and artifact retention remain pending. |
| Pre-external device matrix | Physical iPhone 13 Pro / iOS 27 for Extension lifecycle/performance/Full Access; iOS 18 iPhone + iPad Simulator for minimum-OS compatibility. Simulator is not physical-device evidence. |
| Supported devices/OS | iPhone and iPad; **iOS 18.0+** by [`PD-RELEASE-2026-0801-MINIMUM-OS-IOS18`](../product-decisions/RELEASE-2026-0801-minimum-os-ios18.md). Narrowed iOS 18 Phase 2 is Human-accepted ([evidence](release-2026-0801-10-ios-18-phase2-human-evidence.md)); this is not a release device matrix. |
| Included schemas/features | Existing baseline input; Chinese nine-key; precise-pinyin selection; post-commit continuation; kaomoji content; and a local basic Home input-count display. No schema expansion is authorized. Advanced Typing Intelligence and contextual typo correction are excluded from launch claims. |

## Child Gate Status

| Assignment | Status | Evidence / blocker |
|---|---|---|
| Stable archive | `Assigned — Entry Criteria pending` | Bootstrap locally implemented and Cloud Build pilot passed on `cdc6bfe`; membership, Developer Team and GitHub-to-Cloud connection verified. App Record confirmation, Archive/signing/artifact retention, independent review, final fixes and frozen RC remain pending. |
| Scope freeze | `Reviewed — Architecture and Quality conclusions recorded; no Product Gate or release conclusion` | [Architecture review](release-2026-08-01-02-architecture-review.md) and [Quality review](release-2026-08-01-02-quality-review.md) are historical `Pass` with follow-ups. Minimum OS row superseded by iOS 18.0; iPad support, kaomoji content and iOS 18 Phase 2 remain release blockers |
| iOS 26.0 target | `Superseded by RELEASE-2026-0801-10` | 26.0-only path closed by [`PD-RELEASE-2026-0801-MINIMUM-OS-IOS18`](../product-decisions/RELEASE-2026-0801-minimum-os-ios18.md) |
| iOS 18.0 target | `Reviewed` — Phase 1 Quality `Pass with conditions`; narrowed Phase 2 Human-accepted | [Quality](../assignments/release-2026-08-01-10-quality-review.md) · [Phase 2 Human](release-2026-0801-10-ios-18-phase2-human-evidence.md). Not Archive/release |
| iPad support | `Assigned — Entry Criteria pending` | External-candidate preflight uses iOS 18 iPad Simulator; physical iPad is deferred to targeted external evidence/App Store Gate and is not claimed complete |
| Kaomoji content | `Assigned — Entry Criteria pending` | Sequenced after other necessary preparation but before RC freeze; catalog/source/license and working-content evidence remain pending |
| Onboarding / Full Access | `Closed — Conditional Product Gate accepted` | Device matrix [`release-2026-08-01-03-physical-device-fa-matrix.md`](release-2026-08-01-03-physical-device-fa-matrix.md); gate [`../assignments/release-2026-08-01-03-product-gate.md`](../assignments/release-2026-08-01-03-product-gate.md); Human confirmed `2026-07-20`; TD-004 residual in `TECH_DEBT.md` |
| Device / performance | `Assignment Pending` | Final Cloud build pending; iPhone 13 Pro / iOS 27 physical is the named primary device; TD-003/004/005 remain open |
| App Store materials | `Assigned — Entry Criteria pending` | External TestFlight copy/contact/export inputs may be prepared locally; account/App Record/public URLs/final archive remain pending |
| Product polish | `Assignment Pending` | Executor/visual operator pending |

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

## Final Evidence Matrix

| Area | Required environment/artifact | Result | Evidence location | Reviewer | Expiry/revalidation |
|---|---|---|---|---|---|
| Repository/artifact integrity | Frozen release commit | Pending | — | — | Commit change |
| Stable signed archive/validation | Final archive | Pending | — | — | Archive/toolchain change |
| Automated tests/builds | Frozen commit, stable toolchain | Pending | — | — | Relevant diff/toolchain change |
| RIME/Lua/OpenCC runtime | Final deployed schemas | Pending | — | — | Artifact/schema/config change |
| Full Access off/on | Physical device | Pending | — | — | Access/onboarding/fallback change |
| Keyboard host/device matrix | Physical device, Release build | Pending | — | — | UI/Core/RIME/support change |
| Performance/memory/jetsam | Physical device, Release build | Pending | — | — | Performance-sensitive change |
| Accessibility/appearance | Supported devices/layouts | Pending | — | — | UI/support change |
| Privacy/security/licenses | Final binary and public policy | Pending | — | — | Binary/policy/dependency change |
| App Store metadata/screenshots | Final supported scope | Pending | — | — | Scope/copy/screenshot change |
| TestFlight smoke | Uploaded build | Pending | — | — | Uploaded build change |

## Failed Or Skipped Gates

No skipped release gate is accepted by default. Add one row for every failure or skip.

| Gate | Failed/skipped reason | Impact | Owner | Product decision | Expiry/follow-up |
|---|---|---|---|---|---|
| — | — | — | — | — | — |

## External Action Log

| Time | Action | Explicit authorization source | Actor/account boundary | Result/artifact |
|---|---|---|---|---|
| `2026-08-21 Asia/Shanghai` | Apple Developer Program activation | Human Product Owner reported completion in active Codex task | Human Product Owner; Codex performed read-only Xcode observation only | Human-attested active membership; Xcode account visible; team/access were still `UNKNOWN` at this observation and were subsequently verified below |
| `2026-08-21 Asia/Shanghai` | Connect Xcode Cloud to GitHub and create first workflow | Human Product Owner replied `继续` after Codex identified the persistent repository-access boundary | Xcode Cloud / GitHub; current repository only | Connection succeeded; Developer Team `chenkai shen` / Admin; workflow `Default` created with `Latest Release`; no build or distribution started |
| `2026-08-21 Asia/Shanghai` | Run no-distribution Cloud Build pilot | Same bounded authorization; Human Product Owner supplied a temporary proxy and asked Codex to continue | Xcode Cloud workflow `Default`; feature branch only | Build 1 on `cdc6bfe` passed with Xcode 26.6 / macOS Tahoe 26.6.2; post-clone RIME bootstrap verified 12 artifacts; iOS build completed with no Issues; no Archive or distribution |

## Release Decision

- **Quality conclusion:** Pending
- **Architecture/privacy conclusion:** Pending where applicable
- **Product Gate:** Pending
- **App Store submission authorization:** Not granted by this record
- **Manual release authorization:** Not granted by this record
- **Residual risks:** Pending final evidence
