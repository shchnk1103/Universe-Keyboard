# Assignment: RELEASE-2026-0801-10 — iOS 18.0 最低部署目标（先过编译）

**Policy version:** `1.0.0`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)
**Product Decision:** [`PD-RELEASE-2026-0801-MINIMUM-OS-IOS18`](../product-decisions/RELEASE-2026-0801-minimum-os-ios18.md)
**Repository change types:** `Assignment`, `State`, `Evidence`, `Documentation`, `Build configuration`

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Reviewed` — Phase 1 Quality `Pass with conditions`; narrowed Phase 2 Human-accepted |
| **Phase** | Phase 1 compile 已独立复验；收窄 Phase 2 已 Human 接受 |
| **Non-claims** | 不宣称独立 Quality 设备矩阵、稳定工具链 Archive 或可上架。Phase 2 Human 接受 ≠ Release Gate |
| **Next** | 工作区可提交；`01` 仍要稳定工具链 Archive。`07`/`04` 发布级 iPad/设备矩阵仍开 |
| **Residuals** | R10-01/02 Human 接受（收窄）；R10-04 与 Q-R10-01…03 仍开 |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner 在 Active Codex 任务中批准 `PD-RELEASE-2026-0801-MINIMUM-OS-IOS18`，`2026-08-18 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead

## Assignment

- **Domain Owner:** 📱 App & Data Operations Maintainer
- **Executor:** Current Codex task acting as 📱 App & Data Operations execution thread
- **Environment Executor:** Current Codex task for local unsigned `xcodebuild` / package-platform inspection. The Human Product Owner supplies signing access for any later signed archive.
- **Human Dependency:** Human Product Owner — already decided the iOS 18.0 floor and deferred chrome. No device, signing, upload or release action is required for Phase 1.
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer, independent from the implementation
- **Handoff Target:** Quality Reviewer after Phase 1 compile evidence; Phase 2 chrome remains a later Product-authorized task

## Boundary

- **Scope:** Change every shipping and test `IPHONEOS_DEPLOYMENT_TARGET` and the two local Package iOS platforms from the current mixed 26.4 / 18.0 state to **iOS 18.0**. Update the current deployment-target statement in `PROJECT_CONTEXT.md` and the superseded Minimum OS sources. Fix only compiler-proven unavailable APIs with a minimal `#available` alternative. Revert unrelated `Keyboard.xcscheme` host-app edits if they remain in the working tree.
- **Non-goals:** No keyboard chrome / surface restyle, no RIME/Extension ownership change, no Vendor/XCFramework rewrite, no availability-warning suppression, no test weakening, no signed Archive, no TestFlight/App Store action, no iOS 18 runtime or visual claim.
- **Required Inputs:**
  - [`PD-RELEASE-2026-0801-MINIMUM-OS-IOS18`](../product-decisions/RELEASE-2026-0801-minimum-os-ios18.md)
  - [`RELEASE-2026-0801-02`](release-2026-08-01-02-scope-freeze.md)
  - [`RELEASE-2026-0801-09`](release-2026-08-01-09-ios-26-target.md) (superseded goal)
  - [Architecture review](../evidence/release-2026-0801-10-ios-18-target-architecture-review.md)
  - `Universe Keyboard.xcodeproj/project.pbxproj`
  - `Packages/KeyboardCore/Package.swift`
  - `Packages/RimeBridge/Package.swift`
  - `docs/PROJECT_CONTEXT.md`

## Gates

- **Entry Criteria:** Product Decision recorded; Architecture review authorizes the compile-only boundary; Executor acknowledges the full target matrix; no required Assignment field is `UNKNOWN`. iOS 18 Simulator/device and stable Xcode are **not** Entry Criteria for Phase 1.
- **Exit Criteria (Phase 1):** Every project configuration and both Package iOS platforms are 18.0; Debug and Release compile of the `Universe Keyboard` scheme succeed with a clean DerivedData path; only compiler-proven availability edits exist; Executor-recorded evidence is filed; Quality has not been marked passed by the Executor.
- **Stop Conditions:** An API or binary requires a floor above iOS 18.0 without an approved compatible alternative; the change alters RIME/Extension deployment ownership; warnings/concurrency/availability checks are weakened to obtain a pass; chrome/style work is pulled into Phase 1; a beta-only build is presented as release proof; a signing/upload action lacks explicit authorization.

## Architecture Review

- **Conclusion:** `Go — compile-only target alignment authorized`.
- **Evidence:** [`RELEASE-2026-0801-10 iOS 18.0 target Architecture Review`](../evidence/release-2026-0801-10-ios-18-target-architecture-review.md).
- **Independence note:** The review is performed in the same Codex thread as the Executor. It is a boundary authorization, not a second-person audit and not a Quality conclusion.

## Phase 2 Human Gate

- **Conclusion:** `Accepted` after scope narrow.
- **Decision:** [`PD-RELEASE-2026-0801-10-PHASE2-NARROW`](../product-decisions/RELEASE-2026-0801-10-phase2-narrow.md)
- **Evidence:** [`release-2026-0801-10-ios-18-phase2-human-evidence.md`](../evidence/release-2026-0801-10-ios-18-phase2-human-evidence.md)
- **Non-claims:** 不是独立 Quality，不是发布设备矩阵，不是 Archive / 上架。

## Quality Review

- **Conclusion:** `Pass with conditions`.
- **Evidence:** [`release-2026-08-01-10-quality-review.md`](release-2026-08-01-10-quality-review.md) · [`release-2026-0801-10-ios-18-target-quality-evidence.md`](../evidence/release-2026-0801-10-ios-18-target-quality-evidence.md).
- **Independence:** 独立 Quality 线程复跑；未复用 Executor DerivedData。
- **Non-claims:** 不是 Product Gate、上架、Archive 或 Phase 2 关闭。

## Handoff

- **Required Handoff Content:** exact project/package settings changed; compiler diagnostics and how they were fixed; Debug/Release commands, toolchain identity and result grade (`Executor-recorded`); residual iOS 18 chrome/runtime risks; confirmation that Quality/Release remain open.
- **Revalidation Trigger:** Product changes the minimum OS again; target matrix or Package platforms drift; an unguarded post-iOS-18 API appears; Phase 2 chrome is authorized; the release Archive or stable toolchain changes.

## Residuals

| ID | Residual | Owner | Disposition |
|---|---|---|---|
| R10-01 | iOS 18 keyboard surface / chrome | Keyboard UI | accept — narrowed Phase 2 Human-accepted; no full chrome rewrite |
| R10-02 | iOS 18 Simulator/device runtime and input matrix | Human Product Owner | accept — Human attested 26-key / 九键 / 候选 / iPad; not Quality-reverified |
| R10-03 | Independent Quality re-verification of the 18.0 compile | Quality Reviewer | accept — Phase 1 compile recorded in [quality review](release-2026-08-01-10-quality-review.md) |
| R10-04 | Final signed Archive on a stable toolchain | `RELEASE-2026-0801-01` | accept — not in this task |
