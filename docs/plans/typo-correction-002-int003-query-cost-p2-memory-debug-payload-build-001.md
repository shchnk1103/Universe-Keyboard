# 固定Debug opt-in产物 — Proposed / 未执行

2026-10-09T11:23:30.578517+08:00

## 精确绑定

源worktree `/Users/doubleshy0n/.codex/worktrees/int003-query-cost-memory-impl-001/Universe Keyboard`，HEAD72dd217+22候选manifest `d0e491083df08df27ff8e463ad9f4824c5d083c0804ccc0cdf9c811e23cdf4ad`。旧manifest的other20算术字段保留，以R5勘误22−1=21解释。只新增执行参数和私有输出目录，无源字节搬运或修改；不追main。当前Info/version plist显示Xcode27.0/27A266a，执行Entry须只读对比同工具链及现有Vendorreceipt，不跑version/settings/help/compiler探针。

[机器绑定](../evidence/typo-correction-002-int003-query-cost-p2-memory-debug-payload-build-001-proposed-binding.json)，SHA `6f092894ac1182ba195f9fc61d611c86ebd5ed7b0805ffa4901c18367577653e`。历史成功命令采用target-only/SDK/INDEX_DATA_STORE_DIR设置；本轮追加已验证opt-in Swift/ObjC参数，在新产物实际验证传播，不能仅凭命令参数宣称成功。

## 待Human释放/消费的唯一编译

```sh
env DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer TMPDIR=/private/tmp/universe-keyboard-int003-p2-memory-debug-payload-build-001/tmp SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/universe-keyboard-int003-p2-memory-debug-payload-build-001/Caches/SwiftPMManifestModuleCache CLANG_MODULE_CACHE_PATH=/private/tmp/universe-keyboard-int003-p2-memory-debug-payload-build-001/Caches/ClangModuleCache.noindex /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -project 'Universe Keyboard.xcodeproj' -target 'Universe Keyboard' -configuration Debug -sdk iphonesimulator -packageCachePath /private/tmp/universe-keyboard-int003-p2-memory-debug-payload-build-001/PackageCache -clonedSourcePackagesDirPath /private/tmp/universe-keyboard-int003-p2-memory-debug-payload-build-001/SourcePackages -resultBundlePath /private/tmp/universe-keyboard-int003-p2-memory-debug-payload-build-001/Results/TargetBuild.xcresult -disableAutomaticPackageResolution -skipPackageUpdates build ARCHS=arm64 ONLY_ACTIVE_ARCH=YES BUILD_DIR=/private/tmp/universe-keyboard-int003-p2-memory-debug-payload-build-001/Build SYMROOT=/private/tmp/universe-keyboard-int003-p2-memory-debug-payload-build-001/Build/Products OBJROOT=/private/tmp/universe-keyboard-int003-p2-memory-debug-payload-build-001/Build/Intermediates.noindex CONFIGURATION_BUILD_DIR=/private/tmp/universe-keyboard-int003-p2-memory-debug-payload-build-001/Build/Products/Debug-iphonesimulator CLANG_MODULE_CACHE_PATH=/private/tmp/universe-keyboard-int003-p2-memory-debug-payload-build-001/Caches/ClangModuleCache.noindex SWIFT_MODULE_CACHE_PATH=/private/tmp/universe-keyboard-int003-p2-memory-debug-payload-build-001/Caches/SwiftModuleCache.noindex INDEX_DATA_STORE_DIR=/private/tmp/universe-keyboard-int003-p2-memory-debug-payload-build-001/Build/Index.noindex/DataStore DSTROOT=/private/tmp/universe-keyboard-int003-p2-memory-debug-payload-build-001/InstallRoot CODE_SIGNING_ALLOWED=YES CODE_SIGN_IDENTITY=- SWIFT_VERSION=6.0 SWIFT_STRICT_CONCURRENCY=complete SWIFT_SUPPRESS_WARNINGS=NO SWIFT_TREAT_WARNINGS_AS_ERRORS=YES QUERY_COST_PROBE_CONDITIONS=KEYBOARD_QUERY_COST_PROBE 'OTHER_SWIFT_FLAGS=$(inherited) -DKEYBOARD_QUERY_COST_PROBE' 'OTHER_CFLAGS=$(inherited) -DDEBUG=1'
```

UTF8加末尾换行SHA `7e61048216219742b7fb6f243c9ce064495514451307e810d5229f0136db49fc`。工作目录如上。最多一次spawn/600秒，失败启动同样耗尽；没有前置showBuildSettings、version或test，也没有scheme/destination/derivedDataPath。SDK编译不选择或操作具体模拟器。允许后续wait/log监测同一次进程，不当作新编译；600秒只终止本次自有进程。必须新执行AUTHLive→消费后才创建输出root/必要目录及spawn。当前root不存在，未创建/未编译。

## 运行权限与副作用

准备AUTH不授权此命令。执行前Human须另行释放/允许消费，并接受同账户工具自动缓存/临时原子rename/unlink/安全链接、SwiftPM缓存DB及伴随文件、Xcode模块/SDK/PCH/plugin与默认诊断日志维护；不包外层sandbox-exec、不换账户、不手动清缓存、不改全局Xcode/其他线程状态。无fetch/update授权；skipPackageUpdates等不等于网络防火墙，观察到下载/更新即停。固定env/argv有$(inherited)字面量，必须structured argv/subprocess传递，不用shell展开或eval。日志、Results、Build、Index、Caches、InstallRoot均独立；系统工具自动缓存可能在root之外，不称全部写入受限于root。

## 成功后只读产物检查

仅exit0/BUILD SUCCEEDED后读取 `<root>/Build/Products/Debug-iphonesimulator/Universe Keyboard.app` 和其实际 `PlugIns/Keyboard.appex`。应用主可执行/真实debugdylib等每个MachO都记录SHA/size/LC_UUID、arm64/iOS Simulator平台、Info.plist/Bundles、signature验证及entitlements/Simulator __entitlements与AppGroup。不接受未嵌入的单独appex代表App安装包；不只检查launcher stub，Debug可能有debugdylib。

解析本次SwiftDriver/ObjCresponse真实tokens：Extension及KeyboardCore必须有DEBUG+KEYBOARD_QUERY_COST_PROBE；ObjCgetter实际有DEBUG=1；非测试产物不得有KEYBOARD_QUERY_COST_PROBE_TESTING。查询成本exportReady符号须在实际embeddedExtension代码image中存在；只核对明确test-only注入接口不得进产物，不能把Core内部synthetic工厂符号一概误判成注入。R4/R5及过去Debug-off/Release隔离证据只在各自未变内容/flags/环境范围复用，不声称这次新跑了Release或CI。

readout工具允许/usr/bin/file,lipo,otool,nm,codesign只读verify/display；payloadmanifest列表推导计数、hash只扫描本次产品树。记录symlink/类型，异常link或外部目标停止，禁止越界inventory。build日志定位失败一次、xcresulttool本次bundle诊断一次；失败产品不冒充成功候选。验证/符号/flag/签名缺失即Blocked/Partial，无修源/重新签名/编译重试/测试/install/launch/LLDB权限。

## 下游

本轮只是可安装候选绑定（Executor-recorded），不是RunReady/Capture。安装/零输入transport/观察者预检分别另AUTH及当时设备确认。零输入检查还依赖已存在luna correction session；新进程通常首次query才创建，不能通过getter创建或为补证据偷偷查询。需Human另批准一次测量外正常输入暖机，或者保持该阶段Blocked；不改源绕过。当前只Proposed，AUTH未Live/未消费；父Active。


## 实际执行状态覆盖提案状态

2026-10-09T13:05:35.442324+08:00：Human继续已释放/消费本执行AUTH；唯一buildexit0/32.83秒，随后readout脚本TypeError停止。当前Blocked，AUTH耗尽，旧Proposed文字仅保留提案历史。需要新最小恢复AUTH，不重build。[证据](../evidence/typo-correction-002-int003-query-cost-p2-memory-debug-payload-build-001.md)。
