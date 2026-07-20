# Assignment: RELEASE-2026-0801-06 — 首发键盘与主 App 产品打磨

**Policy version:** `1.0.0`
**Lifecycle status:** `Assigned — Entry Criteria pending`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner, acting as Product Lead, authorized the current Codex task to select and perform KOS-compatible remaining release execution roles in the active Codex task, `2026-07-20 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead

## Assignment

- **Domain Owner:** ⌨️ Keyboard Experience Maintainer
- **Executor:** Current Codex task acting as ⌨️ Keyboard Experience execution thread
- **Environment Executor:** Current Codex task for simulator visual/accessibility operations; the Human Product Owner remains the physical-device visual operator and final Product Gate
- **Human Dependency:** Human Product Owner — selects the desired treatment for incomplete affordances and performs final visual Product Gate
- **Architecture Reviewer:** `Not Applicable — unless a fix changes input semantics, lifecycle or cross-target ownership`
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer
- **Supporting Domain:** 📱 App & Data Operations Maintainer for main-App Toast/settings/about UI
- **Handoff Target:** Quality Reviewer, then Product Lead

## Boundary

- **Scope:** Remove or truthfully disable incomplete user-visible affordances; fix Toast/safe-area overlap; review keyboard/main-App layout, VoiceOver, Dynamic Type, dark mode, orientation, error copy and release-facing settings information architecture; ensure the retained Home input-count card is presented as local basic counting rather than an AI capability; add no new major feature.
- **Non-goals:** No kaomoji content system, new correction engine, unrelated visual redesign, input-state rewrite or feature expansion after scope freeze.
- **Required Inputs:** Final scope decision; UI style guide; current simulator finding; nine-key Product Contract/Assignment; accessibility and physical-device release matrix.

## Gates

- **Entry Criteria:** Executors named; scope task decides incomplete-feature treatment; affected domain boundaries are explicit; no required field is `UNKNOWN`.
- **Exit Criteria:** No visible control is knowingly a no-op; Toasts do not obscure navigation/content; supported layouts and accessibility states are usable; settings expose product concepts rather than engineering-only status; visual evidence and regression tests are reviewed.
- **Stop Conditions:** Fix requires new product semantics or major feature; accessibility regresses; layout is validated only by one cached simulator state; raw input/commit behavior changes without Input Intelligence review.

## Handoff

- **Required Handoff Content:** before/after visuals, interaction behavior, changed files, tests, devices/orientations/accessibility states, unresolved visual differences and Product Gate questions
- **Revalidation Trigger:** scope, supported devices/orientations, keyboard geometry, tab/navigation style, accessibility contract or affected feature behavior changes
