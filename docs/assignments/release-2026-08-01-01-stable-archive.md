# Assignment: RELEASE-2026-0801-01 — 稳定工具链、Archive 与上传就绪

**Policy version:** `1.0.0`
**Lifecycle status:** `Assigned — Entry Criteria pending`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner, acting as Product Lead, authorized the current Codex task to select and perform KOS-compatible remaining release execution roles in the active Codex task, `2026-07-20 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead

## Assignment

- **Domain Owner:** 🧪 Quality, Performance & Release Maintainer
- **Executor:** Current Codex task acting as 🧪 Quality, Performance & Release execution thread
- **Environment Executor:** Current Codex task for locally available Mac/Xcode build and archive operations; the Human Product Owner supplies Apple account/team access when a signed archive is required
- **Human Dependency:** Human Product Owner — Apple account/team access and separate authorization for upload, submission or release
- **Architecture Reviewer:** `Not Applicable — no architecture change is authorized`
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer through a thread independent from implementation/environment repair where practical
- **Handoff Target:** Product Lead for upload/submission authorization; umbrella release coordinator for status synchronization

## Boundary

- **Scope:** Make the stable App Store-supported Xcode installation usable; freeze the release commit; produce a signed Release archive; validate the archive, extension embedding, privacy manifests, icons, entitlements, version/build, dSYM and export-compliance answers; prepare an upload-ready artifact.
- **Non-goals:** No production feature change, warning suppression, signing workaround, TestFlight upload, App Store submission or release without separate authorization.
- **Required Inputs:** Parent Assignment; [`PD-RELEASE-2026-0801-EXTERNAL-TESTFLIGHT-CANDIDATE`](../product-decisions/RELEASE-2026-0801-external-testflight-candidate.md); `RELEASE_CHECKLIST.md`; final scope decision; Apple Developer Program membership; App Store Connect App Record/access; Xcode Cloud stable-toolchain pilot; signing account; RIME vendor manifest; a reviewed Cloud post-clone dependency bootstrap that reuses the pinned vendor fetch/verification contract; final version/build decision.

## Gates

- **Entry Criteria:** Executor and Environment Executor named; Apple Developer/App Store Connect access available; Xcode Cloud has proven a supported stable Xcode environment, repository access, the shared archive scheme, post-clone RIME vendor bootstrap, signing and artifact retention; all remaining fixes including kaomoji are reviewed; release commit selected; no required field is `UNKNOWN`.
- **Exit Criteria:** Stable-toolchain Release build and signed archive succeed; archive validation is recorded; exact archive/dSYM locations and hashes are retained; extension and privacy assets are verified; upload result is recorded only if separately authorized.
- **Stop Conditions:** Beta-only artifact; missing platform/signing access; archive differs from release commit; validation warning affects submission; destructive signing/account change; external upload lacks explicit approval.

## Handoff

- **Required Handoff Content:** commit/tag, Xcode/SDK, archive path/hash, signing team, version/build, validation output, dSYM, skipped checks, upload authorization/result and residual risks
- **Revalidation Trigger:** release commit, local/Cloud Xcode or macOS support, Cloud workflow, signing identity, entitlements, bundle contents, version/build or submission policy changes

## Preliminary Cloud Evidence — 2026-08-22

- Human Product Owner separately authorized configuring and running one no-distribution Archive pilot.
- Xcode Cloud workflow `Archive Pilot (No Distribution)` is manual `main` only, uses `Latest Release`, runs `Archive - iOS`, sets Distribution Preparation to `None` and has no post-actions.
- Build 3 archived and completed App Store distribution signing for `main` commit `4fd3ce70d9acfc54472923fb7d66ff0589e11f6d` with Xcode 26.6 (`17F113`) / macOS Tahoe 26.6.2 (`25G83`). TestFlight remained empty.
- Evidence grade: `Executor-recorded`; [build record](https://appstoreconnect.apple.com/teams/82c0e48e-c8bf-442c-9db9-19ed80ce4d87/apps/6804236252/ci/builds/6aec0bbf-6bbe-4cd3-81b5-8382f2d3898d/summary).
- This satisfies the preliminary Cloud Archive/signing feasibility portion only. Entry Criteria still fail because final version/build, frozen RC and independent review are pending.
- **2026-08-24 supersession:** the retained Archive, App/Keyboard dSYMs, logs, XCResult and non-Internal-Only App Store export were downloaded and inspected. UUID mapping, Cloud distribution metadata and IPA retention passed at pilot grade. See [`cloud artifact retention pilot`](../evidence/release-2026-08-01-01-cloud-artifact-retention-pilot-2026-08-24.md). This remains non-RC evidence and must be repeated for the frozen candidate.
