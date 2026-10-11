# OWN-EXPORT-001 E0 root 就绪检查

检查范围仅主机文件及当前工作树身份；不执行预检、不导入LLDB、不操作设备或修改Grok脚本。Grok仍唯一执行者，root为协调收件。本检查不是新的独立Quality review。

**结论：E0技术预检有覆盖，E1暂不Ready。** 四脚本SHA与交付一致，主机格式读回确实是固定PC/stop-reason，最新预检矩阵all_pass=true。旧stdout尾随字用例false及作者期望修正原文保留；冻结decoder不变，不把旧stdout误读为最新测试失败。branch/HEAD/staged0符合。

## 必须定点补正

1. **停点计时锚点错误。** configure()设置configure_monotonic_ns，而export_hit()以该值判断120秒；这会把配置后等待Human观测/n/AppSwitcher/h等正常运行时间算作停点。应在actual callback进入记录本次stop的UTC/monotonic，读取前及返回后按该stop锚点核耗时，超时不成功交付并立即清理；暂停总上界仍由同stop→detach/机器Exit回执控制。新增host-only用例证明配置已超过120秒但刚命中不会因此拒读；真正stop超120秒0读。不得以configure时间延长/重置来规避。
2. **fake与live输出混用。** host_preflight.reset_callback()删除ROOT中callback/args/binary，当前真实run根残留fake callback.json（callback_count1）/stage/private。与pre-arm callback应不存在/0矛盾，且未来重跑host预检可能删除真实证据。将fake输出分离到专用子目录，预检不得unlink live产物。保全目前fake文件并标synthetic，真实输出起点读回确认空；不能把fake文件当运行回执。当前无设备sample，无需重采。
3. **用量尚不可复算。** e0-receipt无实际call ledger，首工具起点是否等于utc_start未证明；Human转述“约27”不是精确账本。仅补本轮调用表（含必读/失败/一次期望修正/wrapper/nested）和真实首调用UTC，不能重新起计。列出E1所需调用上界及至少12清理保留；原60calls/3600秒不足即停止，不能自续、猜数或把root等待扣除。时间未知应明确UNKNOWN并停交回。

Grok可在已有E0授权及尚余原预算内只补以上私有脚本/主机用例/账本，不改生产、decoder协议、冻结Entry/binding，不attach/设备/Maps/SIGTERM。两脚本新SHA及host结果、synthetic隔离证明、精确预算交回root后，再核E1 Ready；不能绕过检查点。默认formatter真正设备source仍为后续Entry步骤，不以主机可设置代运行事实。

保全原件SHA见e0-root-checkpoint.json，不覆盖作者原回执。当前执行仍Grok，root不并行操作。整体Assignment Active，旧AP-META接受不继承此检查。
