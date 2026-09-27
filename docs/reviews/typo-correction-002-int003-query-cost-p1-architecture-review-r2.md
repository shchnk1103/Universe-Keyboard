# INT-003 P1 Query-Cost Architecture Review Round 2

## 结论

本轮按冻结 packet 独立复核了 7 个 claims。总体结果为 **Blocker / implementation approval withheld**。

- Claim 1：Pass with conditions
- Claim 2：Pass with conditions
- Claim 3：Pass with conditions
- Claim 4：Pass with conditions
- Claim 5：Blocker
- Claim 6：Pass with conditions
- Claim 7：Uncovered（依赖 Claim 5 的实现路径，按 packet 要求停止）

核心 blocker 是：proposal 要求新 query_measured 使用 DiagnosticEvent.TypoRecallQueryPayload，并且 generic fields 必须为空；现有 DiagnosticsJournalRuntime 只有 generic fields 的 record API，没有接收该 typed payload 的入口。实现这个精确协议需要修改 Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift，但该文件不在 P1 AUTH 的 allowed source paths 中。本轮不能替该范围扩权，也不能把 payload 降级为 generic fields。

另外，v4/v5 的兼容规则还需要把 schema 与新 Code 的关系冻结得更精确。PR #182 在 schema version 仍为 4 时加入了 RimeSyncFailure.keychainAccessDenied；当前 baseline 的 v4 decoder 已认识这个值，但更早的 v4 reader 会因未知 enum 值而拒绝该记录。proposal 已说明旧 binary 不保证读取 v5，但没有明确 v4 新 enum 的兼容边界，也没有明确禁止 typo_recall.query_measured 以 schema 4 出现。这个问题必须在扩权后的新冻结中写成可测试的规则。

P1 AUTH 保持 Active/unconsumed；本轮没有编辑 source、Assignment、AUTH、plan、packet 或 manifest，没有运行 build/test，没有启动 Simulator/设备，没有访问日志或用户数据，没有网络操作，也没有 commit/push/PR。

## 身份与冻结输入

Reviewer runtime：/root/int003_p1_arch_review_r2；fresh-context、独立 Architecture & Knowledge Steward reviewer，不兼任 P1 executor/coordinator。

- Frozen packet commit：4778503bcffe4c8dd48c58e85b992ef53c823234
- Source baseline：8e4ea0f1777f1175141731797afeee5ebd964c96
- Packet normalized SHA-256：c3a5e9d53009953d48accf11a7e0369d25596bb545f14962c14df022debf5fb0，匹配 packet 约定
- Source manifest：docs/evidence/typo-correction-002-int003-query-cost-p1-arch-source-freeze-r2.json
- Source manifest SHA-256：d8f7aa17906bfc1d6d9e1c9b39135fb71be80a94b210c81916095940a54fff5f，匹配
- Baseline manifest verification：28/28 Git blob 与 28/28 SHA-256 匹配 baseline

7 个 packet 输入快照均从 packet commit 的 exact bytes 复算并匹配：

| 输入 | SHA-256 |
|---|---|
| Assignment | 0b949e204ae367a09309ed03f67ed3bd6a8920660357b955fd0f38bd989acc9b |
| P1 AUTH | 0b8bd214ca356b83677ab7e1a8c1b876b3491b9e53205fcf221a3b1428b0ee63 |
| P2 AUTH | ed0c6c559ab3ae53e6945ac43ed538d137a2579d13cc64caf1497b799d1944ff |
| Revised P1 field design | f15fad352cabb623c1f4b0dc1cd3f3b505e345a456de00265cdec1c5a9d4c2e3 |
| Measurement plan | c8f4b2020892f736f29fbb399ad35b019f54a253982f181c609d856742980ac9 |
| Round-1 review | e0d0bc7677fa79b775a329e83b723e50cc088938f9156019164af37a91108ee1 |
| Round-1 usage | 6f048595c21fcc9f28690e759fce363e7aa322dee9c1fb71abde2bd5b7b93a61 |

所有 source 证据均使用：

    git show 8e4ea0f1777f1175141731797afeee5ebd964c96:<path>

没有把 mutable working-tree source 当作证据。

## Claim 1 — Stage provenance

**结果：Pass with conditions**

### 依据

- Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift 的 TypoCorrectionRecallDriveEvent 当前只有 query(TypoCorrectionSuggestion)，没有 stage 字段。
- 同文件 TypoCorrectionRecallDriver.nextEvent 按 inFlight、Stage 1 queue、coverage assessment、startedStageTwo、Stage 2 queue 的顺序取事件。实际的取出点是 takeNextStageOne 与 takeNextStageTwo；在 yield 后，inFlight 会先被再次返回。
- Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift 的 continueOperation、handle 与 performQuery 只消费 query 事件，当前不会从 journal 顺序推导阶段。

proposal 在现有 dequeue 点把 stage 作为有限值域写入 driver event，并把该值随 inFlight 穿过 yield，符合当前状态机。它不会改变 debounce、selection、yield、fence 或 query budget，也不需要用 journal 相邻顺序或 operation ordinal 猜阶段。

### 条件、残余与证据

1. stage 必须在 takeNextStageOne / takeNextStageTwo 的返回路径赋值，并在同一个 inFlight query 经 yield 重放时保持不变；不得在 coordinator 通过事件先后推导。
2. Stage 1、coverage assessment 后的 Stage 2、yield 后重放、post-call fence discard 必须由 TypoCorrectionRuntimeIntegrationTests 直接断言。
3. owner：Input Intelligence Maintainer；Architecture reviewer 在实现 review 时复核 event 的 Codable/Sendable 有限枚举和测试。

## Claim 2 — Candidate-count meaning

**结果：Pass with conditions**

### 依据

- Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift 的 TypoCorrectionRecallRuntimeBudget.candidateLimit 是 3。
- 同文件 TypoCorrectionRecallDriver.finishQuery 对 coordinator 收到的 typed [RimeCandidate] 再执行 prefix(3)，并将 limited.count 写入 Stage 2 ledger。
- Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+CorrectionQuery.swift 的 correctionCandidates 通过已安装 bridge facade 取得字典并调用 parseCandidateWindowDictionary，返回 typed candidates。
- Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m 的 correctionCandidatesForInput:limit: 使用 safeLimit，读取 context.menu 的有限窗口，并跳过没有 text 的 candidate。
- Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift 的 performQuery 将 owner.correctionCandidates 的结果直接交给 driver.finishQuery；输入不是完整 RIME menu。

proposal 的 returned_candidate_bucket 语义精确指 coordinator 实际收到、经过现有 parser/limit、再经过现有 prefix(3) 的 typed candidates。zero 和 one_to_three 不表示完整 menu 大小、candidate usefulness、RIME CPU 成功或用户可用性。

### 条件、残余与证据

1. bucket 只能由 coordinator 收到的 typed array 生成，不能从 context.menu.num_candidates、hasMore 或未截断窗口推导。
2. focused tests 必须覆盖 0、1、3、超过 3 被 coordinator 截断，以及 parser 丢弃空 text 后的结果。
3. owner：Input Intelligence Maintainer 与 RimeBridge owner；证据为 KeyboardCore/RimeBridge focused tests 和无文本序列化断言。

## Claim 3 — Readiness and result state

**结果：Pass with conditions**

### 依据

- Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m 的 correctionCandidatesForInput:limit: 在 empty input、zero limit 或 ensureCorrectionSession 失败时直接返回空 candidates；ensureCorrectionSession 在同一个 manager/runtime 内检查 initialized、创建 correction session 并选择当前 schema。
- 同一方法在 ensure 成功后调用 set_input 和 get_context；get_context 返回 false 时当前实现也留下空 candidates，随后 clear_composition 并返回。
- Packages/RimeBridge/Sources/RimeBridgeObjC/include/RimeSessionManager.h 公开的 correctionCandidatesForInput:limit: 目前只承诺 candidates 字典。
- Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionCandidateQuery.swift 的 protocol 当前只返回 [RimeCandidate]；CandidateProviderTypoCorrectionQuery 是非 RIME/test provider。

proposal 把 readiness 和 result_state 放进同一次 installed facade invocation 的有限 result envelope，能够在不增加 probe call、第二条 RIME route 或 raw engine 暴露的情况下区分：

- sidecar_unavailable：同一次调用的 ensureCorrectionSession 失败；
- context_unavailable：ensure 成功但 get_context == false；
- candidates_returned：RIME ready 或 non-RIME/test unknown 下实际返回 typed array；
- empty_input / zero_limit：未执行 ensure/context 的 bounded validation return；
- ready empty：RIME ready、context 成功、typed array 为空，且 result_state 为 candidates_returned、bucket 为 zero。

### 条件、残余与证据

1. invalid-input 的边界必须与 empty_input/zero_limit 的关系写成一个有限枚举规则。当前 proposal 的 result_state 没有独立 invalid_input 值，不能让实现者自由选择 ready、unavailable 或 zero。
2. readiness 只能从同一次 bridge call 穿过 TypoCorrectionCandidateQuerying、InstalledTypoCorrectionSidecarOwner 和 coordinator，不能增加 RIME probe。
3. focused bridge contract tests 必须覆盖 ready-empty、ensure failure、schema-select failure、get_context failure、empty input、zero limit、non-RIME/test adapter unknown。
4. owner：RimeBridge owner 定义 bridge result；Input Intelligence Maintainer 维护 facade；Architecture reviewer 在 schema/API 冻结时复核。

## Claim 4 — Timing

**结果：Pass with conditions**

### 依据

- Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift 的 performQuery 当前执行 pre-fence、query begin marker、owner.correctionCandidates、post-fence、finishQuery 与 outcome marker。
- Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift 当前 DurationMetric 只有 elapsedMilliseconds 和 presentationAgeMilliseconds；以毫秒整数保存会把约 0.010 ms 量级的边界调用压成 zero。
- RimeEngineImpl+CorrectionQuery.swift 加上 RimeSessionManager.m 的 sidecar 方法，installed facade 区间包含 bridge call、set_input、get_context、candidate parsing 和 clear_composition；这不是 librime CPU-only 时间。

proposal 的 facade_elapsed_microseconds 应在 owner.correctionCandidates 前后用单调时钟包住完整 installed facade invocation，floor 到 microseconds，允许真实 under-1-us 为 zero，超过 UInt32.max 饱和并由 duration_saturated 标记。event construction、Date/JSON、fence、driver bookkeeping、queue submission 与 persistence 必须在区间之外。

### 条件、残余与证据

1. 明确 start/end tick 的异常、UInt32 饱和、zero 和没有发生 facade invocation 的表示；cancel-before-call 不得写成 zero-duration success。
2. facade duration 必须命名为 facade boundary duration，不能命名为 rime_cpu_time、engine_time 或 useful_time。
3. focused tests 必须覆盖 zero、floor、UInt32.max saturation，并证明 event construction 不在 interval 内。
4. owner：Input Intelligence Maintainer；Architecture & Knowledge Steward 复核字段与测量边界。P2 仍只能把它作为 Debug/Simulator facade duration，不得直接当 Product latency。

## Claim 5 — Diagnostics protocol

**结果：Blocker**

### 依据

1. **P1 AUTH allowlist 不包含所需 writer API 文件。**

   Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticEvent.swift 可以增加 schema v5、Code、typed payload 和 decoder；但新的 payload 不能通过现有 writer 入口送入 journal。Packages/KeyboardCore/Sources/KeyboardCore/DiagnosticsJournalRuntime.swift 的 public record 只接收 code、level、category、appearanceID、actionSequence 和 [DiagnosticEvent.Field]；它没有接收 composite payload 的方法。现有专用入口只覆盖 scheme-delivery 与 runtime-route payload。

   proposal 同时要求：

   - typo_recall.query_measured 的唯一 payload 是 DiagnosticEvent.TypoRecallQueryPayload；
   - generic fields 必须为空；
   - payload 在 measured interval 外构造并进入现有 bounded ingress。

   因而要实现精确 proposal，至少需要增加或改变 DiagnosticsJournalRuntime 的 writer API。这条路径不在 P1 AUTH allowed source paths（AUTH 的 allowed list 只列出 TypoCorrectionRecallMaterial.swift、TypoCorrectionSidecarOwner.swift、TypoCorrectionCandidateQuery.swift、DiagnosticEvent.swift、coordinator、RimeBridge correction query、RimeSessionManager.m/header）。本 reviewer 不能扩权，也不能把 typed payload 改写成 generic fields 来规避边界。

2. **当前 v4 decoder 没有完成 v4/v5 协议约束。**

   DiagnosticEvent.swift 当前 schemaVersion 为 4。Code 目前只有 typo_recall.query_begin 和 typo_recall.query_outcome，没有 query_measured。Field 是有限的 count/duration/flag/reason；init(from:) 会严格解码 Code、Field enum 与 composite payload，但当前没有只接受 schema 4/5 的 guard，也没有按 schema 版本约束新 Code 与 typed payload 的组合。新协议必须明确：

   - schema 4 历史记录仍按旧 keys、旧 payload 和当前已知有限 enum 解码；
   - schema 5 的 query_measured 必须有且只能有匹配的 TypoRecallQueryPayload；
   - missing/mismatched payload、query_measured 搭配 schema 4、unsupported schema、unknown Code/enum 都必须拒绝；
   - 新 payload 的 generic fields 必须为空。

3. **PR #182 的 schema4 enum 扩展需要显式兼容结论。**

   baseline 的 DiagnosticEvent.RimeSyncFailure 已包含 keychainAccessDenied = keychain_access_denied，但 schemaVersion 仍是 4。当前 baseline reader 可以认识这个值；PR #182 之前的 v4 binary 不能认识它。proposal 仅说明旧 binary 不保证读取 v5，未明确旧 binary 对这个 schema4 新 enum 的不兼容是否被接受，也未给出 v4 fixture 的 pre-PR/post-PR 兼容边界。该边界必须写入新的 schema decision，不能由实现者猜测。

4. **raw JSONL 与 in-app reader 的边界是正确方向，但不能替代 writer scope。**

   DiagnosticsJournal reader 的逐行 decode/compactMap 行为可能丢弃无法解码的行；它不适合作为 exact query count 的唯一输入。proposal 要求 P2 直接保留和 hash raw JSONL，并把 undecodable line 当作 censoring，且不改 DiagnosticsJournal.swift，这符合 content-free retention 边界。但它只能约束后续 evidence，不能解决本轮缺少 typed-payload writer API 的 P1 scope blocker。

5. **one-terminal-event cardinality 的设计本身可成立。**

   每次 coordinator 调用 installed facade 产生一个 query_measured；post-call fence discard 仍是这个 event 的 finite disposition，不再为同一次 query 产生第二个 query fence event；pre-call cancellation 没有 facade invocation，因此没有 query-measured event。现有 coordinator 的 query_begin/query_outcome 路径必须在新的 P1 query path 停止，保留的生命周期 event 只能代表 distinct non-query event。

6. **localSequence/drop 只能支持完整封存段的 exact count。**

   DiagnosticsJournalRuntime 在投入 ingress 前先递增 global localSequence；DiagnosticsJournalIngress 的 bounded queue 为 256，queue-full、suspended、生命周期 admission 失败和 writer failure 都可能丢失 event，health/drop 记录本身也可能延迟或丢失。因此 localSequence gap 只能证明存在未知丢失，不能识别丢的是 query-measured 还是其他 event；aggregate drop count 也不能反推出缺失 query 数。proposal 对此作了正确的 lower-bound/censoring 处理：只有 complete sealed segment、无 unexplained gap、无 undecodable line、无 queue/suspend drop、无 truncation 时才可报告 exact total。

### 必须修复、责任人与交接

1. **Human Product Owner / Product Lead**：明确是否授权把 DiagnosticsJournalRuntime.swift 加入 P1 source scope。新增 source path 后必须重建 numbered packet、baseline、manifest、AUTH binding 和独立 review；本轮不能消费现有 P1 AUTH。
2. **Architecture & Knowledge Steward + Input Intelligence Maintainer**：冻结 schema4/schema5 的 code-version-payload 矩阵，特别写清 keychain_access_denied 在 schema4 的 PR #182 兼容结论、旧 binary 边界和 unknown rejection。
3. **Input Intelligence Maintainer**：在新 allowlist 下实现 typed-payload writer API、one-event admission 和 post-fence disposition；不得改用 generic fields。
4. **Focused tests**：v4 pre/post-PR #182 fixture、v5 round trip、schema/code/payload mismatch、unknown version/code/enum、queue-full/suspend drop、raw serialization no-text/no-fingerprint。Test/Release 后续独立复核证据。

在上述 scope 与 schema repair 重新冻结并获得独立 review 前，Claim 5 不能转为 Pass with conditions，也不能转化为 P1 implementation approval。

## Claim 6 — Runtime ownership

**结果：Pass with conditions**

### 依据

- Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionSidecarOwner.swift 的 InstalledTypoCorrectionSidecarOwner 只包住既有 TypoCorrectionCandidateQuerying facade，不 unwrap raw engine、不创建 session。
- Packages/RimeBridge/Sources/RimeBridge/TypoCorrectionSidecarOwnerAdapters.swift 的 factory 只包装已安装 query facade；RimeEngineImpl+CorrectionQuery.swift 只通过 bridge.correctionCandidates 调既有 route。
- RimeSessionManager.h 明确所有方法必须在同一线程；RimeSessionManager.m 使用 correctionSessionId 旁路 session，在同一 manager/runtime 中 ensure 和选择 schema。主 session composition 不参与 correction query。
- ADR 0004 要求 process-local、serialized session operations；ADR 0025 要求单一 serial owner、checked Swift 6 isolation，禁止 @unchecked Sendable shortcut。shared-container lifecycle 也要求 Extension 不部署、不修复持久化 RIME。

把 readiness 作为同一次 correction query result 的值类型部分，不改变 sidecar session、线程/serial owner 或 installed route，符合 runtime ownership。

### 条件、残余与证据

1. 不得在 facade 外增加第二次 readiness probe；否则会增加 query、改变 timing boundary 并引入第二 RIME route。
2. 不得把 query 改成任意 background librime call，不得增加第二 session owner，不得使用 @unchecked Sendable。
3. 保留 beginTypoCorrectionRecall/endTypoCorrectionRecall、debounce、selection、yield、fence 和 candidate limit；若 responsive gate-on 路径使用 dedicated serial owner，correction query 也必须经过同一 owner。
4. owner：RimeBridge 与 Input Intelligence Maintainer；Architecture reviewer 复核 focused contract tests 和 Swift 6 isolation。

## Claim 7 — Observer cost and censoring

**结果：Uncovered**

### 已核对的边界

- Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift 的 performQuery 在 pre-fence 不匹配时不调用 facade；post-call fence 不匹配时当前会记录 fence discard 与 query outcome。
- DiagnosticsJournalRuntime.record 在进入 DiagnosticsJournalIngress 前创建 finite event；DiagnosticsJournalIngress.record 只做有界内存 admission 和异步 flush，不在该调用中同步 JSON/FileManager/disk write。
- ingress 的 queue-full、suspend 和 lifecycle admission loss 都是 missing-data signals，不能填充为 zero candidate 或 success。

proposal 的“构造一个 terminal event、放在 measured facade interval 之后、post-discard 作为 disposition、capture 不完整就按 lower bound/censoring”在语义上是正确的。但 Claim 7 还要求验证新 event 实际怎样创建并进入 bounded ingress；该路径依赖 Claim 5 所需的 DiagnosticsJournalRuntime typed-payload API，而该文件超出当前 P1 AUTH allowlist。因此按 packet 的“超出 P1 AUTH 文件边界则 Blocker/Uncovered，并停止依赖 claim”规则，本 claim 不得被写成 Pass with conditions。

### 修复、owner 与证据

1. 先完成 Claim 5 的 scope reauthorization 和新 packet，再验证 event construction/admission 在 measured interval 外。
2. Input Intelligence Maintainer 提供 cancellation、ready-empty、unavailable、unknown adapter、post-call discard、queue-full、suspend drop 的 focused tests。
3. P2 独立 capture 只在 raw JSONL、sealed 状态、localSequence gap、decode failure、queue/suspend drop 和 truncation 全部可审计时报告 exact total；否则报告 observed query-measured count 为 lower bound，missing query count 保持 unknown。
4. Independent Test / Release reviewer 负责 observer overhead 与 censoring evidence；P1 author 不得自行声明 Quality/Product cost acceptance。

## 总体修复责任与停止条件

- Input Intelligence Maintainer：stage、candidate bucket、result envelope、timing、terminal disposition 和 focused tests。
- RimeBridge owner：same-call readiness、get_context/invalid-input semantics、sidecar-only session、同线程/serial owner。
- Architecture & Knowledge Steward：schema4/v5 compatibility、PR #182 enum boundary、one-event cardinality、raw JSONL/reader boundary。
- Human Product Owner / Product Lead：任何新 source path、产品合同或 budget/Gate 边界的授权。
- Independent Test / Release reviewer：实现后验证 drop/censor、observer overhead 与 Debug/Simulator 限制。

本轮停止于 Blocker/Uncovered，未消费 P1/P2 AUTH，未编辑 source，未作 Product budget、Quality、QA-001 Gate、merge、TestFlight、Release、ADR acceptance 或 parent Close 判断。
