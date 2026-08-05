# T9-RESPONSIVE-PIPELINE-001 / P2-PERF-03 复现与反向顺序真机证据

状态：**四臂运行完成，等待独立 Architecture / Quality 复审**。这是一份
Product-authorized、content-free 的方向性性能证据，不是 ADR 0025 接受、Product
Gate、Release 默认开启或生产接线批准。

日期：2026-08-03（Asia/Shanghai）

## 边界与环境

| 字段 | 值 |
|---|---|
| Assignment | [`P2-PERF-03`](../assignments/t9-responsive-pipeline-001-p2-perf-03-replicated-ab-proposal.md) |
| Pair | `P2P03-AB`（A→B）与 `P2P03-BA`（B→A） |
| Fixture | `T9-RESP-PERF-39-V1`，39 actions；运行记录不保存原始拼音 |
| Runtime marker fixture | `T9RESP-R5P` |
| Host | 同一提醒事项 disposable list；软件键盘；Universe Keyboard 中文九宫格 |
| Human 操作 | 手动点击可见字母分组键；未点数字、Path、候选、空格、确认、删除、粘贴或坐标自动化 |
| Device | iPhone 13 Pro / `iPhone14,2`；UDID `00008110-000A08440198801E` |
| CoreDevice | `DE65EBE1-463E-5EB4-9694-F6DCBFC04028` |
| OS | iOS 27.0（`24A5390f`） |
| Source | HEAD `3585a540ba8389673acd49128d87040ac9619f27`；运行前 dirty fingerprint 见 Assignment |
| Toolchain | Xcode 27.0（27A5228h）；iPhoneOS SDK 27.0；Swift 6.4 |
| Full Access | 本次未重新观察，保持 `unavailable/unknown`；不从历史运行推断 |
| 评分方向 | `0 = 完全不卡`，`4 = 严重卡顿`；分数越低越好 |

四个运行均在同一设备、同一源快照和同一人工 fixture 下进行。A 使用
`T9_AUTO_ANCHOR_DEVICE_PREFLIGHT`、sync、dual gate `0/0`；B 额外使用
`T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`、thread-affine、dual gate `1/1` 和
`READY`。没有定义任何 `*_ENABLED` auto-anchor 条件，也没有修改生产逻辑或默认 gate。

## 四臂结果

| Arm | 顺序 | Run ID / token | 路径 | Geometry digest | Session | T9SEG total 中位/最大 ms | 人工评分 |
|---|---|---|---|---|---|---:|---:|
| A1 | A→B | `P2P03-AB-A1-20260803-001` / `S6A-4F6E59D5C301D8A7969C551CA12F6ABB` | sync `0/0` | `4062c233…bbf04` | `4384574040`，valid/stable | `14.4 / 242.3` | **2.5/4** |
| B1 | A→B | `P2P03-AB-B1-20260803-001` / `S6A-04E2D1B82EE1853B687E3E34198C5232` | thread-affine `1/1`, READY | `1711ceda…191ef` | `4386175000`，valid/stable | `0.4 / 0.8` | **1/4** |
| B2 | B→A | `P2P03-BA-B2-20260803-001` / `S6A-01EFFFC8FAC49CE6091A05196C14E9C7` | thread-affine `1/1`, READY | `bdb56292…f19d5d` | `4424090840`，valid/stable | `0.3 / 0.7` | **1/4** |
| A2 | B→A | `P2P03-BA-A2-20260803-001` / `S6A-E576AA10440DFA38964EA535AD89A1B1` | sync `0/0` | `7cbc0aa7…a490` | `4577961560`，valid/stable | `15.8 / 246.5` | **3/4** |

四臂人工报告均为：漏键 `no`、重键 `no`、候选消失 `no`、键盘退出 `no`。因此没有因输入完整性而停止或丢弃任何有效 arm。A→B 中 B 比 A 低 1.5 分；B→A 中 B 比 A 低 2 分。两种顺序方向一致，但这仍是单设备、两对样本，不能外推为用户 SLO。

本次没有独立可验证的逐键协议遵守 marker；因此每臂 `protocolAdherence` 固化为
`not-observed`，不把“手动软件键盘”报告推断为 canonical raw fixture 已被逐键证明。

矩阵映射固定为：`AB = [A1, B1]`，`BA = [B2, A2]`。B2 复用 B1 二进制、A2 复用 A1
二进制，复用关系及 hash 已在 summary JSON 的 `packageBinding` 中重复绑定。

### A sync arms

- A1/A2 各有 39 条有序 `T9SEG` action/event（`1..39`）、`committed=false`，各一条
  `T9ARM actions=38` checkpoint；当前 arm-specific validator 将两者判为 `complete`。
- A1 最大 `engine=241.3ms`、`rime=241.0ms`、`ui=7.5ms`；A2 最大
  `engine=245.4ms`、`rime=245.1ms`、`ui=8.4ms`。这说明 gate-off 的主观卡顿仍与
  同步 `process_key` 尖峰一致。
- A1/A2 均只有 `PATH path=sync dualGateRequested=0 dualGateActive=0`，没有响应式
  ACCEPT/PUBLISH 链；这符合 A 的 sync 合同，不应套用 B 的 ACCEPT/PUBLISH 要求。

### B thread-affine arms

- B1/B2 各有 `PATH path=thread-affine`、`READY`、39 条 ACCEPT、39 条 epoch=1
  PUBLISH，以及 39 条有序 T9SEG；当前 thread-affine validator 判为 `complete`。
- B1：T9SEG 最大 total/engine/ui 为 `0.8/0.4/0.6ms`；VISIBLE `42`（engine `35`、
  provisional `7`），PAINT `35`，最大 visible lag `125ms`。
- B2：T9SEG 最大 total/engine/ui 为 `0.7/0.2/0.6ms`；VISIBLE `42`（engine `35`、
  provisional `7`），PAINT `35`，最大 visible lag `128ms`。
- 两个 B arm 的 35 条 PAINT 都记录 `coalesced=0`；仍有 4 个 revision 没有 PAINT
  记录，也没有逐 revision 的缺失原因。因此 B 的即时 accept 证据完整，但 presentation
  coalescing 仍是残余 Partial，不能声称 UI 发布合同已完全闭合。

## 证据绑定与隐私

原始附件留在 Codex attachment 目录，仓库只记录字节数、SHA-256、按唯一 token 截取的
content-free marker 子集摘要；不保存 raw pinyin、候选、宿主文本、截图或 UI hierarchy。
B2/A2 的原始导出包含此前 arm 的历史 token，这是“不得清空诊断日志”的预期；解析时只取
当前 arm token。原始导出中的 `SLOW RIME ... candidates=12` 会触发旧版隐私 deny-list
对字段名的保守拦截，故仓库只绑定当前 token 的 marker-only 子集，并记录其 validator
隐私结果为 pass；这不等于宣称原始附件通过完整隐私 allow-list。

| Arm | 原始附件（lines / bytes / SHA-256） | 当前 token 子集（lines / bytes / SHA-256） | validator |
|---|---|---|---|
| A1 | `d188d784-790a-4d49-b3c0-f7faa2e4fb47` / 170 / 36675 / `f44d4e247f1942280283eb6c9ad79432f799313a4a1857ac38feb4023f0d9a38` | 44 / 15056 / `b3577c568fa4640d24e24ade231d94b67656909d3d37fa2721ca0b813158baab` | `complete`；privacy false |
| B1 | `2cb67c7f-4507-40c8-889a-d795500c82cd` / 208 / 39560 / `ed0d47b52afdb2c783c8503e86b02f417d3747c865c15c36a2cba8bea792796e` | 200 / 38444 / `d015b7cd6a0b67134e31300375470d24569ebab104c15c36a2cba8bea792796e` | `complete`；privacy false |
| B2 | `5bded313-f9cc-41e7-bc58-7b5c3ab710dc` / 449 / 81936 / `dd9a6b96c694d749fd299006b8f073ad17b56ad9abc6c4b78e2fee956d598345` | 200 / 38442 / `70c06ed719c923c6dfe26749949a250a310fec11578edb5a8a60b4830119f305` | `complete`；privacy false |
| A2 | `6e8c48bf-e17d-4a22-9b1f-825f55005bef` / 499 / 96298 / `f3c6ead78a0e4a1695cb06ad17fea9d0cfb3866861343445dcd3064b6c6eae10` | 44 / 15056 / `223f08a8f00a612679f4a6859ace625f6a369687bf7090eb01625bb6a26d2fb` | `complete`；privacy false |

### Geometry

四臂都报告相同的 portrait screen `390×844`、scale `3.000`、keyboard envelope
`82.667,84.000,220.333,705.000` 和 8 个 slot rectangles；每个 arm 的 prepared 与
execution tokenized digest 相同。由于运行时 digest 的输入包含 opaque token，四个
tokenized digest 必然不同。按固定字段去除 token 后，事后派生的 tokenless shape digest 为
`114c78b9a5b97896b1ec3f50ec09387017a01b05b2e97200a2a2ac37795ed4d0`；这是 post-hoc
derived metadata，不是运行时单独写出的 marker，所以仍保留“运行前冻结 tokenless
geometry digest”这一合同债务。

## 无效尝试与恢复

A1 在第一次安装后没有先由主 App 准备 token，附件
`aff40276-035d-4590-b4a1-1a113f522e12`（499 lines / 68431 bytes，SHA-256
`723b2f6c3d8b7fa5ebe268b3c5e762af6a2bb31a9061b617a7243e339e071f21`）只有
`run=invalid`；该尝试明确记为 `invalid-run-token`，没有混入 A1 统计。随后按同一
fixture 重跑并取得上表有效 A1。

四个 consumed envelope 均按 token 精确 cleanup，最后执行
`T9_S6A_FINALIZE_MATRIX=1`；没有清空 `rime_diag_log`、App Group、userdb 或提醒事项。
普通 Release（无 preflight 编译条件）随后安装成功，安装 database sequence `3800`：

| 包 | App executable SHA-256 | Keyboard.appex executable SHA-256 | 安装序列 |
|---|---|---|---:|
| A diagnostic | `da19ce2ffbb4d6abbc95c806001fa412b3826f1e75ff4a919f0362a7b74f9be3` | `5a9a47f8c40313c23119e5397140cb382a05b16b117a24d6c80794242b209542` | 3776（A1）；3792（A2） |
| B diagnostic | `05d6b706be06c09b7460c64c0a1c4ff028ae1535fc85477d8d76f9beb1114b51` | `009e426b41cfccbc067d8b9d69a69695306c8a853f1ae67f2ff8a725525bb787` | 3784（B1/B2 复用） |
| ordinary Release restore | `3b518196d8e89f47288b102c05494904f1576712de112ab54e8f4ed077e3ee7c` | `c7c319039c50e8f92cbcb121d5fa0b8efb5682d080d94b47cac74361cd804df8` | **3800** |

Human 已确认恢复后键盘切换冒烟完成：键盘出现并保持，未输入文字、未观察到退出。

## 结论与停止点

已证明：在同一真实 iPhone 13 Pro、同一人工 39-action fixture、A→B 与 B→A 两种顺序
下，thread-affine B 的即时 T9SEG 热路径均低于 1ms，而 sync A 出现约 242–247ms 的
RIME 尖峰；两种顺序的 Human 主观评分方向一致，B 的分数更低。

未证明：真实 librime 在更长时间/更深队列下的内存与 jetsam、Full Access/宿主 provenance、
逐 revision PAINT 缺失原因、运行时 tokenless geometry 冻结、多设备/iOS 版本复现、iOS
26.0 Release RC、Product Gate、ADR 0025 Accepted 或生产默认接线。

因此本记录交给独立 Architecture 与 Quality 复审；复审完成后停止，不自行宣布 Spike
Pass、生产可用或 Release 许可。

## 独立复审收口

| 角色 | Verdict | P0 / P1 / P2 / P3 | 关键残余 |
|---|---|---:|---|
| Architecture | `Pass with conditions`（bounded replicated evidence-only） | `0 / 0 / 4 / 2` | 顺序/主观非因果、Full Access/host、post-hoc tokenless geometry、PAINT 缺失原因、restore/raw 范围 |
| Quality / Performance | 有界条件通过，整体 `Partial` | `0 / 0 / 4 / 3` | `protocolAdherence` 未观察、Full Access/host/time/run-header、当前 token 子集 privacy、PAINT reason、validator provenance 与小样本 |

复审文件：[`Architecture review`](../assignments/t9-responsive-pipeline-001-p2-perf-03-architecture-review.md)、
[`Quality review`](../assignments/t9-responsive-pipeline-001-p2-perf-03-quality-review.md)。两份
复审都建议至多另行建立 default-off、显式 kill-switch 的 production-shaped canary 设计，
不直接接线、不接受 ADR 0025、不打开 Product Gate。

## 回归验证

本次没有修改生产代码或测试逻辑；在独立临时 scratch 下复跑现有验证：

- `T9ResponsiveEvidenceValidatorTests`：**28/0**；
- `KeyboardCore` 全量：**901/0**；
- 证据 JSON：`jq empty` 通过；相关文档 `git diff --check` 通过。

这些结果只证明现有 validator/KeyboardCore 回归没有退化，不改变四臂真机证据的
方向性和未闭合残余。
