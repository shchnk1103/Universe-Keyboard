# H0b 夹具返回值／错误码记录改动 — 2026-10-06

Human仅授权“请只补夹具的返回值／错误码记录吧”。完成新private副本的两处记录改动，**未编译、未启动夹具或LLDB、未操作模拟器**。原H0/H0b及生产源码保持。

- `fixture.c` 在单次read之后立即保存返回值与errno；仅返回负数时errno有意义，否则记录0。只打印整数`read_return`/`errno`，不输出读取内容。原read_result!=1退出2保留，无重试或修复。
- `host_probe.py` 仅把该子进程stderr保存到任务私有`fixture-read-result.log`，helper与debugger流程保持。文件会在未来授权执行prepare时创建，本次没有错误码样本，不能把代码改动当作已经取证。

Python AST语法检查通过；原件/new副本/差量SHA冻结见[receipt](keyboard-wake-host-activation-fix-001-h0b-read-record-artifacts/receipt.json)与change.patch (`keyboard-wake-host-activation-fix-001-h0b-read-record-artifacts/change.patch`)。未执行C compiler验证，未来执行授权需要先验证编译。private副本：`/private/tmp/ukey-host-activation-fix-h0b-read-record-20261006`，无新binary/大备份。

下一若授权，仅一次主机夹具采样以读取实际返回值／错误码，之后再决定是否修正；不默认是EINTR，不处理生产键盘，不重新Maps。当前H0b完整通道及F4仍Partial。
