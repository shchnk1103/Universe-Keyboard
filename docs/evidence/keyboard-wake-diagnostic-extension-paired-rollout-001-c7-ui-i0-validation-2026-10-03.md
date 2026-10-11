# I0 安装前保护交付

## Scope / Authority / Exit

Human授权继续I0，并确认原模拟器本轮核验/备份独占；主App现已关闭。对精确旧appex PID45871另授权仅一次正常SIGTERM，发送前路径/Executable SHA再次核实，正常退出；主App/appex均缺席，无SIGKILL/restart/install。

**I0新鲜完整备份与恢复方案准备完成；I1候选安装Prepared，未执行。**

## Evidence

main827files/42dirs、Group53files/15dirs/2links、旧C778files/9dirs。三次源库存相等、容器身份稳定、进程缺席；副本bytes/structure/mode/owner/原xattrs吻合，新增provenance865/9/9分类保留；backup双签名通过。源原diagnostic键ABSENT/off；deployment为deployed=true、needs=false、isDeploying原ABSENT。当前Group与旧历史userdb结构不同，以本次新鲜before为恢复基线，不读词条内容。

旧安装ddd557…与新候选43d85d…分别核78file SHA与双签名，新候选未安装。Python环境无os.listxattr时在首次inventory前停止（尚未创建backup），改用原生xattr只读接口后完整流程通过，不改源。

[恢复方案](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-i0-recovery-plan-2026-10-03.md)与[单次I1安装Prepared包](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-i1-install-prepared-2026-10-03.json)具体绑定backup receipt及精确candidate/install argv，不启动、不部署、不输入/观测/LLDB/Maps；发现数据差异先保全after并停止，实际恢复需新的具体清单授权。

## Old backups

旧4组T快照约499.8MiB完整保留，未覆盖/删除/移动，不含更早阶段。本次当前回退使用I0新鲜备份；历史快照保留作证据。验证后整理清理清单交Human决定，private/tmp不当长期备份。

原始用户data/Group内容及全inventory只留private；repo仅收据/脚本/有限状态证明。不包含系统Keychain/全访问等Simulator全系统设置备份。当前完全访问仅先前Human健康证据，未来正常输入须新鲜人工核验。T29接受仅当前T不外推；父子仍Active、根因未确认。无需CHANGELOG/架构合同改动，无Git/Release。
