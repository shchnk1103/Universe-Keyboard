# 新独立reader-first交付：R0/A1 Covered，A2 Partial

Human授权更换独立审查者，先核reader工具再完成同一候选A1/A2。沿[Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-reader-new-entry-2026-10-03.md)，新独立Luna arch_reader_candidate未参与实现/构建/旧review。当前**正式Partial/incomplete**，新预算8calls已耗尽、504.787秒在1200秒hard内；不自动续审。无build/test/device/install/runtime/LLDB/Maps。

[原report](../reviews/c7-ui-reader-candidate-architecture-r1-review-2026-10-03.md)与[usage](../reviews/c7-ui-reader-candidate-architecture-r1-usage-2026-10-03.json)原样保留。usage和reviewer final明确R0/A1 Covered：独立审reader输入表、MachO字段/边界、section原bytes→plist与只读合同，正例及六负例通过后执行candidate --verify返回0；另行复算candidate四binding/78payload、两最终executable SHA/UUID/entitlement原字节等于归档及实际generated xcent，pair签名/Info、6MachO UUID匹配。candidate仍43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50。

A2剩余仅局部diff证明：三处Presentation调用已独立确认受DEBUG&&probe保护，但reviewer工具没有成功解析并人工审阅既有patch.diff，输出files=[]、added=0、safe=false，未取得diff未触及RIME/部署/并发合同的完整意见。root核raw diff为before/Presentation.swift→after/Presentation.swift、3hunks/12新增行、无删除，不能把此root观察充当缺失的独立A2验收。已有patch属于unified diff，不保证diff --git头；误把格式不识别当source不局部是工具局限，不是新材料性产品发现。

report标题写R0/A1/A2全Partial，与usage和final的R0/A1Covered矛盾；原件不改写。reviewer还自报1263总字符超700，但packet要求≤700中文字符+identity表，root计中文126，因此不能据总字符认定该条超限。真正开放项为A2 diff审阅及report/usage结论一致性。当前Q尚不完整，Quality R2限定意见保持；旧失败/Partial/预算缺口均保留。

[Root收尾证据](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-reader-new-artifacts/)保存固定reader、实际reader-checks、真实timer/执行receipt、原报告账本hash和停止裁定。收尾所有冻结输入/source571/Vendor630/产物仍匹配；原worktree/branch/HEAD84b9c192…、staged0，五镜像外原文件不变。文档links/diff通过不是Q完成，未Git发布/Gate/Close/Release，无CHANGELOG/长期架构合同或M-02触发。

下一可审查的最小补审只需直接读raw patch和Presentation关联处，确认unified diff一文件/三组条件插入，并以新报告对齐已有R0/A1Covered和新A2意见。不得重查reader/二进制、重建或操作模拟器；新round与精确预算须另获Human批准，当前8call限已停。
