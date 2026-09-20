# Quality Review: TYPO-CORRECTION-002 recall remediation core contract

## Verdict

**Pass with conditions**，仅限本 exact working-tree snapshot 的纯 `Packages/KeyboardCore` core-contract remediation。

本 verdict 独立于本轮 Architecture review；它只确认当前 remediation evidence、代码/测试结构和边界记录足以进入下一步有界 Product 判断。它不等于生产接线、runtime scheduler、RIME、设备、性能或任何 Product/Quality/Release Gate 通过。

## Exact snapshot and manifest

| 项目 | 值 |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001` |
| Branch | `codex/typo-correction-002-recall-preflight-001` |
| HEAD | `d0df9a6342d8209b5aa7f9826541d0b430b9da04` |
| HEAD tree | `27ae44bec1b157e391ef1e0b859db3a068e21ba8` |
| Remediation Quality manifest SHA-256 | `025f66a7440ea6a7045b2e164582bf9f1daa505175b9118d3a0b54eed5209c8f` |
| Manifest rule | 授权列出的 9 个 artifact 按顺序生成 `sha256sum` 行，以换行连接后再计算 SHA-256 |
| Review role | Independent Quality reviewer；不是实现者，也不是本轮 Architecture reviewer |

当前 artifact 是未提交 working-tree 内容；`HEAD`/tree 作为 remediation 前 source identity 保留。9 个授权 artifact 的逐文件 SHA-256 组合可复现为上述 manifest，未把本 review 文档纳入该 manifest。

## Independent scope result

静态复核确认：

1. preflight 默认入口为 `.substitutionOnly`；生产 `ContextualTypoCorrectionHypothesisEngine` 仍为 `.all` 与 `productionV2` 的 `12/8`，没有发现新的生产 controller、Keyboard Extension 或 RIME 接线。
2. `TypoCorrectionRecallPreflightGroupID` 是不含原始输入的 opaque `UInt64` token；ledger 以 `Set` 去重，重复 token 不增加 `nResolvedGroups`，candidate response 计数仍独立。
3. `nGenerated`、`nQueryAttempts`、`nResolvedGroups`、`nCandidatesReturned` 分开维护；focused tests 对 batch cap、resolved-group cap、composition revision fence 和独立 session epoch fence 有对应案例。
4. 双编辑仍为 display-only：`isDisplayEligible == true`、`isPromotionEligible == false`。这些是 Core contract 观察，不是 RIME 候选或用户可见行为证明。

## Findings by severity

### P1 — runtime corrected-input 到 group identity 的映射仍未定义

当前 Core ledger 能消费稳定 opaque token 并去重，但 token 的生成、corrected-input canonicalization、接受语义和 runtime provenance 仍由未来 scheduler 负责。故只能关闭“ledger 层 token dedup”这一 bounded residual，不能关闭“runtime group identity mapping”。

Disposition：**保留 Architecture P1 residual**；runtime scheduler 接线前必须另立 Authorization，并重新进行 Architecture/Quality review。

### P2 — focused contract coverage 不等于异步/runtime coverage

本次代码和 tests 已分别覆盖 batch cap、resolved-group cap 与 session epoch mismatch，较此前 snapshot 有实质补强；但它们仍是同步纯 Core ledger tests，不是异步 scheduler、真实 RIME 或端到端 publish coverage。

Disposition：**保留为解释边界**；不得把 `14/14` 或 `1143/1143` 扩大为完整 async/runtime contract 或产品质量结论。

### P2 — reviewer 独立 test verification 被环境权限阻断

按授权仅尝试一次：

```text
CLANG_MODULE_CACHE_PATH=/private/tmp/universe-keyboard-recall-remediation-clang-cache
SWIFT_MODULECACHE_PATH=/private/tmp/universe-keyboard-recall-remediation-swift-cache
swift test --package-path Packages/KeyboardCore
```

两个 evidence 指定的临时 cache 目录当前可写；但命令在 manifest 编译前由 sandbox 阻断，返回 `sandbox-exec: sandbox_apply: Operation not permitted`。因此本 reviewer 没有得到独立测试执行结果，也没有把 executor 的结果升级为 reviewer green result。

Disposition：**记录为 reviewer verification limitation，不判为源代码失败**。如后续需要更强测试结论，应在可执行的等价环境重新绑定新鲜输出；本 review 不重跑、不申请额外构建权限。

## Test and evidence reconciliation

Remediation evidence 记录以下 executor results，且与当前 artifact 的静态结构一致：

| Evidence | Quality disposition |
|---|---|
| Focused `TypoCorrectionRecallPreflightTests` `14/14` | 接受为 executor-recorded；未升级为本 reviewer 独立通过 |
| Full `swift test --package-path Packages/KeyboardCore` `1143/1143` | 接受为 executor-recorded；未升级为本 reviewer 独立通过 |
| `swift-format lint --strict` on three changed Swift files | 接受 evidence 记录；本次未重新执行 |
| writable Swift/Clang cache provenance | 路径与当前目录权限可核对；不消除 manifest 编译阶段的 sandbox 阻断 |
| `git diff --check` | 接受为 evidence 记录；本次未重新执行 |

`14/14` 与测试文件中 14 个 test methods 相符；`1143/1138` 的增量也与本次新增 focused cases 相符。但这只是 evidence、代码结构和测试计数之间的一致性核对，不是独立执行证明。

## Residual disposition

| Residual / boundary | 本次结论 |
|---|---|
| preflight default fail-closed | Core contract 已处置；生产/publication 前仍需绑定变化后的 exact snapshot 复核 |
| opaque group identity / dedup | Core ledger token dedup 已处置；runtime corrected-input mapping 仍开放，保留 P1 |
| independent batch / resolved-group / epoch cases | focused pure-Core coverage 已补；不关闭 async/runtime coverage residual |
| contextual 7/8 | `UNKNOWN`，本 review 不推断、不关闭 |
| RIME / device / performance | 未授权、未执行、未关闭 |
| QA-001 / INT-003 | 明确排除，未执行、未关闭 |
| Product / Quality / Release Gate | 不作结论、不授予通过 |
| merge / PR / commit / push / TestFlight / Release | 明确排除，未执行 |

## Explicit non-claims

本 review 不声称：

- 真实 RIME schema、sidecar query、候选内容/排序/可见位置或 runtime scheduler 交付；
- 设备或 Simulator 行为、端到端延迟、180 ms、paired performance、性能回归或产品成功率；
- `contextual 7/8` 已被证明；
- `14/14`、`1143/1143`、strict lint 或 `git diff --check` 是本 reviewer 本次独立执行的通过结果；
- QA-001、INT-003、Product Gate、Quality Gate、Release Gate、PR、merge、TestFlight、Release 或 parent/child Close。

## Product bounded-decision handoff

**建议交 Product，但仅作 bounded decision。** Product 可以决定是否另立、另授权下一步纯 Core 或生产前置工作；任何触及 runtime scheduler、production controller、RIME、设备、性能、publication 或更宽 Quality contract 的动作，都必须建立新的 Assignment/Authorization，并对变化后的 exact snapshot 重新进行独立 Architecture/Quality review。

本 review 只新增本文件；未修改 Swift、测试、Assignment、Authorization、Architecture review 或其他生产文件，未创建 Run ID，未执行设备/Simulator/RIME，未 commit/push/PR/merge。
