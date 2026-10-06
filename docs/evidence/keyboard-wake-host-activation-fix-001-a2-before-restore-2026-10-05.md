# A2 before恢复交付 — 2026-10-05

Human批准“继续吧，直到完成新候选的A2独立复审为止”，覆盖此前提出的精确before恢复及provenance新增/改写例外。root先核对原UDID、静默、before与after保全库存及live与冻结Exit全等，再安装精确78文件旧C7包；安装后重列差量，没有扩大清单。

恢复共110个应用节点动作：主数据3文件恢复、46测试新增节点移除；Group8目录、51文件、2内部symlink恢复。以ditto恢复完整且恰在授权清单内的Rime子树，保留目录xattrs与内部links，未沿用旧脚本丢失目录provenance的做法。两次读回稳定，应用内容/模式/所有者/非provenance原xattrs与before相符；provenance新增20/改写44，未接受missing。78文件安装包哈希和双签名通过，容器根身份、metadata、SplashBoard与安装后live全等。

两诊断键ABSENT、rime_deployed=true、rime_needs_deploy=false、rime_is_deploying ABSENT；目标App/appex进程均为空。未启动App、再部署、输入、Maps或LLDB，机器恢复不等于人工输入健康确认。新候选源码/1156构建输入仍须复审Entry再核，不以旧App健康替代新候选验证。

[恢复回执](keyboard-wake-host-activation-fix-001-a2-restore-artifacts/restore-receipt.json)；[私有原件hash](keyboard-wake-host-activation-fix-001-a2-restore-artifacts/private-receipts.json)。所有备份、源码修复、测试日志与xcresult保留，未清理、Git发布或Release。下一A2独立静态复审已由同一Human消息批准，F4未授权。
