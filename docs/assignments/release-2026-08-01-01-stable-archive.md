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
- **Required Inputs:** Parent Assignment; `RELEASE_CHECKLIST.md`; final scope decision; Apple-supported Xcode/SDK; signing account; RIME vendor manifest; final version/build decision.

## Gates

- **Entry Criteria:** Executor and Environment Executor named; stable toolchain usable; release commit selected; signing access available; no required field is `UNKNOWN`.
- **Exit Criteria:** Stable-toolchain Release build and signed archive succeed; archive validation is recorded; exact archive/dSYM locations and hashes are retained; extension and privacy assets are verified; upload result is recorded only if separately authorized.
- **Stop Conditions:** Beta-only artifact; missing platform/signing access; archive differs from release commit; validation warning affects submission; destructive signing/account change; external upload lacks explicit approval.

## Handoff

- **Required Handoff Content:** commit/tag, Xcode/SDK, archive path/hash, signing team, version/build, validation output, dSYM, skipped checks, upload authorization/result and residual risks
- **Revalidation Trigger:** release commit, Xcode/SDK, signing identity, entitlements, bundle contents, version/build or submission policy changes
