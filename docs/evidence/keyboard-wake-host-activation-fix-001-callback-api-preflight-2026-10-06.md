# AP-API-001 单接口修正与主机注册预检

Human“按照你的建议继续吧”授权仅修正 debugger-side 返回值检查并验证注册读回。root为唯一私有脚本writer，无生产源码权限。本轮新上限16actualcalls／15分钟，非AP-META-002续预算。

修正仅私有副本appex_meta_setup_fixed.py的一处：移除对单参数SetScriptCallbackFunction返回值的Success调用；该API返回void，改用breakpoint command list的Succeeded及明确函数名注册记录核验。其他原脚本字节保持，AST通过；原失败脚本、证据不覆盖。未执行修正版configure；未来运行根替换与fresh绑定仍待新Entry执行。

实际主机LLDB只从冻结Keyboard.debug.dylib创建静态symbol target，没有创建或附加inferior。出口解析1location，SetScriptCallbackFunction返回NoneType；CLI读回“appex_meta_callback.export_hit(frame, bp_loc, internal_dict)”，command_succeeded true、stderr空、hit0。删除断点成功、remaining0，删除静态target成功、remainingtargets0；单独quit会话exit0。

状态PASS_CALLBACK_REGISTRATION_ONLY。加载iOS静态模块时另有8条“Error while searching for Xcode SDK: Bad CPU type in executable”，原始PTY保留。来源和影响未诊断、未接受为通用环境通过、不改环境或重复尝试。注册与读回证据成立，但不证明运行callback、appex停点身份、SDK整体健康、owner缓冲导出、Maps或Release。

五源码SHA保持，staged0，写文档前完整dirty清单逐字一致。Simulator操作0、进程attach0、callback触发0、目标读取0。无构建／测试／安装／部署／大备份／备份删除／Git发布；无CHANGELOG或架构合同更改必要。

原件：/private/tmp/ukey-appex-meta-callback-api-preflight-20261006，entry、original/fixed hash、私有修正版、host_api_probe、commands、rawPTY、host-receipt、completion及最终账本。最终14actualcalls。

下一步只AP-META-003同范围元数据核验Prepared，另授新窗口，不泛查SDK或源码。
