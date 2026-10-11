# P2实际路由与探针scope：最小兼容性设计范围

Status: Design scope approved / design completed — Human“可以继续，记得随时记录”；Human后续“批准，请继续吧”已接受两scope含义并批准独立实施；设备/测试未授权

依据：[固定候选只读链路核查](../evidence/typo-correction-002-int003-query-cost-p2-scope-readiness-readonly-001.md)。下一目标是排除“默认runtime路由与旧DEBUG scope接口不匹配”的阻塞；不再先安排Human盲目预热。

## 限定设计产出

1. 确定可复用的、内容无关的实际route/已安装facade身份观察入口。先区分defaultMainActor、mainActorResponsive、threadAffine及unavailable；不把默认值或App Luna选择当runtime route证据。
2. 评估现有query-cost probe在当前route上所需最小scope适配，绑定已有facade、owner lifetime及已有epoch。绝不从MainActor穿透线程隔离owner、创建session或调用Swift expr；若真实scope无法提供则明确unavailable。
3. 原P2必需query count/stage/readiness/bucket/apply-discard/facade elapsed与完整性不变；provider elapsed不冒称librime/CPU/UI耗时。若适配需要改变P2合同或准入，单列交Human决定，不自行修改。
4. 固定最小修改文件、验证覆盖和执行预算，列出一次运行准备步骤。既有事件传输工具和相关已验证证据复用，不随main推进反复编译或重录。

只输出一份设计及必要的实施Assignment/AUTH草案，Owner Architecture & Knowledge Steward，Executor当前Codex，Product Human。独立审查按最终具体增量需要安排，不重复泛化复审；没有新增存储协议、日志设施、配额/保留/UI等关闭前置。

## 停止和后续

无Swift/工程/测试改动、build/install、LLDB/设备/输入、prefs变更或强制生产fallback。发现真实架构/产品权限缺口则按缺口交Human决定。设计通过以后才新独立实施/验证AUTH；当前及历史consumed AUTH都不复用。

父TYPO-CORRECTION-002保持Active，无Gate/Close、发布/合并、ADR Accept、TestFlight/Release。

## 2026-10-10：最小设计结论（已批准并完成实施，验证待授权）

### 事实、选择与边界

当前固定候选ordinary build默认请求threadAffine/provider，但实际进程route未证实。只允许新增DEBUG观察在真实arm时直接报告route kind，不能根据默认值填写“实际threadAffine”。现有已安装owner的route、coordinator及owner线程发布的不可变diagnostics可用于观察，不需要新建RIME session或新增日志设施。

采用“两种scope、一个既有probe”：

| scope kind | 准入身份 | 查询/耗时解释 |
|---|---|---|
| 1 nativeCorrectionSession | route defaultMainActor；实际installed owner；现有纠错sessionOrdinal非零且Luna | 该已安装纠错query facade的调用计数及elapsed，仍不等于CPU或UI耗时 |
| 2 threadAffineProvider | route threadAffine；当前flags/bridge/coordinator一致；确为CandidateProviderTypoCorrectionQuery包装；owner ready、现有diagnostic session valid、epoch非零、owner发布effective schema为Luna | provider facade的调用计数及elapsed；不是librime correction session查询、真实owner线程执行或CPU耗时 |
| 0 unavailable / 3 unsupportedResponsive | 任一信息缺失或不一致；mainActorResponsive暂不实现 | 拒绝arm并保存数字原因/实际kind，不伪造身份、不自动降级 |

threadAffine scope绑定的是**实际installed facade生命周期**，不是不存在的MainActor correction session。必须由Human明确接受这个准入含义补充后实施；原query总量/stage/readiness/bucket/apply-discard/elapsed、完整性和隐私要求不降低。

不修改TypoCorrectionQueryDebugScope的旧语义，不把epoch填成“纠错sessionID”。使用独立的、仅probe编译条件可见的FacadeScope值类型，包含kind、facadeOrdinal、lifetimeOrdinal、schema有限码；可定义在现有QueryCostMemoryProbe.swift，避免新增工程source membership。

### 身份生成与读取

InstalledTypoCorrectionSidecarOwner增加probe-only facade ordinal：只在MainActor首次观察该实例时分配单调非零ordinal，随后稳定；替换owner产生新ordinal；溢出返回unavailable，不wrap，不使用ObjectIdentifier地址、不序列化raw native handle。分配不发生在query热路径。

kind1的lifetimeOrdinal为真实existing correction sessionOrdinal。kind2的lifetimeOrdinal为当前threadAffine owner epoch；读取现有owner发布diagnostics的session valid与effective runtime selection，只映射为有限Luna码，不输出schema字符串或native identity。观察过程中epoch前后变化、owner未ready、diagnostics缺失、native invalid、非Luna或route/facade错配均拒绝。不能只凭默认epoch=1或App“Luna当前使用”通过。

scope相等比较包含kind、facadeOrdinal、lifetimeOrdinal、schema；现有coordinatorOrdinal/FullAccess继续绑定。native session在同epoch内更换不声明为同一个correction session：provider证据只对应该facade/owner epoch，不提供native-session provenance，也不恢复RimeRuntimeProvenance。

### 生命周期与热路径

arm、sequence边界、freeze以及每次facade调用前后都复核观察scope；变化即沿用现有scopeChange invalidity/lower-bound语义，不改变真实query、fence、调度或候选结果。verifyScope仅观察，不得成为生产query的运行许可。scope读取只使用MainActor已安装owner与现有有限值快照，不用expr、主线程等待owner、文件读写、日志或新队列。

输出区分观测范围unknown与每次query的readiness unknown。前者仍不能arm或接受exact total；后者按现有facade合同原样记录，不能因为provider返回unknown readiness就伪造ready，也不能把它等同计数不完整。

### 固定尺寸的私有DEBUG wire v2

当前buffer/record数量、32-word header、20-word record以及128-byte arm诊断尺寸均保持。显式版本升为2，禁止旧parser把epoch误读成session：

- cost header[13]为lifetimeOrdinal；[16]为scope kind；[31]为facadeOrdinal；[12]仍coordinator、[14]仍schema。kind1/2都要求真实非零identity及Luna，其他kind拒绝exact admission。
- arm diagnostic word[10]为lifetimeOrdinal，[14]为kind，[15]为facadeOrdinal；word[9]仍coordinator，[11]仍schema，[12/13]仍runUUID。版本2允许失败时0身份及unsupported kind，arm結果与checks保持原意。
- 现有私有LLDB工具decoder及报告字段同步v2；历史v1证据原样保留。解析器不静默双解旧版，历史比较须显式version。checksum/严格decode/借用长度不变，不加存储协议。

这些数字layout只是Proposed；实施时任何超出该范围的字节数/协议语义调整须停止交Human。

### 最小文件范围及验证阶段

实施草案绑定下述10路径；其余生产RimeBridge/Bootstrap/ThreadAffine运行源禁止修改。仅DEBUG/probe段观察与codec调整，4个现有测试文件补正反例；不新建部署或engine接口。

阶段分开：

1. 新实施AUTH：source preimages匹配后修改10路径/必要private v2解码工具，strict Swift format/lint，固定新candidate。无test/build/设备/发布权限。
2. 验证另AUTH：先Core probe scope/codec正反例，再现有hostless Extension的scope/diagnostic/coordinator集成target；冻结suite列表/候选/环境、每项最多一次。失败先明确源或环境原因，不自动重跑全套。完整CI若未来拟合并仍另按AGENTS满足，有限验证不是可合并结论。
3. 必要增量独立Architecture/Quality只覆盖新scope隔离、身份失效、v2严格准入与证据覆盖；冻结packet后派发，不复审已通过的LLDB事件机制。
4. 正常App一次build/install及新Extension实例/arm诊断另绑定。先readonly route/ready，route未知或不支持不安排输入；kind2不要求为了创建MainActor session而预热，kind1才按真实query链路制定一次公开fixture。正式P2序列仍独立AUTH。

以上是阶段地图，不是本轮授予全部权限。当前0源码改动、0新增测试/编译、0设备操作，父Active。

### 经验与取舍

先看观察协议支持哪条runtime route，再决定是否预热。Luna设置、主session readiness、correction session和facade scope是不同事实。最小适配应保留来源kind和生命周期失效，不能取消guard或切回旧路由换取通过。私有wire改变含义必须升级版本，保持尺寸并拒绝旧parser误读，避免再增加归档/采集负担。


实施回执见[route scope实施](../evidence/typo-correction-002-int003-query-cost-p2-route-scope-implementation-001.md)。具体实现已固定candidate，但以下阶段地图不是全部执行授权；真实新scope验证尚未开始。
