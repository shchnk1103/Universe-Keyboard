# CI-HEAVY-JOB-SPLIT-001 — Independent Architecture Review

## Review identity

| Field | Value |
|---|---|
| Reviewer | `ci_split_arch_review`（独立 Architecture & Knowledge Steward reviewer） |
| Date / timezone | `2026-09-15 Asia/Shanghai` |
| Frozen subject | 未提交工作树；`HEAD` = `83f840b` on local `main`。实现尚未 commit / push |
| Scope | 仅 [`CI-HEAVY-JOB-SPLIT-001`](../assignments/ci-heavy-job-split-001.md)。工作树中的 `RELEASE-EVIDENCE-PROMOTION-001`（Swift/UI/`scripts/release/` 等）不在范围，不据其下结论 |
| Independence | 只读核对工作树与合同；独立重跑本地 classifier / Gate / KOS trigger 脚本；**仅新建本文件**；未改 workflow、脚本、ADR 正文或其它实现；未 commit / push / merge；未改 GitHub 设置 |
| Authority reviewed | [`PD-CI-HEAVY-JOB-SPLIT-001`](../product-decisions/CI-HEAVY-JOB-SPLIT-001-authorization.md) · [`AUTH-CI-HEAVY-JOB-SPLIT-001-IMPLEMENT`](../authorizations/AUTH-CI-HEAVY-JOB-SPLIT-001-IMPLEMENT.md) |

本审查 **不授权** commit、push、merge、hosted fixture、required-check、branch protection、Product Gate 或 Release。

## Verdict

**Pass with conditions。** 当前不可进入 merge-ready，也不可当作 Product Gate。

分类权威仍 fail-closed；heavy 拆分只改 job 图；`final-quality-gate` 对五条 named jobs 做 all-success / all-skipped 聚合，cancelled / missing / 非法 `requires_full` 在脚本层 fail-closed；ADR 0031 是合同修订而非新 ADR、亦未升格 trust-root；去掉 Debug `build` 落在授权范围内；TD-016 A-P2-02 仍开放；并行 macOS 账单上升被接受，未据此加跳过规则。

下列条件在 Architecture 关闭「可发布」叙事之前必须保持可见：hosted 五条 heavy 的 GitHub result 语义尚未观察；回滚说明须点名 Gate 脚本；required-check 仍禁止。

| ID | Severity | Disposition | Finding |
|---|---|---|---|
| CHS-A-01 | P2 | `accept` | 无 hosted `full` / `docs_only` fixture，故不能声称 GitHub `if: always()` × 五条 skipped/success job 的聚合已在 hosted 上稳定。这是 Assignment Exit / publication 阻塞，不是 job 图设计缺口；不得把本地脚本绿写成 hosted 绿。 |
| CHS-A-02 | P2 | `fix` | 回滚 SoT 写成「一次 workflow revert、恢复单一条件 `build-and-test`」，但 `verify_final_gate.sh` 调用约定已从 4 参改为 8 参。只还原 YAML 或只还原脚本都会让 Gate fail-closed（安全），却不能恢复可工作的旧合同。须在 [`CI_CHANGE_CLASSIFICATION.md`](../CI_CHANGE_CLASSIFICATION.md)（及必要时 Assignment）写明 revert 集合包含 `.github/workflows/swift6-quality.yml` **与** `scripts/ci/verify_final_gate.sh`（及其测试）。 |
| CHS-A-03 | P2 | `tech_debt:TD-016` | 本切片未关闭 A-P2-02：classifier / workflow / Gate 仍从 PR head checkout。`build-and-test` 删除、五条 named heavy 出现，扩大了误把可 skip job 设为 required 的表面。未来若启用保护，仍只能在观察 light+full fixture 之后配置始终运行的 `final-quality-gate`；禁止把五条 heavy 或当前绿色当独立 trust root。 |
| CHS-A-04 | P3 | `accept` | Gate 单测按失败模式抽样，未穷举 5×全部 GitHub result；`docs_only` 未单列 `cancelled`。脚本对非 `success`/`skipped` 的精确匹配已 fail-closed；不构成分类或聚合合同漏洞。 |
| CHS-A-05 | P2 | `accept` | 工作树混有无关 `RELEASE-EVIDENCE-PROMOTION-001`。不否定本切片 job 合同；后续 commit/push 必须按 AUTH 切开本切片文件，且不得把混合 PR 当本审查对象。 |

## Passed Boundaries

- **`docs_only` / `full` 仍 fail-closed。** [`scripts/ci/classify_changes.py`](../../scripts/ci/classify_changes.py) 相对 `HEAD` **无 diff**。轻量 allowlist 仍仅为根目录 `*.md`、`docs/**`、`.kos/**`；空 diff、无效 base/head、未知路径走向 `full`。工作流 `on:` 无 `paths-ignore` / `paths:` 过滤器。五条 heavy 共用同一条件 `needs.classify_change.outputs.requires_full == 'true'`，没有 UI / Rime / KeyboardCore / Lua / OpenCC 路径跳过。
- **分类权威未迁走。** [`docs/CI_CHANGE_CLASSIFICATION.md`](../CI_CHANGE_CLASSIFICATION.md) 仍以 ADR 0031 / TD-016 为分类 SoT；本 Assignment 只拥有 `full` heavy job 图。`lightweight-checks` 与 `classify-change` 始终运行。
- **Gate 矩阵。** [`scripts/ci/verify_final_gate.sh`](../../scripts/ci/verify_final_gate.sh) 要求 classify + lightweight 均为 `success`；`requires_full=true` 时五条 heavy 全为 `success`；`false` 时五条全为恰好 `skipped`；其它 `requires_full`、缺参、cancelled、failure、错位 success 均失败。旧四参数调用被拒绝。本 reviewer 重跑：12 个 Python 测试 OK；`test_verify_final_gate.sh` / `test_kos_trigger_paths.sh` PASS。
- **GitHub 聚合形状。** `final-quality-gate` 保留 `if: always()`，`needs` 含 classify、lightweight 与五条 heavy。这与 TD-016 已落地的「始终运行聚合、合法 skipped」相同，只是 heavy 从 1 条变为 5 条。五条 heavy **不是** required check；当前 `main` 无 branch protection。本切片未引入「因未调度而永久 pending」的 workflow 级 skip。hosted 上的 5-way `needs.*.result` 仍属 CHS-A-01。
- **ADR 0031。** Status 保持 Accepted；`2026-09-15` 段标明合同修订、非新 ADR；分类仍只有两档；Consequences 写明账单分钟可能上升。未把 workflow 升格为 trust-root。
- **Debug `build`。** 删除的是 App scheme 在 Debug `test` 之后的重复 Debug `build`；`test-app-keyboard` 仍 Debug `test`，`build-release` 仍每个 `full` 变更 Release `build`，未收到仅 `main`。与 PD / AUTH / Assignment 一致，不是越权缩验证面。本地 [`AGENTS.md`](../../AGENTS.md) 门禁与 [`RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md) 自动化段已去掉该重复 `build`。
- **KOS advisory。** 分类只选择验证工作；CI 绿 ≠ merge / Product / Release。KOS 2.2 仍 advisory；本切片未启用 `required`。证据 [`ci-heavy-job-split-001-local-gate-2026-09-15.md`](../evidence/ci-heavy-job-split-001-local-gate-2026-09-15.md) Grade 为 Executor-recorded（M-04 允许），未冒充 Quality/hosted。
- **账单。** ADR / Assignment 接受并行 macOS 冷启动使计费分钟上升；实现未用路径跳过对冲。

## Findings And Disposition

### CHS-A-01 — hosted 聚合未观察（`accept`）

ADR 0031 Risks 已写明：GitHub expression / job-result 语义可能与本地脚本不同，首次 hosted run 才是该层证据。本切片 AUTH 明确排除 hosted fixture。本地矩阵测试不能替代 `needs.format_swift.result` 等在 skipped/success/cancelled 下的 hosted 取值。

Architecture 接受「实施授权范围内设计已写完」；**不接受**把本 Verdict 解释为 hosted 合同已证明。Assignment Exit 的 hosted `full` / `docs_only` 两框仍未勾。disposition 不是 `fix`（无需改 job 图才能开始取证），也不是 `tech_debt:TD-016`（缺的是本 Assignment 自己的 fixture，不是 A-P2-02）。

### CHS-A-02 — 回滚集合写窄了（`fix`）

[`docs/CI_CHANGE_CLASSIFICATION.md`](../CI_CHANGE_CLASSIFICATION.md) Branch Protection And Rollback：

> Rollback is one workflow revert: restore the previous single conditional `build-and-test` job, including its extra Debug `build` step.

旧 Gate 为 4 参（`classify, lightweight, heavy, requires_full`），新 Gate 为 8 参且第三参是 `requires_full`。部分还原时脚本会把 `success`/`skipped` 当成非法 classification，Gate 变红——**安全，但不是可运行回滚**。回滚描述要继续安全且可操作，必须把 Gate 脚本（及测试）算进同一 revert 集合；并继续禁止 `paths-ignore` 与源路径跳过。

### CHS-A-03 — A-P2-02 仍在；job 名表面变大（`tech_debt:TD-016`）

[`docs/TECH_DEBT.md`](../TECH_DEBT.md) TD-016 仍开放 required-check trust root；Related 明确本切片 **不** 关闭 A-P2-02。`final-quality-gate` / classifier 仍 `actions/checkout@v4` 后执行 PR head 脚本。删除 `build-and-test` 后，若有人把五条 heavy 的 GitHub `name` 配成 required，docs-only 上它们为 skipped：今日无 protection，故不是当前 pending 事故；这正是 TD-016 要拦的迁移。本切片正确之处是继续只把始终运行的 Gate 当作未来唯一候选聚合点。

### CHS-A-04 — 单测未穷举（`accept`）

实现已对任意 `result != expected` fail-closed。抽样覆盖 Assignment 点名的 full-all-success、docs-all-skipped、full 下 skip/fail/cancel/missing、docs_only 下 success/failure/missing。属 Quality 覆盖完备性，不改架构合同。

### CHS-A-05 — 脏树混片（`accept`）

AUTH 绑定的实施文件与本切片文档可独立审查。混合工作树不是 job 图缺陷；是后续 publication 的隔离条件（Assignment Entry「隔离功能分支」仍未勾）。Architecture 不把混片当成本切片设计失败。

## Evidence Boundary

- 核对对象是 **工作树**，不是 commit。本 reviewer 未冻结实现 SHA。
- 范围外文件（发布证据 UI/store、ADR 0035、`scripts/release/` 等）未用于本 Verdict。
- 本地脚本由本 reviewer 重跑通过；这不是 KOS M-04 的 Quality-reverified（Quality 另有独立记录），也不是 xcodebuild / hosted 证据。
- 未跑 KeyboardCore / RimeBridge / App+Keyboard `test` 或 Release `build`（本切片不改测试语义；merge 前仍须 AGENTS 本地门禁）。
- 未观察任何 GitHub Actions run ID。
- CI 绿（即使将来 hosted 绿）≠ Quality Pass、Product Gate、merge 或 Release。

## Handoff

- 交独立 Quality（若并行记录已存在，以其自身 Verdict / 残差为准；本文件不关闭 Quality 条件）。
- `fix` 项 CHS-A-02：在 commit 前收紧回滚段落的文件集合。
- publication / hosted fixture / merge 仍须 Human 另授权；功能分支只含本切片允许文件。
- 禁止：`paths-ignore`、源路径跳过、第三档分类、把 Release 收到仅 `main`、关闭 TD-016 A-P2-02、把五条 heavy 或 Gate 设为 required。
- 下一步不是 Product Gate。Human Product Owner 在独立审查残差处置后，再决定是否授权 commit/push 与 hosted fixture。

## Revalidation — CHS-A-02 (`2026-09-15 Asia/Shanghai`)

| Field | Value |
|---|---|
| Reviewer | `ci_split_arch_review` |
| Scope | CHS-A-02 only |
| Independence | 只读核对回滚文案；仅追加本段。未改首次 Verdict 或 CHS-A-01/03/04/05；未改 YAML、脚本或其它文档 |
| Authority | Human 授权只复核 CHS-A-02 |

首次审查的 Verdict（Pass with conditions）与 CHS-A-01/03/04/05 **冻结、不重新打分**。本段不授权 commit / push / merge / hosted fixture / Product Gate，不关闭 Quality 残差。

### Verdict for CHS-A-02

**closed。** SoT 与 Assignment 均已把 revert 集合写成 workflow YAML **与** Gate 脚本及其测试；并写明单侧还原因 8 参/4 参约定不匹配而 fail-closed、不是可运行回滚；仍禁止 `paths-ignore` 与源路径跳过。

### Condition disposition

| ID | previous | current | evidence |
|---|---|---|---|
| CHS-A-02 | `fix` | `closed` | [`docs/CI_CHANGE_CLASSIFICATION.md`](../CI_CHANGE_CLASSIFICATION.md) § Branch Protection And Rollback 现列出 revert 集合为 [`.github/workflows/swift6-quality.yml`](../../.github/workflows/swift6-quality.yml)、[`scripts/ci/verify_final_gate.sh`](../../scripts/ci/verify_final_gate.sh) 与 [`scripts/ci/tests/test_verify_final_gate.sh`](../../scripts/ci/tests/test_verify_final_gate.sh)；写明 Gate 现为八参数（`requires_full` 第三）、只还原一侧 fail-closed 但不是可运行回滚；继续禁止 `paths-ignore` 与 UI/Rime/KeyboardCore 路径跳过。[`docs/assignments/ci-heavy-job-split-001.md`](../assignments/ci-heavy-job-split-001.md) §并发与回滚（条目 5）同一集合与同一警告。 |

### Unchanged residuals

| ID | Disposition (frozen) | Note |
|---|---|---|
| CHS-A-01 | `accept` | 本段不重新审查 hosted 聚合 |
| CHS-A-03 | `tech_debt:TD-016` | 本段不重新审查 A-P2-02 / required-check |
| CHS-A-04 | `accept` | 本段不重新审查 Gate 单测穷举 |
| CHS-A-05 | `accept` | 本段不重新审查脏树混片 |

首次 Verdict 仍为 **Pass with conditions**；CHS-A-02 关闭不把该 Verdict 升为 Accept，也不使 Assignment 可 Close。
