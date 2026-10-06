# U1 提前冻结停止交付 — 2026-10-03

状态：Incomplete，未完成正常输入/有界导出链。Human报告首次点击后确实显示“取证”，但输入卡尚未下发时又点击“取证”，觉得没有变化。原话及实际显示保留，不猜操作UTC，不将其解释为冻结失效。

## 已核事实与恢复

本轮session c4c1730c…的实际loaded Keyboard/Keyboard.debug路径在原UDID405D994F…当前installed容器，UUID C3FC7115…/77BD18E2…与43d85d…H1匹配；工具默认标签884CAC1A…冲突仍保留。[绑定readiness](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1-artifacts/binding-readiness/attach-ready.json)。

Human追加点击后breakpoint1真实hit count1，支持已到freeze出口。按异常停止合同不读参数、不采caller、不复制内存，memory reads0、无snapshot/decoded，不为了补证继续冻结实例输入n。该探针单进程实例一次性frozen，不能rearm，不自动重启。

root尝试MCP debug_breakpoint_remove(1)失败“Breakpoint not found:1”：断点由LLDB命令创建，DAP工具自己的registry未登记，不是断点未命中。此前breakpoint list真实存在且hit1。没有把移除错误伪写为成功；随后continue running及detach detached两回执成功。未独立采detach后断点列表，不额外attach补清理；不能声称显式breakpoint-delete成功。只读Exit：PID80843 stat Ss、同可执行路径不在停止态，78SHA匹配H1，两诊断键ABSENT/off保持。Human UI恢复确认仍Pending，不等同machine Ss。

## 账本与边界

原身份冲突3debug calls、绑定readiness6calls、此次停止4calls，共13底层debug calls；逐次原始回执/UTC/monotonic writer时间边界与SHA已完整保存，无遗漏/补造。Human实际点击及target pause开始UTC未测，因此不能声称实际暂停时长符合120秒，只有root cleanup命令区间有可证时间界限。[final ledger](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1-artifacts/premature-freeze-stop/ledger-summary.json)。所有原Hold证据保留。

这次“观测→取证”显示与freeze出口命中已观察到，但不是一次n输入/attempt配对/导出验证通过。用户没看到新的画面并不证明控件无效：freeze是内存快照出口，标题可以仍是取证；root没有读取此次buffer，不能声称内容完整或owner存在/为空。无Maps/根因/Gate/Release结论。没有kill/restart/install/deploy/restore/新测试，旧备份保留。

下一步先收Human界面恢复/标题回报，不追加输入。若继续正常路径单轮，必须另授权新扩展实例（不重装App）及新一轮U1，固定同候选重新核身份，不复用冻结实例；同时cleanup改用与创建方式一致的LLDB breakpoint delete/list命令。[重试Prepared](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1-fresh-instance-prepared-2026-10-03.md)。父子Assignment Active；docs-only跳过xcodebuild，无源码/CHANGELOG/架构合同修改。

## Human Exit补充（原Pending保留为历史）

Human已确认界面恢复正常、标题为取证；另报告cleanup后误触n或其他键并立即删除，字母不确定，不独立读取内容，不填精确动作时间。[Human回执](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1-artifacts/premature-freeze-stop/human-exit-with-accidental-input.json)。这不是协议内正常输入轮，不改变此前0memory read/无snapshot/Incomplete；冻结实例不能由事后输入补成有效配对。之前machine Exit在此误触前，不主张其后data字节一致。新实例单轮仍Prepared，未执行重启或再次采集。
