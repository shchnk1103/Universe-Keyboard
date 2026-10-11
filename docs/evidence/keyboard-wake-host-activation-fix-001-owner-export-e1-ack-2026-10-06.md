# OWN-EXPORT-001 E1 主机 ACK（现场 Entry 未齐）

状态：主机身份 PASS；**未**宣称现场 Ready。未查询设备、未 attach、未 SIGTERM。E0 未重跑。

## 冻结核验

- 工作树/branch/HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a` / staged 0 与 Entry 一致。
- Entry SHA `d3673a274ee76fb35cd6bae04723d3ea6a3e1deba6a55da540be4b1b71adf7e0`，binding `2f2f90d94dc9116b30aabed7f8a14b7cdc6670b18d0cfc30d8145c127554a1b3`。
- E1 AUTH `e1-grok-authorization.json` SHA `c6cdfa40f69e3397bbe77b97f33581e714b90836003cbbd6861eee204c1a21a9`。
- 冻结脚本 SHA 与 AUTH `frozen_e0_sha256` 一致（callback/host_preflight/decoder/formatter/correction-preflight/e0-call-ledger）。
- 1156 源文件逐字节通过（358+168+630）；候选 payload 78/78 通过。
- live callback/args/bin 均为空；synthetic-e0-leftover 保留且不当 live。
- E0 dirty 916/2154 行仍在；新增仅 E0/E1 证据与 AUTH 共 4+3 个 untracked 文档，无 Keyboard/Packages/pbx 路径变化。

## 预算锚点

- 首 E1 `tool_started`：2026-10-06T04:02:52.798Z `read_file`（授权交接包）。
- ACK 主机核验后调用见 run-root `e1-call-ledger.json`。
- 新预算 48／3600s；第 36 次前停止新增非清理；至少留 12 清理。

下一步：Human 确认上轮后是否重装/部署，并关闭 Maps/主 App、回主屏收起键盘、两诊断保持关闭。齐后再只读核设备与进程。
