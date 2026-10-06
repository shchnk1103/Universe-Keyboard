# C6 Maps 一次受控复现步骤 — 待Full Access确认

身份与原值：[本轮preflight](keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-preflight.json)；职责/边界：[preliminary Entry](keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-preliminary-entry-2026-10-01.md)。run C6-MAPS-20261001-01，原精确iPhone18Pro/iOS27.0模拟器，本轮Human独占。Human绑定的历史症状见[内容无关记录](keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-human-reproduction-binding.json)。历史观察不是本轮结果。

目标：切换前正常；AppSwitcher离开再返回Maps后，键盘可见且按键视觉/音/震动反馈正常，但候选与宿主文本更新停滞。只采一次受控切换流程，零自动retry。历史离开时是否有未提交composition及另一宿主未明确；本轮明确保留一段未提交合成composition，切到系统设置后再返回Maps，作为该症状的受控变体，不伪称完全恢复所有历史条件。无网络搜索提交或真实地址输入要求。

1. FullAccess当前仍开启由Human确认后，root完成Entry确认；Human保持Maps未操作。只有root指引后，在现有诊断UI打开logging/首屏高保真（默认30分钟）。不改DISP/ENGINE默认类别、通知、hitbox或其他设置。root只读四键确认gate与expiry，并建立本轮UTC采集start；不提前输入。
2. Human打开Maps搜索框并确认Universe Keyboard可见，用短合成拼音做切换前基线，观察按键反馈、候选变化及输入框预编辑反应。保留未提交composition，不点击地图搜索提交。仅报告三层响应状态，不提供文本/候选内容。若基线失败，停在现场，本轮不能称切换后故障，不继续切换。
3. 基线正常后Human通过AppSwitcher切到系统设置，再通过AppSwitcher返回原Maps搜索框一次；不划掉App卡片，不切输入法，不重启。root/Human记录各步骤确认时间为观察时间，不冒充callback精确时间。
4. 返回后只按少量拼音键观察三层响应：按键反馈、候选变化、宿主预编辑变化。任一异常立刻停，不反复敲击、不尝试恢复；如果正常，仅可一次候选提交观察宿主是否更新，然后停。采集结束前不返回Universe主App，不改开关；root记录window_end，窄采集本窗口内容无关typed lifecycle/resume/proxy记录、过程/外观/sequence/monotonic与计数。
5. Human回同配对Universe Main App reader，刷新/按本轮有限code时间筛选，root核新窗口显示和实际警告状态；原17条与本轮数量不混用。不copyall/截图/清空；不保存宿主或candidate内容。然后按机器先采到的原值和原存在性恢复四键，machine复核、收尾身份保全，结束本轮独占窗口。

本轮事件数未知：只按实际执行路径和窗口解释，不预设17条，不因缺insert_text/tail重试。started非RIME ready、returned非Host接受。恢复原值/存在性无权限缺口时可用仅四键的精确恢复；不得删除其他prefs键或journal。诊断窗口若到期/身份漂移/读拒绝/必要证据缺失停止，不放宽budget或扩大source/trace范围。一般预计10分钟内完成，30分钟expiry不得自动延长。

当前FullAccess待确认，未arming/未开始window；用户明确执行授权持续有效，无需重复授权。无build/test/install/redeploy/source/Git/Release。本轮结果、未来独立审阅和Product/Quality Gate分开；30skip未验证，不自动carry accept。若无复现仅not reproduced/inconclusive。

## Post-capture sequencing update

本轮窗口已结束且30条finite typed事件已封存；为减少reader筛选期间新增记录，先Human关闭logging/高保真、machine核四键原值/原存在性，再同MainApp只读reader查看历史。关闭不清除历史，不重置原window，不扩展采集范围。该顺序属于既有restore/reader授权，目标与Exit不变。
