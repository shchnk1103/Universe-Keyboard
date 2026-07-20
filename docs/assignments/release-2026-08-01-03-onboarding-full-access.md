# Assignment: RELEASE-2026-0801-03 — 新用户启用与 Full Access 降级体验

**Policy version:** `1.0.0`
**Lifecycle status:** `Closed — Conditional Product Gate accepted by Human Product Owner; residual TD-004 follow-up tracked separately`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** [`PD-RELEASE-2026-0801-03`](../product-decisions/RELEASE-2026-0801-03-activation-authorization.md), authorized by Human Product Owner role delegation in the active Grok session, `2026-07-20 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead; Product Lead decisions under that delegation are recorded in the Product Decision

## Assignment

- **Domain Owner:** 📱 App & Data Operations Maintainer
- **Executor:** Grok session acting as App & Data Operations Maintainer (main-App Guide/activation journey, copy, capability-matrix presentation)
- **Environment Executor:** Grok session for Simulator/build/unit-test evidence; Human Product Owner for physical-device Full Access on/off, system keyboard registration and final Product Gate interactions
- **Human Dependency:** Human Product Owner — physical-device setup, wording acceptance if copy changes after review, and final activation-flow Product Gate
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward if Full Access, App Group, privacy or fallback semantics change beyond ADR 0007/0008
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer
- **Supporting Domain:** ⌨️ Keyboard Experience Maintainer for Extension-visible degradation and actual keyboard behavior
- **Handoff Target:** Quality Reviewer, then Product Lead

## Acknowledgement And Activation

- **Product Assignment Decision:** `2026-07-20 Asia/Shanghai` — Executor and Environment Executor named; capability matrix and privacy wording bound by `PD-RELEASE-2026-0801-03`.
- **Executor acknowledgement:** `2026-07-20 Asia/Shanghai` — Scope, Non-goals, Stop Conditions, product source and residual physical-device gate accepted.
- **Entry Criteria status:** Met for main-App implementation (executors named, scope freeze record exists, matrix agreed, privacy wording reviewed, no required field `UNKNOWN`). Physical-device evidence remains an Exit dependency, not an Entry dependency for starting Guide work.
- **Product lifecycle decision:** `Assigned → Acknowledged → Ready → Active`, `2026-07-20 Asia/Shanghai`.
- **Current phase:** **Closed** after Human Product Owner confirmed Conditional Pass (`2026-07-20 Asia/Shanghai`). See [`release-2026-08-01-03-product-gate.md`](release-2026-08-01-03-product-gate.md). Residual TD-004 matrix fidelity / Extension degradation visibility is tracked in `TECH_DEBT.md`, not as an open lifecycle of this Assignment.
- **Executor main-App deliverable:** Journey source, capability matrix, Guide UI, `ActivationChecklistState` tests (6/6 PASS on iPhone 17 Pro Simulator / iOS 26.5).
- **Device evidence:** [`../evidence/release-2026-08-01-03-physical-device-fa-matrix.md`](../evidence/release-2026-08-01-03-physical-device-fa-matrix.md) — iPhone 13 Pro / iOS 27 beta 3; FA off still yields matching `nihao` candidates; haptics only clear FA-linked difference.

## Boundary

- **Scope:** Make keyboard addition, Full Access explanation, RIME readiness/deployment and first successful input understandable and verifiable; define truthful Full Access on/off states and actionable recovery; preserve basic typing without requiring Full Access; publish journey/copy/matrix product source; implement main-App Guide presentation. TipKit may be documented as a future carrier only.
- **Non-goals:** No new account/network service, no Extension deployment, no misleading guarantee that iOS can programmatically enable the keyboard, no unrelated settings redesign, no TipKit dependency required to complete this task's main-App deliverable, no App Store submission.
- **Required Inputs:**
  - [`PD-RELEASE-2026-0801-03`](../product-decisions/RELEASE-2026-0801-03-activation-authorization.md)
  - [`ONBOARDING_ACTIVATION.md`](../ONBOARDING_ACTIVATION.md)
  - [`release-2026-08-01-02-scope-freeze.md`](release-2026-08-01-02-scope-freeze.md)
  - `GuideTab`, Privacy & Data UI
  - ADR 0001, 0003, 0007, 0008
  - shared-container lifecycle, TD-004, `PRIVACY_POLICY.md`
  - Apple keyboard-extension open-access requirements
  - physical-device access-on/off scenarios for Exit

## Gates

- **Entry Criteria:** **Met for Active implementation.** Executors named; V1.0 scope freeze executor record completed; Full Access capability matrix agreed in product sources; privacy wording reviewed in Product Decision; no required field is `UNKNOWN`.
- **Exit Criteria:** Fresh-install activation path is usable in main App; system-settings routing and limitations are truthful; RIME readiness is actionable; access-off basic typing and access-on shared capabilities are verified on device; accessibility and error states pass review; handoff package complete.
- **Stop Conditions:** Basic input requires Full Access; copy overstates access or network behavior; App Group/RIME boundary changes without review; device evidence unavailable when claiming Exit; destructive data operation is introduced.

## Handoff

- **Required Handoff Content:** user journey source, screenshots when available, access-on/off matrix, exact device/OS/host for device runs, changed files, tests, privacy review pointer, known limitations and recovery behavior
- **Revalidation Trigger:** Full Access, App Group, RIME readiness/deployment, fallback engine, onboarding copy or Apple extension requirement changes
