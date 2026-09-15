# KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1 — Architecture review

## Review identity and boundary

| Field | Value |
|---|---|
| Reviewer | Independent Architecture reviewer runtime |
| Review date | `2026-09-14 Asia/Shanghai` |
| Review mode | Read-only review; this artifact is the only permitted addition |
| Worktree | `/private/tmp/universe-keyboard-kos-upgrade-uk-005` |
| Branch / HEAD | `codex/kos-upgrade-uk-005-release-evidence` / `3139f8d3bdb6be6622504ea731988f42681896fb` |
| Exact P1 scope package digest | `e2ab44303b84d62043bf545d6cfd61cd086e28a9becd18cf7a0ea9bafc8faee8` |
| Digest source | [`P1 scope-freeze receipt`](../evidence/kos-release-evidence-implementation-001-p1-scope-freeze-2026-09-14.md#L19-L45)；十个文件按记录顺序做无分隔 raw-byte SHA-256 拼接 |
| Digest verification | 独立重算，与用户指定 digest 及 receipt 一致 |

本 review 只覆盖上述 exact package 的 P1-A Assignment/Authorization、P0 Profile、状态镜像和
scope-freeze receipt。review artifact 本身不属于该 digest；后续若将本文件加入 `.kos` include 或
scope package，必须生成新的 digest 并重新复核。

本 review 未修改 Swift、项目源代码、既有文档、状态镜像、Assignment、Authorization 或 receipt，
也未执行实现、设备、上传、TestFlight、App Store Connect、commit、push、merge、tag 或 Release。

## Overall

**Pass with conditions**：P1-A 的架构意图、P1-B 隔离、证据复用模型和发布非主张总体成立；但下列
P1 条件在 P1-A 实施开始或实施退出前必须修复并由 Architecture 重新绑定验证。这个结论不是
P1 Ready、Product/Quality/Release Gate、current-proof、发布许可或 GitHub 操作授权。

| Severity | Count |
|---|---:|
| P0 | 0 |
| P1 | 3 |
| P2 | 1 |
| P3 | 0 |

## What passes

### P1-A / P1-B boundary

P1-A 只授权新记录 adapter/profile mapping、既有 Main-App source binding、固定 schema/evaluator
fixtures、delta-aware focused validation、P-01/D-01 contract fixtures 和独立 review receipt
（[`P1 Assignment:65-103`](../assignments/kos-release-evidence-implementation-001-p1.md#L65-L103)，
[`P1 Authorization:69-91`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md#L69-L91)）。
P1-B 明确排除 Diagnostics UI、`records.json` persistence、retention/clear、export、migration 和
新的 App Group ownership，并要求另建 Assignment/Authorization（[`P1 Assignment:105-119`](../assignments/kos-release-evidence-implementation-001-p1.md#L105-L119)，
[`P1 Authorization:93-105`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md#L93-L105)）。
因此没有发现把“减少跨工具读取”默认为 Main-App 功能实现的架构越权。

### Source of Truth / ADR 0027 boundary

Profile 明确将 KOS Kit 限制为合同/语义来源，将 Main-App 保留为项目事实 owner，并将未知的
Main-worktree promotion input 和未来 P1 receipt 保留为 `REP-Q-01` 边界
（[`Profile:35-48`](../kos/release-evidence-profile.md#L35-L48)，
[`Profile:159-167`](../kos/release-evidence-profile.md#L159-L167)）。P1-A 也明确禁止第二个 store、
改变 ADR 0027 ownership/retention/clear/App Group boundary（[`P1 Assignment:70-77`](../assignments/kos-release-evidence-implementation-001-p1.md#L70-L77)，
[`P1 Authorization:37-47`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md#L37-L47)）。
这部分的设计方向正确；下方 `ARCH-P1-SOT-01` 只针对 source identity 尚未闭合，不是认定已经
存在重复存储。

### Delta-aware validation and daily Beta reuse

P1 将“只重跑可能被改动的证据、仅复用身份和 freshness 仍成立的未触碰证据”写成了执行契约，
并对 candidate/baseline/history、schema/profile/source-owner 和 delivery/final-validation 变化
分别升级验证范围（[`P1 Assignment:131-149`](../assignments/kos-release-evidence-implementation-001-p1.md#L131-L149)）。
Daily Beta → `external_candidate` 的 first/subsequent 规则、`release_lineage`、baseline 和
previous receipt 条件在 Profile 中是可执行的显式规则（[`Profile:284-313`](../kos/release-evidence-profile.md#L284-L313)）。
这些规则没有把 comparator/pending/none 变成 current-proof，也没有把 validator 变成 Product、
Quality 或 Release Gate（[`P1 Assignment:147-149`](../assignments/kos-release-evidence-implementation-001-p1.md#L147-L149)）。

### Envelope, mirrors and publication boundary

机械引用关系成立：P1 Assignment 的 `authorization_action`、`authorization_refs` 与 P1
Authorization 的 action、target 相符；P1 child 同时指向 P0 parent 和 UK-005 Product Decision
（[`P1 Assignment:3-28`](../assignments/kos-release-evidence-implementation-001-p1.md#L3-L28)，
[`P1 Authorization:10-55`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md#L10-L55)）。
`.kos/project.json`、README、`ACTIVE_WORK` 和 `UPGRADE_STATUS` 均已列出 P1 child 与 P1-A 状态
（[`project.json:18-32`](../../.kos/project.json#L18-L32)，[`README:67-70`](../kos/README.md#L67-L70)，
[`ACTIVE_WORK:79-80`](../ACTIVE_WORK.md#L79-L80)，[`UPGRADE_STATUS:59-78`](../kos/UPGRADE_STATUS.md#L59-L78)）。
P1 scope-freeze receipt 准确声明“只有 scope/Authorization freeze，未发生实现、Envelope evaluation
或独立 review”（[`receipt:15-17`](../evidence/kos-release-evidence-implementation-001-p1-scope-freeze-2026-09-14.md#L15-L17)，
[`receipt:60-69`](../evidence/kos-release-evidence-implementation-001-p1-scope-freeze-2026-09-14.md#L60-L69)）。

`REP-Q-01`、final SHA/base-head 和 hosted provenance 仍被保留为 publication blocker，且 P1
明确不产生 delivery/final-validation receipt 或发布结论（[`Profile:31-33`](../kos/release-evidence-profile.md#L31-L33)，
[`P1 Assignment:248-254`](../assignments/kos-release-evidence-implementation-001-p1.md#L248-L254)，
[`P1 Authorization:107-118`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md#L107-L118)）。

## Findings

### ARCH-P1-AUTHORITY-01 — P1 authority chain is not repository-resolvable

| Field | Value |
|---|---|
| Severity | P1 |
| Disposition | `fix` before P1-A implementation/Ready; Architecture re-review required |
| Evidence | [`P1 Assignment:55-61`](../assignments/kos-release-evidence-implementation-001-p1.md#L55-L61)；[`P1 Authorization:29-55`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md#L29-L55)；[`Product Decision:20-25`](../product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md#L20-L25)；[`Assignment Policy:137-161`](../ASSIGNMENT_POLICY.md#L137-L161) |

Assignment 记录了 `Product Lead` 角色、Human Product Owner 和当前任务批准，但没有明确把
具体 Product Lead identity/authoritative Product thread 绑定到该 P1 child；Authorization 的
`decision_source` 是自由文本 `Current task approval: ...`，而不是可解析的 accepted Decision
ID、相对路径或 Markdown link。上游运行卫生规则也要求在声明“已授权”前能解析
Assignment → Authorization → accepted Decision，且禁止自由文本 decision source
（`/Users/doubleshy0n/Dev/kos-agent-kit/ops/kos-2.1-operational-maturity.md#L52-L61`）。

这不是否定 Human Product Owner 的当前批准，而是指出批准事实尚未以可重放、可解析的
authority reference 落到 P1 Authorization。应补一个明确命名 P1-A scope 的 accepted Product
Decision，或一个可解析且具备同等权威的 Product handoff reference，并明确 Product Lead 与
Human Product Owner 在此 Assignment 中的身份关系。在该条件闭合前，不能仅凭当前 task prose
把 P1 Authorization 当作可执行许可。

### ARCH-P1-SOT-01 — Main-App source identity remains unresolved

| Field | Value |
|---|---|
| Severity | P1 |
| Disposition | `fix` before P1-A source-binding exit; keep `REP-Q-01` open until resolved |
| Evidence | [`Profile:40-48`](../kos/release-evidence-profile.md#L40-L48)；[`ADR 0027:28-38`](../architecture/decisions/0027-enterprise-local-diagnostic-observability.md#L28-L38)；[`P1 Assignment:121-129`](../assignments/kos-release-evidence-implementation-001-p1.md#L121-L129)；[`P1 freeze receipt:85-93`](../evidence/kos-release-evidence-implementation-001-p1-scope-freeze-2026-09-14.md#L85-L93) |

Profile 将 `SRC-MAIN-STORE` 描述为 `Diagnostics/v1/release-evidence/records.json`，但在本次
审查的 isolated worktree 中，ADR 0027 的对应行仍是通用 JSONL segment layout，并没有给出
该 release-evidence object 的实际 owner/implementation identity；isolated worktree 也没有
`ReleaseEvidenceFileStore` source。Profile 已诚实地把 Main-worktree-only promotion input、
未来 `SRC-P1-RECEIPT` 和实际 store identity 标记为 pre-freeze/`REP-Q-01`，所以这不是重复
Source of Truth 或已发生越权，而是 P1-A “bind existing source”尚无可验证落点。

P1-A 只能在此阶段记录稳定 source seam/identity，不能凭 ambient main-worktree 状态实现或
宣称 Main-App integration。P1 退出前必须提供 exact path、owner、candidate/base identity 和
必要 digest；否则保持 `REP-Q-01` blocker，不产生 current-proof、P-01 或 publication claim。

### ARCH-P1-CI-BOUNDARY-01 — Release delta must not downgrade CI classification

| Field | Value |
|---|---|
| Severity | P1 |
| Disposition | `fix` in P1 execution/receipt contract; Architecture re-review required |
| Evidence | [`P1 Assignment:90-99`](../assignments/kos-release-evidence-implementation-001-p1.md#L90-L99)；[`P1 Assignment:139-149`](../assignments/kos-release-evidence-implementation-001-p1.md#L139-L149)；[`CI classification:5-20`](../CI_CHANGE_CLASSIFICATION.md#L5-L20)；[`CI job contract:41-50`](../CI_CHANGE_CLASSIFICATION.md#L41-L50) |

P1 已说明 release-evidence classifier 是执行辅助、不是 Gate，也已区分 delivery/final
validation change。但它没有把这条新 release delta path 明确绑定到现有 CI Source of Truth：
现行规则规定只有 `docs_only` 才能跳过 `build-and-test`，任何其他路径（包括 Swift、工程、
测试、工具链、RIME 和未知路径）都必须 `full`。如果实现者把 `delta` 理解成 CI tier 的降级，
就会把“少做无关发布证据”错误扩展为“少跑必要工程质量门”。

P1 receipt/执行合同必须明确 `release_validation_profile` 与 `ci_change_tier` 是两个独立
分类器：release `delta` 不得覆盖 CI `full`；只有既有 CI classifier 判定的 `docs_only` 才能
跳过 heavy job；validator 结果仍不能代替 Quality、Product、Release 或 App Store Connect
决策。源码/测试/工程变更仍须按仓库 CI 与 Swift 硬门槛验证。

### ARCH-P2-ENVELOPE-01 — Active Authorization 的消费状态语义不一致

| Field | Value |
|---|---|
| Severity | P2 |
| Disposition | `fix` before authorization consumption/closure; record the corrected state and re-review |
| Evidence | [`P1 Authorization:3-8`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md#L3-L8)；[`P1 Authorization:49-55`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md#L49-L55)；[`P1 Authorization:130-135`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md#L130-L135)；[`TD-014:251-259`](../TECH_DEBT.md#L251-L259) |

正文 Current Status 写的是“Not consumed; implementation has not started”，但 Envelope 使用
`consumption_state: not_applicable`。对于一个 status=`active` 且明确授权未来 P1-A action 的
Authorization，`not_applicable` 不是“尚未消费”的同义词；它会降低 replay/audit 判断的
精确性。应改为适用于当前项目语义的 `unconsumed`，或由明确的既有 KOS hygiene exception
记录为何该 action 被视为 not applicable。该问题不扩大权限，也不构成 P0，但不能在关闭或
消费 Authorization 时继续保持无解释的冲突。

## Requested handoff and non-claims

本 Architecture 结论可以交给独立 Quality reviewer 对同一 exact digest 继续审查；Quality
不得把本结论或 validator PASS 解释为实现批准、Product Gate、Release Pass 或 publication
授权。执行顺序应为：先处理 `ARCH-P1-AUTHORITY-01`、`ARCH-P1-SOT-01`、
`ARCH-P1-CI-BOUNDARY-01` 和 `ARCH-P2-ENVELOPE-01`，再以新证据/新 digest 做 Architecture
re-review，随后才可进入 P1-A implementation。

本 review 未运行 standalone release-evidence evaluator、schema fixtures、xcodebuild、CI、
设备或运行时验证；scope-freeze receipt 已明确这些是 P1-A 后续交付项
（[`receipt:60-65`](../evidence/kos-release-evidence-implementation-001-p1-scope-freeze-2026-09-14.md#L60-L65)）。
因此没有产生 current-proof、daily-Beta observation、external-candidate proof、P-01/D-01
receipt，也没有关闭 `REP-Q-01` 或 hosted provenance。
