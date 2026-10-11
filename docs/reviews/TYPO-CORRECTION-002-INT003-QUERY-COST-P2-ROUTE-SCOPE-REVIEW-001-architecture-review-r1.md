# 架构独立增量复审

## 结论

**Changes requested。** A1–A3 与 A4 的候选实现/设计符合性已完整覆盖，未发现实现缺陷；但测试执行绑定中声明的 Extension 预期数与其余冻结回执不一致（AR-01）。这是一项证据元数据问题，不改变原始日志所列的 19 + 33 个通过项，也不构成运行时结论。

## 身份与输入完整性

- Packet：`/private/tmp/uk-routerev1/packet.json`，SHA-256 `a40aff12b6e47a40cf3b3039faf781272db31286a931b2220b3730d973ad7f0c`，匹配入口声明。
- 冻结 inputs：94/94 SHA-256 匹配；候选列出的 25 个源码文件摘要与 `source/` 冻结副本 25/25 匹配。差异清单为 10 个变更路径、15 个非范围路径未变。
- 仅静态读取冻结源、设计、治理及验证回执；未执行测试、构建或 decoder，未操作设备、网络或源码。

## 四项 Architecture Criteria

### A1 — route 来源与身份生命周期：Pass

`KeyboardViewController+TypoCorrection.swift:90–126` 以已安装的 `InstalledTypoCorrectionSidecarOwner` 为入口。native 分支复用其现有 correction-session scope，并以 route flags 拒绝不匹配状态；thread-affine 分支要求 dual flags、bridge、CandidateProvider facade 和已有 coordinator 同时成立，前后读取 epoch、runtime selection、native-session validity 与 ready 状态；值缺失、不一致、epoch 为零/变化或非 Luna 均转 unavailable。没有新建 session 或改变 production route。

native scope 的来源为 `RimeSessionManager` 只读 DEBUG getter（`RimeSessionManager.m:589–598`）；它在 session 缺失时回零、不返回原生句柄或 schema 文本。既有 ordinal 在创建纠错 session 时递增并对溢出 fail closed（`:632–654`）。thread-affine 读取来自 owner 已发布的不可变诊断快照（`ThreadAffineRimeSession.swift:297–327`；`ThreadAffineRimeSpike.swift:779–791`），不是把 epoch 命名或编码成 native correction session ID。

### A2 — v2 codec、尺寸、隐私与借用边界：Pass

`QueryCostMemoryProbe.swift:17–54,398–409,422–443` 把 kind、facade ordinal 与 lifetime ordinal 分开编码；32-word header、20-word record 与 655,616-byte 上限不变，strict decode 只接受 v2 与明确 kind。`QueryCostArmDiagnostic.swift:27–77` 保持 16 个 UInt64 / 128 bytes，armed scope 必须是 kind 1 或 2、非零身份与 Luna schema。私有 `decode-v2.py:6–25` 对齐相同的 v2、精确长度、short-circuit 及 armed-scope 限制，只读取并返回数字和哈希；不接受 cost record 或 v1。

两种 wire 仍只含数字、有限枚举、随机 run UUID 的字节及计数；不含文本、schema 字符串、engine/session 句柄或持久化。arm 数据与冻结快照均在 `withUnsafeBytes` 闭包内同步传指针（`QueryCostArmDiagnostic.swift:79–87`；`KeyboardViewController+QueryCostProbe.swift:117–120`），没有延长借用期。

### A3 — DEBUG 隔离与原 query 行为：Pass

变更后的 probe/controller 实现受 `#if DEBUG && KEYBOARD_QUERY_COST_PROBE` 包围；工程中的 `QUERY_COST_PROBE_CONDITIONS` 默认空，验证命令才显式启用 probe 宏。arm eligibility 继续按 elapsed → touch → callbacks 短路，回调副作用至多执行一次（`QueryCostArmDiagnostic.swift:14–25`）。Coordinator 增量只在 probe 已 armed 时做 scope 检查，随后仍调用同一 `owner.correctionQueryResult`，使用原 pre/post fence、结果与调度路径（`TypoCorrectionRecallCoordinator.swift:278–339`）。验证证据记录的 Core 与 hostless Extension 命令均显式启用宏；这些回执不是 Release 默认编译证明。

### A4 — 变更范围、批准 scope 与证据边界：实现 Pass；证据记录 AR-01

冻结设计批准 native-session 与 provider-facade 两种 scope；unsupported responsive、缺少身份和未知值拒绝准入，且 elapsed 只指被标记 facade 的调用，不宣称 CPU 或完整 UI 成本（产品决定 `...LOCAL-EVIDENCE-REQUIREMENTS-001.md:36–40`；设计 `...route-compatibility-design-001.md:28–60`）。10 个目标路径与 manifest 精确对应，15 个非范围路径摘要保持不变；没有扩到 RimeBridge/Bootstrap/生产路由。

验证回执的 Core 19 项与 Extension 33 项在被冻结日志中均逐项通过；4 个测试类的源码测试方法名与 raw passed log 名称逐项相等。其绑定 candidate SHA 与本轮 candidate 相同。回执明确未覆盖 normal App install、手工输入、实际 route/arm、正式 P2 采集、完整 CI 或 Gate（验证证据 `...route-scope-validation-001.md:3–5,127–131`）。

**AR-01 — 执行绑定预期数不一致（证据元数据，需修正）**

- 精确位置：`/private/tmp/uk-routerev1/validation/execution-binding.json#/expected_extension_tests` 为 `34`。
- 同一冻结证据中的 `validation/coverage.json` 为 8 + 15 + 10 = 33；`validation/extension-summary.json` 与 raw `validation/extension.stdout` 也是 33；`validation/final-identity.json` 记录总计 52（Core 19 + Extension 33）。
- 原始通过清单与 52 总数彼此一致，因此没有证据显示漏跑了一项；但执行绑定预期值仍与实际选择的三套目标不一致。请证据所有者把该字段与其余回执对齐后，再把 execution binding 当作精确执行合同引用。

## 结论边界

本结论只覆盖冻结候选的 Architecture 增量审阅。未验证真实用户 route、实际 arm/导出、runtime 成本或 P2 完成情况；不作 Gate、Release、可合并或实际根因判断。
