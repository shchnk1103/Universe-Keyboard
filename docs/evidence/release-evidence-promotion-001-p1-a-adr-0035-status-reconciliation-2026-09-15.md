# P1-A / ADR 0035 状态对账记录 — 2026-09-15

> 记录类型：Executor-recorded status reconciliation
> 本记录不新增 Product、Architecture、Quality、Release 或 Git 授权，也不改变任何独立 Assignment 的生命周期。

## 对账目标

本记录核对两条容易被混淆、但实际具有不同候选身份和授权边界的工作线：

1. RELEASE-EVIDENCE-PROMOTION-001：为 Universe Keyboard 实现日常 Beta 增量验证、外部候选证据晋级和 Main App 内容无关证据页面；其 bounded candidate 已形成独立分支、hosted provenance 和 ADR 0035 采纳记录。
2. KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-A：UK-005 下的 KOS release-evidence adapter、fixture 和 delta-contract package；其 P1-B diagnostics slice 被原 Assignment 明确延后。

第一性原则是：只有在 candidate、package digest、Assignment、Authorization、owner 和 review scope 全部相同或有明确的 successor 关系时，状态才可以复用。本次两条工作线不满足该条件。

## 当前状态矩阵

| 对象 | 当前可确认状态 | 状态来源与边界 |
|---|---|---|
| ADR 0035 | Accepted — Conditional Accept package，2026-09-15 | Human Product Owner 通过 PD-ADR-0035-ACCEPT 正式采纳；仅约束 RELEASE-EVIDENCE-PROMOTION-001 的 bounded release-evidence workflow |
| RELEASE-EVIDENCE-PROMOTION-001 | Reviewed；REP-Q-01 对本 Assignment 为 Closed | candidate ad39f443b7f77d96c28359bd652356a89bb173de，branch codex/rep-q-01-close，hosted run 34865917284；不代表 merge、Product Gate、Release Pass 或 TestFlight |
| UK-005 P1-A package | r4 Architecture/Quality review 对该 exact package 为 Pass；Assignment 自身仍保留 REP-Q-01、hosted provenance 和 P1-B residual | package digest 45afdbf879c6b0054790342861254abbc6d9cde846f61b43a160bd22064d0382；只代表六文件 adapter/fixture package 的 bounded review |
| UK-005 P1-B diagnostics | Not authorized / deferred | UK-005 P1 Assignment 明确排除 Main-App Diagnostics UI/storage、retention/clear、migration/backfill、export 和 background sync；如需实施必须有新的 Assignment/Authorization/ADR-0027 review |

## 对账结论

### 1. ADR 0035 已采纳，但不是 UK-005 P1-A 的采纳或关闭

ADR 0035 的采纳记录、RELEASE-EVIDENCE-PROMOTION-001 的 Reviewed 状态和该 Assignment 的 REP-Q-01 Closed，均绑定到候选
ad39f443b7f77d96c28359bd652356a89bb173de 及其真实 hosted run。

UK-005 P1-A 的 exact package digest 为
45afdbf879c6b0054790342861254abbc6d9cde846f61b43a160bd22064d0382，属于另一条实现/审查边界。当前 ADR 采纳不能关闭或重写 UK-005 P1-A 的 Assignment、Authorization、REP-Q-01 或 hosted-provenance residual。

### 2. REP-Q-01 不能跨 Assignment 转移

本分支的 receipt 只证明：

- RELEASE-EVIDENCE-PROMOTION-001 的 final candidate SHA；
- 该候选的实际 base/head；
- hosted CI headSha 与 candidate source 相同；
- 本 Assignment 的 same-head provenance。

它不证明 UK-005 P1-A package 的最终 implementation identity、base/head 或 hosted relation。UK-005 如需关闭自己的 REP-Q-01，仍需由其 owner 针对其 exact package 形成独立 receipt。

### 3. Main-App UI/storage 已在另一条 bounded Assignment 中实现，但不自动关闭 UK-005 P1-B

RELEASE-EVIDENCE-PROMOTION-001 已授权并实现 Main App 内容无关的发布证据页面和有界存储。这可以作为 UK-005 P1-B scope reconciliation 的输入，但不能直接把 UK-005 P1-B 标记为 Completed 或 Closed，因为：

- 两条 Assignment 的 scope、candidate 和 review package 不同；
- UK-005 P1-B 还列有 migration/backfill、background sync 等未被当前 bounded Assignment 授权的范围；
- 是否把这些剩余项保留为需求、标记 Deferred，或改为 Not applicable，属于 Human Product Owner 的 Product Decision。

当前不创建重复的 P1-B 实现 Assignment。只有在 Product Lead 明确了仍需实现的剩余范围后，才建立新的 P1-B Assignment 和 matching Authorization。

## 冲突与证据边界

主工作树中有一份未提交的 remediation review，针对 package digest
35a055a4341dbd77bb2aec74fbae7699449d23c700d7c8c226b0e693c385421d 给出 Needs work，文件时间为 21:57。它与 UK-005 r4 review 的 45af... package digest 不同，也不在本分支的提交历史中。

时间线已经提供了足够的 successor 依据：UK-005 r4 Architecture review 和 Quality review 分别在 23:28–23:29 生成，且 UK-005 P1 Assignment history 在 23:34 记录该 45af... package 的 fresh independent review Pass。因此，35a... review 保留为较早的历史审查，45af... / r4 是当前 P1-A exact-package review；35a... 的 P1/P2 findings 不再作为当前 P1-A lifecycle 的未决结论。

这项 supersession 只解决“哪一份 P1-A package review 是当前的”这一状态对账问题，不会关闭 UK-005 Assignment 的 REP-Q-01、hosted provenance 或 P1-B residual。若 45af... package 后续发生字节、source、profile 或 contract 变化，必须重新计算 digest 并重新 review。

## 生命周期处置

| 生命周期事实 | 本次处置 |
|---|---|
| ADR 0035 | 保持 Accepted — Conditional Accept package |
| RELEASE-EVIDENCE-PROMOTION-001 | 保持 Reviewed；不因本记录进入 Closed |
| UK-005 P1-A | 不修改其 Assignment；继续按该 Assignment 的 residual ledger 管理 |
| UK-005 P1-B | 保持 Not authorized / deferred；不创建重复实现任务 |
| Main Worktree 未提交 remediation review | 作为较早的历史 evidence 保留；由 UK-005 的 45af... / r4 exact-package review supersede，不作为当前 lifecycle authority |

## 下一合法决策

1. 若要把 ADR 0035 进入 main，需要单独的 merge / publication authorization；本记录不授予该权限。
2. UK-005 继续按 45af... / r4 review 管理 P1-A；其 REP-Q-01 与 hosted provenance 仍由相应 owner 独立闭合。
3. 若 Product Lead 仍需要 UK-005 P1-B，先明确剩余范围（UI/storage reuse、迁移、background sync 或其他），再建立新的 bounded Assignment、Authorization 和 ADR-0027 architecture review。
4. 在上述决定之前，不把任一 local fixture、review Pass 或 App 内记录解释为 Product Gate、Quality Pass、Release Pass、current-proof 或外部发布依据。
