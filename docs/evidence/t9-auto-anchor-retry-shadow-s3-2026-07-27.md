# T9 S3：首次回滚后的后续机会影子观测

**日期：** 2026-07-27
**设备：** iPhone 17 Pro Max Simulator / iOS 27
**宿主：** 提醒事项 / software keyboard
**构建：** Debug，S2 显式实验门开启
**测试串：** `mingtianzaoshangwomenyiqiqugongyuanpaobu`（40 个 T9 槽位）

## 目的与边界

本次只回答一个问题：S2 第一次锚定被候选守恒拒绝并恢复纯数字后，
随着用户继续输入，已经返回的后续快照中是否会再次稳定出现可提议的锚定前缀。

新增的 `T9AutoAnchorRetryShadowAnalyzer`：

- 仅在 S2 ledger 已处于 `rejected` 后观察；
- 只读取当前按键已经返回的纯数字 raw 与 `RimeOutput`；
- 复用纯函数 `T9ReversibleAutoAnchorPolicy.proposal`；
- 不调用 RIME、不修改状态、不执行第二次 `replaceInput`；
- 只记录状态和计数，不记录数字、拼音、候选或宿主内容。

因此，本证据不能证明第二次事务的候选守恒，也不授权改变 ADR 0024
的一次尝试上限。

## 自动化验证

| 验证 | 结果 |
|---|---|
| 新增 observer 聚焦测试 | 4 / 4 passed |
| S2 + observer 聚焦测试 | 13 / 13 passed |
| KeyboardCore 全量 | 742 / 742 passed |
| iOS 27 Simulator Debug build | passed，0 warning / 0 error |
| iOS 27 Simulator Release build | passed，0 warning / 0 error |
| Release Extension marker scan | 无 `T9RETRYSHADOW` / observer 符号 |

聚焦测试覆盖：

- 拒绝发生的同一长度不观察；
- 后续合格快照只返回计数且不修改 `KeyboardState`；
- 后续不合格快照返回 `notEligible`；
- 非 rejected phase 或非纯数字 live raw 时 fail closed。

## 三轮真实 UI 结果

三轮都在第 18 槽发生唯一一次真实 S2 尝试，并得到相同结果：

`rejectedAndRestored baseline=5 result=5 overlap=2 anchorSlots=11 unresolvedSlots=7`

拒绝后，每一轮的后续影子状态完全一致：

| 状态 | source slot |
|---|---|
| `proposalReady` | 21, 23, 25, 27, 28, 30, 31, 33, 34, 35, 37, 38, 39, 40 |
| `notEligible` | 19, 20, 22, 24, 26, 29, 32, 36 |

`proposalReady` 的锚定 / 未解决槽位计数也在三轮间完全一致：

| source slot | anchor slots | unresolved slots |
|---:|---:|---:|
| 21 | 16 | 5 |
| 23 | 18 | 5 |
| 25 | 21 | 4 |
| 27 | 23 | 4 |
| 28 | 23 | 5 |
| 30 | 25 | 5 |
| 31 | 27 | 4 |
| 33 | 27 | 6 |
| 34 | 27 | 7 |
| 35 | 31 | 4 |
| 37 | 31 | 6 |
| 38 | 31 | 7 |
| 39 | 35 | 4 |
| 40 | 35 | 5 |

## 与耗时尖峰的关系

五个主要慢键都紧跟在一个 `proposalReady` 槽位之后：

| 前一槽影子机会 | 慢键 | Run 1 RIME / total | Run 2 RIME / total | Run 3 RIME / total |
|---:|---:|---:|---:|---:|
| 21 | 22 | 140.2 / 143.0 ms | 53.1 / 55.9 ms | 130.7 / 133.7 ms |
| 23 | 24 | 78.5 / 81.3 ms | 61.6 / 64.3 ms | 71.4 / 74.3 ms |
| 25 | 26 | 84.0 / 87.0 ms | 74.7 / 77.4 ms | 81.7 / 84.4 ms |
| 31 | 32 | 94.8 / 97.5 ms | 87.3 / 90.0 ms | 90.8 / 93.6 ms |
| 35 | 36 | 104.9 / 107.6 ms | 95.3 / 98.2 ms | 102.4 / 105.5 ms |

这是相关性证据：后续快照反复给出可锚定提议，而且这些机会位于下一次
RIME 尖峰之前。它支持继续研究“失败后何时允许重新尝试”，但不能证明
实际应用该提议后仍能通过候选守恒，或一定消除对应尖峰。

## 结论与下一门槛

1. 后续机会不是随机噪声：位置与槽位计数在 3 / 3 轮完全一致。
2. 一次尝试永久锁死会错过多个稳定的后续机会。
3. 下一步不应直接放开任意重试；应先冻结一个离线/测试事务矩阵，对每个
   `proposalReady` 位置实际执行候选守恒比较，并记录接受率、恢复率与耗时。
4. 只有经过 Architecture / Quality 复核，并由 Product Lead 明确修改
   “每个 composition 一次尝试”上限后，才能在真实输入路径增加第二次事务。
