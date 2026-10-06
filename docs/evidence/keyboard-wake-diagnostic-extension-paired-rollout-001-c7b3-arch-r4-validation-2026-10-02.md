# C7-B3 最小 Architecture R4 交付

**唯一criterion Covered：H2 最终embedded-entitlement/xcent字节比较缺口已补齐。** [批准packet](../reviews/arch-c7-b3-r4-approved-packet-2026-10-02.json)、[Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-arch-r4-entry-2026-10-02.md)、[独立报告](../reviews/arch-c7-b3-r4-review-2026-10-02.md)、[调用账本](../reviews/arch-c7-b3-r4-usage-2026-10-02.json)。原独立GPT6 Luna复用，未参与实现；8/8 calls、217.100265秒，未超过360秒原预算，未自动续轮。最终报告SHA a15dc9ddbe3b3e444af0bef51b9195c5acb652316eab26fc20fe32711975c017，root原字节归档，补充完整executable身份仍在同一R4预算内。

两最终executable SHA均匹配allowlist；独立Python遍历thin arm64 LC_SEGMENT_64而非otool文本size，App offset13416/size414、Keyboard offset10266/size423，原始section bytes分别逐字节等于明确配对冻结repo xcent，SHA/plist也相等。两AppGroup均group.com.DoubleShy0N.Universe-Keyboard，application-identifier分别对应主App及.Keyboard；没有发现本项静态字节绑定差异。

H2仅byte-comparison finding现在Resolved by R4 evidence；原R2/R3 Partial与旧缺账不可倒写，R4不重审H1/H3，不替代签名/安装/实际运行/Gate意见。root前后hash保全另存 `/private/tmp/ukey-wake-arch-r4-20261002`。当前源码、产品/Vendor、原R2/R3报告不改；不设备/模拟器/容器/build/test/network/签名修改/Git动作。只授权治理镜像更新，无CHANGELOG/架构合同变化，无M-02触发。

[新环境基线](keyboard-wake-diagnostic-extension-paired-rollout-001-c7b3-environment-rebuild-entry-2026-10-02.md)已正常输入验证，旧数据未恢复限制保持；当前实际套件30次skip仍保留，signed Keychain专项1通过不改写unsigned中的skip。旧整体Hold/F2/F3/57格式diagnostics不因R4消失。下一步是候选晋级前整合验收/本阶段残项处置与安装恢复Entry，需另明确范围；本轮不放行新candidate安装、Maps、arm、LLDB、ProductGate或Release。父子Assignment仍Active，根因未确认。
