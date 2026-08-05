# CANARY-001 独立 Architecture 设计复审

| 字段 | 结论 |
|---|---|
| 复审角色 | Architecture & Knowledge Steward `/root/canary_arch_review`（独立、只读） |
| 日期 | 2026-08-03 Asia/Shanghai |
| 对象 | CANARY-001 Assignment、Architecture/Quality freeze、live-session API inventory |
| Verdict | **Pass for design I-Ready** |
| P0 / P1 / P2 / P3 | **0 / 0 / 2 / 0** |
| 边界 | 不是实现授权、E-Ready、ADR 0025 Accepted、Product Gate 或运行证据 |

## 结论

- ADR 0025 仍为 Proposed。canary 被收窄为基于真实 Extension target、
  lifecycle 和 RIME bridge 的 internal diagnostic artifact；ordinary Release
  必须在 compile/runtime 两层均不可达。违反该边界是 P0。
- pre-start kill 不创建 canary owner；active kill 只 fence 并 FIFO drain；
  timeout 进入 `FencedUnavailable`，不能授权 baseline takeover。
- 每个 `RimeEngine` entry 已有唯一 same-owner、immutable snapshot 或
  fail-closed disposition；ObjC public 旁路与 auto-anchor 在 canary v1
  fail-closed。
- ACCEPT、PUBLISH、VISIBILITY_DISPOSITION、VISIBLE 和 PAINT terminal 的
  基数与匹配规则可由 validator 拒绝性验证。
- transition receipts 使用同一
  `{runID, modeGeneration, fenceID, canarySessionInstance}`，且 baseline
  recovery 只接受正向有序 terminal。
- I-Ready 使用当前 inventory snapshot、精确 allowlist 与 design mappings；
  final diff、artifact hash 与独立 API re-audit 留在 E-Ready，不形成循环。

## 残余

### P2-01：internal artifact 身份待实现后证明

具体 compilation condition、scheme/artifact identity 与 ordinary Release
不可达证明尚未产生。它们是实现后 E-Ready 的强制证据，不得由设计文档代替。

### P2-02：最终 diff 尚未复审

当前 inventory 是 ambient-dirty working-tree snapshot。最终 source、diff、
executable/restore hash 和独立 API re-audit 必须在 E-Ready 重新冻结。

## 停止声明

Architecture 设计复审通过不激活实现、构建、测试、Simulator、真机或证据
采集，也不改变默认 gate、生产接线或 ADR 状态。

## Implementation static review addendum — 2026-08-03

| 字段 | 结论 |
|---|---|
| 对象 | Product Lead 已激活的 frozen-allowlist implementation source |
| Verdict | **Pass** |
| P0 / P1 / P2 / P3 | **0 / 0 / 0 / 0** |
| 执行边界 | 未构建、未运行测试、未运行 Simulator 或真机 |

最终静态复核确认：ordinary build setting 未定义 canary compilation
condition；enable/kill 双 gate、单 owner/fence/drain、visibility abandonment、
完整 immutable presentation identity、同步 PAINT acknowledgement 与 focused
test source 均符合 frozen design。该结论只关闭静态实现复审，不构成
`E-Ready`、ADR 0025 Accepted 或 Product Gate。

## Bounded build/test evidence review addendum — 2026-08-04

| 字段 | 结论 |
|---|---|
| 对象 | v6 manifest、冻结 source/project/vendor hashes、C02R6–C10V6 evidence |
| Verdict | **Bounded Pass / QEF provenance Partial；可交 Product Lead** |
| P0 / P1 / P2 / P3 | **0 / 0 / 1 / 0** |
| 边界 | 自动化与 Simulator 层；不是设备、Product Gate、Release 或 ADR 0025 acceptance |

独立复核确认 v6 source/project/vendor hashes 与当前冻结文件一致，无 frozen-
source drift。ordinary project settings 不含 internal compilation condition；
default-off 仅在静态/构建层获证。kill-switch、single owner、active-kill drain、
visibility abandonment、timeout fail-closed 与生命周期边界由冻结 diff 和
C02/C03/C04/C09 支持，但 C09 不是设备上的真实 RIME 生命周期证明。

P2 为 QEF provenance Partial：v6 manifest 未冻结 destination-discovery output
hash，且部分命令未显式列出 expected artifacts。该缺口不推翻命令结果，但
不可宣称完整 QEF provenance closure，也不得事后改写 immutable manifest。
C10 skips、物理设备、Full Access/host/geometry、manual presentation、设备
restore、Product Gate、Release 与 ADR 0025 均保持 `NotObserved`/未证明。

## QEF-01 run004 post-run evidence review addendum — 2026-08-04

| 字段 | 结论 |
|---|---|
| 对象 | run004 C02V9-C11V9、P01V9-P05V9 与冻结身份链 |
| Verdict | **Pass for automated/Simulator boundary；overall Partial** |
| P0 / P1 / P2 / P3 | **0 / 0 / 1 / 0** |
| 边界 | 不是物理设备、Product Gate、Release 或 ADR 0025 acceptance |

独立复核确认十份命令收据均退出 0 且绑定同一 run004 身份；六组测试共
1107 passed、20 classified skips、0 failed，`unknownSkipped=0`。P02 普通包
安装后 App/Extension 可执行文件哈希与构建产物一致，internal condition
缺失；P03-P05 的聚合、33 项发布范围及最终 inventory 均闭合。

P2 为整体证据层仍 Partial：20 个真实 fixture/provenance 行为保持
`NotObserved`，Main App launch smoke 未运行，物理设备、Full Access、真实
宿主呈现、真实 ACCEPT/PUBLISH/PAINT 时序、持续性能/内存均未证明。可交
Product Lead 决定是否用新的不可变真机 run header 单独激活设备阶段。

## DEVICE-001 physical-device evidence review addendum — 2026-08-05

| 字段 | 结论 |
|---|---|
| 对象 | DEVICE-001 pair-002 iPhone 13 Pro 真机四臂（A/B/K/O）证据、原始隔离收据、实现代码 |
| Verdict | **Pass with conditions** |
| P0 / P1 / P2 / P3 | **0 / 0 / 1 / 0** |
| 边界 | 不是 ADR 0025 Accept、Product Gate、Release default-on、生产接线或 App Group/userdb 清理 |

### 结论

独立复核确认 DEVICE-001 pair-002 四臂真机证据在 assignment 冻结边界内有效。
原始隔离收据与规范证据文档、summary JSON、run header 之间的关键字段自洽。实
现代码的 fail-closed 语义与证据记录一致。以下逐项核实：

**边界遵守。** 所有工作严格限定在 assignment 冻结 allowlist
（`ResponsiveRimePreflight.swift`、`T9DevicePreflightEvidenceView.swift`、
`KeyboardViewController+Bootstrap.swift` 的指定收据点）。未发现 default gate
变化、用户可见设置新增、生产接线、App Group/userdb 清理、uninstall 或 raw 内
容泄漏进仓库证据。ADR 0025 保持 **Proposed**；证据文档与 summary JSON 均明确
写入 `notClaimed: ["ADR 0025 Accept", "Product Gate", "Release default-on",
"production wiring", ...]`，未发现不当声称。

**K 臂 kill-switch 语义。** `assertCanaryKill`（ResponsiveRimePreflight.swift
L221–258）写入 `kill=true`、flush、然后以 typed-boolean 读回 `kill` 并校验
`runID` 一致性。原始收据 `K-kill-launch.json` 证实 `devicectl` 以
`T9_CANARY_ASSERT_KILL_RUN_ID=CANARY001-D001-5C6D32C8-...` 启动 Main App，
outcome=success。证据记录
`actor=app phase=kill kill=1 decision=kill status=success`——该断言独立于
expiry，因为 `assertCanaryKill` 函数内部不检查 expiry。扩展启动后
`decision=baseline`，代码路径
`shouldTerminateActiveCanary`（L429–441）以 `killSwitch || ... ||
expiry` 为析取条件，kill=1 单独即足以触发终止。证据文档（L66–67）如实记录混
杂因素："canary 配置当时已过期（expiryState=expired），扩展 fail-closed 是
kill=1 与过期共同作用；phase=kill decision=kill 断言本身独立证明 kill 写入生
效"。该混杂披露完整、诚实。kill 后输入走 `run=invalid path=sync`，无
`marker=ACCEPT`，单 session，无并发 owner——与代码语义一致。

**A/B 对比有效性。** 同一设备（UDID `00008110-000A08440198801E`）、同一
fixture（`CANARY-001-D001-39-V1`，digest `a71ccfba...a068ac` 在 A/B 间未变
化）、Human cadence 显式标注为 confound。A 臂原始收据
`A-pair002-post-input-receipt.json` 确认 39 segs、`path=sync`、
`no_canary_config=true`，slow actions 24/29/32 的 rime 208–229ms 与 Human
stallScore=2.5 位置一致。B 臂原始收据 `B-pair002-post-input-receipt.json` 确认
39 actions、`canary_enable_1_kill_0_valid_1=true`、ACCEPT inline 中位 0.3ms、
RIME bridge 同位置 208–242ms、coalescing rev[24,25,26]→paintRev 26（lag
22ms）、rev[32,33]→paintRev 33（lag 96ms）、provisional_lagMs 50–52ms。B 的
ACCEPT/PUBLISH/PAINT terminal 在机器验证层通过
（`r5p_accept_inline=true`、`r5p_coalescing_observed=true`、
`r5p_provisional_paints=true`）；完整 terminal 枚举位于原始隔离 paste 中，机
器 validator 为指定验证者——独立架构复审在隐私边界内接受该验证。

**单 owner / 无并发访问。** B 臂使用 `T9_RESPONSIVE_CANARY_INTERNAL` 编译条件
下的 `installProductionShapedCanaryIfArmed`（L396–470），经
`responsiveCanaryModeCoordinator.evaluateStartup` 原子解析配置快照后安装唯一
thread-affine owner。所有可达 session API 走同一 owner 或显式 fail-closed。
K 臂 kill 后 `noConcurrentOwner=true`，代码中 `shouldTerminateActiveCanary`
为析取 fail-closed，任一条件触发即终止。

**O 恢复。** 原始收据 `O-install.json` 确认替换安装成功
（databaseSequenceNumber 3960，container `A5AAD9BA-...`）。run header 中 O 的
App/Extension SHA-256（`65d90433...` / `d911e011...`）与安装身份一致。
`internalCanaryStringScan: absent`，`builtBeforeAnyBInstall: true`。Human smoke
记录为键盘切换+候选+Delete+空格+基本输入正常无异常。O 不包含 canary 编译条
件，普通 Release 无 canary 能力——run header L64 确认 `conditions: []`。

**隐私与保留。** 仓库证据仅含 content-free marker、聚合、hash、status 与
Human 完整性/主观报告。所有原始隔离收据标注
`publishability=quarantined-local-only`，存放于 gitignored 目录
`evidence/CANARY-001-DEVICE-001/raw/`。未发现 raw 输入、拼音、候选、宿主文
本、截图、UI hierarchy 或 userdb 内容进入仓库证据。隐私边界完整。

### 残余

#### P2-01：K 臂 kill/expiry 混杂——扩展启动 fail-closed 观察为 kill=1 与过期共同作用

证据已如实记录该混杂（证据文档 L66–67、run header L201、summary JSON
`confound: "expired + kill=1 joint fail-closed"`）。`phase=kill decision=kill`
断言本身就 kill 写入/读回而言独立于 expiry（`assertCanaryKill` 函数不检查
expiry），但扩展启动 `decision=baseline` 的单一观察无法将 kill=1 与 expiry 的
贡献分离。代码层面 `shouldTerminateActiveCanary` 以析取条件正确处理 kill=1 单
独触发终止，因此该混杂不构成代码缺陷；它仅限制从本观察中声称"kill=1 在未过期
配置下单独使扩展进入 baseline"。若未来需要非过期 kill 证据，应安排一次 expiry
在未来的 K 臂重放。

#### NotClaimed（本证据明确不能声称的事项）

以下均为 assignment 显式非目标或本证据层未覆盖，且已在证据文档与 summary JSON
中列入 `notClaimed`，独立复审确认未被声称：

- ADR 0025 Accepted / Product Gate / Release default-on / 生产接线
- Full Access OFF 行为（本 phase 固定 ON）
- 长期内存/jetsam 行为（39-event 有界 fixture 不构成持续负载证明）
- 多设备/iOS 版本复现（单台 iPhone 13 Pro / iOS 27.0 Beta）
- App Group/userdb 清理（assignment 明确不执行）
- Human cadence 去混杂后的定量 benchmark（cadence 显式标注为 confound）
- pair-001 废弃前的 B 首次 prepare 成功（pair-002 B 经 readbackMismatch 修复后重建）

### 停止声明

DEVICE-001 真机证据独立架构复审不激活 ADR 0025 Accept、Product Gate、Release
default-on、生产接线、默认 gate 变更或任何超出 assignment allowlist 的代码修
改。复审完成后停止，不自行宣布 canary Pass、生产可用或 Release 许可。Product
Lead 对 CANARY-001 做最终处置。
