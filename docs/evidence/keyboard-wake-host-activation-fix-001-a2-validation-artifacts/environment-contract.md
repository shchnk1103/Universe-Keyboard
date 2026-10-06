# A2 新候选验证环境合同 — Prepared only

## 身份与授权缺口

Environment Executor=root，源码writer=Grok且已停止；Product Lead=本线程Human。当前只授权准备Entry，未授权执行。

唯一destination为 `platform=iOS Simulator,id=405D994F-28CB-4F89-BB22-B64AD81C05A2`，谱系iPhone 18 Pro / iOS27.0。不使用CI默认iPhone17Pro替代，不默认继承旧独占。本轮未simctl/检查进程或live容器，实际Booted/空闲/独占均UNKNOWN；只能在执行AUTH后现场核查。原F2 Xcode27.0/Swift6.4记录是历史；执行前查询工具链并与钉死SWIFT_VERSION6.0/strict complete兼容性核对，变化即停止评估。

## 隔离与保护

未来run根 `/private/tmp/ukey-host-activation-fix-a2-validation-run-20261005`，未来backup根 `/private/tmp/ukey-host-activation-fix-a2-validation-backup-20261005`。准备时两者不存在；只在执行授权后新建。若路径被占用，不覆盖、不自动换根，停止报告。独立DerivedData及KeyboardCore --build-path；不并行测试、不开另一worker模拟器。

执行前目标App/appex必须退出且身份可核。Human关闭App；若扩展仍存活，仅精确PID/启动时间/path再次核验且获单独SIGTERM授权后，才能发送一次正常信号。不从测试授权推断kill，禁止force kill/erase/shutdown。

新鲜完整before：主App data、App Group、已安装主App与appex（按存在性保存）；0700 private目录。至少两次完整source库存稳定、复制后byte/结构/size/mode/uidgid/xattrs/内部symlink核验，记录偏好存在性与安装身份、严格签名。无外部symlink或特殊文件；缺席明确记录，不伪造目录。

本Entry默认新建完整before，不用历史备份代本轮before。历史F2/actor/M0等路径全部保留且不覆盖。曾接受的903新增/122改写provenance仅原备份有效，不能直接移植成新备份通过。若新复制发生com.apple.provenance新增/改写：分类并保存source/copy摘要，Product未明确仅本轮接受该属性例外前不得开始测试；任何其他差异必须停止。执行AUTH可以明确接受“仅新副本的provenance属性新增/改写，原live不改，其余全部一致”这一提案，实际数量仍必须如实落盘，不固定套旧数量。不声称all metadata exact。

不备份Keychain、系统键盘设置、Maps内容；签名Keychain专项是冻结唯一用例的自身状态访问，不作为系统Keychain回滚。XCTest可能安装/启动runner并改变App/data/Group，须明确纳入执行授权；不是F4候选安装/试打授权。

## 退出与恢复（仅Prepared，不执行）

成功/失败都停止后续执行，保存命令/日志/xcresult、实际方法列表、警告分类与输入hash。读回当前安装身份和三组库存两次，核对偏好存在性及目标进程，不能机器库存代输入健康。

- 若三组库存与before全等：记录无需恢复，不运行恢复动作。
- 若改变：按执行AUTH范围在新的private after-preservation目录保全三组副本、库存及安装签名，记录差异；不自动恢复。若当前进程仍活跃，只保存读回缺口并停止，不自动终止。
- 恢复方案只引用本轮完整before。另授权后才精确恢复：先核独占/live身份与after保全；必要重装before包但不uninstall/erase；应用内容及存在性按before，保留live系统MCM身份/UUID/SplashBoard，不写旧UUID；两次读回及健康确认分别记录。失败停止，不自动重试或部署。

不清理历史/本轮任何备份、DerivedData/xcresult。是否可删除须在新候选独立审查消耗证据、环境Exit明确之后，另给路径/空间/保留依赖清单，由Human决定。本准备不创建run/backup或复制live数据。

## 残项与停止

预算提案180分钟，从执行AUTH Entry第一步起，含备份、矩阵及Exit；首required命令失败/超时先到停止，不自动续预算/重跑或修改源码。

原F2接受的20Bridge+10App skipped仅F2有效。新阶段不默认迁移。可由Human在执行AUTH中狭义接受本包historical两个skip-list列出的同一30项：仅本次A2验证、仍为未验证非阻塞，不计pass、不Release。实际identity/原因变化、任一新增skip、23gate用例任一skip/fail均停止；不靠fixture/环境修改把skip“修绿”。未有这一阶段决定，实际遇到skip后停止后续job并交Product。

Quality历史超时审计F3-Q-AUDIT-001未处置。矩阵绿不解除A2-F1：还需新候选独立静态复审及Quality交付；本Entry不授权新review lane，不自动续旧F3预算，不授权F4/Maps/LLDB/Release。
