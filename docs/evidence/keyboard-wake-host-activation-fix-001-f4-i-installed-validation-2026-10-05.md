# F4-I 精确诊断pair安装／机器读回完成 — 2026-10-05

**新before保护＋精确候选安装＋机器读回通过；尚未启动App，正常输入健康待Human。** Human已授同F4-I并批准主机工具首次失败后的恢复执行，再仅本次接受883处副本provenance新增（0改写/其他差异0）；[决定](../product-decisions/KEYBOARD-WAKE-HOST-ACTIVATION-FIX-001-f4-i-provenance-accepted-2026-10-05.json)绑定原件。原始backup receipt install_allowed=false历史字段不改，通过单独接受sidecar落实本次许可。

新before /private/tmp/ukey-host-activation-fix-f4-before-20261005 的完整installed-app/main-data/Group三live读、两copy读已通过，源字节稳定，签名有效，约124.2MiB。安装前再读live/backup全清单，1156冻结source/App/Vendor行、13pins及78candidate字节保持，target进程为空。[原安装request](keyboard-wake-host-activation-fix-001-f4-i-artifacts/install-request.json)仅xcrun simctl install原UDID405D994F-28CB-4F89-BB22-B64AD81C05A2，不uninstall、重建、部署或启动。

[命令receipt](keyboard-wake-host-activation-fix-001-f4-i-artifacts/install-command-receipt.json)exit0，stdout/stderr为空。[postinstall receipt](keyboard-wake-host-activation-fix-001-f4-i-artifacts/postinstall-receipt.json)78payload路径/bytes/SHA与冻结pair完全相等，摘要d53523dba8c371c67424ff07c79163a66f41e3bc5bb402637cf9ee79ae7579cb；两级codesign deep/strict有效，四模块UUID依次664DE45A…、C19CE509…、CD0C6F02…、4B207746…，全文/精确路径已记录。Group精确映射同gid且返回唯一组，installed字节相同支持复用该pair已核embedded Simulator entitlement，不假称新的runtime FullAccess证据。

新main-data/Group两次全清单读回稳定，无未解释的应用数据差量；安装创建的容器metadata/SplashBoard保留实际新系统身份，不覆盖旧UUID。[实际恢复准备](keyboard-wake-host-activation-fix-001-f4-i-artifacts/restore-plan-after-install.json)绑定before/after路径、原安装与实际差量，恢复执行未授。诊断logging/high-fidelity/display键仍ABSENT；RIME deployed=true、needs_deploy=false、deploying=false，无自动再部署。

## 已授权的剩余人工健康步骤

1. 开启原模拟器的Universe Keyboard主App，进入搜索Tab并点击搜索框。
2. 叫出Universe Keyboard，确认完全访问仍开，两项诊断保持关闭；不点观测/取证、不重新部署、不去Maps。
3. 只输入合成ni，观察候选，再点击一项候选提交，确认主App搜索框出现提交文字。
4. 回复“完全访问开；两项诊断关闭；候选正常；提交正常”，或指出异常。若提示部署/异常，停止，不自动部署或盲试。

[root真实账本](keyboard-wake-host-activation-fix-001-f4-i-artifacts/installed-root-usage.json)累计39/60actualcalls，沿原保守90分钟锚点，不重置。现阶段无LLDB/Maps/arm/freeze取证；Human正常健康不能代F4-M真实通知/恢复运行证据。新旧备份保留，本轮不删。整体修复未Completed，未Release/真机/Git发布，无CHANGELOG/ADR修改。
