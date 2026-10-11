# F4-P reader/writer修通及独立补审round2 — 2026-10-05

**读写预检通过；晋级核验仍Incomplete，不进入F4-I。** Human批准先实际跑通reader/writer，再只补旧未覆盖项。原两独立Luna runtime复用；新预检各6calls/300秒，正式同lane round2各20calls/900秒、8/14检查点及最后6calls交付，旧round1原件不改、不自动续。

## 流程修复实际结果

[Quality预检作者读回](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-r2-artifacts/preflight-quality/readback.json)6calls/57.155922秒，smoke明确fake_data=true。Architecture也实际写出并作者读回；首调用UTC未记录，作者精确elapsed UNKNOWN保持，root以packet创建早于dispatch至作者readback计算保守102.604647秒上界，证明未超300秒而不冒充作者时间。[双预检root receipt](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-r2-artifacts/root-preflight-receipt.json)提供起止来源及hash，repo通道已由实际reviewer验证可读写。假数据不计审查结论。

## 独立内容与收件

Quality [作者报告](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-r2-artifacts/quality/review.md)正式Partial：Q-P4 Covered；Q-P1/2/3各有精确子项未覆盖。[ACK](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-r2-artifacts/quality/ack.json)、[真实usage](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-r2-artifacts/quality/usage.json)、[作者readback](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-r2-artifacts/quality/delivery-readback.json)完整，18/20calls、616.795676秒，root复算SHA/bytes/起止数学全部符。source/dependency358+168+630逐项、78payload/91448700bytes/d53523db摘要、四UUID及probe/host符号、两target实际flags/零error/两AppIntents工具warning等局部已核，不因局部覆盖把whole Q-P1..3写成Covered。

三个未覆盖子项是主App两模块SHA/UUID配对与standalone证明、原始构建request/receipt对实际两target的绑定、二进制真实otool section解码逐项对照。root定位确认原始数据已在冻结镜像，并准备[精确剩余reader](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-r2-artifacts/quality-uncovered-reader-prepared.json)：四模块原path/SHA/UUID；真实原build request/receipt；两target实际invocation；arm64 otool十六进制词按little-endian解码plist及全字节SHA。两解码SHA分别6610a8c0…/1b5eca79…与旧section记录相等，Group及application identifier均可读。此为root只读reader准备，**不是独立补审结果**；原Quality Partial不改，不要求新build/test。下一精确packet需绑定该reader及原SHA，新的有界补审需Human授权。

Architecture只有[正式ACK](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-r2-artifacts/architecture/ack.json)，budget_start03:26:56.830800Z，900秒截止03:41:56.830800Z。root于03:42:03.712954Z观察指定目录仍只有ACK，随即interrupt原审查实例；不续预算。未收作者report/usage/readback，实际call count UNKNOWN，不补造作者结论或elapsed。[root预算停点](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-r2-artifacts/architecture/root-budget-stop.json)保留；A-P1..3仍未覆盖。读写流程已经实际可用，不把本次内容/交付停点再次混称路径不存在。

## 后续最小建议（Prepared，不执行）

停止沿失败实例追加泛审。建议Human批准一次Architecture独立执行实例替换（仍GPT6 Luna、保留同Architecture责任和原开放项），新同lane round3仅A-P1..3；Quality沿原实例新round3只补上述三个子项，Q-P4/A2/Q3不重审。提案预算Architecture20calls/900秒、Quality6calls/600秒，各从新ACK起计、先写ACK、预留最后交付，首必需输入/流程失败停止。不自动续，不创建/启动新runtime，当前仅Prepared。

[root收件](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-r2-artifacts/root-receipt.json)与[manifest](../reviews/keyboard-wake-host-activation-fix-001-f4-p-promotion-r2-artifacts/manifest.json)保存实际状态。F4-P build/pair冻结仍有效；所有source/Vendor1156行保持，不新增源码/工程/编译/测试/设备/安装/LLDB/Maps/Git/Release，不清历史备份。安装需两个独立资格判断满足后，再另授权fresh独占、静默完整before与精确F4-I；整体修复未Completed。无CHANGELOG/ADR修改。
