# 清单内旧 C7 / 数据恢复交付（机器读回通过，运行健康待核）

Human明确授权清单内旧C7安装包及数据恢复，沿[Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t2-restore-entry-2026-10-03.md)、[清单](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t1t2-artifacts/T2-proposed-restoration.json)与[T0恢复方案](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t0-recovery-plan-2026-10-03.md)。本轮**授权恢复及机器读回已完成**，不等于实际输入健康、T1全部完成、Quality/Product Gate或新candidate晋级；父子Assignment继续Active。

## 实际恢复和核验

执行前原设备Booted/独占连续窗口、App及appex缺席；T0三个完整backup和完整test-after保全均无漂移，原branch/HEAD/source571/Vendor630一致。private旧App安装副本78文件与backup相同、双签名有效。MCP install接口无显式设备参数而current profile属于其它任务，为维持精确原UDID采用已列`simctl install`工具fallback，未修改共享defaults。一次install exit0，不uninstall/build/redeploy/launch。

安装后重新定位main/AppGroup/App；78旧payload匹配，Group重新注册；除已分类systemmetadata/rootUUID与等价系统快照更名外，main未发生未列应用变化。之后117个记录动作：main覆盖4项应用文件，移除46个已保全test-added应用路径；Group恢复51个应用普通文件、14个非根目录、2个内部符号链接；新的Group系统metadata文件及root身份保留，不复制旧UUID。见[逐项动作](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t2-restore-artifacts/restoration-actions.json)。移除只针对批准清单，空目录用rmdir，无递归扩大。

[完整机器读回](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t2-restore-artifacts/restore-verification.json)两次稳定：main827普通文件/42目录，group52普通文件/15目录/2链接（52含新系统metadata），app78文件/9目录。应用自有内容/结构/链接/模式owner及原xattrs与T0一致；systemmetadata及root身份与本次postinstall相同，系统快照SHA多重集与T0一致。旧C7 payload完整SHA对应ddd557…，app/appex codesign deep/strict均通过；不是43d85d…新UI候选安装。

当前45项恢复/安装附加com.apple.provenance已分类，比较保留原属性，仅忽略原不存在的该已知附加key；不宣称全部metadata精确相同，也不清除系统身份。备份初始921附加属性差异、T0工具失败及旧停止历史保留。最终诊断logging_enabled和high_fidelity_expiration仍**原缺键**，默认off；部署deployed=true/needs=false/deploying=false为plist有限状态。未为健康重新部署，未触及系统Keychain或其它任务设备。

## 当前剩余边界

[T1/T2原交付](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-t1t2-validation-2026-10-03.md)仍是历史Partial/Hold：两实际套件无失败但30skip未验证，Keychain专项未执行。当前仅修复机器数据/安装基线缺口；原运行健康未知、未独立验收，不将恢复读回当测试成功补证。下一建议正常基线健康核验（本次补归档后继续验证的当前Human授权已覆盖；执行前核当前独占/设备状态）（启动旧App、只确认完全访问与候选/提交，诊断保持关闭）；之后才讨论未执行Keychain的最小继续Entry及测试前新鲜备份保护。无需重复已成功两套或历史发现数差额。

所有T0和test-after完整raw数据、最终full inventories留private目录：`/private/tmp/ukey-wake-ui-t0-20261003/backup`、`/private/tmp/ukey-wake-ui-t1-execution-20261003/test-after-preservation`、`/private/tmp/ukey-wake-ui-t2-restore-20261003`；repo仅归档无内容receipt/动作。无新源码、test/输入/Maps/LLDB/Git发布/Release或CHANGELOG/架构合同变更；原历史丢失数据不由本次当前基线恢复消除。
