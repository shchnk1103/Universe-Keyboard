# TYPO-CORRECTION-002-INT003-QUERY-COST-P2-LOCAL-EVIDENCE-REQUIREMENTS-001

Status: Human-approved scoped P2 contract

Decision owner: Human Product Lead。2026-10-10 Asia/Shanghai，明确批准“收窄后的 P2 合同与最小验证路线”，并将新增存储协议、目录所有权、配额、保留策略和 UI 留待以后。

## 批准的合同与有效边界

仅对下一新的 INT003 query-diagnostic P2 Run 生效：

1. 必需输出仍是完整且可校验的 query 快照：查询总量、Stage 1/2、readiness、结果 bucket、是否应用/丢弃、facade 单调时钟经过时间。精确计数、完整性及内容无关隐私要求不降低。经过时间不是 CPU 时间，也不等于完整 UI 延迟。
2. 复用现有内存 probe、immutable freeze 与 `queryCostProbeExportReady` 调试器导出接口。LLDB 只在输入测量完成后附加；冻结后在同一次有效字节借用内取得两份有限副本并核对。实际传输尚未成功验证；可与正式 Run 共用一次验证，不强制新增一轮空快照采集。
3. System Trace、两次外部时间锚点和连续 A0/A1/A2 线程/VM/Allocations profile 不再是这份限定 query 诊断完成的必需条件。历史失败/Partial 保留；缺少这些证据的 CPU、真实主线程停顿、内存归因及总体 observer 影响仍未验证。
4. 保留 synthetic hook/freeze/encoding 开销和数值正确性要求。既有 R4/R5 限定独立核对在相关文件身份、覆盖和环境适用性确认后可复用，不因合同变更或 main 前进自动重跑。其结论仅限原 synthetic / DEBUG 环境；调试器暂停不计入输入测量窗口。
5. 使用现有 DEBUG 手动一次开启、有限记录；logging/HF/诊断分类 preferences 不变。不开启 Release 全天日志、云上传，不新增持久化设施。
6. 路线及合同已批准；具体命令、Run、输入 fixture、设备独占与运行条件仍须绑定执行 AUTH。旧 consumed AUTH 不复用；首失败停止，不自动重录、重建或追随 main。

## 完整性准入

快照必须身份对应、协议/byte count/hash 合法、sequence 边界闭合、queryStarted=queryCompleted 且 active=0、operation 闭合、ordinal 唯一连贯，无 loss/capacity/unknown validity。解析错误拒绝。scope/lifecycle/过期/溢出/丢失只支持明确 lower-bound 或 unavailable，不接受为 exact total。时钟异常样本不进入耗时统计；计数与耗时结论分别说明。

缺少快照不等于零 query；导出成功不等于快照完整。独立证据审查、Product 查询预算及残项接受仍按各自权限推进。

## 后续增强与父任务边界

新增存储协议、目录所有权、配额、保留策略、App 导出 UI 为可选后续能力，不是本次 P2 或父任务关闭的新增前置条件，见[归档设计](../plans/typo-correction-002-int003-query-cost-p2-local-evidence-design-001.md)。ADR draft 保持 Proposed / deferred，不 Accept，不实施。

父 TYPO-CORRECTION-002 保持 Active。本合同不授予 Gate/Close、merge、TestFlight/Release；不恢复 180ms 硬门槛或 RimeRuntimeProvenance。真实总体性能残项在父任务最终 Gate 前须有相应证据或 Human 明确的独立范围/风险决定，不能自动当作通过。

## 历史与当前执行入口

[旧 memory route](TYPO-CORRECTION-002-INT003-QUERY-COST-P2-MEMORY-EVIDENCE-ROUTE-001.md)、原 interface §8.2/§9.7 的外部 profiler 必需项，对下一限定 Run 由本合同替代；历史设计、失败和 Partial 不倒写。

当前路线与待冻结的执行条件见[最小验证准备](../plans/typo-correction-002-int003-query-cost-p2-minimal-route-preparation-001.md)。本次仅文档同步，无新运行证据。

## 2026-10-10：Human批准的观测scope补充

Human“批准，请继续吧”明确接受[两scope最小适配设计](../plans/typo-correction-002-int003-query-cost-p2-route-compatibility-design-001.md)并授权独立DEBUG实施。原路由绑定native correction session；当前threadAffine/provider路由可绑定真实installed facade ordinal、已有owner epoch及owner发布的有效Luna runtime快照。两种scope必须以显式kind区分，不将epoch叫作纠错sessionID；unsupported/missing/inconsistent仍拒绝。provider elapsed只表示已安装provider facade调用，不能声称librime correction查询、CPU或完整UI成本。

query数/stage/readiness/bucket/apply-discard/elapsed、完整性和隐私要求不降；原始readiness unknown原样记录，观测scope unknown不得作exact admission。私有codec v2保持既有尺寸并严格标注来源；旧v1证据不倒写。此补充不是runtime Pass、正式P2完成或Gate；具体新candidate测试/安装/运行仍各自AUTH。


## 2026-10-11：本次已有Run的Human批准覆盖调整

Human明确“不希望再重新测试一遍”，在六类各一次＋一次额外重复、保留raw、另存实际输入映射、撤去完整warm组比较并限定独立审查建议之后答“继续吧”。本调整仅适用于 `TC2-SIM-20261011-INT003-ROUTE-QUERY-001` 的现存7闭合序列证据，不倒写原capture/导出AUTH或历史判定，不授权重录。

本轮必需输入覆盖为F01–F06各至少一次，actual序列F01,F01额外,F02,F03,F04,F05,F06。保留全部raw，ordinal2为额外F01，无查询记录；分析canonical选ordinal1/3/4/5/6/7，另列额外ordinal2。编码fixture/arm数值不改，以独立Human操作回执生成派生actual mapping；不将自动arm2标签称真实warm，不推断删除重复能恢复引擎状态。

原12序列、完整FirstObserved/warm比较对本次限定query诊断不再是通过必要项。保留6类单次样本、完整精确计数/协议/双副本/scope/生命周期/隐私及耗时数值要求；readiness unknown照实保留，只声明provider facade elapsed及本run计数，不能给出cold/warm稳健性、nativeRIME、CPU/UI、Release/总体observer结论。两次F01均无query/operation说明记录指标相同，不证明内部状态相同。

独立Test/Release审查须确认输入归属、完整性、工具身份、统计和适用边界；通过后仍需Human Product查询预算/残项决定。本调整不是独立review Pass、Gate、父Close或Release。当前只改合同/现有证据审查，0设备/源码/test/build/重测，不因main变化重试。


## 2026-10-11：Human接受本Run限定结果

Human当前明确：“接受这份限定结果，未知的残项你指的是什么？还有你的建议是什么？”据此记录接受 `TC2-SIM-20261011-INT003-ROUTE-QUERY-001` 六case单次＋额外F01的完整provider-facade调用计数/elapsed观察及[Scoped Pass with conditions审查](../reviews/TYPO-CORRECTION-002-INT003-QUERY-COST-P2-REVIEW-DELIVERY-001-closeout-r2.md)。无需因额外F01重采，保留raw及actualmapping。此接受仅本次限定结果；对当前v2总体observer开销、nativeRIME/CPU/UI/Release未验证范围及Product预算残项仍在解释/建议阶段，未把本句话推定为全部风险接受。

当前事实：61个provider调用，Stage48/13，readiness全部unknown且候选bucket均zero，壁钟量化min/median0、p953/max6µs；不能据这些数据宣称native后端查询或非空候选场景成本、整体按键延迟、Release预算接受、长期查询密度改善。旧synthetic仅其原环境方法证据。父TYPO-CORRECTION-002保持Active，无Gate/Close/ADR Accept/merge/Release；当前只docs接收决定，0设备/测试/重测，旧consumed AUTH不复用。

## 2026-10-11：接受本轮结论限制并结束限定P2收敛

解释未知及“接受为本轮限制，结束P2采集，然后盘点父任务”的建议后，Human明确“可以按你的建议继续”。据此，本Run总体observer/nativeCPU/UI/Release、非空候选及cold/warm未验证范围接受为限定诊断的结论限制，不追加本轮采集，限定P2证据收敛完成。`QPA-R2-LEGACY-SYNTHETIC-NONREUSE-001` / `P2-CURRENT-OBSERVER-BOUNDARY-001` 的本轮disposition为 **accept**，owner Human Product Lead；旧synthetic不用于证明v2总体成本。`QPA-R2-PRODUCT-RESIDUAL-DECISION-001` / `P2-PRODUCT-BUDGET-001` 本轮决定为 **accept bounded observation without numerical budget**；不虚构全产品调用量/CPU/UI/Release预算。

这是限定P2范围接受，不是父性能Gate风险豁免。父Assignment原性能比较要求仍须单独决定。父保持Active，不Gate/Close/merge/ADR Accept/Release。后续最小交接见[父完成盘点](../evidence/typo-correction-002-parent-closeout-inventory-001.md)。原失败/Partial/AUTH状态保留，0重采/设备/测试。
