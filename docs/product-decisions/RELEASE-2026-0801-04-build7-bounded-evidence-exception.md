# Product Decision: RELEASE-2026-0801-04 — Build 7 真机有界证据例外

**Decision ID:** `PD-RELEASE-2026-0801-04-BUILD7-BOUNDED-EVIDENCE-EXCEPTION`
**Lifecycle status:** `Recorded`
**Date / timezone:** `2026-08-24 Asia/Shanghai`
**Assignment:** [`RELEASE-2026-0801-04`](../assignments/release-2026-08-01-04-device-performance.md)
**Runs:** [`P1 invalidated`](../evidence/release-2026-08-01-04-build7-device-run-2026-08-24.md)；[`P2 invalidated`](../evidence/release-2026-08-01-04-build7-device-run-p2-2026-08-24.md)；[`P3 invalidated`](../evidence/release-2026-08-01-04-build7-device-run-p3-2026-08-24.md)；[`P4 invalidated`](../evidence/release-2026-08-01-04-build7-device-run-p4-2026-08-24.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Recorded` |
| **Phase** | P1/P2/P3/P4 均已失效；P4 两次 machine arm 均在 Human 指令前 Device disconnected |
| **Non-claims** | 不是设备字节 SHA/config digest 证明；不关闭 Task04 或 TD-003/004/005；不授权上传 |
| **Next** | 保持 Task04/TD Gate Hold；需要 Product Lead 新裁决及不同/稳定采集环境，当前 P4 禁止重试 |
| **Expiry** | 任一 build/device/OS/schema/toolchain/method 变化，或不晚于 `2026-08-26 Asia/Shanghai` |

---

## Authority

- **Product Approver / Decision maker:** Human Product Owner / Product Lead
- **Decision Source:** Human Product Owner 在 Active Codex 任务中于
  `2026-08-24 Asia/Shanghai` 明示：`授权上述有界证据例外和额外只读预检`
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md)
- **Evidence owner:** 🧪 Quality, Performance & Release Maintainer；当前 Codex task 负责记录/复核，Human Product Owner 负责设备可见状态

本 Decision 只解决当前 iOS/macOS/Xcode 27 Beta 工具限制下的证据方法。它不是 release-risk acceptance、
skipped-gate acceptance、Product Gate 或 TestFlight 外部动作授权。

## Bound Decision

仅对 frozen RC `testflight-v1.0-rc1-build7`、Build `1.0 (7)`、当前 physical iPhone 13 Pro / iOS
`27.0 (24A5418b)` 的单次 run：

1. CoreDevice 无法复制设备中已安装 bundle 字节时，允许用以下组合形成**有界 Keyboard 运行身份链**：
   - SHA-256 已固定的 Build 7 ad hoc IPA 与其中 App/Keyboard executable；
   - CoreDevice 当前安装 receipt `1.0 (7)`；
   - 每个正式 Instruments arm 中实际加载的 Keyboard Mach-O UUID 必须等于
     `08834E19-48AC-3A9C-AE0C-F53EBE94D720`；
   - frozen manifest 后禁止 build/install/uninstall/launch replacement。
2. CoreDevice 无法读取 App Group 根级 `Rime/shared` 时，允许 Human Product Owner 在额外的
   **只看不输入**预检中 Device-attest：`rime_ice` 已安装、为当前方案且九宫格已启用。正式 run 仍须以可见
   26-key/9-key行为和 loaded Keyboard UUID 失败关闭。
3. 额外只读预检不计入默认 formal Human input round；它不得输入文字、切换权限、下载/部署方案、改设置或
   触发 build/install。任何状态不符时保持 `Hold`，不得现场修复后沿用同一 manifest。
4. Activity Monitor 在当前 Beta 组合中约 `1.2 s` 后报告 `Device disconnected`，只允许把断连前
   `sysmon-process` 行表述为阶段性 Physical Footprint/Resident Size 单点观察；不得据此声明连续内存趋势、
   leak-free、预算或无回归。

## Read-only preflight outcome

`2026-08-24 Asia/Shanghai` 的额外只读预检显示：万象拼音 `v17.2.5` 为“当前使用”，部署卡为“已部署 / 配置已生效”；
雾凇拼音仅为“已安装”。这与原 manifest 的 `rime_ice + 九宫格` 计划不一致，因此原 manifest 按本 Decision
fail closed 为 Hold。此次观察未消耗 formal Human input round，也不授权现场切换方案后沿用原 manifest。

随后 Human Product Lead 在同一 Active Codex 任务中明确回复“授权”，授权范围仅为：切换当前方案至
`rime_ice`、完成部署，并在状态确认后冻结一个新 manifest、重新进行 independent readiness review。该授权使
原 P1 manifest 因 schema/config transition 立即失效；它不授权 TestFlight 上传、TD closure 或沿用 P1 证据。

只读复核随后确认：Universe Keyboard 仍为 `1.0 (7)`；设备仍为同一 iPhone 13 Pro / iOS
`27.0 (24A5418b)`；雾凇拼音显示“当前使用”和“基础检查通过”；键盘布局为九宫格，输入方案为雾凇九键
（T9）。设为当前方案后页面曾短暂保留陈旧“需要重新部署”状态；退出重进即显示基础检查通过，故既有部署已
生效且未执行冗余重新部署。这里的“完成部署”以刷新后的可见健康状态为准，不声称取得机器 config digest。
因此新 P2 manifest 已在该状态冻结，正式 Human round 仍为 `0`，必须先通过 independent readiness review。

P2 获得 readiness Go 后，final pre-action 查询发现 Keyboard Extension 在关闭 Main App并等待后仍以同一 PID
驻留。Human Product Lead 明确授权重启 iPhone，以形成真正的冷进程基线并保留正式 C 阶段唯一一次 SIGTERM。
该授权使 P2 因 boot session 变化而失效；重启后必须重新核对身份与配置、冻结 P3 并再次独立审查。授权不包含
额外 signal、TestFlight 上传或 TD closure。

P3 formal round 中，Reminders 空字段因 Universe Keyboard 原本就是系统当前键盘而在 Time Profiler 启动前自动
显示。Device Operator 未输入，P3 作为 runbook 前置条件遗漏失败关闭。Human Product Lead 随后明确授权 P4
准备工作及额外增加一轮 Human round，并报告已经切换到 Apple 系统键盘、完成设备重启。该授权只允许为 P4
建立可审计冷基线并执行既定有界序列；不授权更多轮次、额外 signal、上传或 TD closure。

## Explicit Non-claims And Prohibitions

- 不声称设备安装 App/Extension 的 SHA/size 已被直接回读验证；
- 不声称 `Rime/shared` 或 effective compiled schema 已获得机器 digest；
- 不用本例外关闭 `RELEASE-2026-0801-04`、TD-003、TD-004 或 TD-005；
- 不把 Device-attested schema 状态扩大为安装原子性、全部 Lua/OpenCC 文件或其他 schema 的证明；
- 不授权 TestFlight/App Store 上传、分组、分发、Beta Review 或 skipped-risk acceptance；
- 不允许重新构建、重新安装、下载/部署方案、复制/删除 App Group 数据或发送 memory warning。

## Follow-up And Expiry

- **Follow-up owner:** Test/release owner。
- **Required follow-up:** 在稳定、能够回读 installed payload/config digest 且 Activity Monitor 可连续采集的
  工具链/主机上补做完整机器身份与内存证据；最迟在 App Store 正式提交或扩大外部测试前重新裁决。
- **Immediate expiry:** source/tag/build、App/Keyboard UUID、device/OS、schema/config、Full Access 顺序、host、
  Xcode/Instruments 或采集方法变化。
- **Calendar expiry:** `2026-08-26 Asia/Shanghai`；若届时未补证，Product Lead 必须重新记录处置，不能静默续期。

## Related Documents

- [`RELEASE-2026-0801 external candidate decision`](RELEASE-2026-0801-external-testflight-candidate.md)
- [`Build 7 artifact ledger`](../evidence/release-2026-08-01-01-frozen-rc-build7-artifact-ledger-2026-08-24.md)
- [`Build 7 P1 invalidated device run`](../evidence/release-2026-08-01-04-build7-device-run-2026-08-24.md)
- [`Build 7 P2 formal device run`](../evidence/release-2026-08-01-04-build7-device-run-p2-2026-08-24.md)
- [`Build 7 P3 post-reboot device run`](../evidence/release-2026-08-01-04-build7-device-run-p3-2026-08-24.md)
- [`Build 7 P4 Apple-current device run`](../evidence/release-2026-08-01-04-build7-device-run-p4-2026-08-24.md)
- [`Human-operated evidence profile`](../kos/universe-keyboard-human-operated-evidence-profile.md)
- [`Performance baseline`](../PERFORMANCE_BASELINE.md)
- [`Crash/Jetsam handbook`](../CRASH_JETSAM_SYMBOLICATION.md)
