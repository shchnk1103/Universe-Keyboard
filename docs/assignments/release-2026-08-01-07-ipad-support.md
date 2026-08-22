# Assignment: RELEASE-2026-0801-07 — iPad 首发支持与验证

**Policy version:** `1.0.0`
**Lifecycle status:** `Active — iOS 18 Simulator matrix complete; release-toolchain runtime gate pending`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner decided that iPad cannot be excluded from V1.0 and authorized the current Codex task to select and perform KOS-compatible remaining release execution roles in the active Codex task, `2026-07-20 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead

## Assignment

- **Domain Owner:** ⌨️ Keyboard Experience Maintainer
- **Executor:** Current Codex task acting as ⌨️ Keyboard Experience execution thread
- **Environment Executor:** Current Codex task for iPad simulator operations; the Human Product Owner remains the required iPad physical-device operator and final Product Gate
- **Human Dependency:** Human Product Owner — authorizes iOS 18 iPad Simulator for the pre-external candidate, later supplies targeted physical-iPad external evidence when available, and retains the final App Store iPad Product Gate
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward when support changes keyboard geometry, lifecycle, target configuration or cross-target contracts
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer
- **Supporting Domain:** 📱 App & Data Operations Maintainer for iPad main-App layout, settings and App Store material impact
- **Handoff Target:** Quality Reviewer, then Product Lead and tasks 04/05

## Boundary

- **Scope:** Make the containing App and Keyboard Extension usable and verifiable on supported iPad orientations and size classes; establish the supported iPad matrix, keyboard geometry, accessibility states, screenshots and final device evidence required by the release scope.
- **Non-goals:** No unsupported “universal” claim without a physical-device matrix; no new major keyboard feature; no change to input semantics, RIME deployment ownership or Full Access privacy contract without the required review.
- **Required Inputs:** [`RELEASE-2026-0801-02`](release-2026-08-01-02-scope-freeze.md), [`PD-RELEASE-2026-0801-EXTERNAL-TESTFLIGHT-CANDIDATE`](../product-decisions/RELEASE-2026-0801-external-testflight-candidate.md), `UI_STYLE_GUIDE.md`, `KEYBOARD_LAYOUT.md`, `RELEASE_CHECKLIST.md`, task 04 device matrix, task 05 screenshot/material requirements and representative/final archive.

## Gates

- **Entry Criteria:** Executor named; pre-external iOS 18 iPad Simulator model/OS/orientation matrix proposed; representative release-candidate build available; no required field for this phase is `UNKNOWN`. Historical physical-iPad observations do not replace later external/App Store device evidence.
- **Exit Criteria:** For the external TestFlight candidate, Main App and keyboard layouts, VoiceOver, Dynamic Type, light/dark mode and rotation are reviewed on the iOS 18 iPad Simulator matrix and handed to tasks 04/05 with explicit Simulator grade. Targeted physical-iPad external evidence remains a post-approval residual and a blocker for a final App Store iPad compatibility claim; Quality issues an explicit bounded conclusion.
- **Stop Conditions:** Required iPad geometry demands an unapproved input/lifecycle redesign; Simulator evidence is presented as physical-device/performance proof; iPad-only defect is hidden by excluding it from evidence; final archive differs from the tested build; App Store submission attempts to close physical-iPad evidence without Product/Quality revalidation.

## Handoff

- **Required Handoff Content:** supported iPad matrix, devices/OS/orientations, screenshots, changed files, test results, accessibility observations, failures/skips, residual risk and App Store screenshot requirements.
- **Revalidation Trigger:** iPad support target, keyboard geometry, orientation policy, deployment target, release archive or accessibility contract changes.

## Active Simulator Preflight

- **Authorization / acknowledgement:** `2026-08-21 Asia/Shanghai`，Human Product Owner 明示授权当前 Codex task 继续，并允许把简单的 Simulator 启动操作交回本人执行；当前 Executor / Environment Executor 接受本 Assignment 的 iOS 18 Simulator 范围与停止条件。
- **Representative source:** `codex/external-testflight-cloud-prep` based on `c339591`, plus the explicitly authorized candidate VoiceOver semantics remediation and its regression test in the current validated working tree. It is representative Simulator preflight source, not an RC, Archive or final release artifact.
- **Matrix:** iPad (10th generation) / iOS 18.0 为主矩阵；iPad mini (6th generation) / iOS 18.0 与 iPad Pro 13-inch (M4) / iOS 18.0 为尺寸边界。主矩阵覆盖竖/横屏、浅/深色、默认与 accessibility Dynamic Type、基础 VoiceOver；边界设备覆盖竖/横屏与关键 Main App / Keyboard surfaces。
- **Run Header / evidence:** [`../evidence/release-2026-08-01-07-ios18-ipad-simulator-preflight-2026-08-21.md`](../evidence/release-2026-08-01-07-ios18-ipad-simulator-preflight-2026-08-21.md)
- **Current gate result:** 三档 iPad / iOS 18 Simulator 的关键矩阵已完成；Xcode 26.6 的 `1030` 项 KeyboardCore 测试通过，Xcode 27 + iOS 18 的完整 Main App/Keyboard 测试及 Debug/Release build 通过。精确的本地 Xcode 26.6 iOS gate 因其 iOS 26.5 Simulator platform/runtime 未安装而保持 pending，不能用 Xcode 27 补充证据冒充关闭。
- **Non-claims:** 不替代物理 iPad、性能、Jetsam、真实 Full Access、最终 archive 或 Product Gate；发现 production defect 时停止扩大范围，先记录并交回对应实现 Assignment。

## Exploratory Environment Observation

- **Observed:** `2026-07-20 Asia/Shanghai`; Device Hub reports a connected iPad Pro (11-inch, 3rd generation). A read-only installed-app query reports `Universe Keyboard` version `1.0` / build `1`.
- **Home layout observation:** Human-provided portrait and landscape Home screenshots show the top navigation and local input-count card fully visible, with no observed clipping, overlap or unsafe-area collision. This is a static visual observation only.
- **Boundary:** This only establishes that a user-deployed exploratory build is present. It provides no release conclusion for layout, keyboard behavior, accessibility, Full Access, performance, crash/jetsam or App Store support, and expires when the build or device state changes.
