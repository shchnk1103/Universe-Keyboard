# Assignment: RELEASE-2026-0801-07 — iPad 首发支持与验证

**Policy version:** `1.0.0`
**Lifecycle status:** `Assigned — Entry Criteria pending`
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

## Exploratory Environment Observation

- **Observed:** `2026-07-20 Asia/Shanghai`; Device Hub reports a connected iPad Pro (11-inch, 3rd generation). A read-only installed-app query reports `Universe Keyboard` version `1.0` / build `1`.
- **Home layout observation:** Human-provided portrait and landscape Home screenshots show the top navigation and local input-count card fully visible, with no observed clipping, overlap or unsafe-area collision. This is a static visual observation only.
- **Boundary:** This only establishes that a user-deployed exploratory build is present. It provides no release conclusion for layout, keyboard behavior, accessibility, Full Access, performance, crash/jetsam or App Store support, and expires when the build or device state changes.
