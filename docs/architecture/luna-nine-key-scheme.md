# 朙月九宫格（luna_pinyin_t9）知识卡

写于 2026-11-08，依据 LUNA-PLANNER-001（PR #279，main `38c3930d`）与 LUNA-T9-001 的 PR1 取证。本页只记已验证的事实、已定的决定和未决项；细节与证据在任务报告里（见文末“证据位置”）。目标读者：以后做朙月九宫格 PR2、雾凇或万象九宫格，以及“键盘自有适配层”的人。

## 1. 它是什么
- 朙月九宫格不是一份独立发布的方案：运行时的 `luna_pinyin_t9` 由内置 `luna_pinyin.schema.yaml` 经 `LunaT9SchemaCompatibility`（`Packages/KeyboardCore`）确定性改写得到，改写输出的 SHA-256 记在 `outputSHA256` 常量里，仓库夹具 `Packages/RimeBridge/Tests/RimeBridgeTests/Fixtures/LunaT9/variant1.schema.yaml` 必须与改写输出逐字节相同。确定性改写对未知源、缺失或重复锚点及输出哈希不匹配失败关闭；grammar 存在时由 planner 的简繁与 algebra 闸门拒绝放行。
- 状态（2026-11-08）：生产 planner 已能为 `luna_pinyin_t9` 生成简繁、模糊音与学习的覆盖；九宫格功能本身未接线（未在 `NineKeySchemeRegistry` 登记，没有设置与键盘入口）。接线属 LUNA-T9 的 PR2。

## 2. 补丁链与 planner（PR #279 的结论）
- 旧隔离诊断中，九键 schema 的顶层 patch 未显式消费 luna_pinyin_t9.custom，实验的学习键和对照键未进入编译结果；追加第三项 luna_pinyin_t9.custom:/patch? 后该实验的对照键进入编译结果。朙月 26 键仍是两项；当前确定性重写、夹具与 outputSHA256 绑定。
- planner 对九键简繁 reset 与 algebra 的放行要求 compileInputProven 为真、源 SHA 与重写输出一致且无 grammar；放行后生成相应 reset 与受控 algebra。学习键另按现有 planner 规则生成，不应把上述三项条件概括为所有学习覆盖的共同闸门。
- 学习开关失败曾归为“L4”：隐式的 `luna_pinyin_t9.custom` 不进补丁链，显式引用后才生效。
- 测试证据路径：LUNA 合同测试通过 LunaT9EvidenceRoot 管理运行证据（环境变量 LUNA_T9_EVIDENCE_ROOT，缺省为唯一临时根）；依赖本机绝对路径的实际读写在 CI 环境可能无法访问，应核对目标环境并验证。

## 3. 真引擎事实（PR1 D 段与探针，librime 1.16.1）
- 六个样本 6、44、444444、64、6446、94664 在真引擎上的首选与退格结果：64 → 你，6446 → 你功能（繁体窗口含“你好嗎”，简体含“你好吗”），94664 → 中；退格后 raw 依次为 空、4、44444、6、644、9466。引擎自己的 preedit 是数字分组（如 `64 4 6`）。
- D 段和隔离探针所记录的候选窗口中，未加 spelling_hints 的 comment 均为空；D 段 6446 的现有 smoke 评价因此失败。有限窗口不能证明所有输入或候选均为空。
- 隔离探针中，只添加 spelling_hints（8 或 100）后，观测窗口的 comment 呈小写拼音，观测值由 validatedSource 接受，6446 的 smoke 评价为真。探针未叠加 overlay；模糊音下 comment 的语义尚未验证。
- 用户可见组字（`T9PreeditResolver`）：先看完整覆盖的 Path，其次高亮或首候选的合格 comment，最后只显示显式字母；仅输入数字且无 comment 时为空串。smoke 通过不等于可见组字非空。
- `NineKeySchemeRegistry.entries` 是 `static let`，不能在测试里注入新 ID；生产参数化 `RimeT9SmokeProbe.verify` 对未登记 ID 失败关闭。
- 版本：客户端 Vendor/receipt 当前固定为 `rime-vendor-ios-1.16.1-lua.1-octagram.1`（librime 1.16.1 + lua + octagram）；三方案在仓库定义中共用同一 RimeBridge/Vendor 与部署路径，尚无三方案同一会话的运行时版本/插件加载日志。`RimeBuiltin.manifest.json` 的 `generators.rimeDeployer.version = "librime 1.17.0 (Homebrew 1.17.0_2)"` 仅记录离线预生成内置 RimeBuiltin 资源（朙月、笔画等）的生成器版本，不是客户端运行时版本，也不证明雾凇/万象生成器身份；4e 前置门仍未完全关闭。

## 4. 已定与待定的决定（2026-11-08 历史快照）

> 本节“仍须验证/待做”为当时快照，不作为当前逐项未关闭清单。2026-11-15 的 A9 取证、更正与处置见第7–9节；未在冻结来源中逐项判定的旧事项，本页不自行声称完成。
- 已定：采用方案 A，为派生变体加入 spelling_hints，R6 修订固定 N=8，产生新的重写输出与 outputSHA256；实现和性能对照仍须验证。设计补充 R6 经第二轮独立 Architecture 审查通过。
- 已定：PR1 保留参数化入口的正反例阻断；缝是 `RimeT9SmokeProbe.verify` 的测试可见重载，接受不可变登记快照，生产公开入口只用真实 entries，`entries` 保持 `static let`。
- 待定/待做：N=8 的实现验证与每键延迟对比（朙月旧值、8、雾凇，同条件）；模糊音与简繁叠加下的 comment 语义；Path 与 controller 的真实 fake-host 实测；旧部署目录升级与失败回退；雾凇与万象的内置资源闭包和三家回归仍须在 PR1 核验；缺 fixture 或证据时记未验证并阻断 PR2。
- Human 已定（2026-11-05）：朙月、雾凇、万象必须完整支持，输入缺口不得称“已知限制”。

## 5. 给后来者的提醒
- 做任何九宫格方案前先核对 comment 的来源：它可作为 Path 排序提示，也可成为可见组字来源；Path 的合法性由本地目录决定，空 comment 不妨碍产生合法路径。
- 新方案接入要三件事同时成立：确定性改写（失败关闭）、planner 放行条件、smoke 与可见组字的独立断言。
- 不要把“smoke 通过”当成“用户看得到拼音”。

## 6. 证据位置
任务报告在 PM 的外置工作目录（不在仓库）：LUNA-PLANNER-IMPL-001（planner 设计补充与审查、质量与门禁）、LUNA-T9-001（设计 R1–R5、Architecture 审查、PR1 各段）、LUNA-T9-PR1-D（D 段取证、设计补充 R6 与审查）、LUNA-T9-SPIKE-HINTS（拼写提示探针）。代码入口：`Packages/KeyboardCore/Sources/KeyboardCore/LunaT9SchemaCompatibility.swift`、`Packages/RimeBridge/Sources/RimeBridge/LunaT9DeploymentSupport.swift`、`RimeConfigManager+CustomYaml.swift`、`RimeT9SmokeProbe.swift`；`Packages/KeyboardCore/Sources/KeyboardCore/T9PreeditResolver.swift`、`NineKeySchemeRegistry.swift`、`SchemaSwitchResolver.swift`。


## 7. PR1 未关闭项与本次取证状态（A9，2026-11-15 UTC+8）

这是冻结来源的历史取证快照（Executor-recorded），不是本轮重跑、全量验证或 PR1 合并许可。
A9-M 在 `d7471e8c8b755f9bc5043731708a3795ed54d18c` 取得七步结果；其步骤4失败由 A9-F 的新结果更新，不能用新步骤4外推其它步骤也已在新HEAD重跑。

| 项 | 取证事实与边界 |
|---|---|
| 4c | 无运行时“开启写入、关闭不写”的双向证据；现有仅编译配置证据。`LunaT9CompileInputContractTests` 检查 `translator/enable_user_dict`，compiled learning key 仍记已知失败。 |
| 4e | 本次未比较朙月、雾凇、万象的运行库或生成器身份差异，结论为无法确定。 |
| RimeT9* | A9-M 实测跳过25项，不是历史18：S4提交1、T9 Spike目录16、兼容Spike目录1、矩阵夹具未配置7；本包未配置或补跑。跳过不等于通过，处置归属见第8节。 |
| A9-F | 未配置证据根时自行跳过；定向绿灯1项、1跳过、0失败、EXIT 0，原文 `LUNA_T9_EVIDENCE_ROOT not set`。步骤4为173项、29跳过、0失败、EXIT 0（RimeT9*跳过25）。已设置证据根分支未运行，仅静态确认原断言保留，不扩写为旧根因已全部消除。 |

A9-F 提交 `410f4e62b7ea273b9032b68c83ecd02edf168d00` 只改一个测试文件（3增1减）；其他门禁是此前 `d7471e8` 上取得。本轮仅写文档。

A9-G 在不含 `LUNA_T9_*`、`TEST_RUNNER_LUNA_T9_*`、`WANXIANG_T9*`、`TEST_RUNNER_WANXIANG_T9*` 的条件下实测 RimeBridgeTests：173 项、32 跳过、0 失败、EXIT 0。`LunaT9RelaxedLatencyTests.testRelaxedLatencyAndCompileCost` 在 `LUNA_T9_ICE_FIXTURE` 未设置时跳过，`LunaT9UpgradeRollbackTests.testUpgradeAndFailureIsolation` 在 `LUNA_T9_OLD_VARIANT_PATH` 未设置时跳过，`SchemeT9ContractObservationTests` 在 `LUNA_T9_EVIDENCE_ROOT` 未设置时跳过。同次日志里 `WanxiangT9SwitchTargetTests` 因 `WANXIANG_T9I_SOURCE` 未设置沿用原有跳过，本次 diff 未改它。托管 CI 不提供这些变量，所以上述测试在托管 CI 上不运行；跳过不等于通过，其结果只来自本地带夹具的运行。已设置变量的分支本次未运行，diff 只把未设置分支改为跳过。

### 5c 更正与逐点映射

按更正报告 `executor-report-m5c-r1.md`：`Point` 实际15点，A9-M所写16为误数，逐点方法映射已更正，计数问题已澄清，不是未解决的来源冲突。只证明静态引用与方法级日志结果，不证明各注入断言语义充分；不据此声称 PR1 可合并。

引用均在 `LunaT9DeploymentContractTests.swift`。方法 A=`testEveryForwardFailureRestoresBytesOrNonexistenceThenRedeploys`（:46，日志 37348 passed）；B=`testRollbackFailureSurvivesOuterBoundaryAndRetainsRecoverableBackups`（:88，日志 37411 passed）；C=`testMultipleRollbackFailuresRemainExplicit`（:143，日志 37394 passed）。

| 注入点 | 引用与源码行 | 日志 |
|---|---|---|
| backupResources | A:48 | 37348 passed |
| backupSource | A:48 | 37348 passed |
| backupOverlays | A:48 | 37348 passed |
| backupReceipts | A:48 | 37348 passed |
| resourceWrite | A:49、A:60 | 37348 passed |
| resourceReceiptWrite | A:49 | 37348 passed |
| sourceWrite | A:49 | 37348 passed |
| sourceReplace | A:49 | 37348 passed |
| overlayWrite | A:50、A:60 | 37348 passed |
| overlayReplace | A:50、A:60 | 37348 passed |
| overlayReceiptWrite | A:50 | 37348 passed |
| cacheDelete | A:50、A:60；B:93；C:146 | 37348、37411、37394 passed |
| restoreSource | B:89、B:93；C:146、C:153 | 37411、37394 passed |
| restoreOverlay | B:89、B:93；C:146、C:153 | 37411、37394 passed |
| restoreResources | B:89、B:124；C:146、C:153 | 37411、37394 passed |

## 7.1 PR1 合并回执（2026-11-18）

- PR #304 已合并，合并提交 `2277d0d3a7fac6d471f312623d91708a1943d441`，已并入 `main`（本次文档基线 `bdf1544db317840691ed8b2b8f9f84e5f2676cd2`）。本节只更新合并状态，不改变第 7 节 A9 历史快照的取证边界。
- `NineKeySchemeRegistry.entries` 仍只登记 `t9` 与 `wanxiang_t9i`，生产运行时未接线 `luna_pinyin_t9`；第 8 节 4c/4e 与第 9 节七项 PR2 前置门原文不变。
- PR2（生产接线、第 9 节七门与 4c/4e）待立项；本档案不表示 PR2 已验证或可合并。

## 8. 本次处置新增的 PR2 前置门与 PR1 排除项

来源是 PM-LOG/pr1-open-items-disposition-20261115.md，不是下节设计裁决：Human 对三项原话“这三项可以由你来决定”，以下原文为 Human 委托 PM 的决定：

1. RimeT9* 25 个条件跳过：明确排除出 PR1 回归门禁（A9-M 包已记录 Human 此前决定其不属于 PR1 回归门禁）；PR 描述写明仍跳过、不称已验证。
2. 4c 学习开启写入/关闭不写的运行时双向证据：PR1 无生产接线，移为 PR2 前置门；PR 描述写明 PR1 仅有编译配置证据。
3. 4e 朙月/雾凇/万象运行库身份对照：同上移为 PR2 前置门；PR 描述写明现状“无法确定”。
4. 以上处置只代表 PM 在 Human 委托下的决定，Human 随时可改；PR 描述须如实写“未验证项”，不得写“全部验证”。

因此4c、4e移为本次处置新增的 PR2 前置门，仍未验证；25个 RimeT9* 条件跳过明确排除出 PR1 回归门禁，不是变成通过，也不是转为 PR2 项。对三项不再沿用未经处置时 PR1 合并前补齐的旧要求。

## 9. 既有 PR2 生产接线前置门（独立来源）

来源：LUNA-T9-PR1-COVERAGE/reports/design-pr1-coverage.md 第3节。以下为原文，不与第8节本次4c/4e处置混为同一来源：

「PR2 合并前置门（来源 LUNA-T9-PR1-COVERAGE 设计裁决）：在 `NineKeySchemeRegistry.entries` 真实登记 `luna_pinyin_t9` 的同一提交上，经生产路径取得以下证据，并由独立质量复核核对。取证不得经测试快照、`NineKeyPublishSmoke.override` 或 `selectAndConfirmHook`。任一项失败、跳过、缺 fixture 或只能靠测试缝取得，PR2 不得合并：(1) 生产 `RimeT9SmokeProbe.verify` 对 `luna_pinyin_t9`/`6446` 为真；readiness 由启用编排与 `publishIndependentNineKeyReadiness` 写入，并按 `luna_pinyin_t9.schema.yaml` 指纹与 compatibilityVersion 匹配；源变化或 smoke 失败时不发布 ready。(2) `schemeBinding9` 经设置入口写入并读回；未就绪时不写入。(3) 扩展经 `RimeRuntimeSelectionBridge` 解析，`luna_pinyin_t9` 被 librime 实际选中；`reconciled` 后九键 chrome 与 T9 语义一致；朙月 26 键与九键往返切换后共享用户词典不丢失。(4) schema 与 overlay 由生产编排生成，字节与 `outputSHA256` 一致。(5) 设置页与键盘的可见状态与 readiness 一致；失败时不以九键外观冒充可输入。(6) R6 §5 的旧目录拒绝、新源重部署、逐项失败注入与恢复在生产编排上复验，记录不可用时段；恢复到经验证可用的字母方案，或明确标为不可用。(7) 雾凇 `t9`、万象 `wanxiang_t9i` 的 marker、binding 与扩展路由回归不变。」

## 10. A9 来源与重验边界

外置根为 `~/.kos-work/Universe-Keyboard/`；文中行号只适用于来源冻结提交，代码变化后必须重验，链接检查不验证行锚点或外链可达。原始运行命令/环境与日志见各报告，不把模拟器证据提升为真机或生产接线证明。

| 来源（外置，不入库） | SHA-256 |
|---|---|
| LUNA-T9-A9/reports/executor-report-measure.md | 8652bfbe21ab053d4bd90116c0c58c2285ac0110df6142f4c2009e66f45dc6c0 |
| LUNA-T9-A9/reports/executor-report-fix-r4.md | c206def62ce05c6d788feebfd50512fc516bed793e6c89014caa337dac9c593e |
| LUNA-T9-A9/reports/executor-report-m5c-r1.md | bccc32aaa19b2f8e4b8e8069a00daa823ac1100673d2aae2e36542de93ec6339 |
| PM-LOG/pr1-open-items-disposition-20261115.md | 1d546f68c16a0a9d762686ac8eed02f7986f941ddc02b02de1217f1a16671360 |
| LUNA-T9-PR1-COVERAGE/reports/design-pr1-coverage.md | 9d2f3be0fd889b2ef48074b1e5a7d98a063ea8f5c8f357c5d4c1d216cc457350 |

## 11. PR2 生产接线（本提交事实，不是真机验收）

- `NineKeySchemeRegistry.entries` 登记第三项 `luna_pinyin_t9`（family `luna_pinyin`，marker `rime_luna_t9_readiness_marker`，compatibilityVersion `1`）。读写与失效只经 registry / `NineKeyReadiness`。雾凇 `t9` 与万象 `wanxiang_t9i` 的 marker 键不复用。
- 唯一写盘在 `RimeBuiltinResourceInstaller` 的 `afterInstallingResources` 里：`LunaT9ProductionDeploymentSupport.commitInInstallerCallback` 备份 derived schema、物化、再 `syncCustomYamlFiles`。任一步失败先还原 derived（原先没有则删除）再抛出。`default.custom.yaml` 总是列入 `luna_pinyin`；`luna_pinyin_t9` 仅在 registry 有项、derived 文件存在且 SHA 等于 `LunaT9SchemaCompatibility.outputSHA256` 时列入。
- 启用前 `validateSourceBeforeEnable` 只校验不写盘。已存在但 SHA 不符即失败。物化前删除 `build/luna_pinyin_t9*`，不删 `luna_pinyin.*`、`t9.*`、`wanxiang_t9i.*`。
- 雾凇与万象生成器 provenance：不适用（现场编译与外部归档）。见 `diag-luna-t9-4e-r1.md`。
- 真机 M1–M5 与 4e M4 同会话运行时观测仍待 Human 执行。本页不声称真机验收已完成。
