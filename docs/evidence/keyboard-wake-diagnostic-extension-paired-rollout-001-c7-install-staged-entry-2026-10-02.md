# C7 安装分阶段 Entry

当前：**等待独立准备协议验收最终报告，尚未安装**。root sole repo writer/Environment Executor，Human决定残项与设备独占并负责正常输入反馈；独立Quality只审冻结preflight，不读此后新增设备证据或代替Product。

用户授权继续下一步，随后明确接受C7阶段29未验证残项/431实际计数与备份安装窗口独占，见[阶段决定](../product-decisions/KEYBOARD-WAKE-C7-DIAGNOSTIC-PROMOTION-RESIDUALS-2026-10-02.md)。原App已MCP stop以保护备份一致性；用户暂不输入/切App。实时容器查询原installed111文件相等、部署健康、诊断logging/expiry缺键默认off。FreshBaselineBackup当前main-data827/group53/original-app111文件逐字节验证，私有scratch `/private/tmp/ukey-wake-promotion-preflight-20261002`，备份内容不入repo。这是重建后的新基线，不复用重建前827/4备份，也不声称恢复已丢失旧数据。

C7-B3 candidate digest ddd5579ee6dce39deea3c63487cfe6817c419628c4471c0b3e9298d9c47f3ca9，payload5a935a0e648fd8939b1e56b4e40f5da24828a0f2e6bfe9e6365b98ca3a2a80e4；source/build571、Vendor630、candidate78复核无漂移，两个codesign verify严格0，standalone不含testhost。Architect R4字节补核Covered，原H1/H3及Qualityhost H1-H3证据限定复用；不能声称实际probe运行。

后续只有独立评审满足必需覆盖/报告交付，全部Entry依赖成立才执行MCP install_app_sim该冻结App，不测试工具、不卸载清数据。不先启动；立刻读回candidate78与App/appex identity和mainData/AppGroup路径、备份全部文件hash/preferences/deploy。容器身份漂移或内容丢失即停，不启动/重新部署/猜复制系统metadata；有完整新基线backup+原App恢复来源，交Product决定精确恢复。匹配后才正常启动，核diagnostics off/正常按钮入口和一次输入，禁止arm/Maps/AppSwitcher/LLDB。Exit仅安装配对/入口正常，不rootcause/Gate/Release。

## 安装阶段 Ready checkpoint

[Quality原报告](../reviews/quality-c7-promotion-preflight-r4-review-2026-10-02.md) P1/P2/P3均Covered、Scoped Positive preparation，报告冻结时点仍列Product/fresh Entry依赖；root不倒写review，随后独立记账Human阶段决定、fresh完整main827/group53/app111备份逐字节相等，因此依赖已满足。当前安装执行Ready只基于用户继续下一步及随后备份/安装核验窗口回复、冻结候选和上述实际Entry，不声称review自动授权安装。

Quality usage7/12 calls，actual首调UTC与总elapsed为null，首次采样在错误退出前未落盘；精确hard-time合规性不可证明。本轮不将缺账改为完整、也不重建旧时间，作为准备意见的administrative limitation明示；P1-P3正向覆盖仍为reviewer事实，没有整体Gate/签名安装/runtimeclaim。root未知时长不当作证明通过，保留用于后续独立证据评估。

下一动作只MCP install冻结standaloneApp。postinstall核候选payload和新基线data/group路径及内容无关hash原值；任何变更先停，不启动，不自动部署。

## 安装后暂停与只读映射核验

candidate安装工具成功，78payload字节全部相等；AppGroup同一0296容器53文件和诊断/部署preferences逐字节相同。MainApp data从A0C...迁到FB810...、系统SplashBoard4截图路径更名，最初严格路径判据can_launch=false，root已实际暂停启动。随后只读[迁移分类](keyboard-wake-diagnostic-extension-paired-rollout-001-c7-promotion-artifacts/data-migration-classification.json)：非SplashBoard822文件全相等；4旧→新缓存内容SHA多重集相同，唯一其它截图路径保持，无业务文件丢失/修改。无恢复复制、metadata猜写或自动部署。

root在用户授权继续下一步/自主常规实现选择内，以完整内容映射作为目录路径迁移的等价性证据，继续仅正常启动/入口验证。原postinstall严格失败记录不改写，review冻结协议及意见不倒写，不称系统路径未变；此判断不新增Product残项接受，不越过Maps/arm/LLDB。完整新基线backup仍在私有scratch，旧数据损失历史保持。
