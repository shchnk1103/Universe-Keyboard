# KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001 P1 Architecture exact-digest Review

## 审查身份与范围

- Reviewer identity：独立 Architecture Reviewer（Codex，read-only review）
- Review date：2026-09-14（Asia/Shanghai）
- Review target：隔离工作树 `/private/tmp/universe-keyboard-kos-upgrade-uk-005`
- Checked implementation package digest：
  `d021c29e1fdba423a134167900aed1a7c45e6ff9cfc5ab97fe7cd156020f7e94`
- Digest method：按 implementation receipt 记录的 manifest 顺序，对六个文件的原始字节串联后计算 SHA-256；重算结果与目标 digest 一致。
- Review mode：只读；没有修改实现、Assignment、Authorization、KOS 状态或主工作树；没有 commit、push、merge、tag、Release、App Store Connect、TestFlight 或外部发布动作。
- Verification scope：基于 exact package 的静态读取、既有 Main-App source seam 的只读读取、Assignment/Authorization/ADR/Profile/receipt 对照，以及有限的无写入边界探针。按用户要求未重复完整 CI。

## Exact manifest

本次审查固定检查以下六个文件，不以工作树中其他实现文件替代：

1. `scripts/release/kos_release_evidence_adapter.py`
2. `scripts/release/run_kos_release_evidence_fixtures.py`
3. `scripts/release/fixtures/kos_release_evidence_cases.json`
4. `scripts/release/tests/test_kos_release_evidence_adapter.py`
5. `docs/kos/release-evidence-profile.md`
6. `docs/RELEASE_CHECKLIST.md`

Implementation receipt：
`docs/evidence/kos-release-evidence-implementation-001-p1-implementation-2026-09-14.md`。

主要治理与架构输入：

- `docs/assignments/kos-release-evidence-implementation-001-p1.md`
- `docs/authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md`
- `docs/product-decisions/KOS-UPGRADE-UK-005-P1-A-scope.md`
- `docs/product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md`
- `docs/kos/upgrade-records/KOS-UPGRADE-UK-005-release-evidence-v1.md`
- `docs/architecture/decisions/0027-enterprise-local-diagnostic-observability.md`
- 主工作树既有 source seam：`/Users/doubleshy0n/Dev/Universe Keyboard/Universe Keyboard/Services/ReleaseEvidenceStore.swift`
- 主工作树相关提案 ADR（只读背景）：`/Users/doubleshy0n/Dev/Universe Keyboard/docs/architecture/decisions/0035-release-evidence-accumulation-and-promotion.md`

## 结论

**Needs work**

不建议 Adopt 该 exact digest，也不判定为 Reject 整体方案。P1-A 的架构方向、Main-App ownership 复用、P1-B 排除和权限声明基本正确；但当前实现仍有会直接影响“内容无关导出”和“只复用仍然有效证据”的 P1 缺口。它们不是靠绿色 fixture/validator 或人类 Release Gate 可以补齐的缺口，必须修正并对新的 exact digest 重新进行独立审查。

## P1 findings

### P1-ARCH-01：隐私/叙事字段的输出 allowlist 不是 fail-closed

**Finding**：适配器对 `identity` map 只限制 key 的字符形状、数量和 value 的长度/控制字符，不限制语义 key，也没有拒绝 raw user text、candidate text、host text 或 narrative value。`candidate.artifact_identity` 的额外字段会被保留，并被复制到 candidate、observations、delivery、final-validation 和 promotion binding。receipt 合并也只检查允许的顶层 key、时间戳和少数 pointer；`checker_version`、`scope`、`comparison_basis`、`pr_state` 等字段可携带未经过 token 约束的自由字符串。

**直接证据**：

- `_identity` 接受任意符合通用正则的 key/value：`scripts/release/kos_release_evidence_adapter.py:231-244`。
- artifact identity 的额外字段被完整返回：`scripts/release/kos_release_evidence_adapter.py:421-429`；随后被深拷贝到多个 envelope 区域：`scripts/release/kos_release_evidence_adapter.py:460-472`、`648-663`、`475-508`。
- receipt 合并使用 `result.update(source)`，且只验证 `observed_at` 和指定 pointer：`scripts/release/kos_release_evidence_adapter.py:511-527`。
- 只读探针将 `candidate.artifact_identity.raw_user_input = "SENSITIVE-MARKER"` 后，marker 同时出现在 `candidate` 和 observation identity；将含空格的 marker 放入 `final_validation.checker_version` 也被输出。
- 现有测试只检查 canonical fixture 序列化结果不含 `note`、`nonClaims` 和 `raw_user_input`：`scripts/release/tests/test_kos_release_evidence_adapter.py:29-52`，没有 adversarial nested identity/receipt privacy fixture。

**架构影响**：这违反 Profile 的 forbidden content 和“bounded opaque tokens, not narrative fields”边界（`docs/kos/release-evidence-profile.md:253-302`），也未满足 P1 Assignment 对 privacy allowlist 和 privacy tests 的要求（`docs/assignments/kos-release-evidence-implementation-001-p1.md:68-73`、`244-256`）。上游 JSON Schema 对 identity map 的 wildcard 不能替代项目侧 privacy allowlist；“下游 evaluator 可能拒绝某些形状”也不能证明 adapter 已经完成内容边界。

**修复门槛**：需要在 adapter boundary 对可携带字段使用显式语义 allowlist/opaque-token 规则，对所有 receipt/promotion nested fields 做完整形状验证，并加入会尝试注入 raw/narrative 字段的负向测试；修复后须重算 digest 并重新做 exact-digest Architecture review。

### P1-ARCH-02：authority/Profile 文件路径会被错误当作普通 docs-only，绕过全量证据失效

**Finding**：`_is_docs_only_path` 将所有 `docs/**` 和 `.kos/**` 路径统一归为 docs-only；delta planner 不识别其中的 Profile、schema/contract、privacy、source-owner 或 KOS mode authority 文件。因此这些文件变化时可以返回 delta/docs_only、复用全部 evidence、且不要求停止 current-proof 边界。

**直接证据**：

- docs-only 判断覆盖整个 `docs` 和 `.kos` 顶层目录：`scripts/release/kos_release_evidence_adapter.py:728-745`。
- planner 在 semantic-surface 处理之前直接使用该路径分类，并在无 affected scope 时允许全量 reuse：`scripts/release/kos_release_evidence_adapter.py:952-985`、`1082-1091`。
- 已完成的无写入探针得到：
  - `docs/kos/release-evidence-profile.md` → `profile=delta`、`ci=docs_only`、全部三项 evidence reusable、`stop=false`；
  - `.kos/project.json` → 相同结果；
  - `docs/RELEASE_CHECKLIST.md` → 相同结果（该 canonical fixture 本身可以是普通 checklist 文档变化，但不能证明前两类 authority 文件安全）。
- Assignment 明确要求 Profile/source/privacy/schema/contract/evaluator 等变化使 narrow reuse 失效，并要求 unknown/ambiguous diff empty reuse/full/stop：`docs/assignments/kos-release-evidence-implementation-001-p1.md:142-175`。
- Profile 明确声明 P-01/D-01 及其最终文档变化的 receipt 边界：`docs/kos/release-evidence-profile.md:243-302`、`389-402`。

**架构影响**：一旦 Profile/privacy/owner/KOS mode 规则实际变化，旧 evidence 可能被报告为可复用且 planner 不停止；这与“docs-only 只表示文档检查、不成为候选发布证据”和 stop condition“不能 skip touched contract/privacy/source/final-validation rule”冲突。CI classifier 的独立性并不能修复 release-evidence planner 自身的错误 reuse 结论。

**修复门槛**：必须把普通 checklist/docs 变化与 authority/contract/Profile/privacy/source-owner 文档分开分类；任何后者应走 semantic full invalidation，保留 CI 独立 `full` 规则，并加入这些精确路径的 negative fixtures。

### P1-ARCH-03：delta reuse 的 dependency-closed 输入没有对 evidence 条目 fail closed

**Finding**：planner 对 evidence list 中的非 mapping、缺少字符串 `evidence_key` 的条目直接跳过；`_evidence_is_reusable` 的 required tuple 不包含 `scope`、`coverage_ref` 或 claim-to-scope binding，也不验证 `claim_ref` 是否是该 scope 的注册 claim。因而一个包含正常条目和畸形/错绑条目的输入，可能复用正常条目、忽略畸形条目，并返回 `stop=false`；缺失/错误的 claim scope 也可能不触发受影响 claim 的失效。

**直接证据**：

- reuse 所需字段列表没有 `scope`、`coverage_ref`，且没有 registry binding 校验：`scripts/release/kos_release_evidence_adapter.py:803-869`。
- planner 对 malformed entry 直接 `continue`，只按未经验证的 raw `scope` 判断 invalidation：`scripts/release/kos_release_evidence_adapter.py:1044-1073`。
- `invalidated` 仅收集可识别的字符串 evidence key：`scripts/release/kos_release_evidence_adapter.py:1094-1101`。
- 已完成的无写入探针向 canonical docs-only input 增加一个缺少 `evidence_key` 的 entry；planner 仍返回全部三个 canonical key reusable、invalidated 为空、`stop=false`。
- Assignment 的 dependency-closed 规则要求缺失、不可解析或含糊的 path/base-head/owner/binding/dependency 使 reuse set 为空、release profile 为 full、停止 current-proof：`docs/assignments/kos-release-evidence-implementation-001-p1.md:157-175`；required negative-fixture inventory 还要求每个 invalidation 显示旧 key 不再复用或已 fresh re-executed：`262-281`。

**架构影响**：这里的“fail closed”只对部分已识别 key 生效，不是对完整 evidence 输入集合生效。调用方可能把 `stop=false` 解读为 reuse 安全，而实际有未绑定、未分类或错绑的 evidence 未被纳入失效/重跑集合。这直接破坏“只复用 identity-bound、fresh、未受影响证据”的第一性原则，并可能绕过 touched claim 的重验。

**修复门槛**：evidence entry 缺失必需字段、scope/claim/coverage 不一致、重复 key 或非 mapping 时，应整体拒绝该 reuse plan 或至少清空 reuse 并 full/stop；scope、claim_ref、coverage_ref 必须相互绑定并有负向 fixture。修复后重新验证 ordinary、authority、unknown、missing/ambiguous evidence 输入。

### P1-ARCH-04：Main-App export 的 source shape 只部分验证，存在 recordType/contract bypass

**Finding**：canonical Main-App wrapper 的 `recordType = release_evidence_run`、camel-case `run` 字段和 `partial → inconclusive` 映射是正确的；但 adapter 不校验 wrapper 的 `schemaVersion` 或 `evidenceContractVersion`，并允许一个带 `steps` 与 `candidateID` 的 direct run object 绕过 `recordType` 检查。这样 stale/foreign source export 仍可被当作当前 Main-App source seam 输入。

**直接证据**：

- `_run_from_input` 仅在 wrapper 分支检查 `record_type`，随后允许 direct run fallback：`scripts/release/kos_release_evidence_adapter.py:298-308`。
- `run.schemaVersion` 也未进入 `_run_identity` 的 source contract 校验；canonical export shape 来自主工作树 `ReleaseEvidenceExport`：`/Users/doubleshy0n/Dev/Universe Keyboard/Universe Keyboard/Services/ReleaseEvidenceStore.swift:432-452`。
- 已完成的无写入探针把 wrapper 的 `schemaVersion` 改为 `999`、`evidenceContractVersion` 改为 foreign value，adapter 仍构造 KOS envelope；把 wrapper 替换为 direct `run` object 也被接受。
- `partial` 映射为 KOS v1 可表达的 `inconclusive`，且 `note` 被丢弃：`scripts/release/kos_release_evidence_adapter.py:47-56`、`344-374`；这一部分本身符合 Profile 的语义边界。

**架构影响**：Main-App owner seam 的记录类型和版本是 source binding 的输入，不应仅靠调用者约定。当前实现的 canonical fixture 能证明正常形状，但不能证明 adapter 对错误 source shape fail closed；这削弱了 exact source seam、P1 provenance 和后续 `REP-Q-01` 绑定。

**修复门槛**：生产入口应只接受并验证 canonical wrapper 的 record type、schema/evidence-contract version 和 `run` shape；若 direct-run 只为单元测试保留，应隔离为明确的 test-only helper，不能成为生产 adapter 输入路径。

## 已通过或边界成立的项目

以下结论仅限 exact package 的静态/fixture 边界，不扩大为产品或发布接受：

- P1-A/P1-B 边界：manifest 只新增 Python adapter/runner/fixtures/tests 和两份文档；未在 exact package 中引入 Swift、Main-App UI、`ReleaseEvidenceFileStore`、`records.json` persistence/retention/clear、迁移、background sync、App Group ownership 或 Keyboard Extension runtime I/O。
- Main-App ownership：主工作树现有 `ReleaseEvidenceFileStore`/`ReleaseEvidenceExport` 是只读 source seam；其 `recordType`、`nonClaims`、camel-case run shape 与 fixture 对齐。P1-A adapter 不读取或写入该 store，也不复制 `nonClaims` 或 step `note`。ADR 0027 的 Main-App owner/Extension hot-path 边界保持不变。
- outcome shape：`pass`、`fail`、`inconclusive`、`not-run` 以及 Main-App `partial → inconclusive` 的映射是保守的；缺失 P-01/D-01 receipt 默认 `not-run`/`UNKNOWN`，没有把缺证据填成 pass。
- P-01/D-01 authority：canonical fixture/evaluator matrix 覆盖 missing/unknown/mismatched heads、hosted non-pass、comparison basis mismatch、D-01 tree/checker/exit/result failure；planner 对 delivery/final-validation semantic change 会停止 current-proof 边界。这里仍只是 receipt/evaluator contract，不是实际 owner receipt。
- promotion boundary：canonical first external candidate 使用 baseline、无 previous receipt；subsequent 使用 previous target receipt、无 baseline，并以 `release_lineage` 作为稳定 history key。fixture 结果没有把 Beta history 变成外部 delivery、Beta Review、Product Gate 或 Release Pass。
- CI/human authority：实现将 release profile 与 CI tier 分开，未声称 validator/fixture 绿色等于 Product、Quality、merge 或 Release；没有执行外部发布动作。
- bounded local tooling：脚本使用本地 bounded JSON/subprocess 方式，未见网络、凭证、clipboard、用户输入日志或键盘输入热路径调用。

上述 positive checks 不抵消 P1-ARCH-01 至 P1-ARCH-04。

## Open residuals and non-claims

### 仍然打开的 residual

- `REP-Q-01` 未关闭：主工作树 Main-App implementation 仍未提供该 source seam 所需的最终 exact implementation identity、base/head 和 hosted provenance。根据 Assignment/Authorization，它只能作为 source seam，不能作为 current-proof 或 publication provenance；这不是本 exact package 关闭的事实。
- `HOSTED-PROVENANCE` 未关闭：本审查没有把本地 fixture、未提交主工作树或本地 CI 结果当作 hosted CI/Release provenance。
- Authorization 文件仍保留 `consumption_state=unconsumed`/“P1-A implementation has not started in this documentation turn”的文字，而 receipt/Assignment 已记录实现完成。该治理镜像不在本次授权的可修改范围内；本报告不擅自解释或修正其状态。

### Non-claims

本报告不声明：

- 已完成真实 Build/archive/export、真机或 Extension runtime 验证；
- 已完成 App Store Connect、TestFlight、Beta Review、external delivery、Product Gate、Quality Pass、Release Pass 或任何外部发布；
- synthetic `current-proof` fixture 等于当前候选的真实 proof；
- 本地 CI 或 pinned evaluator 结果替代 hosted CI、P-01/D-01 owner receipt、Human Product/Release Gate；
- `SRC-MAIN-STORE` 已获得最终稳定 identity，或 `REP-Q-01` 已关闭；
- P1-B 的 Diagnostics UI、storage/history、clear/retention、background sync、migration 或 App Group 设计已获批准或已实现；
- 当前 exact digest 可以在未修复上述 P1 findings 的情况下 Adopt、merge、push 或 release。

## Evidence paths

### Exact package / receipt

- `scripts/release/kos_release_evidence_adapter.py:1-9, 231-244, 298-374, 421-472, 511-725, 728-1091`
- `scripts/release/run_kos_release_evidence_fixtures.py`
- `scripts/release/fixtures/kos_release_evidence_cases.json`
- `scripts/release/tests/test_kos_release_evidence_adapter.py:29-225`
- `docs/kos/release-evidence-profile.md:233-311, 313-402`
- `docs/RELEASE_CHECKLIST.md`
- `docs/evidence/kos-release-evidence-implementation-001-p1-implementation-2026-09-14.md:41-64, 184-235, 237-270`

### Assignment / authorization / governance

- `docs/assignments/kos-release-evidence-implementation-001-p1.md:68-105, 136-179, 244-300`
- `docs/authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md:60-145`
- `docs/product-decisions/KOS-UPGRADE-UK-005-P1-A-scope.md`
- `docs/product-decisions/KOS-UPGRADE-UK-005-release-evidence-adoption.md`
- `docs/kos/upgrade-records/KOS-UPGRADE-UK-005-release-evidence-v1.md`
- `docs/architecture/decisions/0027-enterprise-local-diagnostic-observability.md`
- `/Users/doubleshy0n/Dev/Universe Keyboard/docs/architecture/decisions/0035-release-evidence-accumulation-and-promotion.md:21-45, 82-96`

### Existing Main-App source seam, read-only

- `/Users/doubleshy0n/Dev/Universe Keyboard/Universe Keyboard/Services/ReleaseEvidenceStore.swift:1-120, 432-452`
- `/Users/doubleshy0n/Dev/Universe Keyboard/Universe Keyboard/Services/ReleaseEvidenceStore.swift:455-520`

## Review disposition

该 exact digest 保留为可复现的审查输入，但不应被标记为 Architecture Adopted。下一步仅应在新的授权范围内修复 P1-ARCH-01 至 P1-ARCH-04、更新对应 negative fixtures/receipt，并以新的 exact package digest 重新请求独立 Architecture 与 Quality review；本报告不授权任何实现或发布动作。
