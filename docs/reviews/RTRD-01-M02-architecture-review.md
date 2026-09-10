# Architecture Review: RTRD-01-M02

## 审查身份与边界

| Field | Value |
|---|---|
| Reviewer | independent Architecture reviewer runtime；logical lane `RTRD-01-M02/document-architecture` |
| Date / timezone | `2026-09-10 Asia/Shanghai` |
| Worktree / branch | `/private/tmp/universe-keyboard-rtrd-01-m02` / `docs/rtrd-01-m02` |
| Reviewed SHA | `5d2d1cc477e4325b229e081904bc2e28343db03f`（`HEAD^{tree}=f138019b8943cda6f15ba3c78c61419b9c89aef5`） |
| Baseline | `4e4164fa75dab78a43a96c70dfa41471b384d4b7` (`origin/main`，PR #110 merge) |
| Review mode | 只读审查；仅允许写入本文件 |

独立性：本 runtime 未撰写或修改 Assignment、Authorization、Product Decision、
preflight 证据、台账、Dashboard、ACTIVE_WORK 或本 M-02 数据包；只检查最终已提交树
并写入本独立审查。本文件不是 D-01 receipt、不是 hosted CI、不是 merge 权威、
不是 Product Gate。

审查范围限于 `4e4164fa...5d2d1cc4` 的 **post-merge M-02 状态同步**：

- 关闭 [`KOS-SUG-OBS-DEVICE-001`](../assignments/kos-sug-obs-device-001.md)
  与 [`SCHEME-DELIVERY-RUNTIME-ROUTE-DIAGNOSTICS-UI-001`](../assignments/scheme-delivery-runtime-route-diagnostics-ui-001.md)
- 消费 [`AUTH-KOS-SUG-OBS-DEVICE-001`](../authorizations/AUTH-KOS-SUG-OBS-DEVICE-001.md)
- 从 Active Work 去掉上述两项（cap 仍 ≤10）
- [`SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001`](../assignments/scheme-delivery-runtime-route-device-001.md)
  保持 Active；`RTRD-01` 不改写成 `accept`；`RTRD-02` 仍为 `fix`

明确不审查、不授权：uninstall、SUG-08、Product Gate、TestFlight、Release、
ADR Accept、Scheme Platform P1 Swift、Kit `required`、DEVICE-001 Close、
或把 2026-09-09 真机证据重写成已含 UUID / phase / elapsed。

## 冻结输入

审查绑定下列工作树内容。任一输入、reviewer 绑定、采纳范围或项目边界变化，
本结论失效，需对新 SHA 重审。本审查文件本身不在下列 hash 内。

| Input | SHA-256 |
|---|---|
| [`KOS-SUG-OBS-DEVICE-001` Assignment](../assignments/kos-sug-obs-device-001.md) | `a74b5241755d97e6e4394384e3a17888a12bc15ea9fbf88925f85d5b8ea3f82e` |
| [`AUTH-KOS-SUG-OBS-DEVICE-001`](../authorizations/AUTH-KOS-SUG-OBS-DEVICE-001.md) | `55e53562ce3d8950e325d564c15af69b641d55a8874cf3a630fc648da35a8aba` |
| [`KOS-SUG-OBS-DEVICE-001` Product Decision](../product-decisions/KOS-SUG-OBS-DEVICE-001-authorization.md) | `a989caf43d2eeb90afd9be673abcfd6e2713cb4f47c3e5caae0bcc5d5df4c10f` |
| [`preflight evidence`](../evidence/kos-sug-obs-device-001-preflight-2026-09-10.md) | `122a8ff4c7057c0a8ef489843f05ec7ceee78204c35b6163c48ee73673452820` |
| [`DIAGNOSTICS-UI-001` Assignment](../assignments/scheme-delivery-runtime-route-diagnostics-ui-001.md) | `8b325960e109c82ac77d10c8275d329378f9df2aff252a2a66022234d99c8252` |
| [`DEVICE-001` Assignment](../assignments/scheme-delivery-runtime-route-device-001.md) | `6ea831d8f4a187eb7ac1589161497073c60de21994bfffb340858b41dceafdf4` |
| [`INTEGRATION-001` Assignment](../assignments/scheme-delivery-runtime-route-integration-001.md) | `09adf187ba4f1fcc91ad02ecf38c21b856e887c058266d57f4c646f337c2045e` |
| [`SOURCE-STATE-001` Assignment](../assignments/scheme-delivery-source-state-001.md) | `5031240e1c781773f9fe1321719aeb26349093798b7f0924b689514f607614fe` |
| [`ACTIVE_WORK.md`](../ACTIVE_WORK.md) | `780d83ba6d8ef16a8ea05d6bb46b2d9c99236dca143c7547d013ab0399a98423` |
| [`ENGINEERING_DASHBOARD.md`](../ENGINEERING_DASHBOARD.md) | `f5ed0de594746a4d58263ec0c998e12b07c278a8aa1bc5fbb1b4bb004537b1e2` |
| [`disposition ledger`](../kos/kos-improvement-suggestions-scheme-delivery-2026-09-09-disposition-ledger.md) | `02f5492a83603cec9ec7c6aefc060729fe2a966179542c56230d1cc3500cac8d` |
| [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md) | `59fc94f12b61ee303c4dda644c41eeae3b3fc3c63d9ea5b033e766ccc3b9fc5d` |
| [`kos-2.1-operational-maturity.md`](../kos/kos-2.1-operational-maturity.md) | `526094cc345c7bb4552750e0bd31c1fd349eb38d4be24ff7225feff63f30ecb1` |
| [`KNOWLEDGE_INDEX.md`](../KNOWLEDGE_INDEX.md) | `e1d8e4bbc8aac41e084beb9b88aae1b1825a9f5a4be7a585f300b27896f5cd94` |

`git diff --check 4e4164fa...5d2d1cc4` 通过。范围内相对链接可解析（273 个目标路径存在；
无 `path:nn` Markdown 行链接）。相对 baseline 无 `.swift`、无 workflow/script、
无隐私政策、无生产日志 schema 变更。审查时工作树相对 `HEAD` 干净（写入本文件前）。

## Architecture 核对

### 1. Lifecycle Source of Truth 是 Assignment；Dashboard / ACTIVE_WORK 是镜像

成立。

- ACTIVE_WORK 仍声明 Lifecycle SoT = Assignment Record
  （[`ACTIVE_WORK.md:7-8`](../ACTIVE_WORK.md#L7)）。
- 两 Closed 项从 Active 表移除，并在 Dashboard 写成 Closed + Next none
  （[`ENGINEERING_DASHBOARD.md:54-65`](../ENGINEERING_DASHBOARD.md#L54)）。
- DEVICE-001 / INTEGRATION / SOURCE-STATE 的 Active 镜像与各自 Assignment
  Current Status 同向：仍 Active；`RTRD-01` UI 已合入；`RTRD-02` 另案。
- `KNOWLEDGE_INDEX` 未把这两个 Closed 切片编码为 Active；SOURCE-STATE 仍标
  Active，与其 Assignment 一致。本 diff 不改该页，符合 M-02「仅当导航文本编码
  状态时才改」。

失败情景（未发生）：若 Dashboard 把 DEVICE-001 标 Closed，或 ACTIVE_WORK 自行
发明 lifecycle，则违反 M-05。当前没有这样做。

### 2. Closed Assignment 的 Current Status、next=none、non-claims 完整

成立。

| Assignment | Lifecycle | Next | 仍保留的 non-claims |
|---|---|---|---|
| [`KOS-SUG-OBS-DEVICE-001`](../assignments/kos-sug-obs-device-001.md) | `Closed`（#109 `0fd3518` / head `b481d70`） | None for this slice | 无卸载、无 SUG-08、无 Product Gate / TestFlight / Release；关闭 preflight **不**关闭 DEVICE-001 |
| [`DIAGNOSTICS-UI-001`](../assignments/scheme-delivery-runtime-route-diagnostics-ui-001.md) | `Closed`（#110 `4e4164f` / head `8a3f05c`） | None for this slice | 无卸载、无 SUG-08、无 journal schema、无 Product Gate / TestFlight / Release；合入不获得 `RTRD-02` |

PD Next 同样是 none for this slice
（[`PD:10`](../product-decisions/KOS-SUG-OBS-DEVICE-001-authorization.md#L10)）。
frontier 仍把 uninstall / SUG-08 / Release 标为 `Not authorized`。

失败情景（未发生）：若 Closed 记录把 next 写成可执行 uninstall / SUG-08，
或漏掉「不关闭 DEVICE-001」。当前没有。

### 3. AUTH consumed；不可复用于 uninstall / SUG-08 / Release

成立。

`kos-record` JSON 可解析。顶层 `status` 与
`authorization.consumption_state` **均为** `consumed`。
action 仍是 `execute_kos_sug_07_preflight_for_active_uninstall_claims`，
target 仍是 `KOS-SUG-OBS-DEVICE-001`。
exclusions 仍含 `uninstall_operator_round`、`implement_sug_08`、
`implement_rtrd_01_swift`、`raw_directory_read`、`required_mode`、
`push`、`pr`、`merge`、`release`、`testflight`。

Markdown Current Status 写明 consumed by Closed Assignment after #109，
**Not reusable** for uninstall / SUG-08 / Release
（[`AUTH:8`](../authorizations/AUTH-KOS-SUG-OBS-DEVICE-001.md#L8)）。
脚注把后续 push/PR/merge/#110/M-02 记为 **另一次** Human 授权，并声明本
receipt 不能授权 uninstall、SUG-08、`required` 或 Release。

失败情景（未发生）：若 `status`/`consumption_state` 不一致，或把已消费
receipt 写成仍可执行卸载。当前 JSON 与散文一致。

### 4. DEVICE-001 仍 Active；RTRD-01 未改写成 `accept`；RTRD-02 仍 `fix`

成立。

- DEVICE-001 Lifecycle = Active
  （[`DEVICE-001:9`](../assignments/scheme-delivery-runtime-route-device-001.md#L9)）。
- Observability Follow-up：`RTRD-01` disposition 仍为 **`fix`**（实现已合入，
  真机字段核验未重跑）；明确 **不**因 UI 合入改写成 `accept`
  （[`DEVICE-001:46-48`](../assignments/scheme-delivery-runtime-route-device-001.md#L46)）。
- `RTRD-02` disposition 仍为 **`fix`**
  （[`DEVICE-001:50-55`](../assignments/scheme-delivery-runtime-route-device-001.md#L50)）。
- INTEGRATION / SOURCE-STATE 仍 Active；后者 Residuals 写 `RTRD-01`
  implementation Closed via #110，同时 `RTRD-02` remains `fix`。这是实现切片
  Close，不是把 DEVICE residual 改成 `accept`。

失败情景（未发生）：若把 DEVICE-001 标 Closed，或把 `RTRD-01` 写成 `accept`。
当前没有。

### 5. 未声称 2026-09-09 真机证据现已含 UUID / phase / elapsed

成立。

DEVICE-001 non-claims：#110 合入不补齐 2026-09-09 真机证据里缺失的
UUID/phase/elapsed 观察
（[`DEVICE-001:11`](../assignments/scheme-delivery-runtime-route-device-001.md#L11)）。
Follow-up 正文：2026-09-09 真机记录仍只有 event code
（[`DEVICE-001:48`](../assignments/scheme-delivery-runtime-route-device-001.md#L48)）。
History：该证据 **not restated** as containing those fields
（[`DEVICE-001:73`](../assignments/scheme-delivery-runtime-route-device-001.md#L73)）。
SOURCE-STATE Residuals 同样保留「2026-09-09 device evidence still lacks
UUID/phase/elapsed」。
preflight 表仍把三行 trace 标为 `unreadable`，并经 S-03 标明这是 **pre-#110**
formatter 的 source-audit。

失败情景（未发生）：若把 UI 合入写成 Device-attested 字段已可见。当前 fail-closed。

### 6. 未新造 Product Gate / TestFlight / Release / ADR Accept / uninstall / SUG-08 授权

成立。

- 两 Closed Assignment、PD、AUTH、Dashboard、ACTIVE_WORK 更新句均保留
  无卸载 / 无 SUG-08 / 无 Product Gate / TestFlight / Release。
- DEVICE-001：用新诊断 UI 做真机 glance 或卸载轮次需 **新的** Human 授权。
- frontier：uninstall / SUG-08 / Release = `Not authorized`。
- 台账 SUG-08 仍是「only if SUG-07 insufficient and a separate authorization
  exists」，未因 preflight Closed 自动打开。
- 无 ADR Accept、无 `required`、无 Scheme Platform P1 Swift 授权文本。

失败情景（未发生）：若 M-02 把 AUTH 复用为卸载或 SUG-08。当前没有。

### 7. M-05：去掉两项 Closed 后 Active Work ≤10

成立。

Active 表现为 8 行（#1–#8），已去掉原 #9 `KOS-SUG-OBS-DEVICE-001` 与
#10 `DIAGNOSTICS-UI-001`。Cap 声明仍 ≤10。DEVICE-001 仍占一槽且为 Active。

### 8. S-03：历史 preflight “next slices” 第 1 项不再是当前实施指令

成立。

preflight「Next independently gated slices」上有 S-03 横幅：Item 1 为
historical；RTRD-01 later Closed via #110；本表仍是 **pre-#110** formatter
的 source-audit
（[`evidence:50-54`](../evidence/kos-sug-obs-device-001-preflight-2026-09-10.md#L50)）。
第 1 项标 **Completed** on `main`。第 2 项 on-device glance 仍 not authorized。
第 3 项 SUG-08 仍需另行授权。

失败情景（未发生）：若读者仍被指示「现在去实现 RTRD-01」。当前已 supersede。

### 9. 行内 Markdown 链接使用 `path#Lnn` 而非 `path:nn`

成立。范围内 Markdown 链接无 `path:nn` 行引用。preflight 源引用使用
`DiagnosticsLogSource.swift#L385-L398`（prose/backtick，方向正确）。

### 10. 冻结输入 SHA-256

见上表；由 `shasum -a 256` 在审查 SHA `5d2d1cc4` 的工作树计算。本审查文件未计入。

### 11–12. Verdict 计数；本审查不是 D-01 / hosted CI / merge / Product Gate

见 Verdict 与 Non-claims。

## 范围与 Source of Truth

相对 baseline 的变更文件仅 11 个 Markdown：

- `docs/assignments/kos-sug-obs-device-001.md`
- `docs/assignments/scheme-delivery-runtime-route-diagnostics-ui-001.md`
- `docs/assignments/scheme-delivery-runtime-route-device-001.md`
- `docs/assignments/scheme-delivery-runtime-route-integration-001.md`
- `docs/assignments/scheme-delivery-source-state-001.md`
- `docs/authorizations/AUTH-KOS-SUG-OBS-DEVICE-001.md`
- `docs/product-decisions/KOS-SUG-OBS-DEVICE-001-authorization.md`
- `docs/evidence/kos-sug-obs-device-001-preflight-2026-09-10.md`
- `docs/ACTIVE_WORK.md`
- `docs/ENGINEERING_DASHBOARD.md`
- `docs/kos/kos-improvement-suggestions-scheme-delivery-2026-09-09-disposition-ledger.md`

无 Swift、无隐私政策、无生产日志、无 workflow/script。

| 事实 | 权威来源 | 其他文件角色 |
|---|---|---|
| 两切片是否 Closed | 各自 Assignment Current Status | Dashboard / Active Work 为镜像 |
| AUTH 是否仍可执行 | AUTH JSON `status` + `consumption_state` | Markdown Consumption 复述 |
| DEVICE-001 是否仍开放 | DEVICE-001 Assignment | INTEGRATION / SOURCE-STATE / Active Work 交叉引用 |
| `RTRD-01` residual 词 | DEVICE-001 Observability Follow-up：`fix`，非 `accept` | UI Assignment Closed 只关闭实现切片 |
| `RTRD-02` | DEVICE-001 residual `fix` | 各镜像写 open / 另案 |
| 2026-09-09 真机字段 | DEVICE-001 证据指针 + 本 Assignment 明确「仍缺」 | 不得由 #110 UI 回填 |

## Findings

没有发现 P0、P1、P2 或 P3 finding。

| Severity | Count |
|---|---:|
| P0 | 0 |
| P1 | 0 |
| P2 | 0 |
| P3 | 0 |

无阻塞失败情景待修。

## Verdict

**Architecture verdict: Pass.**

Counts: **P0/P1/P2/P3 = 0/0/0/0**.

M-02 正确关闭 SUG-07 preflight 与 RTRD-01 UI 两切片，消费 AUTH，从 Active Work
去掉两项且仍 ≤10；DEVICE-001 保持 Active；`RTRD-01` 未改写成 `accept`；
`RTRD-02` 仍为 `fix`；未把 2026-09-09 真机证据写成已含 UUID/phase/elapsed；
未新造 uninstall / SUG-08 / Product Gate / TestFlight / Release / ADR Accept /
`required` 授权。S-03 已把历史「下一步实现 RTRD-01」标为完成/历史。

## Non-claims

本审查不：

- 充当 D-01 final-documentation receipt、hosted CI、merge 权威或 Product Gate；
- 关闭 DEVICE-001，或把 `RTRD-01`/`RTRD-02` 标为 `accept`；
- 授权 uninstall、on-device glance、SUG-08、TestFlight、Release、ADR Accept、
  Scheme Platform P1 Swift 或 Kit `required`；
- 把 preflight `unreadable` 或 #110 UI 合入写成 2026-09-09 真机字段已证明；
- 替代独立 Quality review。

## Validation and handoff

已执行：相对 `origin/main` 的范围 diff 与 `git diff --check`、输入 SHA-256、
AUTH JSON 解析、`status`/`consumption_state` 对照、Assignment/镜像/残差/S-03
静态核对、范围内相对链接存在性与 `path#Lnn` 约定。
未执行 Xcode、Swift 测试、设备、原始目录读取、hosted CI、网络发布、D-01
receipt 或 Quality 复跑。

下一步仍属 Assignment 所有权：独立 Quality review（logical lane
`RTRD-01-M02/document-quality`）。本审查落盘会使工作树相对 `5d2d1cc4` 变脏，
不覆盖后续文档树。
