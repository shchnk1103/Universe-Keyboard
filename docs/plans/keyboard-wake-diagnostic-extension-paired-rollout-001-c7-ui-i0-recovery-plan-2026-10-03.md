# I0 当前基线恢复方案（Prepared，不执行）

范围仅为本次I0备份；与原T0、Keychain测试前和test-after快照区分。原主App健康后仍前台，Human现已关闭，root对精确旧appex PID45871获授权一次SIGTERM、重新核SHA后正常退出，未强杀/重启。

## Protected baseline

当前完整private backup `/private/tmp/ukey-wake-ui-i0-20261003/backup`，root0700；源3次与容器身份稳定，副本bytes/structure/mode/owner/原xattrs相等；新增provenance main865/Group9/app9单独分类，未声称allmetadataexact。main827/42、Group53/15+2internal symlinks、installed旧C778/9。backup主App/appex strict双签名通过。原始库存SHA与5个偏好键存在性见I0 backup-receipt。

旧C7 candidate ddd557…完整78file SHA与c7b3 paired-products吻合；新候选43d85d…尚未安装。两diagnostic keys原ABSENT/off，rime_deployed=true、rime_needs_deploy=false、rime_is_deploying原ABSENT。恢复应恢复值和原存在性，不强写false替代absent。模拟器系统键盘启用/完全访问以及Keychain未被这份App/data/group备份覆盖；保持系统设置不改，新安装后另做人工健康核验。

当前Group53file与历史恢复52file不同，只读库存差异位于Rime userdb文件结构，未读取用户词条内容、未推断损坏；这是当前新鲜基线。不得用历史52file覆盖当前53file或混淆既有未恢复历史事实。

## Conditional restoration steps

1. 安装后先重新发现精确目标容器，保存全部可访问after主App data/Group/installed App与库存；任何丢失root/进程回归/数据差异/签名或identity异常停止，不重复安装/部署来掩盖。
2. 必要时先重装本次backup中的精确旧C7 standalone，仅在Human批准的恢复切片执行。
3. 列举当前after与本次before的每条应用内容差异、需要覆盖/恢复/移除的路径；保护新容器根/系统metadata与合法新UUID，Snapshot按内容multiset分类；内部链接约束原Group，原xattrs保留、副本新增provenance单列。未列路径不改。
4. 将具体差异、可能数据损失与恢复动作交Human另行批准后再执行；本Prepared plan没有恢复授权。验证恢复身份/签名、应用数据/诊断原值存在性、部署状态；新运行健康另核，不把机器hash等同人工健康。

## Old backup retention

已登记的4组T快照（T0、unsigned test-after、新鲜Keychain before、signed test-after）约499.8MiB，不含更早阶段或本次新备份。它们分别负责历史证据/回退，不删除、覆盖或搬移。当前恢复优先本I0新鲜快照。验证完成后按仍需恢复、只作历史证据、可清理三类列清单，Human确认后再清理。raw位于private tmp，不视为长期持久备份；若需长期保留，另指定持久位置/范围，不擅自迁移用户数据。
