# Architecture Review: SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001

## 审查身份与边界

| Field | Value |
|---|---|
| Reviewer | independent Architecture reviewer runtime；logical lane `RTRD-02/document-architecture` |
| Date / timezone | `2026-09-11 Asia/Shanghai` |
| Worktree / branch | `/private/tmp/universe-keyboard-rtrd-02-accept` / `docs/rtrd-02-accept` |
| Reviewed SHA | `ab592b99e05c2f6a6d8f62e3fb334ef21deaf476`（`HEAD^{tree}=1d2ed211eaa6ec5678d2bb985c171813f0a7ebda`） |
| Baseline | `7caec797b0bb39e4aec781c2a79f411478cab453` (`origin/main`，PR #112 merge) |
| Review mode | 只读审查；仅允许写入本文件 |

独立性：本 runtime 未撰写或修改 Assignment、Authorization、Product Decision、
preflight、台账、Dashboard、ACTIVE_WORK 或本接受包；只检查最终已提交树并写入
本独立审查。本文件不是 D-01 receipt、不是 hosted CI、不是 merge 权威、不是
Product Gate。

审查范围限于 `7caec797...ab592b99` 的 **RTRD-02 同字段缺口接受 / M-02 Close**：

- 关闭 [`SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001`](../assignments/scheme-delivery-runtime-route-elapsed-001.md)
- 消费 [`AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001`](../authorizations/AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001.md)
- [`SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001`](../assignments/scheme-delivery-runtime-route-device-001.md)
  残差 `RTRD-02` → `accept`；DEVICE-001 **保持 Active**
- 从 Active Work 去掉 ELAPSED-001（cap 仍 ≤10；现 8 行）
- 无 Product Gate；无 Swift；无性能快/慢结论

明确不审查、不授权：DEVICE-001 Close、把 `RTRD-01` 改写成 `accept`、新 Swift
elapsed producer、操作员卸载轮、SUG-08、把 2026-09-09 真机证据写成已含
UUID/phase/elapsed **数值**、TestFlight、Release、ADR Accept、Kit `required`。

## 冻结输入

审查绑定下列工作树内容。任一输入、reviewer 绑定、采纳范围或项目边界变化，
本结论失效，需对新 SHA 重审。本审查文件本身不在下列 hash 内。

| Input | SHA-256 |
|---|---|
| [`ELAPSED-001` Assignment](../assignments/scheme-delivery-runtime-route-elapsed-001.md) | `66178226f1e0afa6ed8a3193774faf4ded0f12424760cc3b6ad7d26729006ba1` |
| [`AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001`](../authorizations/AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001.md) | `e9b9d866ed83143b372b4cc88f5dfa57426a31bc659741d36cb18bb9dbd2e2fa` |
| [`ELAPSED-001` Product Decision](../product-decisions/SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001-authorization.md) | `8c580f56071b18ad40e65705b3d95609dc53667e1ca50cfd17d677aa4d17ea8f` |
| [`elapsed preflight`](../evidence/scheme-delivery-runtime-route-elapsed-001-preflight-2026-09-11.md) | `d396728e7f0e3aac7c451302c4c587c14452e7885069287811d6aa83afdb730d` |
| [`DEVICE-001` Assignment](../assignments/scheme-delivery-runtime-route-device-001.md) | `f6cceafed4f3f55dc057a0e37cd98f8f67f002fbdb1d346b9ebec18472ede16c` |
| [`INTEGRATION-001` Assignment](../assignments/scheme-delivery-runtime-route-integration-001.md) | `09adf187ba4f1fcc91ad02ecf38c21b856e887c058266d57f4c646f337c2045e` |
| [`SOURCE-STATE-001` Assignment](../assignments/scheme-delivery-source-state-001.md) | `5031240e1c781773f9fe1321719aeb26349093798b7f0924b689514f607614fe` |
| [`GLANCE-001` Assignment](../assignments/kos-sug-obs-glance-001.md) | `bb47d5932ef990f0ba86960ba66f2455d2da2beb56eedae92a97be3105c1d845` |
| [`ACTIVE_WORK.md`](../ACTIVE_WORK.md) | `4bd81299091b4add457797afda2e093ec90edc6ed40a6c1d2e721dd93a89c54a` |
| [`ENGINEERING_DASHBOARD.md`](../ENGINEERING_DASHBOARD.md) | `ee6995a341eed838373955e0721c970def520004fdc026ac277d4233c3ed1685` |
| [`disposition ledger`](../kos/kos-improvement-suggestions-scheme-delivery-2026-09-09-disposition-ledger.md) | `ca4504f01661c8a751464abaa17b2ed73245e71c96f7f9ef7fae90fcb06edf5f` |
| [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md) | `59fc94f12b61ee303c4dda644c41eeae3b3fc3c63d9ea5b033e766ccc3b9fc5d` |
| [`kos-2.1-operational-maturity.md`](../kos/kos-2.1-operational-maturity.md) | `526094cc345c7bb4552750e0bd31c1fd349eb38d4be24ff7225feff63f30ecb1` |
| [`KNOWLEDGE_INDEX.md`](../KNOWLEDGE_INDEX.md) | `e1d8e4bbc8aac41e084beb9b88aae1b1825a9f5a4be7a585f300b27896f5cd94` |
| [`human-operated evidence profile`](../kos/universe-keyboard-human-operated-evidence-profile.md) | `b7588eeaec64e568945b74047828e455b68aa52f39877320bc813ce3135dd0ec` |
| [`UPGRADE_STATUS.md`](../kos/UPGRADE_STATUS.md) | `29f438145319127811d259dd692f24cbaf0c7b41666df799e8a1972cb71ef83a` |
| [`.kos/project.json`](../../.kos/project.json) | `890e590eb4963a9f028581135eab3b3f01484f05bb8bd614a3c944318ff3615f` |
| [`SchemaManager+Installation.swift`](../../Universe%20Keyboard/Services/SchemaManager+Installation.swift) | `d6e962ea97c4e21dcfc37d2da4577d43f54304a3dd9b4c020e56345fda1d0fb5` |
| [`DiagnosticEvent.swift`](../../Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift) | `5575d7a360fdb207d310a5b08d350c3bfe85d387076612904e5ae61b64f1bc4c` |
| [`DiagnosticsLogSource.swift`](../../Universe%20Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift) | `4fa4a32e40be357a840f87b2c1e4695d0eaf6ae371a11eddc665c5498c151ff3` |

`git diff --check 7caec797...ab592b99` 通过。范围内相对链接可解析（无缺失目标；
无 `path:nn` Markdown 行链接）。相对 baseline 无 `.swift`、无 workflow/script、
无隐私政策、无生产日志 schema 变更（Swift 仅为只读审计对象，hash 与 glance
包冻结值相同）。审查时工作树相对 `HEAD` 干净（写入本文件前）。

## Architecture 核对

### 1. ELAPSED-001 Closed；next=none；不关闭 DEVICE-001

成立。

- Lifecycle = `Closed`；Next = none for this slice
  （[`ELAPSED-001:9-12`](../assignments/scheme-delivery-runtime-route-elapsed-001.md#L9)）。
- Non-claims：无性能 pass/fail、无 Product Gate / TestFlight / Release、无
  SUG-08、无 Swift、**不关闭 DEVICE-001**
  （[`ELAPSED-001:11`](../assignments/scheme-delivery-runtime-route-elapsed-001.md#L11)）。
- Exit：preflight 普通 Luna 臂 `unreadable` **且** Human 接受缺口
  `2026-09-11`；无发明阈值
  （[`ELAPSED-001:90-91`](../assignments/scheme-delivery-runtime-route-elapsed-001.md#L90)）。
- PD Status：缺口已接受；Assignment Closed；Next none
  （[`PD:7-10`](../product-decisions/SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001-authorization.md#L7)）。
- Dashboard 镜像 Closed + AUTH consumed + DEVICE-001 not Closed + next none
  （[`ENGINEERING_DASHBOARD.md:61-66`](../ENGINEERING_DASHBOARD.md#L61)）。

失败情景（未发生）：若把 ELAPSED Close 写成 DEVICE-001 Closed。当前没有。

### 2. AUTH consumed；不可复用于 Swift / SUG-08 / Product Gate / Release

成立。

`kos-record` JSON 可解析。顶层 `status` 与
`authorization.consumption_state` **均为** `consumed`。
action 仍是 `start_rtrd_02_elapsed_comparison_preflight`，target 仍是
`SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001`。
exclusions 仍含 `operator_uninstall_round`、`implement_sug_08`、
`raw_directory_read`、`new_swift_elapsed_producer`、`required_mode`、
`release`、`testflight`、`product_gate`、`adr_accept`。

Markdown Current Status：consumed by Closed Assignment after Human accepted
the same-field gap；**Not reusable** for Swift / SUG-08 / Product Gate /
Release
（[`AUTH:7-8`](../authorizations/AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001.md#L7)）。

失败情景（未发生）：若 `status`/`consumption_state` 不一致，或把已消费
receipt 写成仍可执行 Swift / 卸载轮 / Product Gate。当前 JSON 与散文一致。

### 3. M-03：`RTRD-02` `accept` 有效；DEVICE-001 仍 Active；`RTRD-01` 未改写成 `accept`

成立（残差 **所有者** 记录）。

M-03 要求 Pass-with-conditions 残差具备 ID / Owner / Disposition
（`fix` | `accept` | `tech_debt:<ID>`）/ Pointer。`accept` 允许 Close，只要
关闭时仍列出该残差。

| 字段 | DEVICE-001 记录 |
|---|---|
| Residual ID | `RTRD-02` |
| Owner | Main App UI / Diagnostics |
| Disposition | **`accept`** |
| Pointer | Closed [`ELAPSED-001`](../assignments/scheme-delivery-runtime-route-elapsed-001.md) + [preflight](../evidence/scheme-delivery-runtime-route-elapsed-001-preflight-2026-09-11.md) |

DEVICE-001 Lifecycle 仍为 **Active**
（[`DEVICE-001:9`](../assignments/scheme-delivery-runtime-route-device-001.md#L9)）。
Current Status Residuals：`RTRD-01` 仍 `fix`（实现+glance）；`RTRD-02`
`accept`（[`DEVICE-001:13`](../assignments/scheme-delivery-runtime-route-device-001.md#L13)）。
Follow-up 正文与 History 同向：Human 接受同字段缺口；本 Assignment 保持
Active；Product Gate 未授权
（[`DEVICE-001:50-52`](../assignments/scheme-delivery-runtime-route-device-001.md#L50)、
[`#L73`](../assignments/scheme-delivery-runtime-route-device-001.md#L73)）。
Non-claims：不声称 fallback 与普通 Luna 耗时已可比
（[`DEVICE-001:11`](../assignments/scheme-delivery-runtime-route-device-001.md#L11)）。

`accept` 的实质依据仍是生产者边界，不是静默改写 Quality 早先的 `fix`：

- 前一轮独立 Architecture 已确认 `runtime_route.elapsed_ms` 是卸载开始后的
  单调时间；`recordActiveUninstallRoutePhase` 仅从 `performSchemaUninstall`
  调用；普通 `activateSchema` / Luna deploy 不写该 event。本 SHA 相对
  baseline **无 Swift diff**，上述 hash 与 glance 包冻结值相同。
- Preflight：fallback 臂 `readable`；普通 Luna 同字段同 event code
  `unreadable`；同一孤立 deploy duration 定义 `unreadable`；无 `not-checked`
  （[`elapsed preflight:17-25`](../evidence/scheme-delivery-runtime-route-elapsed-001-preflight-2026-09-11.md#L17)）。
- SUG-07：`unreadable` 时不得为追逐字段要求操作员卸载
  （[`profile:127-129`](../kos/universe-keyboard-human-operated-evidence-profile.md#L127)）。
- Product Lead / Human 明确接受缺口（PD Decision；frontier「接受 RTRD-02
  缺口」；ELAPSED History）。这是 `accept` 的授权，不是 Quality 自行改写。

ELAPSED Close 时 Residuals 仍列出 DEVICE-001 `RTRD-02` disposition `accept`
（[`ELAPSED-001:13`](../assignments/scheme-delivery-runtime-route-elapsed-001.md#L13)）。
符合 M-03「`accept` 且关闭时仍列出」。未使用缺失 disposition，也未把该缺口
写成 `tech_debt:` 却不登记 `TECH_DEBT.md`。

`RTRD-01` **未**改写成 `accept`。DEVICE-001 仍因 Product Gate / TestFlight /
Release 未授权而保持 Active，不是因为 `RTRD-02` 仍阻塞。

失败情景（未发生）：若无 Human/PD 接受就把 `fix` 改成 `accept`；若 `accept`
被写成性能已修复；若关闭 DEVICE-001；若把 `RTRD-01` 一并 `accept`。当前没有。

### 4. M-05：去掉 ELAPSED-001 后 Active Work 8 行 ≤10

成立。

- ACTIVE_WORK 仍声明 Lifecycle SoT = Assignment Record；cap ≤10
  （[`ACTIVE_WORK.md:5-8`](../ACTIVE_WORK.md#L5)）。
- 2026-09-11 更新句：#112 merged `7caec79`；Human 接受 RTRD-02 同字段缺口；
  ELAPSED-001 → Closed（`accept`）；DEVICE-001 仍 Active；无 Product Gate
  （[`ACTIVE_WORK.md:16`](../ACTIVE_WORK.md#L16)）。
- 表内 Active 行 **#1–#8**；原 #9 `SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001`
  已移除。#8 DEVICE-001 仍 Active，残差镜像为 `RTRD-02` **accept**
  （[`ACTIVE_WORK.md:19-28`](../ACTIVE_WORK.md#L19)）。
- `KNOWLEDGE_INDEX` 未把 ELAPSED / RTRD-02 编码为 Active；本 diff 不改该页，
  符合 M-02「仅当导航文本编码状态时才改」。

失败情景（未发生）：若 Closed 项仍占 Active 行，或表超过 10 项，或把
DEVICE-001 从 Active 表拿掉。当前没有。

### 5. 无性能结论；无 Swift；无 SUG-08；无 Product Gate

成立。

- 相对 baseline 的 9 个文件全是 Markdown；无 `.swift`。
- ELAPSED / PD / AUTH / preflight / DEVICE / Dashboard / ACTIVE_WORK 均保留
  无性能 pass/fail、无 Swift producer、无 SUG-08、无 Product Gate。
- Preflight E-01 第三行仍是 fail-closed same-field pair 不可读，**not a
  performance conclusion**
  （[`elapsed preflight:37`](../evidence/scheme-delivery-runtime-route-elapsed-001-preflight-2026-09-11.md#L37)）。
- Frontier：operator uninstall / new Swift producer / SUG-08 / Product Gate /
  Release = `Not authorized`
  （[`ELAPSED-001:39-42`](../assignments/scheme-delivery-runtime-route-elapsed-001.md#L39)）。
- 台账 SUG-07 行改为 ELAPSED Closed + same-field gap `accept`；SUG-08 仍是
  「only if SUG-07 insufficient and a separate authorization exists」
  （[`ledger:44-45`](../kos/kos-improvement-suggestions-scheme-delivery-2026-09-09-disposition-ledger.md#L44)）。
- D-01 对本 Assignment 为 `Not applicable`
  （[`ELAPSED-001:31`](../assignments/scheme-delivery-runtime-route-elapsed-001.md#L31)）。
  本审查落盘会使树变脏，更不能充当 D-01。

失败情景（未发生）：若把 `unreadable`/`accept` 写成 fallback 已与普通 Luna
一样快，或打开 SUG-08 / Product Gate。当前没有。

### 6. S-03：历史「下一步接受缺口」不再是当前实施指令

成立。

preflight「Next independently gated slices」上有 S-03：Item 1 completed；
Human accepted the gap；DEVICE-001 residual `RTRD-02` is `accept`
（[`elapsed preflight:45-49`](../evidence/scheme-delivery-runtime-route-elapsed-001-preflight-2026-09-11.md#L45)）。
第 2 项 Swift producer 仍 not authorized。第 3 项 SUG-08 仍 unauthorized。

失败情景（未发生）：若读者仍被指示「现在去接受缺口 / 现在去写 Swift」。
当前已 supersede 第 1 项。

### 7. 伞/兄弟 Assignment 的残差镜像未与所有者同步（M-02 缺口）

**不成立 — P2-01。**

M-02 在 Assignment Close 后要求父 Assignment Current Status 与镜像一致。
残差 **所有者** DEVICE-001 已改为 `accept`，但两个仍 Active 的伞/兄弟记录
仍把 `RTRD-02` 写成开放/`fix`，且本包 **未修改** 这两份文件（hash 与
RTRD-01-M02 冻结值相同）：

| 记录 | 当前 Current Status 措辞 | 与所有者冲突 |
|---|---|---|
| [`SOURCE-STATE-001:7`](../assignments/scheme-delivery-source-state-001.md#L7) | `RTRD-02` remains **open** under DEVICE-001 | DEVICE-001 已 `accept`；ELAPSED 已 Closed |
| [`SOURCE-STATE-001:18-19`](../assignments/scheme-delivery-source-state-001.md#L18) | elapsed **still needs a separate Assignment**；Residuals：`RTRD-02` remains **`fix`** | 独立 Assignment 已存在并 Closed；disposition 与所有者不一致 |
| [`INTEGRATION-001:12`](../assignments/scheme-delivery-runtime-route-integration-001.md#L12) | `RTRD-02` **仍另案** | 另案已 Close/`accept` |

ACTIVE_WORK #7（INTEGRATION **镜像**）已写成 same-field gap **accept**
（[`ACTIVE_WORK.md:27`](../ACTIVE_WORK.md#L27)），而其 SoT Assignment 仍写
「仍另案」。这是 M-05 所禁止的「镜像领先于 Assignment」。

该缺口：

- **不**使 ELAPSED-001 的 M-03 Close 无效（所有者列出 `accept`）；
- **不**重新打开已消费 AUTH；
- **不**授权 Swift / SUG-08 / Product Gate；
- **会**让后续执行者从 SOURCE-STATE Current Status 读到过期的 `fix` /
  「仍需另案」。

修复属于文档同步，不是本审查可改范围。独立 Quality 应看到同一冲突。

### 8. 行内 Markdown 链接使用 `path#Lnn` 而非 `path:nn`

成立。范围内 Markdown 链接无 `path:nn` 行引用。

### 9. 冻结输入 SHA-256

见上表；由 `hashlib.sha256` 在审查 SHA `ab592b99` 的工作树计算。本审查文件
未计入。

### 10. Verdict 计数；本审查不是 D-01 / hosted CI / merge / Product Gate

见 Findings 与 Verdict。

## 范围与 Source of Truth

相对 baseline 的变更文件仅 9 个 Markdown：

- `docs/ACTIVE_WORK.md`
- `docs/ENGINEERING_DASHBOARD.md`
- `docs/assignments/kos-sug-obs-glance-001.md`
- `docs/assignments/scheme-delivery-runtime-route-device-001.md`
- `docs/assignments/scheme-delivery-runtime-route-elapsed-001.md`
- `docs/authorizations/AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001.md`
- `docs/evidence/scheme-delivery-runtime-route-elapsed-001-preflight-2026-09-11.md`
- `docs/kos/kos-improvement-suggestions-scheme-delivery-2026-09-09-disposition-ledger.md`
- `docs/product-decisions/SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001-authorization.md`

无 Swift、无隐私政策、无生产日志、无 workflow/script。

| 事实 | 权威来源 | 其他文件角色 |
|---|---|---|
| ELAPSED-001 是否 Closed | 该 Assignment Current Status | Dashboard / Active Work 为镜像 |
| AUTH 是否仍可执行 | AUTH JSON `status` + `consumption_state` | Markdown Consumption 复述 |
| DEVICE-001 是否仍开放 | DEVICE-001 Assignment | Active Work #8 交叉引用 |
| `RTRD-02` residual 词 | DEVICE-001 Observability Follow-up：`accept` | ELAPSED Residuals / PD / preflight S-03 |
| `RTRD-01` | DEVICE-001：仍 `fix`，非 `accept` | 不得因本包改写 |
| 同字段是否可比 | elapsed preflight + 未变的 producer 源 | 不得写成性能结论 |
| Product Gate | 各记录 Non-claims + frontier `Not authorized` | 本审查不得授予 |

## Findings

| ID | Severity | Finding |
|---|---|---|
| P2-01 | P2 | M-02 伞/兄弟同步不完整：SOURCE-STATE-001 Current Status 仍写 `RTRD-02` `fix` / open / 仍需另案；INTEGRATION-001 仍写「另案」；ACTIVE_WORK #7 镜像已写 `accept`。残差所有者 DEVICE-001 与 ELAPSED Close 本身有效。 |

没有 P0、P1 或 P3 finding。

| Severity | Count |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 1 |
| P3 | 0 |

P2-01 不阻断本切片的 `accept` Close，也不重新打开 AUTH。它阻断的是「M-02
已对所有仍 Active 的伞记录完成」这一更强声明。

## Verdict

**Architecture verdict: Pass with conditions.**

Counts: **P0/P1/P2/P3 = 0/0/1/0**.

条件：SOURCE-STATE-001 / INTEGRATION-001 的 Current Status 残差措辞应与
DEVICE-001 `RTRD-02` `accept` 及 ELAPSED-001 Closed 对齐，并修正 ACTIVE_WORK
#7 镜像领先于 INTEGRATION Assignment 的倒置。在此之前，不得声称 M-02 伞同步
已完成。

本包正确地关闭 ELAPSED-001、消费 AUTH、把 DEVICE-001 残差 `RTRD-02` 记为
Human-authorized `accept`、保持 DEVICE-001 Active、Active Work 8 行 ≤10；
未新造 Swift / SUG-08 / Product Gate / 性能结论；`RTRD-01` 未改写成
`accept`。M-03 对该 `accept` **有效**。

## Non-claims

本审查不：

- 充当 D-01 final-documentation receipt、hosted CI、merge 权威或 Product Gate；
- 关闭 DEVICE-001，或把 `RTRD-01` 标为 `accept`；
- 授权新 Swift elapsed producer、操作员卸载轮、SUG-08、TestFlight、Release、
  ADR Accept 或 Kit `required`；
- 把同字段 `unreadable`/`accept` 写成 fallback 耗时已修复或已与普通 Luna 可比；
- 把 2026-09-09 真机证据写成已含 UUID/phase/elapsed 数值；
- 替代独立 Quality review。

## Validation and handoff

已执行：相对 `origin/main`（#112 merge `7caec797`）的范围 diff 与
`git diff --check`、输入 SHA-256、AUTH JSON 解析、`status` /
`consumption_state` 对照、M-03 `accept` 字段核对、Assignment/镜像/残差/S-03
静态核对、范围内相对链接存在性与 `path#Lnn` 约定、只读确认相对 baseline 无
Swift。
未执行 Xcode、Swift 测试、设备、原始目录读取、hosted CI、网络发布、D-01
receipt 或 Quality 复跑。

下一步仍属 Assignment 所有权：独立 Quality review（logical lane
`RTRD-02/document-quality`）。本审查落盘会使工作树相对 `ab592b99` 变脏，
不覆盖后续文档树。
