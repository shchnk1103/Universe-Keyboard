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
- **Environment Executor:** Current Codex task for iPad simulator operations and Device Hub-mediated interaction with the connected iPad; the Human Product Owner remains the final iPad Product Gate
- **Human Dependency:** Human Product Owner — provides/unlocks the iPad and enables the keyboard/Full Access as needed; performs actions that Device Hub cannot expose and the final iPad Product Gate
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward when support changes keyboard geometry, lifecycle, target configuration or cross-target contracts
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer
- **Supporting Domain:** 📱 App & Data Operations Maintainer for iPad main-App layout, settings and App Store material impact
- **Handoff Target:** Quality Reviewer, then Product Lead and tasks 04/05

## Boundary

- **Scope:** Make the containing App and Keyboard Extension usable and verifiable on supported iPad orientations and size classes; establish the supported iPad matrix, keyboard geometry, accessibility states, screenshots and final device evidence required by the release scope.
- **Non-goals:** No unsupported “universal” claim without a physical-device matrix; no new major keyboard feature; no change to input semantics, RIME deployment ownership or Full Access privacy contract without the required review.
- **Required Inputs:** [`RELEASE-2026-0801-02`](release-2026-08-01-02-scope-freeze.md), `UI_STYLE_GUIDE.md`, `KEYBOARD_LAYOUT.md`, `RELEASE_CHECKLIST.md`, task 04 device matrix, task 05 screenshot/material requirements and final archive.

## Gates

- **Entry Criteria:** Executor and iPad environment operators named; supported iPad/OS/orientation matrix proposed; final or representative release-candidate build available; no required field is `UNKNOWN`. Device Hub availability was observed on `2026-07-20 Asia/Shanghai` for an iPad Pro (11-inch, 3rd generation); this does not replace final-archive device evidence.
- **Exit Criteria:** Main App and keyboard layouts, VoiceOver, Dynamic Type, light/dark mode and rotation are reviewed on the supported matrix; physical-device results, screenshots and known limitations are handed to tasks 04/05; Quality issues an explicit conclusion.
- **Stop Conditions:** Required iPad geometry demands an unapproved input/lifecycle redesign; device evidence is unavailable; iPad-only defect is hidden by excluding it from evidence; final archive differs from the tested build.

## Handoff

- **Required Handoff Content:** supported iPad matrix, devices/OS/orientations, screenshots, changed files, test results, accessibility observations, failures/skips, residual risk and App Store screenshot requirements.
- **Revalidation Trigger:** iPad support target, keyboard geometry, orientation policy, deployment target, release archive or accessibility contract changes.

## Exploratory Environment Observation

- **Observed:** `2026-07-20 Asia/Shanghai`; Device Hub reports a connected iPad Pro (11-inch, 3rd generation). A read-only installed-app query reports `Universe Keyboard` version `1.0` / build `1`.
- **Home layout observation:** Human-provided portrait and landscape Home screenshots show the top navigation and local input-count card fully visible, with no observed clipping, overlap or unsafe-area collision. This is a static visual observation only.
- **Keyboard observation:** In iPad Notes, the synthetic composition `ni hao` displayed a candidate bar with `你好` first. Selecting it left only committed `你好` in the host, cleared the marked-text underline and kept the floating keyboard visible. No real user content was used.
- **Nine-key observation:** The user switched to 9-key successfully. A synthetic `ni hao` composition showed the compact segmented path `mi / ni / m / n / o`, a visible candidate bar and the 9-key chrome without clipping; the user reported that `你好` can be committed. The screenshot itself captures the in-progress composition, not a final release result.
- **Single-key selection observation:** In iPad Notes, starting from an empty composition, one `MNO` input followed by `选拼音` selected `m`; a second `选拼音` selected `n`. Each state updated the host marked text, retained the expected `m / n / o` order and did not commit a raw letter or candidate. The Human Product Owner completed this synthetic-text check and then authorized the current Codex task to conduct subsequent Device Hub-mediated iPad interaction.
- **Device Hub follow-up:** The current Codex task then used Device Hub on the same connected iPad to observe the remaining cyclic sequence `o → m → n → o`. Each transition updated the marked text and candidate bar without raw-letter submission. One delete cleared the synthetic marked text and restored the empty host state. This remains exploratory evidence for the installed build, not final release acceptance.
- **Rotation observation:** With an empty synthetic Notes document, Device Hub rotated the connected iPad to portrait and back to landscape. The 9-key floating keyboard remained in the selected layout and was fully visible in both orientations, with no observed clipping, overlap or unsafe-area collision. This is visual exploration only; VoiceOver, Dynamic Type and final-archive validation remain open.
- **Boundary:** This only establishes that a user-deployed exploratory build is present. It provides no release conclusion for layout, keyboard behavior, accessibility, Full Access, performance, crash/jetsam or App Store support, and expires when the build or device state changes.
