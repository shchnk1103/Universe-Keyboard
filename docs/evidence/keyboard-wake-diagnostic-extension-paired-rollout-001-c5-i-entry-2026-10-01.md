# C5-I scoped authorization / Entry — 2026-10-01

Human回复“授权继续，之前那台模拟器仍然独占”，绑定上一轮已明确C5-I一次配对安装核验和当前精确候选；fresh独占窗口从本次确认至本轮C5-I完成。权限包括安装/启动及必要readiness核验，不含C5-R启用诊断/输入采集、Maps、source/build/test/Git/Release。需要新增keyboard/启用FullAccess时，本轮仅记录现状并Hold，不自行改设置；此前提案仍要求明确包含设置变更授权。

## Identity / ownership / prerequisite

- worktree `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`，branch `codex/keyboard-wake-v3-compatibility-gate`，HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`；438dirty=19trackedModified+419untracked，staged0。
- candidate `af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9`；568source/build及111Debug文件逐项匹配；C5-P两独立静态lane及Qualityround2有效确认、C5专属30skip接受和本次C5-I授权构成此最小安装前提。历史round1Partial、Architecture呈现/计数限制保留，非整体Gate。
- 安装源 `/private/tmp/ukey-wake-c4-20261001/DerivedData/Build/Products/Debug-iphonesimulator/Universe Keyboard.app`，App/embeddedappex version1.0/build1；manifest SHA256 `28a47d2d7bf669ec3927dbf62112be268dd2bd6c161d11d59a7e0e545fcaa89a`；不重建/重新签名/安装独立appex。
- 目标iPhone18Pro/iOS27.0，UDID405D994F-28CB-4F89-BB22-B64AD81C05A2，XcodeBuildMCP list已确认Booted/available。
- root sole repo writer、Executor/Environment Executor；Domain/Architecture/Quality原职责不变，Human保有Product权限。必需身份/执行角色已知；FullAccess/RIME等是安装后待核验Exit，不虚构当前已通过。
- 窄读AppGroup capture keys均未存在，logging默认false、高保真未启用；本轮不改键值或进入输入采集。系统键盘和FullAccess现状待核验。
- prior active MCP profile `typo-correction-002-recall-publication-preflight-002-release`属于其他工作；新建仅本轮ephemeral profile,persistfalse，结束恢复原profile，不写repo配置。

## Authorized bounded actions / stop / exit

一次XcodeBuildMCP install上述App，自动携带appex；安装后读取实际bundle和11Mach-O SHA256/size/UUID、App/appexplist ID/version/build及完整目录树差异。payload任何不一致Hold，不以OS解释豁免。仅身份吻合后可启动MainApp检查现有readiness。launch已有生命周期可能创建Diagnostics根目录、执行现有retention/后台注册等；记录默认副作用，不手动部署/下载/改schema/清理。

窄读logging/highfidelity/分类状态、已配置keyboard/FullAccess、AppGroup路径和现有RIME资源、MainApp词典宿主可用性。不得启用高保真/输入；若readiness不足记录Hold，不猜修/重试安装或换host/设备。实际appex代码加载/回调/marker/reader运行结论仍归C5-R。不得把hostfilesystem可读或builtentitlement当appex runtimeGroupaccess证明。

本轮安装次数上限1；保留命令/时间/源hash/目标/实际路径和差异。未获C5-R不进行键盘激活/合成输入/捕获。旧App不保证可恢复，不以manifest称回滚；不卸载/reset/erase。完整既有文件基线 `/private/tmp/ukey-wake-c5-i-20261001/before-files.json`（2528项）和dirty状态before-status.*用于收尾保全。
