# T9-RESPONSIVE-PIPELINE-001 / P2-PERF-02 — B 臂真机证据

状态：**Partial — 有效 B 行为观察，取证完整性仍开放**

日期：2026-08-01（Asia/Shanghai）
Assignment：[`t9-responsive-pipeline-001-p2-perf-02-release-like.md`](../assignments/t9-responsive-pipeline-001-p2-perf-02-release-like.md)

## 范围与边界

本记录只描述 iPhone 13 Pro 上的 Release-optimized 内部诊断 B 臂，不是
Release 默认路径、ADR 0025 Accept、R6、Product Gate 或 App Store 证据。
本次未修改生产逻辑；测试后已替换回 A/普通 gate-off 包并发起一次性
preflight envelope cleanup。

## Run Header

| 字段 | 值 |
|---|---|
| Fixture | `jintiandetianqizhenbucuowomenchuquwanba` |
| Device | iPhone 13 Pro，UDID `00008110-000A08440198801E` |
| OS | iOS 27（附件未提供更细 minor/build） |
| Configuration | `Release`，iPhoneOS 27 SDK，deployment target 26.4 |
| B flags | `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` + `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` |
| Auto-anchor enabled flags | 未定义 |
| Run token | `S6A-A01A9F248ED449A4836888D883E36ABB` |
| B App SHA-256 | `8b17a0d7cf4184af8a60c387531427e3a8773a1a93405dcd33a13d22517ca288` |
| B Extension SHA-256 | `963a18dd94702ee446fd1f6ac9ae9ebd293e9cd8f10775bb471818c0c46ed438` |
| Raw attachment SHA-256 | `58435795147c59560d4770b03a3adacf2ba9ce6f0c02fd46a362a96e6f62845b` |
| Human report | 无漏键、重复、候选消失或键盘退出；主观上与上一轮相同，整体流畅 |
| Numeric stall score | 未提供，不将定性“流畅”擅自转换为 0–4 数值 |

## 观测结果

### 1. Run 身份与保留范围

- `T9DEVICE marker=T9DEVICE_DISABLED run=S6A-A01... gate=off measurement=on`：
  这是 auto-anchor 设备 gate，`gate=off` 不等于 responsive B gate 关闭。
- `T9SEG` 连续保留 action/event **1–39**，全部绑定到合法 run token。
- `T9ARM` 记录 `actions=38 committed=0`。

### 2. B 路径行为

每个 revision 均出现：

1. `T9RESP marker=ACCEPT ... pending=1`；
2. `T9RESP marker=VISIBLE ... source=provisional`（慢调用时先出现）；
3. `T9RESP marker=PUBLISH ... pendingAfter=...`；
4. 第二条 `T9RESP marker=PUBLISH fixture=T9RESP-R5P epoch=1 rev=...`。

第 4 条由 `KeyboardController.performResponsivePresentationApply` 在
`isThreadAffineRimeOwnerEnabled` 时专门发出，因此这组 `[PERF]` 记录对
thread-affine B 路径有强支持。正式 `PATH/READY` engine-category 标记未被
本次 `[PERF]` 导出包含，故仍保留为路径取证条件。

### 3. 慢 RIME 与主观体验

保留到 5 条慢 RIME 记录：

| 位置（按日志顺序） | `processKey` API | 同时可见的行为 |
|---|---:|---|
| 首键 | 56.5 ms | provisional/engine visible |
| 中段 | 147.1 ms | ACCEPT 与后续输入继续出现 |
| 中段 | 151.3 ms | provisional 先于 engine visible |
| 后段 | 178.7 ms | ACCEPT/engine publish 仍有序 |
| 后段 | 181.9 ms | provisional 先于 engine visible |

这支持一个有限结论：RIME 仍可能耗时约 150–182 ms，但 B 臂先接受输入并
提供 provisional 视觉反馈，因此没有把同等时长直接暴露为按键热路径卡顿；
Human 也报告整体流畅。它不表示 RIME 结果始终零延迟，也不表示真实生产
Release 已获准默认开启。

## 取证缺口

1. `T9GEOM phase=prepared` 有合法 token，但首键前出现
   `T9GEOM phase=execution run=invalid status=unavailable`；执行几何连续性未证明。
2. 所有 `T9SEG` session 字段为 `sessionBefore/After=0 valid=false`，最终
   `T9ARM session=0 sessionStable=false sessionValid=false`。这表示当前
   thread-affine bridge 的诊断接口没有向指标暴露真实 RIME session identity，
   不能把 session 稳定性写成通过。
3. 导出未包含 `T9RESP marker=PATH path=thread-affine` / `READY` 的
   engine-category 行；第二条 thread-affine-only `PUBLISH` 提供强旁证，但
   不是完整 PATH/READY 取证。
4. 没有数值化 Human 0–4 stall score、队列/内存/jetsam、其他设备/OS、
   iOS 26.0 Release RC 或 Product Gate 证据。

## 结论与后续

- **已证明（bounded）：** 合法 run 的 B 内部诊断包在真实 iPhone 13 Pro 上
  产生了 thread-affine-only publish 标记；慢 `processKey` 出现时，按键接受与
  provisional 反馈仍可先行；本次人工输入无可见完整性回归，主观体验流畅。
- **未证明：** 完整 session/geometry 合同、完整 PATH/READY 取证、真实
  Release/多设备/内存稳定性，以及生产默认开启资格。
- A/普通 gate-off 包已替换安装，B envelope cleanup 已发起；该设备不应被
  视为已切换到生产异步默认路径。
- 交给独立 Architecture 与 Quality 复审；复审应把本记录标为
  **Pass with conditions / Partial evidence**，不得宣布 Spike Pass、ADR
  Accepted 或 Product Gate。
