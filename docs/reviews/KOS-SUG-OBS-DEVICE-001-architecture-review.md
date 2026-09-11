# Architecture Review: KOS-SUG-OBS-DEVICE-001

## 审查身份与边界

| Field | Value |
|---|---|
| Reviewer | independent Architecture reviewer runtime；logical lane `KOS-SUG-OBS-DEVICE-001/document-architecture` |
| Date / timezone | `2026-09-10 Asia/Shanghai` |
| Worktree / branch | `/private/tmp/universe-keyboard-kos-sug-obs-device` / current worktree |
| Reviewed SHA | `708cda81b9589bd5f510e181e2e48255232389e8`（`HEAD^{tree}=659becc096223a8f282d77f214ae73f875b87822`） |
| Baseline | `0fbb3e994ee8382e6a8e37d85fc2157feb081469` (`origin/main`) |
| Review mode | 只读审查；仅允许写入本文件 |

独立性：本 runtime 未撰写或修改 Assignment、Authorization、Product Decision、
preflight 证据、台账或状态镜像；只检查最终已提交树并写入本独立审查。
本文件不替代 Quality 结论，不关闭 Assignment，不授权 uninstall、SUG-08、
RTRD-01 Swift、push / PR / merge、TestFlight 或 Release。

审查范围限于 `0fbb3e99...708cda81` 的 SUG-07 **preflight 执行**文档切片：

- [`KOS-SUG-OBS-DEVICE-001` Assignment](../assignments/kos-sug-obs-device-001.md)
- [`AUTH-KOS-SUG-OBS-DEVICE-001`](../authorizations/AUTH-KOS-SUG-OBS-DEVICE-001.md)
- [`KOS-SUG-OBS-DEVICE-001` Product Decision](../product-decisions/KOS-SUG-OBS-DEVICE-001-authorization.md)
- [`preflight evidence`](../evidence/kos-sug-obs-device-001-preflight-2026-09-10.md)
- `ACTIVE_WORK` / Dashboard 镜像与台账 Execution 指针
- 对照只读：SUG-07 profile 节、Governance 交叉引用、DEVICE-001 `RTRD-01`、
  `DiagnosticsEventDisplayFormatter` 源（相对 baseline **无 diff**）

明确不审查、不授权：RTRD-01 Swift、SUG-08 原始目录/文件读取、新的 uninstall /
候选轮、隐私政策、生产日志 schema、Kit `required`、DEVICE-001 关闭、
push、PR、merge、TestFlight 或 Release。

## 冻结输入

审查绑定下列工作树内容。任一输入、reviewer 绑定、采纳范围或项目边界变化，
本结论失效，需对新 SHA 重审。本审查文件本身不在下列 hash 内。

| Input | SHA-256 |
|---|---|
| [`KOS-SUG-OBS-DEVICE-001` Assignment](../assignments/kos-sug-obs-device-001.md) | `2e6fbd271d3585ff52d8f06c257e9c8611d114a21b10d8b03d1215001239cff3` |
| [`AUTH-KOS-SUG-OBS-DEVICE-001`](../authorizations/AUTH-KOS-SUG-OBS-DEVICE-001.md) | `43e1a74caa320f351ddb91d96d0f6c4f915e4b55aa4898fbe6c309078444404d` |
| [`KOS-SUG-OBS-DEVICE-001` Product Decision](../product-decisions/KOS-SUG-OBS-DEVICE-001-authorization.md) | `e48b4d1ec47194a9617b6caf8c3e8b6a3008690a8904d15a654e745e13536e2c` |
| [`preflight evidence`](../evidence/kos-sug-obs-device-001-preflight-2026-09-10.md) | `ae13c21c52a8875a58b34fbc0fce332306e53802d1ece453cfbd0b7c21db6996` |
| [`universe-keyboard-human-operated-evidence-profile.md`](../kos/universe-keyboard-human-operated-evidence-profile.md) | `b7588eeaec64e568945b74047828e455b68aa52f39877320bc813ce3135dd0ec` |
| [`DOCUMENTATION_GOVERNANCE.md`](../DOCUMENTATION_GOVERNANCE.md) | `d13c15217037571c8df9a43257ecae6e5d8c90556e4512116cae8568999651af` |
| [`ACTIVE_WORK.md`](../ACTIVE_WORK.md) | `146c1e726001551bcb2c3979f7ffbddebf4953cb30e425c881a7e8f383a9cd73` |
| [`ENGINEERING_DASHBOARD.md`](../ENGINEERING_DASHBOARD.md) | `e4244dd19a72a433247383984024a93ac7d69d7d01c767cac188a1ee17fd0e83` |
| [`disposition ledger`](../kos/kos-improvement-suggestions-scheme-delivery-2026-09-09-disposition-ledger.md) | `f419735211ee6c42742d69706182328251cb5759b6b28ffafe5b659f45725589` |
| [`DEVICE-001` Assignment](../assignments/scheme-delivery-runtime-route-device-001.md) | `f43bd65ecb80edf7d771188bd7f0e52a073f1cd9404d57a26dbb5f95fab5bc78` |
| [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md) | `59fc94f12b61ee303c4dda644c41eeae3b3fc3c63d9ea5b033e766ccc3b9fc5d` |
| [`UPGRADE_STATUS.md`](../kos/UPGRADE_STATUS.md) | `29f438145319127811d259dd692f24cbaf0c7b41666df799e8a1972cb71ef83a` |
| [`.kos/project.json`](../../.kos/project.json) | `890e590eb4963a9f028581135eab3b3f01484f05bb8bd614a3c944318ff3615f` |
| [`DiagnosticsLogSource.swift`](../../Universe%20Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift) | `fd56d126d22f03aba00592fd0e53b2d0bb543794a83097c119f75eecf618c820` |

`git diff --check 0fbb3e99...708cda81` 通过。范围内相对链接可解析。
相对 baseline 无 `.swift`、无 `PRIVACY_POLICY`、无诊断 UI、无生产日志文件变更。
审查时工作树相对 `HEAD` 干净（写入本文件前）。

## 七项 Architecture 核对

### 1. SUG-07 opt-in；不是 Kit v0.8 合同；不回填 DEVICE-001

成立。

- 本 Assignment 在 Required Inputs 与 Objective 中**点名**
  [`profile` SUG-07 节](../kos/universe-keyboard-human-operated-evidence-profile.md#observability-preflight-kos-sug-07-opt-in)
  （[`Assignment:47-56`](../assignments/kos-sug-obs-device-001.md#L47)）。
  这满足 profile「新 human-device Assignment 仅在点名该节时才采纳」
  （[`profile:97-102`](../kos/universe-keyboard-human-operated-evidence-profile.md#L97)）。
- Governance 仍写明 SUG-07 是项目 profile 约定、不是 Kit v0.8.0 合同、不回填
  （[`DOCUMENTATION_GOVERNANCE.md:176-186`](../DOCUMENTATION_GOVERNANCE.md#L176)）。
- 本记录 Adopted 的是 **E-01**（仅 UI 可见性的 source-audit claims）与
  **A-01/B-01**；P-01 / D-01 为 `Not applicable`
  （[`Assignment:24-31`](../assignments/kos-sug-obs-device-001.md#L24)）。
  这是本记录的授权链 opt-in，不是把 SUG-07 升格为 Kit 合同。
- `.kos/project.json` 与 `UPGRADE_STATUS.md` 未把 SUG-07 登记为 Kit 合同；
  adopted pin 仍为 `v0.8.0` advisory。
- DEVICE-001 Assignment 文件相对 baseline **未改**；其 `RTRD-01` 不因本切片
  opt-in 被回填关闭。

失败情景（未发生）：若未点名 profile 节却声称 SUG-07 对所有真机 Assignment
生效，或把 SUG-07 写入 Kit 合同表，则越权。当前没有这样做。

### 2. Functional 与 trace 分离；event code 不能证明 UUID / phase / elapsed

成立。

证据表四行：一行 `functional`（卸载后候选条二进制有无，无诊断字段），三行
`trace`（operation UUID、phase/result、elapsed_ms）
（[`evidence:17-24`](../evidence/kos-sug-obs-device-001-preflight-2026-09-10.md#L17)）。
E-01 第二行显式写：列表中出现 `runtime_route.phase_changed` **不能**证明这些字段
（[`evidence:33`](../evidence/kos-sug-obs-device-001-preflight-2026-09-10.md#L33)）。
这与 profile
（[`profile:111-118`](../kos/universe-keyboard-human-operated-evidence-profile.md#L111)）
及源建议稿 SUG-07
（[`source:109-112`](../kos/kos-improvement-suggestions-scheme-delivery-2026-09-09.md#L109)）
一致。

只读核对 formatter（相对 baseline 无 diff）：

```385:398:Universe Keyboard/Views/Diagnostics/DiagnosticsLogSource.swift
enum DiagnosticsEventDisplayFormatter {
    nonisolated static func line(_ event: DiagnosticEvent) -> String {
        ...
        let delivery = event.schemeDeliveryPayload.map(schemeDeliveryDescription)
        let rimeSync = event.rimeSyncPayload.map(rimeSyncDescription)
        let details =
            ([action, delivery, rimeSync].compactMap { $0 } + (fields.isEmpty ? [] : [fields]))
            .joined(separator: " ")
        ...
        return "[\(timestamp)] [\(event.level.rawValue)] [\(event.category.rawValue)] \(event.code.rawValue)\(suffix)"
    }
```

`line` 拼接 timestamp / level / category / `event.code`，可选
`schemeDeliveryPayload` / `rimeSyncPayload` / generic `fields`，**没有**
`runtimeRoutePayload`。列表 UI 只渲染这些格式化行
（`DiagnosticsLogContentView` 的 `displayedLines: [String]`，无 detail sheet）。
`recordRuntimeRoute` 把 UUID / phase / result / `elapsedMilliseconds` 放在
payload 上且 `fields` 必须为空，因此 generic `fields` 也不能带出这些键。

功能行 `Readable now?` 写作 `` `yes` if a run were started ``，不是受控三值
`yes`/`no`/`unknown` 的字面拷贝。它没有把 functional 行标成 `not-checked`，
也没有用它授权 uninstall；trace 行仍是 `no` → `unreadable`。本审查不把它升为
finding。

失败情景（未发生）：若用 event code 把 UUID/phase/elapsed 写成 `readable`，
则会把不可读字段写成已证明。当前表 fail-closed。

### 3. 不可读 trace 字段正确阻止 uninstall；无 operator 指令

成立。

- Mapping：`Readable now?` `no` → `unreadable`；无 `not-checked` 行
  （[`evidence:25`](../evidence/kos-sug-obs-device-001-preflight-2026-09-10.md#L25)）。
- Operator instructions：**None in this slice**；SUG-07 禁止为追逐不可读
  trace 字段要求 uninstall，并禁止打开原始诊断目录
  （[`evidence:46-48`](../evidence/kos-sug-obs-device-001-preflight-2026-09-10.md#L46)）。
- PD：trace 字段为 `unreadable` 时 **不要** 发出 uninstall 操作指令
  （[`PD:8`](../product-decisions/KOS-SUG-OBS-DEVICE-001-authorization.md#L8)）。
- Assignment Stop：任何 uninstall / 宿主输入 / 打开原始目录的请求必须停下
  （[`Assignment:97-101`](../assignments/kos-sug-obs-device-001.md#L97)）。
- AUTH exclusions 含 `uninstall_operator_round`
  （[`AUTH:31`](../authorizations/AUTH-KOS-SUG-OBS-DEVICE-001.md#L31)）。

Generic SUG-07 允许在无 `not-checked` 的前提下带着 `unreadable` 行继续测
**已授权的** functional claim；本切片 PD 更严：在 trace 不可读时不发送
uninstall。Frontier 把「显式 functional-only round」标为需要**新的** Human
authorization，而不是本 AUTH 的附带权限。这是收紧，不是越权。

失败情景（未发生）：若 preflight 填完后直接写出 Ice/Wanxiang 卸载步骤，
则违反 SUG-07 与本 PD。当前证据明确「None」。

### 4. Formatter source-audit 不是 Device-attested；不是 Quality-reverified

成立。

证据 Current Status：`Grade = Executor-recorded (source audit …)`；
Non-claims：**Not Device-attested; not Quality-reverified; not an uninstall
run; not SUG-08**
（[`evidence:10-11`](../evidence/kos-sug-obs-device-001-preflight-2026-09-10.md#L10)）。
三值被标为 **pre-operation readability only**，禁止复制到 E-01 Outcome、
M-04 grade、Device-attested、Quality-reverified、Product Gate、Release 或
SUG-04 触发器（[`evidence:26`](../evidence/kos-sug-obs-device-001-preflight-2026-09-10.md#L26)），
与 profile（[`profile:123-126`](../kos/universe-keyboard-human-operated-evidence-profile.md#L123)）
及 Governance「preflight readability 不是 E-01 outcome」一致。

E-01 表三项均为 `Evidence grade = Executor-recorded`，claim 限于 formatter
是否包含 `runtimeRoutePayload`、隐私安全列表能否显示 UUID/phase/elapsed、
以及本切片未启动 uninstall。这符合 Assignment「Source-audit claims about UI
field visibility only」。Governance 禁止把 Executor-recorded 写成
Quality-verified。

失败情景（未发生）：若把 source-audit `pass` 写成 DEVICE-001 真机复验或
M-04 Device-attested，则污染证据等级。当前文本没有这样做。

### 5. RTRD-01 未关闭

成立。

- 本切片 Non-goals / AUTH exclusions 含 `implement_rtrd_01_swift`。
- Assignment Residuals：`RTRD-01` 在 DEVICE-001 上仍为 `fix`
  （[`Assignment:13`](../assignments/kos-sug-obs-device-001.md#L13)）。
- DEVICE-001 Observability Follow-up 仍描述 formatter 不渲染
  `runtimeRoutePayload`，disposition `fix`；本 diff **未修改**该 Assignment。
- 证据 Next independently gated slices 第一项仍是 RTRD-01 UI，且标明
  **not authorized here**
  （[`evidence:50-54`](../evidence/kos-sug-obs-device-001-preflight-2026-09-10.md#L50)）。
- E-01 第一行只说与 residual **对齐**，不是关闭 residual。

失败情景（未发生）：若把「已证明 UI 不可读」写成 `RTRD-01` Closed/`accept`，
则越权关闭 DEVICE-001 债务。当前没有关闭。

### 6. 无 SUG-08

成立。

AUTH exclusions：`implement_sug_08`、`raw_directory_read`。
Frontier 行 `SUG-08 raw-file read` = `Not authorized`，权威来源为
「New Assignment + Human authorization」。
证据禁止打开原始诊断目录；下一步 SUG-08 仅当 UI 仍不足且**另行授权**命名文件
读取时才可能。
PD Non-claims：no SUG-08。
Profile：`unreadable` 不授权 SUG-08
（[`profile:130-133`](../kos/universe-keyboard-human-operated-evidence-profile.md#L130)）。

失败情景（未发生）：若 `unreadable` 被写成可打开 App Group 目录或自动升格
SUG-08，则越权。当前停在独立授权。

### 7. Frontier 不创造 uninstall 权威

成立。

| Slice | Status | 权威来源核对 |
|---|---|---|
| SUG-07 preflight fill | `In progress` | Assignment → AUTH `execute_kos_sug_07_preflight_for_active_uninstall_claims` → PD；action/target/scope 匹配 |
| Active-uninstall operator round | `Not authorized` | 需 **New Human authorization**（trace 变 `readable` 之后，或显式 functional-only round） |
| RTRD-01 diagnostics UI | `Not authorized` | New Main App UI Assignment |
| SUG-08 raw-file read | `Not authorized` | New Assignment + Human authorization |
| Push / PR / merge / Release | `Not authorized` | New Human authorization |

受控词表符合 [`ASSIGNMENT_POLICY.md:255-263`](../ASSIGNMENT_POLICY.md#L255)：
frontier 记录权威、不创造权威；无 `UNKNOWN`。卸载行不是 `Authorized`。
「批准继续SUG-07 真机执行」已由 PD 解释为 **preflight only**，并写入匹配 AUTH；
Dashboard / Active Work / 台账指针不能把该口语指令升格为 uninstall。

台账 Current dispositions 的 SUG-07 行仅增加 Execution 指针
`preflight filled; no uninstall`，未改 SUG-08「only if SUG-07 insufficient
and a separate authorization exists」，也未把 SUG-04 Deferred 触发器改写为本
source-audit。

失败情景（未发生）：若 frontier 把 uninstall 标为 `Authorized`，或用
Dashboard / 聊天指令代替匹配 AUTH，则违反 A-01。当前链匹配且卸载未授权。

## 范围与 Source of Truth

相对 baseline 的变更文件仅 7 个 Markdown：

- `docs/assignments/kos-sug-obs-device-001.md`
- `docs/authorizations/AUTH-KOS-SUG-OBS-DEVICE-001.md`
- `docs/product-decisions/KOS-SUG-OBS-DEVICE-001-authorization.md`
- `docs/evidence/kos-sug-obs-device-001-preflight-2026-09-10.md`
- `docs/ACTIVE_WORK.md`
- `docs/ENGINEERING_DASHBOARD.md`
- `docs/kos/kos-improvement-suggestions-scheme-delivery-2026-09-09-disposition-ledger.md`

无 Swift、无隐私政策、无诊断 UI、无生产日志、无 workflow/script。
AUTH 绑定 profile 与 `DiagnosticsLogSource.swift` 作为**只读审计对象**，
不是修改许可。

| 事实 | 权威来源 | 其他文件角色 |
|---|---|---|
| SUG-07 表与可读性词表 | human-operated evidence profile | Governance 只交叉引用 |
| 本切片是否可执行 preflight | Assignment + AUTH + 本切片 PD | Dashboard / Active Work 为镜像 |
| 隐私安全 UI 是否渲染 runtime-route 字段 | `DiagnosticsEventDisplayFormatter` 源 + 本 evidence（Executor-recorded） | 不是 Device-attested |
| `RTRD-01` 是否仍开放 | DEVICE-001 Assignment residual `fix` | 本 evidence 只对齐、不关闭 |
| Kit 版本与可选合同 | `UPGRADE_STATUS.md` / `.kos/project.json` | 本切片未改 |

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

本切片正确 opt-in SUG-07；functional/trace 分行且 event code 不能证明
UUID/phase/elapsed；trace `unreadable` 正确阻止 uninstall 且无 operator 指令；
formatter source-audit 保持 Executor-recorded、不是 Device-attested；
`RTRD-01` 未关闭；无 SUG-08；frontier 不创造卸载权威。

## Non-claims

本审查不：

- 关闭 Assignment，或把 Exit Criteria 中未勾选的独立 Quality review 标为已完成；
- 授权 uninstall、on-device glance、SUG-08、RTRD-01 Swift、隐私/日志改动；
- 把 preflight `readable`/`unreadable` 或 E-01 `pass` 写成功能/trace 真机 claim
  已证明，或写成 DEVICE-001 Closed；
- 授权 push、PR、merge、TestFlight 或 Release；
- 替代独立 Quality review。

## Validation and handoff

已执行：相对 `origin/main` 的范围 diff 与 `git diff --check`、输入 SHA-256、
权威链/SoT/七项边界静态核对、formatter 只读源核对、范围内相对链接存在性。
未执行 Xcode、Swift 测试、设备、原始目录读取、CI、网络发布或 Quality 复跑。

下一步仍属 Assignment 所有权：独立 Quality review（logical lane
`KOS-SUG-OBS-DEVICE-001/document-quality`）；然后 Human 在 RTRD-01 UI、
optional on-device glance、或 stop 之间选择。本审查落盘会使工作树相对
`708cda81` 变脏，不覆盖后续文档树。
