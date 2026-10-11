# P2纠错查询scope准备链路：限定只读核查

Status: Completed — 发现静态路由兼容缺口；当前进程实际route未确认

## 权限及输入

Human“继续”承接[条件快照验证](typo-correction-002-int003-query-cost-p2-lldb-event-loop-validation-001.md)后的只读建议。按Assignment Policy明确只读例外，Owner为Test / Release Maintainer，Executor当前Codex；仅读取固定writer候选的相关源码及既有回执，输出本文和下一Proposed方案。0设备操作/LLDB/输入/源码或工具改动，旧AUTH不复用。

11份源文件hash保存在 `/private/tmp/uk-scope-readiness1/read-manifest.json`；固定source25候选不变，不追逐main。

## 第一性原理：输入、状态、副作用、可验证输出

- 探针输入scope来自controller已安装query facade的DEBUG观察接口；`nil`统一fallback为session0/schemaunknown，不能区分route、observer和底层session。
- scope观察不负责创建session。真正创建发生在RimeSessionManager.correctionCandidatesForInput里ensureCorrectionSession：必须runtime initialized，create_session成功且当前schema选择成功；普通键盘主session已有并不等于correction session已有。
- 主session commit/clear不销毁correction session；旁路每次查询只clear其composition。runtime ownership交接/destroySession才会销毁该session。因此正常输入预热仅对支持此观察接口的路由可能有帮助。
- 有效输出必须实际scope非零且Luna；当前一次快照为0/unknown，仍不完整。

## 明确的静态兼容缺口

| 源码位置 | 事实 |
|---|---|
| InstalledTypoCorrectionSidecarOwner.existingCorrectionQueryDebugScope | route必须defaultMainActor，且被包裹query实现DebugScoping；否则直接nil |
| RimeEngineImpl DEBUG adapter | 可以读取现有RimeSessionManager的correction scope，不新建session |
| ResponsiveRimePreflight.productGateReleaseDefaultOn / shouldArmDualGate | true；ordinary build优先请求dual-gate，不能仅通过UserDefaults false关闭 |
| Bootstrap.installResponsiveDualGatePreflightIfArmed | 成功时打开responsive及threadAffine flags，安装CandidateProviderTypoCorrectionQuery；不是MainActor活RimeEngineImpl |
| controller.typoCorrectionSidecarRoute | threadAffine flag优先映射threadAffine；该route不满足观察接口defaultMainActor条件 |
| dual-gate fail-closed分支 | 安装不active会清flags并回退sync，因此不能仅从默认true确认当前实际route |

**若当前实际route是threadAffine，现有观察接口必然nil，输入再长也无法得到探针所需scope。**这是静态确定的限制；本次没有读取当前进程route，不能将条件结论改写为该进程实际根因。

CandidateProviderTypoCorrectionQuery只委托候选provider，没有现有RimeEngineImpl DEBUG scope接口；它的facade成本也不能当成底层librime查询时间。后续route身份与统计必须按实际facade解释。

## 预热条件与为何不立即让Human操作

协调器还要求letters/chinese、非空白至少8字符，随后0.18秒debounce、fence与owner一致、生成hypotheses后才会调用query。nihao5字符不足；现有集成测试的公开fixture `wimenjintianquhongyuan`有stage查询覆盖，但测试用fake owner，不能证明真实环境必然建立scope。

当前已rejected probe不能重复arm；仅切换键盘也不保证process或全局probe重建。未授权恢复、杀进程、新输入或开诊断。当前日志/HF关闭且ordinary path marker使用既有logger，日志缺失不能作为route证据。因此不要求Human更长输入、盲目重启或改prefs。

## 下一最小建议

先做[路由兼容性限定设计](../plans/typo-correction-002-int003-query-cost-p2-route-compatibility-design-001.md)，明确怎样取得实际内容无关route身份、让现有probe只绑定真实的已安装facade及生命周期。保留现有计数/完整性、unknown与elapsed边界；不为通过切回旧MainActor路由，不创建第二个RimeEngineImpl，不放松session guard猜修。

本轮是静态分析，不是独立Architecture/Quality review或runtime结果；源码不变，docs-only，跳过xcodebuild，无发布/Gate/ADR Accept/Release。父TYPO-CORRECTION-002 Active；P2现卡在“实际路由与探针scope兼容”，工具传输问题已在上一轮解决。
