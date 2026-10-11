# F2测试与构建矩阵交付 — 2026-10-04

Human批准root执行F2与原UDID新独占，180分钟墙钟/首失败停止；另精确批准旧PID55759一次SIGTERM，确认退出，完整静默before备份后才测试。所有12required冻结命令exit0；保守预算从10:40Z计，实际测试10:46–10:55Z、after核验10:56Z，未耗尽预算。root未修改五文件，最终1156源树/App/Vendor输入字节不变。[工件manifest](keyboard-wake-host-activation-fix-001-f2-execution-artifacts/manifest.json)。

**结论：执行已交付，质量Hold。** 不是独立Architecture/Quality通过、修复有效或F4/Release。新增test类同步setUp的7条MainActor隔离诊断尚未接受，不能用xcodebuild exit0覆盖它们。

| 作业 | 实际结果 |
|---|---|
| 分类/轻量/4Swift lint | 通过；包含新untracked文件、CIhelper12 tests、链接及JSON |
| KeyboardCore | 1194项，0失败 |
| RimeBridgeTests | 105项：85通过、20skipped、0失败 |
| App+Keyboard完整套件 | 448项：438通过、10skipped、0失败 |
| 新gate | 上述完整套件中17/17实际Passed；focused条件不满足，未再跑，不属于测试skip |
| Release配置build | exit0，非发布 |
| 签名Keychain专项 | 1/1通过，无skip；不改写完整套件的同名unsigned skip |

RimeBridge20skip与完整套件10skip分别获Human仅当前F2非阻塞/未验证接受，原身份/原因全保留，不计通过、不用于Release。signed专项与unsigned full suite身份分开，不能删除原skip或拿专项替完整矩阵。工具预发现与actual计数不凑数重跑。

## 质量缺口：新增测试初始化actor隔离

`KeyboardTests/KeyboardHostLifecycleRecoveryGateTests.swift:19–25` 同步`override setUp()`初始化7个MainActor状态产生7条compiler warning。真实命令钉swift-version6/strict concurrency、要求warnings-as-errors，但实际日志仍有warning、exit0；不声称“零诊断严格门禁已通过”，命令参数出现不代有效编译行为。AppIntents metadata提示另类记录，不与这7条新增源码诊断混算。[精确诊断](keyboard-wake-host-activation-fix-001-f2-execution-artifacts/new-test-actor-diagnostics.json)。

下一源码修正建议仅由Grok修测试fixture初始化隔离，保持测试断言与生产4文件不改，不用unsafe/unchecked手段；需新的明确修正范围/预算与冻结候选。原17实际pass证据保留，但改后不能当新候选最终通过；复验范围按最终内容/target影响确定，至少实际KeyboardTests所在完整App+Keyboard target及严格格式/诊断。

## 环境Exit：未恢复，不可直接Maps

原UDID未替换，测试后无目标App/appex进程，after两次库存一致。已装bundle为本轮签名测试构建，main UUID38DA7472-D854-3103-B78C-9A8B05A97928、appex UUID D6871065-0EB8-3B3E-B033-E114E99FBB85，签名verify0。after Data与Group UUID均已变化；AppGroup从before51files/37,749,287bytes到4files/724bytes，rime_deployed ABSENT、rime_needs_deploy=true。诊断两键仍ABSENT。不能把原诊断现场或正常输入健康视为保持。

before完整128M备份有效，未自动恢复/安装旧包/重新部署/启动/输入。raw run约1.2G，before约128M；均保留，不删历史备份。[after内容无关回执](keyboard-wake-host-activation-fix-001-f2-execution-artifacts/environment-after-receipt.json)，原逐文件库存仅private。

先申请[精确F2-before恢复方案](../plans/keyboard-wake-host-activation-fix-001-f2-before-restore-plan-2026-10-04.md)授权，保持当前独占；再协调Grok最小测试修正与候选复验。恢复不授权源码，测试交付不授权F3新review预算、F4Maps或Git。父诊断Completed/旧rolloutActive及R1Partial/R2仅设计不变。

xcresult读取首次sandbox exit64（TestReport缓存写权限）；主机只读解析成功，未因此重跑测试。原失败回执限制如实记录，解析输出/真实counts归档。
