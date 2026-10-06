# M2R2-REEXPORT-ARCHITECTURE 独立验收

- 冻结包：`architecture-packet.json`；SHA-256 `6537044efc63bade3810617689b702431a506642f48c045e56f926976638f749`（与相邻 `.sha256` 一致）。
- 核验基线：worktree `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`；branch `codex/keyboard-wake-v3-compatibility-gate`；HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`。两者都符合冻结包。
- 43/43 个 `allowed_targets` 均存在且 SHA-256 匹配。只读了冻结包列出的证据、指定源码和 context-only 文件；未访问包外历史输入。
- 独立 Architecture 判定：**Partial**。A1 的历史冻结导出边界和 A2 的 schedule 时点 owner 缺失均有局部证据；A3 已逐条映射，但 parent Assignment Exit 尚不满足。不得据此宣称根因已确立或 parent 已关闭。

## A1 — 历史冻结窗口、出口参数与借用边界

**局部判定：Covered（历史绑定有明确限定）。** `export-frame.json` 记录 PID 55759、`frame_id=0`、预期 mangled symbol、`Keyboard.debug.dylib` UUID，以及 `address` 和 `byteCount=1056`。`pty-transcript.txt` 记录同一断点的调用栈：出口函数 → `handleWakeOwnerProbeButton` 的同步 closure → `Array.withUnsafeBytes` → 按钮处理函数；实际只读一次 1056 字节。`read-receipt.json`、`decoded.json` 和 `snapshot.bin` 的 SHA 相符，解码出 11 条连续记录，缓冲 completeness word 为 complete、overflow 为 0。

借用仍在调用者内：`KeyboardViewController+WakeOwnerProbe.swift:83-90,94-99` 在 `words.withUnsafeBytes` closure 中同步调用导出桩，并通过 `withExtendedLifetime` 保持参数；`KeyboardWakeOwnerProbe.swift:38-49` 说明 buffer pointer 仅在 closure 时有效；frame 栈也验证没有脱离这条同步路径。callback 脚本只用 LLDB 静态 `SBValue`（`eNoDynamicValues`）取参数，没有 `EvaluateExpression` 或调用 target 函数；PTY 显示的是一次有界 memory read，随后删除断点、continue、detach、quit。因而这次参数读取有足够的 frame、borrow 和无 target 求值证据。

历史归属由 retained PID 55759、原 start time 与 app 路径连续、未处于 P_TRACED、Human 记录“期间未做其他操作”，以及 `freeze()` 对已有 `frozenValue` 直接返回的源码合同共同支持（`retained-instance.json`、`human-freeze.json`；`KeyboardWakeOwnerProbe.swift:223-250`）。`human-freeze.json` 的实际点击时刻仍为 unknown，原轮也没有先前 snapshot/header 可作逐字节比较。因此结论是“从同一保留进程导出了原冻结窗口的现存值”，不声称拥有独立旧 header 的字节级交叉比对。原先失败轮的 0 read 未被改写，见 `read-receipt.json`。

## A2 — owner 缺失与 receipt 缺失

**局部判定：Covered，限于两个 schedule 边界字段。** `decoded.json` 显示同一 coordinator 1 / appearance 1 中：attempt 1 的 schedule sequence 4 为 `owner=1, receipt=1, epoch=1, revision=1`；teardown sequence 7 后，attempt 2 的 schedule sequence 10 为 `owner=0, receipt=0, epoch=2, revision=0`，其 begin/end 记录成对。源码 `ThreadAffineRimeSession.swift:228-230,405-422` 显示 `wakeProbeOwnerPresent` 在同一 MainActor schedule 路径读取 `owner != nil`，`scheduleProcessKey` 对该 owner 做 optional `accept`，并将实际 receipt 是否存在写入 probe。故能支持“这次 schedule 时 coordinator 没有 owner，且这次提交没有 accept receipt”。

这不证明为什么 owner 在返回后没有恢复，也不证明所有恢复回调都未发生、既有/后续引擎工作状态、RIME 底层处理结果、结果发布、宿主 proxy 或 Maps 的因果故障。记录中没有 resume 标记只说明这个固定容量缓冲未记录该标记；它不是系统未调用 resume 的证据。`buffer_complete=true` 只表示这个本地缓冲没有标记为 incomplete/overflow，不能表示系统生命周期或父任务证据完整。

## A3 — Parent Assignment Exit 逐项映射

依据 `docs/assignments/keyboard-wake-lifecycle-diagnostics-001.md:140-147`：

| Parent Exit 条款 | 判定 | 本轮证据与剩余边界 |
|---|---|---|
| 1. 成功 baseline 与 failure/recovery timeline 用适用的既有身份关联 | **Partial** | 两次 paired attempt 在同一 coordinator/appearance 内按 sequence、attempt、epoch、revision 对照，正常 attempt 与失败 schedule 可比。该缓冲无 resume 标记，post-return 恢复没有被证明；validation 明确 recovery 未测试，故不满足完整 failure/recovery timeline。 |
| 2. 区分可观测的 disappearance/appearance、suspend/resume、owner、key acceptance、engine、publication、UI | **Partial** | probe 支持 suspend/teardown、两次 schedule 的 owner/receipt 状态；没有记录 resume 的 buffer event，也没有本轮 JSONL 对 engine processing、result publication、UI application 的同身份关联。Human UI 观察只能作视觉事实，不能补成这些内部事件。 |
| 3. source/build、设备/runtime、host、键盘配置、Full Access、诊断配置、时间 | **Partial（字段有保留边界）** | machine-entry、source-identity 和本轮工件记录了 candidate/source 文件 SHA、iPhone 18 Pro/iOS 27、Maps、时间及 configured schema；Full Access 是原轮 Human 确认，诊断键为 ABSENT/off。realized engine schema 未读取，且本轮没有新的 Full Access 或 engine-state 读回；不可把 configured preferences 扩写为运行态证明。 |
| 4. Extension JSONL 动态来源身份；仅在 arm/writer preflight 后才能报告 absence | **Uncovered** | 本轮读出的是内容无关的 KWOPROBE 固定缓冲，不是 Extension JSONL。validation 记录诊断键 ABSENT/off 且未写 JSONL；这不满足 writer-preflight，也不能证明 writer failure 或 JSONL absence。不得用 probe 缓冲替代 JSONL 契约。 |
| 5. 不含私有输入/宿主数据，并记录 artifact identity/hash | **Covered** | 导出结构是固定宽度数值记录；报告说明未复制输入、候选或宿主内容；manifest、raw frame、snapshot 和解码文件均有哈希。 |
| 6. 使用 Debug Investigator 报告格式 | **Covered** | re-export-validation 按 Symptom/Reproduction、Observed Timeline、Boundary Evidence、Root Cause Status、Next Diagnostic Step/Owner 组织。 |

Parent Exit 总体仍为 **Partial**；第 4 条是明确未满足的合同项。当前不应降低 Exit，也不能据“本地 buffer complete”关闭父任务。

## Findings 与交接

1. **阻止 parent Exit 的未覆盖项** — `docs/assignments/keyboard-wake-lifecycle-diagnostics-001.md:145` 要求 Extension JSONL 的 dynamic path/origin/process instance/generation/SHA，并要求先证明 arm/writer preflight。限定证据 `...m2r2-reexport-validation...md:13,25` 记载诊断键 ABSENT/off、本轮没有 JSONL，并明示旧 normal v6 JSONL 证据仍需映射。此缺口要由 Product Owner/Lead 决定是否另行授权满足该合同的证据，reviewer 无权豁免。
2. **审计残项** — `tool-ledger-gap.json` 记录 native 序号 5（命中轮询）没有通过 ledger helper 保存 request/response；完整 PTY 和 callback receipt 在。该缺口要求保留为账本不完整，不能说每个 native tool pair 都落盘；现有 PTY/frame/read/cleanup 互证仍支持本次唯一 1056-byte read 和 cleanup。
3. **禁止外推** — 下一诊断边界由 Keyboard Experience Maintainer 与 KeyboardCore Maintainer 接手，按 validation 的 handoff 处理。若要推进 parent Exit，Product Owner/Lead 先决定第 4 条所需输入/授权；本审查不代替该决定。当前证据不确定 RIME engine、host proxy 或通用 Maps 故障根因。

本 lane 未运行 build/test/simulator/LLDB，也未执行源码或仓库修改；这些不属于本只读 Architecture 验收授权。
