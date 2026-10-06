# M2R1 调试会话生命周期只读核查 — 2026-10-04

Human授权继续核清会话失效与旧断点残留。仅只读source、工具/精确目标进程元数据；无重新附加、输入、AppSwitcher、arm、freeze、目标内存read、信号或工具重启。

## 确认事实与推断

当前两个Node进程都运行缓存XcodeBuildMCP 2.7.0包；source摘要见[receipt](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m2r1-artifacts/tool-continuity-receipt.json)。manager sessions是process-local Map，singleton也是模块内存；runCommand/detach先requireSession，查不到即报No active debug session，尚未进入backend调用。这不是LLDB实际执行breakpoint list后发现断点不存在。

北京时间12:16:51首次attach；12:19:55 call08仍成功且hit0；12:20:26/27当前第一组npm/node启动；12:21:14 call09返回No active session；12:24:56/57当前第二组工具启动。两个现存manager进程都晚于最后一次成功调用。原attach时MCP PID未采，无法唯一绑定其退出或重启原因，也不能排除路由到另一进程。本地源码和时间序支持“进程生命周期/路由更替导致内存会话不可见”的解释，不能把推断写成确证的重启根因。原shell沙箱ps限制确有主机对照，但此No active session错误来自registry检查，不据它认定LLDB权限拒绝。

## 残留与覆盖限度

精确原扩展41635仍Ss；ps flags按系统man说明为十六进制0x4004，SDK P_TRACED=0x800，当前该位未设置；此前 scoped process inventory也未发现debugserver/lldb-dap，其他lldb-rpc-server未触碰。因此采样时没有P_TRACED标记且未发现对应活跃调试服务。不能把这项运行状态替代原breakpoint delete/list或detach成功回执；旧软件断点字节未读取，断点清除/原session detach仍UNKNOWN。没有通过attach读取内存来补证明。

## 下一最小建议（Prepared，未执行）

先验证一个在人工回复边界保持不变的调试通道，再另开Maps配对窗口。具体另授权：精确身份/独占后，用持续LLDB通道附加，核loaded UUID与自身出口断点0hit并恢复运行；Human只等待并回复，不输入/arm/切App；再次核同调试器进程、同target和原断点可查询，随后自身断点cleanup/detach。所有动作绑定持久化账本，不依赖root临时store。优先考虑提升权限下持续PTY LLDB通道，避免依赖本次已失效的MCP进程内session；该方案尚未运行验证，也不保证不会遇到同类宿主生命周期问题。

此次只读调查完成；M2R1仍Incomplete，不追加复现、不改源码/安装/共享配置，无独立Gate或Release结论。更换工具通道/重新附加与新鲜取证不在本次只读授权内。
