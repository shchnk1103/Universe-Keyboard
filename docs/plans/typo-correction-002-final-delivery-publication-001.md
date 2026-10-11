# 固定交付发布方案 — Proposed / unconsumed

具体下一权限：commit、push及一个draft PR。当前未获授权；上一“继续”仅执行交付包准备。

- base `59272331b3627856c1c4480b0b5d7ad0ddade0ad`；branch拟 `codex/int003-final-delivery-592`，不修改main；writer保持当前隔离I。
- 只stage[精确manifest](../evidence/typo-correction-002-delivery-packaging-001-manifest.json)里的payload路径加manifest自身。严禁stage G的全部dirty或使用git add .。Proposed→Live/consumed的授权元数据转换在同一固定路径内明确再封印，不改28源。
- commit前、push前分别执行23Swift format/strictlint；若任何源码hash变化，与已通过CI不一致即停止，不能用“格式修改很小”跳过验证。仅文档变化复用本地CI，预期hosted完整及分类检查。
- 发布包含源码及必要证据/范围决定/有限状态同步/DEBUG复用说明；历史review原件存.original.txt，展示副本仅改临时绝对路径链接语法。raw数值snapshot归档12,896bytes，无输入/候选文本。
- 精确本地证据：[完整CI＋DEBUG52](../evidence/typo-correction-002-fixed-main-validation-001.md)，未声称总体CPU/UI/内存性能Pass；P1/P2不重做。Proposed export ADR仍延期/未Accept。
- PR明确draft、父Active、merge/Gate/Close/Release均未授权；获得URL后附加本线程。读取hosted结果/head，不通过就保存，不自动改源码/追main。仅相关冲突交回Human。
- commit/push失败保留本地分支和证据；不删除尚未合并候选/原worktree。无模拟器或Human输入动作。成功后提出具体merge决定，不能把green CI当Human批准。
