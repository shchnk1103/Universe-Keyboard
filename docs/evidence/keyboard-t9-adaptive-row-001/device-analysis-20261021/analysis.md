# QA-001 DSON 13 Pro 真机追踪分析（只读）

结论：**QA-001 OPEN / MAJOR。已定位到“首键模型已绑定，但UICollectionView没有配置/呈现可见Cell”的UI阶段；最可能是0→34pt首显期间内容更新与真实可见viewport不同步。精确的UIKit失效/重建机制尚未完全证明。** 本轮不修复、不修改探针、生产源码、工程、Scheme或KOS，不运行测试、不提交、不Push/PR/Merge。

## 证据保存与有效性

来源为Human提供的DSON 13 Pro导出；原文件虽后缀.json，实际包含LLDB命令前缀，并非直接可解析JSON。原字节保存在raw/，提取的独立合法JSON在extracted/，没有删改或覆盖Downloads文件。第二份前缀还包含continue与进程恢复行，只作为日志元数据保存，未执行其中任何文本。

- [首键原件](raw/ui2-first-key-blank.json)：17667字节，SHA-256 `5dcde47b171ccb6757fb73bad74708897efe94b7b458211ee963cc599b3ce0fa`。
- [第二键原件](raw/ui2-second-key-visible.json)：29767字节，SHA-256 `59eeeed026f5bb980807b2d9c9dbf57915fda790957354a9cc2142e0e899282a`。
- [首键JSON](extracted/ui2-first-key-blank.json)、[第二键JSON](extracted/ui2-second-key-visible.json)、[完整时序表](timeline.csv)、[哈希/校验清单](manifest.json)。

两份schema=1、capacity=128、armed=true、dropped=0。keysCaptured分别1/2，记录数16/29；seq分别连续1..16/1..29，ms有限且单调。每个event恰有一次T0和一次HANDLE_RETURN，均先于本事件的UI_PUBLISH_CALLBACK；T3入口先于对应T2模型捕获，与代码一致，不要求数字阶段名排序。

第二份的前16条记录与第一份**逐字段完全相等**，强支持同一缓冲的连续两次导出；这是records前缀相等，不是原文件字节前缀相等。没有记录丢失。首键未使用Cell采样额度，第二键配置5个Cell，低于每键8条上限；首键布局采样5条，低于12条上限，因此缺少首键T4_LABEL_CONFIGURED不能用这些采样上限解释。

所有记录asyncAttributionUncertain=1，nativeOperationReturnObserved=false，triageHint均为INCONCLUSIVE。该hint来自探针对异步归属的保守限制，**不是证据损坏、没有复现或问题不存在**。event是UI观察区间，不是native operation ID；JSON未内置设备/构建HEAD签名，DSON设备来源依据Human说明。ms含调试器暂停时间，不用长间隔推断连续空白时长或native输入延迟。

## 首键与第二键时序差异

| seq | 事件 | 已观测事实 |
|---|---|---|
| 1–6 | 首键开始/handle返回/初次UI刷新 | revision0、rawLength=-1、路径0；刷新空模型，行仍hidden/0pt。responsive=1，不能把这个handle返回当RIME完成。 |
| 7–9 | 首键异步UI发布/刷新/模型 | revision1、rawLength1、corePaths3、candidateCount5、modelPaths3/modelRevision1。首键结果已经进入Core/UI模型。 |
| 10 | 首键路径绑定 | boundPaths3，调用点在reloadData及layoutIfNeeded之后；父行hidden/0pt、collection376×0，可见Cell0。 |
| 11–12 | 解除hidden并请求展开 | rowHidden=0、请求288，但实际行尚0，Cell0。 |
| 13 | 子视图已布局 | 父行仍0pt，collection已376×33，Cell0。这是重要的中间几何状态。 |
| 14–15 | 行与根高度落定 | 行34、collection376×33，随后root286、请求288；没有T4_LABEL_CONFIGURED，Cell仍0。 |
| 16 | 首键Human空白快照 | 模型/绑定3、行34、collection33，Cell0；祖先未hidden、有效alpha1、idleHint关闭、panel/mask均不存在，humanVisible0。 |
| 17–21 | 第二键/后续UI发布 | handle先读到上一revision1，随后发布revision2/rawLength2、corePaths5/modelPaths5。 |
| 22–26 | 第二键Cell创建配置 | 恰有5条T4_LABEL_CONFIGURED，labelEmpty0。此时Label height0是配置早于布局的正常中间态。 |
| 27–29 | 第二键绑定与可见快照 | boundPaths5、visibleCells5、Label height33、labelMatchesModel1；行仍34、root286、请求288，humanVisible1。 |

首键并非“第二键才第一次取得路径数据”：seq9已取得3条路径，seq10已存入路径视图。第二键的新增区别是在**已展开的正高度viewport**上再次执行setPaths→reloadData→layoutIfNeeded，随后进入cellForItem/configure。不是靠第二键第一次成功展开根高度。

特别注意：`boundPaths`读取的是视图私有paths数组，不是UICollectionView内部cached item count；源码dataSource若被调用会返回paths.count，但本日志没有证明它何时被调用。`visibleCells=0`时，探针找不到可见Cell/UILabel，labelEmpty=1、labelAlpha=0、bounds0来自nil回退，**不能解释为某个已存在UILabel被赋空字符串或主动设为alpha0**。可以确认没有观察到首键Cell配置，不能从visibleCells0断言所有离屏/复用Cell都不存在。

## 源码因果分析

核心范围为 `Keyboard/Views/T9PinyinPathBarView.swift`：

- 213–239：setPaths先存paths/revision，232–233执行collection.reloadData和layoutIfNeeded，随后处理reveal并只对路径行setNeedsLayout。
- `Keyboard/Controllers/KeyboardViewController+T9PinyinPath.swift:102–118`：apply快照时先setPaths，106的defer最后才刷新行可见性；56–65才把行展开并提交原有750高度请求。因此首次非空刷新发生在隐藏/0高视图是当前实际顺序，不是猜测。
- PathBar:194–203：setRowVisible更新约束、hidden及setNeedsLayout，但不负责一次新的collection内容/布局提交。
- PathBar:244–249：reveal就绪条件仅检查!isHidden和collection的正尺寸，没有检查父Path Bar本身的bounds高度。seq13显示真实设备出现“父0、子33”；该条件允许在父行未真正展开时处理滚动、消费待显示请求。日志没有直接记录消费标志，不能把具体哪一遍消费当作独立观测。
- PathBar:400–405：后续路径行布局只调用collection.layoutIfNeeded和reveal，没有明确的首次可见布局失效/延迟reload交接。父行0→34时，collection可已是相同33pt，未必再产生能触发Cell配置的子viewport变化。
- PathBar:333–350：dataSource返回paths.count；cellForItem在configure之后记录T4。首键0条而第二键5条与“绑定完成但首显Cell生成未恢复”一致。

**最可能的机制（推断）：** collection内容更新在隐藏/零高阶段被处理，父行真正可见时没有可靠地恢复该批数据的Cell materialization；reveal readiness还允许父行0高时提前处理。第二键在稳定正尺寸上重新reload使Cell正常配置。

**已经证实的是失败层和调用/几何顺序；尚未证实的是UIKit内部为何保留空可见集合。** 不能现在就把“某个缓存未invalidate”或“加一次invalidate必然足够”写成确定结论。Apple将layout属性生成与collection/dataSource协作创建Cell区分：[UICollectionView官方说明](https://developer.apple.com/documentation/uikit/uicollectionview)。这仅支持分层分析，不是本缺陷的API保证或根因证据。

## 其他怀疑项与限制

1. **异步结果晚到：** 首次handle返回空是响应式分支的现象；后来的首键UI发布确已拿到revision1/3路径并绑定。缺陷在此之后仍存在，所以“初次空刷新”本身不足以解释持续空白，不应修改RIME顺序。native返回和精确异步operation归属仍未观测，不能证明所有上游语义正确或真实输入文字正确；但当前空白无需用输入丢失来解释。
2. **已存在文字被遮住：** Human首键快照panelPresent/Expanded/Transitioning=0、maskPresent=0、祖先hidden0、有效alpha1；本次无活跃面板/根遮罩证据。没有可见Cell与配置回调，优先级高于已有Label着色/材质遮挡。仍未记录实际window/attachment身份、collection cached item count、layout attributes、contentSize/offset；离屏viewport/空attributes/控件替换等尚未彻底排除。
3. **动画覆盖/F-3：** 两键全部记录无T6且panel/mask均无，不能归因revealToken回调或revealedHeight。T0之前是否曾展开又收起未被记录；历史detach/reattach可作为触发背景，不能凭此认定本轮有残留动画。
4. **UI-1 candidateBar.superview过滤：** 修改位于 `KeyboardViewController+T9PinyinPath.swift:304–307`，用于拼音路径展开面板，保留UI-1 CandidateBarRowView（Presentation:73–82）与路径栏；不是标点待选候选条。当前Keyboard目录只搜到presentPinyinPathExpandedPanel定义、没有静态调用点。本次T0为pendingPunctuation1但完整candidate panel0；没有证据把此过滤变化连到首键Cell缺失。它或UI-1布局改变可能改变触发时序，仍需对照试验才能证明因果，不能直接改回。
5. **performBatchUpdates：** Path Bar自身没有使用batch updates；它只有reloadData。批量追加位于CandidateBar.swift:217与ExpandedCandidatePanel.swift:622，是其他collection实例。现有证据不能推断路径reload正在某个batch中，亦不能据此改候选Authority或快照策略。
6. **采样与观察效应：** 先前同步引擎/手动接受高度并强制flush的测试未覆盖此真实异步首显窗口；不能拿绿测反驳真机。探针有有限时序影响、无像素采集；这是一轮设备失败证据，不是所有设备/颜文字/完整展开层的普遍证明。

## 补充诊断与下一阶段提案（未获实施授权）

不需要为了继续调查而扩大Core/native诊断或再堆模拟引擎用例；现有证据已足够把下一阶段限定在Path Bar首次可见内容提交。若希望精确区分“reload未提交/布局attributes为空/viewport离屏”，建议只追加少量DEBUG数值观察或本机调试器检查：dataSource item-count回调次数、collection实际item count、contentSize/offset、viewport内attributes数量/frames、window/父链存在性、待reload/reveal是否消费及view标识。先冻结本轮原始证据；部分UIKit查询可能触发懒布局，结果不能自动当原现场。不得在本轮执行invalidate/reload“试一下”。

**建议最小修改范围：** 先仅授权 `T9PinyinPathBarView.swift` 与现有 `KeyboardLayoutIntegrationTests/T9AdaptiveRowTests.swift`；必要的诊断字段另列小范围。暂不修改Controller、根高度/750、候选46pt、UI-1、Core/RIME/Authority。

**Proposed设计：** 模型/revision照常即时绑定；隐藏或父行/子collection任一无有效viewport时，保存一个UI-only的“最新内容待呈现”状态，不在无效viewport中消耗首显滚动。等真实可见布局边界，针对最新revision一次性完成内容reload/必要的layout invalidation及Cell布局，再处理reveal。相同revision/相同viewport不重复提交；若测试证明只需更小的readiness修正则收窄。不能只把Controller可见性提前一行就假定已获得实际frame，也不能加延迟、轮询或每个layout pass重复reload。具体选invalidate还是deferred reload须用可复现证据决定，当前不是已验证补丁。

**回归方案：** 窗口已附着的真实Controller，从pending标点和Path hidden/0起步；同一首键先发布空revision0，再在后续主线程turn发布非空revision1，发布时仍保持原254高度，模拟父0/子33再父34/子33的交接，按正常UIKit/宿主高度落定而非由测试直接强制collection reload/layout。只发布这一次有效模型，不输入第二键，检查dataSource一致、Cell配置发生、Label匹配且几何可见。第二键再验证不重复处理首键；原Sticky/恢复/0与34/46与254/288合同及展开面板测试保留。必须尽量先在未修复代码上失败；若本地无法复现，明确记录测试只作守卫，以本轮真机负证据和修后同设备首键验收作为必要Gate。

下一阶段需要Human明确授权：上述小范围UIKit首显同步修复、相关定向测试、本地提交和必要DEBUG字段；不含Push/PR/Merge/发布。修复后Human在DSON 13 Pro分别验证标点、颜文字，第一键后停住、再输入第二键、快速连续输入、真实重新唤醒及展开/收起交叉场景。精确根因/修复尚未最终确认，QA-001保持OPEN。

## 本轮边界

HEAD保持fa8c2cb63c8be32d6723a7538bd1c39746af12e8；已有project.pbxproj及Universe Keyboard.xcscheme未提交修改均原样保留（Scheme修改来源本轮不推断）。本轮只新增本目录证据/分析，没有修改生产/测试/探针/工程、没有运行输入/测试/诊断试验、没有commit/stage/Push/PR/Merge。文件与源码哈希见manifest。完成后停止，等待Human。
