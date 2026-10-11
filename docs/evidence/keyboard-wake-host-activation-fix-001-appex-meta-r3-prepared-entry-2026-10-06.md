# AP-META-003 单修正后元数据核验（Prepared）

继续绑定[AP-META-002](keyboard-wake-host-activation-fix-001-appex-meta-r2-prepared-entry-2026-10-06.md)所有source5/78payload/UDID/模块UUID/SHA、metadata-only字段、禁止动作及验收要求；不继承已耗预算或旧实例。只增加本次已验证的callback返回值修正及注册读回，不改生产。

root为debugger-side writer；私有修正版 /private/tmp/ukey-appex-meta-callback-api-preflight-20261006/appex_meta_setup_fixed.py，实施前hash见同目录entry.json。未来新运行根 /private/tmp/ukey-host-activation-fix-appex-meta-r3-20261006，只执行授权后创建。部署该私有脚本时只替换ROOT字符串至新运行根，并冻结AST/SHA及替换前后差量，不复制旧PID、binding或callback样本。

单参数SetScriptCallbackFunction不检查虚构SBError：以breakpoint command list成功及明确appex_meta_callback.export_hit注册记录验收，然后SetAsync(False)、唯一location/hit0、配置回执成立才发CLI continue并安排人工一arm一freeze。长Python走文件，终端仅短command source；continue、quit各单独发，不批量排队或在Python函数内等待。旧SDK错误记录保留，不通过放宽新运行身份验收规避任何错误。

执行前需Human确认新鲜原UDID独占，关闭Maps和主App、两诊断关闭、未安装部署。旧appex存活若Human明确授权才重核PID/start/path一次正常SIGTERM，不强制终止主App。主App搜索Tab空框、完全访问开、候选空且观测出现；禁止字符输入、Maps/AppSwitcher、候选提交、buffer/address/count读取、target expression、build/test/install/deploy、生产修改/Git/Release、大备份或删备份。

新预算提案30actualcalls／30分钟，最后8calls预留收尾、停点≤120秒、一runtime attempt／一命中。任何未知身份、配置错误/无注册回执、多断点或callback身份不一致都清理停止，不临时修正重试。断点delete/list空、detach、单独quit及同PID非traced、诊断原存在性/Human视觉Exit必须归档。Passed也仅停点metadata身份链路，不关闭F4 owner/整体修复。

状态Prepared，执行授权／fresh窗口待Human，本文件不自动创建运行根或操作设备。
