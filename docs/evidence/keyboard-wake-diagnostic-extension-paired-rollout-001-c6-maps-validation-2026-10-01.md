# C6 Maps App Switcher 观察交付 — 2026-10-01

本轮Human在原精确iPhone18Pro/iOS27.0模拟器复现：**只打开AppSwitcher再直接回Maps后，键盘有按键反馈，候选栏和宿主输入框不更新。** 切换前基线正常；先切到系统设置再返回Maps的路径导致键盘关闭重开，未复现。两条Human变体共用一个机器采集窗口，不能伪称严格单次计划路径或两份独立受控运行。无automatic retry。

范围为现有Debug同配对candidate的诊断观察/有限采集/reader/恢复，未改源码、构建、安装、重新部署或发布。source568/built111/installed111开头及收尾一致，11Mach-O开头SHA/size/UUID匹配；目标405D994F-28CB-4F89-BB22-B64AD81C05A2，本轮Human确认独占和FullAccess。Maps版本1.0/build2972.30.6.12.58。candidate af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9，HEAD84b9c19227330b0fe6ff391be001ee398010fd6a。

证据：[preflight](keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-preflight.json)、[原症状绑定](keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-human-reproduction-binding.json)、[切换前基线](keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-baseline-observation.json)、[两条本轮路径观察](keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-human-transition-observation.json)、[window](keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-window.json)、[typed有限投影](keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-typed-window.json)。采集window UTC06:38:45.734675–06:50:12.335401，对应本地14:38:45–14:50:12；实际目标事件UTC06:39:22–06:46:05。Human阶段确认时间是反馈接收时间，不冒充动作/callback精确时间。

三家族30事件：4lifecycle（2willAppear/2didAppear）、2resume started、24set_marked_text（12entered/returned对），涉及2process/2appearance。第一个group23事件14:39:22–14:40:00，第二个group7事件14:46:01–14:46:05。仅能确认这些finite调用边界及身份；没有标记直接证明哪个group对应失败变体、故障时按键是否到达Core/RIME，不能由最后事件或缺事件推出根因。started非ready，returned非Host接受；没有insert_text/unmark_text或tail证据，不报通过。无自动额外读取其他family/新trace。

[Reader有限UI快照](keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-ui-snapshots.json)、[显示多重集对应](keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-reader-comparison.json)：同MainApp reader显示172/172总条数，关键词phase_changed命中50/172（混合历史窗口，不作本轮数量）。仅保留本轮14:39/14:40/14:46三家族有限行，逐snapshot Counter再逐行取跨snapshot最大值，保留同秒重复数。30/30expected/observed一致，缺失/额外均0；14:40:00 entered/returned各4，14:39:33各2均计齐。Seq34–37未见相应不完整/不支持/不可用/预算/partial警告。只是可见状态与显示覆盖，未读取隐藏reader内部计数器；UI不显示process/appearance/localSequence，隐藏身份绑定依赖原typed投影/同源历史链，不从显示行反推逐条隐藏ID。

[恢复核验](keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-restoration-check.json)、[收尾核验](keyboard-wake-diagnostic-extension-paired-rollout-001-c6-maps-final-check.json)：本轮先机器采原值/存在性，再Human开启；窗口结束后Human关闭，再reader只读历史。logging_enabled存在false、expiry不存在、DISP/ENGINE键不存在，全部精确恢复，与旧C5-RUNKNOWN恢复残项分开。原MCPactive profile恢复且未持久改配置；运行独占窗口在收尾结束，未来设备动作须新的当前授权/独占Entry。

当前结论：**Human复现已记录，窄时间线及30/30reader证据交付，精确恢复完成；故障层次与根因仍未证明。** 两变体缺独立机器边界是本轮重要证据限制，未被自动accept为新非阻塞残项。未来限域Quality独立验收/源码边界分析或单独直接AppSwitcher复现需要另定精确scope，不自动加轮、探针或修复。原30skips仍Skipped/unverified，阶段accept不自动carryC6；旧reviews/Partial/恢复残项保持原边界。ParentActive，无整体Quality/Product/Release Gate、fix或closure。

本轮仅诊断和文档归档，无build/test/Release，docs-only跳过xcodebuild。不涉及shipping行为/架构变化，无需CHANGELOG/ADR修改。禁止清空journal、原C5 window或历史证据；其他既有dirty文件保全。
