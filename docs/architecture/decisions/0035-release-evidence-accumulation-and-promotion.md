# ADR 0035: Release Evidence Accumulation and Candidate Promotion

## Status

**Accepted — Conditional Accept package, 2026-09-15 Asia/Shanghai.** Human Product Owner formally accepted this ADR as the binding architecture decision for the bounded release-evidence workflow. The implementation candidate is recorded at `ad39f443b7f77d96c28359bd652356a89bb173de`; this adoption does not authorize merge or external distribution, and does not grant Product Gate, Quality Pass or Release Pass.

## Context

每次 Beta 上传都重做完整的性能、崩溃、权限、共享容器和全部功能矩阵，会把“候选身份变化”和“风险边界变化”混为同一件事。另一方面，直接把上一次 Beta 的通过结果复制到新构建，也会把旧 artifact、旧环境或旧行为合同误当成当前证明。

项目已有独立的 CI 变更分类和 Main App 内容无关诊断日志。发布流程需要一个同样可追溯、但不改变现有 CI 或 Release 权限的证据层：

1. 先冻结当前 candidate fact tuple；
2. 按变更路径选择 delta、triggered 或 baseline；
3. 将未受影响且身份/环境/合同仍相容的记录作为 comparator 或 current-proof；
4. 为当前候选补齐 changed path、affected path 和 external-only 检查；
5. 保留 Product、Quality、Release 和 App Store Connect 的独立决定边界。

## Decision (Accepted)

Human Product Owner formally accepts the decision below as a binding architecture
decision for the bounded implementation and future release-evidence records that
adopt this contract. The Conditional Accept package preserves the independent CI,
Quality, Product, device and Release boundaries described in this document; it does
not make an evidence record an approval.

### 1. 两个分类器保持独立

scripts/release/release_evidence.py 只生成 release validation profile。现有 scripts/ci/classify_changes.py 继续决定 CI 是否为 docs-only 或 full。任何源码、工程、测试、RIME、工具链或未知路径改动都不能因为 release profile 为 delta 而跳过 CI full。

### 2. 三档发布验证

- delta：普通 UI、文案或低风险运行时改动，只刷新直接修改路径和受影响功能的最小证据；
- triggered：触及键盘、RIME、生命周期、性能/崩溃、Full Access 或 App Group 等边界，刷新对应触发用例；
- baseline：首次外部候选，或触及产物、工具链、权限、支持矩阵和 RIME 资源闭包，重新建立基线。

证据分类失败或路径不可判定时 fail closed 到 baseline；docs-only 只说明文档检查，不成为候选发布证据。

### 3. Beta evidence reuse

日常 Beta 是 evidence-producing run，不是自动的 Release Pass。正式外部候选可以引用该 run：

- 最小 artifact identity 固定为五个字段：`source_commit`、`version`、`build`、`archive_sha256`、`package_sha256`。五字段都存在、格式有效且完全一致，只是 exact-artifact 的必要条件；`rc_tag`、UUID、dSYM、Cloud build、RIME manifest digest 和 toolchain 是额外 provenance，不能替代这五个字段；
- exact-artifact 之上的 current-proof 还必须同时绑定相同的 `behavior_contract`、`validation_profile`、`device_model`、`os_version`、candidate ID、App version/build、`release-evidence-v1` 契约版本，并且证据时间戳不早于候选且不超过 30 天；任一上下文缺失、不一致或过期都不能给出 current-proof；
- 新构建或身份未完整核对：reusable_as = comparator，并必须产生当前 delta；
- 任一关键身份不一致、未知或证据为 fail/inconclusive/not-run：reusable_as = none，或者保持未定，不得静默晋级。

无论哪一种复用结果，external candidate readiness、独立 Quality review、Product Gate 和 Release Pass 都必须独立记录。

外部候选 receipt 也必须携带可机器检查的基线来源：首次候选只能来自带有
`first_external_candidate=true`、`profile=baseline` 和固定 reason 的 verified plan；后续候选必须由已验证的 previous external receipt 生成，并记录其 receipt ID 与文件 SHA-256。缺少首次 marker 或历史 receipt 时，receipt 命令 fail closed。Main App 的 pending promotion 不具备上述 artifact/context 验证能力，因此其总体 outcome 永远不是 pass；它只是等待 Candidate receipt 的本地记录。

### 4. Main App evidence session

Main App Diagnostics 增加本地发布证据会话，保存：

- 候选标识、App 版本/构建、设备/系统；
- 当前 Main App 会记录版本化的 `keyboard-behavior-v1` 行为契约；历史记录缺少该字段时解码为 `UNKNOWN`，不能被 current-proof 静默补齐；行为验收合同变化时必须显式变更该版本；
- release lane、validation profile；
- 有限的候选身份、变更路径、受影响冒烟、触发/基线边界和外部就绪结果；
- outcome、promotion source 和 promotion mode。

会话写入 App Group Diagnostics/v1/release-evidence/records.json，最多保留 50 条并使用原子 JSON 写入。它与诊断 JSONL 分开，清空诊断日志不得清空发布证据。页面不读取或持久化输入、候选文字、宿主文字、词典、完整日志、archive 内容或凭证。release-evidence 子空间沿用 ADR 0027 的 Main App ownership 规则，但不加入 JSONL generation 清理；损坏的 records archive 在明确 save 时保留为 quarantine 副本后重建，步骤 note 有固定长度上限。清除诊断日志必须通过自动化测试证明不会删除该子空间。

## Alternatives Considered

- 每个新 build 都重做完整矩阵：证据强，但成本与风险触发无关，无法持续执行。
- 完全继承上次 Beta 证据：成本低，但会混淆 artifact identity，不能证明新构建。
- 只依赖现有 CI：能保证代码质量层，但不能覆盖设备、签名、TestFlight、共享容器和人工 Release Gate。
- 将证据会话写入现有诊断 JSONL：查询统一，但会混淆操作日志与发布事实，清空/保留策略也不同。

## Consequences

正面：

- 普通小改动只补变更路径和受影响路径，减少无必要的完整重测；
- Beta 证据可以继续为正式外部候选提供可追溯基线；
- 新 build 的当前 delta、旧证据的 comparator 角色和外部专属检查在同一记录中可见；
- Main App 可以直接查看和导出有限证据，减少跨工具搬运。

代价与边界：

- 维护变更分类和 candidate tuple 的成本转移到发布前；
- 证据复用需要核对五字段 artifact identity、环境、行为合同、证据契约、候选绑定和 freshness，不能只看 build number；
- App 内标记仍是 evidence record，不是独立 Quality 或 Product 决定；
- 真实 archive/export、真机、App Store Connect 和正式门禁仍需要各自的外部证据。

## Risks

- 路径分类表过窄，导致高风险改动被错误归为 delta；
- artifact 字段不全时误报 exact artifact；
- 人工把 comparator 误读为 current-proof；
- 本地 App Group 文件被当作跨设备同步或 Release source of truth；
- 复用证据过期或环境变化，却没有触发 baseline。

## Follow-up

1. ~~独立 Architecture Reviewer 复核分类边界、App Group owner 和数据最小化。~~ 已完成；结论见 Architecture review / re-review。
2. ~~独立 Quality Reviewer 复核 promotion 语义、失败闭合和与现有 CI/RELEASE_CHECKLIST 的关系。~~ 已完成；结论为有界 Conditional Accept，见 Quality review / re-review。
3. 已采纳的 ADR 0035 作为日常发布证据合同的架构依据；后续改变分类边界、证据身份、复用语义或数据 owner 时，必须通过新的 Assignment / revalidation 记录。
4. 发布操作者在真实 archive/export 中补齐 candidate fact tuple，并保留原始证据位置。
5. 若未来需要自动读取 Xcode Cloud/App Store Connect，应另行授权并单独设计凭证与网络边界。

## Related Documents

- [RELEASE-EVIDENCE-PROMOTION-001 Assignment](../../assignments/release-evidence-promotion-001.md)
- [RELEASE-EVIDENCE-PROMOTION-001 implementation Product Decision](../../product-decisions/RELEASE-EVIDENCE-PROMOTION-001-authorization.md)
- [ADR-0035 acceptance Product Decision](../../product-decisions/ADR-0035-ACCEPT-authorization.md)
- [Authorization](../../authorizations/AUTH-RELEASE-EVIDENCE-PROMOTION-001.md)
- [外部公测发布复盘建议稿](../../kos/kos-improvement-suggestions-public-beta-release-2026-09-13.md)
- [Release Checklist](../../RELEASE_CHECKLIST.md)
- [CI Change Classification](../../CI_CHANGE_CLASSIFICATION.md)
- [ADR 0001 Main App owns RIME deployment](0001-main-app-owns-rime-deployment.md)
