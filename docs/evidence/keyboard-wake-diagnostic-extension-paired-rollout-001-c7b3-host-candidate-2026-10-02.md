# C7-B3 standalone host候选编译 / 身份

当前专用Debug generic Simulator SDK standalone build成功（Swift6 complete/warnings-as-errors、arm64、adhoc签名），独立CandidateDerivedData，无任何Simulator启动/安装/运行。先前沙箱attempt exit74因SwiftPM缓存权限/XPC限制，未编译源码；原日志/命令/result保留，主机同候选仅换result路径重试exit0，26.934秒。没有clear/reset/依赖fetch或源码改动。

新571source/build+630Vendor清单仅T9已验收单行测试与旧不同，产品输入不变；当前ten-file identity3c45e4d...，build候选digest `ddd5579ee6dce39deea3c63487cfe6817c419628c4471c0b3e9298d9c47f3ca9`。final dedicated App含Keyboard.appex，78文件，无.xctest host；payload digest `5a935a0e648fd8939b1e56b4e40f5da24828a0f2e6bfe9e6365b98ca3a2a80e4`。App/appex为1.0/build1，Info/executable/Mach-O/hash/UUID/dSYM及出口符号见[products](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-artifacts/paired-products.json)。两bundle codesign verify deep/strict exit0；仍未installed或runtime验证。

普通codesign entitlement为空，不能当AppGroup缺失。逐final thin arm64 Mach-O定位LC_SEGMENT_64->__TEXT,__entitlements按offset/size提取，与生成Simulated.xcent完全一致，均包含group.com.DoubleShy0N.Universe-Keyboard和各自application-identifier。见[entitlement证据](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-artifacts/simulator-entitlements.json)。这只证明final Simulator artifact声明，不证明installedcontainer/实际访问/Keychain通过。

实际iOS测试尚待fresh exclusive与installed/恢复Entry，未执行。当前候选不是安装放行/整体Gate，旧整体Hold/F2/F3/57格式及30历史skip保持。准备对当前host artifact身份作两个独立定点补审，不重审产品逻辑或冒充实际suite。原Architecture/Quality runtime复用；stable ARCH-C7-B1 round2、QUALITY-C7-B1 round3，新exact基线及预算；Human继续推进建议授权此必要candidate核验，各12calls/600秒hard、420soft、call4checkpoint，只有Human可扩scope/预算，无自动续轮。
