# C5-R 单轮真实 appex 回调证据 — 2026-10-01

**本轮授权的采集、Human reader查看与诊断关闭恢复已完成；取得限定宿主/配对/轮次的真实回调正向证据。** 不关闭Parent、不声称根因解决、Maps/整体Quality/Gate/Release通过。完整独立runtime验收尚未执行；本记录为Executor机器证据及Human可见观察，不替代reviewer结论。

## Scope / Identity

Human明确授权独立“搜索”Tab宿主的一次非敏感合成输入、窄采集、同MainApp reader核验与恢复，并确认iPhone18Pro/iOS27.0、UDID405D994F-28CB-4F89-BB22-B64AD81C05A2本轮独占、App未重建。branch codex/keyboard-wake-v3-compatibility-gate，HEAD84b9c19227330b0fe6ff391be001ee398010fd6a，candidate af38fac6758df45f6686ff00845a065157c6679fd57de8dcf015c0e9f283cbd9未变。实际installedApp+内嵌appex111文件与留存Debug全树相同，Entry另核11MachO SHA/size/UUID，收尾111全树再次相同，覆盖真实debug.dylib而非仅stub。568source/build及111built payload逐项匹配，RIME部署状态在Entry稳定。

原Quality host-delta R2 H1–H3 Covered及旧Architecture限制保留；host-delta R1 Partial不改判。C5-only20RimeBridge+10App skips仍accepted/nonblocking/unverified，仍Skipped/notpassed。本轮不重跑测试、不重建/安装/部署。

## 回调证据矩阵

内容无关typed投影见[typed window](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-typed-window.json)。预备窗口与正式UTC start/end见[window](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-window.json)。实际事件UTC02:46:26–02:46:34，对应上海10:46:26–10:46:34。仅一个processInstanceID/appearanceID。

| 对象 | 本轮正向证据 | 限定语义 |
|---|---|---|
| appex lifecycle | view_will_appear、view_did_appear各1，localSeq1起 | 只证明本轮SearchTab出现路径，不覆盖所有唤醒或宿主 |
| RIME resume | started1 | 真实边界执行，不是ready/success或RIME根因 |
| text proxy | 6set_marked_text +1unmark_text entered/returned顺序对，共14标记 | 同process/appearance、localSeq和monotonic正序；returned仅UIKit调用返回 |
| insert_text | 无记录 | 未观察到，不计通过；候选提交可走已记录marked/unmark路径 |
| tail disappearance | 无记录 | 补充观察，原合同非必达；不靠无日志判故障 |
| 同配对MainApp reader | Human在当前App“诊断→查看记录”刷新后确认该时间段三类均可见、无异常提示 | 证明Human可见三类渲染及未观察到完整性/unsupported警告；没有machine逐事件消费或内部拒绝/fallback计数证明 |
| 普通输入 | Human反馈键盘正常、提交有反应 | 无内容状态观察，不等于卡死修复或宿主接受的机器证明 |

总17marker，源动态keyboard_extension段55行，仅导出本窗口三种code的有限v6 envelope/payload元数据，不保存原始行、输入/候选/query/host文本、原始prefs、截图或完整历史journal。目标记录无重复JSON成员/无invalid，但不关闭已知duplicate-member parser残项。Python严格投影不是MainApp reader证明；二者分别记录。只执行1轮Human input，automatic retries0，无补采。

## 恢复及明确残项

Human先于machine基线采样启用了logging/高保真，确认原两项off。原键值/存在性未采到，Entry曾Hold，Human明确[本轮接受处置](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-capture-restoration-disposition.json)，仅接受该非阻塞未验证恢复残项后开始输入；不静默跳过UNKNOWN。原键值/存在性仍未验证，不计通过。

Human完成reader观察后先关闭高保真、再关闭logging。machine[收尾核验](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-final-check.json)确认logging_enabled present=true/value=false；diagnostics_high_fidelity_expiration不存在，高保真inactive；log_category_disp/engine继续不存在，默认enabled，无本轮改动。按已批准的off/off合同恢复，不声称恢复未知的原键值/存在性。未延长期满、修改其他类别/FullAccess/schema/dictionary、清空日志或卸载。原preflight JSON日期序列化错误仅scratch交付失败，修typed-date记录后只读重查，不算输入/设备重试。

## 保全 / Handoff

root唯一repo文档writer，仅新增本轮9份证据及owningAssignment追加；2552其他既有文件逐项不变，完整dirty及输出sha见[final receipt](keyboard-wake-diagnostic-extension-paired-rollout-001-c5-r-final-receipt.json)，staged0，git diff --check通过。没有修改MCP默认profile；只读session-show-defaults，无新增或切换profile。无源码修改/build/test/install/Git发布/Maps/Release；docs-only跳过xcodebuild，无CHANGELOG/架构合同变更。设备操作窗口在final-check记录时结束，原独占只覆盖本轮，不自动延为后续lease。

下一步建议只读独立验收本轮证据，特别核查同源、投影vsHuman reader证明、缺失insert/tail有限语义与恢复残项；该新review需要单独精确packet/预算/授权，不自动派发。Maps/跨宿主/性能/Release/根因诊断均保持未执行及另行授权边界。Parent Active。
