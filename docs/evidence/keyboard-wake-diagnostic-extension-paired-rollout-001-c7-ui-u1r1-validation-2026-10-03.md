# U1R1 新候选正常路径有界导出交付 — 2026-10-03

运行采集、离线解码和机器清理/Exit完成；Human UI Exit仍待回报，未开展独立验收。仅原主App搜索页、单次arm/n/freeze，不Maps/AppSwitcher；原U1提前冻结Incomplete保持原样。

## 身份 / Entry / Human步骤

原branch codex/keyboard-wake-v3-compatibility-gate / HEAD84b9c19227330b0fe6ff391be001ee398010fd6a不变。固定候选43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50；1279source/build/Vendor输入Entry/Exit零漂移，installed78SHA匹配H1。原UDID405D994F-28CB-4F89-BB22-B64AD81C05A2、iPhone18Pro/iOS27.0、fresh独占/完全访问与两diagnostic off已绑定Entry。

Human授权新实例、新单轮、确认关闭App和独占；root重核旧PID80843仅一次SIGTERM并确认退出，Human重新叫出键盘形成新PID88188。新session4895a8c9…同session image list证明加载Keyboard和debug dylib路径在原UDID当前installed容器，UUID C3FC7115…/77BD18E2…与H1匹配。工具回执simulatorId仍为共享其他任务defaults884CAC1A…，按Human批准的实际路径/PID/UUID绑定补正留痕，不改defaults，不借该标签操作其他设备。

三张操作卡一回报一推进：Human空栏观测出现→单次arm后“已显示取证”→单次n后“候选已更新，按钮已显示取证”→单次freeze“已点击取证”。实际点击/idle秒数未测量，root收到/归档时刻单独记录，不推精确按钮延迟。输入前无提交/删除/切换，不读真实输入内容。

## 真实停点、borrow与有界读取

breakpoint1唯一resolved，首次hit1；frame0在实际wakeOwnerProbeExportReady。thread backtrace -c8采得frame1 handleWakeOwnerProbeButton closure（源码88）、frame2 Array.withUnsafeBytes、frame3 handleWakeOwnerProbeButton（源码86），明确同候选借用调用路径。未展开其他变量，不是旧轮静态caller复用。

仅static raw frame variable两参数（no dynamic/synthetic/expression）：address0x000000011e62ad20，byteCount528，非零8字节对齐且176<=528<=11352。真实出口暂停内唯一binary memory read复制恰好528字节，回执528 bytes written；未读前后内存、寄存器或用户内容，未continue后复用地址。

## 记录完整性和有限判读

snapshot.bin SHA256 **40ff2daf44c1a6495ea9188b4a10a7aa9160f3d38b35a4c8a99c1d9e41d8e467**。已审decoder字节原样复用，SHA256fc1817ab8843dab76acd9e8ae59277719c059742bb105eebecbc60a66f58775d；真实raw长度/magic/v1/11word头与每行11words/count/TTL/seq/time/enum验证，5记录、buffer_complete=true，所有行保留，未去重修补。

| seq | stage | coordinator/appearance/attempt | owner/receipt |
|---|---|---|---|
|1|synthetic armed|0/0/0|0/0|
|2|UI armed|1/1/0|1/0|
|3|insertBegin|1/1/1|1/0|
|4|schedule|1/1/1|1/1|
|5|insertEnd|1/1/1|1/0|

唯一attempt1同非零coordinator/appearance begin/end配对；唯一schedule夹在两者中，记录点owner=1、receipt=1。仅正常路径该调度记录点owner存在与有receipt，不证明engine实际执行、宿主提交、所有回调覆盖或Maps根因。synthetic armed owner0不作owner为空，buffer_complete仅本探针local buffer无损失标志。

## 清理、账本、Exit与剩余依赖

采用与创建方式一致的LLDB breakpoint delete1，回执1 deleted；随后list1显示No breakpoints currently set，continue running、detach detached均成功。避免旧轮DAP registry remove失败重演。只读机器Exit同PID88188 stat Ss、同可执行路径，78payload/1279输入与diagnostic键原ABSENT/off保持。UI响应健康仍须Human另外观察，不由机器Ss推断。

本轮15底层debug calls的request/response UTC、Python writer monotonic时间边界、原始回执与SHA全部齐。root从本次停点核验工作开始到cleanup结束累计63.106秒，在120秒工作预算内；这是root观察工作区间，不是实际全部target暂停时长。实际click、target stop开始、borrow创建UTC未测，不造全ledger精确时刻。内存唯一read先完成，再delete/list/continue/detach，原始调用顺序与raw文件对应可审。

primary artifacts见[capture freeze](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-artifacts/collection-freeze.json)、[decoded](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-artifacts/decoded.json)、[ledger](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-u1r1-artifacts/ledger-summary.json)。完整raw private /private/tmp/ukey-wake-ui-u1r1-execution-20261003；raw仅固定元数据，历史备份不删除，不主张正常输入后完整data等于I0。

Human UI Exit待回复；probe实例已frozen不rearm，按钮可保持取证，不是两diagnostic打开。若要独立只读验收，需另冻结P1身份停点、P2raw完整性配对、P3借用清理账本的范围/预算与Human授权。本报告是Environment Executor交付，不冒充独立Quality或Product/Gate结论。

未新build/test/install/deploy/restore/source/Git/Maps/Release；原30skip与T29nonblock决定不扩到U1，父子Active、根因未确认。docs-only跳过xcodebuild，无需CHANGELOG或架构合同修改。

## Human视觉Exit已补齐（原Pending保留为历史）

Human原话“界面还是之前点按了n之后的样子，按钮现在显示取证”已归档。冻结不清空当前候选/不重置composition，取证标题与frozen状态相符；此回报是视觉状态确认，**不是额外试打或点击响应验证**，不扩写为交互完全恢复已测。机器running/Ss、断点已删除/detach成功与该视觉回报分别保留。本轮采集、机器清理、视觉Exit交付已齐，附未追加交互验证限制；无独立验收结论。新增回报以collection-human-exit-supplement.json补冻，原collection-freeze与raw字节不改。后续建议只读独立验收，须另授权范围与预算；当前probe已frozen，不自动重启或Maps。
