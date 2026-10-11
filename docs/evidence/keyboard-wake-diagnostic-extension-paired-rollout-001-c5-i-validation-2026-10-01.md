# C5-I 一次配对安装核验 — 2026-10-01

## Outcome / Scope / Authority

**一次配对安装及安装身份核验通过；运行前置条件仍有宿主差异，C5-I runtime Exit 暂为 Hold，C5-R 未执行／未授权。** Human授权继续已提出的C5-I，并确认先前精确模拟器仍独占；[Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-i-entry-2026-10-01.md)在安装前绑定源码/产物、阶段决定和权限。root sole repo writer / Environment Executor，未新增subagent或review预算。

## Installed pairing evidence

- worktree `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`；branch `codex/keyboard-wake-v3-compatibility-gate`；HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`。
- candidate `af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9`；568source/build和111留存Debug文件匹配，复用原Debug产物，无build/resign。
- 精确target iPhone18Pro/iOS27.0，UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`；Booted/available，无boot/reset/erase/设备切换。
- XcodeBuildMCP `install_app_sim`执行**1次**，源为 `/private/tmp/ukey-wake-c4-20261001/DerivedData/Build/Products/Debug-iphonesimulator/Universe Keyboard.app`，embedded `PlugIns/Keyboard.appex`随App安装，无独立appex安装。
- 实际安装根：`/Users/doubleshy0n/Library/Developer/CoreSimulator/Devices/405D994F-28CB-4F89-BB22-B64AD81C05A2/data/Containers/Bundle/Application/1C8EAA6A-D18A-4684-B4E4-95252930B447/Universe Keyboard.app`。
- **111/111实际文件SHA与原bundle一致，无缺失/新增/变化；11/11Mach-O SHA/size/UUID一致**，包括两个业务debugdylib、stubs、preview及framework；App/appex ID分别 `com.DoubleShy0N.Universe-Keyboard` / `com.DoubleShy0N.Universe-Keyboard.Keyboard`，两端version1.0/build1一致。

[完整安装核验](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-i-installed-payload-verification.json)、[安装／启动／profile副作用账本](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-i-tool-actions-receipt.json)。沙箱simctl查询出现CoreSimulator连接失败；主机只读同UDID `get_app_container ... app`成功，未因此重装或改变设备；不是设备异常结论。

## Readiness / Human observations / Privacy

MainApp启动成功（PID79420）；语义UI显示资源已就绪，AppGroup窄读`rime_deployed=true`，既有Rime/shared和Rime/user资源存在。系统AppleKeyboards列表含目标Extension。**这些不能替代实际appex运行/共享访问/RIME session成功证明。**

Human在Mac前参与两项只看不改确认，并回复：“完全访问已开启，搜索框是在‘搜索’Tab页中，而不是在本地词典中。”FullAccess是Human在系统设置的本轮观察，不是App启用清单或历史记忆推断。没有更改系统keyboard或FullAccess。自动导航曾有snapshot settle超时，按提示重新snapshot；打开精确Simulator前端及刷新后MainApp导航可用，不能以此前导航未变化推断产品缺陷。

[机器／Human前置条件及窄读源证据](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-i-machine-human-readiness.json)。原计划本地词典宿主的search field在自动语义观察和Human观察中均未得到正向确认；源码仍有`.searchable`，两者并不互相推翻，未诊断其不可见根因。Human报告现有SearchTab存在可见试用输入框，与原review host不同；没有点击/聚焦该框，没有激活appex或输入。

SearchTab既有source只读核查：`@State query`、真实TextField、SettingsSearchCatalog纯内存过滤设置项；`onAppear`调用RimeSettingsStore.load，其first-launch seed在`rime_deployed=true`时返回，否则可写deploymentintent，不能宣称任意环境零副作用。当前group该flag为true。四份相关源hash保存在readiness receipt；无源码改动，也不声称旧独立review自动覆盖新宿主。

安装前后`logging_enabled`、`diagnostics_high_fidelity_expiration`、`log_category_disp`、`log_category_engine`均保持原不存在状态；logging默认false，高保真未启用。未录屏/保存截图、输入文本、词典条目、原始prefs或完整journal。MCP launch工具自动生成runtime/OSLog文件路径，仅记录路径，不打开或归档其内容。MainApp正常启动已有后台注册/Diagnostics root/retention路径属于已披露默认副作用；任务没有手动部署、下载、改schema或清理历史。

## Installed pass vs runtime Hold

| 项目 | 结论 |
|---|---|
| 一次配对安装、实际App/appex完整载荷身份 | Pass |
| MainApp启动、界面资源已就绪、系统键盘已列入 | 本轮正向观察，有限语义 |
| FullAccess系统设置状态 | Human本轮确认已开；未切换 |
| 原本地词典host field | 未确认，Hold；不按存在源码当运行通过 |
| 拟用SearchTab host | Human观察及源核查成立；C5-R需单独批准／review重绑 |
| appex实际共享访问、RIME session、真实marker、MainApp reader本轮消费 | 未验证，归C5-R，不伪报通过 |

## 最小宿主重绑提案（未授权）

建议只将未来C5-R宿主从“本地词典”改为已有**搜索Tab → ‘任意内容：设置名或试用输入’**，保持同一已安装Debug配对/设备/三marker语义/一次轮次。由Human完成一次非敏感合成拼写及提交，root负责gate窄读、身份rebind、内容无关journal筛选、reader核验、capture键恢复；不点击搜索匹配到的设置项、不更改设置、不重建/重装、不部署、不Maps。

先做一次Quality-only只读宿主变更确认（拟预算4底层工具/300秒，第2次checkpoint，复用原reviewer），冻结新packet/来源及具体host变化，覆盖H1真实TextField与query副作用、H2capture/privacy/reader及同源证据复用、H3本轮结论及未来Entry。其余不变Architecture静态边界仍保留旧证据和流程限制，不据此声称新host已独立review通过。**该补审预算与C5-R采集都需Human另行明确授权**；不自动派发、激活键盘或输入。此前C5-only30skipaccept保持精确候选阶段边界，30项仍Skipped。

## Preservation / Handoff

[保全及完整状态凭据](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-i-final-receipt.json)。除owningAssignment bookkeeping及本轮新证据外，2527既有文件逐项不变；源/结果/旧review保留。MCP只建ephemeral profile，persistfalse，原activeprofile恢复，所有既有profile defaults不变。Human接手后暂停自动UI点击；本轮C5-I设备操作结束，不自动延续为C5-R许可。

未测试/build/source/Git publication/Release，无parent closure或总体Gate。无需CHANGELOG/架构合同修改；只记录授权、真实安装身份、有限readiness和宿主差异。
