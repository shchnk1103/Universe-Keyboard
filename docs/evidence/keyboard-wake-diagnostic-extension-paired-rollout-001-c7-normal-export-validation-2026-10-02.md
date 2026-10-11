# C7 正常路径单轮有界导出交付 — 2026-10-02

正常路径探针导出已实际完成，限定于当前主App搜索页、同一Keyboard appex、一次arm及一次合成n输入；未进行Maps/AppSwitcher。父子Assignment仍Active，根因未确认，未作独立运行验收/整体Gate/Release。

## 授权 / Entry / Human记录

Human明确授权一次正常路径观测→冻结→有界导出，并确认本轮原模拟器独占、FullAccess开启。见[Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-normal-export-entry-2026-10-02.md)。最初按钮不可见而Hold；Human随后确认可见并决定先继续，原Hold及延迟报告保留。

工作树branch `codex/keyboard-wake-v3-compatibility-gate`、HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`；571源码/构建输入、630Vendor、installed78文件无漂移。候选digest `ddd5579ee6dce39deea3c63487cfe6817c419628c4471c0b3e9298d9c47f3ca9`；精确UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`，PID24050。既有backup可用，本轮不安装/部署或恢复。两诊断键不存在/关闭，部署健康。见[机器Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-normal-export-artifacts/machine-entry.json)。

Human报告点击“观测”、只输入n，候选更新；随后看见按钮仍写“观测”，再次点击后键盘卡住。按钮实际显示文字以Human原描述保留，不擅改成“取证”。各点击精确UTC和等待时长未测量，不能填造；操作顺序由Human回执绑定。没有要求再输入、补轮或绕过入口。

## 实际出口与借用期有界读取

Session `3c463407-c051-4fb7-aad3-b78f29f3893e`附加精确PID；loaded Keyboard UUID `7E0813A6-2992-353B-9BA2-C9B1F8AB69E6`、Keyboard.debug UUID `FE12AEDC-088B-3CBB-B00A-1ECD95323DA4`与候选匹配。精确出口断点1唯一resolved；Human第二次点击后hit count=1，frame0为wakeOwnerProbeExportReady +60、源码96:83。所谓卡住在工具侧确认是本次调试暂停，不能作为Maps故障复现。

限定static frame variable读取address和byteCount，无dynamic/synthetic/expression；实际address `0x115955ba0`、byteCount528，非零8字节对齐，176<=528<=11352。源码唯一调用点位于words.withUnsafeBytes借用范围；实际停点确认出口参数可读，未另采caller stack，borrow判断依赖同候选源码调用点及frame证据，不冒充独立caller-stack证明。

暂停期间执行一次memory read binary/count528，只复制该区间至snapshot.bin；工具回执528bytes written。随后移除断点1、continue（running）、detach（detached）。未step-out或先continue再读取旧地址；未读前后内存/寄存器或用户内容。借用开始/冻结点击/各命令精确墙钟起止未逐项采集，仅保留实际工具顺序与有限机器UTC，不能声称完整时刻ledger。见[原始回执](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-normal-export-artifacts/export-receipts.json)。

## 固定metadata完整性与判读

[原始528字节](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-normal-export-artifacts/snapshot.bin) SHA256 `3a2a46a75d3ebd65b4950d1c6d7b6c20bd338609fcac5092d500d6126bd09422`。使用已审repository离线decoder片段，SHA256 `fc1817ab8843dab76acd9e8ae59277719c059742bb105eebecbc60a66f58775d`；实际文件长度与byteCount相等，v1 magic/长度/count/sequence/time/TTL/enum验证通过，recordCount5，buffer_complete=true，未标记损失或溢出。见[所有原始metadata行及attempt表](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-normal-export-artifacts/decoded.json)。

| sequence | stage | coordinator/appearance/attempt | owner/receipt |
|---|---|---|---|
| 1 | synthetic armed | 0/0/0 | 0/0 |
| 2 | UI armed | 3/3/0 | 1/0 |
| 3 | insertBegin | 3/3/1 | 1/0 |
| 4 | schedule | 3/3/1 | 1/1 |
| 5 | insertEnd | 3/3/1 | 1/0 |

仅一个attempt且begin/end唯一、同非零coordinator/appearance，唯一schedule夹在两者之间。正常输入该同步schedule读点owner存在且有accept receipt；Human候选更新是另项现场观察，receipt本身不证明engine执行或host提交。synthetic armed的owner0不作owner为空；complete只证明本buffer未标记丢失，不证明所有回调覆盖。

## Exit / 限制 / 下一步

断点已remove、continue/detach回执成功；只读同PID仍Ss、两诊断键原存在性/值未变，部署true/needsfalse/deployingfalse。见[机器Exit](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-normal-export-artifacts/machine-exit.json)。未让Human追加试打，故只确认工具恢复运行，键盘交互恢复尚待Human观察。probe是已消费单轮/frozen，不再arm；不为了重置而自动重启。源码/Git发布未变。

待查UI项：①按钮在Human长时间停手后才出现（仅主观时长，无精确计时）；②arm/n之后第二次点击前Human仍看到“观测”文字。此次真实出口已命中，不能把文字报告当作第二次arm或失败，也不能抹去报告。先保留，不扩大本轮猜修。

建议下一步独立只读验收本次identity/borrow-read/metadata配对及限制；Maps新现场需另授权和fresh Entry，不复用已消费单轮。历史skip、旧review限制、旧AppGroup未恢复事实均保留。不需CHANGELOG或架构合同改动，无M-02生命周期触发。无build/test/install/deploy/source/Git/Release。

## Human Exit补充与独立验收授权

Human已明确确认键盘恢复正常、按钮仍显示“观测”；见[回执](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-normal-export-artifacts/human-exit.json)。未要求更多输入/点击。原正文“尚待Human观察”是当时状态，现已补齐，不能倒改为当时已经确认。Human授权一次只读独立验收；本轮冻结证据包后复用原独立Quality Luna，不读当前设备，不新增源码或运行操作。
