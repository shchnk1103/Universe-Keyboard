# T9-RESPONSIVE-PIPELINE-001 / CANARY-001 / DEVICE-001 真机证据

状态：**pair-002 四臂（A/B/K/O）执行完成，设备层证据已收口**。这是一份
Product-authorized、content-free 的生产形态 canary 方向证据，不是 ADR 0025
接受、Product Gate、Release 默认开启或生产接线批准。

日期：2026-08-04 → 2026-08-05（Asia/Shanghai）

## 边界与环境

| 字段 | 值 |
|---|---|
| Assignment | [`CANARY-001 / DEVICE-001`](../assignments/t9-responsive-pipeline-001-canary-001-device-001.md) |
| 父 Assignment | [`CANARY-001`](../assignments/t9-responsive-pipeline-001-production-shaped-canary-001.md) |
| Pair | `CANARY001-D001-PAIR-20260804-002`（pair-001 因 A 臂 Delete+retype 协议违规作废） |
| Fixture | `CANARY-001-D001-39-V1`，39 actions；digest `a71ccfba…a068ac`；原始拼音仅本地隔离 |
| 运行时 marker fixture | `T9RESP-R5P` |
| Host | Reminders 空条目；portrait；Universe Keyboard 中文九宫格；暗色外观 |
| Human 操作 | 手动点击可见字母分组键；无 Delete、无候选/Path/数字/空格/确认、无坐标自动化 |
| Device | iPhone 13 Pro / `iPhone14,2`；UDID `00008110-000A08440198801E` |
| CoreDevice | `DE65EBE1-463E-5EB4-9694-F6DCBFC04028`；opaque identity SHA `f5d2508e…4dc9b` |
| OS | iOS 27.0（`24A5390f`）Beta |
| Source | HEAD `3585a540…`；compiled aggregate `a541b226…`；pre/post-build fingerprint equal |
| Toolchain | Xcode 27.0（27A5228h）；iPhoneOS SDK 27.0；Swift 6.4；Release；warnings-as-errors |
| Full Access | ON（本 canary phase 固定）；OFF 行为保持 NotRun |
| Schema | rime_ice（Human 观察为雾凇拼音） |
| 评分方向 | `0 = 完全不卡`，`4 = 严重卡顿`；分数越低越好 |

## 四臂结果

| Arm | 路径 | 安装序列 | Human 评分 | 关键机器结果 |
|---|---|---|---|---:|---|
| A | sync（`T9_AUTO_ANCHOR_DEVICE_PREFLIGHT`，gate `0/0`） | 3936 | **2.5/4** | 39 segs 完整；action 24/29/32 RIME 尖峰 208–229ms；total 最大 229.9ms |
| B | thread-affine（追加 `T9_RESPONSIVE_CANARY_INTERNAL`，dual gate `1/1`） | 3952 | **0/4** | ACCEPT inline 中位 0.3ms；RIME bridge 最大 242.5ms（同位置 action 24/29/32）；provisional 路径保持 UI 响应 |
| K | B artifact + 外部 internal-only kill 断言 | — | — | `phase=kill kill=1 decision=kill status=success`；扩展启动 `decision=baseline`；kill 后无 canary ACCEPT |
| O | 普通 Release（无诊断/内部编译条件） | 3960 | 正常 | 安装身份 hash 匹配冻结 O；app 无 canary 字符串；键盘/候选/Delete/空格冒烟正常 |

### A 臂（sync 基线）

- 39 条有序 T9SEG（action/event `1..39`）、`committed=false`、`rawLen 1..39` 无下降；
  `T9ARM actions=38` checkpoint；`sessionStable=true`。
- `total_ms` 中位 `15.5`、最大 `229.9`；`rime_ms` 中位 `7.2`、最大 `228.6`。
- 慢 segment 集中在 action `1/6/9/19/24/29/32`；其中 action 24/29/32（第二个
  `zhonghuarenmin` 窗口）RIME 208–229ms，与 Human 报告 stallScore=2.5 的卡顿位置一致。
- `PATH path=sync dualGateRequested=0 dualGateActive=0`；无响应式 ACCEPT/PUBLISH 链。

### B 臂（R5P 响应式 provisional）

- 39 条有序 action、`canary_enable=1 kill=0 valid=1`、`pipeline=T9RESP-R5P`。
- `accept_ms` 中位 `0.3`、最大 `0.9`（即时本地反馈）；`rime_bridge_ms` 中位 `58.4`、
  最大 `242.5`（action 24/29/32，与 A 臂相同位置）。
- coalescing 观察：rev `[24,25,26]` 合并后 paintRev 26（lag 22ms）、rev `[32,33]` 合并后
  paintRev 33（lag 96ms）；`provisional_lagMs` 恒定 50–52ms。
- **关键方向结果**：同一位置 RIME bridge 208–242ms 时，A 臂 Human 感知卡顿（2.5），
  B 臂 provisional 路径让 UI 保持响应（0）。这直接印证 R5P 的目标——引擎慢时 UI 不冻结。
- `paint_lagMs_engine` 中位 7、最大 208；所有 ACCEPT/PUBLISH/PAINT terminal 完整。

### K 臂（kill-switch 断言）

- `[19:33:24] CANARY_CONFIG actor=app phase=kill kill=1 … decision=kill status=success`：
  显式 kill 断言写入并读回成功，独立于 expiry。
- kill 后扩展启动：`actor=extension phase=startup enable=1 kill=1 expiryState=expired
  decision=baseline status=success`——扩展 **fail-closed 到 baseline**，不启动 canary owner。
- kill 后 Human 输入：所有 T9SEG `run=invalid path=sync`，**无任何 `marker=ACCEPT`**；
  单 session，无并发 owner。
- 混杂因素：canary 配置当时已过期（`expiryState=expired`），扩展 fail-closed 是
  `kill=1` 与过期共同作用；`phase=kill decision=kill` 断言本身独立证明 kill 写入生效。

### O 臂（恢复普通 Release）

- 替换安装成功（databaseSequence `3960`，晚于 B 的 `3952`）；安装后容器
  `A5AAD9BA-…`；App/Extension 可执行 hash 与冻结 O 一致（`65d90433…` / `d911e011…`）。
- 已安装普通 Release 二进制字符串扫描：canary marker/环境键/偏好键 **absent**。
- Human O smoke（2026-08-05）：键盘切换 + 候选 + Delete + 空格 + 基本输入**正常无异常**。

## 证据绑定与隐私

原始附件与 run header 留在本地隔离目录 `evidence/CANARY-001-DEVICE-001/raw/`
（`publishability=quarantined-local-only`），仓库只记录 content-free marker、聚合、
hash、status 与 Human 完整性/主观报告。不保存 raw 输入、拼音、候选、宿主文本、
截图、UI hierarchy 或 userdb。

| 证据文件 | 路径 |
|---|---|
| 最终 run header | `t9-responsive-pipeline-canary-001-device-001-run-header-final-2026-08-04.json` |
| pair-002 run header（pre-input 快照） | `t9-responsive-pipeline-canary-001-device-001-run-header-pair-002-2026-08-04.json` |
| 机器 summary | `t9-responsive-pipeline-canary-001-device-001-summary-2026-08-04.json` |
| 本地隔离收据（A/B post-input、K、O） | `evidence/CANARY-001-DEVICE-001/raw/`（gitignored） |

## 结论与停止点

已证明（生产形态、default-off 内部 canary、同一 iPhone 13 Pro）：

1. B（R5P）在真实 librime 慢桥（208–242ms）下保持 UI 无卡顿（Human 0/4），A（sync）
   同位置 Human 卡顿（2.5/4）——方向与 P2-PERF-03 一致。
2. 显式 kill-switch 断言写入/读回成功；kill 后扩展 fail-closed 到 baseline，无 canary
   ACCEPT，无并发 owner。
3. O 普通 Release 可安全恢复，安装身份匹配、无 canary 痕迹、人工冒烟正常。

未证明（保持关闭）：ADR 0025 Accept、Product Gate、Release default-on、生产接线、
Full Access OFF 行为、长期内存/jetsam、多设备/iOS 版本复现、App Group/userdb 清理
（按 assignment 明确不执行）。

设备层 DEVICE-001 至此**执行完毕**，本记录交给独立 Architecture 与 Quality 复审；
复审完成后停止，不自行宣布 canary Pass、生产可用或 Release 许可。Product Lead 将
对 CANARY-001 做最终处置。
