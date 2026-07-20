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
- **Executor:** `UNKNOWN — Product Lead must name an independent Quality execution thread`
- **Environment Executor:** Human Product Owner — physical-device operator for the connected iPhone 13 Pro and iPad Pro (11-inch, 3rd generation); current Codex task coordinates capture commands and records only the observed evidence
- **Human Dependency:** Human Product Owner — provides/unlocks devices, enables keyboard/Full Access and decides any skipped-gate risk
- **Architecture Reviewer:** `Not Applicable — evidence collection only; route discovered architecture defects separately`
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer, independent from any domain fix being evaluated
- **Handoff Target:** Owning domain for defects; Product Lead for final release decision

## Boundary

- **Scope:** Execute the final-commit physical-device matrix; collect Release cold-start, first-key, sustained input, candidate, memory, host-switch, crash/jetsam and RIME-session evidence; verify accessibility/appearance and Full Access on/off.
- **Non-goals:** No production fix inside the evidence task, no invented budget, no private typed-content capture and no acceptance inferred from simulator-only results.
- **Required Inputs:** Final scope and release commit; `RELEASE_CHECKLIST.md`; `PERFORMANCE_BASELINE.md`; devices; exact Release archive; synthetic input; trace/report storage.

## Gates

- **Entry Criteria:** Independent Quality Executor named; physical-device operator named; final release candidate available; devices and hosts recorded; capture method and privacy boundary agreed; no required field is `UNKNOWN`. Device Hub availability was observed on `2026-07-20 Asia/Shanghai` for iPhone 13 Pro and iPad Pro (11-inch, 3rd generation), but this observation is not release evidence.
- **Exit Criteria:** Required device matrix and metrics have current evidence; crash/jetsam classification and dSYM mapping are actionable; every failure/skipped row has owner and impact; Quality issues an explicit Pass/Fail/Blocked conclusion.
- **Stop Conditions:** Wrong commit/build; Debug evidence used for product conclusion; real user text would be captured; unexplained termination; device/support scope missing; Product owner asked to accept risk through the Quality thread.

## Handoff

- **Required Handoff Content:** commit/build, device/OS/host/schema/access state, method/sample metadata, traces/reports, passed/failed/skipped rows, regression judgment, defect owner and expiry
- **Revalidation Trigger:** release commit/archive, scope/device matrix, schema, access state, toolchain or relevant implementation changes
