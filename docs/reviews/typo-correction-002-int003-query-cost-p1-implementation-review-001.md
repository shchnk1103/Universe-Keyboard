# INT-003 P1 Query-Cost Instrumentation Implementation Review 001

## 结论

本次是针对已提交 P1 实现的独立、只读 Architecture & Knowledge Steward 复核。复核对象严格绑定：

- implementation commit：6606fbe0ad57cb0a2c636c2383f066a0a09e55e7
- parent commit：5c6a18b30a70921aec9a3286e446f9010bc3506a
- round-3 设计审核基线：1160ac6fd8696c3036391cdf59bc9fe096d0b219
- checkout：/private/tmp/universe-keyboard-int003-query-density-diagnosis-20260925
- branch：codex/typo-correction-002-int003-query-cost-p1-implementation-20260927
- implementation patch SHA-256：1fc7bfc3de343d48509c4670a80ac055fbe27e925df5ee50265d466bacc0099a

总体结果：**Pass with conditions**。

代码实现层面没有发现新的 Blocker 或 Uncovered：七项 round-3 contract 均能在提交 diff 中找到对应的有限值、状态传播、计时边界、typed Field、既有 ingress 和 sidecar 路径。round-2 Claim 5 writer-scope Blocker 已通过单一 Field.typoRecallQuery 沿用现有 record(code:fields:) 入口解决；round-2 Claim 7 的实现路径已可审查。

这个结论只表示 Architecture 实现符合性。它不表示 Quality Pass、Simulator/真机证据、Hosted CI 通过、Product query-cost 接受、数字预算、QA-001 Gate、merge、TestFlight、Release、ADR Accept 或 parent Close，也不消费 P2 AUTH。P2 仍须在独立 Quality/环境条件满足后，冻结精确安装 payload 与 Run manifest，并在任何 Simulator 操作前消费自己的 AUTH。

## 复核方法与身份

- Reviewer：/root/int003_p1_impl_review；独立 Architecture & Knowledge Steward runtime，不是 P1 implementation executor。
- 仅使用只读 git show、git diff、git status、rg、nl 和文件读取核对 exact commit、parent、round-3 review/AUTH、实现源码与 focused tests。
- 未运行 build/test，未操作 Simulator/device，未联网，未读取或修改 raw journal/user data。
- 当前 worktree 在复核开始时已有 implementation receipt、Assignment/status 文档的未提交变更；这些变更不在本次输出范围。仅本文件与对应 usage 文件被写入。
- round-3 baseline 到 parent 的 source allowlist 内容保持不变；实现提交把 stage、result envelope、timing、schema/typed Field、bounded ingress 和 Rime sidecar 变更放入允许路径。

## Allowlist 与副作用边界

提交共修改 15 个路径（955 insertions、50 deletions）：5 个 KeyboardCore source、1 个 Keyboard coordinator、3 个 RimeBridge source/header，以及直接受影响的 KeyboardCore/RimeBridge tests。全部属于 P1 AUTH 的 source allowlist 或其直接受影响 test target。

以下边界得到确认：

- 未修改 Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift。
- 未修改 Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift。
- 未增加第二 persistence route、同步 JSON/file write、raw engine/session handle 或第二 RIME session manager。
- 未修改 debounce、selection、yield 调度、fence 规则、candidate limit 或 RIME deployment ownership。
- 新事件只通过现有高保真、固定容量的 DiagnosticsJournalRuntime.record(code:fields:) 进入异步 ingress。

## 七项 contract 复核

### Claim 1 — stage provenance / yield

结果：**Pass with conditions**。

证据：

- Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift:81-93 新增封闭的 stage_one/stage_two enum 和携带 stage 的 TypoCorrectionRecallQuery。
- 同文件:128、161-176 将 query（包含 stage）保存到 inFlight，并在 yield 前后重放同一个值；stage 在现有 stage-one/stage-two dequeue 点赋值，没有从 journal 顺序、候选文本、yield 次数或预算反推。
- Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift:112-114、138-140、154-173 只把同一个 query 传入 facade。
- Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRuntimeIntegrationTests.swift:38-92 覆盖 stage one、coverage assessment 后的 stage two 以及 yield 后的 stage 保持。

条件与未覆盖证据：

- 当前 focused test 主要验证 driver value flow，没有 coordinator 级别的真实 journal payload 断言来证明 stage_one/stage_two 最终写入 query_measured；该条件需在实现/Quality lane 保留。
- TypoCorrectionRecallDriveEvent 仍是既有的 Equatable value shape；没有独立持久化 driver event 的 Codable 证据，但本次路径没有把它写入 journal。

### Claim 2 — candidate bucket meaning

结果：**Pass with conditions**。

证据：

- Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:103-116 只生成 zero、one_to_three、not_applicable；分类再次应用现有 candidateLimit（3），不读取 full menu、hasMore、usefulness 或 selection。
- Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift:187-224 仍对 coordinator 收到的 array 执行 prefix(3)；bucket 只表示该有限 typed array 是否为空。
- Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+Output.swift:45-81 的既有 parser 丢弃无 text candidate；RimeSessionManager.m:392-407 在 safeLimit 内读取候选。
- TypoCorrectionRuntimeIntegrationTests.swift:122-141 覆盖 0、1、3、超过 3；TypoCorrectionSidecarOwnerAdapterTests.swift:85-105 覆盖 parser 丢弃空 text。

条件与未覆盖证据：

- 当前没有可执行的真实 RimeBridge target 结果来同时证明 ready-empty、safeLimit 后过滤和 full menu 不外溢；实现 receipt 明确记录该 Simulator lane 未运行。
- one_to_three 是非空 bucket，而不是完整数量；实现没有把它表述为完整 RIME menu 或 candidate usefulness，符合 contract。

### Claim 3 — same-call readiness / result state

结果：**Pass with conditions**。

证据：

- Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m:364-385 先按 empty input、zero limit、ensureCorrectionSession 失败返回有限状态；empty input 优先于 zero limit。
- 同文件:390-419 在同一次 correction sidecar operation 中 set_input、get_context、parser 输入与 clear_composition；get_context false 产生 ready + context_unavailable，setup 失败产生 unavailable + sidecar_unavailable。
- Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+CorrectionQuery.swift:11-37 只调用一次既有 bridge facade，并把同次返回的 readiness/result metadata 与 parser 后的 typed array封装成值类型。
- Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionCandidateQuery.swift:9-20、46-90 通过有限矩阵拒绝不匹配的 readiness/state/candidate array；默认 adapter 保留 unknown，不伪装成 ready。
- RimeBridge adapter tests 覆盖 finite parser states、invalid readiness/state；RimeLuaSmokeTests.swift 追加 nonempty unrecognized ordinary query 的 ready/candidates_returned 断言（实际 target 尚未在本复核环境运行）。

条件与未覆盖证据：

- schema-select failure、get_context false 和 ready-empty 的真实 librime 执行证据尚未形成；现有静态路径与 parser/unit fixture 已覆盖语义，但不能替代 RimeBridge Simulator lane。
- malformed raw candidate container 会沿现有 parser 变为空 typed array；本次 contract 没有增加新的 malformed-input 状态，后续 Quality 需保持 raw journal/bridge failure 不被解释为 Product success。

### Claim 4 — monotonic facade timing

结果：**Pass with conditions**。

证据：

- Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift:163-170 在 owner.correctionQueryResult 前后使用 DispatchTime.uptimeNanoseconds；event construction、post-fence、driver bookkeeping 和 ingress 均在 end tick 之后。
- Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionCandidateQuery.swift:23-40 使用非回绕的 end >= start 判断，按微秒向下取整；true sub-microsecond 为 measured/0，精确 UInt32.max 仍 measured，超出时 saturated/UInt32.max，regression 为 clock_regression/0。
- TypoCorrectionRuntimeIntegrationTests.swift:94-120 覆盖 sub-microsecond zero、floor、exact maximum、saturation 和 regression。

条件与未覆盖证据：

- 测试验证的是纯 value helper，不是实际 device/Simulator 时钟或 facade 分布。
- 没有在本次复核中测得 observer overhead 数字；该数字属于 P2/后续 Quality evidence，不能将 facade duration 命名为 librime CPU time 或 Product latency。

### Claim 5 — schema 4/5、typed Field cardinality 与 privacy

结果：**Pass with conditions**。

证据：

- Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:8、103-274、301-375 新增 schema 5、有限 payload、单一 Field.typoRecallQuery 和 duration/result 矩阵；payload 没有 input、candidate text、host、composition 或 fingerprint。
- 同文件:1016-1067 要求 query_measured 只能是 schema 5 + 恰好一个 typed Field，其他 Code 不得携带该 Field；schema 4/5 decoder guard 在:1075-1115 拒绝 unsupported schema、schema-4 query_measured 和 code/field mismatch。
- Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift:65-90 保持原 record(code:fields:)；commit 没有改动 writer API、DiagnosticsJournal.swift 或旧 JSONL reader。
- DiagnosticEventTests.swift:539-650 覆盖 v5 round trip、no-text/no-fingerprint、missing/duplicate/extra/wrong code/schema/unknown enum，以及 schema-4 pre/post-PR #182 的 keychain_access_denied boundary。

条件与未覆盖证据：

- v4/v5 fixture 与 decoder rejection 有 focused unit coverage，但没有在本次复核中由独立 reviewer 读取真实 sealed raw JSONL；P2 必须以 raw bytes/hash 为 canonical，并将 undecodable line、gap、drop、truncation censor。
- 旧 Code query_begin/query_outcome 仍保留以支持历史 decode，当前 coordinator P1 path 不再发出它们；未将历史行与新 query_measured 叠加计数。

### Claim 6 — existing sidecar / serial ownership

结果：**Pass with conditions**。

证据：

- Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionSidecarOwner.swift:13-71 仍只包装已安装 TypoCorrectionCandidateQuerying facade；新增 method 是值类型转发，没有 raw engine/session。
- Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+CorrectionQuery.swift:4-37 仍通过 bridge.correctionCandidatesForInput 路径；RimeSessionManager.m:388-419 复用同一 correctionSessionId。
- RimeSessionManager.m:589-603 的既有 ensureCorrectionSession 在同一 manager/runtime 中建立并选择 schema；没有新增 manager、background queue 或 second route。
- 未引入 @unchecked Sendable；coordinator 仍在现有 MainActor/serial ownership 路径执行。

条件与未覆盖证据：

- 本次未运行 RimeBridge target，故不能独立宣称 thread-affine / Swift 6 strict-concurrency 编译和运行证据已通过；实现 receipt 的 Swift format 与 KeyboardCore 结果属于 executor-reported evidence。
- 任何 responsive gate-on dedicated owner 的真实运行验证仍属于后续 Quality/环境 lane。

### Claim 7 — post-call discard、bounded ingress 与 censoring

结果：**Pass with conditions**。

证据：

- Coordinator.swift:171-195 先完成 post fence 与 driver.finishQuery，再构造一个 payload 并调用 recordQueryMeasured；discarded 只用 disposition=discarded_after_facade，不再追加 query_outcome。
- Coordinator.swift:156-160 的 pre-call fence cancellation 不调用 facade，也不产生 query_measured；保留的 fence_discarded 是独立 lifecycle marker。
- DiagnosticsJournalIngress.swift:59-80、89-119、170-210 保持固定容量、queue-full/suspend drop 和异步 utility writer；没有把丢失事件填成 zero/success。
- DiagnosticsJournalIngressTests.swift:48-109 覆盖 queue-full 与 suspend drop；DiagnosticsJournalRuntimeTests.swift:125-164 验证 typed event 经过现有 bounded async ingress。

条件与未覆盖证据：

- 没有 coordinator-level test 直接捕获 post-call stale fence 的 discarded_after_facade payload，也没有直接断言 pre-call cancel 无 query_measured；代码位置与 driver fence flow符合 contract，但该测试证据仍需补齐。
- 没有 raw segment 的 sealed/open/truncated、localSequence gap、malformed line 或 writer/lifecycle failure capture；P2 只能在完整 sealed segment 且这些 censor 条件均清零时报告 exact total，否则只能报告 observed lower bound。
- queue-full/suspend unit tests 证明 ingress 能丢弃事件，不证明某次 P2 capture 没有丢失。

## 当前测试与证据边界

实现 receipt 报告了以下 executor-side evidence，本次没有重跑：

- changed Swift files 的 swift-format strict lint 通过；
- swift test --package-path Packages/KeyboardCore：1,170 tests passed、0 failures；
- changed RimeSessionManager.m 的 clang -fsyntax-only 通过。

实现 receipt 同时报告 Xcode package resolution/CoreSimulatorService 在其 sandbox 不可用，因此 RimeBridge Simulator tests、App + Keyboard Simulator tests 与 Release build 未通过/未执行，不能声称 green。Hosted CI、真实 Debug facade overhead、raw JSONL sealed Run、Quality review、Product budget 和 Gate 均未在本次复核中建立。

## Residuals 与合法后续边界

| ID | Owner | Disposition / required evidence |
|---|---|---|
| IMPL-R1 | Input Intelligence Maintainer | fix：补 coordinator-level stage、ready-empty、post-call discard、pre-call cancel 与 one-event/no-legacy-pair assertions。 |
| IMPL-R2 | RimeBridge owner + Test/Release | fix：在可用的 RimeBridge target 运行 same-call setup/get_context/schema matrix，并绑定精确 source/build/environment。 |
| IMPL-R3 | Test/Release | fix：完成适用的 iOS Simulator/Hosted CI lanes；本次不把 executor-reported KeyboardCore 结果升级为 Quality Pass。 |
| IMPL-R4 | Test/Release / P2 executor | fix：冻结安装 payload、schema/access/host/diagnostics state、Run ID 和 raw journal；验证 sealed/gap/drop/decode/truncation 后再做 exact/lower-bound/censoring 报告。 |
| IMPL-R5 | Human Product Owner / Product Lead | accept/decision：任何 query budget、Product latency/cost 或 Gate 结论需要独立 Product/Quality authority；本 review 不提供数值接受。 |

在上述 residuals 未分别完成前，允许把本提交描述为已独立 Architecture reviewed 的 P1 implementation，但不得描述为 Quality/Product/Gate 通过，也不得由本文件消费 P2 AUTH 或授权 Simulator/device 操作。
