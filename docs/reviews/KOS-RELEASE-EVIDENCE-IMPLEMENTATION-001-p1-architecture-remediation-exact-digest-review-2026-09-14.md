# KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001 P1 Architecture Remediation 独立审查

> **状态：历史记录（旧 package scope；不作为当前 P1-A 结论）。** 本报告的
> `Needs work` 只属于文首所述 exact package；后续 closure receipt 不把该结论转移到
> 当前或任何新 package，变更 package 必须重新绑定 exact-digest review。

审查日期：2026-09-14（Asia/Shanghai）

审查角色：独立 Architecture Reviewer

结论：**Needs work**

审查对象：/private/tmp/universe-keyboard-kos-upgrade-uk-005 的 exact package digest

## 1. 结论摘要

当前 exact package 的六个文件字节摘要和串联摘要均与授权材料一致。P0 contract、P1-A 授权边界、固定 45 + 21 inventory、P-01/D-01 负向覆盖、daily Beta → external candidate lineage、privacy/output allowlist、CI tier 分离，以及 Main-App/Extension/network/authority 边界的主体设计均已落在当前材料中。

但独立内存探针证明了一个 P1 级 fail-closed 缺口：main_app_source.record_id = "unknown"（小写）仍能被 adapter 接受，生成带有 unknown 的 appdiag:// pointer，并被 pinned evaluator 判为 current-proof。adapter 同时没有要求 source input 显式绑定 SRC-MAIN-STORE。因此，当前实现仍可把未解析或未验证的 source seam 包装成可参与 current-proof 的 provenance；P1-A 独立退出条件不能通过。

另有三个 P2 完整性问题：canonical wrapper 的 nonClaims/outcome 一致性没有强制；delta plan 接受相同的 base_sha/head_sha 与重复 changed-surface，并且不在结果中保留 base/head binding；fixture runner 只校验三份 KOS 源文件 digest，不强制校验 adapter 中声明的 candidate implementation/tree/metadata identity。它们不改变本次已观测的三份 KOS pin 或固定矩阵结果，但会削弱后续复用与 provenance 的可审计性。

因此本报告不作 Product、Quality、Release、Beta Review、TestFlight 或 App Store Connect 结论，也不把 report.json 或本地 fixture 结果提升为 authority。

## 2. Exact digest 重算

方法：按用户给出的六个文件顺序读取原始 bytes，逐个 sha256.update 后计算串联 package digest；没有规范化换行、解码再编码或纳入其他文件。当前 worktree 在“短暂状态行变更已恢复”后的重算结果如下。

| 顺序 | 文件 | 字节数 | 当前 SHA-256 | 期望 |
|---:|---|---:|---|---|
| 1 | scripts/release/kos_release_evidence_adapter.py | 63116 | e4dcbda8e77ed3bf63f4943a851b0133b790ba8391c4f806133e42fb8b4a0466 | match |
| 2 | scripts/release/run_kos_release_evidence_fixtures.py | 24327 | 37147357042924cd051a7d3f8ed9fee9198d1287c3b24f048e3e875006f75888 | match |
| 3 | scripts/release/fixtures/kos_release_evidence_cases.json | 40533 | 6cd843ffd61bf906310dec7e52d19a67656bfa0f422223509358af8cc6e4f37d | match |
| 4 | scripts/release/tests/test_kos_release_evidence_adapter.py | 14745 | 26593d80d056e4291db518ed6d1ccae80b6798fff376361b8c95ef51f8163ae0 | match |
| 5 | docs/kos/release-evidence-profile.md | 41385 | 71d3b301fb8f0bbc71aab14143c6a863320004e6b3cf27f55ae1ef906ccd867b | match |
| 6 | docs/RELEASE_CHECKLIST.md | 29348 | 6c3a2bb9611d32a09256a0e290629ec51a23b7f531f1d0e9ae9ddae0265e5eca | match |

串联总字节数：213454

当前 package digest：35a055a4341dbd77bb2aec74fbae7699449d23c700d7c8c226b0e693c385421d

期望 package digest：35a055a4341dbd77bb2aec74fbae7699449d23c700d7c8c226b0e693c385421d

结果：**match**。

target worktree 的 HEAD 为 3139f8d3bdb6be6622504ea731988f42681896fb。审查期间未修改实现、Assignment、Authorization、状态镜像或 target/main worktree 中的既有内容；唯一写入是本报告文件。

## 3. 审查范围与证据边界

读取并核对了：

- P1 Assignment：/private/tmp/universe-keyboard-kos-upgrade-uk-005/docs/assignments/kos-release-evidence-implementation-001-p1.md:68-95,107-121,154-180,236-282,294-316。
- P1 Authorization：/private/tmp/universe-keyboard-kos-upgrade-uk-005/docs/authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md:65-90,100-145。
- P1 implementation receipt：/private/tmp/universe-keyboard-kos-upgrade-uk-005/docs/evidence/kos-release-evidence-implementation-001-p1-implementation-2026-09-14.md:16-36,54-108,252-307。
- P0 Profile/owner-map：/private/tmp/universe-keyboard-kos-upgrade-uk-005/docs/kos/release-evidence-profile.md:36-84,121-138,140-220,249-286,297-318,405-437。
- P0 freeze/upgrade record/PD：/private/tmp/universe-keyboard-kos-upgrade-uk-005/docs/evidence/kos-release-evidence-implementation-001-p0-freeze-2026-09-14.md、/private/tmp/universe-keyboard-kos-upgrade-uk-005/docs/kos/upgrade-records/KOS-UPGRADE-UK-005-release-evidence-v1.md、/private/tmp/universe-keyboard-kos-upgrade-uk-005/docs/product-decisions/KOS-UPGRADE-UK-005-P1-A-scope.md。
- ADR 0027：/private/tmp/universe-keyboard-kos-upgrade-uk-005/docs/architecture/decisions/0027-enterprise-local-diagnostic-observability.md:5,13,17-24,28-40,57-70。
- 主工作树现有 source seam：/Users/doubleshy0n/Dev/Universe Keyboard/Universe Keyboard/Services/ReleaseEvidenceStore.swift:338-365,432-452,608-616。
- pinned KOS contract/schema/evaluator：/Users/doubleshy0n/Dev/kos-agent-kit/ops/release-evidence.md、schemas/release-evidence-v1.schema.json、scripts/validate_release_evidence.py。
- 固定 fixture report：/private/tmp/uk-kos-kos-fixtures-fix7/report.json。该文件只作为独立核对材料，不作为 Product/Release authority。

历史 review 文件没有被用作本报告的结论依据；本报告结论来自上述材料、当前 exact bytes、静态 source review 与独立内存探针。

### Pinned KOS identity

独立读取 /Users/doubleshy0n/Dev/kos-agent-kit 得到：

| 项目 | 当前值 | 结果 |
|---|---|---|
| kit HEAD | f5c88d57f599d7ef352322ea7664f637fb288d60 | 与材料一致 |
| candidate tree digest（P0 manifest 10 文件） | fec6889e81ea0807b284de45027e0270a70938e220041a8c367fd41a081a88c9 | 与材料一致 |
| contract ops/release-evidence.md | f7ec8d9363cc37e53201e8bf990af80ba77fc9f88b7f78371d2c39f453a78673 | match |
| schema schemas/release-evidence-v1.schema.json | 4e48bcf127edb87e67c4d390a3baec93af26ef72aa251e8172cb1044dca893ce | match |
| evaluator scripts/validate_release_evidence.py | a45145681306c2da581f1054f002b7becd909d1bb4a8329ad14892f17839b9d9 | match |

固定 report 当前 SHA-256 为 59138dbb7128184037d32db2fcaea9b914cc36af6e9145281d5ff2f66621c199；其摘要为 envelope 45/45、delta 21/21、aggregate 66/66，并列出 exact fixture IDs。该结果只证明固定输入在指定 --as-of=2026-09-14T12:00:00+08:00 下的 contract/evaluator classification。

## 4. Findings

### P0 findings

**无已证实 P0 finding。** 当前材料没有显示 adapter 引入 Extension runtime I/O、runtime network、第二个 Main-App store、自动发布/上传或绕过 Product/Release authority 的 P0 级动作。P0 contract/schema/evaluator pin 也未发现摘要不一致。

### P1 findings

#### F-001 — Main-App source identity 对小写 unresolved 值 fail-open，且未绑定 SRC-MAIN-STORE

**等级：P1；状态：已复现；阻断独立 P1-A exit。**

证据：

- adapter 的 _resolved 只拒绝精确的 UNKNOWN、TODO、TBD，没有大小写折叠：kos_release_evidence_adapter.py:250-254。
- _source_pointer 仅验证 record_id、UUID、digest 和 diagnostic-short retention，并构造 appdiag:// pointer；它没有要求 source input 含有或等于 SRC-MAIN-STORE：kos_release_evidence_adapter.py:418-437。
- build_envelope 将该 pointer 写入 observation evidence 与 provenance source ref：kos_release_evidence_adapter.py:1023-1082。
- Profile 明确把 SRC-MAIN-STORE 定义为 source seam，并要求 REP-Q-01 关闭前不得把它当 current-proof provenance：release-evidence-profile.md:48-56。
- Assignment/Authorization 也要求 unresolved Main-App source 停止，而不是制造 current-proof：Assignment :75-77,248-249；Authorization :75-83,127-130。

独立内存探针以 fixture 的 base input 为基础，仅将 main_app_source.record_id 改成小写 unknown，没有写文件、没有运行 fixture runner：

~~~text
adapter.build_envelope: OK
pinned schema validation: OK
pinned evaluator derived_status: current-proof
provenance.source_ref:
appdiag://release-evidence/unknown/10000000-0000-4000-8000-000000000056;
sha256=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
class=diagnostic-short
~~~

这不是“没有 source record”的安全状态：evaluator 将该 pointer 当作已解析 opaque reference，且所有固定 claim 仍可得到 current-proof。因此 FX-035 所覆盖的 uppercase unresolved 负向用例不足以覆盖大小写、空白或其他 unresolved spelling；现有矩阵的绿色不能关闭该边界。

**需要的退出条件（仅记录，不实施）：** 统一 case-insensitive unresolved predicate；对 source input 使用 exact allowlist，并强制 source_identity == SRC-MAIN-STORE；将 source record/operation/digest 与真实 Main-App receipt 的稳定 identity 绑定；任何缺失、大小写变体、foreign source 或无法核对的绑定均应 reject/stop，不能进入 evaluator 的 current-proof 输入。应增加相应负向 fixture，而不是只增加一个 uppercase case。

### P2 findings

#### F-002 — canonical Main-App wrapper 的非声明字段与 outcome 一致性没有 fail-closed

**等级：P2；状态：已复现。**

_run_from_input 对 wrapper 的六个 top-level key、schema version、contract version 与 recordType 做了 exact 检查，但 nonClaims 只要求“非空 token array”，没有要求等于 Main-App canonical export 的四个 non-claim；wrapper outcome 只要求属于支持集合，也没有与 run 实际计算出的 outcome 做一致性核对：kos_release_evidence_adapter.py:383-415。主 App canonical export 明确给出固定四项 non-claim 且 outcome = run.outcome：ReleaseEvidenceStore.swift:432-452。

独立内存探针将 nonClaims 改成 [ grant_release ]，或只将 wrapper outcome 改成 fail，两种输入都仍然 build=OK；在固定 as-of 下 evaluator 仍返回 current-proof。这不会把 wrapper 的 outcome 直接复制到 Envelope，因此不是已观测的 output leakage；问题在于 adapter 接收了一个与 canonical Main-App export 不一致的 source record，并继续生成可证明形状的 envelope。source/run/candidate/provenance 的未知 nested fields 也主要被投影而非 exact-reject。

**需要的退出条件：** canonical nonClaims exact-match；wrapper outcome 与 run-derived outcome exact-match；对 source、run、candidate、provenance 的允许字段做明确区分，若契约要求 canonical 输入则未知字段 reject。补充“非规范 nonClaims、wrapper/run outcome mismatch、nested extra field”负向用例。

#### F-003 — delta 的 base/head 与 changed-surface 输入没有形成完整、不可歧义的 plan binding

**等级：P2；状态：已复现。**

plan_delta 只验证 base_sha 与 head_sha 的格式，随后立即删除这两个值，DeltaPlan 也不返回它们：kos_release_evidence_adapter.py:1295-1329。因此结果 report 无法仅凭 plan 重新确认该分类对应的 base/head。另一个 fail-closed 缺口是 changed-surface 使用 sorted(set(normalized))，会静默去重：:1344-1373。

独立内存探针显示：

- 将 fixture 的 base_sha 改为与 head_sha 相同，同时保留 docs-only changed surface，仍返回 docs_only、全部 evidence 可 reuse、stop_before_current_proof=false。
- 将同一个 docs/RELEASE_CHECKLIST.md 放入 changed surface 两次，仍被静默归一化成一次并返回相同 docs-only 计划。

这不等于实际 Git diff 已被伪造，也没有把 CI tier 误合并进 release profile；但当前 adapter 不验证实际 diff，也不保留 base/head binding，故无法对“空变更却有非空 surface”或“重复/含糊输入”的来源做可审计证明。Assignment 要求的 base_sha/head_sha/candidate/profile/pins/source/claim/coverage/basis/freshness 完整 tuple 不能只停留在输入文件中。

**需要的退出条件：** 在 machine plan/receipt 中保留 base/head；非空 surface 时拒绝 equal heads，空 surface 则明确走 full/stop；重复或规范化前后不唯一的 surface fail-closed；由拥有 diff 的 caller 提供可核验的 changed-surface manifest，或将“未核验实际 diff”明确列为不可复用状态。

#### F-004 — fixture runner 没有强制校验完整 candidate pin

**等级：P2；状态：观察到 enforcement gap，当前实际 pin 未失配。**

runner 的 _verify_pins 只计算并比较 contract、schema、evaluator 三个文件：run_kos_release_evidence_fixtures.py:496-515。adapter 的 PINNED_PROFILE 同时声明 candidate implementation commit、adoption metadata commit 与 candidate tree digest，但 runner 不验证这些 identity；因此只要三份 KOS 源文件相同，即使 kit checkout 或其余 adopted tree 不是声明的 candidate，也可能生成“pinned sources pass”的 report。

本次独立读取 kit HEAD 与 P0 manifest tree digest 均与声明一致，所以这是 provenance enforcement 缺口，不是本次 observed mismatch。应将完整 candidate identity 的核验放入独立 receipt/runner，或明确把三份 semantic pin 与 candidate tree pin 分成两个不可混淆的检查结果。

### P3 findings / unresolved items

#### F-005 — REP-Q-01、hosted provenance 与 P1-B 仍是开放边界

**等级：P3 process/residual；状态：Unknown/open，且不是本次实现可自行闭合的事项。**

- REP-Q-01：主工作树 ReleaseEvidenceStore.swift 目前是 source seam；其稳定 implementation identity、最终 SHA、base/head 以及与 candidate 的关系尚未形成独立 hosted/committed receipt。Profile 已明确 SRC-MAIN-STORE 不是当前 proof provenance：release-evidence-profile.md:48-56,435-437。
- HOSTED-PROVENANCE：没有本次审查授权范围内的 hosted tag/Release/CI relation 或 Product/Release owner receipt；不能从本地 fixture report 推出。
- P1-B-DIAGNOSTICS：Main-App diagnostics UI/storage、迁移、background sync 仍按 Assignment/Authorization deferred；ADR 0027 的 Main-App ownership 与 Extension hot-path 边界没有被本 package 改写。

这些项目应保持 UNKNOWN/open，不能用 current-proof、66/66 fixture 结果、P1 receipt 或本报告替代。

## 5. 重点边界复核结果

### 已满足或未发现越界的部分

- **Main-App canonical wrapper/version/direct-run：** top-level wrapper key set、schemaVersion=1、evidenceContractVersion=release-evidence-v1、recordType=release_evidence_run 以及 direct-run/foreign-wrapper negative cases 已有实现与 fixture 覆盖；canonical consistency 缺口见 F-002。
- **Output privacy/identity/receipt allowlist：** adapter 输出不复制 Main-App note、nonClaims 或 raw_user_input；未知 artifact identity 与 narrative checker field 有负向覆盖。P-01/D-01 缺失时使用 not-run/UNKNOWN，没有观察到 adapter 自动制造 pass。证据为 kos_release_evidence_adapter.py:1031-1087、P1 receipt :263-270。F-001 说明 source pointer 本身仍可由未解析 ID 生成，故 allowlist 不能被解释为真实 source identity 已验证。
- **P-01/D-01 binding：** delivery 的 candidate identity、context、profile、三 heads、hosted result、comparison basis，以及 D-01 的 final tree/checker/version/scope/baseline/output/exit/result 均有正负字段覆盖；FX-025–034、FX-042–045 覆盖 missing/future/stale/mismatch/non-pass/unknown。该结论是 schema/evaluator input-shape review，不是实际 hosted delivery 或 final-validation receipt。
- **daily Beta → external first/subsequent lineage：** Profile 的 first baseline/previous-null 与 subsequent previous-receipt、same lineage/context/profile/contract/history 规则已在 adapter/evaluator 与 FX-010–014、FX-041 中表达；未观察到把 pending external promotion 直接变成 publication authority 的路径。
- **delta evidence tuple、claim/coverage registry 与 fail-closed cases：** 14-field delta evidence normalization、exact claim/coverage bindings、candidate/context/profile/source/basis/pin checks、duplicate evidence key、malformed/unknown/unsafe/stale/expired cases均已实现或列入 DELTA-001–021；F-003 是 plan provenance/ambiguity 的剩余问题。
- **Profile/KOS/authority path 与 docs-only allowlist：** Profile/KOS/Assignment/Authorization/PD/ADR 改动均被列为 release dependency；唯一 docs-only path 为 docs/RELEASE_CHECKLIST.md。release profile 与 repository CI tier 分开，非 docs path 仍 full/stop：release-evidence-profile.md:121-138、docs/RELEASE_CHECKLIST.md:74-114。
- **固定 inventory：** runner 对 envelope IDs UK-RE-FX-001..045 与 delta IDs UK-RE-DELTA-001..021 做 exact tuple 比较：run_kos_release_evidence_fixtures.py:41-45,518-558。固定 report 记录 45/45、21/21、66/66。该 enforcement 通过，但不覆盖 F-004 的完整 candidate pin。
- **P1-B / Extension hot-path / network / authority：** 本 exact package 是 release tooling 与 docs/fixtures；没有发现它新增 Swift runtime、Extension 文件 I/O、runtime network、App Group store 或上传/发布调用。ADR 0027 仍要求 Main-App 创建/管理 diagnostics、Extension 不在 key event 中做 I/O/network/wait：ADR 0027 :13,17-24,28-40,61-70。主 source seam 的现有 records.json actor/store 及四项 non-claims 位于主工作树 ReleaseEvidenceStore.swift:338-365,432-452，本审查未修改它。

## 6. Non-claims

本报告不声称：

- P1 implementation 已通过独立 Architecture/Quality exit；F-001 仍未修复。
- 当前 Main-App source seam 已有稳定 commit/archive/package SHA、base/head 或 hosted provenance。
- fixed fixture report 是 Product approval、Quality pass、Product Gate、Release Pass、Beta Review、TestFlight 可安装性或 App Store Connect 状态。
- current-proof 是人类 authority；它只是 pinned contract/evaluator 对输入的派生分类。
- 已执行或授权 commit、push、merge、tag、Release、TestFlight、App Store Connect、上传、Beta Review、外部通知或任何账户动作。
- P1-B diagnostics UI/storage、migration、background sync 或 Extension runtime integration 已实现。
- 本审查提供了真机、性能、签名、安装、外部 Beta 或正式 Release 证据。

## 7. 复核结论与后续门槛

**结论：Needs work。**

通过 exact digest 与固定矩阵只能确认“当前审查对象就是声明的实现包，且声明的 bounded fixtures 在 pinned KOS semantic sources 下得到预期分类”。它不能关闭 source identity 的 P1 fail-open，也不能把本地材料提升为 Release authority。

在不改变本审查范围的前提下，下一次独立复核至少需要看到：F-001 的 source identity/case-fold/receipt binding 修复及负向 fixture；F-002 的 canonical wrapper consistency；F-003 的 base/head 与 changed-surface fail-closed receipt；以及 F-004 的完整 candidate pin enforcement。之后仍需由相应 owner 独立闭合 REP-Q-01 与 hosted provenance；P1-B 如需实施必须重新取得其 Assignment/Authorization/ADR review。
