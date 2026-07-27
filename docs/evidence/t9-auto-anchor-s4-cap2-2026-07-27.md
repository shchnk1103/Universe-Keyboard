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
