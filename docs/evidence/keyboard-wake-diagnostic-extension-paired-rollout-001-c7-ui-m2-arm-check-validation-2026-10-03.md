# M2-A 新实例单次 arm 出口检查 — 2026-10-03

## 限定结果

Human 授权新实例仅 arm 后检查出口；本轮截至点按后的机器检查，出口断点 hit count 仍为 0。未执行输入、App Switcher、freeze 或内存读取，不能判定旧 M2 的提前出口原因、Maps 返回后 owner 状态或根因。父子 Assignment 保持 Active。机器 cleanup/Exit 已完成，人工仅视觉 Exit 待确认。

## Entry 与身份

原设备 iPhone 18 Pro / iOS 27.0，UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`，Human 关闭 Maps/主 App并确认独占。旧 PID3626 精确核实后仅一次 SIGTERM 正常退出；新 PID8491，Maps PID8484。Human 新实例回报“观测已出现”。同候选 `43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50`：安装78文件、6 MachO、双签名、1279源输入与M0备份956文件核验通过；两诊断键保持 ABSENT/off，部署状态正常。

实际加载 Keyboard.appex 路径属于原 UDID；appex UUID `C3FC7115-4215-3801-ABBB-C8A648ED0C32`、debug dylib UUID `77BD18E2-E090-37D7-865F-84D762E69F70` 匹配冻结候选。MCP raw profile 标签仍为另一个 UDID `884CAC1A-516A-421F-ACF5-035A36F7088A`；精确 PID、实际加载路径/UUID用于身份，不把标签冒充真实目标。未改共享 defaults，全部命令显式 session。makeCurrent:false 与 raw current banner 差异保留，全局 current 状态未独立核验。

## 单次操作与检查

本轮 session `1aa93c8c-de39-4b22-946f-6e823c2127b6`。出口符号唯一匹配；自身断点1只有一个 resolved location，pre-arm hit0；continue回执 running 后才下发只点一次观测的操作卡。Human 回报“按钮显示‘取证’”；收到回复后第一项机器操作直接检查断点（call07），仍 hit0。标题本身不能区分 armed/frozen；此处结论来自断点计数。Human 点按数量依赖操作卡和回报，未采 UI action 数；不宣称计数证明单一物理事件。

## Cleanup、Exit 与账本

call08 删除自身断点1，call09 list为空。随后多余的 continue（call10）返回 `threads failed: notStopped`，不记成功、不重试；call11 detach成功。最终 ps 为 Ss，未保持暂停。安装/源码/M0副本及关闭诊断状态再次核验通过，0 memory reads、无 snapshot、无输入或切换。11 debug calls / 22 request-response 账本顺序与raw SHA全核验；UTC与monotonic在调用前后落盘。真实 target pause start 未测，保留 UNKNOWN；本轮未发生出口停点。

原machine-entry继承模板的 old_consumed_pid=88188 字段不准确：本次真正终止的前驱是3626，原件不改，增量结果和 machine-exit 已纠正。记录范围不构成独立 Quality/Architecture 验收或 Release。

## 后续边界

本轮仅 arm checkpoint 到此停止；probe 的后续状态未读取，不追加 freeze 取消。人工 Exit 只看界面，不试打、不切换。Human 后续决定仅记录旧 M2 一次提前 hit1，暂停专项追查；如后续再现再讨论。此项不再作为当前阻塞或默认下一步。原因仍未确定，不改写旧 M2 Incomplete，也不新增输入、切换或取证授权。

证据：[保全清单](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2-arm-check-artifacts/preservation.json)、[本轮结果](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2-arm-check-artifacts/arm-only-result.json)、[Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2-arm-check-entry-2026-10-03.md)。


## Product 增量决定 — 2026-10-03

Human：“我们先只记录，等后续再有这样的情况再说吧。”保留旧轮 hit1 与本轮 hit0 原始证据；不追加该异常的专项验证或猜修。人工视觉 Exit 尚未回报；本决定不等于已完成该确认。
