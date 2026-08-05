# Assignment: T9-RESPONSIVE-PIPELINE-001 / P2-PERF-02

Policy version: 1.0.0  
Lifecycle status: **Active — Product-authorized Release-optimized diagnostic A/B**  
Date: 2026-08-01 Asia/Shanghai

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Owner authorization in the active Codex task, 2026-08-01 Asia/Shanghai, following the P2-PERF-01 bounded attribution
- Product Approver: Human Product Owner / Product Lead
- Parent assignment: [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)
- Related evidence: [`P2-PERF-01`](t9-responsive-pipeline-001-p2-perf-01.md)
- Architecture boundary: [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) remains **Proposed**

## Boundary

### Scope

1. Build two physically comparable, Release-optimized internal diagnostic arms
   from the same current worktree and source identity, using separate DerivedData
   directories and replacement-only installation.
2. Arm A is measurement-enabled but responsive-gate-off:
   `Release` + `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT`; it must not define
   `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` or any auto-anchor `*_ENABLED` flag.
3. Arm B is measurement-enabled and explicitly thread-affine:
   `Release` + `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` +
   `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`; it must not define any auto-anchor
   `*_ENABLED` flag. The two responsive gates remain project-default `false`.
4. On the connected iPhone 13 Pro, have the Human Product Owner manually type
   the declared nine-key fixture in an empty Reminders title using the software
   keyboard. No coordinate typing, Path tap, candidate tap, numeric page or
   Computer Use typing is allowed.
5. Export only content-free `T9DEVICE`, `T9SEG`, `SLOW RIME`, `T9RESP` and
   session/integrity records; correlate the Human report with the two arms.
6. Restore the ordinary gate-off build by replacement and hand the bounded
   evidence to independent Architecture and Quality reviewers.

### Declared fixture

`jintiandetianqizhenbucuowomenchuquwanba`

The Human taps only the visible nine-key letter-group buttons. The exact number
of retained log rows is an evidence field, not an input event to be invented if
the export is incomplete.

### Interpretation of “Release-like”

These are **Release-optimized internal diagnostic builds**, not shipping Release
artifacts: the measurement condition and, for Arm B, an explicit compile-time
preflight arm are injected outside project defaults and the device build remains
Development-signed. Results may inform an off-main decision but cannot prove
App Store Release behavior or a Product Gate.

## Non-goals

- No production source, KeyboardCore semantics, RIME/Lua, gate default or user
  setting change.
- No ADR 0025 acceptance, R6, Product Gate, Release default-on or shipping claim.
- No expansion of T9 auto-anchor; no `T9_AUTO_ANCHOR_*_ENABLED` flags.
- No input drop, merge, reorder or synthetic workload.
- No uninstall, container wipe, RIME/userdb reset or deletion of host data.
- No automated coordinate input or accessibility-based third-party keyboard claim.
- No numeric latency SLO, jetsam, memory or multi-device conclusion.

## Assignment

- Domain Owner: 🧪 Quality, Performance & Release Maintainer
- Executor: Current Codex task for build, install, log collection and analysis
- Environment Executor: Current Codex task for Xcode/device tooling
- Human Dependency: Human Product Owner for manual fixture input, ordered outcome,
  integrity report and 0–4 subjective stall score
- Architecture Reviewer: Independent Architecture & Knowledge Steward
- Quality Reviewer: Independent Quality, Performance & Release Maintainer

## Required inputs

- [`P2-PERF-02 evidence contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md)
- [`P2-PERF-02 evidence enforcement`](t9-responsive-pipeline-001-p2-perf-02-evidence-enforcement.md)
- [`Evidence Enforcement Architecture review`](t9-responsive-pipeline-001-p2-perf-02-evidence-enforcement-architecture-review.md)
- [`Evidence Enforcement Quality review`](t9-responsive-pipeline-001-p2-perf-02-evidence-enforcement-quality-review.md)
- [`P2-PERF-02 Evidence Hardening (reviewed; runtime evidence open)`](t9-responsive-pipeline-001-p2-perf-02-evidence-hardening.md)
- [`P2-PERF-01 canonical evidence`](../evidence/t9-responsive-pipeline-p2-perf-01-canonical-partial-2026-08-01.md)
- [`P2-PERF-01 Assignment`](t9-responsive-pipeline-001-p2-perf-01.md)
- [`R5 formal design`](t9-responsive-pipeline-001-r5-formal-design.md)
- [`R5-Rem-Device design`](t9-responsive-pipeline-001-r5-rem-3-device-design.md)
- [`ADR 0025 Proposed`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)
- [`Test and Release playbook`](../playbooks/test-release.md)
- [`RimeBridge playbook`](../playbooks/rime-bridge.md)

## Entry criteria

- The declared iPhone 13 Pro is connected, unlocked and trusted.
- The ordinary gate-off build is installed before Arm A; runtime readiness and
  Full Access are observed rather than inferred.
- The worktree/source fingerprint and both build flag sets are recorded before
  installation; neither preflight flag exists in project or shared-scheme defaults.
- The App Diagnostics view can export content-free records.
- Human confirms an empty Reminders title and software-keyboard mode.

## Exit criteria

1. A/B run headers record source/worktree identity, exact configuration and
   injected flags, device/OS, bundle identity and App/Extension hashes.
2. Each arm records path identity, gate state, retained `T9SEG` range,
   `processKey`/RIME and UI stage timings, publish/visible markers when active,
   session/integrity fields and the Human 0–4 score.
3. The evidence states whether each export is complete or partial and never
   treats missing rows as zero-latency rows.
4. The comparison is limited to direction: whether the explicit off-main arm
   reduces perceived stalls without introducing integrity or freeze-then-burst
   regressions. No product budget is invented.
5. The device is restored to ordinary gate-off by replacement and the installed
   identity is confirmed.
6. Independent Architecture and Quality reviews receive the immutable evidence
   and the skipped Release/Product Gate checks.
7. Each arm and the pair are evaluated against the
   [`P2-PERF-02 evidence contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md);
   missing PATH/READY, native session, execution geometry, A-arm, Human score or
   restore identity remain explicit `Partial` fields rather than inferred values.

## Stop conditions

- Either arm has the wrong device, wrong compile flags, wrong path marker or an
  unexpected default-on gate.
- Diagnostics contain raw input, candidate text, host text or user-dictionary
  content that cannot be safely filtered.
- Installation requires destructive reset or the keyboard cannot be used
  manually in the declared host field.
- The build cannot retain identical measurement cost between A and B.
- Any failure would require changing production logic, default settings or ADR
  status; record the blocker and stop.

## Handoff

- Handoff Target: Independent Architecture reviewer, then independent Quality reviewer
- Required Handoff Content: source/build/device fingerprints, A/B flag and path
  proof, content-free export hashes, parsed stage metrics, Human report,
  restore proof, limitations and bounded recommendation
- Revalidation Trigger: source/gate/schema/device/OS/toolchain change, diagnostic
  schema change, or any request to turn the explicit arm into a Release default

## P2-H-06 真机运行收尾（2026-08-02）

本次已完成 iPhone 13 Pro 上的 A/B 手动输入与 App 自带 `rime_diag_log` 导出，详见
[`P2-H-06 device evidence`](../evidence/t9-responsive-pipeline-p2-perf-02-device-2026-08-02.md)。

- A/B 均保留 `T9SEG` action/event `1…39`，无漏键、重键、候选消失或键盘退出；
  Human 评分按 `0=最卡、4=最流畅` 记录为 A=`3/4`、B=`4/4`。
- A 为 `path=sync`；B 具有 run-bound `path=thread-affine` / `READY`。两臂均记录真实
  librime、稳定有效 session 和同 run geometry；B 的 rev `16/25/33` 缺 epoch-bound
  publish，合同判定保持 `Partial`。
- 原始日志被当前隐私 deny-list 对 `SLOW RIME candidates=12` 计数摘要误识别，原始
  validator 结果为 `Blocked`；排除该摘要后的 marker-only 对照仍为 `Partial`，未把它
  改写成 Complete。
- A/B preflight envelope 与 matrix registry 已精确清理；普通 gate-off Release 已
  替换安装并核验设备仍连接。

Assignment 保持 **Active / Runtime evidence captured — Partial**；独立 Architecture 与
Quality 复审已完成，结论均未形成 ADR 0025 Accept、Product Gate、Release 或默认开启结论：

- [`独立 Architecture 复审`](t9-responsive-pipeline-001-p2-perf-02-device-architecture-review.md)：
  `Pass with conditions`，P0/P1/P2/P3=`0/0/3/2`；
- [`独立 Quality / Performance 复审`](t9-responsive-pipeline-001-p2-perf-02-device-quality-review.md)：
  `Partial`，P0/P1/P2/P3=`0/0/3/2`。

两份复审共同确认的停止点：

1. A `sync` arm 的 validator 不应无条件要求 responsive `ACCEPT/PUBLISH`；需要单独冻结
   sync expectation 与回归样本；
2. B 的 rev `16/25/33` 缺 epoch-bound publish，必须先决定 PUBLISH 是 owner completion
   还是可见 UI apply，再定义 coalescing receipt；
3. `candidates=12` 计数被 privacy deny-list 误判，且当前证据包缺少可长期重放的 pair/run
   manifest、privacy scan 与 restore manifest；
4. restore 后 keyboard-switch smoke 尚未形成独立记录。

上述项目均需要新的契约/证据授权；在授权前保持生产路径、默认 gate、ADR 0025 和 Product
Gate 状态不变。本 Assignment 在此停止于“复审完成、后续决策待授权”。
