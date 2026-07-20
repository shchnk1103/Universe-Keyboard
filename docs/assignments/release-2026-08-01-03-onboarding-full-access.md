# Assignment: RELEASE-2026-0801-03 — 新用户启用与 Full Access 降级体验

**Policy version:** `1.0.0`
**Lifecycle status:** `Assignment Pending`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Release-control bootstrap authorized by Human Product Owner, `2026-07-20 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead

## Assignment

- **Domain Owner:** 📱 App & Data Operations Maintainer
- **Executor:** `UNKNOWN — Product Lead must name the App/Data execution thread`
- **Environment Executor:** `UNKNOWN — Product Lead must name Simulator and physical-device operator`
- **Human Dependency:** Human Product Owner — device setup, wording acceptance and final activation-flow Product Gate
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward if Full Access, App Group, privacy or fallback semantics change
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer
- **Supporting Domain:** ⌨️ Keyboard Experience Maintainer for Extension-visible degradation and actual keyboard behavior
- **Handoff Target:** Quality Reviewer, then Product Lead

## Boundary

- **Scope:** Make keyboard addition, Full Access explanation, RIME readiness/deployment and first successful input understandable and verifiable; define truthful Full Access on/off states and actionable recovery; preserve basic typing without requiring Full Access.
- **Non-goals:** No new account/network service, no Extension deployment, no misleading guarantee that iOS can programmatically enable the keyboard, and no unrelated settings redesign.
- **Required Inputs:** `GuideTab`, Privacy & Data UI, shared-container lifecycle, TD-004, Apple keyboard-extension requirements, physical-device access-on/off scenarios.

## Gates

- **Entry Criteria:** Executors named; scope freeze completed; Full Access capability matrix agreed; privacy wording reviewed; no required field is `UNKNOWN`.
- **Exit Criteria:** Fresh-install activation path is usable; system-settings routing and limitations are truthful; RIME readiness is actionable; access-off basic typing and access-on shared capabilities are verified on device; accessibility and error states pass review.
- **Stop Conditions:** Basic input requires Full Access; copy overstates access or network behavior; App Group/RIME boundary changes without review; device evidence unavailable; destructive data operation is introduced.

## Handoff

- **Required Handoff Content:** user journey, screenshots, access-on/off matrix, exact device/OS/host, changed files, tests, privacy review, known limitations and recovery behavior
- **Revalidation Trigger:** Full Access, App Group, RIME readiness/deployment, fallback engine, onboarding copy or Apple extension requirement changes
