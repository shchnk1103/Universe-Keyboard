# INT-003 P1 Query-Cost Architecture Review Round 3

## 结论

本轮是全新、独立的 Architecture & Knowledge Steward review，审查对象严格绑定到 round-3 frozen packet、其九份输入快照，以及 source baseline 1160ac6fd8696c3036391cdf59bc9fe096d0b219 的 28-file manifest。

总体结果：**Pass with conditions**。七项 claims 均有明确结论，没有新的 Blocker 或 Uncovered。

- Round 2 Claim 5 Blocker：**已在架构与 scope 层面解决**。一个封闭的 DiagnosticEvent.Field.typoRecallQuery(payload) 可以通过现有 DiagnosticsJournalRuntime.record(code:fields:) 入口写入；不需要改动 DiagnosticsJournalRuntime.swift，也不需要新增 P1 allowed source path。
- Round 2 Claim 7 Uncovered：**已在架构覆盖层面解决**。event construction、bounded admission、post-call disposition 和 censoring 现在有可执行的单事件协议；实现后的 focused tests、overhead receipt 与 P2 raw-segment evidence 仍是条件。

本结论批准精确 packet 进入 P1 的后续实现入口，但不消费 P1/P2 AUTH，不替代 AUTH consumption，不授权 source edit、build/test、Simulator capture、Quality/Product/Gate、merge、TestFlight、Release、ADR acceptance 或 parent Close。

## Reviewer 与身份核验

- Reviewer lane：TYPO-CORRECTION-002-INT003-QUERY-COST-P1-ARCH-001/round-3
- Reviewer identity：fresh-context、独立 Architecture & Knowledge Steward runtime，/root/int003_p1_arch_review_r3；不兼任 P1 executor/coordinator
- Checkout：/private/tmp/universe-keyboard-int003-query-density-diagnosis-20260925
- Frozen packet commit / HEAD：7ef0b4679f4f8cff9dd9e3cc9bcf93b666c86acc，匹配
- Source baseline：1160ac6fd8696c3036391cdf59bc9fe096d0b219，匹配 packet
- Packet normalized SHA-256：513b26ed593906b20597091e016e1648e6a27c6d231642b92179cbb994d37f9f，按 packet 规则将 packet digest 值替换为 64 个 ASCII 0 后独立复算，匹配
- Source manifest SHA-256：a98a722b03e2c66de61ab41ae30f59791ccb53a3b365f55a18e96d373732b395，匹配 packet 中的完整值
- 28-file baseline manifest：28/28 Git blob ID 与 28/28 SHA-256 均匹配 baseline
- 九份 mutable input snapshot：9/9 SHA-256 均匹配 packet

所有 source 判断均来自 baseline Git object 的 git show 读取；没有把 mutable working-tree source 当作证据。

## Claim 1 — Stage provenance

**结果：Pass with conditions**

### 冻结证据

- baseline Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift:81-114 的 TypoCorrectionRecallDriveEvent 目前只有 query(TypoCorrectionSuggestion)，driver 同时维护 stageOneQueue、stageTwoQueue、inFlight、awaitingYield 和 startedStageTwo。
- 同文件:136-161 的 nextEvent 先重放 inFlight，再从 takeNextStageOne 或 takeNextStageTwo 取出 query；:164-167 的 acknowledgeYield 只清除 yield 状态。
- 同文件:244-263 的两个 takeNext... 是实际从 Stage 1/Stage 2 队列取出 suggestion 的位置。
- baseline Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift:102-150 只消费 query 事件；:186-207 通过 RunLoop yield 后重新进入 driver。

### 判断

proposal 把 stage 作为有限值域附着在现有 driver dequeue 结果上，是正确的 provenance 位置。Stage 1/2 不需要从 journal 顺序、候选内容、yield 次数、operation ordinal、selection 或 query budget 反推，也不要求改变 debounce、selection、yield、fence 或 scheduler。

当前 inFlight 仍只是 suggestion，因此实现必须把 stage 与 inFlight/query value 一起保存；只在首次 query 事件上赋值、再在 yield 后读取队列顺序会重新引入猜测。只要 stage 在 takeNextStageOne/takeNextStageTwo 处产生，并随同一 query 跨过 finishQuery → waitForYield → nextEvent 的状态转移，stage 在 yield 后保持稳定。

### 条件、owner 与证据

1. Input Intelligence Maintainer 必须使用封闭的 stage_one/stage_two 值域，并确保 stage 不是自由字符串、输入内容或 hypothesis。
2. 直接受影响的 KeyboardCore tests 必须覆盖 Stage 1 query、coverage assessment 后的 Stage 2 query、yield 后重放，以及 post-call fence discard；测试应断言 discard 不被计为成功。
3. Architecture follow-up 复核 driver event 的 Codable/Sendable 形状与 stage 的 inFlight 保存位置。

## Claim 2 — Candidate-count meaning

**结果：Pass with conditions**

### 冻结证据

- baseline Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift:4-8 将 candidateLimit 固定为 3；:170-203 的 finishQuery 对 coordinator 收到的 typed candidates 执行 prefix(3)，再以 limited.count 更新 ledger。
- baseline Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift:168-172 以 candidateLimit 调用已安装 facade；这不是完整 RIME menu 的读取接口。
- baseline Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+CorrectionQuery.swift:3-8 通过 bridge correctionCandidates 后调用 parseCandidateWindowDictionary。
- baseline Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m:362-392 对 safeLimit 做边界处理，读取 get_context 的有限 menu，过滤没有 text 的 candidate，并清理旁路 composition。

### 判断

returned_candidate_bucket 的定义可以精确实现为：parser 和 bridge limit 后送到 coordinator 的 typed array，再经 driver 现有 prefix(3) 后的数组长度 bucket。zero 与 one_to_three 只表示 coordinator/driver 实际收到并保留的有限候选数量，不表示完整 RIME menu、hasMore、candidate usefulness、用户选择结果或 RIME CPU 成功。

这也保留了 ready-empty 的语义：RIME 已 ready、context 成功、typed array 为空时才是 candidates_returned + zero。sidecar 不可用、context 不可用、empty input 和 zero limit 使用 not_applicable。

### 条件、owner 与证据

1. Input Intelligence Maintainer 必须从 final limited typed array 生成 bucket，不能从 context.menu.num_candidates、hasMore 或 raw dictionary 推导。
2. RimeBridge/KeyboardCore focused tests 必须覆盖 0、1、3、超过 3、parser 丢弃空 text 的情况，并确认超出 3 的输入不会形成第四个 bucket。
3. 序列化断言必须确认 bucket 不携带 candidate text、identity、composition 或 fingerprint。

## Claim 3 — Readiness and result state

**结果：Pass with conditions**

### 冻结证据

- baseline Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m:362-365 当前把 empty input、zero limit 与 ensureCorrectionSession failure 都折叠为空 candidates。
- 同文件:368-392 在旁路 correctionSessionId 上执行 set_input、get_context、candidate parsing 和 clear_composition；get_context false 当前没有可供上层区分的状态。
- 同文件:562-575 的 ensureCorrectionSession 在同一个 manager/runtime 内检查 initialized、创建 correction session、读取当前 schema 并选择 schema。
- baseline Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionCandidateQuery.swift:4-20 当前 protocol/测试 adapter 只返回 [RimeCandidate]；baseline RimeSessionManager.h:74-76 也只承诺 candidates 字典。

### 判断

round-3 result envelope 在同一次 installed facade invocation 内补齐了当前缺失的状态，且路径在 P1 allowed files 内。以下有限矩阵是明确的：

| 输入/bridge 状态 | readiness | result_state | bucket | facade invocation |
|---|---|---|---|---|
| input 为空；即使 limit 也为 0 | unknown | empty_input | not_applicable | 是，bounded validation return |
| input 非空、safe limit 为 0 | unknown | zero_limit | not_applicable | 是，bounded validation return |
| ensureCorrectionSession 失败，包括 initialized/session/schema setup 失败 | unavailable | sidecar_unavailable | not_applicable | 是 |
| ensure 成功但 get_context == false | ready | context_unavailable | not_applicable | 是 |
| ensure/context 成功并返回 typed array | ready | candidates_returned | zero 或 one_to_three | 是 |
| non-RIME/test adapter 返回 typed array | unknown | candidates_returned | zero 或 one_to_three | 是 |

empty_input 优先于 zero_limit；非空但 unrecognized 的输入不产生新的 invalid-input probe，而是走普通 query path，按实际结果进入 ready + candidates_returned + zero 或 one_to_three。该规则不要求第二次 RIME route，也不把 unknown 伪装成 ready。

### 条件、owner 与证据

1. RimeBridge owner 必须让 readiness、get_context 状态与候选数组来自同一次 bridge call；不能在 facade 外追加 probe。
2. Input Intelligence Maintainer 必须把该 envelope 作为值类型跨过 TypoCorrectionCandidateQuerying、InstalledTypoCorrectionSidecarOwner 和 coordinator。
3. focused bridge contract tests 必须覆盖 ready-empty、ensure failure、schema-select failure、get_context false、empty input、zero limit、non-RIME/test unknown，以及非空 unrecognized input。

## Claim 4 — Timing

**结果：Pass with conditions**

### 冻结证据

- baseline Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift:154-184 的 performQuery 在 pre-fence 后调用 owner.correctionCandidates，随后读取 post-fence、运行 finishQuery 和写 outcome。
- 同文件:164-167 的 query_begin marker 在 facade 前；该 marker、fence、driver bookkeeping 与 query outcome 不属于 proposed facade interval。
- baseline Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:96-99 当前只有毫秒级 DurationMetric，因此不能直接回答约微秒级 facade boundary 成本。
- baseline RimeEngineImpl+CorrectionQuery.swift:6-8 与 RimeSessionManager.m:368-392 表明 installed facade 包含 bridge call、set_input、get_context、candidate parsing 和 clear_composition，不等于 librime CPU-only time。

### 判断

proposal 的边界是正确的：在 owner.correctionCandidates 前后以单调时钟取 start/end，只把完整 installed facade invocation 放入 facade_elapsed_microseconds。event construction、Date、JSON、fence、driver bookkeeping、persistence 与 queue submission 都在 interval 外。微秒值向下取整；真实小于 1 微秒的调用可以为零；大于 UInt32.max 时记录 UInt32.max 并以 saturated 标志；end tick 小于 start tick 时记录 clock_regression、duration 0，并将该 timing 样本 censor，而不是解释成极快调用。

这描述的是 facade boundary duration，不能命名为 rime_cpu_time、engine_time 或 useful_time。

### 条件、owner 与证据

1. Input Intelligence Maintainer 必须采用不回绕的 tick 比较和 UInt32.max 饱和规则；clock regression 不能使用 wrapping subtraction。
2. tests 必须覆盖 true sub-microsecond zero、floor、exact max、saturation、clock regression，以及 cancel-before-call 没有 duration-success event。
3. P2 只能把该值作为 Debug/Simulator facade duration；没有 Release-like Product latency 或预算含义。

## Claim 5 — Diagnostics protocol and writer boundary

**结果：Pass with conditions**

### Round-2 Blocker disposition

Round 2 的 blocker 是 writer API 越界：当时的 typed payload 需要改 DiagnosticsJournalRuntime.swift。本轮将 payload 改为一个闭合的 DiagnosticEvent.Field.typoRecallQuery(payload) 成员，沿用现有 record(code:fields:)；因此不需要 DiagnosticsJournalRuntime.swift 改动，不需要新增 allowed source path，Round-2 Claim 5 Blocker 已解决。

### 冻结证据与判断

- baseline Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift:65-90 的 record 已接收 [DiagnosticEvent.Field]，递增 localSequence，构造有限 DiagnosticEvent 并投入 ingress。
- baseline Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift:7-8 当前 schemaVersion 为 4；:15-50 的 Code 目前没有 query_measured；:126-188 的 Field 目前只有 count/duration/flag/reason。
- 同文件:787-845 的 init 已在 DiagnosticEvent.swift 内对 composite payload、code、fields 做构造期约束；:868-948 的 decoder 已做 code/payload/fields 交叉校验。新增 query Field、query code、schema v5 和对应 validation 全部可以留在该 allowed file。
- baseline :228-238 的 RimeSyncFailure 已包含 keychainAccessDenied = keychain_access_denied；schema 仍是 4。
- baseline Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournal.swift:1384-1415 对单行 decode 使用 try? 与 compactMap，无法解码的行会被 reader 忽略而不改写原始行。

round-3 contract 在 ADR 0027 的有限字段边界内可执行：

1. schema v5 的 typo_recall.query_measured 必须有且只能有一个 Field.typoRecallQuery(payload)；generic fields 必须为空；任何其他 Code 携带该 Field 都拒绝。
2. query payload 的每个成员都是有限 enum 或有界整数；schema/code/payload 不匹配、missing、duplicate、extra typed/generic field、unsupported schema、unknown Code/enum 都拒绝，不转换为 zero/ready/success。
3. schema 4 历史行继续按其原始 schema 与旧 keys/finite values 解码；schema 4 的 query_measured 明确拒绝。新的 v5 writer 不改写旧 JSONL。
4. PR #182 的 schema-4 enum 边界接受当前 baseline reader 能识别 keychain_access_denied，而更早的 pre-#182 v4 binary 可能拒绝该值；这是已明确接受的 compatibility boundary。raw JSONL 是后续检查的 canonical bytes，不对旧 binary 作 v5 读取承诺。
5. P2 直接校验保存并 hash 的 raw JSONL，不把 reader 的 compactMap 结果当作 exact query total。

### 条件、owner 与证据

1. Architecture & Knowledge Steward 与 Input Intelligence Maintainer 必须在实现中冻结并测试 v4/v5 code-version-payload matrix：v5 允许旧 code/旧 composite payload 按既有规则继续工作，query_measured 只允许 v5 + 一个 typed Field；旧 v4 行保持原 schema。
2. DiagnosticEventTests 必须覆盖 v4 pre-#182 与 post-#182 fixture、v5 typed-field round trip、schema-4 query rejection、missing/duplicate/extra/mismatched query fields、unknown schema/code/enum、generic-field rejection 与 no-text/no-fingerprint serialization。
3. 不得以 generic fields 替代 typed Field，也不得修改 DiagnosticsJournalRuntime.swift、DiagnosticsJournal.swift 或另一个 persistence route 来绕过现有边界。

## Claim 6 — Runtime ownership

**结果：Pass with conditions**

### 冻结证据

- baseline Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionSidecarOwner.swift:29-68 的 InstalledTypoCorrectionSidecarOwner 只包装已安装 TypoCorrectionCandidateQuerying，不访问 raw engine 或创建 session。
- baseline Packages/RimeBridge/Sources/RimeBridge/TypoCorrectionSidecarOwnerAdapters.swift:3-22 只做 route-aware wrapper；RimeEngineImpl+CorrectionQuery.swift:3-8 只调用现有 bridge.correctionCandidates。
- baseline RimeSessionManager.m:45-65、:362-392、:560-575 使用同一 manager/runtime 的 correctionSessionId 旁路 session；RimeSessionManager.h:74-76 的接口不暴露 raw session。
- ADR 0004:9-25、36-44 保持 process-local session、serialized session operation、MainActor/thread 规则及“Extension 不部署”；ADR 0025:81-104、162-197、220-224 要求单一 serial owner、checked Swift 6 isolation、禁止 @unchecked Sendable shortcut，并维持 content-free diagnostics。

### 判断

把 readiness/result envelope 放进同一个 correction facade 的值类型，不会增加 session owner、改变 correction sidecar 的主 session 隔离或建立第二 RIME route。主 session 的 composition、selection、debounce、yield、fence 与 candidate limit 仍由既有 coordinator/driver 控制。该设计保留 sidecar-only RIME ownership 与 Main-App-owned deployment boundary。

### 条件、owner 与证据

1. RimeBridge owner 必须让 correction query 与现有 process-local serial owner 同步执行；responsive gate-on 路径也不能把该调用从单一 RIME serial owner 偷渡到任意 background queue。
2. 不得使用 @unchecked Sendable，不得暴露 session handle/raw engine，不得创建第二 session manager，不得增加 facade 外 readiness probe。
3. implementation review 必须核对 begin/end lifecycle、same-thread/thread-affine contract、Swift 6 strict isolation 和 focused bridge tests。

## Claim 7 — Observer cost and censoring

**结果：Pass with conditions**

### Round-2 Uncovered disposition

Round 2 的 Uncovered 只因 event construction/admission 依赖当时越界的 DiagnosticsJournalRuntime typed writer。本轮通过既有 record(code:fields:) 入口解决该依赖，因此 Claim 7 的架构路径已可审查；它不再是 Uncovered。实现和 capture evidence 仍需满足下列条件。

### 冻结证据与判断

- baseline DiagnosticsJournalRuntime.swift:65-90 在 facade 外构造有限 event 并调用 ingress；没有同步 JSON/file write。
- baseline DiagnosticsJournalIngress.swift:5-8 将 pending queue 限制为 256；:59-80 只在有界内存状态中 admission，queue-full 丢弃；:89-119 在 suspend 时清除未开始尾批并累计 dropped count；:121-211 的 JSON/file writer 在 utility queue/Task.detached 阶段执行。
- baseline Coordinator.swift:154-184 已有 pre-fence、facade call、post-fence 和 discard 分支；proposal 把 terminal query event 放在 post-call 之后，并将 post-call fence mismatch 写入 disposition。
- baseline DiagnosticsJournal.swift:1384-1415 的 per-line decode failure 会被 compactMap 忽略，不能伪造为成功或 zero。

proposal 的 event construction、record admission 和 persistence 都在 measured facade interval 之后。一个 facade invocation 最多产生一个 query_measured：applied 或 discarded_after_facade；pre-call cancel 没有 facade invocation，所以没有 query_measured。queue-full、suspend、writer/lifecycle failure、malformed/unsupported line、localSequence gap、open/unsealed/truncated segment 都是 missing/censored signals，不能填成 zero 或 successful query。

只有 complete sealed segment，同时满足无 unexplained gap、无 undecodable line、无 queue/suspend drop、无 truncation，并且高保真 ingress 已按 run manifest armed，才可以报告 exact query total。其余 capture 只能把 observed query_measured count 报为 lower bound，missing query count 保持 unknown，并 censor 受影响区间。

### 条件、owner 与证据

1. Input Intelligence Maintainer 必须停止 P1 query path 的 query_begin/query_outcome 二事件配对；历史 Code 可保留用于旧 journal decode，但不能与新 query_measured 叠加为同一次 query 的第二 terminal event。
2. post-call fence discard 必须仍生成一个带 discarded_after_facade 的 query_measured；pre-call cancellation 不得写成 zero-duration success。若保留独立取消生命周期 marker，证据必须把它与 query-measured count 分开。
3. P1 focused tests 必须覆盖 ready-empty、sidecar unavailable、unknown adapter、post-call discard、pre-call cancel、queue-full、suspend drop、no-text/no-fingerprint 与 measured interval 外的 event construction。
4. Independent Test/Release reviewer 在 P2 复核 raw JSONL、sealed state、localSequence、decode failure、drop/truncation 与 lower-bound/censoring；不能由 P1 author 自行声明 Product cost 或 Quality acceptance。

## 总体 residual 与交接

- Input Intelligence Maintainer：stage-bearing driver value、candidate bucket、result envelope、timing boundary、one-event disposition 与 focused tests。
- RimeBridge owner：same-call ensure/get_context semantics、sidecar-only session、thread/serial ownership。
- Architecture & Knowledge Steward：v4/v5 compatibility matrix、PR #182 boundary、typed Field cardinality、raw reader/censoring interpretation。
- Independent Test/Release reviewer：implementation correctness、observer overhead、drop/censoring 和 Debug/Simulator 限制。
- Human Product Owner / Product Lead：仅在需要新 source path、产品合同、budget/Gate 或其他 packet boundary 时重新授权并建立新 packet。

本轮不消费任何 AUTH，不更改 Assignment lifecycle，不作 Product budget、Quality、QA-001 Gate、merge、Release 或 parent Close 判断。
