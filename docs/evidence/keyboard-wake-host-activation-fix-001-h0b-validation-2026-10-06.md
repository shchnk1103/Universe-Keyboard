# H0b 就绪握手交付 — 2026-10-06

Human授权“接下来只补H0b就绪握手”。新12actualcalls/10分钟；只改新private目录中的隔离macOS夹具/主机采样脚本，不改生产源码或原H0字节。

**就绪握手完成；等待→出口完整验证仍Partial。**

夹具在main通过独立stdout pipe写固定R就绪标记，launcher收到才附加；同时以实际frame验证等待，不仅相信ready。PID92468、线程44479797、stop ID1，frame0为libsystem_kernel/read，caller names为read/main/start。此项补齐了H0的_dyld_start覆盖缺口。

CLI continue后夹具退出2、helper退出1，未触发callback。夹具main仅在read(...,1)返回不等于1时返回2；未记录实际返回值与errno，helper stderr也未保存，原因UNKNOWN。不能直接归因为EINTR或EOF，更不能归为键盘/RIME故障。未猜内存、未silent retry。

断点删除，夹具与helper均已退出，LLDB正常退出0；工具exit0不盖过夹具exit2。目标内存读取0、expression0、模拟器操作0。生产五文件SHA/branch/HEAD/staged0保持，旧大备份不动，也未建新大备份。

本轮8/12calls；UTC墙钟、四批逐调用账本、完整PTY/host脚本/夹具及hash清单见[completion](keyboard-wake-host-activation-fix-001-h0b-artifacts/completion.json)和[manifest](keyboard-wake-host-activation-fix-001-h0b-artifacts/manifest.json)。新binary/原件保持于`/private/tmp/ukey-host-activation-fix-h0b-20261006`。

这个macOS程序是取证工具校准样本：没有键盘、RIME或用户数据，只在任务私有pipe等待固定token，之后走一个专用出口，供LLDB核对停点/frame身份。它只能验证主机工具链路，不证明Swift/Simulator appex或Maps修复成功。

授权的握手补齐已经完成；完整通道验证缺口保留。若后续继续，最小建议仅补夹具read返回值/errno收据及经证据确认的有界中断处理，另授权后才修改/新运行。不重复Maps、不改产品源码，F4 owner导出仍未验证。
