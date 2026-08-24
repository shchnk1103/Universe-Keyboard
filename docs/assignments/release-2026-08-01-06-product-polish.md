# Assignment: RELEASE-2026-0801-06 — 首发键盘与主 App 产品打磨

**Policy version:** `1.0.0`
**Lifecycle status:** `Active — Full Access deferral remediation verified; other polish residuals remain`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | Active |
| **Phase** | R-06-01…07 closed at Simulator/source grade; R-06-08/09 deferred to post-upload TestFlight testers; R-06-10 is a local toolchain residual |
| **Non-claims** | No visual redesign, input/RIME semantic change, RC freeze, complete accessibility certification, physical-device visual Gate, or skipped TD-003/004/005 |
| **Next** | 06 没有已知的前冻点代码修复；保持 R-06-08/09 到 post-upload tester Gate。R-06-10 由最终 Cloud 构建提供稳定发布工具链证据，但不把本机缺失 runtime 记成通过，也不要求买真机 |
| **Residuals** | 见下方 Residual Inventory |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner, acting as Product Lead, authorized the current Codex task to select and perform KOS-compatible remaining release execution roles, `2026-07-20 Asia/Shanghai`; explicitly authorized the minimal candidate VoiceOver remediation and clarified/authorized the Full Access deferral semantics on `2026-08-22 Asia/Shanghai`; on `2026-08-23 Asia/Shanghai` authorized the current Grok task to continue remaining `RELEASE-2026-0801-06` residuals strictly under KOS; later the same day stated physical-device visual/accessibility certification must wait for TestFlight testers because the available device set is too small
- **Product Approver:** Human Product Owner acting as Product Lead

## Assignment

- **Domain Owner:** ⌨️ Keyboard Experience Maintainer
- **Executor:** Current Codex task acting as ⌨️ Keyboard Experience execution thread for residual handoff and revalidation only
- **Environment Executor:** Current Codex task for any newly authorized simulator visual/accessibility operations; the Human Product Owner remains the physical-device visual operator, Simulator VoiceOver operator and final Product Gate
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

## Current Reassignment

- **Previous Executor:** Grok task that completed the remaining executable polish audit and deferred R-06-08/09 to TestFlight testers
- **New Executor:** Current Codex task
- **Reason:** Human Product Owner explicitly asked Codex to take over and continue the remaining release work
- **Effective date:** `2026-08-24 Asia/Shanghai`
- **Decision source:** Human Product Owner acting as Product Lead, current Codex task
- **Remaining work at reassignment:** preserve closed R-06-01…07; do not invent pre-freeze work from R-06-08/09; revalidate only if the final candidate or supported matrix changes

## Residual Inventory

| ID | Item | Status | Owner | Next allowed action |
|---|---|---|---|---|
| R-06-01 | Compact candidate VoiceOver spoke label only | **Closed** (Simulator smoke) | Keyboard Experience | Do not reopen unless revalidation trigger |
| R-06-02 | J2 “稍后再开启” no-op / false completion | **Closed** (Simulator smoke) | Keyboard Experience | Preserve verified deferral semantics |
| R-06-03 | Dark-mode toolbar `吗` low contrast | **Closed — not Extension-owned** | System `UITextInputAssistantItem` | Do not “fix” iPadOS assistant bar |
| R-06-04 | AXXXL Main App content behind keyboard | **Closed** (primary Simulator scroll) | Keyboard Experience | Do not reopen unless revalidation trigger |
| R-06-05 | Main App Diagnostics breadth unreviewed | **Closed — source review** | App & Data Operations / 06 Environment Executor | No no-op found. iPad Simulator visual walk not repeated this slice. Evidence: [`release-2026-08-01-06-residual-review-2026-08-23.md`](../evidence/release-2026-08-01-06-residual-review-2026-08-23.md) |
| R-06-06 | Complete VoiceOver navigation/order | **Closed — Human Simulator speech smoke** | Keyboard Experience; Human operated VoiceOver | Speech recorded 2026-08-23. Not R-06-08 complete certification |
| R-06-07 | Settings still expose 智能纠错 / 输入洞察 | **Closed — keep + non-AI copy** | Product Lead chose keep; Executor reworded | Titles kept. Subtitles/body now state local non-AI boundary |
| R-06-08 | Complete accessibility certification | **Deferred — TestFlight testers** | Human Product Gate | Not skipped. External testers after upload; Simulator smoke (R-06-01/06) is not this Gate |
| R-06-09 | Physical-device visual Product Gate | **Deferred — TestFlight testers** | Human Product Owner | Same deferral. Does **not** close or skip [`RELEASE-2026-0801-04`](release-2026-08-01-04-device-performance.md) or TD-003/004/005 |
| R-06-10 | Exact local Xcode 26.6 iOS 26.5 Simulator runtime | **Open — environment, not a phone** | Environment | This Mac has Xcode 26.6 but not the iOS 26.5 Simulator platform, so local 26.6 iOS test/build cannot run. Xcode Cloud Archive pilot already used Xcode 26.6. Do not treat Xcode 27 local runs as that gate |

## Observed Release Residuals

- `2026-08-22` iPad (10th generation) / iOS 18 Simulator / VoiceOver initially spoke only the compact Chinese candidate text (for example `呢`) and omitted its actionable role and configured hint. The Human Product Owner then explicitly authorized a minimal remediation. `CandidateCollectionCell` now declares itself as an accessibility element with the `.button` trait; the existing candidate label and “双击选择候选词” hint remain unchanged. Strict formatting, the focused source-contract test, the complete iOS 18 Main App/Keyboard suites, Debug/Release compilation/install and Human Simulator revalidation passed. The observed speech is now “呢，按钮，双击选择候选词”. This closes only the identified candidate-role residual; it does not constitute complete accessibility, physical-device or release certification. Exact local Xcode 26.6 iOS execution remains pending its missing iOS 26.5 Simulator platform/runtime. Evidence: [`release-2026-08-01-07-ios18-ipad-simulator-preflight-2026-08-21.md`](../evidence/release-2026-08-01-07-ios18-ipad-simulator-preflight-2026-08-21.md).
- `2026-08-22` the Human Product Owner clarified J2 deferral semantics: “稍后再开启” must continue to J3/J4 rather than exit the Guide, while Full Access remains incomplete and returns after the other steps finish. The implementation stores presentation-only deferral, keeps completion/TipKit flags false, and lets observed shared-data failure override deferral. Focused state tests cover the complete J2 → J3 → J4 → J2 state path; complete iOS 18 Main App/Keyboard suites, KeyboardCore, RimeBridge, RIME Vendor verification and Debug/Release builds pass. On a separately deployed iPhone 16 Pro / iOS 18 Simulator, the Human operator tapped “稍后再开启” and confirmed the App entered resource preparation/scheme selection without navigating to Search. This closes the identified no-op/false-completion affordance residual without claiming complete accessibility, physical-device or release certification. Evidence: [`release-2026-08-01-07-ios18-ipad-simulator-preflight-2026-08-21.md`](../evidence/release-2026-08-01-07-ios18-ipad-simulator-preflight-2026-08-21.md).
