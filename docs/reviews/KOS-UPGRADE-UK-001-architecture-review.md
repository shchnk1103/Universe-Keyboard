# KOS-UPGRADE-UK-001 — Independent Architecture Review

## Review identity

| Field | Value |
|---|---|
| Reviewer | `architecture_review` / Hilbert（独立 Architecture Reviewer） |
| Date / timezone | `2026-08-27 Asia/Shanghai` |
| Frozen commit | `f58061314d4e9c08313deac97228a62f95bcf9fe` (`docs/kos-2-2-advisory-v0.5.0`) |
| Kit pin reviewed | `shchnk1103/kos-agent-kit@v0.5.0` (`e11cbfb1dacaadc3441b70b2362b6b96d2803385`) |
| Local kit HEAD | `e11cbfb` / exact tag `v0.5.0`（与 pin 一致） |
| Objects | [`KOS-UPGRADE-UK-001`](../assignments/kos-upgrade-uk-001.md) · [`PD-KOS-UPGRADE-UK-001`](../product-decisions/KOS-UPGRADE-UK-001-authorization.md) · [`AUTH-KOS-UPGRADE-UK-001`](../authorizations/AUTH-KOS-UPGRADE-UK-001.md) · [`.kos/project.json`](../../.kos/project.json) · [`UPGRADE_STATUS`](../kos/UPGRADE_STATUS.md) · first workflow `DIAGNOSTICS-VIEWER-LOAD-001` · Kit `ops/kos-2.2-operational-reliability.md` / `docs/kos-2.2-adoption.md` / `core/upgrade-governance.md` / `docs/project-adaptation.md` · frozen UK [`knowledge-os-2.0-specification.md`](../kos/knowledge-os-2.0-specification.md) · [`kos-2.1-operational-maturity.md`](../kos/kos-2.1-operational-maturity.md) |
| Independence | 本审查不是 `f580613` 的作者（该提交 Author 为 `Cowork 3P`）。审查只读；未改业务代码、Profile 语义、Envelope、Assignment 范围，也未开启 `required`、未关 Gate、未 commit/push/PR。 |
| Scope | 仅审查 **KOS 2.2 advisory pin** 的权威边界、Envelope/include、Authorization 收据语义、Gate 开放性和第一条工作流边界。不是 Quality、不是 Product Gate、不是 merge。 |

**HEAD 核对：** 审查时 `git rev-parse HEAD` = `f58061314d4e9c08313deac97228a62f95bcf9fe`。`git show f580613 --stat` 为 18 个文档/JSON 文件、+740/−3；未触及 `docs/kos/knowledge-os-2.0-specification.md`、`docs/kos/kos-2.1-operational-maturity.md`、Swift / 主 App / Keyboard Extension。

---

## Verdict

**Pass with conditions**

这是叠在冻结 KOS 2.0 宪法与仍有效的 KOS 2.1 ops 之上的 **additive advisory pin**。权威边界没有被 Kit 覆盖；`record_envelopes.mode` 仍为 `advisory`；两条 Gate 仍为 `open`；校验绿没有被写成 Architecture / Product / merge / Release Pass。第一条工作流把诊断**实现**、万象下载和 PR #83 merge 明确排除在外。

条件全部是 P2/P3 残余（见下表）。**无未处置 P0。** 本 Verdict 不关闭 `GATE-KOS-UPGRADE-UK-ADVISORY`（`close_authority` = Human Product Owner）。

Finding counts: **P0: 0 · P1: 0 · P2: 3 · P3: 3**

---

## Answers to the review questions

### 1. 是否仍是叠在 KOS 2.0/2.1 上的 additive advisory pin？有没有改冻结内核或权威边界？

**是 additive advisory pin；没有改冻结内核或权威边界。**

- 冻结 2.0 十原则、权威模型、lifecycle 骨架未被本提交修改。
- 2.1 ops（M-01…M-05 等）仍声明「不替代 2.0」；本提交只增加导航指针，不重写 2.1 正文。
- Kit R-08：`advisory` 只报告 record 缺陷，不改变退出状态或任何 Gate。Profile `mode: "advisory"`，`extensions.universe_keyboard.kos_kit.record_envelopes_mode: "advisory"`。
- Assignment / PD / AUTH 的 non-goals 均排除 `required`、bulk Envelope、改写 KOS 2.0、产品 Swift、PR #83。
- `legacy_yaml_policy: absent` 且仓库无 `.kos/project.yaml`，没有 v1/v2 隐式合并。
- `extensions` 使用项目命名空间，未覆盖 core Profile 字段。

### 2. Envelope / Current Status mirror / include glob 是否把历史记录错误地变成 required 或双真相？

**没有把历史记录变成 required。同记录 mirror 与 Envelope 一致。跨文档仍是非权威摘要。**

- `include` 只点名两条 Assignment、两条 PD、两条 Evidence，外加 `docs/authorizations/*.md` 与 `docs/gates/*.md`。当前这两个目录只含本 pin 新建的收据，不含历史 Assignment。
- `record_roots` 虽包含整个 `docs/assignments` 等，但 validator 先按 `include` 过滤；未匹配文件不会因缺 Envelope 报 `KOS2103`。历史 Markdown 仍在 glob 外，符合 Assignment Residuals。
- `intra_record_mirrors: required` 是 Profile schema 常量（同记录 Current Status 必须与 Envelope 一致），**不是** `record_envelopes.mode: required`。已抽查 enveloped 记录的 Lifecycle/Status/Current Phase 与 fence 一致。
- `cross_document_mirrors: off`：`ACTIVE_WORK.md` / Dashboard 不得成为第二真相。Active Work 仍声明 Assignment 为 lifecycle SoT。
- `UPGRADE_STATUS.md` 按 Kit 仍是升级状态唯一事实来源；Profile `extensions` 只重复 pin 身份，数值与 status 页一致（`v0.5.0` / `e11cbfb`）。升级记录本身无 Envelope、也不在 `include` 内——这是有意的非机器路径，不是第二套 required 规则。

### 3. Authorization 是否被当成可执行许可（bearer token）而不是收据？

**没有当成 bearer token。收据语义写清楚；执行边界仍回到人类 Decision/Assignment。**

- 两条 AUTH 正文都写明：不是认证令牌 / 不能单独授权 `required`、merge、Release 或业务代码；诊断 AUTH 不授权改代码。
- `authorization_action` 与 AUTH `action`/`target`/`issuer_role` 对齐（`adopt_kos_2_2_advisory` → `KOS-UPGRADE-UK-001`；`establish_assignment` → `DIAGNOSTICS-VIEWER-LOAD-001`；issuer 与 `product_approver` 均为 Human Product Owner）。符合 Kit 绑定规则，不是「持有收据即可执行」。
- Kit R-05：外部/破坏性/merge/release 必须在执行时解析当前人类 Decision/Assignment。本 pin 的 exclusions 含 `required_mode`、`merge`、`release`、`product_code`、`pr_83_merge`、`implement`、`scheme_download_fix`。
- 残余：两条 AUTH 的 `consumption_state` 仍为 `unconsumed`，而对应 bounded action（钉住 Kit / 建立 Assignment）已落在 `f580613`。这是审计观察滞后，不是用收据当执行令牌。见 A-P2-01。

### 4. Gate 是否仍为 open？有没有用校验绿声称 Architecture/Product/merge Pass？

**两条 Gate 均为 `open`。没有用校验绿声称 Architecture / Product / merge Pass。**

- `GATE-KOS-UPGRADE-UK-ADVISORY`：`status: open`，`closure_decision_ref: null`，正文禁止把 advisory 校验证据标成 Product 或 Architecture Pass。
- `GATE-DIAGNOSTICS-VIEWER-LOAD-IMPLEMENTATION`：`status: open`；正文写实现、Simulator 回归和真机复验未开始。
- `EVIDENCE-KOS-UPGRADE-UK-ADVISORY-VALIDATE` Non-claims：不关闭该 Gate、不启用 `required`、不迁移其余 Markdown。
- `UPGRADE_STATUS` / `AGENTS.md` / `READING_MAPS.md`：校验绿 ≠ Product / merge / Release（及 Quality）通过。
- 结构安全网：`passed`/`closed` 时 `frozen_inputs` 与 `required_artifact_bindings` 不得为空（Kit `KOS2261`）。当前两 Gate 这两项皆为空，validator 不能把它们当已关闭。

本审查的 Architecture Verdict **不等于** 关闭 `GATE-KOS-UPGRADE-UK-ADVISORY`。

### 5. 第一条工作流是否完整？边界是否把诊断实现、万象下载、PR #83 merge 排除在外？

**作为「完整的开放工作流」是完整的。实现 / 万象 / #83 被排除。**

链（均在 `include` 内且同记录 mirror 对齐）：

| 环节 | 记录 | 状态 |
|---|---|---|
| Authorization | `AUTH-DIAGNOSTICS-VIEWER-LOAD-001` | active；action=`establish_assignment`；exclusions 含 implement / merge / pr_83_merge / scheme_download_fix |
| Decision（授权决策，非 closure） | `PD-DIAGNOSTICS-VIEWER-LOAD-001` | accepted；outcome 写明实现仍需另一次明确授权 |
| Assignment | `DIAGNOSTICS-VIEWER-LOAD-001` | lifecycle `ready`；phase 等待「授权实现」 |
| Evidence | `EVIDENCE-DIAGNOSTICS-VIEWER-LOAD-20260827` | current；device_attested / exploratory；非实现关闭证据 |
| Gate | `GATE-DIAGNOSTICS-VIEWER-LOAD-IMPLEMENTATION` | **open**；无 closure Decision |

这符合本项目 Assignment 的「one complete **open** workflow」，而不是 Kit 采用指南里已关闭 workflow 的 closure Decision。开放 Gate + 无 closure Decision 是正确的，否则会伪造关闭。

边界排除已重复写在 PD Non-goals、Assignment Non-goals/Stop、AUTH exclusions、Active Work、Dashboard。**本 pin 不授权诊断实现、不授权万象分类/下载猜修、不授权 merge PR #83。**

缺口（非完整性失败）：Kit 采用步骤 6 的 Review 记录尚未 enveloped；本文件是 pin 的独立 Architecture 审查，不在 `include` glob 内。诊断实现的 Architecture/Quality 审查属于另一次授权之后，不在本次范围。

### 6. 项目特有事实有没有被错误地写成通用 kit 规则？

**没有。** 角色、路径、真机 profile、RIME 仍留在项目侧。

- 角色名（Architecture and Knowledge Steward、Main App UI、Quality Performance and Release Maintainer、Human Product Owner）写在项目 Envelope / Profile，符合 Kit「必须参数化」。
- 真机证据继续用既有 [`universe-keyboard-human-operated-evidence-profile.md`](../kos/universe-keyboard-human-operated-evidence-profile.md)；Assignment 明确不在本 pin 用 H-01 模板替换。仓库无 `HUMAN_OPERATED_EVIDENCE_RUN.md` 双文件。
- Claim / Environment ID 在项目 Profile 注册（`CLAIM.DIAGNOSTICS.VIEWER_LOAD_BLOCKING`、`ENV.HUMAN_DEVICE` class `human_operated`、`ENV.LOCAL_EXECUTOR`）。Kit 不含这些产品语义。
- RIME / 万象 / ADR 0027 预算 / Extension 热路径只作为诊断 Assignment 的冻结输入与 Stop，没有提升为 Kit 通用规则。
- `extensions.universe_keyboard` 是项目命名空间，不产生授权。

### 7. P0/P1/P2 发现与 disposition

见下表。无 P0/P1。Disposition 仅使用 `fix` / `accept` / `tech_debt:<ID>`。

---

## Findings

| ID | Severity | Disposition | 说明 |
|---|---|---|---|
| A-P2-01 | P2 | `fix` | `AUTH-KOS-UPGRADE-UK-001` 与 `AUTH-DIAGNOSTICS-VIEWER-LOAD-001` 的 `consumption_state` 仍为 `unconsumed`，但各自 bounded action（advisory 采用 / 建立 Assignment）已体现在 `f580613`。Kit 将 consumption 定义为审计观察、不提供 replay 保护；当前正文也否定 bearer token。仍应在后续 Envelope 卫生中改为 `consumed`（或书面说明为何 Assignment 仍 Active 时收据保持 unconsumed），以免被误读成可反复执行的许可。不阻塞对本 pin 的 Quality 审查。 |
| A-P2-02 | P2 | `accept` | `GATE-DIAGNOSTICS-VIEWER-LOAD-IMPLEMENTATION` 的 `required_evidence_refs` 绑定的是入口阻塞截图，不是实现关闭证据。Gate 保持 `open`，且 `frozen_inputs` / `required_artifact_bindings` 为空，无法在 validator 下伪造成 `passed`/`closed`。接受为开放工作流的入口绑定；关闭该 Gate 必须另附实现/回归证据与独立 closure Decision。本 accept 只覆盖「开放状态下的入口证据绑定」，不接受用该截图关 Gate。 |
| A-P2-03 | P2 | `accept` | `DIAGNOSTICS-VIEWER-LOAD-001.envelope.parent_refs` 指向 `KOS-UPGRADE-UK-001`，把产品 Assignment 接到治理 pin 的谱系上。权威仍只经 `AUTH-DIAGNOSTICS-VIEWER-LOAD-001`（`establish_assignment`，排除 implement）。接受为「第一条 enveloped workflow」的谱系边，不把它读成升级 AUTH 授权实现。后续 agent 不得沿 parent 扩大范围。 |
| A-P3-01 | P3 | `accept` | `ENGINEERING_DASHBOARD.md` 新增 2026-08-27 段正确，但保留的「Active Work 收敛 — 2026-08-24」仍写 `3/10`；Active Work 现为 `5/10`。Dashboard 非 SoT，且 `cross_document_mirrors: off`。不把该漂移升级为双真相。 |
| A-P3-02 | P3 | `accept` | 校验证据绑定了 Kit commit 与 `.kos/project.json`，未绑定 UK `f580613`。对 `ENV.LOCAL_EXECUTOR` 的 executor_recorded 证据可接受；Quality 若复跑应注明 checkout。 |
| A-P3-03 | P3 | `accept` | `GATE-KOS-UPGRADE-UK-ADVISORY.evidence_reviewer` 写的是产出证据的「Current Grok session」，不是独立 `architecture_review`。`close_authority` 仍是 Human Product Owner，Gate 保持 open。独立性由本审查文件承担，不由该字段关闭 Gate。 |

无 `tech_debt:<ID>` 项（不新开债务记录）。

---

## Conditions (for Pass with conditions)

1. **A-P2-01 `fix`：** 后续 Envelope 卫生应修正两条 AUTH 的 `consumption_state`，或在收据上写明「Assignment Active ≠ AUTH unconsumed」的审计规则。不是本审查的修复提交。
2. **A-P2-02 / A-P2-03 `accept`：** 诊断实现、关 Gate、万象、PR #83 仍须新的人类授权；parent_refs 与入口证据不得被解释为执行许可。

这些条件不构成未处置 P0，不阻止进入独立 Quality 审查。

---

## Non-claims

本文件：

- **不是** Quality 审查，不评判 validator 可复现性以外的测试充分性。
- **不是** Product Gate / Product Accept，不授权 `required`、不授权实现诊断查看、不授权万象下载分类或猜修。
- **不是** merge 或 Release 结论；不授权合并本分支或 PR #83。
- **不** 把 advisory 校验绿、本 Verdict、或 `UPGRADE_STATUS` 的 `Adopted — advisory only` 写成 Architecture Gate Pass。`Adopted` 只表示 Human Product Owner 对 Kit 版本 pin 的升级处置，Assignment 仍为 `active`。
- **不** 关闭任何 Gate 记录。
- **不** 把 `include` glob 扩到历史 Markdown，也 **不** 授权 `record_envelopes.mode: required`。

---

## Quality handoff

**可以进入独立 Quality 审查：** 是（无未处置 P0）。

Quality 应冻结同一提交 `f580613` 与 Kit `e11cbfb` / `v0.5.0`，并至少核对：

- advisory validator 只读、exit 0、输出未被措辞为 Gate/Product/merge Pass；
- include glob 仍不扫历史 Assignment；
- 两条 Gate 仍为 `open`；
- A-P2-01 作为 Envelope 卫生（非本 Quality 的 merge 门，除非 Quality 另判）。

Quality 通过也不等于 Product 通过，也不等于可以 `required` 或 merge。
