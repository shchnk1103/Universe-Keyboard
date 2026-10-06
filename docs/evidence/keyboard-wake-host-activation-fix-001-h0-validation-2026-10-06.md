# H0 主机隔离预检 — 2026-10-06

Human“授权继续做H0”授20actualcalls/20分钟。状态：**Partial：基本主机callback身份链路通过，系统等待场景未覆盖。** 本轮仅一条macOS C夹具路径、一次专用出口命中；不把主机结果外推为Swift/Simulator appex成功。

## 结果

新夹具PID92050/helper92054，均由本轮创建。出口callback与CLI同PID/线程44472156/stop ID13/断点1.1；callback PC、bp_loc PC及CLI PC均0x102134410，模块UUID均F8346C9C-B8C0-4301-80AB-FE93EE8F62AC。函数h0_export_ready，命中恰1次。目标内容读取0、expression0，没有猜buffer地址。说明本次macOS主机链路可以得到一致身份。

附加时stop ID1/frame0为_dyld_start，未进入预期read系统等待位置：夹具附加前只等固定0.15秒，缺少程序内部就绪信号。这个H0设计遗漏使F4等待场景仍未覆盖，不能称完整H0通过。本轮没有错误后重跑。调试器明确使用同步CLI continue；F4未采async模式，不宣称两模式等价。C夹具也不替Swift动态库/实际appex。

## 收尾与账本

断点删除、detach成功、夹具/helper退出码均0，LLDB命令exit0；无强制终止。callback时间至清理结束上界由UTC可复算，详completion。五生产源码hash/branch/HEAD/staged0保持。不操作模拟器/已安装App/容器偏好，不建大备份、不清旧备份。

本轮12/20actualcalls，详细六批wrapper+nested账本及墙钟见[completion.json](keyboard-wake-host-activation-fix-001-h0-artifacts/completion.json)。[原始PTY](keyboard-wake-host-activation-fix-001-h0-artifacts/lldb-transcript.txt)、作者脚本/夹具/收据/hash清单齐。private binary与原件保留于`/private/tmp/ukey-host-activation-fix-h0-20261006`。

## 最小补齐提案：H0b（Prepared，未执行）

只改本轮隔离夹具/host脚本副本：在main进入read前通过独立ready pipe发固定就绪标记，launcher收到后才附加；附加frame须确为本夹具的系统等待点，PID/path必须是新建子进程。随后只一次continue/固定触发/专用出口命中，沿同样PC/stop ID/thread/bp_loc身份记录，禁目标内容读取及Simulator。ready只证明进入main，不替代实际附加frame的系统等待验证。

提案新12actualcalls/10分钟，最后4calls留清理/交付；不匹配停止不重跑。适用范围仍只主机隔离夹具，未来修复脚本及新运行需Human授权。原H0字节/失败覆盖保持，不覆盖原目录；不让Human重做Maps，不改生产五文件。

F4-M及整体修复仍Partial/Active，owner/callback导出缺口不因本轮关闭。
