# Quality 独立增量复审 — Changes requested

> 发布展示副本：仅将历史临时绝对路径链接改为文字。审查原件逐字节保存在[TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-REVIEW-001-quality-review-r1.original.txt](TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-REVIEW-001-quality-review-r1.original.txt)，SHA256 `20aeb7aee13a7a1b42bab37ad2e57d0ec784c9767486304aa5ea028b9ee7904b`；结论/计数/范围不变。旧manifest中的报告哈希应核对该原件，不能核对展示副本。

- Work item：`TYPO-CORRECTION-002-INT003-QUERY-COST-P2-ROUTE-SCOPE-REVIEW-001`，round 1
- Candidate：`d45bdc9be791aa1654dfde1699a261c34434cd05f68de9456d8102beebd1c2c2`
- 范围：10 个 Swift 源路径及私有 arm v2 decoder 的静态增量、Core 19 / Extension 33 测试证据。未运行测试、build、decoder、设备、LLDB 或网络操作。
- 结论：**Changes requested**，原因仅为一处执行绑定计数与实际 Extension 测试数不一致。没有发现已证实的 route 源码安全/正确性缺陷；这也不等于完整 CI、runtime arm、P2 或 Gate 通过。

## Evidence matrix

| Criterion | 结论 | 核对结果 |
|---|---|---|
| Q1：逐套测试与 source、日志、receipt、summary、命令、candidate 对应；宏和 membership | **Changes requested — F1** | 19 + 8 + 15 + 10 个实际 XCTest 方法逐套与 source 名称及 raw logs 对上，合计 52。命令、receipt、summary、覆盖记录和候选 SHA 对上；但 execution binding 的 `expected_extension_tests` 写 34，与其余证据的 33 冲突。 |
| Q2：双 scope、身份变化/失效、unsupported、v2 codec 正反例 | **Pass（限定静态/测试证据）** | Core 与 Extension 测试包含 provider/native scope、有效与拒绝准入、facade/lifetime/schema/kind 变化失效、unsupported 及 v2 正反解码；私有 Python arm decoder 按同一 v2 字段/边界静态比对。它没有作为 52 项测试实际运行，本复审也未执行它。 |
| Q3：测试与真实 controller/helper 调用链差异及结论边界 | **Pass（声明受限）** | coordinator 测试经 test host 与 synthetic probe，host 返回固定 native facade scope；不会覆盖 KeyboardViewController 的真实 route 观察实现。证据明确排除真实用户 route/arm 与运行采集，所以此差异没有被说成 runtime 证明。未运行 runtime 本身不作为代码失败。 |
| Q4：格式、源码 hash、证据来源和 Executor 声明 | **Changes requested — F1** | packet 与 94 个输入 SHA-256 全匹配；candidate 的 25/25 source hash 对上冻结 source；10 个 delta 路径与 format receipt 路径相同，format/lint receipt 均 exit 0；归档子文件 hash 一致。Executor 将 implementation 的 0 test/build 与后续单独的限定测试分开，且正确排除 full CI、Release、真实 route/arm、P2、Gate。F1 的 stale 计数仍需修正。 |

## Finding F1 — Extension 预期数与实际数冲突

冻结的 validation/execution-binding.json（历史路径 `/private/tmp/uk-routerev1/validation/execution-binding.json:71`） 写 `expected_extension_tests: 34`。但 validation/coverage.json（历史路径 `/private/tmp/uk-routerev1/validation/coverage.json:17`） 对三个被选 Extension suites 分别列 8、15、10，即 33；validation/extension-summary.json（历史路径 `/private/tmp/uk-routerev1/validation/extension-summary.json:48`） 也列总数 33；raw log 的 selected tests 最终为 33（extension.stdout（历史路径 `/private/tmp/uk-routerev1/validation/extension.stdout:2197`））。回执正文同时报告 hostless Extension 33、共 52（validation evidence（历史路径 `/private/tmp/uk-routerev1/governance/docs/evidence/typo-correction-002-int003-query-cost-p2-route-scope-validation-001.md:5`）），但其嵌入的执行绑定再次列 34（validation evidence（历史路径 `/private/tmp/uk-routerev1/governance/docs/evidence/typo-correction-002-int003-query-cost-p2-route-scope-validation-001.md:104`））。

实际日志仍支持 Core 19 + Extension 33 = 52 passed、0 failed/skip；因此该问题不证明测试未通过，也不抹去已匹配的 52 个测试名。它使固定执行绑定与测试回执不能完全一致。请将预期数修正为 33，或提供确实被该命令选中的第 34 个测试及其 raw-log 证据，并重新冻结更正后的验证记录。此复审未改动冻结输入。

## 关键覆盖依据与边界

- provider scope 的 ready、valid、Luna、稳定 epoch 正反例及身份组件变化/失效见 QueryCostMemoryProbeTests.swift（历史路径 `/private/tmp/uk-routerev1/source/Packages/KeyboardCore/Tests/KeyboardCoreTests/QueryCostMemoryProbeTests.swift:52`） 和 QueryCostMemoryProbeTests.swift（历史路径 `/private/tmp/uk-routerev1/source/Packages/KeyboardCore/Tests/KeyboardCoreTests/QueryCostMemoryProbeTests.swift:92`）；unsupported / 缺身份拒绝见同文件 第 114 行（历史路径 `/private/tmp/uk-routerev1/source/Packages/KeyboardCore/Tests/KeyboardCoreTests/QueryCostMemoryProbeTests.swift:114`）。Strict cost v2 decoder 正反例见 第 351 行（历史路径 `/private/tmp/uk-routerev1/source/Packages/KeyboardCore/Tests/KeyboardCoreTests/QueryCostMemoryProbeTests.swift:351`）。
- Arm v2 provider scope 和不合法 wire 正反例见 QueryCostArmDiagnosticTests.swift（历史路径 `/private/tmp/uk-routerev1/source/KeyboardExtensionTests/QueryCostArmDiagnosticTests.swift:7`）、第 28 行（历史路径 `/private/tmp/uk-routerev1/source/KeyboardExtensionTests/QueryCostArmDiagnosticTests.swift:28`） 和 第 124 行（历史路径 `/private/tmp/uk-routerev1/source/KeyboardExtensionTests/QueryCostArmDiagnosticTests.swift:124`）。逐套 raw passed 数见 core.stdout（历史路径 `/private/tmp/uk-routerev1/validation/core.stdout:43`）、extension.stdout（历史路径 `/private/tmp/uk-routerev1/validation/extension.stdout:2137`）、extension.stdout（历史路径 `/private/tmp/uk-routerev1/validation/extension.stdout:2170`）、extension.stdout（历史路径 `/private/tmp/uk-routerev1/validation/extension.stdout:2193`）。
- 当前实际 controller 的 route observer 静态实现见 KeyboardViewController+TypoCorrection.swift（历史路径 `/private/tmp/uk-routerev1/source/Keyboard/Controllers/KeyboardViewController+TypoCorrection.swift:90`）；coordinator 在 facade 前后复核 scope 的调用点见 TypoCorrectionRecallCoordinator.swift（历史路径 `/private/tmp/uk-routerev1/source/Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift:291`） 与 第 335 行（历史路径 `/private/tmp/uk-routerev1/source/Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift:335`）。Extension coordinator 测试 host 固定返回 native facade 值，见 TypoCorrectionRecallCoordinatorIntegrationTests.swift（历史路径 `/private/tmp/uk-routerev1/source/KeyboardExtensionTests/TypoCorrectionRecallCoordinatorIntegrationTests.swift:459`）。因此测试验证的是 coordinator/probe 合作，不是实际 controller route 分支。
- 测试项目配置将 `KeyboardExtensionTests` 作为 `TEST_HOST = ""` 的 Debug hostless target，且将测试注入宏限定于该 target（project.pbxproj（历史路径 `/private/tmp/uk-routerev1/source/Universe Keyboard.xcodeproj/project.pbxproj:1147`））；执行命令另外显式启用 probe 宏，见 execution-binding.json（历史路径 `/private/tmp/uk-routerev1/validation/execution-binding.json:23`）。
- 证据明确把测试、runtime 与 Gate 分开：validation evidence（历史路径 `/private/tmp/uk-routerev1/governance/docs/evidence/typo-correction-002-int003-query-cost-p2-route-scope-validation-001.md:5`） 及 第 131 行（历史路径 `/private/tmp/uk-routerev1/governance/docs/evidence/typo-correction-002-int003-query-cost-p2-route-scope-validation-001.md:131`） 排除实际用户 route/arm、P2、Gate、完整 CI、Release、安装与手动输入；implementation evidence（历史路径 `/private/tmp/uk-routerev1/governance/docs/evidence/typo-correction-002-int003-query-cost-p2-route-scope-implementation-001.md:28`） 记录实施阶段没有运行 tests/build。没有将这些未运行事项单独判为本轮代码失败。

## 计时更正记录

先前草稿错误复用了另一轮 `13:15:07Z` 起点并报告 6,815 秒。按协调器确认的本轮原始起点 `2026-10-10T15:07:46Z` / monotonic `1731750.232498041` 重新计算，本报告记录的 elapsed 为 monotonic 累计值；之前的超预算停止结论已被本报告更正并取代。完整计时及经过保留在 usage JSON。
