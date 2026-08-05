# CANARY-001 独立 Quality 设计复审

| 字段 | 结论 |
|---|---|
| 复审角色 | Quality, Performance & Release Maintainer `/root/canary_quality_review`（独立、只读） |
| 日期 | 2026-08-03 Asia/Shanghai |
| 对象 | CANARY-001 Assignment、Architecture/Quality freeze、live-session API inventory |
| Verdict | **Pass for design I-Ready** |
| P0 / P1 / P2 / P3 | **0 / 0 / 0 / 0** |
| 边界 | 不是实现授权、E-Ready、运行授权、Product Gate 或 Release 结论 |

## 结论

- I-Ready 与 E-Ready 已分层：当前 snapshot、精确 allowlist 和 executable
  design/test mappings 属 I-Ready；final diff、artifact hashes、独立 re-audit
  和 immutable command manifest 属 E-Ready。
- 所有 `RimeEngine` entries 与 ObjC public entries 已选择唯一 disposition；
  typo sidecar 与 reversible auto-anchor 在 canary v1 fail-closed。
- 每个 ACCEPT 恰一 terminal；每个 PUBLISH 恰一 visibility disposition 与
  PAINT terminal；canonical VISIBLE 数量和 coalesced/fenced pairing 唯一。
- transition key/order、process-death terminal、ordinary Release、pre-start
  kill、active kill 和 Main-App overlap provenance 均有 fail-closed 分类。
- 精确 production/test/document allowlist 已冻结，额外路径必须重新双审。

## 证据边界

本结论只说明设计阶段满足 I-Ready。实现产物、build、Simulator、设备、真实
RIME runtime、restore 与 performance 数据均未产生；任何运行仍需 E-Ready 和
对应阶段的显式激活。Physical-device phase 继续关闭。

## 停止声明

Quality 复审没有授权写代码、构建、测试、安装、日志采集、默认 gate 变化、
生产接线或真机操作。

## Implementation static review addendum — 2026-08-03

| 字段 | 结论 |
|---|---|
| 对象 | Product Lead 已激活的 frozen-allowlist implementation source |
| Verdict | **Pass for static implementation review** |
| P0 / P1 / P2 / P3 | **0 / 0 / 0 / 0** |
| 动态证据 | **NotRun** |

五轮独立只读收敛后，visibility teardown、bounded PAINT acknowledgement、
pending/finalize/preterminate/ACK、terminal 与 abandonment 的 frozen identity
均无剩余静态阻断项。新增测试仅为 source evidence，尚未执行。因此本结论
不代表 build/test 通过，不进入 `E-Ready`，也不授权 Simulator、安装、日志、
真机、默认 gate、生产接线或 Product Gate。

## Bounded build/test evidence review addendum — 2026-08-04

| 字段 | 结论 |
|---|---|
| 对象 | v6 immutable manifest、冻结 source/diff hashes、C02R6–C10V6 result record 与 retained xcresults |
| Verdict | **Results verified; QEF-01 formal closure blocked** |
| P0 / P1 / P2 / P3 | **0 / 1 / 1 / 0 at review time** |
| 边界 | Simulator diagnostic evidence only；不是设备、Product Gate、Release 或 ADR 0025 acceptance |

独立核验确认冻结 source/diff/manifest hashes 匹配；C08 为 139 success / 0
issue，C09 为 1 success / 0 issue，C10 为 34 success / 20 skipped / 0 issue。
C10 的 20 个 skip 中，19 个缺少 RIME/Lua/spike/userdb 环境，1 个缺少
immutable 40-character S4 commit；result record 已据此纠正原 P2 分类。

剩余 P1 无法事后修复：v6 manifest 未在运行前记录 destination-discovery
output hash 与逐命令 expected artifacts；xcresult 仅有临时路径，未冻结
digest/archive identity；C02R6–C07V6 也没有 retained command-output artifact
hash。因此本轮可保留为可信 bounded diagnostic result，但不能正式关闭
QEF-01。若要正式关闭，必须由 Product Lead 另行授权新 immutable manifest
与重跑；本复审不提供该授权。

## QEF-01 run004 post-run evidence review addendum — 2026-08-04

| 字段 | 结论 |
|---|---|
| 对象 | run004 C02V9-C11V9、P01V9-P05V9 与冻结身份链 |
| Verdict | **Automated/Simulator Pass；overall Partial** |
| P0 / P1 / P2 / P3 | **0 / 0 / 3 / 0** |
| 边界 | 不是物理设备、Product Gate、Release 或 ADR 0025 acceptance |

独立复核确认六组测试分别为 906/0、9/0、18/0、139/0、1/0，以及
54 total / 34 pass / 20 skip / 0 fail；十份收据和 P01-P05 均绑定同一
run004 manifest、binding、approval、expected 与 tool。20 个 skip 全部有
分类且 `unknownSkipped=0`。普通 Simulator 包恢复的构建/安装 App 与
Extension 哈希一致，internal condition 缺失；发布扫描与 inventory 通过。

三个 P2 残余为：20 个真实 fixture/provenance 行为仍 `NotObserved`；P02
没有启动 Main App，不能外推为完整 runtime/lifecycle restore；物理设备、
Full Access/host、手工键盘呈现、生产形态 RIME、性能 SLO 均未运行。证据可
交 Product Lead 决定 stop/retain、补 fixture，或用新身份单独激活真机阶段。

## DEVICE-001 physical-device evidence review addendum — 2026-08-05

| 字段 | 结论 |
|---|---|
| 复审角色 | Quality, Performance & Release Maintainer `/root/canary_quality_review`（独立、只读） |
| 日期 | 2026-08-05 Asia/Shanghai |
| 对象 | DEVICE-001 pair-002 四臂（A/B/K/O）真机证据、最终 run header、machine summary、operator sheet 与全部 raw receipts |
| Verdict | **Pass with conditions** |
| P0 / P1 / P2 / P3 | **0 / 0 / 5 / 3** |
| 边界 | 不是 ADR 0025 Accept、Product Gate、Release default-on、生产接线或性能 SLO |

## 结论

### 独立性声明

本复审为独立只读交叉核对：已验证了全部 10 份 raw receipts、4 份仓库证据文档、
5 份实现代码与之前的 Quality review addendum。本复审不盲信现有文档结论，每个
数字/断言均追溯 raw receipt 对应字段。未发现证据伪造、隐私违规或 gate 状态
误述。

### 核心核实结论

**A/B 聚合交叉核对（通过，完全一致）。** A 臂 stallScore 2.5 与
`A-pair002-human-report.json`（`subjectiveStallScore: 2.5`）及
`A-pair002-post-input-receipt.json`（`stallScore: 2.5`）一致。A 的
total_ms max 229.9、rime_ms max 228.6 与 raw receipt 中 slowSegActions
逐条匹配。B 臂 stallScore 0 与 Human 报告一致；accept_ms 中位 0.3、
rime_bridge_ms max 242.5、paint_lagMs_engine max 208、provisional_lagMs
50-52 全部与 raw receipt 字段逐项一致。coalescing [24,25,26] 合并到
paintRev 26（lag 22ms）、[32,33] 合并到 paintRev 33（lag 96ms）与 raw
receipt 中 `coalescingEvents` 精确匹配。

**K 臂 kill 断言（通过，混杂因素诚实披露）。** K-kill-launch.json 证明
`outcome=success`。ACCEPT 缺席与 decision=baseline kill 后扩展启动由
operator sheet 和 final run header `KDeviceAcceptance` 共同记录。混杂因素
（`expiryState=expired`+`kill=1` 共同导致 fail-closed 到 baseline）在各证据
层均诚实标注——证据文档、summary JSON 的 `confound` 字段、run header 的
`confoundNote` 一致。`phase=kill decision=kill` 断言被正确描述为独立于
expiry 的 kill 写入/读回证明——无过度声称 kill 单独因果。

**O 恢复证据（通过，有 minor gap）。** O-install.json 证明
databaseSequence 3960（晚于 B 的 3952）、outcome=success。安装后
App/Extension hash（65d90433... / d911e011...）与冻结 O 一致。但"已安装
普通 Release 二进制字符串扫描 absent"的声称在 raw receipts 中仅有 operator
sheet 中的一句话支持——`O-install.json` 是 devicectl 安装输出，不含字符串
扫描证据。构建时普通 Release 的二进制验证与设备时安装后扫描之间缺少机器
可读桥接。Human O smoke 由 operator sheet 记录，合理可接受。

**隐私合规（通过，坚如磐石）。** `docs/evidence/` 下 4 份文件仅含 content-free
marker、聚合、hash、status 与 Human 主观报告。无 raw 输入、拼音、候选、
宿主文本、截图、UI hierarchy、userdb。raw paste 文件（`*-human-paste.txt`）
经行级检查全部为 T9 诊断 marker 行（60/60 行），被 `T9DevicePreflightEvidenceLineFilter`
过滤。raw 目录 `/evidence/` 在 `.gitignore` 第 56 行确认 gitignored。代码层
双重防护（filter + `T9ResponsiveEvidenceValidator.containsPrivacySensitiveContent`）
提供防御纵深。无隐私违规。

**run004 与设备层区分（明确，但 NotClaimed 列表不完整）。** 设备证据文档的
"未证明"列表（ADR 0025 Accept 等 7 项）与各 Assignment 的 non-goals 一致。
但 run004 的 3 个 P2 残余——20 个 `NotObserved` fixture/provenance 行为、
P02 Main App launch smoke——未出现在设备证据的 NotClaimed 列表中。设备层
没有声称覆盖这些（也未悄悄关闭），但缺少显式免责声明。详见残余 P2-01、P2-02。

### 逐收据交叉核对摘要

| 文档声称 | raw receipt 字段 | 结论 |
|---|---|---|
| A stallScore 2.5 | `A-pair002-human-report.json` `subjectiveStallScore=2.5`；`A-pair002-post-input-receipt.json` `stallScore=2.5` | 一致 |
| A total_ms max 229.9 / rime_ms max 228.6 | `A-pair002-post-input-receipt.json` `aggregates.total_ms.max=229.9`；`rime_ms.max=228.6` | 一致 |
| A slow actions: 1,6,9,19,24,29,32 | `slowSegActions` 数组 7 个元素，action 值逐条匹配 | 一致 |
| B stallScore 0 | `B-pair002-post-input-receipt.json` `humanCrossCheck.stallScore=0` | 一致 |
| B accept_ms median 0.3 | `aggregates.accept_ms.median=0.3` | 一致 |
| B rime_bridge_ms max 242.5 | `aggregates.rime_bridge_ms.max=242.5` | 一致 |
| B coalescing [24,25,26]→26 lag 22 | `coalescingEvents[0]: batchRevs=[24,25,26], paintRev=26, lagMs=22` | 一致 |
| B coalescing [32,33]→33 lag 96 | `coalescingEvents[1]: batchRevs=[32,33], paintRev=33, lagMs=96` | 一致 |
| B provisional_lagMs 50–52 | `provisional_lagMs.min=50, max=52` | 一致 |
| K kill=1 decision=kill status=success | `K-kill-launch.json` `outcome=success`；operator sheet attestation | 机器 launch 已验证；marker 内容为 Human-mediated |
| K 扩展 decision=baseline | final run header `KDeviceAcceptance.extensionStartupAfterKill`；operator sheet 佐证 | 一致 |
| O dbSeq 3960 | `O-install.json` `databaseSequenceNumber=3960` | 一致 |
| O hash 匹配 | summary/run header artifact hashes 与冻结 O 一致；`O-install.json` 含 container UUID | hash 一致；安装目标身份已验证 |

## 残余列表

### P2（应修复）

| ID | 内容 |
|---|---|
| P2-01 | run004 的 20 个 `NotObserved` fixture/provenance 行为未在 DEVICE-001 证据文档的 NotClaimed 列表中显式列出。设备层未声称覆盖它们，但缺少显式免责声明，可能会被误解为设备层已覆盖。 |
| P2-02 | P02 Main App launch smoke（非 canary 控制入口）未在 DEVICE-001 NotClaimed 中列出。O 恢复 smoke 仅覆盖键盘输入，不覆盖 Main App 前台生命周期。 |
| P2-03 | O 已安装二进制字符串扫描声称 `absent in installed O product`（evidence .md + run header），但 raw receipts 中仅有 operator 一句 attestation，O-install.json 为 devicectl 安装输出不含扫描证据。安装后身份匹配依赖构建时普通 Release 验证与 hash 一致性推理，缺少安装后独立机器扫描。 |
| P2-04 | Full Access 重新确认步骤在 run header 中要求 `reconfirm immediately before Human A input`，但 operator-sheet-pair-002.md 中未记录该重新确认。Full Access ON 状态可靠（非首次使用），但协议要求的重新确认步骤缺少显式 attestation。 |
| P2-05 | 单对 A/B 不是 benchmark 的声明不充分。证据结论中的"直接印证 R5P 的目标"措辞可能被误读为超过单对手工证据（含 cadence confound）的强度。应在证据文档结论中显式声明"单对 A/B（n=1）+ Human cadence confound，不是 benchmark，不构成 SLO"。 |

### P3（小改进）

| ID | 内容 |
|---|---|
| P3-01 | K 臂 `CANARY_CONFIG actor=app phase=kill kill=1 decision=kill status=success` 证据链为 Human-mediated：kill launch（机器验证）→ kill 写入 + 日志 → evidence view 显示（机器验证 launch）→ Human 从设备屏幕读取 marker → 记录。raw receipts 无直接机器解析的 CANARY_CONFIG 文本。可接受（物理设备限制），但应注明。 |
| P3-02 | 最终 run header `runtimeEnvelope.powerThermal` 仍为占位符 `reconfirm at Human A start`，未解析为实际观测或显式 `NotObserved`。虽然不是必须字段，但占位符残留影响 provenance 完整性表象。 |
| P3-03 | B accept_ms 范围（0.1–0.9ms）在证据文档中仅提及中位数（0.3ms），max 被遗漏；A 臂 `t9arm actions=38` 与 `segCount=39` 的偏差（arm checkpoint vs segment count）未在证据文档中解释。 |

## NotClaimed（显式声明）

以下事项不在 DEVICE-001 证据范围内，且设备层证据不声称证明：

- ADR 0025 Accept
- Product Gate / Release default-on / 生产接线
- Full Access OFF 行为
- 长期内存 / jetsam / 多设备 / iOS 版本复现
- App Group / userdb 清理（Assignment 明确不执行）
- run004 的 20 个 `NotObserved` fixture/provenance 行为
- Main App 前台 lifecycle/launch smoke（非 canary 控制入口）
- 单对 A/B 作为 benchmark 或性能 SLO

## 正面确认

- **K 混杂因素诚实披露**是本证据包的楷模：证据 .md、summary JSON（`confound` 字段）、
  run header（`confoundNote`）三层一致，将 `kill=1` 与 `expiryState=expired`
  共同作用与独立的 `phase=kill decision=kill` 断言正确分离。
- **隐私屏障**严密：`docs/evidence/` 零隐私内容，raw 目录 gitignored，代码层双重防护。
- **算术一致性**优秀：所有聚合数值在 raw receipt 与证据文档间完全一致，无四舍五入偏差、无捏造。

## 修复收口 addendum — 2026-08-05

Quality 复审后，证据文档与机器收据已按残余修复，独立 Quality 复审者复核如下：

### 已关闭（证据文档/收据补强）

- **P2-01 / P2-02（NotClaimed 补全）**：证据文档"未证明"段与 summary JSON
  `notClaimed` 列表已补入：run004 自动化/Simulator 层 20 个 `NotObserved`
  fixture/provenance 行为、Main App 前台 lifecycle/launch smoke、单对 A/B 作为
  benchmark/SLO。三层证据（.md / summary / run header）现在一致显式免责。
- **P2-03（O 扫描机器收据）**：新增隔离收据
  `evidence/CANARY-001-DEVICE-001/raw/O-binary-scan-2026-08-05.json`
  ——O 产物 4 个 marker 全部 0 hits（sha `65d90433…` 与安装身份绑定），B 对照产物
  6 hits。证据文档已引用并如实说明这是**构建产物扫描**（经冻结 hash 绑定安装身份），
  非设备二进制直接读出；"安装后独立机器扫描"仍保留为残余。
- **P2-05（样本强度声明）**：证据文档结论新增"单对 A/B（n=1）+ Human cadence
  confound，方向性证据、非 benchmark、非 SLO"显式段落。
- **P3-03（B 聚合补全）**：`accept_ms` 范围 `0.1–0.9ms` 已补入；`t9arm actions=38`
  vs `segCount=39` 的口径差异已解释（checkpoint 行 vs segment 计数，`actions_1_to_39`
  与 `rawLen 1..39` 确认无丢键）。

### 保持开放（如实记录，未伪造补证）

- **P2-04（Full Access 重新确认）**：run header 已记录 operator 确认 Full Access
  全程保持 ON，但原始操作表缺独立的逐臂 toggle attestation 行；协议要求的"重新确认"
  无逐次机器记录，属过程记录缺口。
- **P3-01（K marker Human-mediated）**：`decision=kill` marker 为人工转录；kill
  launch 机器验证，marker 文本非机器解析。证据文档已如实标注。
- **P3-02（powerThermal）**：run header 已从占位符解析为"观测正常、无节流指示"，
  但这是 operator 观测而非独立传感器记录。

### 结论

P2-01/P2-02/P2-03/P2-05 与 P3-03 已在文档/收据层关闭；P2-04、P3-01、P3-02
保持开放并如实披露。整体 Verdict 维持 **Pass with conditions**，残余不影响
DEVICE-001 方向性证据的可用性，但 P2-04 等过程缺口在后续更强证据阶段需补。

## 停止声明

独立 Quality 复审未授权写代码、构建、安装、默认 gate 变更、生产接线、ADR 0025
Accept、Product Gate、Release 许可。本 addendum 的 `Pass with conditions`
仅针对 DEVICE-001 pair-002 物理设备证据的质量、一致性与隐私合规。P2 残余
修复前，该证据不应被任何 gate decision 单独依赖。
