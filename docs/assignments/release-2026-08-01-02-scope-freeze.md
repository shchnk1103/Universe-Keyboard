# Assignment: RELEASE-2026-0801-02 — V1.0 范围冻结

> **Supersession (Minimum OS only):** `2026-08-18 Asia/Shanghai` — Product Decision [`PD-RELEASE-2026-0801-MINIMUM-OS-IOS18`](../product-decisions/RELEASE-2026-0801-minimum-os-ios18.md) 将 V1.0 最低系统从 iOS 26.0 改为 **iOS 18.0**。实施改由 [`RELEASE-2026-0801-10`](release-2026-08-01-10-ios-18-target.md) 执行。下方表格中的历史 iOS 26.0 行保留为审计记录，不再约束实施。本 Assignment 的 Reviewed 生命周期不因此重开。


**Policy version:** `1.0.0`
**Lifecycle status:** `Reviewed — independent Architecture and Quality conclusions recorded; no Product Gate or release conclusion`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner, acting as Product Lead, appointed the current Codex task as Executor and approved the V1.0 scope decisions in the active Codex task, `2026-07-20 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead

## Assignment

- **Domain Owner:** 🧭 Product Lead
- **Executor:** Current Codex task — `RELEASE-2026-0801-02` scope-record Executor, explicitly appointed by the Product Lead
- **Environment Executor:** `Not Applicable — this task records product scope; device evidence is delegated to child task 04`
- **Human Dependency:** Human Product Owner — decides included features, excluded experiments, minimum OS, iPhone/iPad support and accepted schedule tradeoffs
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward for any feature-gate, target or durable support-boundary change
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer for testability and release impact
- **Handoff Target:** Every child Assignment Executor; umbrella release coordinator

## Boundary

- **Scope:** Freeze V1.0 user-visible features, defaults, supported devices/orientations, minimum OS, schemas, Full Access claims and explicit exclusions; reconcile open Assignments already merged into `main` with launch scope.
- **Non-goals:** No implementation, silent feature removal, inferred Product acceptance or acceptance of missing release evidence.
- **Required Inputs:** Dashboard; active feature Assignments; release audit; App Store support/screenshot requirements; release checklist and technical debt.

## Approved V1.0 Release Scope

This table is the Product Lead-approved scope record. It freezes what the release may claim; it is not final archive, device, privacy or App Store acceptance evidence.

| Area | V1.0 decision | Closure path / copy constraint |
|---|---|---|
| Devices and orientations | iPhone and iPad are supported. The final archive, device matrix, screenshots and accessibility review must cover both families and their supported orientations. | [`RELEASE-2026-0801-07`](release-2026-08-01-07-ipad-support.md), then tasks 04 and 05. Until evidence exists, App Store copy and screenshots must not imply verified iPad quality. |
| Minimum OS | **Current:** iOS 18.0 and later ([`PD-RELEASE-2026-0801-MINIMUM-OS-IOS18`](../product-decisions/RELEASE-2026-0801-minimum-os-ios18.md)). **Historical freeze (2026-07-20):** iOS 26.0 and later. No release may claim iOS 18 appearance or runtime verification until Phase 2 and the final archive are reviewed. | Implementation Assignment is [`RELEASE-2026-0801-10`](release-2026-08-01-10-ios-18-target.md) (supersedes `-09`). Task 01 still validates the final archive. |
| Included input experience | Existing baseline keyboard input, Chinese nine-key, precise-pinyin selection and post-commit continuation are in V1.0. Chinese nine-key uses the existing `rime_ice` base / `t9` effective-runtime boundary; no schema expansion is authorized here. | Nine-key chrome and precise-pinyin predecessor Assignments are closed. Post-commit continuation is closed. The still-active `KEYBOARD-LAYOUT-9KEY-PINYIN-002` is **not** a V1.0 claim until its independent review and Product Gate close. |
| Kaomoji | Kaomoji content is a required V1.0 capability, not an excluded placeholder. | [`RELEASE-2026-0801-08`](release-2026-08-01-08-kaomoji-content.md). Until it closes, the existing control must not be presented as a working content feature. |
| Basic input counts | Included: the Home card may show today's local Chinese, letter and Emoji counts. It is a basic on-device count display, not an AI feature or input-content analysis claim. | Product polish must ensure visual and accessibility copy do not promise an AI capability. |
| Advanced Typing Intelligence | Excluded from V1.0 launch scope: trends, composition, streak/history and any broader intelligence/analytics positioning. | Do not mention excluded capability in App Store copy, screenshots or review notes. Existing implementation remains governed by `TYPING-INTELLIGENCE-001`; this scope record does not remove it. |
| Contextual typo correction | Excluded from V1.0 launch scope. | Do not mention it in App Store copy, screenshots or review notes. Existing implementation remains governed by `TYPO-CORRECTION-002`; this scope record does not remove it. |
| Full Access and privacy | Full Access remains an optional shared-capability state; basic typing must remain usable when it is off. No launch copy may imply data upload or that iOS can enable the keyboard programmatically. | Task 03 must close the truthful on/off journey; task 05 must reconcile final privacy and review copy. |

### Executor Acknowledgement

The Executor has verified that the required current sources were identified: the release control Assignment and evidence ledger, Dashboard, release checklist, technical-debt/performance/privacy sources, current active feature Assignments, and the project configuration showing an iOS 26.4 deployment target with iPhone/iPad target families. No required Assignment field remains `UNKNOWN` for this scope-record task.

The scope record is complete as an Executor deliverable. Independent Architecture and Quality conclusions are recorded in the [review handoff](release-2026-08-01-02-review-handoff.md); they do not constitute a Product Gate, release conclusion, or authorization to alter production code. The required iOS target, iPad, kaomoji, Full Access, final Archive and App Store follow-ups remain open under their child Assignments.

## Gates

- **Entry Criteria:** **Met.** Executor named and acknowledged; Human Product Owner supplied decisions; current active/closed feature sources identified; no required field is `UNKNOWN`.
- **Exit Criteria:** **Reviewed.** The approved table names included/excluded/feature-gated work, makes iPad and iOS 26.0 explicit, creates closure paths for newly included work, and constrains App Store copy. Independent Architecture and Quality conclusions are recorded; they do not close any child gate or create a release conclusion.
- **Stop Conditions:** Scope decision would contradict an Accepted Product Contract/ADR without amendment; unresolved data/privacy behavior; unsupported feature remains publicly claimed; Product owner decision is unavailable; an implementation attempts to lower the deployment target or claim iPad/kaomoji readiness without its own Assignment and review.

## Handoff

- **Required Handoff Content:** included features, excluded features, defaults, supported devices/OS, open Gates, owner per gap, App Store copy constraints and required implementation follow-ups. Current required follow-ups are iPad support (07), kaomoji content (08), the iOS 18.0 target-change implementation in `RELEASE-2026-0801-10`, and the child-task/final-release evidence listed in the [review handoff](release-2026-08-01-02-review-handoff.md).
- **Revalidation Trigger:** any user-visible feature/default/support target changes after freeze
