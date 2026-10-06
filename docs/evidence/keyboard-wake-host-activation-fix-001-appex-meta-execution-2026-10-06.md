# AP-META-001 执行记录（Stopped / Partial）

本轮按已授权 Entry 核实原 UDID、新鲜独占及关闭状态；核实旧 PID 64039 身份后仅一次正常 SIGTERM，确认退出。Human 在主 App 搜索空框叫出新实例 PID 95682，确认观测可见、完全访问开。安装 78 文件核验一致，Keyboard.debug.dylib 字节与 UUID 匹配冻结产物。

LLDB attach 成功，出口符号解析至 +60，模块 UUID 4B207746-89A7-321F-83C4-91477259BB26。配置命令在 PTY 输入期间未完成，原始记录显示重复／损坏输入；具体机制尚未确认。未生成 live-binding.json、未配置成功或调用 callback；未要求 Human arm/freeze、未输入、未读取目标缓冲或参数。本轮不得报告停点身份匹配、owner 导出或 Maps 回归通过。

清理中显式删除断点 1；原始记录另显示意外断点 2 建立，不声称 detach 前列表已清空。随后 process detach、quit，PTY exit 0；同 PID 状态 Ss，无匹配 debugserver，诊断原三键仍 ABSENT。Human 已确认“界面正常，显示观测；App 已关闭”，视觉 Exit 已闭合。未改生产源码、未构建／测试／安装／部署／Git 操作或删除备份。

运行根：`/private/tmp/ukey-host-activation-fix-appex-meta-20261006`。原件包括 device-entry、old-appex-termination、fresh-instance、pty-transcript、machine-exit、run-summary。最终累计 29/30 actual tool calls，起点 2026-10-06T02:22:04.417917Z，机器 Exit 02:29:40Z。收尾采用剩余预算，不续采样。后续先预检主机命令交付方式，不能把本次停滞推断为 Keyboard 源码问题。

最终收尾：2026-10-06T02:31:39.673909+00:00；墙钟 575.3 秒，未超过 30 分钟。执行状态仍为 Stopped / Partial，不将停止收尾等同采样成功。
