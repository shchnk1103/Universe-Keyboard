# RELEASE-2026-0801-03 — Product Gate Decision

**Date / timezone:** `2026-07-20 Asia/Shanghai`  
**Assignment:** [`release-2026-08-01-03-onboarding-full-access.md`](release-2026-08-01-03-onboarding-full-access.md)  
**Decision ID:** `PG-RELEASE-2026-0801-03`  
**Authority:** Product Lead under Human Product Owner role delegation and Human Environment Executor device evidence

## Decision

**Conditional Pass** for the main-App activation deliverable of `RELEASE-2026-0801-03`.

This is **not** an unconditional claim that TD-004 is closed, that Full Access gates all shared RIME behavior on every OS, or that App Store release is authorized.

## What passed

| Exit item | Judgment |
|---|---|
| Fresh-install / Guide activation path usable | **Pass** — Human visual walkthrough on device; checklist and settings routing acceptable |
| System Settings limitations truthful | **Pass** — App does not claim programmatic keyboard enablement |
| RIME readiness actionable | **Pass** — deploy/readiness remains main-App owned; resources were already deployed in the device run |
| Basic typing without Full Access | **Pass** — FA off still invokes keyboard and produces `nihao` candidates |
| Physical-device FA on/off evidence recorded | **Pass** — [`evidence/release-2026-08-01-03-physical-device-fa-matrix.md`](../evidence/release-2026-08-01-03-physical-device-fa-matrix.md) |
| Privacy short-form (no keystroke upload) | **Pass** — consistent with policy and Guide |

## What did not fully pass / residual

| Item | Judgment |
|---|---|
| Pre-device matrix claim “real RIME unavailable without FA” | **Not confirmed** on iPhone 13 Pro / iOS 27 beta 3 with 雾凇 pre-deployed; candidates matched FA on |
| Explicit Extension degradation UI when FA off | **Fail / missing** — no user-visible degraded banner |
| “Complete shared capability depends on FA” as blanket statement | **Narrowed** — haptic (and feedback-related) difference observed; broad RIME-off claim overstated |
| TD-004 closed | **No** — open with updated mitigation + residual follow-up |
| Independent formal Quality sign-off beyond unit tests | **Not claimed** — unit 6/6 + human device matrix only |
| Accessibility full audit | **Not separately evidenced** |

## Product interpretation of FA off/on

Human observation: the only clear perceptible difference in this run was **key haptic feedback** (present with FA on, absent with FA off). Operator hypothesis that FA currently mainly affects key click/haptics is **plausible and aligned with Feedback settings copy**, but is **not** proven as the exclusive FA surface area without Architecture instrumentation.

**Binding product rules after this gate:**

1. Keep: basic input must not require Full Access.  
2. Keep: Full Access explanation for shared local data / feedback reliability.  
3. Change: do **not** ship copy that says Chinese input is impossible without Full Access.  
4. Follow-up (not blocking Conditional Pass of Guide): amend matrix communication, optional Extension degraded cue for feedback/shared failures, Architecture verify App Group/RIME availability under FA off on iOS 27.

## Lifecycle effect

- Assignment may move to **`Completed — Conditional Product Gate; residual matrix follow-up`**.  
- **Closed** requires: Human Product Owner explicit acceptance of this Conditional Pass **or** a later unconditional re-gate after follow-up; plus any remaining repo commit/merge hygiene the owner requires.  
- Umbrella release `RELEASE-2026-0801` remains open.

## Human confirmation

- **Human Product Owner confirmation:** `确认 Conditional Pass` received in the active Grok session, `2026-07-20 Asia/Shanghai`.
- **Effect:** Conditional Product Gate is accepted. Residual TD-004 matrix-fidelity / Extension-visible recovery follow-up remains open and does not reopen this Assignment unless Product Lead revalidates.
- **Closed for Product Gate purposes:** Yes (conditional). Repository publication/merge is a separate engineering action.