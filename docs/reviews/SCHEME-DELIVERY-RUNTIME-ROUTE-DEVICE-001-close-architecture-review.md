# Architecture Review: SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001 Close

## 审查身份与边界

| Field | Value |
|---|---|
| Reviewer | independent Architecture reviewer runtime；logical lane `DEVICE-001/document-architecture` |
| Date / timezone | `2026-09-11 Asia/Shanghai` |
| Worktree / branch | `/private/tmp/universe-keyboard-device-001-close` / `docs/device-001-close` |
| Reviewed SHA | `7c89bbdb781948f88a92fb969aa43009e22fa1a0`（`HEAD^{tree}=a2b151cad52b97415d101a61c1c4285037e6bc06`） |
| Baseline | `1e09b827e0dcaf377e372c95c573ddc8f6e6836b` (`origin/main`) |
| Review mode | 只读审查；仅允许写入本文件 |

独立性：本 runtime 未撰写或修改 Assignment、Authorization、Product Decision、
证据、台账、Dashboard 或 ACTIVE_WORK；只检查最终已提交树并写入本独立审查。
本文件不是 D-01 receipt、不是 hosted CI、不是 merge 权威、不是 Product Gate。

审查范围限于 `1e09b827...7c89bbdb` 的 **DEVICE-001 工程 Close / M-02 镜像**：

- 关闭 [`SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001`](../assignments/scheme-delivery-runtime-route-device-001.md)
- 消费 [`AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001-CLOSE`](../authorizations/AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001-CLOSE.md)
- 残差 `RTRD-01` 保持 `fix`（实现 + glance）；`RTRD-02` 保持 `accept`
- 从 Active Work 去掉 DEVICE-001（cap 仍 ≤10；现 **7** 行）
- [`SCHEME-DELIVERY-SOURCE-STATE-001`](../assignments/scheme-delivery-source-state-001.md)
  与 [`SCHEME-DELIVERY-RUNTIME-ROUTE-INTEGRATION-001`](../assignments/scheme-delivery-runtime-route-integration-001.md)
  **保持 Active**
- 无 Product Gate；无 Swift；无性能快/慢结论

明确不审查、不授权：Product Gate、TestFlight、Release、ADR Accept、SUG-08、
新 Swift elapsed producer、把 `RTRD-01` 改写成 `accept`、把 2026-09-09 真机
证据写成已含 UUID / phase / elapsed **数值**、关闭 SOURCE-STATE / INTEGRATION、
Kit `required`。

## 冻结输入

审查绑定下列工作树内容。任一输入、reviewer 绑定、采纳范围或项目边界变化，
本结论失效，需对新 SHA 重审。本审查文件本身不在下列 hash 内。

| Input | SHA-256 |
|---|---|
| [`DEVICE-001` Assignment](../assignments/scheme-delivery-runtime-route-device-001.md) | `6d8632251cf9eece2d951c546b0455d66e9d62f946907a70077b7a17a944a017` |
| [`AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001-CLOSE`](../authorizations/AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001-CLOSE.md) | `dee4396d142af7a18eb7973ba9ebe4d9b49f7cd61d7af36793b64edb4cbd4e1c` |
| [`ELAPSED-001` Assignment](../assignments/scheme-delivery-runtime-route-elapsed-001.md) | `20cb160ca7ab07ce4c35326b2a2a491ef5b2b94ac2742ef6c5e1c6c0f2f2bf6a` |
| [`AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001`](../authorizations/AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001.md) | `e9b9d866ed83143b372b4cc88f5dfa57426a31bc659741d36cb18bb9dbd2e2fa` |
| [`ELAPSED-001` Product Decision](../product-decisions/SCHEME-DELIVERY-RUNTIME-ROUTE-ELAPSED-001-authorization.md) | `8c580f56071b18ad40e65705b3d95609dc53667e1ca50cfd17d677aa4d17ea8f` |
| [`elapsed preflight`](../evidence/scheme-delivery-runtime-route-elapsed-001-preflight-2026-09-11.md) | `d396728e7f0e3aac7c451302c4c587c14452e7885069287811d6aa83afdb730d` |
| [`INTEGRATION-001` Assignment](../assignments/scheme-delivery-runtime-route-integration-001.md) | `356751dc254d46f8cf46258eae746bb67014dc2d3530ecd8e8e96ba360b07245` |
| [`SOURCE-STATE-001` Assignment](../assignments/scheme-delivery-source-state-001.md) | `31d2d46e259e892229b3fd4a39d8206b61c3258047805fbc71a362ec23c13ab7` |
| [`GLANCE-001` Assignment](../assignments/kos-sug-obs-glance-001.md) | `bb47d5932ef990f0ba86960ba66f2455d2da2beb56eedae92a97be3105c1d845` |
| [`DIAGNOSTICS-UI-001` Assignment](../assignments/scheme-delivery-runtime-route-diagnostics-ui-001.md) | `bf53e432471b8d4d8c0765026e5553b0ec370c284361a6414a2647fb2dd185af` |
| [`2026-09-09 device evidence`](../evidence/scheme-delivery-runtime-route-device-001-2026-09-09.md) | `3b3cc37cf775fdc2d909c0801a83a4a7aa3f5155a4acfc878c13f1b28dc236c8` |
| [`DEVICE-001 Quality review`](scheme-delivery-runtime-route-device-001-quality-review.md) | `af818a3dd04fa10ef2b1c6c2558c387a4638f80523a7294cb8daa496053e432b` |
| [`glance device evidence`](../evidence/kos-sug-obs-glance-001-device-2026-09-11.md) | `b9191206c7af3651ad97bb1c9c2afa29948d88a655fef62adf2c185826fc6053` |
| [`ACTIVE_WORK.md`](../ACTIVE_WORK.md) | `9c7f561924e04ab1aaac8ae30636d07b161068ab1b3d0da9ebef9ee6e800557f` |
| [`ENGINEERING_DASHBOARD.md`](../ENGINEERING_DASHBOARD.md) | `3e88f525032d016825f12f78e14034d240ce5eb7a0deadb6d301f4e98408b8ab` |
| [`disposition ledger`](../kos/kos-improvement-suggestions-scheme-delivery-2026-09-09-disposition-ledger.md) | `ca4504f01661c8a751464abaa17b2ed73245e71c96f7f9ef7fae90fcb06edf5f` |
| [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md) | `59fc94f12b61ee303c4dda644c41eeae3b3fc3c63d9ea5b033e766ccc3b9fc5d` |
| [`kos-2.1-operational-maturity.md`](../kos/kos-2.1-operational-maturity.md) | `526094cc345c7bb4552750e0bd31c1fd349eb38d4be24ff7225feff63f30ecb1` |
| [`KNOWLEDGE_INDEX.md`](../KNOWLEDGE_INDEX.md) | `e1d8e4bbc8aac41e084beb9b88aae1b1825a9f5a4be7a585f300b27896f5cd94` |
| [`human-operated evidence profile`](../kos/universe-keyboard-human-operated-evidence-profile.md) | `b7588eeaec64e568945b74047828e455b68aa52f39877320bc813ce3135dd0ec` |
| [`UPGRADE_STATUS.md`](../kos/UPGRADE_STATUS.md) | `29f438145319127811d259dd692f24cbaf0c7b41666df799e8a1972cb71ef83a` |
| [`.kos/project.json`](../../.kos/project.json) | `890e590eb4963a9f028581135eab3b3f01484f05bb8bd614a3c944318ff3615f` |

`git diff --check 1e09b827...7c89bbdb` 通过。范围内相对链接可解析（272 个目标
路径存在；无缺失；无 `path:nn` Markdown 行链接）。相对 baseline 无 `.swift`、
无 workflow/script、无隐私政策、无生产日志 schema 变更。审查时工作树相对
`HEAD` 干净（写入本文件前）。

## Architecture 核对

### 1. DEVICE-001 Closed；next=none；工程 Close 不是 Product Gate

成立。

- Lifecycle = `Closed`；Next = none for this Assignment
  （[`DEVICE-001:9-12`](../assignments/scheme-delivery-runtime-route-device-001.md#L9)）。
- Current Phase：Human closed；CS09-10-02 functional Pass with conditions；
  `RTRD-01` fix glanced；`RTRD-02` accept
  （[`DEVICE-001:10`](../assignments/scheme-delivery-runtime-route-device-001.md#L10)）。
- Non-claims：Not Product Gate Passed、TestFlight、Release、ADR Accept；
  不是 Luna vs fallback 性能对照
  （[`DEVICE-001:11`](../assignments/scheme-delivery-runtime-route-device-001.md#L11)）。
- History：Human “批准关闭 DEVICE-001”；Engineering Close；Not Product Gate
  （[`DEVICE-001:75`](../assignments/scheme-delivery-runtime-route-device-001.md#L75)）。
- Dashboard 镜像 Closed + AUTH consumed + Next none + 同样 non-claims
  （[`ENGINEERING_DASHBOARD.md:61-66`](../ENGINEERING_DASHBOARD.md#L61)）。

M-03 允许 Close：`fix`（有证据指针）与 `accept`（关闭时仍列出）均可关闭。
本 Close 不把原始 Exit 中的 operation-correlated payload 重写成已在
2026-09-09 真机记录中核验；残差仍承担该缺口。

失败情景（未发生）：若把工程 Close 写成 Product Gate Passed。当前没有。

### 2. AUTH consumed；不可复用于 Product Gate / TestFlight / Release / SUG-08 / Swift

成立。

`kos-record` JSON 可解析。顶层 `status` 与
`authorization.consumption_state` **均为** `consumed`。
action = `close_scheme_delivery_runtime_route_device_001`；
target = `SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001`。
exclusions 含 `product_gate`、`testflight`、`release`、`adr_accept`、
`implement_sug_08`、`new_swift_elapsed_producer`、`required_mode`。

Markdown Current Status：Consumed by Closed DEVICE-001；**Not reusable**
for Product Gate / TestFlight / Release / SUG-08 / Swift
（[`AUTH:7-8`](../authorizations/AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001-CLOSE.md#L7)）。
脚注同向
（[`AUTH:41-42`](../authorizations/AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001-CLOSE.md#L41)）。

失败情景（未发生）：若 `status`/`consumption_state` 不一致，或把已消费
receipt 写成仍可执行 Product Gate。当前 JSON 与散文一致。

### 3. M-03：`RTRD-01` 仍为 `fix`（实现+glance）；`RTRD-02` 仍为 `accept`

成立。

| Residual | Owner | Disposition | Pointer |
|---|---|---|---|
| `RTRD-01` | Main App UI / Diagnostics | **`fix`**（implemented + glanced） | Closed [`DIAGNOSTICS-UI-001`](../assignments/scheme-delivery-runtime-route-diagnostics-ui-001.md)（#110）；[`GLANCE-001`](../assignments/kos-sug-obs-glance-001.md) 七键+底部详情 `是`（Debug `36b63c7`） |
| `RTRD-02` | Main App UI / Diagnostics | **`accept`** | Closed [`ELAPSED-001`](../assignments/scheme-delivery-runtime-route-elapsed-001.md)；Human 接受同字段缺口 |

Follow-up 正文：2026-09-09 真机记录仍不包含 UUID/phase/elapsed **数值**；
`RTRD-01` **不**改写成 `accept`
（[`DEVICE-001:47-49`](../assignments/scheme-delivery-runtime-route-device-001.md#L47)）。
`RTRD-02`：普通 Luna 不发 `runtime_route.phase_changed`，同字段不可比；
无性能结论；本切片无 Swift
（[`DEVICE-001:51-53`](../assignments/scheme-delivery-runtime-route-device-001.md#L51)）。

关闭时两残差仍列出，符合 M-03。未把 `fix` 静默改成 `accept`，也未用
`tech_debt:` 却不登记 `TECH_DEBT.md`。

失败情景（未发生）：若 Close 时漏列残差；若把 glance 写成 2026-09-09
payload 已补齐；若把 `RTRD-01` 一并 `accept`。当前没有。

### 4. SOURCE-STATE 与 INTEGRATION 保持 Active；前一轮 P2 伞表已对齐

成立（M-01 表 / Next / ACTIVE_WORK 镜像）。

前一份 ELAPSED Architecture 审查的 **P2-01**（SOURCE-STATE Residuals 仍写
`RTRD-02` `fix` / open；INTEGRATION 写「另案」；ACTIVE_WORK 镜像领先）在
本包已被修到所有者一致：

| 记录 | Lifecycle | Next / Residuals |
|---|---|---|
| SOURCE-STATE | **Active** | Next：DEVICE-001 **Closed**；Residuals：`RTRD-02` **accept**；不关闭 SOURCE-STATE / Product Gate / TestFlight / ADR Accept（[`SOURCE-STATE:7`](../assignments/scheme-delivery-source-state-001.md#L7)、[`#L19-23`](../assignments/scheme-delivery-source-state-001.md#L19)） |
| INTEGRATION | **Active** | Next：DEVICE-001 **Closed**；勿扩展诊断 UI 或耗时；`RTRI-*` 仍为该 Assignment 自己的残差（[`INTEGRATION:9-13`](../assignments/scheme-delivery-runtime-route-integration-001.md#L9)、[`#L111`](../assignments/scheme-delivery-runtime-route-integration-001.md#L111)） |
| ELAPSED | Closed | Current Status Non-claims 去掉 “does not close DEVICE-001”，避免与本 Close 冲突（[`ELAPSED-001:11`](../assignments/scheme-delivery-runtime-route-elapsed-001.md#L11)） |

`KNOWLEDGE_INDEX` 仍只把 SOURCE-STATE 标 Active，未把 DEVICE-001 编码为
当前工作项；本 diff 不改该页，符合 M-02「仅当导航文本编码状态时才改」。

失败情景（未发生）：若因 DEVICE Close 把 SOURCE-STATE / INTEGRATION 标
Closed。当前没有。叠放的旧 follow-up 见 P3-01。

### 5. M-05：去掉 DEVICE-001 后 Active Work 7 行 ≤10

成立。

- ACTIVE_WORK 仍声明 Lifecycle SoT = Assignment Record；cap ≤10
  （[`ACTIVE_WORK.md:5-8`](../ACTIVE_WORK.md#L5)）。
- 2026-09-11 更新句：Human 关闭 DEVICE-001（工程 Close；非 Product Gate）；
  本表移除第 8 行；无 TestFlight / Release
  （[`ACTIVE_WORK.md:16`](../ACTIVE_WORK.md#L16)）。
- 表内 Active 行 **#1–#7**；原 #8 DEVICE-001 已移除。#6 SOURCE-STATE 与
  #7 INTEGRATION 仍 Active；#7 镜像 DEVICE-001 **Closed**
  （[`ACTIVE_WORK.md:19-27`](../ACTIVE_WORK.md#L19)）。

失败情景（未发生）：若 Closed 项仍占 Active 行，或表超过 10 项，或把
SOURCE-STATE / INTEGRATION 从 Active 表拿掉。当前没有。

### 6. 无性能结论；无 Swift；无 SUG-08；无 Product Gate

成立。

- 相对 baseline 的 7 个文件全是 Markdown（6 改 1 增）；无 `.swift`。
- DEVICE / AUTH / Dashboard / ACTIVE_WORK / SOURCE-STATE / INTEGRATION /
  ELAPSED 均保留无性能 pass/fail、无 Product Gate Passed。
- ELAPSED frontier：operator uninstall / new Swift producer / SUG-08 /
  Product Gate / Release 仍 `Not authorized`
  （[`ELAPSED-001:39-42`](../assignments/scheme-delivery-runtime-route-elapsed-001.md#L39)）。
- 台账 SUG-07 仍指向 ELAPSED Closed + same-field gap `accept`；SUG-08 未因
  DEVICE Close 打开（本包未改 ledger）。

失败情景（未发生）：若把 `accept` 写成耗时已修复，或打开 SUG-08 /
Product Gate。当前没有。

### 7. 未声称 2026-09-09 真机证据现已含 UUID / phase / elapsed 数值

成立。

DEVICE Follow-up 明确：2026-09-09 记录仍缺数值；`RTRD-01` 不改写成
`accept`（[`DEVICE-001:49`](../assignments/scheme-delivery-runtime-route-device-001.md#L49)）。
Glance 仍是后续 Debug 上的键可见性，不是把 2026-09-09 Quality 矩阵升级为
payload Device-attested。SOURCE-STATE Residuals 仍写「2026-09-09 device
evidence still lacks UUID/phase/elapsed values」
（[`SOURCE-STATE:23`](../assignments/scheme-delivery-source-state-001.md#L23)）。

失败情景（未发生）：若 Close 把功能性 Pass 写成 payload 已在原真机记录中
核验。当前 fail-closed。

### 8. 行内 Markdown 链接使用 `path#Lnn` 而非 `path:nn`

成立。范围内 Markdown 链接无 `path:nn` 行引用。

### 9. 冻结输入 SHA-256

见上表；由 `hashlib.sha256` 在审查 SHA `7c89bbdb` 的工作树计算。本审查文件
未计入。

### 10. 本审查不是 D-01、不是 merge、不是 Product Gate

成立。本包无 D-01 选择、无 hosted CI、无 merge 动作。AUTH exclusions 含
`product_gate` / `required_mode`。本文件只记录 Architecture 核对，不关闭
SOURCE-STATE / INTEGRATION，不授予 Gate。

## 范围与 Source of Truth

相对 baseline 的变更文件仅 7 个 Markdown：

- `docs/ACTIVE_WORK.md`
- `docs/ENGINEERING_DASHBOARD.md`
- `docs/assignments/scheme-delivery-runtime-route-device-001.md`
- `docs/assignments/scheme-delivery-runtime-route-elapsed-001.md`
- `docs/assignments/scheme-delivery-runtime-route-integration-001.md`
- `docs/assignments/scheme-delivery-source-state-001.md`
- `docs/authorizations/AUTH-SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001-CLOSE.md`

无 Swift、无隐私政策、无生产日志、无 workflow/script。

| 事实 | 权威来源 | 其他文件角色 |
|---|---|---|
| DEVICE-001 是否 Closed | 该 Assignment Current Status | Dashboard / Active Work 为镜像 |
| AUTH 是否仍可执行 | AUTH JSON `status` + `consumption_state` | Markdown Consumption 复述 |
| `RTRD-01` / `RTRD-02` 词 | DEVICE-001 Observability Follow-up | SOURCE-STATE Residuals / ELAPSED Residuals |
| SOURCE-STATE / INTEGRATION 是否仍开放 | 各自 Assignment Current Status | Active Work #6 / #7 交叉引用 |
| 工程 Close 是否等于 Product Gate | DEVICE Non-claims + AUTH exclusions | 本审查不得授予 |
| 2026-09-09 payload 是否已核验 | 该日 evidence + Quality review + Follow-up | glance 只证明后续 Debug 键可见 |

## Findings

| ID | Severity | Finding |
|---|---|---|
| P3-01 | P3 | SOURCE-STATE **Current Status** 区在最新 follow-up 与 M-01 表已写 DEVICE-001 Closed / `RTRD-02` `accept` 之后，仍叠放同日旧段「Does not close … DEVICE-001」与 2026-09-10「`RTRD-02` remains open under DEVICE-001」，且无 S-03 横幅。SoT 表正确；读者若停在中间段会误判。 |
| P3-02 | P3 | Dashboard 页头 `Updated: 2026-09-10 Asia/Shanghai` 未随本 2026-09-11 Close 推进。DEVICE 节正文已 Closed，不构成生命周期冲突。 |

没有 P0、P1 或 P2 finding。前一轮 ELAPSED **P2-01** 在本包的 M-01 表 /
INTEGRATION Next / ACTIVE_WORK 镜像层已关闭。

| Severity | Count |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 0 |
| P3 | 2 |

P3 不阻断本 Assignment 的工程 Close，也不重新打开 AUTH。它们阻断的是
「Current Status 叠放段与 Dashboard 时间戳已无陈旧句子」这一更强卫生声明。

## Verdict

**Architecture verdict: Pass with conditions.**

Counts: **P0/P1/P2/P3 = 0/0/0/2**.

条件：SOURCE-STATE Current Status 旧 follow-up 应对 DEVICE Close 加 S-03
（或移入 History）；Dashboard `Updated` 可与 2026-09-11 Close 对齐。在此
之前，不得声称 Current Status 叠放段已无「DEVICE 仍开放」句子。

本包正确地关闭 DEVICE-001、消费 Close AUTH、保持 `RTRD-01`=`fix`（实现+
glance）与 `RTRD-02`=`accept`、SOURCE-STATE / INTEGRATION 仍 Active、
Active Work **7** 行 ≤10；未新造 Swift / SUG-08 / Product Gate / 性能结论；
未把 2026-09-09 真机证据写成已含 UUID/phase/elapsed 数值。M-03 对该 Close
**有效**。本审查不是 Product Gate。

## Non-claims

本审查不：

- 充当 D-01 final-documentation receipt、hosted CI、merge 权威或 Product Gate；
- 关闭 SOURCE-STATE-001 或 INTEGRATION-001，或把 `RTRD-01` 标为 `accept`；
- 授权新 Swift elapsed producer、SUG-08、TestFlight、Release、ADR Accept
  或 Kit `required`；
- 把同字段 `unreadable`/`accept` 写成 fallback 耗时已修复或已与普通 Luna 可比；
- 把 2026-09-09 真机证据写成已含 UUID/phase/elapsed 数值；
- 把 glance 七键写成原 CS09-10-02 轮次的 operation-correlated payload 核验；
- 替代独立 Quality review。

## Validation and handoff

已核：reviewed SHA/tree 与用户绑定一致；`origin/main` baseline
`1e09b827`；`git diff --check` 通过；AUTH JSON 可解析且 dual-consumed；
Active 表 7 行；范围内相对链接 272 个目标均存在。未跑 xcodebuild / 真机 /
hosted CI（本包无 Swift、无设备动作）。

Handoff：Coordinator 可将本文件交给独立 Quality。工程 Close 候选在
Architecture 上 **Pass with conditions**（仅 P3 卫生）。Product Gate /
TestFlight / Release 仍未授权。
