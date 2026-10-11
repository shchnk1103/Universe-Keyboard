# C7 候选晋级／安装 checkpoint

当前已安装冻结dedicated Debug candidate、App正常启动；**仍待Human核候选键盘按钮/正常输入，未arm/Maps/LLDB**。本阶段用户授权继续下一步及stage残项处置/独占，见[安装Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-install-staged-entry-2026-10-02.md)与[Product决定](../product-decisions/KEYBOARD-WAKE-C7-DIAGNOSTIC-PROMOTION-RESIDUALS-2026-10-02.md)。

[独立Quality](../reviews/quality-c7-promotion-preflight-r4-review-2026-10-02.md) P1/P2/P3均Covered，Scoped Positive preparation，不安装/运行/Gate放行。17/17输入匹配、7/12calls；首次时钟未落盘，start/elapsed null、hard时限精确合规性未知，[原usage](../reviews/quality-c7-promotion-preflight-r4-usage-2026-10-02.json)保留，不能说完整计时或重建假时钟。报告冻结时点Product/backup依赖后来由root真实记账满足，不倒写报告。

[candidate复核](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-promotion-artifacts/candidate-revalidation.json)：source/build571、Vendor630、payload78无漂移、双签名verify0；[skip清单](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-promotion-artifacts/skip-details.json)30条保留。Human只本C7阶段接受29未验证残项/431实际执行计数；signedKeychain1/0/0独立，不改unsigned skip、不用于Release。

[完整fresh备份](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-promotion-artifacts/fresh-backup-entry.json)main-data827/AppGroup53/原app111逐字节验证，内容只存private scratch。MCP install冻结standaloneApp成功，不build/test/uninstall；[postinstall](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-promotion-artifacts/postinstall-verification.json)证明installed78匹配冻结candidate、AppGroup53及preferences相同。主App data目录迁移与4个系统截图路径更名，初步strict can_launch=false如实保留，root实际暂停。

[只读迁移分类](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-promotion-artifacts/data-migration-classification.json)证明822非SplashBoard文件逐字节等同、4截图SHA多重集相等，AppGroup无变化；root在已授权常规实现判断内据内容映射继续正常启动，不猜写metadata/恢复/重新部署。该映射不叫系统路径未变，也不证明任意安装保持数据。

启动PID23981；[postlaunch](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-promotion-artifacts/postlaunch-status.json)：rime_deployed=true/needs=false/deploying=false、compiled目录存在、诊断logging/expiry缺键默认off。已指引Human空栏看观测按钮，有候选应隐藏、候选提交正常；未点观测/取证，不进入Maps/AppSwitcher。仅App运行成功，不当前appex正常/borrow有效/rootcause。

旧数据未恢复、旧overallHold/F2/F3/57format和历史Partial保持；当前候选就位不能自动成为真实owner nil证明。新现场取证需要精确Debug/LLDB准备和单轮授权/Entry。无源码/格式/Git/Release或Gate；父子Active。

## Human 正常入口 Exit

Human确认候选与提交正常、没有点击观测/取证；第二张截图空候选栏显示观测，第一张未显示。有候选隐藏为Human文字观察，截图均为空候选栏。源码 showsControl 与controller idle deadline统一2秒：没有active touches、触摸后elapsed>=2秒、未观测时必须无候选。截图22:16/22:17并不测量真实idle延迟；未证明延迟超设计，不猜修时间。见[内容无关回执](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-promotion-artifacts/human-keyboard-check.json)。

安装配对和Human正常键盘/按钮入口核验完成；仅Button可见/正常输入，不是点击功能、arm/freeze/export/借用参数可读、Maps故障或owner nil证明。本轮没有点击probe或调试器操作。下一步建议只做调试器就绪核验（精确appex process/image UUID/符号及断点resolve），单独冻结范围后执行，不先arm。
