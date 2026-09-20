# AUTH-TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-SCOPE-RECONCILIATION-001

- 状态：consumed
- 建立时间：2026-09-20T14:19:04+08:00
- 消费时间：2026-09-20T14:23:13+08:00
- 适用工作树：`/private/tmp/universe-keyboard-typo-correction-002-recall-preflight-001`
- 分支：`codex/typo-correction-002-recall-preflight-001`
- 当前 HEAD：`d0df9a6342d8209b5aa7f9826541d0b430b9da04`
- 当前 tree：`27ae44bec1b157e391ef1e0b859db3a068e21ba8`
- 上游比较基线：`origin/main`
- 上游 source manifest：`docs/evidence/typo-correction-002-recall-remediation-publication-preflight-source-manifest-2026-09-20-002.txt`
- manifest SHA-256：`709370f83f819a885f95b6224a763d59712eeac93f164939c03ae31627a9f207`
- 前置 Product decision：`docs/product-decisions/TYPO-CORRECTION-002-RECALL-REMEDIATION-PUBLICATION-PREFLIGHT-BOUNDED-DECISION-2026-09-20.md`

## 目的

在申请真正的 publication Authorization 之前，对当前混合 working tree 做一次只读范围对账，确定：

1. 哪些源码、测试和 KOS 记录属于 recall remediation 的最终候选范围；
2. 哪些文件是历史、旧基线、其他 Assignment 或无关残留，不能未经重新授权带入；
3. 最终候选文件、HEAD/tree、source manifest 与后续 publication Authorization 应如何重新绑定。

## 允许动作

- 只读执行 `git status`、`git diff`、`git ls-files`、对象哈希和历史/上游对比；
- 写入一份 scope-reconciliation evidence；
- 在证据完成后，更新本 Assignment 与 `docs/ACTIVE_WORK.md` 的状态镜像；
- 消费本 Authorization，并在记录中保留消费时间和证据路径。

## 明确禁止

- 不修改 Swift、测试、RIME/vendor 或工程文件的内容；
- 不执行 build、test、deploy、reinstall、Simulator/device capture 或新的 Run；
- 不 stage、commit、push、创建/更新 PR、merge 或 Release；
- 不删除、清理、restore、reset 或吸收其他工作树的变化；
- 不关闭 parent Assignment、Product Gate、Quality Gate、Release Gate 或任何 child Assignment；
- 不把本 Authorization 解释为 publication、commit、push 或 PR 授权。

## 关闭条件

只有 scope-reconciliation evidence 明确列出最终候选文件、排除项、当前 HEAD/tree、与上游的差异及 manifest 绑定后，才可将本 Authorization 标为 consumed。任何无法归属的文件保持 UNKNOWN，并交由后续独立授权处理。

## Consumption receipt

- Evidence：`docs/evidence/typo-correction-002-recall-remediation-publication-scope-reconciliation-2026-09-20.md`
- Result：范围对账完成；publication staging 被当前分支相对 `origin/main` 的旧基线和混合 working tree 阻止。
- Non-claims：未修改源码、未 build/test、未产生 Run、未 stage/commit/push、未创建/更新 PR、未 merge、未关闭任何 Gate 或 Assignment。
