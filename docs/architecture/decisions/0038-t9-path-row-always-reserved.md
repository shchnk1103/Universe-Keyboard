# ADR 0038: T9 path row always reserved

Status: Proposed
Date: 2026-10-26 Asia/Shanghai

## 背景

S4观察到首键后第二次触摸可能接收于ABC，但没有远端宿主屏幕原点轨迹；S5只证明受控host下的几何差异，不能归因全部历史错行。Human选择消除首键触发的路径行高度变化。产品决定见 [T9-PATH-ROW-RESERVED-001](../../product-decisions/T9-PATH-ROW-RESERVED-001-product-decision.md)。

## 决定

用编译期策略默认选择always，保留adaptive。区分实际行预留与内容展示：always在合格表面始终排版34pt，同时请求与UI-4预算含34；空内容隐藏交互内容和可访问性，不折叠实际行。生产默认不提供设置开关。不改变高度协商或触区快照算法。

已知行为（方案 A 的有意表现，非已验证的产品效果）：有组字（composition）或 Recovery 但路径列表（paths）为空时，预留的34pt仍保留、内容隐藏且不可点，也不显示退休提示；以后若要在此情形显示其它内容，需要Human另行决定。

## 被替换设计与恢复

被替换设计：`KEYBOARD-T9-ADAPTIVE-ROW-001`，在本轮 main 上最后保留该设计的提交为 `cd16fcb143f74a08cb3d6eb4f837a369a71d4317`（归档基线，不声称该提交引入设计）。行为：新空闲周期0pt，首次有效 composition/Path/Partial Commit/Recovery 信号后锁存34pt，直到明确结束并重新出现。基线另存本地标签 `archive/t9-adaptive-path-row`，不推送。恢复需选择 `T9PathRowReservation.adaptive`，核对 `KeyboardViewController+T9PinyinPath.swift` 的 latch/高度与可见性、`T9PinyinPathBarView.swift` 的行折叠、控制器策略入口及相关测试，并另行取得产品授权、同步合同；不通过恢复旧提交覆盖 #244/#247。

## 后果

首键前后四行根坐标不因路径行而改变；代价是空闲增加34pt，844pt竖屏上限87→78，保存值不变。空白透明行沿用键盘surface背景，空内容无分隔线；有内容沿用原路径/候选分隔线。其它布局不受影响。

必须保留adaptive回归，新增main失败/修复通过证据，完整模拟器套件两轮和KeyboardCore。模拟器不代表真实Extension或UITouch；Human iPhone13 Pro至少10轮与外观验收待阶段B。Architecture状态仍Proposed，独立Architecture/Quality由Human另派。
