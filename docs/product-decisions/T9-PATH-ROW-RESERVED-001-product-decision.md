# T9-PATH-ROW-RESERVED-001 — 九宫格路径栏始终预留

状态：Accepted by Human

## 决定来源

Human Product Owner，2026-10-26 Asia/Shanghai，S7 任务包及本会话匹配 SHA-256 的激活授权；授权原文保存在外置 reports/human-authorization-issued.md。

- “我发现苹果原生键盘也是直接预留了拼音栏的位置，我们可以先存档现有自动出现的这个功能。”
- 他肉眼从未看到键盘在屏幕上往下挪，所以不再做屏幕录像（S6 已取消）。
- 此前的倾向：“希望拼音栏可以在需要的时候再出现”，现已被上一条取代。

## 决定与边界

选择方案 A：中文九宫格字母页且 T9 readiness 成立时，路径行始终预留34pt，初始空闲总高由254变288（默认行高45）。空内容为空白、无空 Path 交互或 VoiceOver 元素，不恢复退休提示。有内容照常显示。26键、英文、数字、符号、emoji和fallback不自动增加34pt。

固定部分始终含34；844pt竖屏、保存行高87时有效上限78，总高420≤422，保存值不改。其它UI-4条款、#244高度协商、#247触区几何、候选展开、Recovery与Partial Commit不变。KEYBOARD_LAYOUT原第95/96行冲突以“始终预留”为准。此为产品选择，不是D4根因结论或真机验收；阶段A仅本地实现，独立评审和Human真机复测后另授权发布。

## 旧设计存档

被替换设计：`KEYBOARD-T9-ADAPTIVE-ROW-001`，在本轮 main 上最后保留该设计的提交为 `cd16fcb143f74a08cb3d6eb4f837a369a71d4317`（归档基线，不声称该提交引入设计）。行为：新空闲周期0pt，首次有效 composition/Path/Partial Commit/Recovery 信号后锁存34pt，直到明确结束并重新出现。基线另存本地标签 `archive/t9-adaptive-path-row`，不推送。恢复需选择 `T9PathRowReservation.adaptive`，核对 `KeyboardViewController+T9PinyinPath.swift` 的 latch/高度与可见性、`T9PinyinPathBarView.swift` 的行折叠、控制器策略入口及相关测试，并另行取得产品授权、同步合同；不通过恢复旧提交覆盖 #244/#247。
