# CHANGELOG

Change history for Universe Keyboard. Entries are in reverse chronological order.

## 2026-07-23 — Residual-B Path-ledger cursor（单字/多字统一）

- Gate 5 residual-B：**Path 游标**。用户已 Path 点选前缀后，候选确认推进 `K=min(CJK字数, 剩余用户Path栈)` 站；数字消费跟音节走（非 `dropFirst(K)`）。
- 下一站若用户曾点选 → Path 展示该槽选项并 **soft-select**（如「请」→`wei` 选中；「请喂」→`fan` 选中）。栈耗尽（「请喂饭到」）→ `wo…` **无**伪造选中。
- 触发：多音节用户栈 **或** unchanged-raw；保留 `qiu→球` 等单音节 pure-digit nested partial。Host 无内部数字。
- 自动化：KeyboardCore **712 / 1 skip / 0 fail**。**Human residual-B 真机 Pass**（2026-07-23）。PD：`PD-…-GATE5-RESIDUAL-B-PATH-LEDGER-PEEL` Accepted。

## 2026-07-23 — 完整 Path 目录、原子呈现与 Gate 5 residual（KEYBOARD-LAYOUT-9KEY-PINYIN-004）

- 九键 Path 改为本地完整音节目录驱动（compile-time catalog + progressive focus），Path Bar 固定高度横向列表展示当前焦点全部可选项，不再依赖扩展候选窗「刷完才有 Path」。
- 原子 composition revision：候选与 Path 同快照发布；前缀只锁定拼写、完整音节可推进；Partial Commit / Delete 保留 Path 身份时禁止把内部数字泄漏到 host marked text。
- Gate 5 β-limited：`T9CompositionIdentity` 处理 shortened remainder 与 typo Append/Delete；engine-only unchanged-raw 仍 fail-closed（不猜槽）。
- Human residual H5：多位 progressive 以 Core `sourceDigits` 为 SoT（消除幽灵 JKL）；Path 选择后重投影剩余拼音、不丢尾；短串 `da→JKL→删→MNO` Path 与 `dao` 候选对齐。
- 自动化：Gate5 定向矩阵含 Human residual 回归；完整 Human Product Gate 仍不宣称通过。权威见 Assignment 004 与 PD post-β residual。

## 2026-07-22 — T9 Path 原子快照与固定前台成本（KEYBOARD-LAYOUT-9KEY-PINYIN-003）

- Path 直接点击不再执行按拼写数量增长的 `replaceInput → candidateWindow → restore` 循环；一次推进最多 `1 replaceInput + 1` 个固定 48 项只读窗口。
- KeyboardCore 新增 composition revision；候选选择先失效旧 segmented snapshot，再从新余段发布 Path。完整 `qing/wei/fan/dao → 请喂饭到` 回归会立即切到 `wo`。
- 所有 composition marked-text 更新经过带来源边界：内部数字投影 fail closed，显式数字页 suffix 和候选确认前缀中的合法数字保留。Runtime fail-close 后 Return/符号也不再提交遗留 T9 raw。
- `qiu → 球 → Delete` 与 `qiule → qiul` 的现行 Product Decision 语义保持。Stage A pinned-RIME 与定向 Core 测试通过；iPhone 13 Pro 可感知延迟及交互 Product Gate 仍待人工验证。

## 2026-07-21 — Path Bar 局部替换与焦点 Delete（KEYBOARD-LAYOUT-9KEY-PINYIN-002 Amendment H）

- Path Bar 选择只替换对应拼音片段并保留用户已输入的未选择后缀：`qiu le → qiule`，选择 `shu` 则为 `shule`；RIME 新排名出的 `ke` 不得覆盖原有 `le`。
- 候选「球」后的第一次 Delete 精确撤销为 `qiule`，并恢复 `qiu'53` 锚定 raw；安全的删除前 marked-text 快照优先于重建产生的 `qiu5` 等混合内部串。
- 第二次 Delete 按当前未确认焦点删除 `l`：内部 `qiu'53 → qiu'3`，可见 `qiule → qiue`。任意含 ASCII 数字的 T9 preedit 均不得进入 host。
- focused qiu 完整序列曾通过；最后的 refined-raw 通用修正因 Codex 执行额度耗尽尚待复跑。Grok 接手说明见 `docs/assignments/keyboard-layout-9key-pinyin-002-grok-handoff-2026-07-21.md`，Product Gate 保持 Pending。

## 2026-07-21 — 九宫格确认前缀、完整音节与逐键显示（KEYBOARD-LAYOUT-9KEY-PINYIN-002 Amendments E/F/G）

- Path Bar 确认 `qiu` 后，RIME session 以 `qiu' + 剩余数字` 锚定；输入框只显示已确认的 `qiu`，候选与后续路径必须继承该前缀，失败则整次回滚。
- 对剩余数字优先执行有界完整音节探测（最多 6 位、48 次 live-RIME probe），例如 `53` 可同时提供经 RIME 授权的 `ke / le`；单字母分支仅作为后备，不再让候选页稀疏度替用户缩窄选择。
- 普通九宫格逐键输入最多显示一个字母槽位：`8 → t`、`86 → to`、`868 → tou`。RIME 可继续在内部预测 `ta / tong`，但预测不会提前进入输入框，内部数字也不会暴露。
- 自动化验证：T9 Path `46/46`、布局与运行时 `14/14`、KeyboardCore 全量 `647/647` 通过；最终 Debug 真机包已构建并安装到 iPhone 13 Pro（iOS 27.0），空白备忘录首按 `TUV` 实测只显示 `t`。Device Hub 后续窗口焦点不稳定，`to / tou` 与 `qiu → le` 完整矩阵仍保持 Product Gate Pending。

## 2026-07-21 — 九宫格剩余拼音与可见字符删除（KEYBOARD-LAYOUT-9KEY-PINYIN-002 Amendment D）

- 修复 `toutoumaiqiule → 偷偷买` 后把 `748 53` 当显示文本及整串 provenance 的问题：空格/撇号分隔的数字尾巴现统一识别为内部 raw，剩余状态对齐到 `74853 / qiu le`，Path Bar 不再错误回到 `t / u / v`。
- T9 host preedit 不再回退显示内部数字；无有效 comment 时只保留显式 refine 字母，session fallback 保留最后安全拼写。
- 普通未确认 Delete 改为删除最后一个可见拼音字符并 exact-refine：`tou → to → t → 空`，不再因较短数字串重新排名而跳成 `tong → ta`。显式分段与 Partial Commit checkpoint Delete 合同不变。
- 新增 spaced-tail、`qiu` provenance、digit-bearing comment/fallback、exact Delete 与双失败 fail-closed 回归。KeyboardCore `642/642`、RimeBridgeTests `28` passed + `4` fixture skips、主工程 `127/127`、Debug/Release 严格构建通过；真机交互与延迟 Product Gate 仍待复核。

## 2026-07-21 — 九宫格长输入保持用户选择（KEYBOARD-LAYOUT-9KEY-PINYIN-002 Amendment C）

- 修复长串分段输入确认 `xian / zai / you` 后，下一焦点因只检查前 16 个候选而收缩成单个 `yi` 的问题：音节发现改用有界 48 项窗口。
- 精确音节不足 5 项时，继续用当前物理键组做有界 live-RIME 探测；仅发布 comment 明确授权的分支，不引入静态拼音图、笛卡尔展开或第二候选引擎。
- 每次推进后的 path focus 都保持未选中；即使 RIME 确实只授权一个选项，也不会代替用户选择、确认或继续推进。探测逐次恢复原始 raw，失败沿用完整事务回滚。
- 新增首屏 16 项之后仍有合法音节、单个精确音节仍需补充分支、无隐式选择与 session raw 恢复回归测试。Focused Core、KeyboardCore 全量、RimeBridgeTests、主工程 Simulator 测试及 Debug/Release 严格构建通过；真机长输入与延迟 Product Gate 仍待执行。

## 2026-07-20 — 新用户启用旅程与 Full Access 文案边界（RELEASE-2026-0801-03，Conditional Pass）

- Product Decision `PD-RELEASE-2026-0801-03` 与产品源 `docs/ONBOARDING_ACTIVATION.md`：定义添加键盘 → 完全访问 → 准备资源 → 首次输入清单、canonical 文案边界与 Full Access 能力矩阵。
- 主 App「启用指南」改为可重入激活清单：诚实说明系统无法代开键盘/完全访问；诊断项收入高级折叠区。
- 纯状态模型 `ActivationChecklistState` 与单元测试 6/6 PASS。
- 真机矩阵（iPhone 13 Pro / iOS 27 beta 3）：FA 关仍可唤出键盘且 `nihao` 候选与 FA 开一致；可感知差异主要为按键震动；无降级提示。Product Gate **Conditional Pass**；TD-004 残留 follow-up（矩阵保真 + Extension 可见降级）。

## 2026-07-20 — T9 Partial Commit 剩余显示与 path 刷新

- Partial Commit 在 T9 下剩余 preedit 走 `T9PreeditResolver`（comment 优先）：选「你好」后 marked 为 `你好ya`，不再泄漏剩余 raw 数字 `92`。
- 当 librime **保留整串 digit raw** 时，Core 按剩余拼音字母数剥离未确认后缀（`6442692` + `ya` → `92`），path bar 按剩余键重建（`wa/ya/za` + `w/x/y/z`），不再误用首键 `m/n/o`。
- 整词 compact 合并改为**先首音节、再首键字母**（上限 5），避免字母位挤掉 `ya`。
- **Delete 恢复 / checkpoint**：`previousDisplayText` 取宿主 marked / comment 预编辑，不再误存 T9 raw；恢复走 `applyRimeOutput` 的 T9 显示路径；无引擎 fallback 删除禁止把 digit raw 写回宿主。
- `PartialCommitControllerTests` 覆盖剩余剥离、path 重建与 Delete 不泄漏数字。

## 2026-07-20 — 九宫格 path bar 音节级渐进（KEYBOARD-LAYOUT-9KEY-PINYIN-002 Amendment B）

- 整词态 compact 栏禁止展示整句多音节路径（如 `ni xian zai` 叠字）；只保留**首音节**（`mi` / `ni`…）+ **首键字母**（`m` / `n` / `o`），上限 5。
- 确认已选首音节后，下一段改为**音节级**选项（`xian` / `zhan`…），由 live RIME comment 在对应分段索引授权；若无多字母音节则回退到下一键字母组（`g` / `h`）。
- **直接点击** path 选项：一次即确认并推进下一段；**选拼音**仅在当前焦点 first/next/wrap 暂选，不负责确认推进。
- Path bar UI 强制单行截断，避免固定 34pt 行高内换行重叠。
- 聚焦测试 `T9PinyinPathTests` 全绿；独立 Architecture/Quality 与真机 Product Gate 仍属 002 未关闭项。

## 2026-07-19 — 九宫格单键精准选项与选拼音循环（KEYBOARD-LAYOUT-9KEY-PINYIN-002，Active）

- `MNO` 等单个九键按键现在从 KeyboardCore 的规范键位身份生成完整有序选项；`6` 即使在 RIME comment 只有 `o` 时也显示 `m / n / o`。多键路径仍由兼容 RIME comment 决定，不新增候选引擎。
- **选拼音** 改为首次/下一个/循环选择，并与路径直接点击共用同一事务式 `replaceInput`；成功 refine 保留单键选择快照，失败完整回滚，所有生命周期边界清除陈旧授权。
- 选中路径现在复用首选候选的反转色圆角高亮；初始无高亮。显式选择后，宿主 marked text 严格显示当前 `m/n/o`，不再被首候选的完整拼音 comment 覆盖；失败切换恢复此前显示。
- 固定 34 pt 路径栏、候选栏几何和 Extension session-only 边界不变；前序完整路径面板不再由产品交互入口打开。
- pinned librime `1.16.1` Spike 已证明 `m / n / o` 均返回非空中文候选且不提交文本；KeyboardCore 全量测试、RimeBridgeTests、主工程 Simulator 测试及 Debug/Release 严格构建通过。独立 Architecture/Quality 审查、clean-commit Spike 和真机 Product Gate 仍待完成。
- Amendment A 新增分段消歧状态机：`MNO → GHI` 的整词态显示 `mi / ni / m / n / o`；已暂选的 `n` 会跨后续数字保持焦点和选中态，点击已选 `n` 才确认并推进到无选中态的 `g / h`。**选拼音**只在当前焦点循环，活动 T9 的空格标题为 **选定**且仍提交首个/高亮中文候选。
- 最终 pinned-librime 硬门证明 `n'g / n'h` 的 live comment 含对应第二分段，而 `n'i` 仅产生无第二分段的回退 comment；机器断言为 `authorizedSuffixes=g|h`。实现使用每个物理键至多 4 次有界 session probe，不维护静态拼音图；聚焦测试 `34/34`、KeyboardCore 全量 `628/628`、Debug/Release 严格构建通过，交互 Product Gate 仍按独立证据处理。

## 2026-07-19 — 九宫格精准选拼音（KEYBOARD-LAYOUT-9KEY-PINYIN-001，Accepted / Closed）

- Product Decision + Assignment `Ready→Active→Accepted / Closed`；ADR 0020 扩展 ADR 0018：混合 T9 raw input、composition refinement、comment 路径来源；双 revision（`rawInputGeneration` / `provenanceRevision`）与 new-output hard apply。
- 真实 librime Spike **PASSED**（pinned 1.16.1 / `t9`）：`replaceInput` 字母 refine 无 host commit；`64→ni`；继续输入得 `ni4`；BackSpace 正常。证据：`evidence/keyboard-layout-9key-pinyin-spike/20260718-201043/`。
- KeyboardCore：`T9PinyinPath*`、`selectT9PinyinPath`、`t9PinyinPathsChanged`、扩展 `T9CompositionCommitPolicy`；`T9PinyinPathTests`（21）+ 全包自动化矩阵（Codex rereview-5）。
- Keyboard Extension：固定 34pt 精准拼音栏、「选拼音」完整路径面板（与候选展开互斥）；panel 绑定 provenance revision。
- Codex Architecture + automated Quality **Pass**（rereview-5）；Human 真机 Product Gate **PASS**；PR [#20](https://github.com/shchnk1103/Universe-Keyboard/pull/20) 合并入 `main`（`fe9010f`）。未升级 librime；未改主 App 部署边界。

## 2026-07-17 — 九键 chrome 向原生九宫格靠拢（KEYBOARD-LAYOUT-9KEY-UI-001）

- 中文九键字母页对齐系统九宫格：字母组主标签（ABC…WXYZ）；左区四列；右列删除 SF Symbol / 颜表情 `^_^` / **双行高 return 箭头**；底栏表情 + **选拼音（占位）** + 宽「拼音」（列宽 1+1+2）。
- 类型阶梯与符号分离：SF Symbol **22**；字母 **16**；功能文字 **15**；空格/拼音 **14**。回车不再显示 `send` 等宿主文案。
- RIME 仍接收数字 2–9（`accessibilityIdentifier` + `t9Digit`）；选拼音 / 颜表情为 chrome 占位，完整产品行为另立项。
- 本地 `photos/` 仅作设计对照，已 gitignore；Assignment `Accepted / Closed`；领域说明见 `KEYBOARD_LAYOUT.md` / `UI_STYLE_GUIDE.md`。

## 2026-07-17 — 文档卫生整理（DOC-HYGIENE-001）

- 规范化全部 `docs/plans/*` 生命周期头为 `Active` / `Archived` / `Superseded` / `Abandoned`。
- 同步已关闭但头状态漂移的 Assignment：`KOS-GOV-001`、`ENV-TOOLING-001` → `Accepted / Closed`。
- 修复双 ADR `0017`：上屏后联想保留 ADR 0017；App 通知/Toast 重编号为 ADR 0019 并更新引用。
- 精简 `README.md` 为入口/最短构建/导航；刷新 `DOCUMENTATION_HEALTH` 快照与债务队列。
- 未改动生产代码、测试、构建或产品运行时行为。

## 2026-07-17 — Knowledge OS 2.0 运营迁移（KOS-MIG-001）

- 发布并关闭 `KOS-MIG-001`：将 Knowledge OS 2.0 从“规范已发布”推进到“仓库单轨运营”。
- `docs/kos/` 继续拥有冻结治理合同与 Zero-Context Startup；`docs/KNOWLEDGE_OS.md` 明确为运营入口（layers / 导航协议 / self-healing），不再与冻结原则竞争。
- 更新 Source of Truth、导航索引、文档图与依赖路由；写入迁移计划、完成记录与回滚说明。
- 未改动生产代码、测试、构建、Runtime/RIME、Assignment Policy，也未开启 Knowledge OS 2.1/3.0 或领域文档大搬家。

## 2026-07-16 — 26 键 / 中文九键布局切换（KEYBOARD-LAYOUT-9KEY-001）

- 新增 `KeyboardLayoutStyle`、版本化 T9 就绪标记、`RimeRuntimeSelection` 有效方案解析，以及 `T9PreeditResolver` / 无 raw 数字上屏策略（ADR 0018）。
- 主 App「设置 → 输入体验 → 键盘布局」提供 26 键 / 9 键卡片与无字符缩略图；启用九键走安装→部署→验证→就绪→最后写布局，失败保持原布局。
- 雾凇安装清单与卸载清理包含兼容版 `t9.schema.yaml`；卸载先回退 26 键并失效就绪再删资源；切换离开雾凇仅回退布局并在资源完整时保留就绪。
- Keyboard Extension 在中文 + 就绪九键时显示 3×3 T9 键（数字+字母），英文与自动英文场景保持 QWERTY；设置仅在出现/激活时缓存。
- T9 兼容性 Spike 已通过固定 librime 1.16.1（移除 `t9_processor`）；不升级 vendor。
- Codex 实现复审通过；Product Gate PASS（真机证据包）；Assignment `Closed`。

## 2026-07-16 — 上屏后联想 V1.3 真机与配对性能证据

- 在物理 iPhone 13 Pro、iOS 27.0 beta 3、雾凇拼音和完全访问开启的环境中，重新核对系统键盘注册与权限，并用正常签名的 Release 合并提交验证上屏后联想。
- 开启状态下，重复 `chile -> 吃了` 后稳定显示 V1.3 词表中的接续候选；关闭状态下仍正常上屏，但候选栏保持为空。冷进程重启后两种状态都能恢复真实 RIME 输入，测试草稿最终清空且未发送消息。
- Activity Monitor 与 Time Profiler 配对快照覆盖冷启动、最终提交、候选刷新、CPU、物理内存和 250ms 卡顿表；该设备/构建上未观察到无法解释的功能回归。具体数值只属于带环境与重验证条件的证据快照，不是永久性能预算或广泛兼容性结论。
- PR #13 已合并且 CI 通过，但没有提交的独立 review；Assignment 已推进到 `Completed`，仍需独立 Quality/Architecture review 后才能正式 `Reviewed/Closed` 并归档 V1.3 计划。
- 独立 Quality、Performance & Release 与 Architecture & Knowledge 审查已在 `2026-07-16` 通过并形成可复算的记录；Product Gate 仍待明确关闭，因此 Assignment 和 V1.3 计划尚未进入正式收口状态。
- 人类 Product Lead 已在 `2026-07-16` 明确关闭 V1.3，并授权 PR #14 转为 Ready、合并以及合并后的安全分支清理；Assignment 已记录为 `Closed`，V1.3 计划已归档。

## 2026-07-15 — 有界渐进式多错误召回预检

- 按 KOS 2.0 发布并完成 `TYPO-CORRECTION-003`：在不改变 V2.0 生产默认值的前提下，新增纯内存、默认关闭的 60/64/8 渐进式召回计划。
- 规范长句双错误输入 `wimenjintianquhongyuan` 可在无生产特例表的情况下召回 `womenjintianqugongyuan`；召回计划按最多八项分批，但没有连接 RIME、候选 UI 或持久化路径。
- 聚焦测试及 KeyboardCore 全量回归通过；语义评分、真实 RIME、配对性能和生产启用仍属于 `TYPO-CORRECTION-002` 的后续 Gate。
- 根据 Product Owner 澄清，将指定验收环境纠正为 Device Hub iOS 27 iPhone 17 Pro Max 模拟器；已有通用 UI baseline 不等于上下文纠错场景验收。


> **AI agents**: Load this file only when investigating historical decisions, debugging regressions, or understanding why a specific implementation approach was chosen. Do not load for routine coding tasks.

---

## 2026-07-15 — 上屏后联想 V1.3 首候选自然度优化

- 资源总量保持 250 条不变，移除 8 个容易在无关语境中抢占的单字后缀，替换为 8 个经过人工审查的具体上下文。
- 在既有 15 类 Top-3 合成基准之外，增加每类一个精确 Top-1 自然度门禁，并增加高歧义单字后缀抑制门禁。
- 排序算法、状态机、候选 UI、资源安全上限和隐私边界均未改变；仍不读取宿主上下文、不学习、不持久化、不联网。
- 模拟器行为验证新增强制前置顺序：确认设备、正常签名与 App Group、雾凇安装/基础检查/当前方案、系统键盘启用与实际切换后，才允许开始输入测试。
- V1.3 已按该顺序在 iOS 27.0 iPhone 17 Pro Max Simulator 完成验证：`吃了 -> 吗 -> ？`、`我在地铁 -> 上` 可连续选择，单字 `我` 不产生联想，删除可清理状态；真机手感、启动/按键延迟及内存对比仍是发布前门禁。

## 2026-07-15 — 上屏后联想 V1.2 常用场景扩展

- 内置接续资源从 100 个扩展到 250 个手工编写的合成上下文，新增家庭、购物、学习、娱乐、天气等常用场景，并增加更具体的多字后缀以减少泛化候选抢占。
- Top-3 合成回归集从 30 个扩展到 60 个，覆盖 15 类场景且每类固定 4 个案例；继续保留未知后缀为空和资源失败关闭语义。
- 运行时排序、状态机与隐私边界不变：仍为最长精确后缀与资源顺序，不读取宿主上下文、不学习、不持久化、不联网，也不改动 RIME session。
- V1.2 已在安装并启用 `rime_ice` 的 iOS 27.0 iPhone 17 Pro Max Simulator 验证 `吃了 -> 吗 -> ？`、`早餐 -> 吃了吗`、`下雨 -> 了` 和删除清理；真机候选手感、启动/按键延迟及内存对比仍是发布前门禁。

## 2026-07-15 — 上屏后联想 V1.1 质量基线起步

- 内置接续资源从 30 个扩展到 100 个手工编写的通用上下文，覆盖餐饮、日程、问候、工作、行程、关怀、物流和常见提问等场景。
- 增加严格的资源大小、词条数量、文本长度、重复值和候选数量校验；不合规资源会安全降级为空候选。
- 增加 10 类、30 个合成代表场景的 Top-3 回归基准及未知后缀负例；该基准不包含真实用户数据，也不作为真实覆盖率或接受率证据。
- 隐私与输入架构保持不变：不读取宿主上下文、不持久化输入、不学习、不联网，也不改动 RIME session。

## 2026-07-15 — 上屏后联想 V1 自动化实现

- 中文内容成功上屏后，候选栏可从本地内置词表继续推荐常见续词、标点和少量 Emoji；候选可连续选择，例如 `吃了 -> 吗 -> ？`。
- 联想状态与 RIME 组合态相互独立，活动组合始终优先；删除、换行、英文模式、键盘隐藏、进程结束或关闭设置会清理状态。
- 最近上下文仅在当前 Keyboard Extension 进程内保留，最多 32 个 `Character`，不读取宿主上下文，不持久化、记录、同步或上传；仅保存启用开关。
- KeyboardCore 全量测试及严格并发 Simulator 构建通过；真机候选手感、启动/按键延迟和内存对比仍是发布前门禁。

## 2026-07-15 — 统一 App 通知与 RIME 分项提醒

- 设置页新增统一的”通知与提醒”入口：App 通知总开关、RIME 云同步类别和 App 内操作状态提示均由主 App 的同一状态源管理；RIME 页面复用相同控件，两个入口不会出现状态分叉。
- RIME 通知类别新增”RIME 标准同步”和”Universe 设置同步”两个通知子项。它们只筛选提醒，不改变自动同步总开关或实际同步范围；关闭最后一个通知子项会同时关闭 RIME 类别和 App 通知总开关。
- 两个通知子项同时开启时，一次完整同步合并为一组开始和结果通知；只开启一项时，仅按该部分真实的开始、完成、失败或尚未执行状态提醒，避免把另一阶段的失败错误归因给已选择的部分。
- 旧 RIME 通知偏好会迁移为两个子项的默认选择，不自动请求权限，也不改动自动同步设置。操作 Toast 仍可独立关闭；前台有 Toast 时，系统通知只保留在通知中心，避免重复横幅和声音。
- Swift 6 严格并发构建、通知/同步聚焦测试和 `UniverseKeyboardTests` 全量模拟器测试通过；系统权限、通知中心呈现和真实后台机会仍需物理 iPhone 验收。

## 2026-07-15 — 修复 RIME 自动同步冷却与状态通知

- 主 App 启动和回到前台时的 Universe 私密设置维护现在服从用户选择的每天或每 7 天冷却时间，并按尝试时间节流；同步失败或取消后也不会在每次打开 App 时立即重试并反复弹出成功状态。
- 首次成功同步只解锁自动同步资格，不再替用户开启总开关；用户主动开启后会显示并默认启用”RIME 标准同步”和”Universe 设置同步”两个独立子开关。关闭最后一个子项会同时关闭总开关；手动”立即同步”仍完整同步两部分，并重置前台和后台的共享冷却时间。
- “同步提醒”明确为”同步通知”；用户授予权限后，手动与自动同步的开始、完成、失败或取消都会发送不含目录、词库、恢复码和输入内容的本地通知。
- 自动通知会明确说明本次处理的是 RIME 标准资料、Universe 设置或两者，避免局部成功被误解为全部同步完成。
- 增加通知结果文案测试并通过严格 Debug Simulator 构建及同步相关针对性测试；后台任务实际触发和通知中心呈现仍需物理 iPhone 验收。

## 2026-07-15 — 有界渐进式多错误召回预检

- 按 KOS 2.0 发布并完成 `TYPO-CORRECTION-003`：在不改变 V2.0 生产默认值的前提下，新增纯内存、默认关闭的 60/64/8 渐进式召回计划。
- 规范长句双错误输入 `wimenjintianquhongyuan` 可在无生产特例表的情况下召回 `womenjintianqugongyuan`；召回计划按最多八项分批，但没有连接 RIME、候选 UI 或持久化路径。
- 聚焦测试及 KeyboardCore 全量回归通过；语义评分、真实 RIME、配对性能和生产启用仍属于 `TYPO-CORRECTION-002` 的后续 Gate。
- 根据 Product Owner 澄清，将指定验收环境纠正为 Device Hub iOS 27 iPhone 17 Pro Max 模拟器；已有通用 UI baseline 不等于上下文纠错场景验收。

## 2026-07-14 — 有界多错误拼音纠错 V2 实现

- 新增与可见 RIME composition 隔离的 sidecar session，纠错假设查询不会改写用户正在输入的拼音、marked text 或候选分页状态。
- KeyboardCore 增加本地有界双误触假设搜索和独立 corrected-input 查询接口；多错误候选仅显式点击提交，且不会因搜索结果自动提升到首位。
- 多错误搜索移出按键同步路径，改为 180ms 可取消输入停顿后刷新；普通 RIME 候选仍保持逐键同步更新。
- 发布 `TYPO-CORRECTION-002` 的产品合同、Assignment、ADR 0015、实现计划和 V2 增量 Registry。KeyboardCore 全量测试、iOS Debug/Release Simulator build、RimeBridge contract tests 及 iOS UI baseline（9 通过、1 按设计跳过）通过；真实 rime_ice fixture、上下文候选停顿 UI trace、Device Hub iOS 27 iPhone 17 Pro Max 验收及性能结论仍待完成。

## 2026-07-14 — 修复键盘预创建与挂起阶段的 RIME 文件锁终止

- 真机高频切换验收定位到 Keyboard Extension 被 RunningBoard 以 `0xdead10cc` 终止；系统可在 `viewWillAppear` 前预创建并直接挂起扩展，因此仅在隐藏回调中 finalize 不能覆盖该路径。
- `viewDidLoad` 现在只解析只读运行时目录并使用内存回退引擎；librime 仅在 `viewDidAppear` 确认键盘已实际呈现后才初始化、创建 session 并打开用户词典。
- 进程内仍保持 librime 单一 owner；正常隐藏路径同步清理输入状态并 finalize runtime，重新显示时再初始化 runtime、创建 session 并恢复活动输入方案，不依赖时机不确定的 `deinit`。
- 诊断 writer 增加可见性生命周期屏障：挂起前丢弃待写批次并阻止延迟 App Group 写入，恢复显示后再接受日志，避免诊断副作用跨入系统挂起阶段。
- 增加 RIME 可见性生命周期与日志挂起/恢复测试；真机高频切换与 AirPods 双设备路由仍需完成最终回归。

## 2026-07-14 — 完整修复系统点击音输入视图造成的空白键盘崩溃

- Device Hub 复现并定位到 `KeyboardViewController+Presentation.swift:80`：点击音承载视图在控制器 `init` 中直接赋给 `inputView`，使 UIKit 可能在 `viewDidLoad` / KeyboardCore bootstrap 前进入 `viewWillAppear`；此前仅保护 `textDidChange` 不能覆盖这条生命周期路径。
- 点击音承载视图改为通过标准 `loadView` 创建，恢复 `loadView -> viewDidLoad -> viewWillAppear` 顺序，同时继续使用 `UIInputViewAudioFeedback` / `UIDevice.playInputClick()`，没有重新引入 Extension 自有音频会话。
- Device Hub 两次冷启动均成功；英文输入、`nihao -> 你好` 候选提交、`zhongguo` 候选展开和切走时组合清理通过，隔离冷启动 UI 测试及严格 Release Simulator 构建通过。物理 iPhone/iPad 当时不可用，AirPods 与真机持续输入仍待验收。

## 2026-07-14 — 候选呈现路径剩余性能优化

- 候选触控诊断开关改为随键盘设置快照刷新；`pointInside` / `hitTest` 不再轮询时间或读取 App Group 偏好。
- collection 数据源直接复用重建边界已经清理过的候选快照，不再在计数、复用和尺寸查询时反复过滤；尺寸缓存改用结构化键，避免拼接含候选文本的临时字符串。
- 后续候选分页使用一次全局索引集合完成去重，展开面板布局按 `IndexPath` 索引属性缓存；内存警告会释放可重建的候选尺寸缓存。
- KeyboardCore 全量测试、99 项 Xcode 工程测试、隔离冷启动 UI 测试及严格 Debug/Release Simulator 构建通过；Device Hub 已完成 Simulator 启动、输入、候选提交与展开验证。物理 iPhone 当前不可用，因此真机持续输入、AirPods 路由与性能结论仍待验收。

## 2026-07-13 — 阶段性保护启动前文本回调

- 物理设备崩溃报告表明 UIKit 可能在 `viewDidLoad` 前发送 `textDidChange`；增加 bootstrap 前保护，避免该回调访问尚未创建的 KeyboardCore controller。后续 Device Hub 验证发现 `viewWillAppear` 仍存在独立的提前到达路径，完整根因与修复记录在 2026-07-14 条目。
- bootstrap 前的文档变化回调现在会安全忽略；正式 bootstrap 仍会读取当前键盘类型与自动大写上下文，不改变正常输入语义。
- 通过 iPhone 物理设备崩溃报告定位到 `synchronizeAfterTextChange()`，并完成 Debug 真机构建、安装及 Release 通用 iOS 构建；持续输入仍需真机人工验收。

## 2026-07-13 — 键盘输入热路径优化

- 键盘命中区域改为每次布局后生成一次触控单元快照；正常命中测试直接复用，不再逐次递归发现、排序按键并重设触控背景。
- Release 构建移除逐键、逐候选的成功明细日志，保留慢输入、慢候选刷新、慢候选预取及失败告警；Debug 继续提供完整时序诊断。
- 诊断写入器改为按顺序异步批处理，多条记录共用一次格式化和日志存储读写，同时保留条数上限、类别过滤、清空与显式刷新语义。
- KeyboardCore 全量测试与 Debug/Release Simulator 构建通过；按键边缘、行间空隙和持续中英文输入仍需真机验收。

## 2026-07-13 — 键盘冷启动与系统点击音优化

- 键盘 Extension 改用 UIKit 系统输入点击音，不再创建或激活自己的音频会话，也不再生成 WAV、写临时音频文件或预热双播放器；避免键盘启动主动争抢 AirPods 音频路由。
- 主 App 移除无法控制系统点击音的五档音量界面，保留独立开关并明确静音、音量和音频路由由 iOS 管理。
- RIME 健康冷启动改为 schema 选择快速路径，不再枚举全部 schema 或合成 `ni` 功能自测；完整功能验证继续保留在异常恢复路径。
- 首次显示复用同一设置快照，布局材质开关改为缓存读取，触感关闭时不再预热；Release librime 日志降为 Error/Fatal 且不再创建启动日志目录，逐键成功诊断仅保留在 Debug。
- 自动化测试和 Debug/Release 构建用于实现验证；AirPods 双设备路由与冷/暖启动性能仍需真机验收。

## 2026-07-13 — 安全的 RIME 自动同步与同步提醒

- 完成一次用户确认的 RIME 标准同步后，默认启用自动同步；用户可改为每天或每 7 天一次，并可随时关闭。
- 新增 iOS 后台处理任务、键盘活动心跳和本地通知：系统只在合适的空闲机会运行；键盘正在使用、目录授权失效或冷却期未结束时会安全跳过。开始与完成提醒需要用户单独授权。
- 自动路径继续使用 librime `sync_user_data` 快照合并，不复制运行中的 `*.userdb*`，不自动导入其他设备 YAML，也不进入键盘按键路径。
- 更新同步、隐私、架构、调试和发布文档，明确后台任务不保证固定时刻或实时完成。

## 2026-07-12 — RIME standard sync as the interoperability path

- Added a main-App-only bridge to librime `sync_user_data` and configured its standard `sync_dir` / installation ID through a user-selected file-provider folder.
- Made standard sync an explicitly confirmed manual operation: it refreshes managed `.custom.yaml`, merges official user-dictionary snapshots and backs up RIME YAML/TXT without copying live `*.userdb*` files.
- Kept `universe-rime-sync` as a separate encrypted auxiliary package. WebDAV continues to carry only that private package and is not presented as an interoperable RIME `sync_dir`.
- Added fail-closed `installation.yaml` preservation checks, clear privacy copy and no-auto-sync boundaries. Physical-device, multi-frontend and configuration-import evidence remain open.
- Consolidated the two visible sync commands into one staged `立即同步` flow: standard-folder users see RIME user-data sync followed by encrypted private-settings sync, with each state shown through the shared global toast.
- Coordinated all local-folder and standard-sync writes with `NSFileCoordinator` and the file provider's supplied URL, fixing provider paths that could create folders but rejected saving `format.json` during atomic writes.
- Added a coordinated write/read/delete preflight before switching standard folders. The file-picker callback now holds the security-scoped directory access through preflight and bookmark persistence, which fixes iCloud Drive selections that could become unavailable after the callback returns. A failed selection pauses sync, retains the old directory only as recovery reference, and records a non-sensitive diagnostic phase/error code instead of silently continuing to the old directory.
- Moved candidate learning into “数据与同步” as “RIME 用户词典”, aligned the RIME 云同步 icon with the app's neutral settings-icon style, and clarified that cross-device learned-dictionary exchange uses standard RIME sync.
- Hardened local user-dictionary restore and reset: both now create and verify a distinct recovery backup before modifying live `userdb` files, abort safely on preparation failure, and attempt rollback after a failed replacement.

## 2026-07-12 — Portable encrypted RIME settings sync V1

- Added a main-App-only RIME sync coordinator with deterministic field-level logical versions, unknown-field preservation and conflict-safe retries.
- Added ChaCha20-Poly1305 end-to-end encryption, a device-local Keychain key, an exportable recovery code and fail-closed handling for wrong keys or damaged packages.
- Added WebDAV transport with HTTPS enforcement, Basic authentication, ETag conditional writes and remote deletion, plus a security-scoped local-folder transport with atomic writes.
- Added a native Settings page for provider setup, stable sync status, explicit content scope, recovery information, foreground/manual synchronization and destructive data controls.
- Kept user dictionaries, Typing Intelligence, diagnostics, Typo learning, typed text and custom YAML files outside V1; keyboard input remains offline and unchanged.
- Added focused merge, crypto, local-folder, conflict-retry and WebDAV request-contract tests. Real provider, physical-device, accessibility and cross-platform client evidence remain open before Product acceptance.

## 2026-07-11 — Local Typing Intelligence implementation

- Added a final-commit observation contract that classifies committed graphemes into irreversible local aggregates without persisting raw text, candidates, composition or host context.
- Added a bounded, versioned App Group statistics store with asynchronous coalescing, 365-day retention, corruption recovery and reset-epoch protection against stale queued writes.
- Added disabled, empty, active and failure-state main-App views for local typing trends, composition, activity, privacy controls and permanent clearing; collection remains disabled by default.
- Added a top-level Home tab with a single, tappable daily aggregate card that leads to detailed insights.
- Added target privacy manifests, prohibited-payload tests, exactly-once commit tests, store/model coverage and synthetic Release performance evidence.
- Preserved RIME, candidate generation and keyboard lifecycle behavior. Physical-device Full Access, process-death, sustained-typing, appearance and final review gates remain open before release acceptance.

## 2026-07-08 — Knowledge OS 2.0 Zero-Context Startup Layer

- Published `KOS-BOOT-001` as the accepted and closed Assignment for Zero-Context Startup governance bootstrap.
- Added `docs/kos/zero-context-startup.md` to define startup reading order, repository discovery, Work Item/lifecycle/role/repository-truth discovery, startup validation and prompt compression.
- Linked the startup layer through Knowledge OS navigation and synchronized the Engineering Dashboard closure state without beginning Repository Migration, implementation, Benchmark work or Task 7.

---

## 2026-06-30 — Typo Correction Benchmark Registry v1.0

- Published the accepted `TC-CTR-*`, `TC-CASE-*` and `TC-PERF::*` namespaces as the repository Source of Truth in `docs/TYPO_BENCHMARK_REGISTRY.md`.
- Added ADR 0009 for independent, versioned Registry ownership and linked benchmark, performance, Partial Commit, navigation and governance documents without copying authority.
- Preserved historical aliases, independent `nihoa-satisfied`/`nihoa-unsatisfied` Cases, cross-layer coverage rules and the Task 7 prohibition; publication does not claim current evidence passed.

---

## 2026-06-29 — Executable subagent playbooks

- Added nine domain playbooks with explicit mission, scope, forbidden changes, evidence, output, stop, escalation and documentation-impact rules.
- Separated multi-agent orchestration in `AI_WORKFLOW.md` from executable domain boundaries in `docs/playbooks/`.
- Connected playbooks to the Knowledge Index, Reading Maps, documentation graph/dependencies and health dashboard without copying architecture facts.

---

## 2026-06-29 — Knowledge OS v1.0

- Added a pure navigation index, task reading maps, documentation graph, dependency routing and change decision trees.
- Added staged onboarding, a project glossary and an ADR-linked architecture timeline without replacing current architecture sources.
- Added a reproducible documentation-health dashboard and recorded the current governance debt instead of hiding it.
- Changed the new-thread entry path to `AGENTS.md` → `docs/KNOWLEDGE_INDEX.md` → `docs/READING_MAPS.md`; retained `CONTEXT_INDEX.md` as the detailed legacy registry.

---

## 2026-06-29 — Documentation governance baseline

- Established one Source of Truth per knowledge category, mandatory documentation triggers, ADR requirements and volatile-data rules.
- Defined plan lifecycle metadata, changelog boundaries, subagent playbook boundaries and monthly/milestone Knowledge Audit outputs.
- Connected governance checks to pre-push review without duplicating the full rules across project documents.

---

## 2026-06-29 — Decision lock-in and ADR baseline

- Accepted eight ADRs covering deployment ownership, visibility cleanup, shared-container ownership, RIME sessions, restore safety, transactional schema installation, Full Access/privacy and fallback semantics.
- Locked the long-term user-dictionary rule: create and verify a safety backup before restore; current implementation remains explicitly tracked as debt.
- Added a measurement-only Extension performance baseline without invented latency or memory budgets.
- Added the canonical technical-debt register for schema transactions, `Rime/user` coordination, performance evidence, Full Access degradation, crash/jetsam operations and reproducible RIME artifacts.
- Adopted the current minimum acceptance matrix: primary development device, current development iOS and one available Simulator; expansion is required before broader TestFlight/App Store release.

---

## 2026-06-29 — Critical documentation stabilization

- Corrected the keyboard visibility contract: returning/disappearing keyboards abandon unfinished composition and marked preedit; runtime session recovery remains a separate in-presentation path.
- Removed current hardcoded test counts, refreshed README architecture/feature status, and standardized build destinations versus concrete simulator test destinations.
- Marked completed Lua and typo-correction implementation plans as archived historical references.
- Added durable documentation for the shared-container/RIME lifecycle, input and marked-text invariants, debugging flows, and release acceptance.
- Refreshed `CONTEXT_INDEX.md` so future work loads these documents instead of relying on stale summaries.

---

## 2026-06-28 — Typo correction V0.9a/V0.9b transposition value

- Moved eligible adjacent-transposition correction candidates into the near-front area without default first-position promotion.
- Reused the bounded V0.8b learning store for explicit transposition selections; three selections may enable conservative learned promotion under existing assessment and prefix guards.
- Preserved the normal-RIME satisfaction gate: when RIME already returns the corrected best candidate first, the entire transposition suggestion remains suppressed.
- Kept Release defaults off and kept substitution, deletion, rejected, and multi-edit corrections outside local learning.
- Validated on a real device that `zohngguo -> 中国` enters the front area, accumulates local selections, reaches first position after repeated explicit choices, and preserves the `nihoa` normal-RIME suppression path.

---

## 2026-06-28 — Typo correction V0.9 transposition preflight

- Added a long-pinyin transposition audit case, `zohngguo -> zhongguo -> 中国`, because real RIME already handles the original `nihoa -> 你好` example in some environments.
- Suppressed the entire corrected-input suggestion when normal RIME already returns the corrected best candidate first, preventing low-value secondary candidates such as `拟好` or `你号` from leaking into the candidate bar.
- Added assessment-level short-input protection and kept transposition Debug-only, display-only, non-promoting, and excluded from V0.8b local learning.

---

## 2026-06-28 — Typo correction V0.8b local selection learning

- Added bounded, local learning for explicit insertion-correction selections without writing RIME weights, schemas, user dictionaries, surrounding text, or telemetry.
- Kept V0.8a ranking as the default: early selections only prioritize near-front correction candidates, while three explicit selections can promote an eligible insertion correction under conservative prefix guards.
- Added 90-day expiry, a 64-record limit, malformed-store fallback, and a Debug-only reset action on the smart-correction page.
- Kept substitution, deletion, transposition, multi-edit, rejected corrections, and Release-default behavior outside V0.8b learning.
- Validated on a real device that repeated explicit selection moves `niho -> 你好` to first position without regressing existing normal-input behavior.

---

## 2026-06-21 — Typo correction internal experiment switches

- Added Debug-only main-App switches for local insertion and transposition typo correction experiments, so real-device validation no longer requires temporary code edits.
- Kept Release behavior stable: experiment keys are ignored outside Debug builds and all experimental typo edits remain disabled by default.
- Wired the Keyboard Extension to refresh experiment settings through the existing App Group settings path, without changing RIME, candidate UI, ranking rules, or production typo behavior.

---

## 2026-06-21 — Typo correction V0.8a insertion display value

- Made eligible conservative near-final insertion correction candidates rank near the front when the experimental insertion flag is enabled, without allowing first-position promotion.
- Kept production typo correction defaults unchanged and kept transposition benchmark-only.
- Added ranker regression tests for insertion near-front placement and transposition non-promotion.

---

## 2026-06-21 — Typo correction V0.8 staging plan

- Recorded the V0.8 flag-on real-device finding: `niho -> nihao` is safe but appears too far back in the candidate list, while `nihoa -> 你好` is already handled by normal RIME behavior on device.
- Split the next insertion work into V0.8a front-display optimization and V0.8b local correction-selection learning, keeping both separate from RIME weights, RIME user dictionaries, telemetry, and production defaults.

---

## 2026-06-21 — Typo correction experimental audit gate

- Added a local flag-on audit for default-off V0.8/V0.9 insertion and transposition experiments, keeping production typo correction behavior unchanged.
- Extended the main-App 智能纠错 page with a read-only "实验开关审计" section that reports target coverage, normal-input regression, false positives, dangerous corrections, and device-validation readiness.
- Documented that passing the audit only qualifies a feature for real-device validation; it does not approve production enablement.

---

## 2026-06-21 — Typo correction V0.6 quality gates

- Added a pure KeyboardCore benchmark evaluator and result model so smart-correction coverage can be checked without runtime telemetry or real user input.
- Extended the main-App 智能纠错 page with a local read-only evaluation section showing pass status, expected/actual results, confidence, promotion, and assessment reason.
- Added assessment reason summaries and default-off experimental edit flags for future insertion and transposition validation without changing production keyboard behavior.
- Documented the V0.6-V0.9 quality-gate roadmap and kept RIME schema, RIME weights, candidate UI, and Typo Partial Commit defaults unchanged.

---

## 2026-06-21 — Typo correction V0.5 prioritized recall

- Prioritized safe single-edit typo suggestions before applying the fixed lookup window, so long-pinyin back-half mistakes such as `zhonghuo -> zhongguo -> 中国` can be resolved without increasing hot-path lookup volume.
- Preserved existing safety boundaries: no omitted-character, transposition, multi-edit, RIME schema, RIME weight, ranking, or candidate UI changes.
- Updated the smart-correction benchmark and read-only main-App explanation page to mark `zhonghuo -> zhongguo` as supported near-front coverage.
- Added the V0.5 prioritized-recall plan for future benchmark-driven typo correction work.

---

## 2026-06-21 — Typo correction V0.4 scoring and benchmark UI

- Added an explicit typo-correction assessment model for confidence tier, score, display eligibility, promotion eligibility, and reject reasons.
- Kept RIME weighting and typo scoring separate: RIME continues ranking candidates for the same input code, while typo correction only decides whether a corrected input code can contribute an optional side-channel candidate.
- Added a read-only main-App 智能纠错 page that explains local correction behavior, benchmark examples, scoring principles, unsupported boundaries, and the relationship to RIME candidate learning.
- Documented the V0.4 plan and updated the typo benchmark with assessment tiers and rejection reasons.

---

## 2026-06-21 — Typo correction V0.3 coverage

- Expanded the KeyboardCore typo-correction engine from final-character-only substitution to conservative all-position single-character adjacent-key substitution, covering examples such as `bihao -> nihao` and `nigao -> nihao`.
- Kept correction behavior benchmark-driven and optional: corrected inputs must still resolve through the candidate provider/RIME flow, and normal RIME candidates remain preserved.
- Added conservative ranking so final high-confidence corrections can still be promoted ahead of longer expansions, while initial and middle corrections enter the front area without blindly replacing the normal top candidate.
- Preserved safety boundaries: repeated-final deletion remains conservative, very short inputs are protected, and omitted characters, transpositions, multi-edit corrections, and unsafe non-final consonant/vowel cross-class replacements remain unsupported.
- Refined correction-candidate rendering so a first-position correction uses the same preferred candidate emphasis while showing the typo hint as a small secondary label instead of truncating the candidate text.
- Documented the V0.3 coverage plan and updated the typo benchmark to distinguish typo correction from traditional RIME fuzzy pinyin and Lua advanced input.

---

## 2026-06-19 — Advanced input settings and Settings cleanup

- Added a shared advanced-input settings model for user-facing features such as 日期与时间、计算器、数字大写、随机编号, and candidate optimization without exposing internal Lua component names in the UI.
- Added a global Advanced Input settings page that disables controls when the active scheme does not support them, while preserving the user's choices for supported schemes.
- Added plain-language usage guidance for advanced input examples such as date/time shortcuts, calculation results, number formatting, random identifiers, and special content.
- Reorganized the main Settings tab into clearer sections for input experience, input schemes, tools, and diagnostics.
- Moved diagnostic logging controls into a second-level diagnostics settings page so the Settings tab keeps only one entry point.
- Fixed the app appearance setting to update the active root view reliably and migrated any previous standard-defaults value into the shared settings store.
- Split the `rime_ice` advanced-input settings and diagnostics links into separate Form rows to avoid overlapping tap targets.
- Made deployment apply advanced-input preferences before full RIME deployment, preserving a restorable source schema so disabled features can be turned back on without redownloading.
- Expanded dynamic-input diagnostics and compatibility post-processing to cover the full processor/segmentor/translator/filter component family.
- Prevented app launch/settings refresh from showing a stale "RIME 设置已生效" toast when the app merely reads an already-deployed state from shared storage.
- Removed the duplicate Advanced Input entry from the RIME scheme settings page; advanced-input switches now stay in the main Settings tab while scheme pages focus on scheme state and recovery actions.
- Kept number and calculator-style symbol keys inside the active Chinese RIME composition so inputs such as `N20260619` and `cC1+2` are not split by the symbol page, while ordinary punctuation still commits the current candidate first.
- For ordinary pinyin followed by number-page digits, keep the inline preedit as raw input such as `nihao123` while showing the transformed first candidate such as `你好123`, avoiding librime's default number-key candidate selection until the user confirms.
- Preserved raw-input deletion and highlighted candidates for ordinary pinyin-number suffix input, so `nihao123` deletes as `3`, `2`, `1`, `o`... while the candidate bar updates or clears at the right composition boundary.
- Updated RIME scheme-management docs, the Lua capability plan, and the Swift 6 manual acceptance record with the partial physical-device Lua smoke evidence and remaining coverage gaps.

---

## 2026-06-18 — RIME Lua diagnostics and deploy module alignment

- Added a main-App `rime_ice` Lua capability diagnostic that distinguishes unavailable engine support, stripped schema files, missing Lua files, pending deployment, inactive schema, and ready states without touching the keyboard input path.
- Exposed RimeBridge Lua capability metadata so tests and main-App diagnostics can verify the compiled bridge and deployment module list.
- Aligned `RimeDeployer` with the keyboard session engine by loading the `lua` module under `RIME_HAS_LUA` during full main-App deployment.
- Added a conservative "高级输入功能" status section on the `rime_ice` detail page with recovery actions for selecting the scheme, reapplying RIME settings, redownloading incomplete files, and opening diagnostics.
- Documented the scheme-detail status boundary in `docs/RIME_SCHEME_MANAGEMENT.md`; the UI says "基础检查通过" instead of claiming Lua dynamic candidates are fully available before real smoke testing.
- Expanded Lua file diagnostics to derive required `lua/*.lua` files from schema `lua_processor` / `lua_translator` / `lua_filter` references.
- Cleared scheme-specific RIME build cache entries before forced redownloads so old compiled artifacts do not mask recovered schema files.
- Added an opt-in iOS Simulator Lua smoke-test skeleton gated by `UK_RIME_LUA_SMOKE_SHARED_DIR` and `UK_RIME_LUA_SMOKE_USER_DIR`; it skips without a real runtime fixture.
- Added simulator and service tests for deployment module coverage and the new Lua diagnostic states.
- Recorded the staged 雾凇拼音 Lua implementation plan in `docs/plans/rime-ice-lua-full-capability-plan.md`; real Lua smoke testing remains pending.

---

## 2026-06-14 — RIME scheme operation feedback V1.2

- Added a shared in-flight operation state for scheme-side effects such as checking updates, downloading, redownloading, and uninstalling.
- Prevented repeated taps from starting duplicate scheme operations; repeated taps while a scheme operation or download is active now show a throttled global toast instead of creating extra tasks.
- Added loading labels and disabled states to scheme management buttons while an operation is running.
- Moved scheme operation results into the global bottom toast, including up-to-date, update-check failure, download start/completion/failure, redownload start, and uninstall completion messages.
- Split update checking into explicit results for update available, already current, and failed, so network failures no longer look like "already current".
- Added regression coverage for duplicate update taps, update-check failure release, and uninstall toast/release behavior.

---

## 2026-06-14 — RIME multi-scheme management V1.1 infrastructure

- Added a catalog-backed RIME scheme model covering scheme metadata, download distribution, storage keys, license metadata, user-dictionary capability, and installation plans.
- Moved rime_ice download, version, ETag, installation, uninstall, and update checks onto generic schema-ID based manager methods while preserving the existing user-facing 雾凇 behavior.
- Generalized archive installer boundaries so cache paths, extraction directories, installed-file checks, install filters, uninstall cleanup, and build-cache cleanup come from each scheme's installation plan.
- Kept the V1 list/detail UI visually stable while making download cards, license acceptance, update checks, redownload, and uninstall actions use the current scheme metadata and schema ID.
- Expanded SchemaManager coverage to assert catalog metadata reaches the scheme list and kept the existing update, install, uninstall, and deployment tests passing.

---

## 2026-06-14 — RIME multi-scheme management V1

- Reworked the main RIME settings page into a scalable scheme list with per-scheme detail pages, preparing the UI for more open-source schemes without making the top-level settings page long.
- Moved scheme-specific actions such as setting the active scheme, downloading, updating, redownloading, uninstalling, and viewing the license into the matching scheme detail page.
- Kept global RIME preferences and deployment status on the top-level RIME settings page because they apply across schemes rather than belonging to one scheme.
- Added compact per-scheme status text and icons for current, installed, downloadable, downloading, and failed states.
- Documented the V1 scheme-management structure and future extension rules in `docs/RIME_SCHEME_MANAGEMENT.md`.

---

## 2026-06-13 — RIME candidate learning V1.1 backup basics

- Refined the candidate learning settings page with plain-language status text for whether learning is on, whether there is anything learned, and whether a backup exists.
- Added per-schema local backup and latest-backup restore actions for the built-in `luna_pinyin` scheme and the downloaded `rime_ice` scheme.
- Added backup manifests so the settings page can disable redundant backups when the latest backup already matches current learning data.
- Added an off-by-default automatic backup switch that runs only from the main App at low-risk moments and skips duplicate backups.
- Reworked the candidate learning UI into a scalable scheme list with per-scheme detail pages, so future open-source schemes do not repeat across multiple long sections.
- Moved candidate-learning operation feedback into the shared global bottom toast and kept scheme rows focused on short status text plus a compact status icon.
- Made restore replace the matching scheme learning data and mark RIME for the same automatic main-app apply flow used by candidate learning and fuzzy pinyin settings.
- Added regression coverage for backup, restore, no-backup, status-copy, and file-level `{schema}.userdb*` restore behavior.

---

## 2026-06-13 — RIME candidate learning settings

- Added a main Settings entry for candidate learning, covering the built-in `luna_pinyin` scheme and the downloaded `rime_ice` scheme separately.
- Added per-schema user dictionary learning switches that write `translator/enable_user_dict` into schema custom YAML during the main-app deployment path.
- Added per-schema learning-record reset actions that remove only the matching `{schema}.userdb*` data from the App Group RIME user directory.
- Extended the pending-deploy flow so candidate-learning changes use the same automatic apply behavior and global bottom toast as fuzzy pinyin settings.

---

## 2026-06-13 — RIME fuzzy pinyin UX refinement

- Moved fuzzy pinyin settings out of the RIME scheme page and into the main Settings page as an input-habit preference.
- Added a master fuzzy pinyin switch while preserving detailed `zh/z`, `ch/c`, `sh/s`, and `n/l` preferences.
- Replaced the fuzzy page deploy button with pending-deploy scheduling on page exit/app lifecycle, guarded by a fuzzy settings deployment signature to avoid unnecessary redeploys.
- Added a main-app global bottom deployment toast for RIME applying/success/failure states; the Keyboard Extension continues using the last compiled config and does not block input while deployment is pending.
- Refined the RIME scheme management UI with non-cramped two-column action buttons and made the scheme deployment page rely on the shared global deployment toast for transient progress/results.
- Added a reusable `AppActionButton` so main-app content actions share one Liquid Glass style across RIME download, deployment, retry, reset, destructive management, and license acceptance flows.

---

## 2026-06-13 — RIME fuzzy pinyin Phase 1

- Added traditional RIME fuzzy pinyin settings for `zh/z`, `ch/c`, `sh/s`, and `n/l`, defaulting the four common initial-consonant groups to enabled.
- Added active-schema-only deployment post-processing that preserves existing `speller/algebra` rules and manages only the `# universe:fuzzy-pinyin begin/end` block.
- Added a dedicated main-app fuzzy pinyin settings page; toggles save App Group settings and mark RIME as needing redeploy instead of compiling on every change.
- Documented the separation between RIME fuzzy pinyin and small-screen typo correction in `docs/RIME_FUZZY_PINYIN.md`, `CONTEXT_INDEX.md`, and `docs/TYPO_BENCHMARK.md`.

---

## 2026-06-13 — Context-aware symbol page input

- Added a main App input setting for paired-symbol auto-completion, stored as `paired_symbol_completion_enabled` and defaulting to enabled.
- Strengthened number/symbol page one-shot behavior with mode-specific whitelists: Chinese mode uses `；（）@“”。，、？！【】｛｝#%^*+=_\｜《》&·`, while English mode keeps half-width punctuation such as `.` as one-shot.
- Fixed Chinese-mode ASCII period and non-composition `‘` handling so they no longer return to letters, while symbols such as `#`, `（`, and `“` do.
- Added digit-key protection so symbol-page numbers never auto-return to letters.
- Added paired-symbol insertion for left paired marks such as `（`, `“`, `【`, `｛`, and `《`, placing the cursor between the inserted pair when the setting is enabled.
- Chinese composition now stays alive when switching from letters to the number page; pressing ordinary punctuation commits the first RIME candidate before inserting the symbol, while active-composition `‘` is routed to RIME as an apostrophe separator for inputs such as `wa'o` and then returns to letters.
- Fixed Partial Commit + paired-symbol ordering so selecting a prefix candidate and then pressing a left paired symbol commits the remaining first candidate before inserting the pair, for example `还找` + `（` becomes `还找得到（|）`.
- Cleared stale candidate presentation when symbol input both commits composition and returns to letters, so the candidate bar reflects the same state as a first-candidate confirmation.
- Expanded KeyboardCore regression coverage for empty-context symbols, digit symbols, paired-symbol cursor placement, RIME composition + punctuation commit, and the Chinese apostrophe separator path.

---

## 2026-06-12 — Marked text composing underline

- Replaced the plain inline preedit rewrite path with `UITextDocumentProxy.setMarkedText(_:selectedRange:)` / `unmarkText()`, allowing host text fields to show the system composing underline for active Chinese input.
- Return now commits non-partial RIME composition using `rawInput` instead of display `preeditText`, so segmented preedit such as `ni h` confirms as `nih` and clears the underline.
- Number and symbol pages now behave as one-shot symbol layers: after a normal symbol is inserted from either page, the keyboard returns to the letters page while preserving Chinese/English input mode.
- Kept active Partial Commit displays marked until final commit, so selected Chinese segments and the remaining preedit stay visually connected as one unfinished composition.
- Added `TextInputClient` marked-text methods and expanded `FakeTextInputClient` test state so unit tests can distinguish visible text from still-marked composition text.
- Updated regression coverage for normal RIME commits, unknown raw commits, segmented RIME Return commits, Partial Commit, typo Partial Commit, delete restore, mode switch, Return, direct text insertion, one-shot symbol pages, and final-commit fallback paths.

---

## 2026-06-11 — Candidate touch hit-area hardening

- Fixed candidate-gap hit testing in the Keyboard Extension by keeping `UICollectionView` item spacing at zero, preserving the visual gap inside each cell, and retaining a nearly invisible cell backing so the apparent gap is still a valid pan start area on real devices.
- Removed visible red diagnostic backgrounds from candidate cells and expand/collapse chevrons. Candidate touch diagnostics now remain log-only for visuals, so enabling display diagnostics no longer changes the touch surface being tested.
- Expanded the real hit area for the candidate expand/collapse chevrons through button hit testing and invisible backing, preserving the native-looking chevron while improving tap and downward-swipe reliability.
- Applied the same hit-area principle to the key input region across text, symbol, bottom-row, and emoji insertion keys: visual key spacing stays unchanged, while the root keyboard stack splits dead-space touches at adjacent midlines into per-key touch cells, keeps a nearly invisible backing surface always active without red debug overlays, and keeps forwarded touches valid through key tracking.

## 2026-06-09 — Liquid Glass keyboard appearance tuning

- Adapted the keyboard presentation toward the iOS 26/27 system rounded keyboard container while avoiding a second custom rounded surface inside the extension.
- Added a main-app experimental switch for the material-based Liquid Glass path, but kept the default keyboard path conservative so visual regressions can be compared against the system-provided container.
- Reduced the candidate bar height and tightened the candidate/top spacing while keeping key row heights, input logic, RIME, feedback, and delete behavior unchanged.
- Final visual tuning lowers the keyboard by trimming only content insets (`top 2pt`, `bottom 0pt`) while preserving input-row height and candidate-bar height; candidate text was increased slightly for readability.
- Removed the candidate/key separator and expanded the candidate chevron hit area to make candidate expansion easier to trigger.
- Fixed an iOS 26 candidate-list washout: `UICollectionView` inherits `UIScrollView` edge effects, and the new `UIScrollEdgeEffect` visually added a rectangular fade/overlay over the first candidate row. Candidate scroll views now hide all four scroll edge effects on iOS 26+.
- Candidate cells now render with a plain `UILabel` plus an explicit highlighted background view instead of `UIButton.Configuration`, keeping candidate text rendering independent from system button/material compositing.
- Real-device validation confirmed the horizontal candidate overlay disappeared after disabling candidate scroll edge effects.

---

## 2026-06-07 — Feedback UX Phase 1

- Replaced continuous key click and haptic controls with independent switches plus five discrete levels: light, softer, normal, stronger, and heavy.
- Added `KeyboardFeedbackSettings` as the shared feedback settings model, including `KeyboardFeedbackEvent` (`tap`, `modeEnter`, `repeat`, `commit`, `preview`) and migration from legacy `key_click_volume` / `haptic_intensity` values without deleting the old keys.
- Rebuilt the main-app feedback settings UI around list-based level selection with automatic preview, same-level suppression, and preview throttling to avoid click or haptic bursts during rapid changes.
- Added a clear `modeEnter` haptic when space long-press actually enters cursor movement mode; cursor movement itself remains silent.
- Completed Delete Repeat UX Phase 1.1: delete speed stays unchanged, repeat feedback is emitted only after an effective delete, empty-field long press is silent after the first tap feedback, click feedback is more frequent than haptic feedback, and repeat click keeps an independent `tapVolume * 0.60` multiplier.
- Tuned key click audio for long-session comfort: final `ClickSoundGenerator` uses a short native-style 9ms click with 1450Hz fundamental, 2900Hz light harmonic, low noise, softened attack/decay, and a reduced five-level volume curve (`0.15 / 0.24 / 0.36 / 0.48 / 0.60`).
- Real-device validation completed across normal typing, long-press delete, settings preview, and heavy-level click tuning; the final target is light, short, restrained feedback that confirms typing without taking over the interaction.

---

## 2026-06-07 — Native-style symbol page layout refresh

- Reworked Chinese and English number/symbol pages to match native keyboard ordering more closely while keeping the V1 frozen geometry constants unchanged.
- Added first-level and second-level symbol rows with function-wrapped third rows (`#+=` / `123` on the left, Delete on the right) and shared non-letter bottom rows (`拼音` or `English`, emoji, space, dynamic Return).
- Switched emoji page buttons to a template SF Symbol so they follow the same text color as other function keys instead of rendering as a colored emoji glyph.
- Added an English smart double-quote key: the visible `”` key inserts `“` first, then `”`, and returns to opening behavior after the surrounding quotes are deleted from the input context.
- Added a visible `^_^` kaomoji entry point on the Chinese second-level symbol page as a placeholder for a future candidate-bar kaomoji picker.

---

## 2026-06-05 — Partial Commit milestone closure

- Documented the completed Partial Commit milestone across normal RIME candidates, Delete restore, typo correction Partial Commit V1, and Phase 3 V2 stabilization.
- Recorded the current product decision: typo correction Partial Commit keeps Delete restore behavior for now, with no further optimization until English input mode architecture is revisited.
- Added `docs/architecture/partial-commit.md` as the architecture and merge-readiness reference, including feature flag status, known boundaries, and recommended squash-merge/tag strategy.

---

## 2026-06-05 — Typo correction Partial Commit Phase 3 V2 stabilization

- Expanded stabilization coverage for typo correction Partial Commit without changing typo generation, ranking, UI, or the default-off feature flag.
- Added regression coverage for full-commit fallback boundaries: repeated-final deletion, multi-edit corrections, missing corrected candidates, no remaining composition, and typo correction selection during an active partial commit.
- Added lifecycle and parity coverage for final candidate commit, space/return/direct-text commit, visibility recovery, and candidate paging while typo partial commit is active.
- Clarified feature-flag exit requirements and documented that intermediate-syllable typo correction remains outside the current typo engine scope.

---

## 2026-06-05 — Typo correction Partial Commit Phase 3 V1

- Completed a default-off internal path for typo correction candidates to reuse the existing Partial Commit pipeline.
- Typo correction partial commit preserves the exact original typo input as the Delete restore target, continues composition through the corrected RIME input, and invalidates the checkpoint after continued typing.
- Real-device validation passed for flag-off regression behavior and flag-on typo partial commit, Delete restore, and checkpoint invalidation.
- Known boundary: V1 only supports typo correction candidates already produced by the current typo engine. Intermediate-syllable typo correction, such as `nihapanpai -> nihaoanpai`, is not implemented and belongs to a later phase.
- Added regression coverage for flag-off full commit behavior, repeated-final deletion exclusion, corrected-candidate fallback, and real RIME-style selected-segment preedit.

---

## 2026-06-04 — Reversible partial commit for RIME candidates

- Added normal RIME partial commit for selecting a shorter candidate inside an active composition, e.g. `nihaoanpai -> 你好an pai`.
- First Delete restores the previous raw composition and candidate list by rebuilding the RIME session from raw input; subsequent Delete resumes normal RIME deletion.
- Real-device validation confirmed no duplicate selected segment, restored `你好安排` candidates after undo, and normal candidate refresh after the second Delete.

---

## 2026-06-03 — Partial Commit Phase 1 infrastructure

- Added RIME raw-input and candidate-page contracts, plus a `replaceInput` capability for future composition restoration.
- Added stable candidate selection reference metadata and a single-checkpoint `PartialCommitState` model without changing candidate, Delete, UI, or typo-correction behavior.

---

## 2026-06-03 — Segmented RIME preedit typo correction

- Normalized display-oriented segmentation spaces in real RIME preedit before typo matching and corrected-candidate lookup.
- Verified on a real device that `nihap -> nihao -> 你好` appears as a correction candidate, commits immediately, clears composition, and no longer continues matching `安排`.

---

## 2026-06-03 — Feedback settings and RIME management reliability

- Persisted keyboard sound and haptic settings through the shared App Group store, refreshed extension-side cached values when the keyboard appears, and documented the Allow Full Access dependency for shared settings and diagnostics.
- Separated RIME update checks from forced redownloads: update checks now compare the installed release tag and report when rime_ice is already current, while redownload always starts a fresh download.
- Removed temporary runtime diagnostics after validating the App Group and deployment paths.

---

## 2026-06-02 — Typo correction benchmark reference

- Added `docs/TYPO_BENCHMARK.md` as the benchmark reference for fuzzy pinyin typo correction coverage, scoring principles, known unsupported categories, and next milestone guidance.
- Linked typo correction work in `CONTEXT_INDEX.md` and added a long-term `CLAUDE.md` note requiring future correction rules, ranking, and UI work to use `TypoCorrectionTests` plus the benchmark document as the source of truth.

---

## 2026-06-01 — Keyboard UI V1 freeze

- **Frozen layout baseline**: `candidateBarHeight=44`, `keyHeight=45`, `keySpacing=8`, `keyboardGroupSpacing=10`, `keyHorizontalSpacing=6`, `thirdRowFunctionSpacing=10`, `primaryFunctionKeyWidth=46`, `functionKeySymbolPointSize=18`, horizontal margins `7`, `keyCornerRadius=9`.
- **Input feedback baseline**: standard keys emit visual press state, haptic feedback, and key click together from touch-down. Candidate commits and long-press variant commits use the shared feedback helper at commit time. Key click playback keeps the overlapping rapid-typing behavior.
- **V1 UI freeze rule**: keyboard UI is frozen unless a major usability issue is found. Future UI changes must cite a specific usability reason such as mistouch reduction, clipping, accessibility, or interaction regression.
- **Manual verification checklist captured**: slow typing, rapid typing, repeated function keys, long-press delete, edge keys, candidate commits, and accessibility labels.

## 2026-05-25 (evening) — 候选栏滑动检测重构

- **三层滚动检测**: ① `scrollViewDidScroll` 用百分比阈值（>60% 可滚宽度）替代绝对距离 ② `scrollViewWillEndDragging` 预测性触发（Apple 推荐方式，在 deceleration 开始前触发）③ `scrollViewDidEndDragging` overscroll 兜底（>30pt）
- **百分比阈值更可靠**: 候选栏/展开面板统一用 `progress = offset / max(1, scrollableWidth)` > 0.6，不受设备宽度或候选数量绝对值影响
- **新增 6 个 loadMore 流程测试**: pageDown/pageUp 恢复、composing 状态保持、去重逻辑、预加载流程、多次翻页回到页1、深度追踪

**Key Lessons:**
- 百分比阈值优于绝对距离。80pt 阈值在不同设备/不同候选数量下表现不一致，60% 可滚宽度是通用解法。
- 三层检测（scroll + willEndDrag + didEndDrag）互补覆盖所有滚动场景。单靠 `scrollViewDidScroll` 可能在快速滑动时漏检。

---

## 2026-05-25 (afternoon) — 关键 Bug 修复

- **Bug 1 (候选栏滚动后空格失效)**: 预加载和 `loadMoreCandidates` 使用 `controller.handle(.candidatePageDown)` 污染了 `state.lastRimeOutput`（从第1页变为第2/N页）。修复：直接用 `engine.pageDown()`/`pageUp()`，不经过 controller。添加 `candidatePageDepth` 跟踪深度，每次加载后回到第1页。`handleInsertSpace` 改为从 `lastRimeOutput.candidates.first` 直接取最佳候选提交。
- **Bug 2 (首候选背景拉伸)**: 候选栏 `UIStackView` 的 `.fill` distribution 导致单按钮被拉伸至整行宽。修复：在 `fillCandidateBar` 和 `appendToCandidateBar` 末尾添加 low-hugging trailing spacer。
- **Bug 3 (选择候选后删除键重现拼音)**: `handleInsertCandidate` fallback 路径没有调用 `engine.resetSession()`，RIME 残留旧 composition。删除时 `isComposing()` 仍返回 true → 从残留拼音删除 → 重现旧拼音。修复：fallback 路径添加 `rimeEngine?.resetSession()`，`handleInsertSpace` 所有分支都确保重置。
- **Bug 4 (应用切换后无候选词)**: 键盘挂起恢复后 RIME session 可能失效，`viewDidAppear` 未做检查。修复：`viewDidAppear` 调用 `engine.resetSession()` + 清空累积状态。
- 新增 7 个回归测试。Test suite at this point: 341 → 347 tests, 0 failures.

**Key Lessons:**
- 预加载/翻页必须直接用 engine，不能经过 `controller.handle`。`controller.handle(.candidatePageDown)` 会更新 `state.lastRimeOutput`，破坏 UI 层依赖的"第1页"假设。UI 层翻页累积候选词 ≠ RIME 引擎翻页改变内部状态，两者必须解耦。
- 所有候选/空格提交路径都必须 `engine.resetSession()`。无论是 RIME 路径还是 fallback 路径，提交后残留 composition 会导致下次删除从旧拼音删除、重现候选词。
- `.fill` distribution 的 UIStackView 不能有单按钮行。每行末尾加 trailing spacer 是最简单的防御措施。
- `viewDidAppear` 是键盘恢复的最后防线。应用切换后 session 可能丢失，在这里重置保证干净状态。→ *Promoted to Key Design Decisions in CLAUDE.md.*

---

## 2026-05-25 (morning) — 候选栏交互全面重构 + Apple HIG 合规

- **Candidate bar swipe-based pagination**: Removed ◀ ▶ page buttons. Infinite horizontal scroll with auto-load: user scrolls right → near-edge detection triggers RIME page-down → new candidates appended via `appendToCandidateBar()` (no clear+rebuild flash). `scrollViewDidScroll` near-right-edge detection (80pt) + `scrollViewDidEndDragging` overscroll fallback (40pt).
- **Pre-load 2 pages**: `refreshCandidateBar()` immediately fetches RIME page 1 + page 2 on new input, showing ~18 candidates upfront. `loadMoreCandidates()` appends subsequent pages on demand.
- **Expanded panel redesign**: Flow layout replaces fixed 4-column grid. Buttons wrap naturally by text width, trailing spacers prevent `.fill` distribution stretch. Panel fills entire keyboard area (252pt, candidate bar disappears when expanded). Collapse button (chevron.up, 44×44pt) floats top-right above scrollView. Vertical infinite scroll with bottom-edge detection (80pt).
- **Fade mask refined**: Gradient range 82%→92%, last candidate almost fully visible.
- **Apple HIG P0 (Touch Targets)**: `candidateBarHeight: 36→44` (≥44pt). Expand/collapse buttons: 34×36→44×44pt.
- **Apple HIG P0 (VoiceOver)**: All candidate/expand/collapse buttons have `accessibilityLabel` + `accessibilityHint`. Composition items read "提交拼音 X".
- **Apple HIG P1 (Dynamic Type)**: `UIFontMetrics(forTextStyle: .body).scaledFont(for:maximumPointSize: 28)` replaces hardcoded `systemFont(ofSize:)`.
- **Apple HIG P2 (Semantic colors + 8pt grid)**: Highlighted background uses `.systemGray3`/`.systemGray6`. Candidate stack spacing 3→4pt, highlighted insets 6→8pt, vertical panel spacing 5→4pt.
- **Apple HIG P3 (Spring animation + indicator)**: Chevron rotation uses `usingSpringWithDamping: 0.75` spring. "More" indicator `⋯` (U+22EF, `.quaternaryLabel`) appended when `hasMoreCandidates`, removed when exhausted.
- **KeySpacing split**: `keySpacing: 8` (vertical between rows) + `keyHorizontalSpacing: 6` (horizontal within rows). Total height 250→258pt.
- Test suite at this point: 347 KeyboardCore tests, 0 failures.

---

## 2026-05-22 (afternoon) — Flickering 修复 + Session 自动恢复

- **Flickering fix (current approach)**: `view.alpha = 0` in `viewDidLoad` + height-triggered reveal in `viewDidLayoutSubviews`. After `viewDidAppear`, the first layout pass with `view.bounds.height` in range (0, 400) sets `view.alpha = 1`. This waits until the 3-phase resize settles to the final height (250pt on iPhone 13 Pro). The intermediate heights (844pt, 445pt) are filtered out by the `< 400` guard.
- **RIME session auto-recovery**: `RimeSessionManager.processKey` now detects `sessionId == 0` and automatically calls `create_session()` + `select_schema()` to recover, instead of returning empty output.
- **Expanded candidate panel height capped**: `makeExpandedCandidatePanel()` container constrained to `keyHeight * 4 + keySpacing * 3` (194pt). Overflow candidates scroll vertically in `UIScrollView`.
- **Logger category enhancement**: Added `Category.display` (DISP). Per-category toggle switches in settings (性能/画面/引擎/配置/部署/通用). `DiagnosticsView` with category filter chips and color-coded log lines (ERROR=red, WARN=orange, PERF=blue, DISP=purple).
- **iPhone 13 Pro**: Primary test device. Final keyboard view height: 258pt (may vary 216–268pt). Layout constants: `candidateBarHeight=44`, `keyHeight=44`, `keySpacing=8` (vertical), `keyHorizontalSpacing=6` (within-row), `keyCornerRadius=9`, horizontal margins 4pt. `preferredContentSize=258pt`.
- **RIME session diagnostics**: NSLog in `RimeSessionManager.m` for `processKey(sessionId=0)`, `createSession`, `destroySession`, plus `select_schema` after auto-recovery.

**Flickering approaches attempted and discarded:**
1. *Alpha=0 + fadeInKeyboardIfNeeded()* (original): iOS presentation animation overrides `view.alpha=0` during the 3-phase resize, causing half-screen flash at 445pt.
2. *Mask overlay*: solid-color mask view covered keyboard content. Mask itself visibly changes size 844→445→250pt — user sees the mask shrinking.
3. *Bottom-anchored layout*: rootStack pinned to view bottom with fixed height. Failed because final view height varies (216–250pt), and fixed content height either clips or leaves too much empty space.
4. *Async alpha in viewDidAppear*: `DispatchQueue.main.async` not guaranteed to land after the final layout pass.
5. *Current approach*: top+bottom pinning (original layout) + `view.alpha = 0` + height-triggered reveal. ✅ Simplest solution that works.

---

## 2026-05-21 (evening) — 性能与稳定性优化

- **Keyboard flickering mitigation**: `view.alpha = 0` + height-stability-detection fade-in (via `fadeInKeyboardIfNeeded()`) to mask iOS system's 3-phase keyboard resize (full-screen → intermediate → final). Apple DTS confirmed no API can prevent the resize itself.
- **Candidate bar simplified**: Removed button reuse + associated-object tracking (`objc_getAssociatedObject` Bool bridging issue). Replaced with simple clear-rebuild each refresh. 20-button creation <0.5ms vs RIME 2–5ms — negligible.
- **Enter key chat-app adaptation**: `updateReturnKeyAppearance()` checks `textDocumentProxy.returnKeyType` and `hasText` — action keys (send/search/go) show blue accent when text present, gray when empty. Called from `textDidChange`, `syncUI`, `reloadKeyboard`.
- **ForEach duplicate ID fix**: `DiagnosticsView.swift` + `RimeSettingsView.swift` — changed `ForEach(lines, id: \.self)` to `ForEach(Array(lines.enumerated()), id: \.offset)` to handle repeated log lines.
- **Performance optimization**: `KeyClickPlayer` audio moved to background serial queue — main-thread blocking reduced from 18–76ms to <1ms per keystroke.
- **Double-tap bug fix**: Removed `UIView.animate` from `keyTouchDown`/`restoreKeyAppearance` — rapid same-key taps now register reliably.
- **Deduplicated data source**: `candidateItems()` called once per keystroke (was twice in expanded mode).
- **Touch feedback**: Instantaneous `transform` + `backgroundColor` (no Core Animation transactions per keystroke).

**Key Lessons:**
- iOS keyboard flickering is unfixable at the API level. Apple DTS engineers confirmed: the keyboard extension runs in a separate process, the system assigns wrong heights (844→445→216) before correcting. No constraint, `intrinsicContentSize`, `allowsSelfSizing`, or `preferredContentSize` prevents it. Only mitigation: alpha fade-in.
- Final keyboard height varies. On iPhone 17 with iOS 26 non-adapted apps, the final height is **216pt** (not the standard 250–268pt). → *Promoted to Key Design Decisions in CLAUDE.md.*
- Do NOT override `loadView` in `UIInputViewController`. It breaks the RIME bridge (processKey returns 0 candidates with 0.0ms bridge time). → *See `docs/architecture/swift6-migration.md` Regression Invariants.*
- Bottom anchoring causes candidate bar clipping at 216pt. `rootStack.height(236) + bottomMargin(8) = 244pt` minimum, but view is only 216pt → top 28pt clipped.
- Associated-object Bool bridging is unreliable. `objc_getAssociatedObject(...) as? Bool` can fail on `__NSCFBoolean`. Simpler: just rebuild.
- Log aggressively. Without `viewDidLayoutSubviews` frame logging, we wouldn't know the final height is 216pt or that `viewDidAppear` fires at intermediate height 445pt.

---

## 2026-05-21 (earlier) — Swift 6 企业级重构 + RIME 统一桥接

- Enterprise-grade refactoring: RIME C/ObjC ownership consolidated in `Packages/RimeBridge`; Swift 6 baseline verified 347 KeyboardCore tests with 0 failures.
- Duplicate WAV generation unified → `ClickSoundGenerator` in KeyboardCore.
- Duplicate Lua stripping removed from SchemaManager → uses `RimeConfigPostProcessor`.
- Schema repair and Lua stripping are performed in the main App preparation/deployment flow; `RimeEngineImpl.init` only starts an input session over prepared data.
- BulletRow + CapsuleBadge patterns unified into shared components (11 call sites updated).
- `RIME_HAS_LUA=1` defined in Keyboard target preprocessor macros.
- `activateRimeIce()` + `deployRimeConfig()` order swapped: schema activated BEFORE deploy, so deploy compiles the correct schema and flags are not overridden.
- `t9.schema.yaml` always installed (was conditionally skipped, causing "missing input schema: t9" in deployment_tasks.cc).
- App-side `RimeConfigManager.prepareDirectories()` schema repair is guarded by `!rimeDeployed` so it respects prior deployment results.
- `RimeSettingsView.deployState` now refreshes via `.onChange(of: rimeIceDownloadState)` instead of only on `onAppear`.
- `RimeDeployer.finalize` renamed to `cleanup` to avoid NSObject deprecated-method collision.
## 2026-06-15 — 输入体验区域重构：简繁转换与候选数量移至设置页顶层

- 将简繁转换和候选数量设置从「RIME 方案设置」内部提升到「设置 > 输入体验」区域，让用户更方便调节日常输入体验。
- 简繁切换和候选数量（松手时）都会自动触发 RIME 部署，无需手动点「应用并重新部署」。
- 候选数量 slider 使用 `onEditingChanged` 防抖，快速拖动不会触发多次部署。
- 修复 RIME 桥接层 `syncSchemaCustomYaml` 中简繁设置只写给当前激活方案的 bug，现在两个拼音方案都写入 `switches/@1/reset`。
- 移除了已无内容的 `RimePreferencesSections.swift`。
- 更新了 RIME 部署页的步骤文案和 footer 说明，删除"修改上方设置"等失效引用。

---
