# Assignment: RELEASE-2026-0801-04 — 真机、性能、内存与终止证据

**Policy version:** `1.0.0`
**Lifecycle status:** `Assignment Pending`
**Parent:** [`RELEASE-2026-0801`](release-2026-08-01.md)

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Release-control bootstrap authorized by Human Product Owner, `2026-07-20 Asia/Shanghai`
- **Product Approver:** Human Product Owner acting as Product Lead

## Assignment

- **Domain Owner:** 🧪 Quality, Performance & Release Maintainer
- **Executor:** This Codex task — independent Quality Executor, appointed by Product Lead on `2026-07-21 Asia/Shanghai`
- **Environment Executor:** Human Product Owner — physical-device operator for iPhone 13 Pro / iOS 27; current Codex task coordinates iOS 18 iPhone/iPad Simulator and future Xcode Cloud evidence after account authorization, and records only observed evidence
- **Human Dependency:** Human Product Owner — provides/unlocks the iPhone, enables keyboard/Full Access, later supplies lower-OS/iPad external testers when available, and decides any skipped-gate risk
- **Architecture Reviewer:** `Not Applicable — evidence collection only; route discovered architecture defects separately`
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer, independent from any domain fix being evaluated
- **Handoff Target:** Owning domain for defects; Product Lead for final release decision

### Executor Acknowledgement

This Codex task accepts the independent Quality Executor role under the Product Lead appointment dated `2026-07-21 Asia/Shanghai`. It will collect and assess only final-candidate evidence after every Entry Criterion is met; it will not implement domain fixes, accept release risk, or make a Product Gate decision. The Assignment remains `Assignment Pending` until the final Xcode Cloud release candidate/archive, host and current device/simulator state, capture method, and privacy boundary are frozen.

## Boundary

- **Scope:** Execute the final-commit physical-device matrix; collect Release cold-start, first-key, sustained input, candidate, memory, host-switch, crash/jetsam and RIME-session evidence; verify accessibility/appearance and Full Access on/off.
- **Non-goals:** No production fix inside the evidence task, no invented budget, no private typed-content capture and no acceptance inferred from simulator-only results.
- **Required Inputs:** Final scope and release commit; [`PD-RELEASE-2026-0801-EXTERNAL-TESTFLIGHT-CANDIDATE`](../product-decisions/RELEASE-2026-0801-external-testflight-candidate.md); `RELEASE_CHECKLIST.md`; `PERFORMANCE_BASELINE.md`; iPhone 13 Pro / iOS 27; iOS 18 iPhone/iPad Simulator; exact Xcode Cloud Release archive; synthetic input; trace/report storage.

## Gates

- **Entry Criteria:** Independent Quality Executor named; physical-device operator named; final Xcode Cloud release candidate available; iPhone/Simulator destinations and hosts recorded; capture method and privacy boundary agreed; no required field is `UNKNOWN`. Historical Device Hub availability is not release evidence.
- **Exit Criteria:** iPhone 13 Pro / iOS 27 physical evidence covers Extension lifecycle, Full Access, performance, memory and termination; iOS 18 iPhone/iPad Simulator covers minimum-OS compatibility only; crash/jetsam classification and dSYM mapping are actionable; every failure/skipped row has owner and impact; Quality issues an explicit Pass/Fail/Blocked conclusion. Physical iPad/lower-OS residuals remain explicit for targeted external testing and App Store revalidation.
- **Stop Conditions:** Wrong commit/build; Debug evidence used for product conclusion; real user text would be captured; unexplained termination; device/support scope missing; Product owner asked to accept risk through the Quality thread.

## Handoff

- **Required Handoff Content:** commit/build, device/OS/host/schema/access state, method/sample metadata, traces/reports, passed/failed/skipped rows, regression judgment, defect owner and expiry
- **Revalidation Trigger:** release commit/Cloud archive, scope/device matrix, physical or simulated environment, schema, access state, toolchain or relevant implementation changes
