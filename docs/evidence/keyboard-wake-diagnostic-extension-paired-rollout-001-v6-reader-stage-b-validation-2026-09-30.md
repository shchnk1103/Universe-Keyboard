# Stage B verification / partial independent review

2026-09-30 Asia/Shanghai。自动验证已完成；Stage B独立评审尚未收齐。Assignment与parent保持Active；生产writer5/marker off。

## Identity / authorization

[Stage B Authorization](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-v6-reader-stage-b-authorization-2026-09-30.md)、[Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-b-entry-2026-09-30.md)、[finalcandidate](keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-b-candidate-r2.json)（SHA2565b2ced9d3a8220357c603bd9e5c2236837c51a8200e28980d73fceee8c5bf21c）、[evidenceindex](keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-b-evidence-index.json)。仍为指定worktree，branch codex/keyboard-wake-v3-compatibility-gate HEAD84b9c19227330b0fe6ff391be001ee398010fd6a。

Stage B只在原Stage A第五文件新增临时fixture目录创建，修复真实target发现的fixture错误；其他四文件/七readonlydependencies未改。保留原StageA manifest和首轮失败身份，不把旧App测试hash重标为最终证据。2340既有文件中仅该App测试和owningAssignment改变，其他2338hash保留；新增仅StageB授权/Entry/evidence。没有Git stage/reset/clean/switch/commit/push。

## Automated evidence matrix

| Check | Total | Passed | Skipped | Failed | Evidence |
|---|---:|---:|---:|---:|---|
| KeyboardCore host (复用最终StageA exactCore) | 1181 | 1181 | 0 | 0 | StageA final host log；Coreinputs/dependencies/toolchain未变 |
| RimeBridgeTests Simulator | 105 | 85 | 20 | 0 | RimeBridgeTests log/xcresult/legacy/tree |
| App + Keyboard Debug Simulator r2 | 429 | 419 | 10 | 0 | AppKeyboardTests-r2 log/xcresult/legacy/tree |
| 新v6 composite query focused r2 | 1 | 1 | 0 | 0 | AppV6Focused-r2；同用例也包含在429中，不重复累计 |
| Signed Keychain focused r2 | 1 | 1 | 0 | 0 | SignedKeychain-r2 log/xcresult/legacy/tree |
| Release configuration build r2 | — | build exit0 | — | 0 | ReleaseBuild-r2 log/xcresult |

七个candidateSwift文件strictlint通过（第五文件fix后format/lint及r2七文件strictlint）；所有命令/时间/exit记录于matrix-results/matrix-results-r2。四项Simulator最终gate退出0。CLI严格并发/警告flags与当前AGENTS/CI对齐；指定UDID、paralleltestingNO、maximumdestination1、独立DerivedData。r2关闭失败verbose diagnostics（-collect-test-diagnostics never），不改变用例/断言/覆盖。

环境：Xcode27.0 build27A266a / AppleSwift6.4 swiftlang-6.4.0.34.1 clang-2100.3.34.1 / iPhone18Pro iOS27.0 UDID405D994F-28CB-4F89-BB22-B64AD81C05A2。独占窗口由Human本次确认，从Entry至测试构建结束；现在自动验证结束不再占用窗口，未shutdown/erase设备或手工安装promotion。test-runner自动安装/启动仅为本次test范围。

新query用例五场景实际通过；完整App数量429是历史v5 raw428之外新增1个测试，历史429 discovery差异及428接受原样保留，本次没有count-only重跑。

## Retained failure / remediation

第一轮新App用例因prepareRoot仅生成control、未生成g1/open，rawfixture atomicwrite抛NSCocoaError4；该轮其他测试输出保留。失败后xcodebuild诊断收尾无新日志，root仅对本任务PID97138发SIGINT后SIGTERM，最终exit-15，不能算通过。随后仅授权测试文件创建临时目录，focused1通过再fullApp429通过。首轮结果bundle标为中断/部分证据；最终r2结果为通过证据。旧收尾与新focused launcher有短暂进程交叠，旧用例已结束；不能称全程无进程交叠。

## Independent review / residuals

[Quality review](keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-b-quality-review.md)、[usage](keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-b-quality-usage.json)为未参与实现GPT6Luna独立结论，原文保存，不由root改判。其最终消息澄清Q3未独立遍历底层legacy/test-tree；按冻结packet必需条件，Q3记为未覆盖，不能据报告Covered行推定完整核验。另设备可用性/Release配置/两项CS0910原因的文字偏差见[Coordinator qualifications](keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-b-coordinator-review-qualifications.md)。
[Architecture R1](keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-b-architecture-review.md)/[R2](keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-b-architecture-review-r2.md)均Partial：R1packet遗漏绝对root导致误核主检出，非候选漂移；R2只覆盖AS1，AS2-AS6未覆盖且原累计14tool预算耗尽。不能称Architecture通过或由Quality替代。

| Residual | Owner / authority | Current disposition |
|---|---|---|
| B-ARCH-001 AS2–AS6补审 | Architecture lane；Human Product Owner批准新增预算 | pending；[最小R3补审请求](keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-b-architecture-r3-completion-request.md)：仅这5criteria，新增20tools/15minutes；未派发/未自行续期 |
| B-QUAL-001 Q3底层结构独立核验及报告文字修正 | Quality lane；Human Product Owner批准新增预算 | pending；[最小Quality R2请求](keyboard-wake-diagnostic-extension-paired-rollout-001-v6-reader-stage-b-quality-r2-completion-request.md)：仅Q3与三项事实文字修正，新增10tools/8minutes；原24tools用尽，未派发 |
| B-SKIP-001 20 RimeBridge未验证环境用例 | Environment/Quality；Human Product Owner | 未获得StageB风险接受，skipped不是passed；逐项reason在validation-summary/test-evidence |
| B-SKIP-002 10 App+Keyboard未验证环境用例 | Environment/Quality；Human Product Owner | 未获得StageB风险接受，v5-onlyacceptance不能沿用到此candidate |
| B-VENDOR-001 vendor原archivebytes独立比对未完成 | Environment Executor / Quality | 12framework结构+receiptpin通过，630currentfilehash已冻结；仅receipt不是本地bytes对archive的独立attestation；不夸大provenance |
| B-JSON-001 duplicate JSON members | 原合同Product/Quality | 未实现检测，原限制保留；没有扩写parser |

## Artifacts / non-claims

Debug/Release App及KeyboardExtension均记录bundleID/version1.0/build1、executablehash、Mach-O UUID，见paired-binaries；各结果bundle递归文件/treehash在xcresult-manifest，提取完成后冻结。没有manualinstalled/promotion candidate、用户Maps观测、rootcause、行为修复、FullAccess/Lua真实fixture或性能声明。

Stage C writer/producer/APIpatch恢复、paired promotion、manualinstall/Maps、Product/Quality Gate、Release、parent closure和Gitpublication均未授权/未执行。AcceptedADR未重写；CHANGELOG不在切片范围，正式集成/发布时另决定。
