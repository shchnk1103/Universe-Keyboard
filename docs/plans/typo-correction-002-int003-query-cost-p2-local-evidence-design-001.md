# P2 轻量查询取证与本地导出设计

Status: Archived

Archived at: 2026-10-10。原因：Human 批准收窄合同，将新增存储协议、目录所有权、配额、保留策略和 UI 留待以后；本文保留设计想法，不再作为当前开发指导或任务关闭前置。

Current source of truth: [批准的 P2 合同](../product-decisions/TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LOCAL-EVIDENCE-REQUIREMENTS-001.md)与[最小验证准备](typo-correction-002-int003-query-cost-p2-minimal-route-preparation-001.md)。关联 [ADR draft](../architecture/decisions/proposed-query-cost-local-export.md) 保持 Proposed / deferred。以下为原 Proposed 设计的历史内容，尚未实现或独立批准。

## Proposed work-package handoff

- Triggering evidence: 180秒ATRC读取超时；延长读取在335秒触及4GiB磁盘阈值并停止，无可用TOC；Human授权设计并提出修改P2需求。
- Frozen facts and unknowns: 固定72dd217及23文件dirty candidate；现有probe、freeze和DEBUG按钮可复用，未实施持久化；各轨12.6GB构成及磁盘下降来源未证实。
- Decision to preserve: 精确query总量、阶段/结果/用途、facade经过时间、隐私和完整性；父Active；不声称CPU、UI停顿、内存归因、Release或Gate。
- Proposed seam and alternatives rejected: 专用probe冻结快照，Extension后台写已预留的App Group槽位，主App验证并导出；不恢复高密度文本日志，不重写query调度，不默认全天收集。
- Verification matrix: 见§7；没有设备、构建、测试或实现授权。
- Stop conditions and non-goals: 见§8；独立审查前不得当作实施指导。
- Required authorization and reviewers: Human批准精确证据修订；独立Architecture/Quality设计复审；实施、验证、采集和发布各自绑定新AUTH；ADR draft不得视为Accepted。

## 1. 目标与分阶段边界

当前阶段只设计。推荐最小第一版保持 `DEBUG && KEYBOARD_QUERY_COST_PROBE`，服务开发者反复调试；正式版日常用户取证、全天自动记录、远程上传另立产品/隐私合同。手动开启、有限记录、停止保存、App导出是第一版目标，不能由现有DEBUG按钮推断它已可用于Release。

复用 `QueryCostMemoryProbe` 的唯一生产arm、4096条上限、30分钟TTL、scope校验、完整性reason、immutable freeze、strict decoder和现有numeric query payload。一个Extension进程仍仅一次arm，已冻结不能reset或重新arm；重复调试需新进程和新Run，新启动必须在后来环境AUTH中授权。现有full benchmark的161216 bytes是1006条fixture记录+256字节header，并非生产4096条上限；生产最大655616 bytes。新保存协议不得沿用fixture长度作通用上限。

## 2. P2必需证据修订（Proposed，待Human批准）

权威修订草案见 [Product Decision](../product-decisions/TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LOCAL-EVIDENCE-REQUIREMENTS-001.md)。只对下一新candidate/Run生效；既有失败、Partial及历史门禁不改级。原P2要求不能因本计划已写而自动消失。

| 问题/原要求 | 新P2必需证据 | 保留的限制与后续归属 |
| --- | --- | --- |
| query总量、Stage1/2及结果用途 | complete probe快照，unique invocation/operation、stage、readiness、结果bucket及applied/discarded | 缺记录只报lower bound；不能从A0未armed零记录推断无query |
| facade调用耗时 | 单调clock逐调用elapsed、时钟状态、样本数/分布 | 是wall elapsed，不是CPU、全按键/UI延迟；时钟异常样本单列，不静默替换 |
| measurement自身影响 | 已绑定的synthetic hook/freeze/encoding开销与数值正确性；新保存/导出验证证明I/O不进入query路径、保存处于freeze之后 | 不声称真实整机无影响；运行期全主线程/内存profile转为单独后续性能任务；是否足以Product接受由Human另决 |
| LLDB拷贝snapshot与exact bytes | App Group原子发布、Main App strict decode和逐字节/length/hash校验；文件成对匹配 | hash只是完整性，不是可信签名；成功保存不证明操作完整或CPU/内存可接受 |
| SystemTrace及两anchor跨工具时钟对齐 | 对只用同一probe单调clock的query分析不再必需 | 不再需要跨工具时间线，旧anchor按钮/失败证据保留；未来跨工具分析另AUTH |
| 同Run A0/A1/A2连续外部VM/Allocations/线程采样 | 不再是本query-diagnostic P2的必需前置 | 不把它当已通过；真实observer总体干扰、内存归因、Release可接受性转为后续专项；无trace不能推出无泄漏或无卡顿 |

合成fixture维持已批准六类输入、阶段/操作关联及冷暖标识；输入仅用于明确授权的测试宿主，任何原文不写文件。未来正式Run可只收armed诊断段，A0仅作为synthetic control的标识，不能要求普通未armed键盘产生query快照。统计问题保持，旧A0/A1/A2外部对比目标明确缩小，不能发布同等性能结论。

## 3. 用户操作与状态

Main App DEBUG诊断页新增独立“查询取证”入口，复用导航与系统分享风格；普通journal列表/清空按钮不管理这份证据。App先“准备本轮”，在App Group预留一个slot及一次性ticket，再让用户回输入宿主显示键盘。

键盘复用左上四按钮组，保留右侧关闭/展开hit区域。第一版建议前三按钮为“观测成本”“序列边界”“保存取证”；第四时间锚点先保持现状并从本轻量流程中排除，不偷偷移除历史功能。读取准备ticket在后台完成，返回MainActor后再次核对当前scope和quiescent再arm；arm失败不执行query、不恢复/部署RIME。

保存状态：未观测→已观测→冻结→保存中→已保存或保存失败。freeze后拒绝新增记录，后台编码/校验/落盘，不保存借用指针，不把现有 `queryCostProbeExportReady` 空hook冒充持久化实现。

保存失败时保留同一immutable snapshot；允许用户再次点击重试保存同一Run，不能reset probe或重新采集。每次点击仅一次I/O提交，无循环重试；有唯一attempt ordinal和错误码。保存成功也需Main App独立读取验证，才能标记“可导出”。Extension退出前没完成保存则unavailable；不保证被系统终止后仍有数据。

## 4. 所有权、Swift隔离与存储协议

新的跨target边界见 [ADR draft](../architecture/decisions/proposed-query-cost-local-export.md)。不改现有App Group entitlement、RIME部署或Diagnostics/HF/category preferences。

- Main App是 `QueryCostEvidence/v1/` root、control/ticket、目录准备、全局quota、retention与删除owner；Extension不能创建root、清空全局数据或运行retention。
- Main App在后台存储actor持有非阻塞跨进程维护锁，预留受控UUID run目录；同时最多一个pending slot。准备ticket包含protocol/run ID、随机reservation nonce、期限、预留大小；ticket不包含用户文字。
- Extension准备/保存使用专用后台actor（不可只把MainActor继承的Task当后台）；只写匹配ticket的本Run目录。所有异步回调再次核对Run/process/session/scope，晚到的结果不能更新新controller状态。
- 文件I/O、hash/JSON编码/目录查询不能在query、operation callback、触摸热路径或probe锁内执行。freeze自身内存复制保持idle-only并另测开销，不承诺完全无MainActor代价。
- 数据文件 `snapshot.bin` 沿用现有little-endian strict wire格式。`manifest.json`固定字段：协议/Run/process/coordinator/session身份、schema枚举、FullAccess标记、DEBUG配置、build version/number、source candidate ID、字节数/SHA、record/query/operation计数、reason bits、begin/freeze tick、保存attempt ordinal；不存在任意自由文本payload。
- source candidate ID来自将来固定build流程注入，并由安装产物manifest独立对照，不能以应用自报build作为完整provenance。具体注入路径在实施AUTH冻结；当前无工程改动。
- 在预留run目录内写唯一临时文件，关闭并验证有限长度/hash，原子rename数据和manifest，最后发布完成标记；Main App只读完成标记存在且两文件验证一致的Run。中途终止/半写不算完成。
- 不覆盖既有completed Run；同一snapshot重试使用新临时attempt，完成标记作为发布条件。维护锁及Run读写锁使删除与发布互斥；锁忙即返回有限错误，不等待阻塞主线程。
- 只接受可信生成UUID path与固定文件名，拒绝symlink、路径逃逸、未知protocol、超长manifest、hash/identity错配；不从用户提供的manifest构造任意删除路径。
- Full Access不足、App Group不可写、root/ticket缺失、过期或无quota：不保存，显示有限错误。不能回落到私有容器却显示“已保存可导出”，不能改权限开关。Apple现行文档区分未open-access只读共享访问和open-access写入，runtime权限仍须后续精确验证。

## 5. 数据量、保留及清理（Proposed参数）

沿用4096条/30分钟，不新增滚动覆盖。单个binary <=655616 bytes，manifest <=64KiB，完成标记<=4KiB；每Run预留2MiB包含临时attempt。全局最多10个slot、总20MiB包括pending和临时文件。超过上限拒绝新准备，不悄悄丢失证据，不无限积累。

Main App每次prepare/list/delete时检查容量，无后台定时器要求。Run默认保留7天；只有已成功导出且用户明确标记“无需保留”的Run可自动回收。未导出、pinned或仍被当前证据合同引用的Run保留并计入quota；满额让用户选择删除，不以TTL强制删除唯一证据。

单Run删除有确认，Main App持锁后按可信完成目录删除；active/pending/读取中不删。导出share临时副本计入2MiB预留；分享结束清理，只清自己的UUID目录，崩溃后的副本下次维护可辨识回收。若pending因进程退出遗留：不能仅按过期ticket推断writer已死，先非阻塞取得Run独占锁；未知或锁忙保留。锁失败、磁盘不足、写入中断只报有限错误。

现有macOS `/private/tmp` rawtrace不是此新retention管辖范围；旧12GB文件不随新合同批准自动删除。先保留identity/hash/事实摘要并核对后续引用价值，再按独立精确清理范围操作。本轮不删除。

## 6. 隐私与诊断开关

默认disabled，仅Human按钮一次开启；无全天持久化开关、后台自动收集、上传或剪贴板自动写入。记录不含键值、输入/marked text、候选原文、词典数据、宿主输入正文、用户ID或它们的hash/fingerprint。只含numeric枚举、运行身份和时间/计数；本地run身份仍按诊断数据处理，不自动发布。

不读取或改动原DiagnosticsJournal控制generation、日志/HF/category开关。保存协议与journal分开，避免开启旧高频query日志；可复用受审核的hash/decoder/分享UI等通用部件，不直接复用会改变prefs或writer-sealing语义的流水线。

## 7. 后续验证矩阵（未执行）

| 层次 | 必需内容 | 结论边界 |
| --- | --- | --- |
| 独立设计复审 | Contract映射、observer残项、privacy、MainApp/Extension ownership、并发、retention、UI流程与所有失败状态 | 未实施；不能当作Quality/Gate |
| KeyboardCore/存储测试 | exact bytes/decoder、complete/incomplete、溢出/期限/duplicate、不重置probe；超长/未知/错hash/错Run拒绝；部分写/并发读删/锁忙/重复保存 | 由新测试AUTH执行；非真机性能 |
| App/Extension集成 | 未FullAccess/无ticket/磁盘不足/写入中被终止；同Run保存成功→App验证→分享→清理；晚回调不改新controller；未开诊断prefs | 实际App+Keyboard target；不能只跑Core |
| 开销 | 固定synthetic begin/fill/freeze/encode/decoder样本与identity，外层单调时间及timer/no-op baseline；保存不进入query路径 | 工具和harness局限明示，不推出运行期CPU/VM无影响 |
| 本地CI | Swift格式硬门禁、Core、RimeBridge、App+Keyboard及适用Release/签名测试按执行基线AGENTS | 每次Swift commit/push必须先strict lint；当前0执行 |
| 有限P2 Run | 后来AUTH冻结exact candidate、产物/安装身份、UDID独占、Luna/FullAccess/宿主/两诊断off、合成序列及run ticket，验证complete与export | 同一probe时间域，不必SystemTrace/anchor；只有新合同被批准后才适用 |
| 后续专项性能 | 出现卡顿、内存增长或Product需总体可接受性时，另立有限profile/物理设备预算 | 不属于这次查询诊断；不能借P2 complete自动通过 |

独立复审需要两个未参与设计的runtime：Architecture & Knowledge Steward审边界；Test/Release审证据与失败可见性。用户指定gpt-6-luna，能复用满足独立性者时复用；派发须新review AUTH、固定文档hash/问题/调用与时间预算，当前不派发。

## 8. 停止、授权与交接

本设计AUTH只允许doc/source reads、上述设计和Proposed Product/ADR及导航同步，0Swift变更/测试/build/device/Git发布/清理。新合同必须先由Human明确批准；ADR接受仍需单独Human授权，实施也需独立范围AUTH。审查争议不能通过直接降低complete/privacy来绕开。

后续若源manifest漂移，先做相关路径impact分析，不因main推进无限重试或重新跑验证；固定candidate可保持，未来合并另核对integration baseline。原P1事实和失败记录保持，禁止恢复RimeRuntimeProvenance，禁止把Consumed AUTH当Live权限。

设计交付Completed只表示准备完毕，整体P2仍未完成。下一交接为Human批准精确修订与独立设计复审；父TYPO-CORRECTION-002保持Active，Capture不是Gate，不合并PR、不Accept ADR、不TestFlight/Release。

## 9. 官方依据及文档影响

- [Apple：Configuring open access for a custom keyboard](https://developer.apple.com/documentation/uikit/configuring-open-access-for-a-custom-keyboard)：共享写入权限需open access；本轮搜索可读摘要，完整Markdown获取失败，runtime行为不视为已验证。
- [Apple：Configuring app groups](https://developer.apple.com/documentation/xcode/configuring-app-groups)：App/Extension共享数据途径，具体锁/发布/quota是本项目Proposed设计，不是Apple提供的自动保证。
- 新App Group生命周期/retention与跨targetowner变化需要Proposed ADR，当前draft不Accepted；实施前须补对应architecture/DEBUGGING，UI遵守UI_STYLE_GUIDE。Release产品化另ADR/Product。
- 本轮docs-only，跳过xcodebuild，无CHANGELOG必要，无ReleaseChecklist合同修改，无生产诊断prefs变更。
