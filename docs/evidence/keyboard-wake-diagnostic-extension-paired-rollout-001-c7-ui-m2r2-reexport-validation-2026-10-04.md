# M2R2 同一历史冻结窗口补导出 — 2026-10-04

## Symptom → Reproduction

Human正常基线后，仅打开AppSwitcher直接返回Maps，键盘没有关闭重开；宿主输入框清空，候选保留。返回后单次合成按键有反馈，但候选和输入框无更新。原轮出口参数失败保持Incomplete/0read，未重写。本补证只重复导出其已冻结记录：Human确认“已点击取证，期间未做其他操作”。没有新arm、输入、切换、构建、安装或部署。

## Observed Timeline

快照1056字节、11条连续记录，本地incomplete=0、overflow=0；header和600秒TTL验证通过。记录相对arm：正常attempt1约76.602秒开始，schedule记录owner=1/receipt=1/epoch1/revision1，begin/end齐；约209.295秒suspendBegin，随后teardown reason1且owner=0，再suspendEnd；返回后attempt2约391.271秒开始，schedule记录owner=0/receipt=0/epoch2/revision0，begin/end齐。所有记录为同coordinator1/appearance1；没有resume标记。无resume是本缓冲的缺失，不等于证明系统回调从未发生。

## Boundary Evidence

原PID55759/start UTC04:48:08与安装路径持续一致，Human无其他操作及Core freeze优先返回existing frozenValue合同支持归属原M2R2历史窗口。没有旧header可逐字节对比，run/process token仅本补读取得，非PID值。原UUID/source/build 1279、installed78/6MachO/双签名、956保护文件通过；原UDID iPhone18Pro/iOS27.0及Maps固定，Full Access来源原轮Human确认，schema仅configured26key/luna_pinyin，realized engine schema未读。两诊断键ABSENT/off，未写JSONL；本次来源是已审内容无关KWOPROBE缓冲，不能伪造JSONL路径/generation或以off时absence推writer失败。

实际callback命中帧为export frame0，符号和debug dylib UUID匹配、按钮同步borrow栈齐，静态address与byteCount可读。只读一次1056字节，SHA256 11bafebea4e558360a155d5ac3f7739161f2e4177456fd84f7322bef1b5e631e。断点删除/list为空，continue/detach55759/quit exit0；LLDB59734与debugserver59735退出，55759flags0x4004/P_TRACED clear。机器与人工视觉Exit齐：Human当前候选/输入框均空、按钮仍取证，与原轮保留候选的视觉状态不同。此差异原因未观测，不将其解释为输入恢复；未追加试打。

## Root Cause Status

该历史失败attempt在同MainActor schedule边界实测owner缺失且receipt未取得；ThreadAffineRimeSession.swift的wakeProbeOwnerPresent明确读owner != nil，schedule标记读取实际receipt。正常attempt与失败attempt对照已取得。证据支持交接coordinator visibility teardown／返回后owner恢复与调度边界；不证明RIME底层处理失败、部署缺陷或宿主proxy故障，也不证明所有Maps失败均同因。精确恢复回调为何未覆盖仍待领域所有者分析，禁止猜修。

## Next Diagnostic Step / Owner

停止新的模拟器复现，交Keyboard Experience Maintainer与KeyboardCore Maintainer定点确认以上边界。下一只读独立Architecture/Quality针对冻结manifest验收历史绑定、参数读取、双attempt关系和父Exit映射；无源码实施/Release/Git动作授权。

父任务Exit尚未自动满足：旧正常v6 JSONL证据、当前probe timeline与回调覆盖限制需逐项映射；独立结论未取得，不能把probe缓冲冒充JSONL，不能只凭一次snapshot关闭父任务。

## 工具账本残项

native序号1–4、6有request/response原件；序号5命中轮询未经账本helper落盘。完整PTY、callback receipt与后续read/cleanup原件保留，已单列tool-ledger-gap，不能宣称全部工具request/response齐。该缺口不删除或补造时间；是否影响最终验收由独立review判断。

证据：[冻结manifest](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r2-reexport-artifacts/manifest.json)、[decoded](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r2-reexport-artifacts/decoded.json)、[cleanup](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r2-reexport-artifacts/cleanup-exit.json)。原轮[M2R2停止记录](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r2-frame-stop-validation-2026-10-04.md)不可变。本次无用户文本、候选或宿主内容写入artifact。
