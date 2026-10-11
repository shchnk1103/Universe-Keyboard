# H0b 一次主机夹具错误码采样 — 2026-10-06

Human授权“授权一次主机夹具采样”。只编译/sign已冻结记录副本，执行新主机夹具一次；无代码修正、自动重跑、Simulator或生产写入。

## 确认结果

PID93025，ready及实际libsystem_kernel/read+main等待验证通过。continue后私有stderr为`read_return=-1 errno=4`，本机Python errno映射为EINTR；[Apple read手册](https://developer.apple.com/library/archive/documentation/System/Conceptual/ManPages_iPhoneOS/man2/read.2.html)定义EINTR为收到数据前读取被信号打断。夹具源码对任何read_result!=1返回2，所以本次中断后立即退出2，未到专用出口，callback0。

已证的是本次夹具没有处理EINTR；具体信号来源未被记录，不能声称已定位LLDB/OS根因。helper exit1原因未采，不能补称EPIPE；原H0b未保存errno的UNKNOWN历史保持，不以新轮拼补旧轮。更不能把此错误外推为键盘/RIME问题。

## 收尾

断点删除，夹具exit2/helper1均已退出，LLDB命令exit0；无目标内存/表达式/设备操作，五生产文件hash/branch/HEAD/staged0保持。记录采样目标完成；完整主机callback和F4导出仍Partial。

实际9toolcalls、墙钟与逐批账本见[completion](keyboard-wake-host-activation-fix-001-h0b-read-sample-artifacts/completion.json)，原始PTY、错误码文件、作者脚本及SHA清单已归档。未新建大备份、不删旧保护。

下一仅建议：在隔离夹具处理已确认的EINTR，限制重试次数并继续记录每次返回值/errno；不处理其它错误，之后一次主机验证。修改与新执行另授权，当前未实施；不再次要求Human操作Maps、不改生产键盘。
