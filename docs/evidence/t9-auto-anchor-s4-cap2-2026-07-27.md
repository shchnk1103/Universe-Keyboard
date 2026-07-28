# T9 S4 两音节自动锚定预检证据

- **日期：** 2026-07-27 Asia/Shanghai
- **实现 checkpoint：**
  `22d34ddb612dcf50e5dc0dde569ba82c226d3731`
- **范围：** Debug / 显式 gate；单次可回滚自动事务
- **结论：** Architecture Pass；Quality Pass；Product Gate 未执行

## 冻结身份

- `git cat-file` 确认 checkpoint 是真实 commit，正式采集前工作树干净。
- 测试可执行文件 SHA256：
  `d942c16749dbde1e648331bdcb8141abd2f436fc5e4be71dc2670d651f0bd2e8`
- shared RIME fixture SHA256：
  `003b43b465c8ba6f776b374d530c8047322da443f4341fc1ccb7e2d0fbb01c5d`
- Xcode：`27A5228h`；配置：`Debug`
- Simulator：iPhone 17 Pro Max（`iPhone18,2`），iOS 27.0，
  arm64，UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- schema：`t9`；每个 arm 使用新的严格 `/private/tmp` 子目录。

正式日志：
`/Users/doubleshy0n/Library/Developer/XcodeBuildMCP/workspaces/Universe-Keyboard-dc07bf780737/logs/test_sim_2026-07-27T15-23-48-149Z_pid42715_bab7fe4c.log`

Run Header 位于日志第 244–245 行，Run ID：
`5DE0F275-7B68-4D01-8485-3F1485A452D9`。

## 自动化结果

| 验证 | 结果 |
|---|---|
| 自动锚定聚焦测试 | 15 / 15 passed |
| KeyboardCore 全量 | 748 / 748 passed |
| 真实 RIME 整类 | 7 / 7 passed，0 failed，0 skipped |
| 24-case corpus | 24 cases；21 proposals；maximal accepted 8；cap2 accepted 9 |
| isolated S5 | 3 个 complete-learning positive + 1 个 partial negative 均通过 |
| 默认 RimeBridge | 32 passed，0 failed，15 个 fixture-gated skip；仅作非覆盖报告 |
| strict Debug build | passed，0 warning，0 error |
| strict Release build | passed，0 warning，0 error |
| RIME vendor inventory | 11 / 11 artifacts verified |

直接把 `TEST_RUNNER_*` 当作 xcodebuild build setting 的首次正式调用
产生 6 个 skip，因此按 Assignment 规则作废且未计入上述证据。随后通过
Simulator test-runner environment 重跑整类，得到 7 / 7、0 skipped。

## 冻结配对 A/B

- 合成拼音：`jintiandetianqihenbucuowomenchuquwanba`
- T9 槽位：38
- cadence：每个输入动作间隔 200 ms
- 顺序：`A→B`、`B→A`、`A→B`、`B→A`、`A→B`
- 结果：5 / 5 valid pairs；10 / 10 arms 均
  `startupValid=true`、`sessionValid=true`、`cleanup=true`
- A：gate off，全部 `attempt=none`
- B：gate on，全部恰好一次 `accepted`，`anchorSlots=7`，
  `baseline/result/overlap=5/5/5`
- 所有 B arm 均保持 `selectedPath == nil` 且
  `confirmedSegmentValues` 为空；显式 Path 接管另有确定性测试。

| Pair | `≥50 ms` B−A | median B−A | p95 B−A | worst B−A |
|---|---:|---:|---:|---:|
| 1 | -1 | +0.8 ms | -14.4 ms | -16.9 ms |
| 2 | -2 | -2.9 ms | -29.7 ms | -26.0 ms |
| 3 | -1 | +0.2 ms | -13.6 ms | -8.5 ms |
| 4 | -2 | -1.8 ms | -31.3 ms | -29.9 ms |
| 5 | 0 | +0.6 ms | -0.8 ms | -15.7 ms |

五对 p95 与 worst 均改善。局部噪声仍存在：pair 1 / 3 / 5 的 median
略增，pair 5 的 slot 24 增加 3.7 ms。`50 ms` 仍只是继承的诊断计数，
不是 Product SLO；本轮不据此定义 Release 承诺。

## 独立复审

- Architecture：P0–P3 均无，`Pass`。
- Quality：P0–P3 均无，`Pass`。
- 两份结论均绑定实现 checkpoint `22d34ddb…`，并明确不代签
  Product Gate。

## 保留边界

- Release 默认保持关闭；没有用户设置、第二次事务或 runtime backoff。
- 没有生产 personalization、App Group userdb、同步或持久化变更。
- 本证据来自 iOS 27 Simulator Debug，不替代物理设备、Release-like
  性能、内存/jetsam、人工九宫格体验或最终 Product Gate。
- 是否进入 S6、如何启用及对外性能声明仍由 Product Lead / Human
  Product Owner 决定。

## 2026-07-28 ETTrace 补充归因

### 目的与方法

- 目的：补充回答“长串输入卡顿主要消耗在哪条调用栈”，不是重新签署
  S4 性能 Gate。
- 环境：同一台 iPhone 17 Pro Max / iOS 27 Simulator、提醒事项、
  software keyboard。
- 合成拼音：
  `jintiandetianqihenbucuowomenchuquwanba`（38 个 T9 槽位）。
- A 为 Debug 自动锚定 gate 关闭；B 为 gate 开启。
- ETTrace 仅在采样构建中临时链接；A 的 gate 改动也仅用于采样。

### 证据身份

这些原始文件位于本机易失的 `/private/tmp`，不是仓库内的长期制品：

| Arm | ETTrace JSON | SHA256 |
|---|---|---|
| A1 off | `/private/tmp/universe-t9-ettrace-20260728/run-A-off-20260728-0025/output_259.json` | `c3016b489194f733fe15711b8b12865a1cdf4a7c4ba88fd811bc7dd2a7827391` |
| A2 off | `/private/tmp/universe-t9-ettrace-20260728/run-A2-off-20260728-0027/output_259.json` | `ea3114f8efb07b922c5809a65fede9578c29fbd4907b22c33aeb4f361cf6b0d1` |
| B1 on | `/private/tmp/universe-t9-ettrace-20260728/run-20260728-0014/output_259.json` | `a690b734da3a62ea6b47738781f97a449ff302686e40bafdf10c839c51dab535` |

B1 最终状态为 `expectedCandidatePreserved=true` 且未发生意外 commit。
三臂均使用同一合成序列；完整交替顺序未完成。

### 采样结果

下表为 ETTrace 中所有同名 symbol node 的 inclusive duration 聚合，单位
为秒。它用于定位热路径；递归及重入会重复计入，因此各行不能相加，也
不能把 `Table::Query` 大于其表面祖先的情况解释为时间守恒关系：

| Stack frame | A1 off | A2 off | B1 on |
|---|---:|---:|---:|
| `insertKey` | 0.456521 | 0.282269 | 0.413486 |
| `handleInsertKey` | 0.375313 | 0.190679 | 0.352020 |
| `RimeEngineImpl.processKey` | 0.360294 | 0.185550 | 0.332428 |
| `RimeProcessKey` | 0.355170 | 0.170068 | 0.317356 |
| `ScriptTranslation::Evaluate` | 0.329408 | 0.164874 | 0.276908 |
| `PrepareForMakingSentence` / `MakeSentence` | 0.267555 | 0.159659 | 0.251551 |
| `Table::Query` | 0.386882 | 0.195490 | 0.338318 |

### 可得结论

1. 三臂一致把主要成本定位在
   `insertKey → handleInsertKey → RimeEngine.processKey → RimeProcessKey →
   ScriptTranslation → Dictionary/Table`。
2. 在被采样的同步 `insertKey / handleInsertKey` 调用栈内，
   `handleInsertKey` 与 `RimeEngineImpl.processKey` 的聚合差值较小，
   且主要 inclusive duration 向下落入 RIME 查询/造句路径。这不能排除
   UI / main-thread scheduling、其他线程或物理设备上的不同归因。
3. A2 相比 A1 显著变快，与 warm state 和/或 sampling variance 一致，
   足以淹没单次 A/B 差异。A1 与 B1 虽在多个 RIME frame 上显示 B
   较低，也不能据此宣称稳定百分比改善。
4. Simulator 的 active self profile 中 `libhvf.dylib` 在 A1 / B1 分别
   占约 `35.68% / 32.14%`。这是虚拟化噪声 caveat，也说明本结果不能
   替代真机归因。

### 不可得结论与清理

- 本轮只有 `2A / 1B`，不满足交替配对矩阵；不能作为 S4 增益百分比、
  Product SLO、Release 默认启用或 Product Gate 证据。
- 计划中的 A3 / B2 / B3 因 profiling tool account usage limit 未执行；
  没有尝试绕过额度限制。
- 临时 gate 修改与 ETTrace 工程链接已全部回滚。随后使用独立
  DerivedData 完成一次普通 Debug build 作为本地清理检查；该次 build
  log 未作耐久归档，因此不作为可独立重放的冻结证据。对 App /
  Extension 主可执行文件与 Debug dylib 的 `otool -L` 检查及 App
  bundle 文件名扫描均无 ETTrace 命中。
- 本补充结果只增强根因归因。S4 的行为与配对时序结论仍以本文件前述
  冻结 `5 / 5` 矩阵为准；物理设备、Release-like 性能和 Product Gate
  仍然开放。

### 2026-07-28 补充证据独立复审

- Architecture 初审发现生命周期镜像不一致（P2）及不必要的合成候选
  正文（P3）。计划现已明确 S1/S3 证据由 S4 累计重验但生产策略仍未
  授权；候选正文已改为内容无关布尔观察。复验结果：
  `Pass`，P0–P3 均无。
- Quality 初审发现 B1 `insertKey` 聚合少计一个同名节点（P2）、归因
  强度超出 Simulator ETTrace 能力（P2），以及普通清理 build 缺少
  耐久身份（P3）。数值已按 28 个同名节点修正；inclusive 聚合、
  `libhvf`、调度/线程/真机 caveat 已补齐；普通 build 已降级为未归档
  的清理检查。复验结果：`Pass`，P0–P3 均无。
- 两个 Pass 只接受本节的 Simulator Debug 热路径补充归因与文档同步。
  它们不代签 Product Gate、真机或 Release-like 性能，不授权 S6、
  第二次事务/backoff、生产 personalization 或 Release 默认启用。
