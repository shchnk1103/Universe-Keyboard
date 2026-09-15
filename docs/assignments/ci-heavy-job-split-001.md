# Assignment: CI-HEAVY-JOB-SPLIT-001 — 拆分 full 路径 heavy job 并去掉重复 Debug build

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "CI-HEAVY-JOB-SPLIT-001",
  "record_type": "assignment",
  "title": "Split full-path Swift 6 heavy jobs for localization and drop redundant Debug build",
  "lifecycle": "active",
  "current_phase": "All Quality fix residuals closed; #130 draft awaiting merge authorization",
  "authorization_action": "implement_ci_heavy_job_split",
  "updated_at": "2026-09-15T11:00:00+08:00",
  "revalidation_triggers": ["scope_changed", "workflow_contract_changed", "required_checks_changed", "branch_protection_changed", "skip_rule_requested"],
  "authorization_refs": ["AUTH-CI-HEAVY-JOB-SPLIT-001", "AUTH-CI-HEAVY-JOB-SPLIT-001-IMPLEMENT", "AUTH-CI-HEAVY-JOB-SPLIT-001-PUBLISH"],
  "parent_refs": ["TD-016-CI-TIERING-001"],
  "responsibilities": {
    "domain_owner": "Quality, Performance and Release Maintainer",
    "executor": "Current Grok session",
    "environment_executor": "Current Grok session locally after implement authorization; GitHub Actions hosted runners after publication authorization",
    "human_dependency": "Human Product Owner for implementation, commit, push, merge, hosted-fixture, and any required-check or branch-protection change",
    "architecture_reviewer": "Independent Architecture and Knowledge Steward reviewer after implementation",
    "quality_reviewer": "Independent Quality, Performance and Release reviewer after implementation",
    "product_approver": "Human Product Owner"
  }
}
```

**Policy version:** `1.0.0`

**Repository Change Type:** `Implementation` + `Procedure` + `Documentation`

## Current Status

| Field | Value |
|---|---|
| Lifecycle | Active |
| Phase | Quality `fix` 残差均 closed（Q-01/02/03）；#131 已 close without merge；#130 draft 待 Human merge 授权 |
| Non-claims | 不是 Product Gate、无条件 Quality Pass、merge 或 required-check 迁移 |
| Next | Human 决定是否 undraft/merge #130 |
| Residuals | 见下方 ledger |

### Review Residual Ledger

| ID | Residual | Owner | Disposition | Evidence pointer |
|---|---|---|---|---|
| `CHS-A-01` | 无 hosted 五条-job 聚合观察 | Architecture | `accept` | [Architecture review](../reviews/ci-heavy-job-split-001-architecture-review.md) |
| `CHS-A-02` | 回滚 SoT 须同时包含 workflow YAML 与 `verify_final_gate.sh`（及其测试） | Executor / Architecture | `closed` | [Architecture revalidation](../reviews/ci-heavy-job-split-001-architecture-review.md#revalidation--chs-a-02-2026-09-15-asiashanghai) |
| `CHS-A-03` | A-P2-02 未关；禁止把五条 heavy 设为 required | Architecture | `tech_debt:TD-016` | [TD-016](../TECH_DEBT.md#td-016-ci-变更分级与文档提交快速门禁) |
| `CHS-A-04` | Gate 单测未穷举 | Architecture | `accept` | Architecture review |
| `CHS-A-05` | 脏树混有 RELEASE-EVIDENCE | Architecture | `accept` | Architecture review；commit 须切开 |
| `CHS-Q-01` | 无 hosted `full` | Quality | `closed` | [hosted full evidence](../evidence/ci-heavy-job-split-001-hosted-full-2026-09-15.md) · [Quality revalidation](../reviews/ci-heavy-job-split-001-quality-review.md) · run `34923523955` |
| `CHS-Q-02` | 无 hosted `docs_only` | Quality | `closed` | [hosted docs_only evidence](../evidence/ci-heavy-job-split-001-hosted-docs-only-2026-09-15.md) · Quality revalidation · run `34924821846`；[#131](https://github.com/shchnk1103/Universe-Keyboard/pull/131) close without merge |
| `CHS-Q-03` | 工作树未隔离本切片 | Quality | `closed` | Quality revalidation：`39a25bd` vs `origin/main` 恰好 20 个本切片文件 |
| `CHS-Q-04` | Gate 单测抽样 | Quality | `accept` | Quality review |
| `CHS-Q-05` | A-P2-02 仍开放 | Quality | `tech_debt:TD-016` | TD-016 |

---

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Owner 当前会话「可以，按照你的建议写一个 Assignment 吧。」，`2026-09-15 Asia/Shanghai`
- Product Approver: Human Product Owner / Product Lead
- Authorization: [AUTH-CI-HEAVY-JOB-SPLIT-001](../authorizations/AUTH-CI-HEAVY-JOB-SPLIT-001.md)（撰文，consumed）· [AUTH-CI-HEAVY-JOB-SPLIT-001-IMPLEMENT](../authorizations/AUTH-CI-HEAVY-JOB-SPLIT-001-IMPLEMENT.md)（实施，active）· [AUTH-CI-HEAVY-JOB-SPLIT-001-PUBLISH](../authorizations/AUTH-CI-HEAVY-JOB-SPLIT-001-PUBLISH.md)（隔离 commit/push，active）
- Product Decision: [PD-CI-HEAVY-JOB-SPLIT-001](../product-decisions/CI-HEAVY-JOB-SPLIT-001-authorization.md)

## KOS v0.8.0 optional-contract selection

| Contract | Selection | Boundary and owner source |
|---|---|---|
| E-01 claim-bound observation | Not applicable | 本切片改 CI job 图与聚合 Gate，不声称产品/运行时/真机行为 |
| A-01 / B-01 authorization chain and briefing | Adopted | Assignment → Authorization → Accepted Product Decision；实施、发布、merge 各自独立 |
| P-01 publication facts | Not applicable | 本切片不发布；实施授权后若 opt-in 再填 |
| D-01 final-documentation receipt | Not applicable | 普通 docs 链接检查不得称为 D-01 |

### Authorization frontier (A-01 / B-01)

| Slice | Status | Action / target / boundary | Authority source |
|---|---|---|---|
| Current authorized slice | In progress | 隔离功能分支 `feature/ci-heavy-job-split-001` 上 commit/push；不含 RELEASE-EVIDENCE | [AUTH-CI-HEAVY-JOB-SPLIT-001-PUBLISH](../authorizations/AUTH-CI-HEAVY-JOB-SPLIT-001-PUBLISH.md) |
| Author Assignment records | Authorized | 撰文切片已 consumed | [AUTH-CI-HEAVY-JOB-SPLIT-001](../authorizations/AUTH-CI-HEAVY-JOB-SPLIT-001.md) |
| Commit / push / PR | Authorized | 隔离功能分支 commit 与 push；不授权 merge 或开合入默认分支的 PR | [AUTH-CI-HEAVY-JOB-SPLIT-001-PUBLISH](../authorizations/AUTH-CI-HEAVY-JOB-SPLIT-001-PUBLISH.md) |
| Merge / Release | Not authorized | 合入默认分支或任何发布动作 | 独立 Human 授权 |
| Required-check / branch protection | Not authorized | 仍属 [TD-016](../TECH_DEBT.md#td-016-ci-变更分级与文档提交快速门禁) A-P2-02 | 不得借本 Assignment 迁移 |
| Environment or external slice | Not authorized | GitHub Actions hosted full 与 docs-only fixture | 随发布授权给出 |

## Boundary

### Objective

在 **不增加任何新的跳过规则** 的前提下，把 `full` 路径上现在串行的单一 `build-and-test` job 拆成可并行、失败可定位的 heavy jobs，并去掉 Debug `test` 之后重复的 Debug `build`。墙钟时间应对齐最慢的那一个 heavy job，而不是五段 `xcodebuild` 相加。分类合同保持 ADR 0031：只有 `docs_only` 与 `full`。

### Scope

实施一旦另行授权，仅包括以下内容。

1. **保持分类不变。** `scripts/ci/classify_changes.py` 仍只输出 `docs_only` / `full`。轻量 allowlist 仍仅为根目录 `*.md`、`docs/**`、`.kos/**`。空 diff、无效 base/head、未知路径 fail-closed 为 `full`。禁止 `paths-ignore`。禁止 UI / Rime / KeyboardCore / Lua / OpenCC 路径跳过。
2. **拆分 heavy jobs（仅 `requires_full == true` 时运行）。** 建议 GitHub job `name` 固定为：

   | Job name | 工作 | 备注 |
   |---|---|---|
   | `format-swift` | 对 base…head 变更 `.swift` 做 `swift-format lint --strict` | macOS；不拉 RIME vendor |
   | `test-keyboardcore` | `swift test --package-path Packages/KeyboardCore` | 不拉 RIME vendor，除非该包测试证明需要 |
   | `test-rimebridge` | 现有 `RimeBridgeTests` `xcodebuild test` | 先 `scripts/ensure_rime_vendor.sh fetch` |
   | `test-app-keyboard` | 现有 `Universe Keyboard` scheme Debug `xcodebuild test` | 先 fetch vendor；**不再**追加 Debug `build` |
   | `build-release` | 现有 Release `xcodebuild build` | 先 fetch vendor |

   `classify-change`、`lightweight-checks`、`final-quality-gate` 名称保留。`build-and-test` 作为单一 job 删除。
3. **去掉重复 Debug build。** Debug `test` 已经编译 Debug 配置；不得在同一变更上再跑一次 Debug `build`。Release `build` 保留在每个 `full` PR/push 上，不挪到仅 `main`。
4. **重写 `final-quality-gate` 结果矩阵。**

   - `classify-change` 与 `lightweight-checks` 必须 `success`。
   - `docs_only`：五个 heavy job **全部恰好** `skipped`；任一 `success` / `failure` / 缺失为失败。
   - `full`：五个 heavy job **全部** `success`；任一 `skipped` / `failure` / 缺失为失败。
   - 更新 `scripts/ci/verify_final_gate.sh` 与 `scripts/ci/tests/test_verify_final_gate.sh`。不得用 workflow 级 skip 冒充聚合绿。
5. **并发与回滚。** 保留现有 `concurrency` + `cancel-in-progress`。回滚同时还原 `.github/workflows/swift6-quality.yml` 与 `scripts/ci/verify_final_gate.sh`（及其测试），回到 TD-016 单一条件 `build-and-test`（含 Debug build，Gate 四参数）。只还原其中一侧会因调用约定不匹配而 fail-closed，那不是可运行回滚。不是回到无分类的无条件 heavy job，也不是 `paths-ignore`。
6. **文档对齐。** 更新 `docs/CI_CHANGE_CLASSIFICATION.md` job 合同、Accepted ADR 0031 的 job 图与后果（Status 保持 Accepted，记为合同修订而非新 ADR）、`AGENTS.md` 本地门禁：本地仍可串行；删除「Debug test 后再 Debug build」；本地 full 仍须 KeyboardCore + RimeBridge + App/Keyboard test + Release build。
7. **验证。** 分类器单测保持绿。新 Gate 矩阵单测覆盖 full-all-success、docs-all-skipped、以及「full 但某一 heavy skipped/failed」和「docs_only 但某一 heavy success」。实施并取得发布授权后：一条 hosted `full` 路径必须五条 heavy 都跑且 Gate 绿；一条 hosted `docs_only` 路径必须五条 heavy 都 skip 且 Gate 绿。改 workflow / `scripts/ci/**` 本身仍分类为 `full`。
8. **独立审查。** 实施完成后交独立 Architecture 与独立 Quality；二者通过不等于 Product Gate / merge。

### Non-goals

- 不按 UI、Rime、Views、Lua、OpenCC 或其它源路径跳过 heavy job。
- 不增加第三档分类（包括 hosted KeyboardCore-only skip）。
- 不把 Release build 收到仅 `main` / 仅 `workflow_dispatch`。
- 不引入 DerivedData / SPM / RIME vendor 缓存（可另开 Assignment）。
- 不修改测试语义、Swift 6、warnings-as-errors、模拟器目的地或 RIME artifact 合同。
- 不启用 branch protection，不把拆开的 job 或 `final-quality-gate` 设为 required；不关闭 TD-016 A-P2-02。
- 不加入 PAT、跨仓库 secret，不启用 KOS `required`，不 vendor 私有 Kit。
- 不授权 commit、push、PR、merge、TestFlight 或 Release。
- 不把 CI 墙钟下降或 job 级绿当成 Quality / Product / Release 通过。

### Required Inputs

- [ADR 0031](../architecture/decisions/0031-fail-closed-ci-change-classification.md)（Accepted）
- [`docs/CI_CHANGE_CLASSIFICATION.md`](../CI_CHANGE_CLASSIFICATION.md)
- Closed [`TD-016-CI-TIERING-001`](td-016-ci-tiering-001.md) 与残余 [TD-016](../TECH_DEBT.md#td-016-ci-变更分级与文档提交快速门禁)
- `.github/workflows/swift6-quality.yml` 当前单一 `build-and-test` 合同
- `AGENTS.md` 本地 CI 门禁
- [`PD-CI-HEAVY-JOB-SPLIT-001`](../product-decisions/CI-HEAVY-JOB-SPLIT-001-authorization.md)

## Assignment

- Domain Owner: Quality, Performance & Release Maintainer
- Executor: Current Grok session
- Environment Executor: Current Grok session（本地脚本与工作流语法）；GitHub Actions hosted runners（仅在实施与发布均已授权之后）
- Human Dependency: Human Product Owner — 本记录之后必须分别授权：implement、commit/push/PR、hosted fixture 观察、merge；required-check 迁移仍禁止
- Architecture Reviewer: 独立 Architecture & Knowledge Steward（实施后；撰写本 Assignment 不需要 Architecture Gate）
- Quality Reviewer: 独立 Quality, Performance & Release Maintainer（实施后）
- Product Approver: Human Product Owner / Product Lead
- Handoff Target: Human Product Owner（是否授权实施）→ 实施后 Independent Architecture → Independent Quality → Human Product Owner（是否授权发布/merge）

## Gates

### Entry Criteria

- [x] Human Product Owner 已要求按「拆 job + 去重复 Debug build、不引入跳过规则」撰写 Assignment。
- [x] 本切片拥有独立 Assignment，不复活已 Closed 的 `TD-016-CI-TIERING-001`。
- [x] 无 `UNKNOWN` 责任字段。
- [x] 存在匹配的 implement Authorization，当前授权切片为 workflow/脚本/文档实现。
- [x] 发布前：工作在隔离功能分支上进行，不把 workflow 改动塞进无关 PR。

### Exit Criteria（仅实施授权后适用）

- [x] `docs_only` / `full` 分类表与 classifier 行为与本 Assignment 开始时语义相同（未改 `classify_changes.py`）。
- [x] `full` 时五个 named heavy jobs 均运行；`docs_only` 时五个均 skip（workflow `if:`）。
- [x] 无 Debug `test` 之后的 Debug `build`。
- [x] `final-quality-gate` 按上文矩阵 fail-closed；本地脚本单测覆盖成功与失败组合。
- [x] ADR 0031、`CI_CHANGE_CLASSIFICATION.md`、`AGENTS.md` 本地门禁与 job 名称一致。
- [x] Hosted `full` 证据：五条 heavy 为 success，Gate success。
- [x] Hosted `docs_only` 证据：五条 heavy 为 skipped，Gate success。不得为取证而合并 docs-only fixture PR，除非另授权。
- [x] 独立 Architecture 与 Quality 结论已记录；残差均有 `fix` / `accept` / `tech_debt:<ID>`。含 `fix` 的项在取得证据前不得 Close。
- [ ] Human Product Owner 决定是否 merge。Merge 不是本 Exit 的默认项。

### Stop Conditions

- 任何提案以路径、文件扩展名或「只改了 UI」为由跳过 KeyboardCore、RimeBridge、App/Keyboard tests 或 Release build。
- 使用 workflow `paths-ignore` 或让 required check 因未调度而永久 pending。
- 削弱 Swift 6、warnings-as-errors、现有测试或 RIME vendor 准备。
- 把拆 job 当作 TD-016 required-check 迁移，或在无独立授权下改 branch protection。
- 需要 PAT、跨仓库 secret、KOS `required` 或 vendor 私有 Kit 才能完成切片。
- 将并行 macOS job 的账单上升解释为必须再加跳过规则。
- 分类器、workflow 或 Gate 脚本只能从 PR head 取得信任、却把结果宣传为不可绕过的 required check。

## Handoff

- Required Handoff Content: job 图、Gate 结果矩阵、与 TD-016 分类合同的 diff（应为「无分类语义 diff」）、删除 Debug build 的理由、本地与 hosted 证据、回滚步骤、未做的缓存/路径跳过/required-check 项、macOS 并行分钟数可能上升的说明。
- Local script evidence: [`ci-heavy-job-split-001-local-gate-2026-09-15.md`](../evidence/ci-heavy-job-split-001-local-gate-2026-09-15.md)
- Independent reviews: [Architecture Pass with conditions](../reviews/ci-heavy-job-split-001-architecture-review.md) · [Quality Pass with conditions](../reviews/ci-heavy-job-split-001-quality-review.md)
- Revalidation Trigger: 增加新的可执行/构建输入目录；heavy job 名称或 Gate 矩阵变化；branch protection / required checks 变化；有人请求路径跳过；Xcode scheme / 模拟器目的地 / Release 门禁变化；KOS Kit 分发变化。

## Cost And Localization Note

拆 job 的目的是 **定位** 与 **墙钟时间**，不是减少 GitHub 账单。每个 macOS job 会重复 checkout、（如需要）RIME vendor、冷编译和模拟器启动。计费分钟数可能高于今天的单一串行 job。本 Assignment 接受该代价；若 Human 认为不可接受，应停止本切片，而不是加跳过规则。

## History

- `2026-09-15 Asia/Shanghai`: Human Product Owner 授权按建议撰写本有界 Assignment。实施、commit、push、merge 均未授权。
- `2026-09-15 Asia/Shanghai`: Human Product Owner 接受 Assignment 并授权实施。workflow 拆分为五条 heavy jobs，去掉重复 Debug build，Gate 矩阵与文档已改。本地 classifier 12 tests OK；`test_verify_final_gate.sh` 与 KOS trigger-path 测试 PASS。证据：[`ci-heavy-job-split-001-local-gate-2026-09-15.md`](../evidence/ci-heavy-job-split-001-local-gate-2026-09-15.md)。commit / push / merge / hosted fixture 仍未授权。
- `2026-09-15 Asia/Shanghai`: Human 授权独立审查。Architecture **Pass with conditions**（`CHS-A-01`…`CHS-A-05`）；Quality **Pass with conditions**（`CHS-Q-01`…`CHS-Q-05`，脚本 Quality-reverified）。不是 Product Gate / merge / hosted 绿。
- `2026-09-15 Asia/Shanghai`: Human 授权修复 CHS-A-02。回滚 SoT 现要求同时还原 workflow YAML 与 Gate 脚本及测试。该项仍为 `fix`，待独立 Architecture 复核。
- `2026-09-15 Asia/Shanghai`: 独立 Architecture 专项复核 CHS-A-02 → **closed**。首次 Verdict 仍为 Pass with conditions；CHS-A-01/03/04/05 与 Quality 残差未改。无 commit / push。
- `2026-09-15 Asia/Shanghai`: Human 授权隔离功能分支 commit/push。基线 `origin/main`；不含 RELEASE-EVIDENCE 产品文件。
- `2026-09-15 Asia/Shanghai`: Draft PR #130；hosted run `34923523955` same-head `full` 五条 heavy + Gate success。独立 Quality 复核 CHS-Q-01 / CHS-Q-03 **closed**。CHS-Q-02 仍开放。无 merge。
- `2026-09-15 Asia/Shanghai`: Stacked fixture PR #131 run `34924821846` `docs_only`；五条 heavy skipped；Gate success。Quality 复核 CHS-Q-02 **closed**。#131 close without merge。#130 仍 draft；无 merge。
