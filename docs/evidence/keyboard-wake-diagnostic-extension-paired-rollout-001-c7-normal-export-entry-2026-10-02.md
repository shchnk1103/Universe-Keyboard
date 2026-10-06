# C7 正常路径单轮有界导出 Entry — 2026-10-02

Human明确授权一次“正常路径的观测→冻结→有界导出”，并确认本轮仍独占。root继续作为唯一repo writer和Environment Executor，沿已冻结C7-C-P取证合同和完成的调试器就绪核验；本轮不新增源码/架构决策/独立review lane，不推断Maps根因。

## 确认事实

原工作树 `paired-rollout-preflight/Universe Keyboard`，branch `codex/keyboard-wake-v3-compatibility-gate`，HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`。本轮before-files2795非忽略文件全hash、full dirty保存在私有scratch `/private/tmp/ukey-wake-normal-export-20261002`。571源码/构建输入、630Vendor、installed78候选文件全部匹配；候选digest `ddd5579ee6dce39deea3c63487cfe6817c419628c4471c0b3e9298d9c47f3ca9`，ten-file identity `3c45e4d76a858d4d5484496d216cb8b1dc6a1d59d5bc3311eb5a2e451602e0e0`。

精确原UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`，唯一Keyboard appex PID24050，installed容器4EB4A3E6下的Keyboard可执行。两项诊断键不存在，保持关闭；deployed true、needs-deploy false、deploying false。既有完整FreshBaselineBackup可用，本轮不安装/恢复/部署；旧AppGroup数据未恢复历史限制保留。

此前readiness证明模块UUID匹配、精确出口唯一断点resolved/0hits，已remove/continue/detach。不能代本轮attach、实际borrow参数可读或导出成功。待Human补确认本轮FullAccess和空栏观测入口；补齐前不arm。现场Ready分阶段：pre-arm身份/入口/断点先通过，实际freeze出口停点再核参数/borrow；不可把无法提前获得的参数预填通过。

## 单轮操作合同

在当前主App「搜索」页正常键盘中执行，不切Maps，不打开AppSwitcher。root先精确PID attach，读loaded UUID与出口symbol，再设置唯一出口断点并continue。Human在收到操作卡后停手>=2秒，点击“观测”一次；只输入合成字母n一次，观察候选是否更新；不选候选、不提交、不删除、不换键盘。停手>=2秒后只点击“取证”一次，随后不操作。

root仅在真实出口断点命中/借用仍有效时，限定读取address/byteCount两局部参数，关闭dynamic/synthetic，不EvaluateExpression或猜寄存器ABI。确认非零对齐地址、176<=byteCount<=11352且8字节对齐；只复制恰好该byteCount至私有snapshot.bin。借用起止/命令/原始回执/hash/字节数/decoder版本/所有metadata行均保留。buffer只有固定UInt64元数据，不读用户内容或前后内存。未核参数、未命中、优化不可读或身份异常即停止；无自动再arm、再输入或重试。

无论成功失败均移除自己设置的断点，continue并detach，保持原诊断键值/存在性，read-only Exit核验。freeze后数据借用结束，绝不在continue后读取旧地址。本实例单轮状态保留，不重启清空；按钮可保持“取证”，不是诊断开关开启。离线decoder来自已审repository代码片段，保留raw及所有记录，不去重或修补；synthetic armed owner0不证明owner为空。正常单attempt仅验证链路，无法代Maps返回故障证据。

## 边界与后续

本轮无build/test/install/deploy、源码、Git发布/Release、Maps/AppSwitcher、广域memory dump、target方法调用或寄存器/内存写。历史skip仍skip、review限制及未恢复旧数据保留。独立运行证据验收需单独授权/冻结packet；当前不声称Gate或rootcause。

## 现场 Entry Hold（arm 前）

Human已确认FullAccess开启、本轮独占；但报告视觉空栏下“观测”从询问到回复仍未出现，体感超过一分钟。仅Human时长估计，不宣称实测一分钟。入口未满足，本轮暂停在arm前：没有attach、arm、freeze或导出，不自动通过重启/换键盘/更多输入绕过。见[现场记录](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-normal-export-artifacts/human-entry-hold.json)。

只读源码确认：显示还依赖controlsAvailable、activeTouches为空、停手>=2秒、observing或presentedCandidates为空；视觉空栏不能独立证明内部候选数组为空。有activeTouches或controlsAvailable关闭时不安排idle task。当前没有这几个运行值，原因未知，不猜修或仅调整时间。下一步先定点核查显示/刷新/触摸终止边界，必要运行状态观测另冻结最小范围。

## 入口随后可见，按Human决定继续

Human随后报告“观测”已可见，明确要求先继续本轮，延迟问题暂记。此前Hold事实保留；等待时长未实测、原因未确认，不能解释为正常两秒等待。FullAccess/独占已确认。精确PID24050重新attach，session `3c463407-c051-4fb7-aad3-b78f29f3893e`；两模块UUID仍匹配，出口断点1唯一resolved/0hits；已continue。现在只待既定单轮Human操作，尚未arm/freeze/export，不放行Maps。
