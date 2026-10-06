# T0 只读身份、完整备份与恢复方案交付

Human明确授权T0并确认本轮原模拟器独占。初次核验主App/appex运行，暂停复制；Human手动关闭后只剩PID24050，另获“仅正常终止已核实扩展”授权，核精确路径后一次SIGTERM退出，无强制终止、重启或启动。见[回执](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t0-artifacts/authorized-appex-termination.json)。沿[T Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t-entry-2026-10-03.md)执行，root唯一repo writer。

MCP只读确认iPhone18Pro/iOS27.0/原UDID Booted；sandbox simctl服务访问阻断，按已授权scope使用主机只读simctl定位当前容器及ps核进程。没有boot/launch/install/test/deploy/LLDB/UI/input或诊断修改。

[完整备份 receipt](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t0-artifacts/backup-receipt.json)：main-data827文件/42目录；AppGroup52普通文件/15目录/2内部符号链接；installedApp78文件/9目录。raw全部保存private scratch `/private/tmp/ukey-wake-ui-t0-20261003/backup`，repo不含raw用户内容。source before/after一致；副本文件字节、目录结构、模式/owner及原xattrs一致，两内部链接保留。已安装payload canonicalSHA匹配历史C7 `5a935a0e648fd8939b1e56b4e40f5da24828a0f2e6bfe9e6365b98ca3a2a80e4`，备份App/appex codesign deep/strict均exit0，version1.0/build1配对；**不是新UI候选43d85d…已安装**。

首次Python缺os.listxattr在复制前停止，改系统只读xattr接口；首次完整比对因副本新增com.apple.provenance停止，原源稳定。仅对private副本清除921项新增属性，readback仍出现同类属性；之后逐项分类确认无其它差异。保留初始失败inventory与后续receipt，不追认全部metadata完全相同。见[分类](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t0-artifacts/metadata-classification.json)。无源文件属性修改。

原诊断logging_enabled/diagnostics_high_fidelity_expiration均缺键、默认关闭；deployed=true/needs=false/deploying=false是当前plist有限状态，不是本轮启动或输入健康验证。恢复必须保留原缺键，不写false冒充。完整恢复方案已[准备](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t0-recovery-plan-2026-10-03.md)：安装身份及新旧容器映射、系统metadata例外、内容/属性/链接readback、异常停止、必要Human健康核验。**未实装恢复、未验证运行健康，系统Keychain/整个模拟器未备份。** 原历史AppGroup数据损失不被当前备份掩盖。

T0获授权工作已交付，当前完整内容备份和可审查恢复方案具备；T1仍未授权/未执行，进入测试前须再次确认独占、源/工具链及备份未漂移，冻结实际命令并明确T2必要恢复副作用授权。副本provenance差异不得隐藏，若后续独立验收要求全部xattrs精确相同则不能据此放行。新实际skip需Product当前阶段处置，旧30skip仍未验证；不重跑历史发现数差额。父子Assignment Active，无整体Gate/Release/Git发布/CHANGELOG或架构合同变更。
