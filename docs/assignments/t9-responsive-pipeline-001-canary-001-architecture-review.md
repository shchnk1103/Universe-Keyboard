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
