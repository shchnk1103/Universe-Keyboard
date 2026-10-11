# 固定候选交付证据核对 — Completed（只读）

日期：2026-10-11 Asia/Shanghai。等级：Executor-recorded，非新独立review或可合并结论。

[Assignment](../assignments/typo-correction-002-fixed-candidate-delivery-audit-001.md) / [AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-FIXED-CANDIDATE-DELIVERY-AUDIT-001.md)：Human对上一建议明确“继续”。仅读取本线程S/G/P1工作树与既有私有证据；0源码变更、测试、编译、模拟器、Git发布/main查询。原父[完成盘点](typo-correction-002-parent-closeout-inventory-001.md)的待核对交付项由本回执补齐。

## 1. 可审阅的交付包身份

- S：`/Users/doubleshy0n/.codex/worktrees/int003-query-cost-memory-impl-001/Universe Keyboard`；分支`codex/int003-query-cost-memory-001`。
- HEAD `72dd21710f2a86c9f951d489f645bae89b053b58`，tree `8ce8e8c0d9b821ca4d24aff4faf46a3e49bf87ff`，index为空；保留未提交overlay。
- 当前25路径candidate摘要 `d45bdc9be791aa1654dfde1699a261c34434cd05f68de9456d8102beebd1c2c2`，25/25当前size/hash核对一致。
- 另有3个继承路径，与原P2实施baseline均hash一致：`.github/workflows/swift6-quality.yml`、`KeyboardExtensionTests/CandidatePrefetchUIContractTests.swift`、`Universe Keyboard.xcodeproj/xcshareddata/xcschemes/Universe Keyboard.xcscheme`。
- 因此完整源码交付清单为**28路径**，不能只提交25路径漏掉hostless测试/CI/Scheme关联。完整路径、size/hash、来源、P1/10月9日对应关系见[交付manifest](typo-correction-002-fixed-candidate-delivery-audit-001-manifest.json)。三继承路径未被本次新增、修改或删去。
- 核对前后S状态一致，归档前28文件再核对一致。未fetch/rebase或改默认分支；main更新不自动触发重验。

这是一份供后续交付使用的只读清单，不是当前源码已获commit/push/PR/merge权限。G文档为本线程另一writer，后续发布需明确docs集合与源码集合，不能整体复制所有脏文件。

## 2. P1确已完成有界证据收敛：修正旧镜像产生的待办印象

找到P1专用worktree `int003-ci-72dd-once/Universe Keyboard` 的2026-09-29收敛记录，原件逐字节归档且摘要一致：

- [收敛receipt002原件](typo-correction-002-fixed-candidate-delivery-audit-001-p1-convergence-original.txt)：**Complete bounded Quality evidence coverage with conditions**。
- [Quality004原件](typo-correction-002-fixed-candidate-delivery-audit-001-p1-quality004-original.txt)：R4覆盖run004 Claim2六项criteria；结合有效预算内R2的Claims1/3/4/5，解决Q-R2-01。
- [Quality002原件](typo-correction-002-fixed-candidate-delivery-audit-001-p1-quality002-original.txt)历史Partial保留，不倒写。
- [CI004原件](typo-correction-002-fixed-candidate-delivery-audit-001-p1-ci004-original.txt)：完整本地矩阵已执行，包含三项真实synthetic Rime integration、协调器、签名Keychain及Release。

原已处置限制保持：Q-R2-02 discovered433/result432差异accept；Q-R2-03独立stage oracle为`tech_debt:INT003-COORDINATOR-INDEPENDENT-ORACLE`；Q-R2-04真实setup/schema/get_context失败边界为`tech_debt:INT003-RIME-FAILURE-BOUNDARY`；Q-R2-05组合式覆盖accept。它们不是本次新发现的新必做工作，不从旧IMPL-R1/R2直接推断应重补P1。

原件属于P1旧候选；当前S与原CI004十路径仅3路径相同，不能把旧P1完整矩阵称作本轮28路径全绿。归档内容中的旧相对链接/“P2 unconsumed”是历史原文，现阶段以本回执和现行P2合同为准，不复用旧AUTH。

## 3. 现有验证到底能复用到哪里

| 证据 | 精确身份和覆盖 | 交付适用性 |
|---|---|---|
| P1原完整矩阵/独立收敛 | 固定72dd＋原10路径，R2/R4组合式覆盖 | 原P1结论保留；不当作当前28路径完整矩阵 |
| [10月9日默认/probe/Release验证](typo-correction-002-int003-query-cost-p2-memory-test-number-binding-001.md) | 22路径`d0eb9d1474de…`：Rime90pass/20skip；App默认422pass/10skip；signed Keychain1；probe Extension21；Release成功；Core按206输入核对复用 | 与当前共有22路径中10相同、12已变，详情manifest。Bridge测试类型修正与flag证据保留；不能整体升级当前candidate全CI。skip不算pass |
| [当前限定验证](typo-correction-002-int003-query-cost-p2-route-scope-validation-001.md) | 25路径`d45bdc9be791…`；Core19＋hostless Extension33，52pass/0fail/0skip，含协调器10 | 精确当前scope受支持；不覆盖完整Core/Bridge/App/Keychain/Release矩阵 |
| [route独立增量审查](../reviews/TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-REVIEW-001-closeout-r1.md)、[Architecture计数closure](../reviews/TYPO-CORRECTION-002-INT003-QUERY-COST-P2-EVIDENCE-RECONCILIATION-001-closeout-r2.md)、[Quality剩余closure](../reviews/TYPO-CORRECTION-002-INT003-QUERY-COST-P2-QUALITY-REMAINDER-001-closeout-r3.md) | 同25路径；唯一34→33证据字段修正已闭合；源码/测试不重跑 | 当前route增量与证据计数已有结论，不为交付重开整轮架构审查 |
| [正常DEBUG包](typo-correction-002-int003-query-cost-p2-route-payload-001.md)、[安装78文件](typo-correction-002-int003-query-cost-p2-route-install-001.md)、[冻结导出](typo-correction-002-int003-query-cost-p2-partial-export-001.md)和[Run独立审查](../reviews/TYPO-CORRECTION-002-INT003-QUERY-COST-P2-REVIEW-DELIVERY-001-closeout-r2.md) | 实际同candidate/current payload，7闭合sequence、61provider calls | 当前限定P2已接受，不再采集；不作为默认Release性能或产品候选恢复证明 |

仅重新要求交付并不使现存证据失效；真正缺口是**最终内容与完整门禁不相同**。输入fixture重复不是当前门禁缺口。条件编译静态投影一致不能替代真实Release编译；当前源码还含工作流改动，依AGENTS/CI分类规则，预期合并前需完整本地路径与hosted证据，不采用docs-only豁免。

## 4. Registry / benchmark /产品验收映射（不改原Registry状态）

| 身份 | 当前源/既有结果索引 | 边界 |
|---|---|---|
| legacy v1 | `TYPO_BENCHMARK_REGISTRY.md` / `TYPO_BENCHMARK.md`；Core `TypoCorrectionTests` normal/single-edit回归 | v1文档列unsupported不等于V2失败；本次不重跑或覆写Registry |
| TC2-STB001/002 | V2 Registry STB001–003；`testContextualEngineSkipsShortAndOversizedCompositions`、`testContextualEngineBuildsBoundedTwoErrorSentenceHypotheses`、`testContextualMultiEditSentenceIsDisplayOnly`、`testRankerDoesNotPromoteLowConfidenceMultiEditCorrection` | Core结构/排名测试；不替代真实目标句恢复 |
| TC2-EXP001–004 | V2 Registry；`testProgressiveRecallPlanContainsSeparatedTwoErrorCorrection` / `testProgressiveRecallPlanKeepsHypothesesAndBatchesBounded` / `testProgressiveRecallPlanPreservesInputLengthBoundary` | default-off preflight/有界hypothesis，不当语义Product Pass |
| TC2-INT001 / INT002 / INT003 | Core `testControllerUsesDedicatedQueryForContextualRecovery`；真实sidecar历史bounded review；当前协调器10例；Sept23 stale-cancel Capture及独立reviews | 每份结果维持source/Run边界。180ms是调度设计常量，Human手动按键<180ms通过条件已撤去，不能重新加入 |
| TC2-QA001 | [reval08](typo-correction-002-sim-run-2026-09-22-qa001-reval-08-target-observed.md) / [Quality](../reviews/typo-correction-002-sim-run-2026-09-22-qa001-reval-08-quality-review.md) / 子Closed | 指定17ProMax iOS27 Ice目标句Human可见/可选；不是当前405D Luna成本Run；不要求因为本轮P2再采同一句 |
| TC2性能退出 | 原跨进程配对inconclusive；限定P2 provider elapsed已接受 | 父性能范围仍需单独决定；不由P2结果自动替代 |

当前Registry表还保留早期Pending/Skipped字样，而后续Run已发生。此为**交付文档状态映射事项**：后续授权的发布包应以原Run/review/子Close来源更新有限状态，保留Human-attested/bounded措辞，不升级为父Product Gate。当前audit只给映射，不改其权威状态。

## 5. 剩余最小工作与建议

1. **固定最终交付候选的一次CI验证方案**：基于本28路径manifest，先拟明确命令、覆盖、环境及首失败停止的独立Assignment/AUTH。发布前Swift23路径须按目标分支差异format/lint硬门槛；完整本地门禁按实际工作流顺序，不能只用52测试。方案阶段不操作设备；执行前另确认模拟器独占。不因main更新无限重试；最终候选/baseline发生相关变化才做影响判断并由新AUTH限定后续。
2. **父性能范围决策**：Human可另批准继续一个最小明确比较，或明确接受/收窄原性能合同。此处仅列待决，不推定已豁免。无需现在恢复大trace、存储/UI或重做P2。
3. 上述完成后做源码/docs交付（含Registry有限状态同步），再单独取得commit/push/PR、merge及父Gate/Close各阶段权限。现有route架构和Run审查不为纯交付重新审一遍；若新增语义变更才另评范围。

本次有明确结束点：只读交付核对完成。**没有新技术故障**；发布就绪缺口为当前最终完整门禁/hosted证据，父关闭另受性能范围未决约束。原P1不是待重做，限定P2不是待重采。源码与私有raw/原审查checkpoint仍有复用价值，未清理唯一证据。

CHANGELOG/架构：本次无源码变动，不修改；后续源码交付应说明DEBUG取证能力和既有合同边界，是否记录CHANGELOG按最终发布范围判断，不自动Accept ADR。
