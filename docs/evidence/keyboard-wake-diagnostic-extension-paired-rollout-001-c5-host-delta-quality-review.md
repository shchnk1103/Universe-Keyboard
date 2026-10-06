# QUALITY-C5-HOST-DELTA 独立 Quality Review

## 范围与身份

本轮只读评估 C5-R 候选宿主从“本地词典 searchable”切换为 Settings 中 SearchTab 的影响，不作 host/Product acceptance，也不授权 C5-R、输入或设备操作。Packet、manifest、Entry SHA 分别为 3469778494804a0b6c4682923c44baf809b7671535d3bc0ab45f042a08a78afd、69b8179e3549d0f487253b23a98f03c8ea4f6fcb2c4c0010301b01db2434c48b、5c2432915d2dfa75d964c1dcd5eb7dd22824b73466e06847943e46d5617a8012，均匹配。HEAD、branch、candidate 匹配；22/22 输入文档、568/568 source/build 文件、111/111 built bundle 哈希匹配。

## H1–H3 正向覆盖

| Criterion | 结论 | 依据与边界 |
|---|---|---|
| H1：SearchTab 状态、catalog 与 onAppear load | Covered | SearchTab 的 @State query 和真实 TextField 是可输入宿主；SettingsSearchCatalog 仅在内存静态目录中匹配。没有看到 query 的直接网络或持久化路径；无匹配项时页面会把 query 显示在空结果文案中。SearchTab.onAppear 调用 RimeSettingsStore.load；该函数加载设置后会调用 seedFirstLaunchBuiltinDeploymentIntentIfNeeded 与 refreshDeploymentState，因此不是纯读取合同，首次/缺状态路径可能改变部署 intent 或刷新部署状态。现有旧状态观察不能证明未来安装环境处于相同状态。旧 DictionaryBrowser 使用 .searchable、query onChange/scheduleRefresh 和 task/loadIfNeeded，与 SearchTab 的执行路径不同。定位：SearchTab.swift:12、56、41、95；SettingsSearchCatalog.swift:188；RimeSettingsStore.swift:207–247；DictionaryBrowserView.swift:29–46。 |
| H2：原采集、隐私、reader 与单轮边界 | Covered | 三类 typed marker、同 origin/process/appearance/local sequence/monotonic 时间关联、窄日志筛选、同 App reader completeness、原值恢复、一次操作/不自动重试的合同仍适用。新宿主额外带来 SearchTab 首次显示时的 RimeSettingsStore.load，以及无匹配项时 UI 回显 query；可用非敏感合成输入、不留查询文本/截图、确认 RIME 状态稳定后再开始一次采集来控制。30 个 C5 skip 是已接受但未验证 residual，不由本 reviewer重作 Product 接受；marker started/returned 不等于成功，duplicate-member reader 限制保留。 |
| H3：本 lane 结论与 future Entry | Covered | 只读源码支持 SearchTab 作为实际输入字段的候选宿主；未发现必须改源码或改 wire/capture schema 的 Quality blocker。尚需 Product 决定是否采用此 host。未来 C5-R 未授权；其 Entry 仍需精确当前安装身份、RIME 部署状态稳定、fresh exclusive window，以及明确的键盘切换、合成输入、采集和恢复授权。 |

## Findings

- **HOST-Q-01 — 条件性部署状态副作用（future Entry）。** SearchTab.onAppear → RimeSettingsStore.load 会条件性 seed 首次部署 intent 并刷新部署状态。责任人：Environment Executor。最小建议：C5-R 前确认 C5-I 已初始化且 RIME 状态稳定；若首次部署/状态变更发生，停止该轮输入采集，不能称零副作用。
- **HOST-Q-02 — 页面可能显示输入 query。** 空结果视图会显示未匹配文本。责任人：Human 操作者/Environment Executor。最小建议：只用非敏感合成 query，不保存/截图页面或复制 echo 到日志。
- **HOST-Q-03 — host 选择仍由 Product 决定。** Quality 只能说明候选的代码与副作用边界，不能代 Product 接受 SearchTab 或授权 C5-R。

## Verdict

H1–H3 覆盖完成；**本只读 host-delta Quality review 未发现新增设计级 Quality blocker**。SearchTab 的 load 副作用和 query echo 必须保留为未来 Entry 约束。C5-R、Product host 决定、设备/安装/真实 callback 验证仍未完成或授权。本轮未访问设备、安装目录、App Group、UI、prefs 或 journal；未执行 build/test、输入/采集、网络或 Git mutation。