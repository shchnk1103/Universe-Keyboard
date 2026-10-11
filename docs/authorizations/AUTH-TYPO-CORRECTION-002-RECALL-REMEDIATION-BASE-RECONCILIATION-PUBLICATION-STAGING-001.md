# AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-BASE-RECONCILIATION-PUBLICATION-STAGING-001

- 状态：consumed
- 建立时间：2026-09-20 Asia/Shanghai
- 消费时间：2026-09-20 Asia/Shanghai
- 来源决定：`PD-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-BOUNDED-2026-09-20`
- 前置对账：`TC2-RECALL-PUBLICATION-SCOPE-20260920-001`
- 当前旧工作树：`/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001`
- 当前旧 HEAD：`d0df9a6342d8209b5aa7f9826541d0b430b9da04`
- 目标基线：`origin/main=162b09fd58ba60538a944026b1902efa405c75aa`

## 目的

把已完成 provenance/quality preflight 的 recall remediation 从旧的混合工作树迁移到当前 `origin/main` 基线的干净 staging worktree，重新确认最终文件范围、source manifest、HEAD/tree 和文件哈希。此 Authorization 只处理 staging 与 provenance，不等于 publication、commit、push、PR 或 merge 授权。

## 允许动作

1. 从精确的 `origin/main=162b09f` 创建新的隔离 worktree 和 `codex/` 分支；
2. 仅移植 scope reconciliation 中列出的 recall 源码/测试候选及 recall 治理文档命名空间；
3. 对 `docs/ACTIVE_WORK.md`、`docs/KNOWLEDGE_INDEX.md`、parent Assignment 等共享镜像做最小差异审计，必要时只写入与 recall staging 直接相关的镜像更新；
4. 重新计算最终文件清单、每个 source/package 文件哈希、canonical manifest、HEAD/tree 和 Git ancestry；
5. 执行 `git diff --check`、KOS governance validators 和 final-gate checks；
6. 若移植后的 Swift/source/test bytes 或目标基线使既有门禁不能复用，建立新的 bounded Run ID，并在不发布的前提下执行适用的格式/测试/build 质量门。

## 明确禁止

- 不触碰旧工作树中的无关变更，不 reset、restore、clean、stash 或删除任何残留；
- 不把 sidecar、AX/testability、INT-003、QA-001、性能或历史 parent 文档作为 recall staging 的隐式范围；
- 不修改 recall 生产行为以解决 staging 冲突；任何代码修复必须另立 Assignment/Authorization；
- 不 stage、commit、push、创建/更新 PR、merge、TestFlight、Release；
- 不关闭 parent/child Assignment、Product Gate、Quality Gate 或 Release Gate；
- 不把本阶段 staging 或本地门禁结果解释为真实 RIME、设备、INT-003、QA-001、paired performance 或 180 ms 结论。

## 退出条件

- 新 worktree 明确从 `origin/main=162b09f` 开始；
- recall allowlist 与排除项逐项记录；
- 最终 source manifest 与 HEAD/tree 可复算；
- 任何 source drift、冲突、失败或不可归属文件都保留为 residual，不被静默吸收；
- 生成 staging evidence 后将本 Authorization 标为 consumed，并把 commit/push/PR 交给后续独立 publication Authorization。

## Consumption receipt

- Evidence：`docs/evidence/typo-correction-002-recall-remediation-publication-staging-2026-09-20-001.md`
- Result：clean `origin/main` staging 与 source-manifest reconciliation 完成；后续质量门被新 worktree 缺失 12 个 RIME artifact 阻塞。
- Non-claims：未 stage、commit、push、创建/更新 PR、merge、部署、设备采集或关闭任何 Gate/Assignment。
