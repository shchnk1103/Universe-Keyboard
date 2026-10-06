# F4-P 静态晋级核验收件闭合 — 2026-10-05

**Human“接受”仅接受本轮Quality原生独立判断＋实际2call账本＋root来源/哈希回执的替代收件，明确保留300秒合规UNKNOWN。** [Product决定](../product-decisions/KEYBOARD-WAKE-HOST-ACTIVATION-FIX-001-f4-p-quality-native-receipt-accepted-2026-10-05.json)绑定原文hash。原作者文件缺失/Partial/权限失败、旧报告及所有备份保持，不倒改为正常writer交付；不继承至下一阶段。

Architecture R3 A-P1/A-P2/A-P3 Covered且有界替代收件已接受；Quality旧Q-P4、R3 Q-P2/Q-P3及[新独立R5 Q-P1四路径](keyboard-wake-host-activation-fix-001-f4-p-promotion-r5-validation-2026-10-05.md)Covered，本次静态诊断pair/flags资格判断及正式收件依赖闭合，不再重复四记录技术审查。普通A2矩阵只覆盖其原source/gate/flags，不能代诊断UI/probe运行；30skip仍未验证不计通过，非Release。

## F4-I 当前准备状态

Prepared，未Ready／未授权执行。只接下述已有[F4 Entry](keyboard-wake-host-activation-fix-001-f4-prepared-entry-2026-10-05.md)安装阶段，替代其中历史“产物尚不存在/审查未满足”事实；其他备份恢复/停止合同保持。

- 唯一目标：iPhone18Pro／iOS27.0，UDID405D994F-28CB-4F89-BB22-B64AD81C05A2。新鲜独占、Booted、App/扩展静默、上轮后打开/安装/部署情况仍待Human和机器Entry，不复用旧PID。
- 唯一候选：[F4-P冻结配对](keyboard-wake-host-activation-fix-001-f4-p-validation-2026-10-05.md)，路径 /private/tmp/ukey-host-activation-fix-f4-p-build-20261005/CandidateDerivedData/Build/Products/Debug-iphonesimulator/Universe Keyboard.app；78文件／91448700bytes，摘要d53523dba8c371c67424ff07c79163a66f41e3bc5bb402637cf9ee79ae7579cb，四模块UUID与SHA按原pair清单。不使用普通A2或旧C7替代。
- 未来明确授权范围建议：先只读设备/精确进程身份，静默完整新before（installed-app/main-data/Group，存在性/权限/xattr/内部links），两次读回保护；再仅精确pair安装及postinstall字节/UUID/签名/Group/部署状态核验；最后Human正常输入候选/提交健康，不arm、不Maps、不LLDB。
- 提案预算仅F4-I新60actualcalls／90分钟，计wrapper及nested，首失败/身份或非批准差异停止，不自动续。此为Prepared提案，不继承F4-P预算、不自动启动。
- 残留扩展进程正常SIGTERM、provenance副本例外等按实测缺口另决定，旧授权不自动继承。完整before保护不满足则不安装；不uninstall/自动部署。安装后恢复如需要，绑定实际差量再授权。
- 历史备份当前保留，F4-I/E实际完成后再列可去重/删除候选给Human决定；本轮不删或重复复制大安装包。

本次root已重新核1156冻结source/App/Vendor、13pins及78payload逐字节符合，branch/HEAD/staged0符合；仅治理收件更新，无源码/编译/测试/设备/备份/安装/LLDB/Maps/Git发布。整体运行修复仍待F4-I/M/E，未Completed。无CHANGELOG/ADR修改。
