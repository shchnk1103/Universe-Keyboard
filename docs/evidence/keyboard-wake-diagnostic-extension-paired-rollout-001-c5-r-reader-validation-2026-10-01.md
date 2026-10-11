# C5-R 同一历史窗口 reader 补证

原运行 `C5-R-20261001-01` 的 17 条有限标记，在同一配对 Main App reader 中完成 **17/17 显示多重集核对**：2 lifecycle、1 resume started、14 proxy（6 set_marked_text 对、1 unmark_text 对）。15 个不同显示行中，10:46:30 的 entered/returned 各出现两次，按实际重复数保留。原历史窗口与原 typed-window 不改写。

证据：[UI 有限快照](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-reader-ui-snapshots.json)、[预期渲染](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-reader-expected-rendering.json)、[逐行对应与数量](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-reader-comparison.json)、[收尾身份与诊断状态](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-reader-final-check.json)。重复观察按单屏最大出现次数合并，避免把反复滚动同一行重复计数。

Human 自主使用既有关键词搜索 `text` 并要求查看，随后按指引搜索 `10:46:26`、滚动到底。seq30 显示 14/67，全部14个 proxy 目标行可见；seq33 显示10/67，其中三个目标 lifecycle/resume 行可见，另七条不属本补证目标。67 是 reader 总条数，不是目标窗口条数。显示时间10:46对应原UTC02:46，偏移+08:00。已观察语义UI未显示匹配的 incomplete/unsupported/unavailable/budget/partial 异常提示；这是可见警告状态证据，不冒充内部解析计数器。

Entry 原先建议避免搜索以免激活键盘；Human 后续明确自行搜索并要求检查，故仅记录既有诊断 reader 筛选活动。没有启用诊断或重跑合成输入，不声称整个查看期间零键盘/lifecycle 激活。没有读取当前 raw journal、截图、复制全部日志或保存其他日志内容。

UI 不显示 process/appearance/localSequence：隐含身份仍依赖原 producer 投影与未变 source/built/installed 绑定。同秒相同行只能证明数量，不能逐行辨识隐藏 localSequence。17/17 是本次历史有限标记的显示覆盖证据，不是所有日志/所有操作完整、Host接受、RIME ready、insert_text通过或根因结论。

收尾 source/build568、built111、installed111 完全匹配，branch/HEAD 不变；logging=false，high-fidelity expiry 不存在，DISP/ENGINE键仍不存在。MCP 临时 active profile 已恢复原 profile，未持久改配置。原30 skips仍Skipped/unverified；原恢复键存在性残项和旧review Partial保持不变。

**本次补证完成；原 HOST-Q-R-01 Hold 保留，等待另行授权的独立处置。** 本轮不自动开始独立复审。Parent Active，无整体Quality/Product/Release Gate、根因或closure；未执行source/build/test/install/Maps/Git发布。
