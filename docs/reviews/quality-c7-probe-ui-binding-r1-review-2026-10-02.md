# QUALITY-C7-PROBE-UI-BINDING round 1

**结论：Partial / incomplete。** 仅评价局部 Debug UI 绑定的静态证据，不表示现场 UI 表现已修复。

| 标准 | 判定 | 依据 |
|---|---|---|
| P1 | Covered | makeCandidateBar 在 CandidateBar.swift:40 安装控件、:49 填充；WakeOwnerProbe.swift:13 的构造期刷新通过 candidateBar 属性取旧 bar。Presentation.swift 三处赋值 Presentation.swift:93→96、138→141、154→157 均在新 bar 赋值后、布局前刷新，覆盖该静态时序缺口。 |
| P2 | Partial | 归档 diff 仅 Presentation.swift，三处新增调用均受 DEBUG 与 KEYBOARD_WAKE_OWNER_PROBE 双重条件保护，无删除；Core、输入/touch、TTL、policy、布局及隐私合同未改。归档语法/格式检查四项 exit 0；这是静态回执，不是runtime测试。 |
| P3 | Partial | 按钮延迟与“观测”文案原因仍未知；源码变化意味着旧候选 installed/runtime 证据不适用于新候选。须对新候选另行冻结并做实际验证。 |

该有限意见不声称 runtime 修复、Maps、engine、Gate 或 Release 通过。
