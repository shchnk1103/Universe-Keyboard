# H0b 有界EINTR处理与单轮验证 — 2026-10-06

Human授权“仅给夹具增加有界EINTR处理，再验证一次”。仅新private主机夹具：read最多两次，只在第一次-1/EINTR时重试一次，其它错误及第二次中断仍退出2；记录每次整数返回值/errno，无输入内容。没有改生产键盘。

**本轮主机夹具等待→出口身份链路通过。**

私有读记录如下：

```text
read_attempt=1 read_return=-1 errno=4
read_attempt=2 read_return=1 errno=0
```

ready后实际附加frame为libsystem_kernel/read+main，stop ID1。出口callback恰1次，PID93371、线程44492531、stop ID2、断点1.1；callback/CLI/bp_loc PC同为0x100a0c460、模块UUID同为3B1459FA-EF00-466F-A0DD-F2FD0AC6D0AE。不是拿CLIframe替代callback，未读取目标内存或调用表达式。

删除断点/detach成功，夹具及helper退出0，LLDB退出0；callback至清理结束时间上界由UTC可复算。五生产hash/branch/HEAD/staged0保持，未Simulator/App/容器/部署或新大备份。6actualcalls及完整账本、原件hash见[completion](keyboard-wake-host-activation-fix-001-h0b-eintr-artifacts/completion.json)与[manifest](keyboard-wake-host-activation-fix-001-h0b-eintr-artifacts/manifest.json)。

此Pass只限macOS C隔离夹具的一次等待→命中路径。同步CLI模式与Swift/Simulator appex仍不同；不证明F4异常根因、owner/receipt或Maps修复完成。未另测第二次EINTR/EOF等失败分支；代码有界退出规则不代实际分支验证。历史Partial保留，不拼补旧轮。

下一仅建议准备appex元数据停点Entry，绑定实际stop ID/thread/bp_loc/frame PC与时间戳；未来执行另授权。不自动再次LLDB/点击probe/Maps、不改生产源码。
