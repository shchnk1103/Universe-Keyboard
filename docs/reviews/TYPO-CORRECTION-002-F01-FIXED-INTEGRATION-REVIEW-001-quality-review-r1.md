# F01 固定基线整合独立质量审查

展示版本：仅删除两处Markdown尾空格，不改变审查结论。字节原件以base64 JSON保留，见 [original](TYPO-CORRECTION-002-F01-FIXED-INTEGRATION-REVIEW-001-quality-review-r1.original.json)，原SHA256 `00f6c71ac7300dd3bc59b78b335deef7352205d4d9c3652aa371037bc828a576`。

**Lane / round：** `F01_FIXED_A44_QUALITY_R1` / 1
**Work item：** `typo-correction-002-f01-fixed-integration-review-001`
**结论：Scoped Pass with conditions**，仅限下述冻结 candidate 的五文件 F-01 增量及本轮 executor-recorded CI 证据。没有发现阻断该限定增量的代码问题。本结论不是 Product Accept、父项 Close、Quality Gate、Release、合并或发布结论。

## 身份与范围

- packet SHA256 `4c46f4f1ae270f37b6a609aba741391c32ac75a080b27395451bd1e77b10e654` 与入口指定值一致；packet 列出的 23 项输入均独立核对字节数和 SHA256，全部匹配。另对允许的五个原始源路径逐一重算，均与 packet/candidate 所列哈希和字节数一致。
- 冻结基线 `a44f850d638204aa5c992ac13fb71f5f5424734c`；旧整合 head `e20e7c8a3a48822e2e712d36453e2cf574088e87`；source tree `0bc4bb5dc7cd830c25a8bdb9b5dfbbd476b969f3`；candidate manifest SHA256 `44fbd8924502c48f36f1f58bcf8446f83801119b78dbf666d124ae45b2b47be1`。
- 五个 candidate paths、`identity.json` 的五个 dirty paths、receipt 的 `source_status_before` 五项在去除 Git 对含空格路径的显示引号后完全一致；`index_paths` 为空。执行回执记录入口和 source closeout 均匹配五个源路径。
- 唯一读取范围是冻结 packet 所列文件及允许重算哈希的五个原始源路径。没有读取其他工作区/线程或网络内容，没有运行测试、构建、设备操作或 Git mutation；executor 结果不作为 reviewer 独立重跑。

## C1–C4 覆盖矩阵

| Criteria | 结论 | 独立核对及边界 |
|---|---|---|
| C1 候选身份 | **Covered** | Packet、23 项输入和五个原始源文件的 SHA/字节数匹配；base、tree、status、空 index 与 candidate paths 对齐。 |
| C2 生产差异与 fixture union | **Covered** | 完整阅读五文件全部 patch hunks 与旧 head fixture 差异；PR139 等价关系、拒绝输入、有效版本、既有 smoke 字段、Main App 部署边界及无 `RimeRuntimeProvenance` 均按冻结材料核对。 |
| C3 本轮 CI 适用性与结果 | **Covered with evidence limits** | Receipt 与 binding/candidate 精确关联；21 个步骤均为 attempt 1、exit 0、顺序连续；完整路径分类、计数及六条 focused pass 行核对一致。测试/build 是 executor 记录，不是独立重跑；source closeout 的原始 after-status 字符串未单独打包，状态稳定结论依赖 receipt 的 5/5 closeout 计数及 executor 明确陈述。 |
| C4 历史身份、残项及 AUTH 顺序披露 | **Covered with conditions** | 原 review/Close 仍绑定旧身份与已接受残项；本审查只覆盖整合增量。Executor 明确披露 AUTH 记录顺序事故，本报告保留该边界，不把后续补记说成事前记录。packet 不含单独 timestamped AUTH 原始记录，因此不扩张为对其精确时间线的独立认证。 |

## 五文件差异审查

1. `Packages/RimeBridge/Sources/RimeBridge/RimeDeploymentService.swift`：新增 `RimeDeploymentIdentity.normalizedVersion(from:)`，对 nil、空白和大小写不敏感的 `(no api)` / `(unknown)` fail closed，并保留裁剪后的有效版本；`RimeDeploymentResult` 增加可选版本字段，full-check 还要求 deployment 成功、有效 identity 与现有 `runtimeSmokePassed == true`。既有 runtime smoke 字段和门槛保留。
2. `Packages/RimeBridge/Tests/RimeBridgeTests/RimeEngineContractTests.swift`：覆盖 nil/空白/sentinel 拒绝、有效版本归一化及 maintenance 转发 sentinel 时失败关闭。
3. `Universe Keyboard/Services/SchemaManager+Deployment.swift`：主 App 的 SchemaManager 在标记部署成功前再次要求有效 identity；无 identity 时清除 deployed/deploying、保持 needs-deploy 并返回 false。增量没有把部署移到 Extension。
4. `UniverseKeyboardTests/RimeSettingsStoreTests.swift`：唯一 fixture union；部署替身新增 `librimeVersion`，同时保留 main 已有的 `runtimeSmokePassed`。旧 head delta 显示两项均存在于最终 fixture。
5. `UniverseKeyboardTests/SchemaManagerTests.swift`：新增 nil、blank、(no api)、(unknown) 时保持 pending 的四个用例，并让 stub 成功时提供有效测试版本。

`equivalence.json` 将五个路径中的四个标为与 PR139 字节相同；唯一差异是 `RimeSettingsStoreTests.swift` 的上述 union。Candidate 内容未引入额外路径或 `RimeRuntimeProvenance`。在 packet 所限的静态审查范围内，未见破坏有效版本传递、已有 smoke 条件或 Main App 部署所有权的差异。

## C3：本次 CI 证据

- `execution-receipt.json` 的 run ID 为 `TC2-CI-20261011-F01-FIXEDA44-001`；binding SHA256 与 `binding-original.json` 实际哈希相同，binding 引用的 candidate manifest SHA256 也匹配。receipt 记载五个源路径入口匹配、source closeout 五个路径匹配；executor evidence 记载源哈希及 git 状态前后匹配。
- receipt 内嵌分类将五个改动路径全部列为 `full_required_paths`，`requires_full=true`；分类路径与 candidate 的五路径一致。该结论限于本次 receipt 内嵌的当前适用性记录，本 reviewer 未读取 packet 外的 workflow/classifier 源码。
- 回执记录 21 个步骤全部一次、退出码 0、时间顺序连续且无 stop reason：Xcode/SDK/模拟器入口、whitespace、三项 lightweight、vendor、五文件 strict format、KeyboardCore、RimeBridge、App+Keyboard、单项签名 Keychain、Release build 和三项结果读取。未重试。
- 计数与 summaries 算术一致：KeyboardCore 1207/1207；RimeBridge 112 = 92 passed + 20 skipped；App 417 = 407 passed + 10 skipped；Keyboard 44 passed；默认 Extension 6 passed；签名 Keychain 用例 1 passed；Release `build succeeded`。App+Keyboard summary 合并为 467 = 457 passed + 10 skipped；默认 Keychain 的 skip 与独立签名阶段的 pass 不重复算作通过。跳过总数 30 不计为通过。
- 六个 focused case 在 accounting 列表中全部有对应的 pass line：两项 RimeBridge identity 用例，以及四项 SchemaManager 无 identity pending 用例。这里只确认冻结执行记录及其摘要/通过行，不表示 reviewer 独立重跑。

## Findings 与可复用结论

- **`F01-A44-Q-ID-001` — candidate 身份（通过）**：五源 hash/bytes、base、tree、dirty paths 和空 index 与冻结 candidate 身份匹配。
- **`F01-A44-Q-DELTA-001` — 集成差异（通过）**：四个路径与 PR139 字节相同；唯一测试 fixture 变更合并了 `librimeVersion` 与主线 `runtimeSmokePassed`。本审查范围未见阻断实现缺陷。
- **`F01-A44-Q-CI-001` — 当前候选 CI（executor-recorded）**：本 run 的 binding、完整路径分类、阶段尝试数、摘要计数和六个 focused pass 行相互吻合；跳过项仍是跳过项，不据此宣称 reviewer rerun。
- **`F01-A44-Q-PROV-001` — AUTH 顺序记录边界（保留）**：`executor-evidence.md` 明确说明：Human task authorization 已存在，但 standalone AUTH 记录脚本失败后曾误先执行依赖 patch；之后按实际时间补记、暂停后续动作，不倒填且不声称事前消费。该披露未被本审查抹去。packet 不含 standalone AUTH 原始时间记录，本审查不独立认证更细的时间线，也不把本结论当作其 Product disposition。
- **`F01-A44-Q-HIST-001` — 旧残项保留（条件）**：原 exact-commit review 为 `Pass with conditions`，其复用测试/远端观察限制仍是历史事实；2026-09-19 Close 已接受 `F01-R-01`、`F01-R-02`、`F01-R-03`，其中普通 `RimeEngineImpl` 诊断仍记录 raw bridge version，属于既有 out-of-scope non-goal。本轮没有重开、扩大或清除这些残项。

## 限定与剩余决定

- 结论只适用于固定的 F-01 五路径整合及这次 executor-recorded CI。精确 post-CI git status 原文与独立 AUTH 原始记录不在 packet；相关结论依赖已列明的 executor 摘要/回执字段，已在 C3/C4 保留边界。
- 历史材料记载 PR139 仍为 draft/open/unmerged，父 `TYPO-CORRECTION-002` 仍 Active；这些是冻结历史材料中的状态，不是本审查对 live GitHub 的刷新。
- 不据此作 Product/Gate/Close/Release、merge/publication、整体性能、CPU/UI/内存、native runtime 或新风险接受结论。是否处置 AUTH 顺序记录边界及后续父项生命周期仍由 Human Product Lead 决定；本审查不新增重测、trace、持久化或 UI 要求。
