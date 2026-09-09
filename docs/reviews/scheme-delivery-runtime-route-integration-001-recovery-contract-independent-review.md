# SCHEME-DELIVERY-RUNTIME-ROUTE-INTEGRATION-001 recovery contract 独立复审

日期：2026-09-09 Asia/Shanghai
复审类型：KOS Architecture / Knowledge Steward，只读、独立复审
复审基线：`/private/tmp/uk-scheme-delivery-fix`，当前未提交工作树

本复审只核对 Human 已授权的 `rollbackIncomplete` 契约冲突处置。复审期间没有
修改产品代码、Assignment 或 `docs/ACTIVE_WORK.md`；本文是本轮唯一新增文件。

## 复审范围与依据

- `docs/assignments/scheme-delivery-runtime-route-integration-001.md`
- `docs/plans/scheme-delivery-active-uninstall-runtime-route-reconciliation-2026-09-08.md`
- `Universe Keyboard/Services/SchemaManager+Installation.swift`
- `Universe Keyboard/Services/SchemaArchiveInstaller.swift`
- `UniverseKeyboardTests/SchemaManagerTests.swift`
- `UniverseKeyboardTests/SchemeResourcePreparationCoexistenceTests.swift`
- `Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift`

复审问题是：`rollbackIncomplete` 是否已明确成为 Luna 保留、恢复文件与安装元数据
保留、原 route 不重新部署、commit 停止的 fail-closed terminal state；诊断是否有
受控结果；以及该处置是否越过 archive ownership、Extension 或后续 P2 边界。

## 结论

结论：**Pass with conditions**。

本轮已经解决了先前的契约冲突：Assignment 与 route plan 均明确把
`rollbackIncomplete` 从普通 staging failure 中分离出来，并明确不再宣称
complete before-state 已恢复。Main App 的实现与该终态一致，没有发现 P0/P1
级别的契约越界或错误地重新部署不可证明完整的原 route。

但该契约目前仍缺少一组完全对应的 Main App 断言，且文档中“`staging:failed` with
recovery-incomplete result”和实际 typed 事件 `staging:recovery_incomplete` 的
命名关系需要固定下来。因此本复审不把该契约单独升级为 P1 已关闭，也不把它解释
为真机部署耗时问题已解决。

## 已确认的契约一致性

### 1. fail-closed terminal state 已写入 SoT

Assignment 的 Failure Recovery Contract 明确规定：

- `rollbackIncomplete` 表示 installer 不能证明原 resource tree 已恢复完整；
- 保留已部署的 Luna route；
- 保留 recovery files 与 installation metadata；
- 跳过原 route redeploy；
- 在 commit 前停止本次 uninstall；
- 使用同一 operation 记录 recovery-incomplete diagnostic；
- 后续 retry 由显式 recovery operation 负责，不由当前 uninstall 隐式重试。

同一语义已写入 route plan 的 Recovery-incomplete boundary。两份文档都明确声明
这不是 crash/restart atomicity 或 Recovery persistence 结论，因此没有把本次修正
扩展成未授权的恢复系统。

### 2. Main App 行为符合终态

`performSchemaUninstall` 在 fallback Luna 部署成功后调用 archive staging。捕获
`SchemaUninstallRecoveryError` 时：

- 只记录受控失败日志和 runtime-route event；
- 直接返回，不调用 `restoreSchemaAfterFailedUninstall`；
- 不调用 `commitSchemaUninstall`；
- 不清除 installed/version/license/checksum 等安装元数据；
- 不发起原 route 的第二次 deploy。

这与 normal staging failure 的分支保持区分：普通 failure 仍恢复完整 route state
并尝试原 route redeploy；只有 archive 无法证明恢复完整时才进入终态。

### 3. archive checkpoint 仍由既有 owner 管理

`SharedContainerSchemaArchiveInstaller.rollbackSchemaUninstall` 在恢复不完整时
保留仍可能是唯一副本的 staging root，并抛出 `rollbackIncomplete`；它不会在失败
分支删除 checkpoint。既有 `SchemeResourcePreparationCoexistenceTests` 还覆盖了
双失败保留 checkpoint、随后显式 retry 恢复并清理 staging root 的路径。

本轮没有改变 `uninstallRelativePaths`、Lua matching、commit cleanup 或 shared
resource ownership，也没有添加按 hash/prefix 删除资源的逻辑。

### 4. Extension 与 RimeBridge 边界未被越过

route mutation、Luna deployment、archive staging/commit 和 failure terminal
decision 仍全部位于 Main App `SchemaManager` 与 archive installer。新增的
`RuntimeRoutePhaseEvent` 只进入现有 content-free journal；没有向 Keyboard
Extension 下放 deployment、App Group 写入或 recovery retry。

### 5. 诊断结果是受控的，但命名需固定

Main App 记录的事件只包含 operation UUID、有限 phase/result/schema/layout/state
和有界耗时。`staging_rollback_incomplete` 映射为：

`phase = .staging`, `result = .recoveryIncomplete`, `isFailure = true`。

这比自由文本能稳定表达“staging 失败且原因是 recovery incomplete”，并且不携带
路径、URL、用户输入、文件内容或异常原文。对应 Main App 测试已断言：Luna 只部署
一次、原 route 不重新部署、没有 commit，并产生
`staging:recovery_incomplete` 事件。

## 条件与残余

### P1-REC-01：固定文档与 typed event 的失败命名契约

Assignment 文字写的是“`staging:failed` with the recovery-incomplete result”，
而测试和 typed payload 使用 `staging:recovery_incomplete`。两者语义可以一致，
但必须在后续 P1 序列复审中明确其规范表示：建议保留有限枚举
`result = recovery_incomplete`，并把文档改成“staging phase with
`recovery_incomplete` result and failure level”，避免要求一个事件同时拥有
`failed` 和 `recovery_incomplete` 两个互斥 result。

### P1-REC-02：Main App 测试需要断言完整 route state

`testIncompleteRollbackStopsWithoutRedeployingOriginalSchema` 已断言 active
schema 为 Luna、installed 标记仍存在、只出现 Luna deploy、未 commit、lease 最终
释放和 typed sequence。但它没有逐项断言 after-state 的 layout、26-key binding、
9-key binding、legacy alias 仍构成预期的 Luna route，也没有把 staging checkpoint
保留行为与 manager 终态放在同一测试中。

该缺口不改变已确认的契约方向，但在 P1 close 前应补一条可观察断言；文件保留
证据继续由 archive installer 的真实文件测试负责，不能用 stub 的“抛出 error”
替代。

### P1-REC-03：继续保留既有非声明

本复审不关闭以下事项：

- fallback 或 rollback 的 callback 是否可由测试证明始终持有同一 lease identity；
- 多 key App Group preference 写入的 crash / cross-process 语义；
- matched T9 persisted resolver、inactive binding 悬挂策略；
- CS09-10-02 真机 route、candidate input 或 Luna 部署耗时对照；
- RimeBridge/Extension target、Product Gate、PR、merge、TestFlight 或 Release。

这些属于 Assignment 中已有的 P1/P2 或后续 Human gate，不应借 recovery contract
修正而扩大范围。

## 验证记录

本轮执行了指定 active-uninstall 单测命令，但环境在编译前阻塞：
CoreSimulatorService connection invalid，且 SwiftPM/Clang ModuleCache 返回
`Operation not permitted`。因此本复审不把该命令记为新的测试通过证据；结论基于
当前源码、Assignment/plan、既有测试源码与 archive 文件级测试证据。

已确认的静态边界：

- `git diff --check` 的既有结果无新增越界；
- 相关 Swift 文件的既有 strict format/lint 结果通过；
- 当前变更未新增 Extension/RimeBridge 生产文件；
- 未进行 commit、push、PR、merge 或设备操作。

## 交接

可以将“契约冲突已解决”交给下一轮 P1 序列复审，但交接时应携带上述两个 P1
条件。只有在命名、完整 route state 断言以及既定 lease/sequence 证据闭合后，才
能决定 P1 是否关闭；即使关闭，也只能说明自动化契约成立，不能替代真机耗时矩阵。
