# AP-CMD-001 主机命令交付预检

Human“可以按照你的建议继续”授权仅 Mac 端命令交付核查及不附加进程的预检。状态 PASS_HOST_TRANSPORT_ONLY。没有 Simulator 查询、attach、arm/freeze、目标内存／参数读取、生产修改、构建、测试、安装或备份删除。

原 AP-META-001 记录显示 PTY 输入重复／损坏，live-binding 与 callback 未生成；具体机制保持未确认。不能据此归因 Keyboard 源码，也未故意重现原异常。

本轮把较长 Python 配置放入主机文件，PTY 只发送一条 80 字节左右的 command source；文件内最大命令行 102 字节。真实 LLDB 无 target，会话成功导入冻结 callback，SetAsync(False) 读回 false，1485 字节合成配置的 80 个 token 校验通过，host-receipt 写出并读回。callback 未配置亦未调用，不把合成值充作停点证据。

sourced 文件内 quit 未结束外层提示符；单独发送短 quit 后 session exit0。未来清理必须显式确认外层会话退出。五源码 hash、HEAD、branch、staged0 保持；写文档前完整 dirty 清单逐字相等（2120 行）。所有原备份／证据保留。

原件：/private/tmp/ukey-appex-meta-command-preflight-20261006，entry、host_transport_probe.py、commands.lldb、pty-transcript、host-receipt、completion。新范围自设上限20 actual calls／20分钟，不继承上轮30calls；最终16calls（含每次functions.exec及nested工具）；逐调用账本已写入completion。started_utc为4次入口读取之后，post_entry墙钟不冒称完整逐调用墙钟审计。

下一仅 AP-META-002 Prepared，另授新鲜独占及一次空框 arm/freeze。主机交付通过不代表 appex 停点身份、owner 导出、通知或 Maps 修复通过。无 CHANGELOG／架构合同修改必要。
