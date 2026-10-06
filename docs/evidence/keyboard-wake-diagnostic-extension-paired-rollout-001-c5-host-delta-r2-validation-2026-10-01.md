# C5 Host Delta Quality round2 — 2026-10-01

**本轮独立只读确认完成，H1/H2/H3 Covered；C5-R仍未授权或执行。** Human授权2底层工具/180秒，第1调用后checkpoint；复用原未参与实现的GPT6LunaQuality reviewer。原round1 Partial、原report/timer及缺失usage记录保持，不追认。

## Scope / Evidence

[原样独立报告](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-host-delta-r2-quality-review.md)、[usage](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-host-delta-r2-quality-usage.json)、[timer](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-host-delta-r2-timer.json)。Packet/manifest/Entry三摘要匹配；HEAD84b9c19227330b0fe6ff391be001ee398010fd6a及指定branch/worktree未变，candidate af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9。26/26输入、568/568源码/构建输入、111/111builtDebug文件hash匹配。第1调用核身份但尚未覆盖hash/source，checkpoint如实披露；第2调用完成核验并写三outputs，未加第三调用。

Reviewer elapsed146.722秒采样在最后timer文件写入前，明确不含timer自身写入延迟。root另保留[文件交付观察](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-host-delta-r2-delivery-observation.json)：三文件mtime相对起点146.724544–146.725058秒；root随后观测三文件可读时为192.925384秒。文件时间支持预算内交付，不能把root观察时刻称为reviewer运行耗时，也不编造精确close后monotonic。原timing备注不改写。

## 正向结论与保留条件

H1：独立“搜索”Tab真实TextField和内存query/catalog成立；onAppear的RimeSettingsStore.load存在条件性首次部署intent写入，不能称页面零副作用；空结果会回显输入，采集禁留输入内容/截图。
H2：原finite三类marker、origin/process/appearance/localSeq/monotonic关联、窄导出/同App reader completeness/键原值恢复/一次轮次无自动重试合同可适用；started/returned语义及duplicate-member限制保留。30项C5 skip仍已接受非阻塞、未验证，不是通过。
H3：无新增必须源码修复的Quality blocker；Product采用新host与C5-R执行尚待授权，须fresh独占窗口、实际installedidentity及部署状态稳定重核。不声称实际appex加载、runtime callbacks、根因、整体Quality/Gate/Release或parent closure。原C5-I安装匹配与FullAccess观察是历史证据，不充当当前设备证明。

## 最小 C5-R 决策／操作包（提案，未执行）

建议Human一次授权采用独立“搜索”Tab宿主，并确认iPhone18Pro/iOS27.0、UDID405D994F-28CB-4F89-BB22-B64AD81C05A2本轮至结束独占。仍用当前C5-I配对Debug载荷，不重建/重装。root在操作前窄核实际installedApp/appex完整身份、必要RIME部署状态（deployed且无deploying/pending intent）及capture键原值/存在性；身份漂移、部署未稳定或未知则Hold，不开始输入。Human/Environment分工：root负责Entry、采集、reader证据、恢复；Human按指引完成UI动作，期间root不并行点击输入宿主。

获授权后，通过已有诊断UI开启logging/high-fidelity默认30分钟及DISP/ENGINE，只改本轮相关键；不延长expiry或开启其他类别。Human进入“搜索”Tab，不点击设置结果，切到UniverseKeyboard一次，完成一次非敏感合成拼写及候选提交，键盘可见约2秒（不是持久化保证），再隐藏一次并仅清除本轮合成query。root仅筛选该UTC窗口动态keyboard_extension-*.jsonl内内容无关typed v6记录，以origin/process/appearance/localSeq/monotonic关联；通过同配对MainApp reader核验消费/完整性/拒绝/fallback。不会保存输入、候选、宿主文本、截图、原始prefs或完整历史journal。

正向判据：新process/appearance willAppear+didAppear；真实resume started；实际执行的至少一个proxy操作entered/returned顺序对；MainApp reader消费及完整性状态；普通输入仅无内容反馈。未调用的proxy路径不计通过；started非ready、returned非宿主接受；disappear尾部仅补充。缺marker/过期/reader不完整/身份变更均Hold或inconclusive，最多一次人工轮次，零自动重试。无论运行成败，恢复本轮确实改动capture键原值及存在性，不清日志、不改FullAccess/schema/dictionary，不Maps/源码/Git/Release。

## Preservation / Documentation

root是唯一repo文档writer，仅新round2证据及owningAssignment追加。2543其他既有文件逐项不变，568source/111built载荷收尾匹配。完整dirty状态及输出hash见[final receipt](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-host-delta-r2-final-receipt.json)，staged0。docs-only，跳过xcodebuild及测试；本轮无Simulator/设备/安装目录/AppGroup/prefs/journal/UI访问，无arming/input/build/test/install/source/Git/Maps/Release。无需CHANGELOG或架构合同变更，Parent Active。
