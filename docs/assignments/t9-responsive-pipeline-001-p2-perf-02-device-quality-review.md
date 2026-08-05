# 独立 Quality / Performance 复审：P2-H-06 真机 A/B Evidence

| 字段 | 结论 |
|---|---|
| 复审角色 | 🧪 Quality, Performance & Release Maintainer（独立、只读） |
| 复审日期 | 2026-08-02（Asia/Shanghai） |
| 复审对象 | [`P2-H-06 真机运行证据`](../evidence/t9-responsive-pipeline-p2-perf-02-device-2026-08-02.md) |
| 关联合同 | [`P2-PERF-02 Release-like Assignment`](t9-responsive-pipeline-001-p2-perf-02-release-like.md)、[`Evidence Contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md)、[`Evidence Hardening Quality review`](t9-responsive-pipeline-001-p2-perf-02-evidence-hardening-quality-review.md)、[`Evidence Hardening Architecture review`](t9-responsive-pipeline-001-p2-perf-02-evidence-hardening-architecture-review.md) |
| 复审范围 | A/B 真机行数、Human 评分、raw/marker-only validator、隐私误报、性能指标、build/hash/flags、restore/cleanup、validator/metrics 源码 |
| Quality 结论 | **Partial（真实设备事实可复核，但合同闭合条件未满足）** |
| P0 / P1 / P2 / P3 | **0 / 0 / 3 / 2** |
| 治理边界 | 不宣布 Product Gate、Release、ADR 0025 Accepted、生产 off-main 完成或默认开启 |

## 1. 复审方法与证据分层

本次没有修改生产逻辑、测试、Assignment、ADR 或设备状态，也没有提交。独立核对分为三层：

1. **真机日志重放**：使用当前临时目录中 A/B 的 content-free raw 与 marker-only 日志，
   以项目内 `T9ResponsiveEvidenceValidator` 编译临时只读 CLI 重放；
2. **独立算术/指纹核对**：重算事件行数、session/geometry 唯一值、阶段 median/max、
   raw log SHA-256、App/Extension executable SHA-256，并检查 build 命令和项目默认 flags；
3. **执行者报告复核**：对 evidence 文档声明但本机没有可重建附件/运行过程的字段，明确标为
   executor-provided，不能冒充本角色重新执行。

当前 worktree 本身仍是 dirty；`HEAD=3585a540ba8389673acd49128d87040ac9619f27`。
真机 evidence 记录的 63 个既有变更与当前复审期间的 ambient 文档变化不归因、不覆盖。

## 2. 独立核对结果

### 2.1 日志文件与 logical row counts

证据文档声明的 raw hash 与当前临时文件一致：

| 臂 | raw 日志（本机临时路径） | raw SHA-256 | marker-only SHA-256 |
|---|---|---|---|
| A | `/private/tmp/universe-keyboard-p2-h06-A-run.log` | `ff4b332c18fe942f6a5394f129cd62c0ef0007278012fbd814da814b814be7fd` | `9b887e9b4996a1c2915c9bbcd0e9cc5183958bdaaf05b7841502c66e466d11dc` |
| B | `/private/tmp/universe-keyboard-p2-h06-B-rime_diag_log.txt` | `385c74a60ea2efd434fe08ee284ef8927f4009dc2b8713a049c7d3549633859c` | `68b1924ba29d2b9b5a87ff5b421b9990514308bd16e5cdfa194f35d5058050a7` |

`wc -l` 的换行行数为 A raw=76、A marker-only=70、B raw=220、B marker-only=215；B raw
末行无 trailing newline，Swift parser 实际读取 221 个文本行。这些总行数不是输入动作数，
以下 marker 行数才是合同相关计数：

| Marker / 事实 | A | B | 独立核对 |
|---|---:|---:|---|
| physical `T9SEG run=` | **39** | **39** | action/event 1…39 连续 |
| `SLOW T9SEG` duplicate warning | 5 | 0 | 不计为第二次物理 action |
| `SLOW RIME` | 6 | 6 | 两臂均有 processKey 慢调用 |
| `T9DEVICE` | 1 | 1 | schema=v1、gate=off、measurement=on |
| `T9GEOM` | 2 | 2 | prepared/execution 各一条、单一 digest |
| `T9RESP PATH` | 1 (`sync`) | 1 (`thread-affine`) | gate 字段与 evidence 一致 |
| `T9RESP READY` | 0 | 1 | B 为 config-only/owner-thread |
| `T9RESP ACCEPT` | 0 | 39 | B revision 1…39 |
| `T9RESP VISIBLE` | 0 | 42 | B provisional=6、engine=36 |
| `T9RESP PUBLISH` | 0 | 72 | B lag publish=36、epoch-bound=36 |
| B epoch-bound publish 缺口 | — | **rev 16、25、33** | 与 evidence 声明一致 |

A/B 两臂的 39 个 physical `T9SEG` 均为 `committed=false`。独立字段扫描还确认：A native
session 为 `4444243096`，B 为 `4712770776`；两臂各自 39 行的 before/after identity
相同且 `validBefore/After=true`。A geometry digest 为
`1e4c12c19d5c7add52dd0badb190ca4432abebac4e2cd1617c36bb5c190930b2`，B 为
`ee6dac9fbbeb6286c06daf5ec709621193958253287275b4eb8ac15bf11d64f2`，各自 prepared 与
execution 一致。

### 2.2 raw / marker-only validator 结果

使用项目当前 `T9ResponsiveEvidenceValidator`，分别以正确的 canonical run token 和
`arm=.sync` / `arm=.threadAffine` expectation 重放：

| 臂 / 输入 | Validator status | reasons | 其他独立字段 |
|---|---|---|---|
| A raw | **Blocked** | `privacy-sensitive-content`、`publish-marker-missing`、`accept-revisions-not-complete` | 39 segments；path/geometry/session 均有效 |
| A marker-only | **Partial** | `publish-marker-missing`、`accept-revisions-not-complete` | privacy=false；39 segments；path/geometry/session 均有效 |
| B raw | **Blocked** | `privacy-sensitive-content`、`epoch-bound-publish-incomplete` | 39 segments；PATH/READY/geometry/session 均有效 |
| B marker-only | **Partial** | `epoch-bound-publish-incomplete` | privacy=false；39 segments；PATH/READY/geometry/session 均有效 |

这与 evidence 文档的 raw/marker-only 摘要一致。`Blocked` 不是本次发现真实用户文本泄漏；
它主要由下节的 privacy false positive 触发。去除慢调用摘要后，A/B 的真实证据仍然是
`Partial`，不是 Complete。

### 2.3 `candidates=12` privacy false positive

两份 raw 日志各自有 6 条 `SLOW RIME ... candidates=12,`。独立扫描未发现
`rawInput=`、`composition=`、`candidate=` 文本、`markedText=`、`hostText=`、`pinyin=`、
`userDictionary=` 或非 ASCII 字节；`candidates=12` 是 content-free 候选**数量**摘要。

当前 validator 的 `containsPrivacySensitiveContent` 以字符串包含
`"candidates="` 即拒绝，因而把合法计数误判为 privacy violation。这解释了 raw A/B
均为 Blocked，而 marker-only 对照 privacy=false；它不能被写成“发现候选内容泄漏”。
同时，这个误报说明 validator 尚未区分安全的非负计数与候选文本字段，保留为 P3 hardening
缺口，而不是把 raw `Blocked` 降格为真实隐私事故。

## 3. Human 评分与 A/B 性能事实

### 3.1 评分口径

本次评分方向已明确并与 Assignment 一致：**0=最卡，4=最流畅**。

| 臂 | 漏键 | 重键 | 候选消失 | 键盘退出 | Human 评分 |
|---|---|---|---|---|---:|
| A sync | 无 | 无 | 无 | 无 | **3/4** |
| B thread-affine | 无 | 无 | 无 | 无 | **4/4** |

评分是 Human 主观观察，不是自动从延迟换算的 SLO；本 review 不把 3/4、4/4 宣称为产品
预算或普遍用户结论。

### 3.2 独立重算的 `T9SEG` 阶段统计

| 指标 | A sync | B thread-affine |
|---|---:|---:|
| `total` median / max | 15.8 / 202.0 ms | 0.3 / 2.3 ms |
| `ui` median / max | 5.3 / 10.5 ms | 0.2 / 2.1 ms |
| `rime` median / max | 9.0 / 200.8 ms | 0.0 / 0.0 ms |
| `engine` median / max | 10.0 / 201.0 ms | 0.1 / 1.2 ms |
| `pathUI` median / max | 4.8 / 9.8 ms | 0.0 / 0.0 ms |
| `SLOW RIME` 最大 `bridge` | 200.7 ms | 202.2 ms |

该方向与设备 evidence 的解释一致：B 的 MainActor accept/UI 热路径显著短于 A，但真实
librime `processKey` 慢调用仍在 B 的后台 owner 侧出现。它支持“主观输入响应方向改善”的
单设备 bounded observation，不证明所有设备/输入节奏都满足不卡顿 SLO。

## 4. Build、hash 与 flag 复核

### 4.1 独立重算的 executable hash

| 臂 | App SHA-256 | Keyboard.appex SHA-256 |
|---|---|---|
| A | `ee176c6652ac21e6b8a660a47fb809bf371deb959d4f494ac119277e9fbb5229` | `4fde6e616b16b9e491572ed2b9f422116fccd64eec8d401948799c2eb1a65708` |
| B | `ff727c47d572361a9c42465bdf855effd6cc72550f5982d07c3c912d9ba349da` | `b67f254c54bbc4134d9d7f05fd9fd409571ba8f4c4bda2419d631e2565a243d5` |
| Restore | `3c9aa210fe80b9631e0f3bcc224d22da94ba2da50e700cb42e6ab2b3359e30c9` | `60ea7cafa58f38fa2ce2216509078e64ad08974aa1808b273a8e17df21ffbb87` |

三组 hash 均与 evidence 文档声明一致。A/B/Restore build log 均显示 `BUILD SUCCEEDED`、
Release、iPhoneOS 27.0 SDK、deployment target iOS 26.4 和开发签名内部包：

- A 仅注入 `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT`；
- B 注入 `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` + `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`；
- Restore 不注入 preflight flags。

独立 `project.pbxproj` 扫描未发现 preflight flag 写入项目默认 compilation conditions；
因此这三组包的显式 flag 差异与 default gate-off 边界相符。Restore 产物仍可能包含共用
诊断字符串，这是静态共享模块的存在性事实，不能单独当作运行时 preflight 已开启。

## 5. Restore / cleanup 复核

本机可读的 `/private/tmp/universe-keyboard-p2-h06-after-cleanup-copy.json` 显示从真实
iPhone 13 Pro App Group 成功复制 cleanup 后 plist；其 `deviceIdentifier` 与本次设备一致。
cleanup 后 plist 中没有 `t9_s6a_run_envelope`、`t9_s6a_matrix_tokens` 或待导出的
`rime_diag_log` 内容，只保留普通 `rime_diag_summary`/readiness 等运行状态。该结果与
evidence 的“按 token 精确清理、保留普通诊断存储、不删除用户数据”声明一致。

Restore `devicectl device install app` JSON outcome 为 `success`，数据库 sequence number
为 **3680**；Restore App/Extension hash 与上表一致。没有发现卸载、container wipe、
RIME/userdb reset 或提醒事项数据删除记录。

仍缺少一次明确的 restore 后 keyboard-switch / software-keyboard smoke 记录；因此 restore
善后可判为 **bounded verified**，不能写成完整 post-restore functional acceptance。

## 6. Quality findings

### P2-DEVICE-01 — B 的 epoch-bound publish 合同未闭合

B 接受了 39 个 revision，但只对 36 个 revision 产生 epoch-bound publish；rev 16、25、33
只有 provisional visible，没有对应 epoch-bound publish。Evidence Contract §6.1/§7 要求
thread-affine 每个 accepted revision 都有合规 publish，因此 B 必须保持 `Partial`。
这不是把 provisional 反馈判错，而是说明 provisional→engine 的最终发布链在这三个 revision
缺少可验证终点。

有界建议：在任何生产接线或 Product Gate 讨论前，先明确 coalescing 的合同（补齐 epoch
publish，或把无 engine 结果显式编码为可验证的终态），再用新的 validator negative/positive
fixture 和同一真实设备日志复核；不得用“Human 未见卡顿”补齐缺失 revision。

### P2-DEVICE-02 — A sync arm 与当前 validator expectation 不匹配

A 的合同路径是 `sync`、responsive gate off，运行时合理地没有 ACCEPT/VISIBLE/PUBLISH；但
当前 validator 即使 `arm=.sync` 仍会无条件要求 accepted revisions 和 publish marker，故
A marker-only 只能得到 `publish-marker-missing`/`accept-revisions-not-complete`。这不是
A 运行失败，也不是应在 gate-off 路径强行增加响应式 marker，而是 evidence validator 的
arm-specific schema 尚未冻结。

有界建议：单独定义 sync expectation（只验证 T9SEG、session、geometry、commit、PATH/gate
状态），或明确 validator 的这些 reasons 仅为“not applicable”；保留 A 的真实 gate-off
事实，不通过静默补 marker 的方式追求 Complete。

### P2-DEVICE-03 — Run Header / Pair Manifest 字段不足以形成长期可重放包

设备 evidence 以单一 Markdown 记录了 source HEAD、dirty 描述、设备、flags、hash、raw log
hash 和 Human 表格，但没有独立的 Pair ID/Run ID、contract version、fixture digest、每臂
start/end window、完整 worktree fingerprint、Xcode/toolchain identity、Full Access observed
状态、artifact byte size、`validator-summary.json`/privacy-scan/restore 引用或仓库可读取的
附件字节。当前临时日志使本次复审能独立重放，但临时目录不是长期 immutable evidence。

有界建议：下一次保留 content-free `pair-manifest`、A/B run header、raw/marker-only digest、
validator summary、privacy scan 和 restore summary；原始用户内容仍留在受控临时区，不进仓库。

### P3-DEVICE-04 — privacy deny-list 将安全计数误判为敏感内容

`T9ResponsiveEvidenceValidator.containsPrivacySensitiveContent` 对任意
`candidates=` 直接判敏感，造成 A/B raw 都 Blocked；而日志只有 `candidates=12` 计数，没有
候选文本。它不构成当前隐私泄漏 P0/P1，但会使真实导出的默认判定不可用。

有界建议：只允许明确的非负计数 schema（例如 `candidatesCount=` 或严格整数值），对文本
字段和非整数值继续 fail-closed，并补 `candidates=12` 正例与 `candidates=今天天气` 负例；
未获得授权前不改生产逻辑，本 review 只记录问题。

### P3-DEVICE-05 — restore 缺少 post-restore keyboard smoke 证据

Cleanup plist、普通 Restore hash 和安装成功已被独立核对，但没有一条明确的恢复后软件键盘
切换/空列表 smoke 结果。它不否定 cleanup，也不构成设备状态破坏；只是 Restore Contract
的最后一项仍为 `unavailable`。

有界建议：未来 restore 后由 Human 做一次不输入内容的 keyboard-switch smoke，并在
`restore.json` 记录 observed/unavailable；不需要删除容器或重置 userdb。

## 7. 已证明、未证明与最终判定

### 已证明（bounded）

- A/B 都在同一真实 iPhone 13 Pro、39-key 手动 fixture 下保留 39 个连续 physical `T9SEG`；
  无 commit、漏键、重键、候选消失或键盘退出的 Human 观察；
- 评分口径正确使用 0=最卡、4=最流畅，A=3/4、B=4/4；
- B 显式 thread-affine PATH/READY、39 ACCEPT、42 VISIBLE 和 36 epoch-bound publish 的
  运行事实可由 content-free 日志重放；A sync PATH 与 gate-off 事实可核对；
- A/B 的 session identity、geometry digest、阶段时延和 processKey 慢调用统计与 evidence
  文档一致；B accept/UI 热路径明显短于 A；
- A/B/Restore 构建 hash、Release flags、构建成功、项目默认 flag-off、Restore 安装成功和
  cleanup 后 envelope/matrix/log 清理均有独立或可复核证据。

### 未证明（必须保留）

- B 三个 revision 的完整 epoch-bound publish 合同；
- A sync arm 的 validator Complete 语义；
- 完整 Pair/Run Header、durable attachment 和长期可重放的 privacy/validator summary；
- 多轮、多设备、iOS 26.0 RC、签名 App Store Release、jetsam/memory/queue、Product Gate、
  ADR 0025 Accept 或用户体验 SLO。

### 最终 Quality verdict

**Partial（not blocked as a device run; not complete as a contract evidence package）**。
P0/P1=0/0；P2=3（B 发布链、A validator arm 语义、证据包元数据）；P3=2（privacy 计数误报、
restore smoke）。Raw validator 的 `Blocked` 仅由已识别的 `candidates=12` false positive
触发，不能改写成真实隐私事故；marker-only 结果和 Human/device facts 仍只能支持 bounded
direction observation。

本 review 不关闭 P2-H-06、不宣布 P2-PERF-02 Complete、不接受 ADR 0025、不创建 Product
Gate、不授权 Release default-on。后续若继续，应先处理 P2-DEVICE-01～03 的合同/证据问题，
再决定是否值得另行授权生产接线或 Release 验证。

本角色在此停止；本文档为独立只读 Quality/Performance 复审记录。
