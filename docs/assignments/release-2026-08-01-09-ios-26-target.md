# Assignment: RELEASE-2026-0801-09 — iOS 26.0 最低部署目标调整

**Policy version:** `1.0.0`
**Lifecycle status:** `Assigned — Architecture No-Go; Entry Criteria blocked`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner approved iOS 26.0+ as the V1.0 minimum OS and authorized the current Codex task to select and perform KOS-compatible remaining release execution roles in the active Codex task, `2026-07-20 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead

## Assignment

- **Domain Owner:** 📱 App & Data Operations Maintainer
- **Executor:** Current Codex task acting as 📱 App & Data Operations execution thread
- **Environment Executor:** Current Codex task for locally available Xcode build/test operations; the Human Product Owner supplies signing access for any signed archive
- **Human Dependency:** Human Product Owner — provides/authorizes signing access and decides any compatibility-risk acceptance; no upload, submission or release is authorized here
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer, independent from the implementation
- **Handoff Target:** Quality Reviewer, then task 01 and umbrella release coordinator

## Boundary

- **Scope:** Change the release project's minimum deployment target from iOS 26.4 to iOS 26.0 only after Architecture confirms the API-availability, target/configuration and cross-target boundary; build and test every affected target against the supported toolchain.
- **Non-goals:** No feature expansion, broad project-file cleanup, API-availability suppression, deployment-boundary change, signing workaround, archive upload or App Store submission.
- **Required Inputs:** [`RELEASE-2026-0801-02`](release-2026-08-01-02-scope-freeze.md), its [independent review handoff](release-2026-08-01-02-review-handoff.md), current Xcode project settings, `PROJECT_CONTEXT.md`, `RELEASE_CHECKLIST.md`, stable-toolchain availability and the final archive path from task 01.

## Gates

- **Entry Criteria:** Architecture review confirms the allowed change boundary; Executor acknowledges the affected target matrix; stable toolchain is usable; no required Assignment field is `UNKNOWN`.
- **Exit Criteria:** Every affected target/test target has the explicit iOS 26.0 setting required by the approved boundary; no unavailable API or configuration regression remains; Quality records supported-toolchain build/test evidence; task 01 validates the final signed archive.
- **Stop Conditions:** An API or dependency requires iOS 26.4 without an approved compatible alternative; target change alters RIME/Extension deployment ownership; stable toolchain cannot build the target; a beta-only build is used as release proof; a signing/upload action lacks explicit authorization.

## Architecture Review

- **Conclusion:** `No-Go — implementation not authorized`.
- **Evidence:** [`RELEASE-2026-0801-09 iOS 26.0 target Architecture Review`](../evidence/release-2026-0801-09-ios-26-target-architecture-review.md).
- **Blocking Entry Criteria:** The locally observed Xcode is beta-only, and no iOS 26.0 Simulator runtime or physical device is available. The completed static preflight is explicitly non-release evidence.
- **Product Lead direction:** Do not modify the deployment target, Package platform declarations, or code. When a stable Xcode/SDK and iOS 26.0 runtime/physical device are available, return to Product Lead for Executor revalidation before any implementation begins.

## Handoff

- **Required Handoff Content:** exact project settings changed, affected targets, API/dependency availability findings, build/test outputs, stable-toolchain version, residual compatibility risks and final archive dependency.
- **Revalidation Trigger:** Xcode/SDK, project target matrix, dependency/API usage, supported-device/OS decision or release archive changes.
