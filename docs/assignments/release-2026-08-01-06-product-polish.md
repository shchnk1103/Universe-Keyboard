# Assignment: RELEASE-2026-0801-06 — 首发键盘与主 App 产品打磨

**Policy version:** `1.0.0`
**Lifecycle status:** `Active — Full Access deferral remediation verified; other polish residuals remain`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | Active |
| **Phase** | Full Access “稍后再开启” remediation verified; remaining Product Polish residuals stay open |
| **Non-claims** | No visual redesign, input/RIME semantic change, RC freeze, physical-device accessibility certification or release approval |
| **Next** | Preserve the verified J2 deferral semantics while continuing separately authorized Product Polish work |
| **Residuals** | Complete accessibility and physical-device certification remain open; local Xcode 26.6 iOS execution still requires its missing platform/runtime |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner, acting as Product Lead, authorized the current Codex task to select and perform KOS-compatible remaining release execution roles, `2026-07-20 Asia/Shanghai`; explicitly authorized the minimal candidate VoiceOver remediation and clarified/authorized the Full Access deferral semantics on `2026-08-22 Asia/Shanghai`
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

## Observed Release Residuals

- `2026-08-22` iPad (10th generation) / iOS 18 Simulator / VoiceOver initially spoke only the compact Chinese candidate text (for example `呢`) and omitted its actionable role and configured hint. The Human Product Owner then explicitly authorized a minimal remediation. `CandidateCollectionCell` now declares itself as an accessibility element with the `.button` trait; the existing candidate label and “双击选择候选词” hint remain unchanged. Strict formatting, the focused source-contract test, the complete iOS 18 Main App/Keyboard suites, Debug/Release compilation/install and Human Simulator revalidation passed. The observed speech is now “呢，按钮，双击选择候选词”. This closes only the identified candidate-role residual; it does not constitute complete accessibility, physical-device or release certification. Exact local Xcode 26.6 iOS execution remains pending its missing iOS 26.5 Simulator platform/runtime. Evidence: [`release-2026-08-01-07-ios18-ipad-simulator-preflight-2026-08-21.md`](../evidence/release-2026-08-01-07-ios18-ipad-simulator-preflight-2026-08-21.md).
- `2026-08-22` the Human Product Owner clarified J2 deferral semantics: “稍后再开启” must continue to J3/J4 rather than exit the Guide, while Full Access remains incomplete and returns after the other steps finish. The implementation stores presentation-only deferral, keeps completion/TipKit flags false, and lets observed shared-data failure override deferral. Focused state tests cover the complete J2 → J3 → J4 → J2 state path; complete iOS 18 Main App/Keyboard suites, KeyboardCore, RimeBridge, RIME Vendor verification and Debug/Release builds pass. On a separately deployed iPhone 16 Pro / iOS 18 Simulator, the Human operator tapped “稍后再开启” and confirmed the App entered resource preparation/scheme selection without navigating to Search. This closes the identified no-op/false-completion affordance residual without claiming complete accessibility, physical-device or release certification. Evidence: [`release-2026-08-01-07-ios18-ipad-simulator-preflight-2026-08-21.md`](../evidence/release-2026-08-01-07-ios18-ipad-simulator-preflight-2026-08-21.md).
