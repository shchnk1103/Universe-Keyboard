# 隐私文案云端候选：可重建快照

日期2026-11-01，北京时间UTC+08:00。仅保存经过独立静态验收的候选，未应用到原源文件，未通过Mac格式/编译/UI、真实网络/同步或最终包验收。批准表达与既有结论边界见[进度快照](2026-11-01-cloud-launch-checkpoint.md)。本Markdown代码块不是自动执行、源文件修改或manifest修复授权。

固定base/parent：`1ecd9933f83b967fafb27bec8b3a24a498d62bb2`。下面完整unified diff相对该base的两原文件；精确原文可由GitHub按ref取得，不依赖不可访问的本地路径。

| 逻辑文件 | 精确source SHA256 | candidate SHA256 |
|---|---|---|
| [PrivacyDataView.swift](https://github.com/shchnk1103/Universe-Keyboard/blob/1ecd9933f83b967fafb27bec8b3a24a498d62bb2/Universe%20Keyboard/Views/Settings/PrivacyDataView.swift) | 11026a25ac7b95521d9f1ebae8d871e9dba1bc26d28bb1cdab900905e3ab1159 | b55116e3f2ba13304b061fd460c0c8618c6bd69d2402dcc1820aaf9813ee63a0 |
| [PRIVACY_POLICY.md](https://github.com/shchnk1103/Universe-Keyboard/blob/1ecd9933f83b967fafb27bec8b3a24a498d62bb2/docs/PRIVACY_POLICY.md) | 92d71cffe20c6c196638d79ef519e02312ae72098c2355d4bd8e20ba77ba8b77 | 3c7f37623d069ead0eaecdda9c1faf4deafbb387846f44422131d5b256d2408a |

source Git blob：Swift `91ae090c978e43ec8a9718cf2369ffb2125a4c72`；政策`aea45504059b35473bcbc7a77a15e22d66c6db6b`。diff原UTF-8字节SHA256：`b2b0edb62f5b3b0e3e584bca5d1d6f0861f50bc77dbe6a4712eba7578cfd7d35`。

重建（只在新建隔离副本，不能直接对生产目录应用）：取该base两原文件，先核source hash；下方代码块为避免Markdown尾空白，把仅含一个上下文空格的行显示为空行；提取代码块后，在每个@@ hunk内部将空行还原为一个ASCII空格加LF（文件头/其他行不变），按UTF-8保存且保留最后一个LF、不包含围栏，再核diff hash；在副本check/apply后核两candidate hash。任何字节不符停止，不用带额外终止换行的旧摘录替代精确source。原独立重放exit0；此步骤用于可重建性，不豁免后续实际应用授权和Swift格式硬门槛。

```diff
--- a/Universe Keyboard/Views/Settings/PrivacyDataView.swift
+++ b/Universe Keyboard/Views/Settings/PrivacyDataView.swift
@@ -6,7 +6,7 @@
             Section {
                 privacyRow(
                     "键盘输入不上传",
-                    detail: "输入内容、候选、上下文和用户词典不会发送给开发者或第三方。",
+                    detail: "键盘扩展不向开发者或第三方发送输入内容、候选、上下文或用户词典。你在主 App 主动确认的标准 RIME 同步另行处理，见下方“网络”说明。",
                     icon: "keyboard.badge.ellipsis"
                 )
                 privacyRow(
@@ -26,7 +26,7 @@
                 )
                 privacyRow(
                     "候选学习",
-                    detail: "RIME 用户词典和纠错选择学习保存在设备上的共享容器中。",
+                    detail: "RIME 用户词典和纠错选择学习保存在设备上的共享容器中。若你在主 App 确认标准 RIME 同步，词典快照可写入你选择的共享文件夹。",
                     icon: "character.book.closed"
                 )
                 privacyRow(
@@ -55,12 +55,12 @@
             Section {
                 privacyRow(
                     "方案下载",
-                    detail: "主 App 只在你请求下载或更新可选输入方案时访问 GitHub。键盘输入不会加入请求。",
+                    detail: "当你请求查询、下载或更新可选输入方案时，主 App 可能连接 GitHub、南京大学开源镜像或 CNB 下载源。键盘输入不会加入这些方案请求。",
                     icon: "arrow.down.circle"
                 )
                 privacyRow(
-                    "可选的 RIME 云同步",
-                    detail: "默认关闭。开启后，主 App 只把端到端加密的 RIME 设置发送到你选择的 WebDAV 或文件夹；不包含用户词典、输入洞察、日志或输入内容。",
+                    "可选的 RIME 同步",
+                    detail: "Universe 私有设置同步在你选择目的地前保持关闭；设置包离开设备前加密，不含用户词典、输入洞察、日志或输入内容。标准 RIME 同步需另选共享文件夹并确认，可包含用户词典快照及非生成的 YAML/TXT 配置备份，Universe 不对这些文件加密。首次标准同步成功后，自动同步仍需你另行开启；后台执行由 iOS 安排，可能延迟或不执行。",
                     icon: "icloud.and.arrow.up"
                 )
             } header: {
--- a/docs/PRIVACY_POLICY.md
+++ b/docs/PRIVACY_POLICY.md
@@ -11,6 +11,8 @@
 ## Keyboard Input

 The Keyboard Extension does not transmit typed text, unfinished composition, surrounding text, candidates, clipboard content, host-application identity or user-dictionary contents to the developer or a third party.
+
+Separately, when the user selects a shared folder and confirms standard RIME synchronization in the containing App, that operation may place user-dictionary snapshots and non-generated YAML/TXT configuration backups in the selected folder, as described under Optional Standard RIME Sync.

 Full Access is requested so the Keyboard Extension can use the shared App Group container prepared by the containing App, read shared settings, use managed RIME resources, persist local user-dictionary learning, play configured feedback and, when explicitly enabled, update local Typing Intelligence aggregates. Full Access is not used to send keystrokes to a server.

@@ -54,7 +56,7 @@

 The Keyboard Extension does not use network access for input processing or Typing Intelligence.

-The containing App may connect to GitHub when the user requests information about, downloads or updates an optional RIME input scheme. When the user explicitly configures RIME settings sync, the App may also connect to the selected WebDAV or file-provider destination. The About page may open the system mail composer or the linked Xiaohongshu profile only after the user taps those controls; the App does not attach diagnostics or typed content. Keyboard input, Typing Intelligence aggregates, user dictionaries and diagnostics are not included in those requests.
+The containing App may connect to GitHub, the Nanjing University open-source mirror, or CNB when the user requests information about, downloads or updates an optional RIME input scheme. Keyboard input, Typing Intelligence aggregates, user dictionaries and diagnostics are not included in these scheme-information and download requests. When the user explicitly configures Universe private-settings synchronization, the containing App may connect to the selected WebDAV or file-provider destination and transfer the encrypted settings package described above. Separately, user-confirmed standard RIME synchronization may write user-dictionary snapshots and non-generated YAML/TXT configuration backups to the selected shared folder. Universe Keyboard does not encrypt those standard RIME files. The About page may open the system mail composer or the linked Xiaohongshu profile only after the user taps those controls; the App does not attach diagnostics or typed content.

 ## Tracking, Advertising And Accounts

@@ -71,7 +73,7 @@

 ## App Privacy Disclosure

-Data processed only on device and never transmitted off device is not represented as developer collection in App Store privacy details. User-directed encrypted transfer to the user's selected storage destination must be reviewed separately from developer collection. Required Reason API declarations remain separate and accurately describe APIs used for App Group preferences, container metadata and storage-capacity checks.
+Data processed only on device and never transmitted off device is not represented as developer collection in App Store privacy details. User-directed transfers to selected storage destinations, including encrypted Universe private-settings packages and standard RIME files that Universe Keyboard does not encrypt, require a separate assessment of their data contents, recipients, purposes and access. A user-selected destination or the presence of encryption does not by itself determine the App Store privacy-disclosure classification. Required Reason API declarations remain separate and accurately describe APIs used for App Group preferences, container metadata and storage-capacity checks.

 The App Store privacy answers, bundled privacy manifests, product behavior and this policy must be reviewed together before every submission.

```

保留边界：仅四UI row五字面量，P1/P3/P4；P2保持。未新增布局/逻辑/权限/默认值/同步或数据合同；U4长文须在授权Mac/设备验标准和最大辅助字号、滚动无遮挡、VoiceOver完整朗读。后续formatter如改变候选字节，应记录新hash并按影响复核，不能继续把本快照hash冒充实际候选。
