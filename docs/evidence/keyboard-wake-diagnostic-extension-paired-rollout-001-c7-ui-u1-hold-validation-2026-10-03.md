# U1 pre-arm 停止交付 — 2026-10-03

状态：Hold，未arm、freeze、输入或导出。Human已授权单轮U1并确认独占/完全访问/当前正常空栏/未点击观测。fresh原iPhone18Pro/iOS27.0 UDID405D994F…、候选43d85d…、78payload、1279source输入与精确PID80843验证通过。

## 身份冲突与及时清理

MCP调用debug_attach_sim(pid80843, continueOnAttach=false, makeCurrent=false)返回session363a2807…，PID正确，但artifacts.simulatorId为884CAC1A…，与原设备不同。未设置断点、未读取模块/内存，即按停止条件continue同session、detach同session，均成功。原PID80843随后stat Ss、同可执行路径，不在调试暂停态；78SHA仍匹配、两诊断键ABSENT/off保持。机器运行状态不冒充Human交互健康。

3次debug底层调用的原始回执、root request/response UTC与Python writer monotonic时间边界实时写入，调用账本完整；0arm/0freeze/0memory read/0breakpoint。完整before dirty/3145文件hash及raw保留private /private/tmp/ukey-wake-ui-u1-execution-20261003。无kill/relaunch/install/deploy/data restore，历史备份未删。

## 只读工具核查

session_show_defaults确认当前其他任务profile中的simulatorId正是884CAC1A…，本任务未改defaults。[缓存源码分析](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1-artifacts/tool-routing-analysis.json)：公开schema隐藏simulatorId；executor从defaults确定UDID，但将显式PID传入manager，DAP忽略simulatorId并以PID attach。该机制支持“标签来自共享defaults”解释，不能假装实际加载模块已核验或已证明运行server恰为缓存版本。原冲突回执保留不改。

## 下一步范围建议

[最小绑定补正建议](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1-binding-amendment-prepared-2026-10-03.md)待Human决定：保留工具UDID标签冲突，以fresh原设备安装路径/精确PID/执行文件SHA加本session实际loaded模块路径+UUID核验实际目标；全程显式session，不改共享defaults、不使用simulatorId session lookup。匹配后才单轮arm，任何实际路径/UUID错配就cleanup停。当前未再次attach；不会把首次回执改成通过。

U1整体未完成，无采集结果或根因/Maps/Gate/Release结论；父子Active。仅docs/证据，跳过xcodebuild，无产品源码/CHANGELOG/架构合同修改。
