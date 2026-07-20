# Assignment: RELEASE-2026-0801-08 — 首发颜表情内容

**Policy version:** `1.0.0`
**Lifecycle status:** `Assigned — Entry Criteria pending`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner decided that kaomoji content cannot be excluded from V1.0 and authorized the current Codex task to select and perform KOS-compatible remaining release execution roles in the active Codex task, `2026-07-20 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead

## Assignment

- **Domain Owner:** ⌨️ Keyboard Experience Maintainer
- **Executor:** Current Codex task acting as ⌨️ Keyboard Experience execution thread
- **Environment Executor:** Current Codex task for simulator interaction operations; the Human Product Owner remains the physical-device interaction operator and final Product Gate
- **Human Dependency:** Human Product Owner — approves the bounded launch catalog, content policy and final product behavior
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward if storage, synchronization, privacy, user-data or cross-target contracts are proposed
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer
- **Supporting Domain:** 📱 App & Data Operations Maintainer only if a main-App content/settings surface is explicitly approved
- **Handoff Target:** Quality Reviewer, then Product Lead and task 05

## Boundary

- **Scope:** Define and deliver a bounded, offline launch catalog of kaomoji that the existing user-visible control can present and insert truthfully; cover selection, insertion, accessibility and supported-device behavior.
- **Non-goals:** No network catalog, user-generated/shared catalog, account, analytics, remote sync, learning/ranking system or unrelated keyboard redesign. No persistent user content without a separate Product/privacy/architecture decision.
- **Required Inputs:** [`RELEASE-2026-0801-02`](release-2026-08-01-02-scope-freeze.md), `UI_STYLE_GUIDE.md`, current nine-key chrome contract, `PRIVACY_POLICY.md`, `RELEASE_CHECKLIST.md`, and task 05 copy/screenshot requirements.

## Gates

- **Entry Criteria:** Executor and interaction operator named; Product Lead approves catalog source/licensing/content boundaries; insertion behavior and storage boundary are explicit; no required field is `UNKNOWN`.
- **Exit Criteria:** The control is no longer a no-op; catalog and insertion behavior pass accessibility/device checks; license/privacy/copy implications are handed to task 05; Quality records an explicit conclusion.
- **Stop Conditions:** Catalog provenance or license is unclear; a network, persistence, sync or user-data requirement appears; input commit semantics regress; final behavior would require an unapproved major UI or architecture change.

## Handoff

- **Required Handoff Content:** approved catalog/provenance, interaction and insertion contract, changed files, tests, accessibility/device evidence, privacy/license assessment, screenshots, known limits and App Store copy constraints.
- **Revalidation Trigger:** catalog source, insertion behavior, persistence/network boundary, keyboard geometry, supported devices or release archive changes.
