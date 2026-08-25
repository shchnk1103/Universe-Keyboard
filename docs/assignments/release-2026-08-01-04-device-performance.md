# Assignment: RELEASE-2026-0801-04 — 真机、性能、内存与终止证据

**Policy version:** `1.0.0`
**Lifecycle status:** `Blocked — current macOS/Xcode/iOS 27 Beta Time Profiler cannot retain a physical-device arm`
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

This Codex task accepts the independent Quality Executor role under the Product Lead appointment dated `2026-07-21 Asia/Shanghai`. It will collect and assess only final-candidate evidence after every Entry Criterion is met; it will not implement domain fixes, accept release risk, or make a Product Gate decision. The Assignment is currently `Blocked — evidence environment`: the frozen Xcode Cloud candidate/archive and P4 manifest existed, but the current macOS/Xcode/iOS 27 Beta Time Profiler could not retain either authorized machine arm. A future run requires a new Product Lead decision and a different/stable physical-device capture environment.

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

## Current execution status — 2026-08-24

- Frozen Build 7、iPhone 13 Pro / iOS 27、雾凇九宫格/T9 偏好、Full Access off 与 Apple-current 冷起点均已建立；
  P4 在启动 machine arm 前的 historical independent readiness review 为 Go，但该结论不改变随后 P4 失效的最终状态。
- 第一段 all-processes Time Profiler 在任何 Human 指令或输入前连续两次于约 `1.3 s` 以
  `Device disconnected` 结束；唯一 bounded machine re-arm 也失败，并伴随 iOS 27 DeviceSupport dylib overlap 警告。
- 两个 trace 均永久排除；没有产品性能、输入、Full Access on/off 或终止结论。P1–P4 审计链见
  [`P4 record`](../evidence/release-2026-08-01-04-build7-device-run-p4-2026-08-24.md) 与
  [`bounded evidence Decision`](../product-decisions/RELEASE-2026-0801-04-build7-bounded-evidence-exception.md)。
- **Blocker owner:** Test/release evidence environment。下一步需要 Product Lead 选择不同或稳定的物理设备采集环境；
  当前 P4 禁止继续 re-arm，上传与 TD-003/004/005 closure 仍未授权。
