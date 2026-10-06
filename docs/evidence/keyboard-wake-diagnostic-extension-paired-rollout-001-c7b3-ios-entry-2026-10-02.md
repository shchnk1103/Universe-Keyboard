# C7-B3 actual iOS Entry

Human 本轮明确确认指定模拟器独占，并追加最小 Architecture R3；原 C7-B3 授权继续覆盖实际三套 iOS 验证。原 Draft/R2 Partial 与缺失旧账不改写。批准 R3 packet digest `4e9b7ea1d3ca82bce65438c52756562da1094687d2219c86324c4819f0b06058`，复用独立 Luna。

设备为 iPhone 18 Pro / iOS 27.0，UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`，MCP discovery Booted。只使用此设备；不 Maps、arm、LLDB、输入或完整生产部署。shared MCP 原 active profile 是其他任务，另建本任务 nonpersistent profile。

主机只读查询安装 App/appex 均 1.0/build1；当前 executable SHA 分别 `a9d2535534d92f804b9a3630a5c978ec24c65119afe4778d7db61812c1a2c6d2`、`3a1c3ff7454be12c45c58866bb801917644c68af1f986cd7918663e3022f4cc7`。111 文件安装包逐字节备份到 `/private/tmp/ukey-wake-c7b3-20261002/current-round/InstalledRestore/Universe Keyboard.app`，双 bundle codesign verify strict exit0。该备份是恢复来源，不把新 host candidate 视为已安装。

App Group groups query 与容器 metadata 对齐。内容无关 preferences：logging_enabled 存在且 false；diagnostics_high_fidelity_expiration 不存在；六类日志键不存在；rime_deployed=true、rime_needs_deploy=false、rime_deploying=false、auto_retry_suppressed=false。Rime/shared、Rime/user、Rime/user/build 存在。先前误查 Rime/build 与 rime_deploy_in_progress 不能作为失败证据，保留原 bounded 记录并补对正确源码键/路径。

实际 App tests 使用 TEST_HOST，会安装替换主 App；结束后使用原 bundle 备份恢复并逐字节验证。ContentView XCTestConfigurationFilePath 分支跳过首次 seed/deploy；生产 App init 仍会初始化诊断根/retention，不能声称零副作用。测试 fixture 使用 temporary root/UUID suites，runtime fullCheck 是 temporary fixture 部署，不是生产 App Group 完整部署；Keychain unique account finally cleanup。只核对内容无关配置和文件 hash，不读取输入/词典/日志正文。前后状态若异常，停止依赖动作交回。

Entry Ready for sequential RimeBridgeTests、App+Keyboard unsigned、signed unique Keychain test；strict Swift6 complete/warnings-as-errors、禁止 package 更新、专用 DerivedData/xcresult、显式 exact UDID，禁并行 clone。新 skips 按实际 skipped 记录，旧30项接受不继承本轮。不重复有效1194 Core或源码字节等价的普通编译，不改源码/格式/Git发布。证据 scratch current-round installed-entry.json、installed-backup-manifest.json、installed-container-paths.json、before-files.json、before-status.z。
