# Assignment: RELEASE-2026-0801-05 — 隐私、支持与 App Store 上架材料

**Policy version:** `1.0.0`
**Lifecycle status:** `Assignment Pending`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Release-control bootstrap authorized by Human Product Owner, `2026-07-20 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead

## Assignment

- **Domain Owner:** 📱 App & Data Operations Maintainer
- **Executor:** `UNKNOWN — Product Lead must name the App/Data materials thread`
- **Environment Executor:** `UNKNOWN — Product Lead must name the App Store Connect/account operator`
- **Human Dependency:** Human Product Owner — provides legal/support/contact answers, account access, metadata approval and separate submission authorization
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward for privacy/data/export-compliance consistency
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer for final-binary and metadata consistency
- **Handoff Target:** Product Lead for submission authorization; umbrella release coordinator

## Boundary

- **Scope:** Publish and link the privacy policy; prepare support/contact/about/license surfaces; verify App Privacy, privacy manifests, export-compliance answers, screenshots, descriptions, review notes, demo instructions, age rating, availability and required App Store Connect fields against final behavior.
- **Non-goals:** No legal guarantees by an AI, no unsupported marketing claim, no account action or submission without explicit authorization, and no collection of credentials in repository evidence.
- **Required Inputs:** Final scope; final archive; privacy policy; Privacy manifests; dependency/license inventory; supported-device decision; App Store Connect access; current Apple submission requirements.

## Gates

- **Entry Criteria:** Executors named; final scope frozen; public URLs/contacts decided; account access available; no required field is `UNKNOWN`.
- **Exit Criteria:** Public privacy/support URLs work; in-app links and final behavior agree; screenshots cover every supported family; metadata/review notes are accurate; privacy/export/license answers are reviewed; submission-readiness checklist has no unexplained omission.
- **Stop Conditions:** Policy and behavior conflict; unsupported claim; required legal/contact answer missing; credentials would enter logs/repo; iPad remains supported without required material; submission requested without explicit approval.

## Handoff

- **Required Handoff Content:** approved copy, public URLs, screenshot inventory, privacy/export/license assessment, App Store field status, review instructions, unresolved legal/product questions and submission authorization state
- **Revalidation Trigger:** release scope/binary, privacy behavior, dependency inventory, supported devices, public URL, App Store metadata or Apple requirement changes
