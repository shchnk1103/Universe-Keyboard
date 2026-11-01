# 云端首发准备进度快照 — 2026-11-01

日期：2026-11-01，北京时间（UTC+08:00）。这是进度保存与交接快照，不是产品合同、正式发布门禁或当前运行能力声明；不变更PORTFOLIO及任何已接受合同/任务状态。

## 用户决定与本次保存授权

Human已明确：先免费、中国大陆条件齐后首发，相关备案咨询按浙江省方向准备；后续新增会员，具体权益、价格、时点未定。不得据此默认境外先发、删掉万象/九宫格，或把免费当许可/备案豁免。

Human当前要求“先提交到GitHub保存进度”。本保存任务仅允许Executor在独立功能分支提交本页与同目录候选说明两个Markdown文件；不改生产Swift、xcprivacy、plist、二进制或真实政策，不merge、不开PR、不发布App。PM仅协调，不推分支。责任：Human为Product授权方，Executor为保存执行者，Architecture & Knowledge Steward和Quality, Performance & Release Maintainer分别作独立预检；保存包准备阶段快照（历史）：当时待本保存包预检、尚未创建分支或commit。远端文档保存事实以承载本文件的实际提交和分支为准；文档已保存不表示候选已应用生产源或App已发布。文案内容、云端候选及其既有独立验收与这次保存包预检是不同记录。

本轮重新GET核对main为`1ecd9933f83b967fafb27bec8b3a24a498d62bb2`，根tree `890ea6e02770462ba9d2152516aae3007b219047`；不是把旧研究基线直接称最新。所有下文源码结论固定该ref，发布前如main改变须重新核对。

## 已完成的云端候选

已批准隐私表达修正仅在隔离副本制作：四个UI row中的五个字符串字面量；英文政策P1/P3/P4，P2可选导读未加入。区分扩展不上传与主App标准RIME词典快照同步，分别说明加密私有设置包与Universe不加密的标准文件，下载配置包含GitHub/南京大学镜像/CNB。没有改逻辑、布局、默认值、权限或同步行为。

完整两文件diff、固定source/candidate/patch SHA256、精确源链接和重建步骤在[隐私文案候选](privacy-copy-candidate.md)。候选未应用到原源仓库。静态替换/其余字节不变及独立副本补丁重放已验证；Mac swift-format、编译、U4长文标准/最大辅助字号/滚动与VoiceOver均未验，不能称可合并或已发布。

### 原独立复核快照与身份

以下历史结论仅覆盖其原范围；本次公开保存只摘录结论和hash，不上传内部工具日志。证据等级为`Quality-reverified`仅限独立复核中明确核查的候选内容/重放，未覆盖设备或真实行为。

| 独立记录 | 结论及边界 | 原报告SHA256 |
|---|---|---|
| Architecture设计/包预检 r2 | Pass；冻结表达、设计/包范围，非候选实际运行 | b163388b50ad26020fd9e1597339e7f39e25f9b1fe28c7fe6993dd973bd2256d |
| Quality包预检 r2 | Pass；批准文字映射，非运行验收 | 40361ddd32ea47f70370585c7c4669f0a710e5f2a0ca884cb949ae255e379d17 |
| Architecture候选验收 r2 | Pass；补齐原件映射/追溯；未代Quality或发布 | e87e886e8e6e44eb6b8e664fd7235e401d98f644e9220980a40de5a9b911c40e |
| Quality候选验收 r1 | Pass with conditions；候选及独立重放通过，QCA-01为执行包预算身份标注 | 5456f0e7dc5cbd8de52a693e27b6e020a2a851f088c2142a09c3ea2bfa7fda73 |
| Quality候选增量 r2 | Pass；QCA-01追加更正关闭，原候选hash不变；未重跑相同内容/重放 | 51aac63d1b1a2c20c757c31575a120043709aaea09a731bb5b0b3839fa6bf435 |

旧预检包SHA256 `466630df6d897fd992baa21bb767497e558beba6e34ae42e20e359be6c7a0e42`；实际执行包SHA256 `945d085c9f7ca58a141c74df0891d3aefc7a356d29f45de721d85c422cc52c09`。差异仅补显式16调用/12分钟预算及checkpoint，技术方案未变，不能把两者说成字节身份相同。既有流程残项不由此快照接受或删除。

## BT-01：Extension SystemBootTime静态声明缺口

[CommitTraceRecorder.swift](https://github.com/shchnk1103/Universe-Keyboard/blob/1ecd9933f83b967fafb27bec8b3a24a498d62bb2/Packages/KeyboardCore/Sources/KeyboardCore/CommitTraceRecorder.swift#L62)默认clock为`ProcessInfo.processInfo.systemUptime`；[KeyboardViewController.swift](https://github.com/shchnk1103/Universe-Keyboard/blob/1ecd9933f83b967fafb27bec8b3a24a498d62bb2/Keyboard/Controllers/KeyboardViewController.swift#L76)构造时未传clock，且第492行从日志display开关设置enabled。这些语句不在DEBUG内；enabled默认false及lazy构造是运行门禁，不是编译排除。尚未验证实际Release触发、最终链接/包字节。

[Keyboard PrivacyInfo](https://github.com/shchnk1103/Universe-Keyboard/blob/1ecd9933f83b967fafb27bec8b3a24a498d62bb2/Keyboard/PrivacyInfo.xcprivacy)只有UserDefaults与FileTimestamp，未列SystemBootTime。[Apple官方DocC原文](https://developer.apple.com/tutorials/data/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype.json)的`$.primaryContentSections[1].values[1]`明确将systemUptime归入SystemBootTime。35F9.1可用于App内事件经过时长/计时器，并有访问/衍生信息离设备限制及事件时长例外；它是当前差值用途的候选理由，完整消费/导出仍须核，未自动改manifest、不保证审核。

主App链接共享包不等于其实际使用或最终保留该API，不能一律说两份manifest都必须加。下一步由Keyboard/Privacy/Architecture评估正式修订Extension类别/理由，或提供Release排除证据；Quality核同一候选最终包。其他reason API全仓/SDK覆盖、签名entitlements、最终资源收录及真实行为仍待证。项目使用同步资源组，不因无显式PrivacyInfo引用就判漏包。

## 许可、大陆办理及首发依赖

- 许可准备为Partial。固定vendor归档不能填补[librime-lua精确source revision缺口](https://github.com/shchnk1103/Universe-Keyboard/blob/1ecd9933f83b967fafb27bec8b3a24a498d62bb2/Universe%20Keyboard/Models/ThirdPartyLicenseDescriptor.swift#L103)；octagram根BSD与GPL文件头残余须保留来源/阈值决定；雾凇GPL下载/修改、万象CC署名/修改、Luna多来源署名需对应真实交付逐项核，不以项目根MIT覆盖第三方。参考[固定artifact说明](https://github.com/shchnk1103/Universe-Keyboard/blob/1ecd9933f83b967fafb27bec8b3a24a498d62bb2/docs/architecture/rime-artifacts.md)、[GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)、[CC BY 4.0原文](https://creativecommons.org/licenses/by/4.0/legalcode.en)。免费、用户主动下载或勾选不是自动免责；GPL本身不等于禁止收费。
- 浙江咨询资料已准备，未发送/申请、未有本产品个案答复。以[浙江省通信管理局联系页](https://zjca.miit.gov.cn/wzpz/lxwm/art/2020/art_28c5348af655422695a0887c6cc39e93.html)和有权渠道确认实际APP受理路径、个人主体材料、网络资源、编号及后续会员影响；不把ICP咨询入口等同本产品已可办或已备案。参考[MIIT通知](https://www.miit.gov.cn/zwgk/zcwj/wjfb/tz/art/2023/art_920db564162e4312916a01bed6540ad8.html)、[Apple App信息](https://developer.apple.com/cn/help/app-store-connect/reference/app-information/app-information)。不在公开进度保存中放真实身份材料、账号、凭据或设备资料。
- 万象九宫格首发前置保留；原设计/实施接续及同一最终候选的工程/设备/Full Access/恢复/稳定性/性能/RIME/Lua/OpenCC验收仍需相应输入与授权。TestFlight例外或云端文本Pass不等于正式发布Gate。

下一步：先完成本docs-only保存包独立预检，再由Executor按授权提交独立功能分支；后续由对应owner补BT-01、资产/来源、浙江个案与同候选证据。Mac环境及操作者由Human提供/确认，仓库应用真实代码、合并、商店提交和App发布分别核授权。本快照不新增Ready/Closed或接受任何未决风险。
