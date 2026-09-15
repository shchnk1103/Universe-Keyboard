# Assignment: RELEASE-2026-0801-04 — 真机、性能、内存与终止证据

**Policy version:** `1.0.0`
**Lifecycle status:** `Active — bounded Build 55 diagnostics, TD-004/TD-005 evidence, fresh-install activation observations and scoped 雾凇 nine-key gate captured; Archive/export relation conditionally reconciled; independent Quality/Release re-review Blocked; full physical matrix remains open`
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

This Codex task accepts the independent Quality Executor role under the Product Lead appointment dated `2026-07-21 Asia/Shanghai`. It collects and assesses only final-candidate evidence; it does not implement domain fixes, accept release risk, or make a Product Gate decision. The Assignment was blocked by the two historical Build 7 P4 retention failures. On `2026-09-12`, Human Product Owner authorized one bounded Build 55 retry with Xcode `27.0 RC`; that run retained a valid Time Profiler window and is recorded separately. The full physical matrix, Quality conclusion and release decision remain open.

## Current Status

- **Lifecycle:** `Active`
- **Current phase:** Build 55 / Xcode 27 RC diagnostic revalidation, TD-003 follow-up, TD-004 off/on matrix, TD-005 acquisition query and read-only classification follow-up, Archive/export relation reconciliation, fresh-install J1/J2/J3 plus Luna 26-key J4 basic output, and the scoped 雾凇 nine-key gate recorded; independent Quality/Release re-review returned Blocked; full physical matrix pending
- **Material non-claims:** No TD-003 numeric baseline, TD-004 closure, TD-005 classification closure or claim that the retained Archive/dSYM metadata itself is `1.0 (55)`, clean App Group state, downloadable-scheme parity beyond the tested 雾凇 path, full fresh-install activation or Release authorization
- **Next handoff:** Product Lead for the final release-scope decision after the independent Quality/Release `Blocked` conclusion; any skipped-gate risk must be explicitly scoped, owned and recorded. No additional scheme download is required for the authorized nine-key gate
- **Evidence:** [`Build 55 Xcode 27 RC diagnostic receipt`](../evidence/release-2026-09-12-build55-td003-xcode27rc-diagnostic.md) · [`Build 55 TD-003 cold/warm diagnostic`](../evidence/release-2026-09-13-build55-td003-cold-warm-diagnostic.md) · [`Build 55 TD-004 matrix`](../evidence/release-2026-09-13-build55-td004-full-access-matrix.md) · [`Build 55 TD-005 query receipt`](../evidence/release-2026-09-13-build55-td005-system-crash-query.md) · [`Build 55 TD-005 classification follow-up`](../evidence/release-2026-09-13-build55-td005-classification-follow-up.md) · [`Build 55 Archive ↔ export reconciliation`](../evidence/release-2026-09-13-build55-archive-export-reconciliation.md) · [`Build 55 fresh-install boundary`](../evidence/release-2026-09-13-build55-fresh-install-boundary.md) · [`Build 55 雾凇九宫格 gate`](../evidence/release-2026-09-13-build55-rime-ice-nine-key-gate.md) · [`Build 55 public-beta readiness handoff`](../evidence/release-2026-09-13-build55-public-beta-readiness-handoff.md) · [`Build 55 Quality/Release review`](../reviews/release-2026-09-13-build55-quality-release-review.md) · [`Build 55 Quality/Release re-review`](../reviews/release-2026-09-13-build55-quality-release-re-review.md)

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

## Current execution status — 2026-09-12

- Human Product Owner explicitly authorized one bounded retry after the available Xcode environment was clarified as
  Xcode `27.0 RC (27A266a)`. The installed receipt was confirmed as Build `55` on the named iPhone 13 Pro / iOS `27.0 (24A435)`.
- The all-processes Time Profiler retained `61.170705 s` to the requested time limit. It sampled Main App PID `8570`
  (`774` rows) and Keyboard Extension PID `8530` (`3,238` rows). The potential-hangs export contained no row for either
  product process; the five rows belonged to other apps.
- This is valid one-run physical diagnostic evidence. Random single-run input, absent memory/crash/Jetsam collection,
  Full Access on-only treatment and missing loaded Keyboard UUID in the Time Profiler export keep the full Assignment open.
- See [`Build 55 diagnostic receipt`](../evidence/release-2026-09-12-build55-td003-xcode27rc-diagnostic.md). No code, install/uninstall,
  commit, push or external distribution action occurred.

## Current execution status — 2026-09-13

- A read-only `systemCrashLogs` query and targeted raw-report copy were completed against the still-installed Build 55 on
  the same iPhone 13 Pro / iOS `27.0 (24A435)`.
- The query found one Build 1 `Universe Keyboard` crash report, which is excluded by version/UUID, plus four Jetsam
  snapshots. Three contain the Build 55 App/Keyboard UUIDs, but none marks the Keyboard as victim/jettisoned/killed;
  they remain `unclassified`.
- This advances TD-005 from no current query to acquisition/identity filtering exercised, but it does not close TD-005,
  TD-003, TD-004 or the fresh-install boundary. No install, uninstall, termination induction, commit, push or external
  distribution action occurred. See [`Build 55 TD-005 query receipt`](../evidence/release-2026-09-13-build55-td005-system-crash-query.md).

- A separate `2026-09-13` Build 55 / Xcode 27 RC all-processes Time Profiler follow-up retained `151.239897 s` to the
  requested time limit. `48/48` read-only process snapshots observed Main App PID `8570` and Keyboard PID `10210`; the
  exported table contained `3,625` Keyboard rows but no Main App rows. Potential-hangs rows belonged only to Reminders and
  WeChat. This is partial TD-003 diagnostic evidence, not a cold/warm or numeric performance baseline; no code, install,
  uninstall, termination induction, commit, push or external distribution action occurred. See [`Build 55 TD-003
  cold/warm diagnostic`](../evidence/release-2026-09-13-build55-td003-cold-warm-diagnostic.md).

- A current Build 55 / iOS 27 physical Full Access off/on matrix was completed in separate Extension sessions. In both arms the
  Human reported that the keyboard stayed selected, basic input worked, candidates appeared and committed, and no degradation
  prompt appeared. Haptics were absent off and present on; sound was present in both. A follow-up with Full Access on explicitly
  toggled the main-App haptic switch: vibration disappeared and returned in the Extension while sound and selection remained
  normal. A follow-up with Full Access on observed a candidate-learning effect: after selecting a non-leftmost candidate,
  re-entering the same synthetic sequence moved that candidate earlier. Extension-restart persistence, Full Access-off
  behavior, backup/restore, other shared settings, resource-not-ready and clean-state App Group behavior were not exercised.
  A further Full Access-on check with 「记录诊断数据」 enabled produced a new main-App diagnostic record after keyboard use
  while the keyboard remained normal. A subsequent Full Access-off session produced no new visible diagnostic record, while
  basic input remained usable and no degradation prompt appeared. A safe resource-not-ready induction was then attempted with
  uninstalled 万象拼音 still marked「可下载」; without downloading it, RIME did not redeploy and remained「已部署」, so no
  resource-not-ready Extension session was reached. TD-004 therefore remains open. See
  [`Build 55 TD-004 matrix`](../evidence/release-2026-09-13-build55-td004-full-access-matrix.md).

- Human Product Owner accepted preserving the verified 雾凇 installation instead of uninstalling it to force a resource-not-ready
  state. This is a scope-preserving decision, not release-risk acceptance; resource-not-ready recovery remains open for the
  Quality/Release conclusion.

- The independent read-only Quality/Release review returned **Blocked**. It accepts only the scoped runtime claims recorded in
  the handoff, leaves TD-003/TD-004/TD-005 and the clean App Group boundary open, and returns the next decision to Product Lead.
  See [`Build 55 Quality/Release review`](../reviews/release-2026-09-13-build55-quality-release-review.md).

- The authorized TD-005 read-only classification follow-up reconfirmed the three UUID-bearing Jetsam rows as
  `unclassified` because none contains victim evidence. It also found `CFBundleVersion=1` in the retained Archive/dSYM
  metadata while the exported Store/Ad Hoc packages and summaries report Build `55`; at that point the exact artifact
  relationship remained to be reconciled. No device, Git or external action occurred. See [`Build 55 TD-005 classification follow-up`](../evidence/release-2026-09-13-build55-td005-classification-follow-up.md).

- The authorized Release/Artifact owner reconciliation confirmed the code-image UUID/dSYM and non-identity resource
  lineage, and found explicit `buildNumber=55` in both export records. The retained Archive/dSYM metadata remains `1.0 (1)`,
  so the relationship is conditionally reconciled rather than silently normalized. No device, Git or external action occurred.
  Independent Quality/Release re-review returned **Blocked**; it accepted the conditional candidate relationship but kept
  TD-003/TD-004/TD-005 and clean App Group open. See [`Build 55 Archive ↔ export reconciliation`](../evidence/release-2026-09-13-build55-archive-export-reconciliation.md)
  and [`Build 55 Quality/Release re-review`](../reviews/release-2026-09-13-build55-quality-release-re-review.md).

- Human Product Owner authorized the fresh-install boundary. The exact target App was uninstalled, the post-uninstall App and
  Keyboard process listings were empty, and the locally retained Build 55 Ad Hoc `.app` was installed successfully and rechecked
  as `1.0 (55)` with the frozen App/Keyboard executable UUIDs. On first main-App open, Human reported that the guide directed the
  user to iOS Settings to add the keyboard, matching the documented J1 fresh-install scenario, and then reported `已添加`.
  Human subsequently reported `完全访问已开启`, so J1 and J2 are complete. The J3 resource view then showed built-in Luna as
  default while downloadable 雾凇/万象 were not installed. Human then clarified that the main App already showed RIME as `已部署`
  automatically; no manual deployment tap or third-party download occurred. J3 is therefore recorded complete for this progress
  run. Human additionally reported normal output with the default Luna 26-key layout; because 雾凇/万象 were not downloaded at
  that preflight stage, no nine-key/T9 or downloadable-scheme behavior was claimed from that stage. The separately authorized
  雾凇 nine-key gate then passed for download, deployment, candidate and commit behavior, with no degradation prompt; its full
  device-attested receipt is linked above. App
  Group/RIME/user-dictionary state was not read or manually reset,
  so the full fresh-install boundary remains open. See
  [`Build 55 fresh-install boundary`](../evidence/release-2026-09-13-build55-fresh-install-boundary.md).

- Human Product Owner completed the declared label-based synthetic keyboard sequence twice without reporting an abnormality. This is a Device-attested functional observation only and does not close TD-003.
- Two subsequent Time Profiler starts, one after process termination and one after a full iPhone reboot, ended after 1.180512 s and 1.194239 s with Device disconnected. Neither captured product samples; both are excluded from TD-003. See [Build 55 TD-003 Human observation](../evidence/release-2026-09-13-build55-td003-human-functional-observation.md).

## Historical execution status — 2026-08-24

- Frozen Build 7、iPhone 13 Pro / iOS 27、雾凇九宫格/T9 偏好、Full Access off 与 Apple-current 冷起点均已建立；
  P4 在启动 machine arm 前的 historical independent readiness review 为 Go，但该结论不改变随后 P4 失效的最终状态。
- 第一段 all-processes Time Profiler 在任何 Human 指令或输入前连续两次于约 `1.3 s` 以
  `Device disconnected` 结束；唯一 bounded machine re-arm 也失败，并伴随 iOS 27 DeviceSupport dylib overlap 警告。
- 两个 trace 均永久排除；没有产品性能、输入、Full Access on/off 或终止结论。P1–P4 审计链见
  [`P4 record`](../evidence/release-2026-08-01-04-build7-device-run-p4-2026-08-24.md) 与
  [`bounded evidence Decision`](../product-decisions/RELEASE-2026-0801-04-build7-bounded-evidence-exception.md)。
- **Historical blocker:** Test/release evidence environment。该历史 P4 只禁止继续使用当时失败的 re-arm；后续
  `2026-09-12` 的独立 Human 授权已允许一次 Build 55 / Xcode 27 RC 有界重试，但不改变 P4 记录或授权上传、分发、
  TD-003/004/005 closure。
