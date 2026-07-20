# Product Decision: RELEASE-2026-0801-03 Activation Journey Authorization

**Decision ID:** `PD-RELEASE-2026-0801-03`  
**Lifecycle status:** Recorded  
**Date / timezone:** `2026-07-20 Asia/Shanghai`  
**Assignment:** [`RELEASE-2026-0801-03`](../assignments/release-2026-08-01-03-onboarding-full-access.md)  
**Parent release:** [`RELEASE-2026-0801`](../assignments/release-2026-08-01.md)

## Authority

- **Product Approver / Decision maker:** 🧭 Product Lead, exercising KOS 2.0 Product authority under the Human Product Owner's explicit instruction in the active Grok session (`2026-07-20 Asia/Shanghai`) to continue `RELEASE-2026-0801-03`, name task roles, and complete in-scope work while respecting permanent role boundaries.
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- **Domain Owner:** 📱 App & Data Operations Maintainer.
- **Executor:** Grok session acting as App & Data Operations Maintainer for main-App activation journey, copy, capability-matrix presentation and Guide implementation only.
- **Environment Executor:** Same Grok session for Simulator/build/unit-test evidence; Human Product Owner for physical-device Full Access on/off toggles, system keyboard registration and final Product Gate interactions.
- **Architecture / Quality review:** Architecture & Knowledge Steward when Full Access, App Group, privacy or fallback semantics change beyond existing ADR 0007/0008; Quality, Performance & Release Maintainer for independent evidence conclusions.

This record is the stable Product Decision Source for activation journey semantics, copy boundaries and the Full Access capability matrix used by task 03.

## Product Problem

New users currently see a short “add keyboard” Guide and an internal-style test checklist. The path does not:

1. explain why Full Access is requested without overstating network or surveillance behavior;
2. make RIME readiness actionable after keyboard installation;
3. distinguish basic typing from complete shared RIME capabilities;
4. provide a re-entrant checklist that survives trips into system Settings.

TD-004 and ADR 0007 already require a truthful degradation matrix; scope freeze (`RELEASE-2026-0801-02`) requires Full Access to remain optional for basic typing and forbids launch copy that claims programmatic keyboard enablement or data upload.

## Bound Product Decisions

### 1. Activation success definition

1. **Full recommended activation** means the user completes: add keyboard → allow Full Access → main-App RIME resources ready → first successful Chinese input (`nihao` candidate + commit is the V1 smoke example).
2. **Minimum degraded success** means the keyboard is added and basic local typing remains possible without Full Access. Degraded success must not be marketed as complete RIME readiness.
3. Activation is a **re-entrant checklist**, not a one-shot modal that claims completion after reading text.

### 2. Journey and presentation

1. The product source for the journey, copy boundaries and capability matrix is [`ONBOARDING_ACTIVATION.md`](../ONBOARDING_ACTIVATION.md).
2. V1.0 presentation is **main-App Guide checklist + status cards**. TipKit is an authorized future presentation layer for the same semantics; TipKit is **not** required to close task 03.
3. System Settings steps remain user-owned. The App may open the root Settings URL and must state that it cannot programmatically add the keyboard or enable Full Access.
4. Main App must not invent a live Extension Full Access boolean. Allowed states are observation-based failures, deployment readiness owned by the main App, and weak user affirmations that later observation may overturn.

### 3. Full Access claims

1. Full Access is required for complete shared capabilities: prepared RIME resources in the App Group, cross-target settings, user-dictionary learning, diagnostics persistence, shared feedback settings and optional Typing Intelligence aggregates.
2. Full Access is **not** required for basic local key insertion that the Extension can still perform without shared container features.
3. Copy must reuse the privacy position in [`PRIVACY_POLICY.md`](../PRIVACY_POLICY.md): Full Access is for shared local data, not keystroke upload, advertising or tracking.
4. Capability-specific available / degraded / unavailable wording follows the matrix in `ONBOARDING_ACTIVATION.md`.

### 4. Privacy wording review

Product Lead reviewed existing Privacy & Data UI and policy text against the activation journey. Approved short-form lines:

- Full Access is used for shared settings, RIME resources, local learning and optional insights.
- It is not used to upload keystrokes.
- Keyboard input processing remains on device.

Any App Store public privacy URL or review-note packaging remains owned by `RELEASE-2026-0801-05`.

### 5. Safety and non-goals

1. No Extension deployment, no new network/account service, no destructive data operation.
2. No claim that iOS can enable the keyboard programmatically.
3. No V1.0 launch claim for Typing Intelligence or contextual typo correction (scope freeze).
4. No automatic TipKit dependency for the August release gate.
5. Physical-device Full Access on/off evidence remains a Human Environment dependency and is required before Product Gate close, not before starting main-App implementation.

## Non-goals

- Redesigning Settings information architecture beyond activation recovery links
- Extension UI chrome redesign
- Closing TD-004 without physical-device matrix evidence
- App Store Connect, screenshot or public URL publication
- Uploading, TestFlight or App Store submission

## Gates

1. Assignment 03 must replace Executor / Environment Executor `UNKNOWN` values with this Decision before `Ready`.
2. Scope freeze constraints from `RELEASE-2026-0801-02` remain binding.
3. Implementation may advance with Simulator/unit evidence; Product Gate remains blocked until physical-device access-on/off and fresh-install path evidence exist.
4. Architecture review is required only if implementation changes App Group, deployment ownership, fallback product semantics or privacy boundary beyond ADR 0007/0008.

## Change Policy

Changing activation success criteria, Full Access optionality, privacy claims or the capability matrix requires Product Lead amendment of this Decision and revalidation of Assignment 03.
