# C7-B3 actual iOS 验证与恢复 Hold

**整体收尾 Hold：测试均无失败，但原 App Group 数据未恢复；Architecture R3 仍 Partial。** Human 本轮独占和最小 Architecture 补审授权成立，见 [iOS Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-ios-entry-2026-10-02.md)。仅原 iPhone 18 Pro / iOS27.0，UDID 405D994F-28CB-4F89-BB22-B64AD81C05A2；未执行 Maps、probe、LLDB、生产完整部署、源码/格式/Git发布。

| 实际套件 | 通过 | 失败 | 跳过 | 证据 |
|---|---:|---:|---:|---|
| RimeBridgeTests | 85 | 0 | 20 | [MCP](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-ios-artifacts/rime-mcp-result.json)、[xcresult summary](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-ios-artifacts/rime-xcresult-summary.json) |
| App + Keyboard unsigned | 421 | 0 | 10 | [MCP](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-ios-artifacts/app-mcp-result.json)、[xcresult summary](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-ios-artifacts/app-xcresult-summary.json) |
| Signed unique Keychain integration | 1 | 0 | 0 | [MCP](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-ios-artifacts/keychain-mcp-result.json) |

三次实际 test 使用 Swift6 complete/warnings-as-errors、显式原UDID、专用 DerivedData/xcresult、禁 parallel clone/package更新。无签名全套中 Keychain skipped 仍保留，签名专项另证通过；不把全套30个skip改通过，29个其它用例尚无本阶段 Product 残项处置。工具发现432、实际xcresult431=421+10；discovery items仅6项preview，不能逐项证明432对应，原因UNKNOWN，不为计数重跑，见 [count receipt](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-ios-artifacts/app-count-reconciliation.json)。

## 恢复事故 / Environment Hold

Executor 事前保全原111文件安装包与内容无关配置/72文件hash，但没有完整备份主App data/App Group 数据。该准备不足，不能以原 Entry Ready 的判断掩盖。actual tests之后旧 App Group B0D7CE38-2B36-4AF1-B585-63ED3DA340E0 已不可见，新的group为0296BFCE-F465-4F1A-9E9A-F2EDFDA41172；主App data身份也改变。未在三套之间逐轮采样容器身份，因此具体哪次test/工具安装步骤造成变更尚未定位，不能定责到某用例。

按既定恢复路径重新安装事前原包，工具成功；[恢复核验](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-ios-artifacts/restore-verification.json)证明111文件逐字节相等。**仅安装包恢复，数据没有恢复。** 新group只有4文件，旧72路径中68缺失：Rime50、Diagnostics18，另metadata与preferences两项hash改变。Rime/shared、Rime/user、Rime/user/build均不存在；rime_deployed不存在、rime_needs_deploy=true；logging_enabled由存在false变为不存在，高保真expiry仍不存在。不等于恢复原值/存在性。完整缺失路径和before哈希均在artifact中；没有读取日志/词典正文。

立即停止现场/晋级；未启动恢复后的App、未重部署/清理/写preferences。旧诊断内容和RIME数据不能由hash还原。恢复原数据需要先另做只读恢复来源核查，若无完整备份，Product需决定新的环境重建/基线授权；重建不能声称恢复原数据，也不能自动继承旧现场Entry。当前不建议用户打开App，以免触发初始化/部署。

## Architecture R3

复用独立 Luna，批准 [R3 packet](../reviews/arch-c7-b3-r3-approved-packet-2026-10-02.json)。[原样报告](../reviews/arch-c7-b3-r3-review-2026-10-02.md)与[usage](../reviews/arch-c7-b3-r3-usage-2026-10-02.json)：8/8 calls、221.666秒，Partial/incomplete。packet摘要规范首次误用ensure_ascii=true，后按false验证匹配；xcent历史locator与allowlist冻结副本映射检查停止，未读Mach-O/xcent原bytes，所以没有matching/mismatch结论。旧R2 Partial与缺账保留，新R3只补齐本轮文件/usage，不关闭H2。

已准备 [R4 draft](../reviews/arch-c7-b3-r4-proposed-packet-2026-10-02.json)，明确两exe→两冻结xcent直接配对与摘要规范，不需追历史临时locator。未授权/未派发，不自动续预算。Root旧静态核验与Quality Covered不能替代独立Architecture。

父子Assignment仍Active，根因不明；保留旧整体Hold、57格式diagnostics、F2/F3、历史skip限制。本轮无源码/CHANGELOG/架构合同变化，无Gate/M-02触发。FullCore1194字节等价证据复用未重跑。完整dirty与所有既有文件保全另附收尾receipt。

[保全与检查 receipt](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-ios-artifacts/final-checks.json)：2737既有文件仅五份授权治理镜像改变，范围外0、staged0，分支/HEAD保持；完整dirty逐文件状态见 [full status](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-ios-artifacts/final-full-status.z)。Markdown本轮新改文档链接检查无缺失，定点git diff --check通过。
