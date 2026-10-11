# Evidence: TYPO-CORRECTION-002 recall remediation implementation preflight

> **Evidence ID:** `TC2-RECALL-PREFLIGHT-20260920-01`
>
> **Status:** `Executor-recorded — pure KeyboardCore preflight complete; independent Architecture/Quality review pending`
>
> **Collected:** `2026-09-20 Asia/Shanghai`
>
> **Assignment:** [`TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-001`](../assignments/typo-correction-002-recall-remediation-implementation-preflight-001.md)
>
> **Authorization:** [`AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-IMPLEMENTATION-PREFLIGHT-001.md)

本回执只记录纯 `Packages/KeyboardCore` 的实现预检、搜索 frontier 和契约测试。
没有新的 Simulator/真机 Run，因此本回执没有创建或替代 Run ID；没有接入 Keyboard
Extension、生产 controller、RIME 或 sidecar query，也没有执行 commit、push、PR、merge
或 Release。

## Provenance

| 项目 | 值 |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001` |
| Branch | `codex/typo-correction-002-recall-preflight-001` |
| Source HEAD before preflight | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` |
| Source tree before preflight | `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |
| `Packages/KeyboardCore/Package.swift` identity recorded by Authorization | `1a06a522f12089f3dbb2ad774d13fe9f56193d04` (Git blob ID；已消费 Authorization 的字段曾标为 SHA-256) |
| `Packages/KeyboardCore/Package.swift` actual SHA-256 | `9ebf33313b560b83634a074dd675211aee9cec13b1d879e9cd4f35fbb94aa764` |
| Source implementation freeze | `fb27b24ff85c48302e85309e834dbbe9a777871e` |
| Authorization consumption | `2026-09-20T09:43:55+08:00`, before first code change |

当前代码仍是未提交 working-tree diff，因此上述 HEAD/tree 是变更前的精确来源身份；Authorization
中的 `1a06…` 按 Git blob identity 保留，不能当作 SHA-256 使用。变更文件的
工作树 SHA-256 另列如下，供后续 publication 前重核：

| Changed source/test file | SHA-256 |
|---|---|
| `Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift` | `b54478969c127b17450a2504a3c3ffa5ed43a8ff1614aa18a826873ede1a21a3` |
| `Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift` | `9a4eae729c28cc30ecc819de270e082b2a2f2d2c75fd06e67fce8d2288f7dab9` |
| `Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift` | `4f71cd924d4463c674fafd0320a4b86ed80d5d49c08a4ad781d0afe88df28d7f` |

## 实现边界

本切片做了三件事：

1. 给纯字符串假设生成器增加显式 `TypoCorrectionEditPolicy`。生产默认仍是 `.all`；预检首个编辑切片使用 `.substitutionOnly`，不会改变生产默认预算或路径。
2. 增加不依赖 RIME 的 `TypoCorrectionRecallPreflightLedger`，把 `N_generated`、`N_query_attempts`、`N_resolved_groups` 和 `N_candidates_returned` 分开计数，并验证 batch 上限、query cap、candidate limit、取消、revision/epoch stale-result discard 与 publish fence。
3. 增加 focused tests，验证双编辑结果仅 `displayEligible`、不具备 `promotionEligible`；没有把结果接入 host text、marked text 或提交路径。

预检 execution budget 为：`maximumBatchSize=8`、`candidateLimit=3`、
`maximumResolvedGroups=4`、`maxQueryAttempts=8`。这里的 `8` 是一个单批次纯 Core
契约上限，不是生产调度值、不是 180 ms 性能目标，也不是已经执行的 RIME query 数。

生产基线仍为 `maximumFirstLayerStates=12` / `maximumHypotheses=8`；预检搜索预算为
`60` / `64`，但仍只生成内存中的字符串假设。

## Frontier observations

测试 case：
`wimenjintianquhongyuan` → `womenjintianqugongyuan`。

| `maximumFirstLayerStates` | canonical target rank |
|---:|---:|
| 12 | absent |
| 16 | absent |
| 24 | 54 |
| 32 | 55 |
| 40 | 55 |
| 48 | 55 |
| 60 | 55 |

因此，在这个纯 substitution-only、双编辑、内存生成的 benchmark 中，首个观察到目标的
最小扩展档位是 `24`，在 `60/64` 预检档位的观测 rank 为 `55`；生产 `12/8` 档位中
目标仍不存在。该结果只是召回 frontier 事实，不能外推为真实 RIME 候选质量、用户可见候选
位置、端到端延迟或产品成功率。

## Verification

| Check | Result | Boundary |
|---|---|---|
| `xcrun swift-format lint --strict --configuration .swift-format` on all three changed Swift files | PASS | formatting only |
| `git diff --check` | PASS | current worktree |
| KOS structural validator | PASS — structural checks completed | Emits repository historical warnings, including the already-consumed Authorization's legacy envelope-field warning; not a Product/Architecture/Quality/Release approval |
| Focused `TypoCorrectionRecallPreflightTests` | PASS — `9/9` | pure KeyboardCore contract/frontier tests |
| `swift test --package-path Packages/KeyboardCore` before change | PASS — `1129/1129` | recorded at Authorization consumption |
| `swift test --package-path Packages/KeyboardCore` after change | PASS — `1138/1138` | full package; no failures |

完整测试仍报告仓库既有的无关 warning：
`Packages/KeyboardCore/Tests/KeyboardCoreTests/T9PinyinPathTests.swift:1429:37`
的 optional interpolation。它不属于本切片改动，也没有被改写。

## Residuals and non-claims

- `contextual 7/8` 仍是 `UNKNOWN`；本回执只覆盖 substitution-only 的代表 benchmark，不覆盖所有真实输入。
- 没有证明 RIME schema、真实 sidecar query、候选排序或设备行为；没有使用 FakeCandidateProvider、旧 Ice 目录或合成 RIME fixture。
- 没有测量或声称 180 ms、paired performance、QA-001 或 INT-003。
- 没有修改 UIKit、Keyboard Extension、RimeBridge、schema/vendor、App Group、host text 或隐私边界。
- 不是 Product/Quality/Release Gate，不是 parent/child Close，也不授权 production wiring。
- 独立 Architecture 与 Quality reviewer 尚未对本精确 working-tree diff 作出结论；如要进入生产接线，必须先完成独立复核并另取得新的 implementation/publication Authorization。

## Reproduction commands

```bash
xcrun swift-format lint --strict --configuration .swift-format \
  Packages/KeyboardCore/Sources/KeyboardCore/ContextualTypoCorrection.swift \
  Packages/KeyboardCore/Sources/KeyboardCore/TypoCorrectionRecallPreflight.swift \
  Packages/KeyboardCore/Tests/KeyboardCoreTests/TypoCorrectionRecallPreflightTests.swift

swift test --package-path Packages/KeyboardCore
git diff --check
```
