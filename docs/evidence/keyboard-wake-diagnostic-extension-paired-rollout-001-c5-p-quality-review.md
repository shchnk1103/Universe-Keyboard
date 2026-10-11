# QUALITY-C5-P 独立 Quality Review

## Scope 与身份

这是未参与 C5-P 实现的独立晋级前补审，仅覆盖 P-Q1、P-Q2、P-Q3。Human 授权不包含 C5-I/R、设备操作、安装或运行采集。本报告不作 Product residual acceptance、安装授权、整体 Quality Pass 或 Release Gate 结论。

冻结 packet SHA-256：81dfc80d0197ebd2cc34653e851a94bbd24a144e95aee03f88e02548a78035a5。输入 manifest SHA-256：928bfdd6412ce5b23bdad7cece3141e00c993d191079ea2b7ed692662f06d941。C5-P Entry SHA-256：8e507a253fcb89f0d8570ce0b980c029c59b1ec5c452db84b71545da94454dc7。三者均与派发值匹配。当前身份核验：HEAD 84b9c19227330b0fe6ff391be001ee398010fd6a，branch codex/keyboard-wake-v3-compatibility-gate，worktree /Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard，与冻结值 匹配。冻结候选摘要为 af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9；40/40 文档输入、568/568 source/build 输入、111/111 Debug bundle 文件哈希匹配。

## 正向覆盖

| Criteria | 评审覆盖 | 证据与判断 |
|---|---|---|
| P-Q1：C4 证据复用及 30 skip 对 C5 的影响 | Covered | C4 记录为 Core 1184/0 failures、Rime 85 passed + 20 skipped、App/Keyboard 421 passed + 10 skipped。冻结 inventory 中 30 项仍全部是 skipped；其中 Rime 项涉及 Lua/T9 Spike/R4-B 等真实运行环境，App 项涉及 archive、Keychain entitlement、Ice/Wanxiang fixture 和 TD-012 physical-device 条件。C4 Round 2 的 Product 接受明确仅适用于 C4；C5 提案也明确不继承，要求由 Product 为 C5 单独处理。单次受控输入可限制暴露范围，但会走真实 keyboard visibility/RIME resume 边界；C4 的 skipped real-engine 环境用例因此仍是运行 readiness 的不确定性。报告没有替 Human 接受该残项，也没有将它们改记为通过。 |
| P-Q2：安装后身份检验与可执行宿主前置条件 | Covered | 冻结 Debug bundle 的 App ID 是 com.DoubleShy0N.Universe-Keyboard，appex ID 是 com.DoubleShy0N.Universe-Keyboard.Keyboard，均 version 1.0/build 1；appex plist 声明 keyboard-service principal class 与 RequestsOpenAccess。codesign verify 成功；Mach-O entitlement receipt 显示两端的 application-group 值相同。完整 payload manifest 覆盖 111 文件及 11 个 Mach-O 的 SHA-256、size、UUID 输出；所有 11 项均有 UUID 输出。提案要求 C5-I 安装后重新比对真实 App/appex 身份及全部 11 个 Mach-O，并核验 keyboard 设置、Full Access、App Group 可访问性、RIME 资源和宿主可用性。Settings 中的 searchable 词典字段提供候选宿主，但静态 plist 的 RequestsOpenAccess 不证明用户已启用 Full Access；当前没有安装或运行环境证据。 |
| P-Q3：一次采集、reader 验证及残项 | Covered | 提案把未来 C5-R 限定为一次授权采集、一次合成输入、无自动重试、动态 extension JSONL 窄筛选、同一 Main App reader 消费，并要求保留完整性/拒绝/fallback 状态；避免保留输入文字、候选、截图或完整历史日志。源代码显示 KeyboardViewController 生命周期与 RIME resume marker 的调用边界，proxy adapter 在实际调用周围记录 entered/returned；Main App DiagnosticsLogSource 从 App Group v1 路径调用 DiagnosticsJournalReader，reader 扫描 open/sealed JSONL 段并累积 decode completeness。对 marker 只报告 started 或 UIKit 调用 returned，不宣称 RIME ready、宿主接受或输入成功；提案也注明两秒等待不是持久化保证。 |

## Findings

| ID / 严重性 | 证据位置与影响 | 责任人 / 最小建议 |
|---|---|---|
| C5P-Q-01：C5 Product 决定依赖 | C4 supplement product disposition 与 C5 slice 提案的 C5-P Exit。30 项仍未验证，且部分真实 RIME 环境 residual 与受控暴露中的 RIME resume 有关。C4 接受不跨阶段，Quality reviewer 无权替 C5 接受。 | Human Product Owner / Product Lead：C5-P Exit 前记录当前 C5 的精确残项决定；若未决定，不进入 C5-I。 |
| C5P-Q-02：实际安装与宿主 readiness 尚待 Entry | C5 preparation payload/entitlements/signing 证据及 C5-I 计划。它们证明候选构建载荷与拟定核验方法，不证明已安装配对、Full Access、App Group runtime access、可激活键盘或 RIME readiness。 | Environment Executor 与授权人：仅在 C5-I 单独授权和 fresh exclusive window 后，按计划逐项验证；未满足则 Hold。 |
| C5P-Q-03：marker 的可观测边界 | DiagnosticEvent v6 与 proxy adapter 源码、C5-R 采集计划。生命周期/RIME marker 没有可用 actionSequence；resume started 不表示成功，proxy returned 不表示宿主接受。既有 ADR 0036 Addendum 002 的 duplicate JSON member 检测限制仍未解除。 | Quality/Architecture：采集和报告严格保留这些语义边界；有缺失或不完整记录时标为 inconclusive，不补造因果或隐藏拒绝。 |

## Verdict 与后续边界

P-Q1、P-Q2、P-Q3 的设计审查覆盖完整，**未发现阻止完成 C5-P 独立 Quality review 的设计级 Quality blocker**。这不等于 C5-P Product Exit 已完成：C5 专属 Product residual 决定仍待记录。C5-I/R 的实际安装身份、宿主/Full Access/App Group/RIME readiness、真实 appex callback 与日志 reader 运行验证仍是未来 Entry，且需要各自授权及 fresh lease。本轮没有执行 build、test、Simulator、安装、输入、捕获、Maps 或 Git mutation。