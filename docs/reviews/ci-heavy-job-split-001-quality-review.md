# CI-HEAVY-JOB-SPLIT-001 — Independent Quality Review

## Review identity

| Field | Value |
|---|---|
| Reviewer | `ci_split_quality_review`（独立 Quality, Performance & Release reviewer） |
| Date / timezone | `2026-09-15 Asia/Shanghai` |
| Frozen subject | 未提交工作树；`HEAD` = `83f840b` on local `main`。实现尚未 commit / push |
| Scope | 仅 [`CI-HEAVY-JOB-SPLIT-001`](../assignments/ci-heavy-job-split-001.md)。工作树中的 `RELEASE-EVIDENCE-PROMOTION-001`（`ReleaseEvidenceStore.swift`、`scripts/release/` 等）不在范围 |
| Independence | 只读核对工作树与文档；独立重跑本地脚本测试；未改实现、未 commit / push / merge；未把 Executor 本地结果升级为 hosted 绿 |
| Hosted evidence | **无。** 当前授权切片不含 publication；不得假装 hosted 已绿 |

本结论 **不是** Product Gate、merge、Release，也 **不是** hosted CI 绿。

## Verdict

**Pass with conditions。** 本地实施切片与 Assignment 合同一致；分类器语义未被削弱；Gate 矩阵脚本与单测覆盖要求组合且经本 reviewer 重跑为绿。Assignment Close 与任何 merge 声称仍被缺失的 hosted fixture 阻塞。

| ID | Severity | Disposition | Finding |
|---|---|---|---|
| CHS-Q-01 | P1 | `fix` | 无 hosted `full` 证据：五条 heavy 均为 `success` 且 `final-quality-gate` `success`。Exit Criteria 未勾。待 commit/push 授权后取证；当前不得声称 hosted 绿。 |
| CHS-Q-02 | P1 | `fix` | 无 hosted `docs_only` 证据：五条 heavy 均为恰好 `skipped` 且 Gate `success`。不得为取证而合并 docs-only fixture PR，除非另授权。TD-016 先例是独立 fixture PR 关闭不合并；此处仍是本 Assignment 的 Exit `fix`，不是 `tech_debt:TD-016`。 |
| CHS-Q-03 | P2 | `fix` | 工作树混有无关 `RELEASE-EVIDENCE-PROMOTION-001`；Assignment Entry「隔离功能分支、不把 workflow 改动塞进无关 PR」未勾。后续 commit/push 必须切开本切片文件。不因此否定当前 workflow/脚本合同。 |
| CHS-Q-04 | P3 | `accept` | Gate 单测按失败模式抽样（首/中/末 job 与缺参），未穷举 5×全部 GitHub result。`docs_only` 未单列 `cancelled`。已覆盖 Assignment 要求的成功/失败组合，不阻塞本切片。 |
| CHS-Q-05 | P2 | `tech_debt:TD-016` | 本切片未关闭 A-P2-02：classifier / workflow / Gate 仍来自 PR head，hosted 绿不是独立 trust root，也不是 required check。禁止借本 Assignment 改 branch protection。 |

## Evidence disposition

- Executor 证据 [`ci-heavy-job-split-001-local-gate-2026-09-15.md`](../evidence/ci-heavy-job-split-001-local-gate-2026-09-15.md) Grade 写明 **Executor-recorded**、Not hosted、Not Quality Pass、Not merge。未误标 Quality/hosted。KOS 2.1 M-04 遵守。
- 本 reviewer 独立重跑同一组脚本，下列行标 **Quality-reverified**。不得把该 Grade 延伸到 xcodebuild 或 hosted。
- 物理设备、TestFlight、签名、Release、required-check 迁移均不在本 Assignment。
- Close 被 CHS-Q-01 / CHS-Q-02 阻塞，直到 hosted 日志可核对。本 Pass with conditions 只记录本地实施质量，不授权 Close。

### Quality-reverified local scripts (`2026-09-15 Asia/Shanghai`)

Environment: local reviewer workstation；cwd = 仓库根；`HEAD` `83f840b`；工作树脏（含范围外文件）。未跑 xcodebuild / `swift test`（Assignment 当前切片不要求）。

```bash
python3 -m unittest discover -s scripts/ci/tests -p 'test_*.py' -v
bash scripts/ci/tests/test_verify_final_gate.sh
bash scripts/ci/tests/test_kos_trigger_paths.sh
```

| Check | Result | Grade |
|---|---|---|
| Python classifier + markdown-link tests | 12 tests, OK（`test_classify_changes.py` 相对 `HEAD` **无 diff**） | Quality-reverified |
| `test_verify_final_gate.sh` | `PASS final gate result matrix` | Quality-reverified |
| `test_kos_trigger_paths.sh` | `PASS KOS governance trigger paths` | Quality-reverified |
| Hosted `full` / `docs_only` workflow | 未跑；无 run ID | 缺失（CHS-Q-01 / CHS-Q-02） |
| KeyboardCore / RimeBridge / App+Keyboard / Release xcodebuild | 未跑 | 本切片不要求；merge 前仍须按 AGENTS 完整门禁 |

## Findings

### Gate 矩阵与测试覆盖

`scripts/ci/verify_final_gate.sh` 现接收 8 参：`classify`、`lightweight`、`requires_full`、五条 heavy。`classify`/`lightweight` 必须 `success`；`requires_full` 仅接受 `true`→全部 heavy `success`、`false`→全部 heavy 恰好 `skipped`；其它值（含空）fail-closed。任一 heavy 与期望不符即失败并点名 job。

`scripts/ci/tests/test_verify_final_gate.sh` 实际覆盖：

| 要求 | 覆盖 |
|---|---|
| `full` 全 success | 有 |
| `docs_only` 全 skipped | 有 |
| 任一 heavy skip / fail / cancel / missing（`full`） | 有（分别打在 format / KeyboardCore / RimeBridge / 缺 release / release skip） |
| classify / lightweight 失败 | 有 |
| 空 `requires_full` | 有 |
| 旧四参数调用 `success success success true` | 有，必须失败 |
| `docs_only` 下某一 heavy success / failure / missing | 有 |

`scripts/ci/run_lightweight_checks.sh` 仍调用该矩阵脚本，hosted 轻量 job 会执行新合同。测试被扩展而非削弱。CHS-Q-04 仅接受未穷举组合。

### Workflow job 图

`.github/workflows/swift6-quality.yml`：

- 已删除单一 `build-and-test` 与 Debug `test` 之后的 Debug `build` 步骤。
- 保留 App scheme Debug **`test`**（`test-app-keyboard`）与 Release **`build`**（`build-release`）。
- 五条 heavy 的 GitHub `name` 与 Assignment / Gate 脚本一致：`format-swift`、`test-keyboardcore`、`test-rimebridge`、`test-app-keyboard`、`build-release`。
- 五条均 `if: needs.classify_change.outputs.requires_full == 'true'`，故 `docs_only`（及 classify 失败导致输出为空）时 GitHub 结果为 `skipped`；`final-quality-gate` 以 `if: always()` 聚合，不能用 workflow 级 skip 冒充绿。
- `classify-change`、`lightweight-checks`、`final-quality-gate` 名称保留。`concurrency` + `cancel-in-progress` 保留。无 `paths-ignore`。无按 UI/Rime/KeyboardCore 路径跳过。
- RIME vendor：`test-rimebridge` / `test-app-keyboard` / `build-release` 仍 `fetch`；`format-swift` / `test-keyboardcore` 不拉，符合 Assignment。
- xcodebuild 参数（scheme、Debug/Release、模拟器 `iPhone 17 Pro`、Swift 6、warnings-as-errors）相对旧 heavy 步骤未削弱。

ADR 0031 风险已写明：GitHub job-result 语义可能与本地脚本不同，**第一次 hosted run 才是该语义的证据**。本地绿不能替代 CHS-Q-01/02。

### 分类器

`scripts/ci/classify_changes.py` 与 `scripts/ci/tests/test_classify_changes.py` 相对 `HEAD` 无 diff。仍仅 `docs_only` / `full`；allowlist 仍为根 `*.md`、`docs/**`、`.kos/**`；空 diff / 未知路径 / 源→docs rename fail-closed。分类语义未被本切片削弱。

### 文档与本地门禁对齐

- [`docs/CI_CHANGE_CLASSIFICATION.md`](../CI_CHANGE_CLASSIFICATION.md) job 图改为五条并行 heavy；Rollback 写明回到「条件 `build-and-test` + 额外 Debug `build`」，不是无分类无条件 heavy，也不是 `paths-ignore`。
- ADR 0031 Status 保持 Accepted，记合同修订而非新 ADR。
- [`AGENTS.md`](../../AGENTS.md) 本地门禁：删除 Debug `test` 后再 Debug `build`；本地仍串行 format + KeyboardCore + RimeBridge test + App/Keyboard test + Release build。串行可接受；语义与 hosted 五条 heavy 对齐。
- [`docs/RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md) 自动化验证已去掉 Debug `build`，仍保留 Debug `test` 与 Release `build`。该文件其它 hunk 属于范围外 Assignment，本审查不评价。
- TD-016 仍开放 A-P2-02；Related 指向本 Assignment 且写明不关闭该项（CHS-Q-05）。

### 本地证据 Grade

Executor 记录未把脚本 PASS 写成 Quality Pass 或 hosted 绿。本审查只把 **本 reviewer 重跑** 的三组命令标为 Quality-reverified。

## Skipped With Reason

| Item | Reason |
|---|---|
| Hosted `full` fixture | 未授权 commit/push/publication；无 Actions run |
| Hosted `docs_only` fixture | 同上；且禁止为取证合并 fixture PR |
| KeyboardCore / RimeBridge / App+Keyboard `xcodebuild` / Release `build` | Assignment 当前切片不要求；本 reviewer 不把未跑写成通过 |
| actionlint / workflow 在 GitHub 上的表达式求值 | 无 hosted；列入 CHS-Q-01/02 |
| branch protection / required checks | 明确 Non-goal |
| `RELEASE-EVIDENCE-PROMOTION-001` 实现与测试 | 范围外 |

## Handoff

- 交回 Human Product Owner：是否授权隔离功能分支上的 commit/push（CHS-Q-03），以及随后的 hosted `full` + 不合并的 `docs_only` fixture（CHS-Q-01/02）。
- 独立 Architecture 结论需另记录；本文件不代替 Architecture Gate。
- 残差均已给恰好一个 `fix` / `accept` / `tech_debt:<ID>`（KOS 2.1 M-03）。含 `fix` 的项在取得证据指针前 **Assignment 不得 Close**。
- 下一步 Quality 复核应只读 hosted jobs API / 公开 run：核对五条 `name`、`full` 全 success、`docs_only` 全 skipped、Gate success，以及 classifier JSON。在此之前不得把本 Verdict 升级为 hosted 绿或 merge-ready。

## Revalidation — hosted full (CHS-Q-01 / CHS-Q-03)

| Field | Value |
|---|---|
| Reviewer | `ci_split_quality_review` |
| Date / timezone | `2026-09-15 Asia/Shanghai` |
| Frozen first Verdict | **Pass with conditions**（上表首次打分不改写） |
| Independence | 独立 `gh` jobs API + classify 日志 + `git diff --name-only origin/main...HEAD`。未把 Human「全绿」或 Executor 证据文件当成 Quality-reverified。未改 workflow / 脚本 / 其它残差打分 |
| Hosted `docs_only` | 仍无 fixture PR / skip 矩阵 run。**CHS-Q-02 保持 `fix`** |

首次 Verdict 保持 **Pass with conditions**。本复核不授权 merge、Product Gate、Release 或 required-check 迁移。Assignment Close 仍被 CHS-Q-02 阻塞。

### Residual disposition this round

| ID | Previous | Current | Evidence |
|---|---|---|---|
| CHS-Q-01 | `fix` | **`closed`** | 见下：run [`34923523955`](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/34923523955) 为 hosted `full`，五条 heavy 与 Gate 均为 `success`，无 heavy `skipped`。Grade: **Quality-reverified** |
| CHS-Q-02 | `fix` | **`fix`（仍开放）** | 未见 docs_only hosted skip fixture。不得声称 docs_only 矩阵已绿 |
| CHS-Q-03 | `fix` | **`closed`** | PR head `39a25bd` 在隔离分支 `feature/ci-heavy-job-split-001`；`origin/main...HEAD` 恰好 20 个本切片路径，无 `ReleaseEvidenceStore.swift` / `scripts/release/`。Grade: **Quality-reverified** |
| CHS-Q-04 | `accept` | `accept`（未重开） | 本轮不复核 |
| CHS-Q-05 | `tech_debt:TD-016` | `tech_debt:TD-016`（未重开） | hosted 绿仍不是独立 trust root |

### Quality-reverified hosted full

独立命令：

```bash
gh pr view 130 --repo shchnk1103/Universe-Keyboard --json number,isDraft,headRefName,headRefOid,baseRefOid,state,url
gh run view 34923523955 --repo shchnk1103/Universe-Keyboard --json databaseId,conclusion,status,event,headSha,headBranch,url,workflowName
gh api repos/shchnk1103/Universe-Keyboard/actions/runs/34923523955/jobs --jq '[.jobs[] | {name, conclusion}]'
gh run view 34923523955 --repo shchnk1103/Universe-Keyboard --job 104236569682 --log
git -C /tmp/uk-ci-heavy-job-split-001 diff --name-only origin/main...HEAD
```

| Fact | Independently observed |
|---|---|
| PR | [#130](https://github.com/shchnk1103/Universe-Keyboard/pull/130) `OPEN` **draft** |
| Branch | `feature/ci-heavy-job-split-001` |
| PR head | `39a25bd691dcf8ff18819741b29ea7a439849d09` |
| Base | `1a405143229eff151f61d1c7fc789bc4368802d7` |
| Run | `34923523955`；workflow `Swift 6 Quality`；event `pull_request`；`headSha` = PR head；`conclusion=success`；attempt 1 |
| Classifier JSON（classify-change 日志，非 Executor 摘录） | `{"classification": "full", "requires_full": "true", "reason": "sensitive_or_unknown_path", "changed_count": "20", "base_sha": "1a405143229eff151f61d1c7fc789bc4368802d7", "head_sha": "9c64b5ae4058b55c19fabbfa1a7f1584ae01a62e", "full_required_paths": [".github/workflows/swift6-quality.yml", "scripts/ci/tests/test_verify_final_gate.sh", "scripts/ci/verify_final_gate.sh"]}` |
| Swift 6 jobs（jobs API `total_count=8`） | `classify-change` / `lightweight-checks` / `format-swift` / `test-keyboardcore` / `test-rimebridge` / `test-app-keyboard` / `build-release` / `final-quality-gate` 全部 `success` |
| Heavy skipped | **无** |

PR-head 与 merge-ref `GITHUB_SHA`（`9c64b5a…`）身份不同，属 pull_request 工作流常态；分类按 merge-ref 对 base 的 20 路径 fail-closed 为 `full`，且 `full_required_paths` 含 workflow 与 Gate 脚本，符合 Assignment。

Executor 稿 [`ci-heavy-job-split-001-hosted-full-2026-09-15.md`](../evidence/ci-heavy-job-split-001-hosted-full-2026-09-15.md) 与上述独立核对一致，但其 Grade 仍为 Executor-recorded；本段才是 Quality-reverified。

### Quality-reverified isolation (CHS-Q-03)

`origin/main...HEAD` 20 个路径均为本切片（workflow、Gate 脚本、ADR 0031 合同修订、Assignment/AUTH/PD、CI 文档、本审查与 Architecture 审查、CHANGELOG/导航）。无 `Universe Keyboard/Services/ReleaseEvidenceStore.swift`、`scripts/release/` 或其它 `RELEASE-EVIDENCE-PROMOTION-001` 源。`docs/RELEASE_CHECKLIST.md` 相对 `origin/main` 仅 CI 门禁文案（去掉 Debug `build` / `build-and-test` 跳过语）。隔离提交条件满足。

### Still open

- **CHS-Q-02 `fix`：** Assignment Close 仍须 hosted `docs_only`（五条 heavy 恰好 `skipped` 且 Gate `success`）。不得为取证而合并 fixture PR，除非另授权。
- 本 Pass with conditions **不**因 CHS-Q-01/03 closed 变成无条件 Pass、merge-ready 或 Product Gate。

