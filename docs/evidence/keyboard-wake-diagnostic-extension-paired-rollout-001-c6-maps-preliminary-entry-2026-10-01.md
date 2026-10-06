# C6 Maps 一次受控复现 — preliminary Entry

日期2026-10-01 Asia/Shanghai；Human明确授权下一步Maps受控复现并确认原模拟器本轮独占。沿用已审同源候选af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9，branch codex/keyboard-wake-v3-compatibility-gate，HEAD84b9c19227330b0fe6ff391be001ee398010fd6a。run C6-MAPS-20261001-01，目标iPhone18Pro/iOS27.0 UDID405D994F-28CB-4F89-BB22-B64AD81C05A2。

Assignment Authority/Product Approver Human Product Lead；Domain Owner沿用Keyboard Experience Maintainer；Executor/Environment Executor当前Codex root，仅本轮身份/gates/窄采集/reader/恢复，root唯一repo writer；Human Dependency当前用户，操作一次Maps流程并报告内容无关反馈；Architecture Reviewer Not Applicable（本轮无设计/源码改变，复用已归档同candidate设计证据）；Quality Reviewer原独立Quality lane为未来归档review handoff，本轮不自动授权新的独立review。ParentActive。

**只读preflight完成；尚未arming或复现，runtime Entry未满足。** root只读核source568/built111/installed111与11Mach-O、branchHEAD一致，RIME稳定，原targetBooted及Maps可用（build2972.30.6.12.58）。开启前四键已由machine读取：logging_enabled存在false，diagnostics_high_fidelity_expiration不存在，log_category_disp/engine不存在。冻结本轮原值/原存在性，不能用上一轮UNKNOWN恢复残项替代本轮精确恢复。完整身份/限定prefs与Maps版本见同prefix preflight.json。

当前依赖：Human补充原Maps AppSwitcher/app-switch操作和具体异常，确认本轮FullAccess状态；root据此冻结一次具体操作顺序/最小合成输入、窗口开始/结束与反馈观察项，再指引开启。所缺复现路径不是推测已有bug；无这些事实不进入Ready，不启用诊断。用户已获得询问，开启前保持两项关闭。

执行范围：单次Human Maps受控流程，现有logging/Debug高保真默认30分钟及DISP/ENGINE gates，本轮最多一次且零automatic retry。只用合成输入，不归档实际输入、候选或宿主内容；导出本窗口finite typed lifecycle/resume/proxy标记及计数/拒绝/不完整状态，动态keyboard_extension*.jsonl窄读取，不复制完整journal/history。原17条是历史reader证明，不作为本轮数量预期。reader同配对App查看此新窗口，真实呈现警告；UI不显示隐藏IDs，不冒充逐行隐藏身份证明。

Exit：本轮身份/时间/操作反馈、有限事件timeline、reader可见状态、四键原值及原存在性恢复核验和保全收据。若未复现仅not reproduced/inconclusive，started非ready、returned非Hostaccepted。未发生事件不能推断producer缺陷；不得声称30skip通过/接受自动carry到C6，不把新观察升级整体Gate。

停止：身份漂移、独占失效、FullAccess/宿主不可用、RIME部署不稳、expiry失效、必要路径或证据缺失；原始故障出现时保留现场、不重启/重装/清日志，先结束窗口采证和恢复。需要新增读域/探针/源码修复/复现轮次交Human决定。无build/test/install/redeploy/reset/日志清空/源码/Git/Release授权。Handoff parent Assignment及Human Product Lead，未来独立review需新精确packet/预算。默认marker release行为不变。


## Entry update before arming

Human本轮确认FullAccess仍开启；历史症状已绑定，单次受控变体步骤已冻结。身份/独占/四键原值和存在性/RIME/Maps前置均有本轮证据。**Ready for Human arming only**；开启后机器确认gates/expiry和window start，才指引Maps基线输入。原pending段保留历史，不声称已执行复现。

## Armed gate and window start

Human已报告两项开启；machine确认logging=true/expiry有效，DISPENGINE保持原absence/defaultenabled；source568/built111/installed111未变。现有执行授权与FullAccess/独占有效，Active for one Human Maps trial。window start见同prefix window.json；先Maps基线，不提前app-switch，不重置窗口或retry。
