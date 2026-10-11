# T0 当前基线恢复方案（Prepared，未执行）

适用于原iPhone 18 Pro/iOS27.0、UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`。执行前需对应T2恢复/必要重安装授权及持续独占；当前T0仅准备。备份位于 `/private/tmp/ukey-wake-ui-t0-20261003/backup`；三个子目录main-data、app-group、installed-app。完整private before/after/backup inventory保留内容SHA、目录结构、模式/owner/xattr哈希及符号链接目标；raw用户数据不进入repo。目录必须留存，不视临时目录为永久归档；测试前再次核其存在及hash。

1. 先保全测试结果和测试后当前容器清单，核App/appex均退出。重新用指定UDID及bundleID发现app/data/groups；旧UUID路径不得当新路径使用。独占、身份或backup漂移即停止。
2. 对比已安装App与备份78文件及双签名；若测试已替换且授权恢复安装，使用精确备份 `installed-app` 执行 `simctl install`，不uninstall、不构建、不部署。安装后再次发现容器并核完整payload，必须恢复旧C7候选 `ddd5579ee6dce39deea3c63487cfe6817c419628c4471c0b3e9298d9c47f3ca9`，不是新UI候选 `43d85d…`。安装本身未在T0实测，可恢复性仅由备份完整性和双签名支持，不能声称实际恢复成功。
3. main-data与App Group按新路径逐项映射恢复应用数据，保留新容器的根身份xattrs、`.com.apple.mobile_container_manager.metadata.plist`及系统容器登记；不要把旧容器UUID/系统metadata整目录覆盖到新容器。备份所有原文件均保留，恢复时系统metadata与SplashBoard路径变化需单独分类，禁止把未恢复项隐去。系统更名若不能按内容对应核清则Hold，不猜删。
4. 恢复前列出新容器中多出的文件及每项拟覆盖/移除/恢复动作；这些可能破坏测试后数据，须先保全且纳入恢复授权。没有授权时不删除任何文件。恢复内容时保留原文件模式/owner、原xattrs和两个内部符号链接；副本额外`com.apple.provenance`不得当作源原属性，记录原/恢复后属性差异。T0尝试清除副本该属性后readback仍存在，因此不可声称完全metadata等同；若出现其它内容或权限属性差异则停止。
5. 恢复后重新读取新容器并对照备份逐字节及结构/链接核验，单独列系统身份例外；核诊断`logging_enabled`及`diagnostics_high_fidelity_expiration`恢复为**原键不存在**，不以写false替代。部署原键应为deployed=true、needs=false、deploying=false。不要为了“健康”自动重新部署RIME。
6. 机器数据核验通过后，按另获的启动/人工验证授权检查主App部署状态、完全访问及候选/提交。未做人工验证前只有静态数据恢复意见，不能声明键盘运行健康。若无法恢复，保留全部备份和测试后状态，停止安装新候选或进一步取证。

本方案不备份整个模拟器、系统键盘设置或系统Keychain。签名Keychain专项仅允许测试自有唯一UUID项及自身清理，不能扩成清理现有Keychain。新测试有skip仍按实际记录，由Product另作当前阶段处置；旧残项accept不继承。T0不恢复历史已损失的日志或词典；当前完整备份只保护现在的基线。
