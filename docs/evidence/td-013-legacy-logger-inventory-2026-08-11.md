# TD-013 legacy `Logger(String)` producer inventory — 2026-08-11

> **Purpose:** Phase D 的迁移前审计。它盘点当前自由文本日志入口，不能把
> legacy logger 视作 v1 的兼容输入，也不授权删除 `rime_diag_log`。
>
> **Method:** `rg -n "Logger\\.shared\\.(debug|info|warning|error|performance|devicePreflightPerformance)\\(" --glob '*.swift' --glob '!**/Tests/**' --glob '!**/.build/**'`，在当前工作树得到 **205** 个生产调用点、**40** 个文件。数字用于审计基线；后续改动必须重新生成并解释增减。

## 固定边界

- `DiagnosticEvent`/`DiagnosticsJournalIngress` 不接受 `String` payload；这 205 个
  legacy 调用不得通过 sanitizer、formatter 或 bridge 自动进入 v1。
- 本文件的 `Safe after review` 只表示当前文本不含用户输入、候选正文、preedit、
  任意路径或系统错误原文；它**不**等于可自动迁移。每个 cohort 仍需有 typed code/
  field、测试 target 和独立 privacy review。
- `High risk` 代表历史或当前调用点可能把自由字符串、动态资源标识、诊断摘要或
  外部错误带入 `rime_diag_log`。必须先改为聚合状态，或在单独 Assignment 中移除。

## 按 target / domain 的调用量

| Domain | Files | Calls | 默认 disposition |
|---|---:|---:|---|
| `Keyboard/` Extension UIKit 与候选 UI | 69 | 69 | 保持 legacy；先审热路径与 KBDVIS 已迁移范围，禁止在按键路径增加 v1 bridge。 |
| `Universe Keyboard/` Main App、部署与同步 | 62 | 62 | 分为 deployment/sync/notifications cohort；只迁移 Main-App 可以安全枚举的固定 lifecycle。 |
| `Packages/RimeBridge/` RIME runtime/资源部署 | 50 | 50 | 高风险优先，禁止记录 schema、文件、runtime 输出或外部错误原文。 |
| `Packages/KeyboardCore/` Core 状态和性能 | 24 | 24 | 保持 legacy；仅审查后迁移内容无关的性能/恢复摘要。 |
| **Total** | **40** | **205** | 不在 TD-013 中自动迁移或删除全部调用。 |

## 已在本次变更中消除的 P0-style payload

| Producer / location | 旧风险 | 本次 disposition | 后续条件 |
|---|---|---|---|
| `RimeLuaRuntimeSmokeProbe` + `RimeDeploymentService` | `developerSummary` 可含输入、候选样本、raw input、preedit。 | Result 不再保存这些样本/正文；过渡 legacy 输出仅保留 pass、registered、case count、dynamic count。 | 若迁移至 v1，需新建受控 smoke code 和 case enum，不能复用字符串。 |
| `SchemaManager+LuaDiagnostics` | `developerSummary` 由解析出的 Lua 组件/依赖名组成。 | legacy 输出改为 availability、布尔值和 component/dependency count。 | 组件名不能作为 v1 string field。 |
| `T9SchemaForceGCDiagnosticsRunner` | `developerSummary` / `userFacingLines` 可含路径、fingerprint、layout 和将来新增 UI 文本。 | legacy 输出仅保留固定 phase 与 source/compiled 状态 flag。UI 仍可在内存中展示用户说明。 | 需独立定义 T9 诊断的 typed code 后才迁移。 |
| `RimeConfigManager+DeploymentResources` | bundle / shared 目录的动态文件名和大小列表。 | 输出改为文件数、总字节数和固定操作状态。 | 任何文件 kind 进入 v1 前必须为封闭 enum，不能记录 basename。 |
| `RimeRuntimeLogSnapshot` | 读取第三方 runtime log 后返回原始匹配行及文件名。 | API 改为 `filesInspected`、`matchingLineCount`、`readFailureCount` 聚合结果。 | 若需持久化，使用专门 typed event，不读取原文。 |

## 未迁移 cohort（按风险顺序）

| Cohort | 代表文件 | 风险 | 当前处置 / stop condition |
|---|---|---|---|
| RIME 输入、候选、session runtime | `RimeEngineImpl+Input.swift`、`RimeEngineImpl+Candidates.swift`、`KeyboardViewController+InputActions.swift` | 直接邻接 raw/preedit/candidate/host 输入，且部分 message 在热路径构造。 | 不迁移；必须先以静态检查证明所有字段仅为长度/计数，再由 Architecture review 决定。 |
| Deployment / schema / Lua / T9 | `SchemaManager+Deployment.swift`、`RimeConfigManager+*.swift`、`T9SchemaForceGCDiagnosticsRunner.swift` | schema id、组件名、路径、`localizedDescription` 或 provider 文案可能进入文本。 | 仅已处理的 P0-style payload 可继续 legacy；其余逐 file review，不得 batch bridge。 |
| RIME sync / 网络 / 通知 | `RimeSyncViewModel.swift`、`RimeAutomaticSyncScheduler.swift`、`AppNotificationSettings.swift` | 目录/transport/provider error 与任意 `String(describing:)` 可能泄露外部内容。 | 另立 Main-App sync cohort；需要 allowlisted error family，不能记 error text/domain。 |
| Extension display / candidate paging | `KeyboardViewController+CandidatePaging.swift`、CandidateBar views | 大部分是布局/数量，但属于渲染和滚动路径。 | 已有 KBDVIS v1 覆盖的问题观测保留；不要为了去除 legacy 而增加每帧 event。 |
| Core performance / recovery | `HotPathSegmentTiming.swift`、`KeyboardController+RimeRecovery.swift` | 可能安全但覆盖输入关键路径。 | 仅选取稳定、低频的 lifecycle summary；任何 record 仍须经现有有界 ingress。 |

## 下一次 cohort Assignment 的最低输入

1. 调用点清单（文件/行、调用频率、target）；不得只给 grep 总数。
2. 每项的旧 payload 分类、v1 `Code`/`Field` allowlist 映射或明确“不迁移”理由。
3. 隐私审查、热路径审查、目标测试和 legacy 删除条件。
4. 迁移只允许把已审阅的 content-free 事件写入 v1；`rime_diag_log` 的删除、历史导入、远程上传均不属于该 cohort。

## 结论

TD-013 P1 的 Phase D 当前完成**inventory 与 P0-style 直接泄露收敛**，尚未开始广泛 cohort migration。legacy `Logger(String)` 仍是单独的受控技术债；在每个 cohort 获得明确 Assignment/隐私审查前，不能声称 v1 已替代它。
