# INT-003 P1 Query-Cost Architecture Review Round 1

## 结论

审查覆盖 1–7 全部 claim，但本轮不批准 P1 实现。总体结果为 **Blocker / implementation approval withheld**：claim 5 是 Blocker；claims 1、2、3、4、6、7 为 Pass with conditions。P1 AUTH 不应在本轮消费，source/Swift/ObjC/test 编辑不应开始。修复后若需要继续审查，应按 packet 要求建立新的 numbered round、精确 baseline/digest 与授权绑定。

本结论只评价冻结 source、field design、measurement plan、Assignment、两份 AUTH、ADR 0004/0025/0027、shared RIME lifecycle 与两个 playbook。它不构成 Quality/Performance/Product Gate、query budget、ADR acceptance、merge、TestFlight、Release 或 parent Close 结论。

## 身份与冻结输入

- Reviewer：`/root/int003_p1_arch_review_r1`，fresh-context、独立 Architecture & Knowledge Steward reviewer；未兼任 P1 executor/coordinator。
- Checkout：`/private/tmp/universe-keyboard-int003-query-density-diagnosis-20260925`；实际 HEAD `f72e41dec71e956922f664b66ce96138495922f8`，与 packet 冻结提交一致。
- P1 source baseline：`2b9b15ee2d1d903b3a948109b2c2217535bd5248`。
- Packet normalized SHA-256：`ecc05ba189e9115d76e645c0a3d32e7ccae3beb0095efeacce5c23c4535fa986`，通过将 packet digest 行中的值替换为 64 个 ASCII `0` 后独立计算，匹配。
- Source manifest SHA-256：`5c19b79be205ba9afe2e50f321283071695c0b2dd9c4bdda9a4723af535b6d8a`，匹配。
- Manifest 的 28 个冻结 git blob/SHA：28/28 匹配 baseline；Assignment、P1 AUTH、P2 AUTH、field design、measurement plan 五个 mutable snapshot：5/5 SHA-256 匹配。

## Claim 1 — Stage provenance

**结果：Pass with conditions**

**定位与依据：**

- `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift:81-87` 的 `TypoCorrectionRecallDriveEvent` 当前只有 `.query(TypoCorrectionSuggestion)`，没有阶段字段。
- `TypoCorrectionRecallDriver.nextEvent` 在 `:136-161` 先处理 `inFlight`、Stage 1 queue，再在 `startedStageTwo` 后处理 Stage 2 queue；`takeNextStageOne`/`takeNextStageTwo` 在 `:244-约270` 是实际取出点。
- `completeCoverageAssessment` 在 `:210-241` 才把 `startedStageTwo` 置为 true；`Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift:102-151` 只按同一个 `.query` case 调用 `performQuery`。

**判断：**阶段可在 driver 事件源处可靠产生，不需要以 journal 顺序、候选内容、yield 次数或 operation budget 反推，也不要求改变 debounce、selection、yield、fence 或 query budget。最小路径是让 query value 携带受控 `stageOne`/`stageTwo` enum，并在两个 `takeNext...` 分支赋值；coordinator 只转发这个值。

**条件与责任：**

1. `TypoCorrectionRecallDriveEvent` 的 stage 必须是有限、可 Codable/可测试的值域；不能把 corrected input、hypothesis 或任意字符串作为 tag。
2. 同一 in-flight query 在 yield 后重复观察时必须保留同一 stage；禁止在 coordinator 通过事件先后或 `operationOrdinal` 猜阶段。
3. `TypoCorrectionRuntimeIntegrationTests` 应覆盖 Stage 1 首个 query、coverage assessment 后的 Stage 2 query，以及 fence discard 不产生虚假的阶段成功。责任方：Input Intelligence Maintainer；测试覆盖由直接受影响的 KeyboardCore 测试承担。

## Claim 2 — Candidate-count meaning

**结果：Pass with conditions**

**定位与依据：**

- `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallMaterial.swift:5-8` 将 `candidateLimit` 固定为 3；`finishQuery:170-207` 在 coordinator 结果上再次 `prefix(3)`，并把 `limited.count` 交给 Stage 2 ledger。
- `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+CorrectionQuery.swift:5-8` 通过已安装 facade 调 bridge 并解析 typed candidates。
- `Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m:362-392` 使用 `safeLimit`，只把最多 `safeLimit` 个可解析 candidate dictionary 返回；Swift parser 还会过滤缺少/空 text 的项目。
- `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift:168-182` 的输入是 facade 已返回并解析后的 `[RimeCandidate]`，不是完整 RIME menu。

**判断：**`0` / `1–3` 可以无歧义表示“coordinator 在现有限制和 parser 后收到的 candidate 数量 bucket”。它不能表示 RIME 全部菜单大小、候选质量、用户 usefulness 或 query 成功。`query_succeeded` 当前只表示 fence 在 facade 后仍成立，已有 `DiagnosticEvent.Reason.typoRecallQuerySucceeded` 的注释也如此说明。

**条件与责任：**

1. 字段名和 schema 注释必须写成 `returned candidate bucket after limit/parser` 一类的明确语义；禁止使用 `menu_size`、`useful`、`rime_count` 等会扩大 claim 的名称。
2. bucket 必须由 coordinator 收到的 typed array 生成，保留 `0` 与 `1–3`；不能从 RIME context 的未截断 `num_candidates` 或 `hasMore` 推断。
3. 测试应覆盖 0、1、3、超过 3 被截断，以及 parser 丢弃空 text 的情况。责任方：Input Intelligence Maintainer 与 RimeBridge test owner。

## Claim 3 — Sidecar readiness

**结果：Pass with conditions**

**定位与依据：**

- `Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m:362-365` 当前在空 input、zero limit 或 `ensureCorrectionSession` 失败时都返回相同空 candidates 字典。
- `ensureCorrectionSession` 在 `:562-575` 负责 initialized 检查、创建 correction session 与 schema 选择；失败后销毁并清零 correction session。
- 同一方法 `:374-389` 对 `get_context` 失败不产生额外状态，直接留下空数组；`:391-392` 清理 correction composition 并返回 candidates。
- `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionCandidateQuery.swift:1-13` 与 `RimeEngineImpl+CorrectionQuery.swift:5-8` 当前 facade 只返回 `[RimeCandidate]`，没有 readiness/result envelope；`CandidateProviderTypoCorrectionQuery` 是非 RIME/test fallback。

**判断：**在同一次已安装 correction-query facade 调用中携带有限 readiness result，架构上可以区分 `ensureCorrectionSession` 失败与 ensure 成功但 candidate array 为空。`ready` 的定义应是 correction session 已通过 `ensureCorrectionSession`；`unavailable` 应表示该 readiness/setup 失败；非 RIME/test adapter 使用 `unknown`。但当前 proposal 没有冻结 `get_context == false`、空 input 或 zero limit 的最终语义，因而尚未达到可直接实现的边界。

**条件与责任：**

1. 必须定义 `get_context` 失败：不得静默编码成 ready-empty。可采用另一个有限 query state，或将其明确归入 unavailable/unknown，并在 schema 与证据解释中保持可区分性。
2. 空 input/zero limit 的“未实际尝试”必须有显式有限语义，不能伪装成 ready-empty 或 setup unavailable。
3. readiness 必须从 bridge 同一次 query result 穿过 `TypoCorrectionCandidateQuerying`/installed owner；不能新增 probe call、raw engine 暴露或第二条 RIME route。
4. 增加 bridge contract tests：ready-empty、ensure failure、get_context failure、schema-select failure、empty/zero-limit、non-RIME adapter unknown。责任方：RimeBridge owner 定义 bridge result，Input Intelligence Maintainer 维护 facade，Architecture reviewer 在 schema 冻结时复核。

## Claim 4 — Timing precision and name

**结果：Pass with conditions**

**定位与依据：**

- `Keyboard/Controllers/TypoCorrectionRecallCoordinator.swift:154-184` 当前在 `query_begin` marker 后调用 `owner.correctionCandidates`，再做 live fence、driver bookkeeping、outcome marker；没有 facade duration 字段。
- `DiagnosticEvent.DurationMetric` 当前只有整数 `elapsedMilliseconds` 与 `presentationAgeMilliseconds`；`DiagnosticEvent` 以 `monotonicNanoseconds` 作为事件时间，但 decoder/field vocabulary 在 `DiagnosticEvent.swift:770-880` 是严格受控的。
- `RimeEngineImpl+CorrectionQuery` 与 `RimeSessionManager.m:368-392` 的 facade 区间包含 set_input、get_context、candidate parsing、clear composition 及 session boundary；它不是 librime CPU-only 时间。
- field design 已记录历史调用约 `0.010 ms` 量级；毫秒整数会把这类调用压成 0，无法回答边界成本问题。

**判断：**应以单调时钟紧贴包裹 installed facade：在 `owner.correctionCandidates` 前取 start，返回后立即取 end；driver/fence/journal/UI work 不得进入该 duration。应使用有界 microsecond 整数或预先冻结的 timing bucket。推荐有限名称 `facade_elapsed_microseconds`（或等价明确表示 facade boundary 的名称）；不得称为 `rime_cpu_time`、`engine_time` 或 `useful_time`。

**条件与责任：**

1. 明确 clamp/overflow/zero 的编码规则；duration 缺失、cancel-before-call、discard-after-call 必须有有限的非成功状态，而不是写 0 伪装成快速成功。
2. 记录 timing 的代码应在 measured interval 外构造 diagnostic event；不要把 Date/JSON/queue submission 纳入 facade duration。
3. 新 duration vocabulary 需同时满足 Claim 5 的 schema compatibility 方案。责任方：Input Intelligence Maintainer 实现，Architecture & Knowledge Steward 复核命名与边界。

## Claim 5 — Diagnostics protocol

**结果：Blocker**

**定位与依据：**

- `DiagnosticEvent.swift:7-8` 当前 schema version 为 4；`Field` 仅允许 finite `count/duration/flag/reason`，不能接收任意 string（约 `:118-204`）。这符合 ADR 0027 的 content-free allowlist。
- `TypoCorrectionRecallDiagnosticMarkers.fenceFields:24-31` 当前包含历史 `compositionFingerprint`。field design 明确禁止把它复制到新的 cost aggregate；新 query fields 不应携带 composition/hypothesis/candidate/host text 或新 stable fingerprint。
- `DiagnosticEvent.init(from:)` 在 `:867-880` 严格 decode schema、Code、字段 enum 和 fields；没有按 schema version 做兼容分支。旧 reader 遇到新增 Code/CountMetric/DurationMetric/Reason 值会在 enum decode 失败；仅仅保留 `schemaVersion` 数字不能提供 backward decoding。
- `DiagnosticsJournalIngress:7-20,59-79,89-118` 有界队列为 256，queue-full 与 suspended drop 在内存中累计并通过延后的 health event 尝试报告；它没有保证每个 query event 永久落盘。
- 现有测试 `DiagnosticEventTests:461-524` 只证明当前 typo code/fields 的 round-trip 与无文本，不覆盖旧 schema 解码、新字段兼容、query event drop 或新 readiness/timing envelope。

**判断：**proposal 只要求“任何 DiagnosticEvent field extension 经过 ADR 0027 allowlist 与 schema/compatibility decision”，但没有提供本轮实现所需的具体 versioning/backward-decoding 方案，也没有冻结 query event 的 cardinality/pairing。这个缺口直接影响已有 journal 读写协议、旧记录可读性、drop 后的计数解释，属于架构 blocker。

**必须修复后才能消费 P1 AUTH：**

1. 由 Architecture & Knowledge Steward 与 Input Intelligence Maintainer 先冻结 schema 方案：例如 bump schema 并实现旧版本读取/迁移，或定义经审查且真正 backward-compatible 的有限 envelope；必须明确未知 code/field 的 decoder 行为和旧 JSONL 的保留语义。
2. 在 schema 方案中冻结 stage、candidate bucket、readiness、facade duration、terminal/censored state 的有限值域；不得用自由文本、candidate/input/host text 或新 fingerprint。
3. 优先一个 query aggregate/terminal event，避免当前 `query_begin` + `query_outcome` 两事件各自携带 fence fields 后再叠加字段；若保留两事件，必须增加有限 attempt pairing 与 missing/drop 语义，不能依赖 journal 相邻顺序。
4. 增加旧 schema fixture、新 envelope round-trip、未知版本/未知字段的预期行为、queue-full/suspend drop 可见性与不泄露文本的测试。责任方：Input Intelligence Maintainer 实现；Architecture reviewer 复核并签署 ADR 0027 compatibility decision；Quality reviewer 在实现后验证。

在上述 repair 与新的冻结审查之前，claim 5 不能被解释为“Pass with conditions”，也不能转化为 P1 implementation approval。

## Claim 6 — Runtime ownership

**结果：Pass with conditions**

**定位与依据：**

- `Packages/RimeBridge/Sources/RimeBridge/RimeEngineImpl+CorrectionQuery.swift:5-8` 只调用已有 `bridge.correctionCandidates`；`TypoCorrectionSidecarOwnerAdapters.swift` 与 `TypoCorrectionSidecarOwner.swift` 将其包在 installed facade 中，没有 raw engine unwrap。
- `RimeSessionManager.h` 的 session contract 明确所有方法必须在同一线程；`RimeSessionManager.m:362-392` 使用已有 `correctionSessionId` 旁路 session，主 session composition 不参与；`:562-575` 在同一个 manager/runtime 内 ensure 并选择 schema。
- `ADR 0004` 要求 process-local session 与序列化调用；`ADR 0025` 保持单一 serial owner、禁止并行 librime route 与 `@unchecked Sendable` shortcut。`TypoCorrectionRecallMaterial` 也明确 driver 不调用 RIME。

**判断：**把 readiness 作为同一 correction facade result 的有限部分，保留已安装 sidecar session 和已有 route，可以满足 runtime ownership。它不需要新 RIME route，也不应把 session handle/raw engine 暴露给 KeyboardCore。当前 MainActor coordinator 的同步调用与 header 的同线程约束一致。

**条件与责任：**

1. readiness 不得通过 facade 外的第二次 RIME probe 获得，否则会增加一次 query、改变 measured boundary 并引入第二 route。
2. 不得将 correction query 改成独立 background librime call；不得引入第二 session owner、`@unchecked Sendable` 或绕过 ADR 0025 的隔离。
3. 保留 `beginTypoCorrectionRecall`/`endTypoCorrectionRecall` 对既有 owner lifecycle 的保护，并保持 debounce、selection、yield、fence、candidate limit 不变。责任方：Input Intelligence Maintainer 与 RimeBridge owner；任何 route/threading 变更需回到 Architecture review。

## Claim 7 — Observer cost and censoring

**结果：Pass with conditions**

**定位与依据：**

- `TypoCorrectionRecallCoordinator.performQuery:154-184` 当前在 facade 前后记录 marker；pre-fence cancellation 在 `:156-161` 没有真实 query call，post-call fence failure 在 `:173-180` 记录 discarded；正常返回在 `:182` 无论 candidates 是否为空都写 `typoRecallQuerySucceeded`。
- `TypoCorrectionRecallDiagnosticMarkers:24-31` 每个 marker 构造 5 个 fence fields，其中包含历史 fingerprint；`DiagnosticsJournalRuntime.record`/`DiagnosticsJournalIngress.record` 仅在 HF 开启时进入 bounded value queue，但 `Ingress` 的 `pending.withLock`、sequence/time/event construction 仍是同步观察成本，不能再叠加新的同步 persistence/lock/JSON/DateFormatter。
- `DiagnosticsJournalIngress` 的 queue-full/suspend drop 是 best-effort health 事实；事件丢失不能被当作 zero candidates 或 successful nonempty query。

**判断：**本 proposal 可以保持 observe-only 与有限成本，但必须将 instrumentation 本身的增量成本作为 P1/P2 evidence，且不能把 dropped/cancelled/discarded/incomplete/unknown 当作 successful nonempty query。query aggregate 应在 HF guard 后构造，并在 measured facade 区间外 enqueue；优先一个 event，减少当前两事件协议的额外队列压力。

**条件与责任：**

1. 用独立有限 terminal/censor state 表示 cancel-before-call、discard-after-call、incomplete/no terminal、queue/suspend drop、readiness unknown；candidate bucket `0` 只在真实返回的 typed result 上产生，不能代替这些状态。
2. 记录 drop visibility 与 high-fidelity enabled 状态；P2/后续 evidence 对缺失 event 按 censoring 处理，而不是补成 zero 或 success。
3. 先做 instrumentation off/on 的同环境 overhead comparison；在未有该 receipt 前，不作 key-path latency/memory acceptance。责任方：Input Intelligence Maintainer 负责实现与 focused tests；Independent Test/Release reviewer 负责后续 evidence，不由 P1 author 自行声明 Quality。
4. 测试 cancellation、post-call fence discard、ready-empty、unavailable、unknown adapter、queue-full、suspend drop、incomplete event pairing，并断言无文本/无 fingerprint 新增。

## 修复责任、交接与停止条件

1. **Input Intelligence Maintainer**：冻结 typed driver query event、candidate bucket、censor state 与 facade timing 的实现边界；补齐 KeyboardCore/Coordinator focused tests。
2. **RimeBridge owner**：在同一次 correction query result 内提供 readiness 与 `get_context`/invalid-input semantics；保持 sidecar-only session、同线程/serial owner 与 schema selection 生命周期。
3. **Architecture & Knowledge Steward**：先完成 ADR 0027 schema/version/backward-decoding 决策和事件 cardinality/pairing 审查；这是本轮 claim 5 的 blocker owner。
4. **Independent Test/Release reviewer**：在新实现与 P2 evidence 后独立验证 drop/censor、observer overhead 与 Debug/Simulator 限制。
5. 修复涉及新的 source/schema/boundary 时，按 packet 的要求创建新的 numbered review round、exact baseline/digest 与相应授权；本轮不消费 AUTH、不写 source、不改变 Assignment 生命周期。

## Non-claims

本审查没有运行 build/test，没有访问真实 journal/用户数据，没有启动 Simulator/设备，没有评估 RIME 二进制部署，没有作 Release-like cost、Product budget、QA-001 Gate、merge、TestFlight、Release 或 parent Close 判断。
