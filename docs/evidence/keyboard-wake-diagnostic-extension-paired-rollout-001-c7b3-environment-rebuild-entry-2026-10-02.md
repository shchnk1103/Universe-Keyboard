# C7-B3 环境重建 Entry（新基线，非旧数据恢复）

Human 确认上一轮结束后未打开Universe Keyboard、未重新部署或安装；随后明确“授权此环境重建切片，并确认独占”。root Coordinator/Environment Executor唯一repo writer，Human负责必要主App页面操作和正常输入反馈；本切片不新增独立review lane，原Architecture R3 Partial/旧finding保留。

只读恢复来源核验本任务ukey-wake历史scratch1712文件，没有完整容器备份。旧72路径中9项只是空字节匹配，非空文件恢复来源0；这不是全机/TimeMachine无备份的证明。当前只重建新基线，不称旧词典或日志恢复。

固定branch codex/keyboard-wake-v3-compatibility-gate，HEAD84b9c19227330b0fe6ff391be001ee398010fd6a。原模拟器iPhone18Pro/iOS27.0，UDID405D994F-28CB-4F89-BB22-B64AD81C05A2，MCP Booted；安装111文件逐字节匹配事前原App/appex。

任何启动前完整复制当前MainApp data827文件与AppGroup4文件，均逐字节验证，private scratch `/private/tmp/ukey-wake-recovery-readonly-20261002/PreRebuildBackup`，相关manifest/rebuild-entry.json同级。备份内容不进入repo，不展示用户内容。此备份仅保护当前残存状态，不代替丢失旧数据。Entry Ready仅本切片。

执行只启动已恢复App，从MainApp正常路径部署RIME；不build/install/test、新candidate、Maps异常、arm或LLDB。核键盘添加/完全访问/正常输入，保持两项诊断关闭；页面或部署有错误即停，不自动重试。Exit要求新部署健康、原安装身份不漂移、诊断值/存在性、人类正常输入反馈与新baseline；旧环境恢复Hold历史不改写，不自动Gate/晋级。授权内阶段同步不触发M-02。

## 已执行 checkpoint（尚未 Exit）

[启动回执](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-environment-rebuild-artifacts/launch-result.json)：原App PID19680启动成功；未重新构建或安装。主App自动完成首次资源准备/部署，无需手动再次部署。[机器状态](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-environment-rebuild-artifacts/after-launch-status.json)：rime_deployed=true、needs_deploy=false、deploying=false、auto_retry_suppressed=false，Rime/user/build存在；logging_enabled与高保真expiry均不存在，按默认关闭读取。UI资源已就绪，完全访问/键盘添加的App内确认不是系统实时证明。

已指引Human检查系统键盘添加/完全访问、两项关闭及Search Tab一次正常输入/候选提交；当前待反馈，不判正常输入已通过。不进入Maps/AppSwitcher，不启动新probe。旧原数据缺失历史Hold保持，新环境baseline还未验收。仅内容无关摘要归档，完整data备份仍留私有scratch，不进repo。

## 本切片 Exit 完成

Human反馈：“好了，完全访问、候选、提交都很正常。”系统完全访问与正常候选/提交为Human观察证据；[只读Exit](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-environment-rebuild-artifacts/rebuild-exit.json)再核111文件原安装身份相等、部署成功、无pending/in-progress、compiled build存在、两项诊断按缺键默认关闭。新环境基线可用，仅解除本轮重建与正常输入依赖；原容器数据未恢复和旧事故Hold保留为历史未解决限制，不把重建当恢复。原Architecture R3 Partial、H2未覆盖、skip/格式/整体Gate保持。下一步建议明确配对输入的最小Architecture R4补审，然后再决定新候选晋级/安装/现场；R4仍Draft，未续budget或派发。本次未新build/test/install、Maps/AppSwitcher、arm、LLDB、source/Git动作；无CHANGELOG/架构合同变更。
