# M 阶段分阶段 Entry（Prepared）— 2026-10-03

Work Item: KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001。Human仅授权[M准备包](../plans/keyboard-wake-diagnostic-extension-paired-rollout-001-c7-ui-m-prepared-2026-10-03.md)。Lifecycle沿Assignment Active，本阶段Prepared，不Ready；root唯一repo writer，无新独立reviewer lane。

| 项目 | 当前事实／执行前要求 |
|---|---|
| 工作树 | paired-rollout-preflight/Universe Keyboard；codex/keyboard-wake-v3-compatibility-gate；84b9c19227330b0fe6ff391be001ee398010fd6a已只读核验 |
| 候选与源 | 43d85d…；1279hash-only源／构建／Vendor输入与78本地payload无漂移；不是当前installed证明 |
| 范围授权 | 准备已授权；M0当前保护、M1新实例/Maps入口、M2LLDB/单轮输入导出均未授权 |
| 目标 | 唯一405D994F-28CB-4F89-BB22-B64AD81C05A2 iPhone18Pro/iOS27.0；当前身份/Booted与fresh独占UNKNOWN |
| 数据保护 | M0新鲜main data/AppGroup/已装App完整备份、库存/签名/副本核验及具体恢复方案UNKNOWN；I0/I1只是历史 |
| 环境 | Maps当前版本、schema/布局、部署状态、完全访问、两诊断键原值/存在性UNKNOWN，不能填历史off/ABSENT为当前 |
| 新实例 | fresh唯一appex PID、精确path/SHA、未arm控件、loaded UUID、explicit session/own断点UNKNOWN；当前旧probe已消费，不重用 |
| M2执行就绪 | M0/M1通过、明确新授权、断点唯一0hits后continue、账本先写、Human停手并逐卡确认；现场UNKNOWN有一项未解决即不进入Ready |
| 限制 | U1R1交付残项只当前U1R1接受，不外推M；30skip仍skip，不计Pass／不用于Release |

M0如需退出仍在的旧扩展，应在M0授权文本明确“一次正常SIGTERM，仅现场精确核实进程”；未经该授权不发信号。M1/M2授权不隐含reinstall／RIME部署或data restore。M0/M1/M2按依赖顺序分别记录实际Entry，不改这份冻结Prepared为成功。执行设备、PID、地址等占位符只在新的现场记录填入。

M结束只报告已取得的内容无关输入链、停点／借用／导出／cleanup证据；owner=0必须是完整配对返回后attempt内的schedule记录，缺event或synthetic armed不能替代。根因仍需后续解释与独立验收，不预先放行。
