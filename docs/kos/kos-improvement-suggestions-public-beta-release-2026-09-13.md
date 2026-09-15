# KOS 改进建议：外部公测发布的证据分级与差异验证

> **状态：建议稿；未采纳**
>
> **日期：** `2026-09-13 Asia/Shanghai`
>
> **输入：** Build 55 公测候选的真机 Product Gate、TD-003/004/005 证据交接、全新安装边界、雾凇九宫格 Gate，以及独立 Quality/Release Reviewer 的 `Blocked` 结论。

本文件是一次发布复盘建议，不是 KOS 2.0/2.1 的冻结规则、KOS 2.2 的 required 合同、Product Decision、Assignment、Quality 结论或 Release 授权。它不改变当前仓库状态，也不授权代码、测试、真机、App Store Connect、TestFlight、commit、push、merge 或发布动作。

## 目的

保留首次外部公测候选所需的严格证据，同时避免后续每一个 Beta build 都机械地重做整套 TD-003/004/005、全新安装和全部功能 Gate。核心原则是：

1. 候选身份必须先精确冻结；
2. 证据可以作为比较基线复用，但不能脱离构建身份直接外推；
3. 后续验证按变更和风险触发，只补受影响的边界；
4. `scoped pass`、独立 Quality 结论和 Product Gate 必须继续分层；
5. 人工设备操作应是一次有界行动包，而不是反复要求操作者重跑整轮。

## 本次复盘观察

| 观察 | 影响 |
|---|---|
| Build 55 的功能性真机、雾凇下载/部署和九宫格路径已有有效的限定范围证据 | 证明了具体路径可工作，但不等于整体公测 Gate 通过 |
| TD-003 的两次 Time Profiler 采集证明了采集链路和进程出现 | 没有形成受控冷/暖、首键、固定节奏、候选或内存基线；重复同类采集不会自动关闭 TD-003 |
| TD-004 OFF/ON 基础矩阵已完成 | 共享设置、学习、诊断持久化、资源未就绪和恢复边界仍未覆盖；不应要求用户重做已经完成的基础矩阵 |
| TD-005 已执行当前日志查询和 UUID 过滤 | Jetsam 没有 victim 标记，仍需完整采集/分类链；重复同一查询不能替代分类证据 |
| App 卸载重装不等于 App Group/RIME/user dictionary 清空 | 全新共享容器边界必须作为独立证据，不应由“已重装”推导为干净状态 |
| umbrella Release 记录仍指向 Build 7，而 Build 55 证据指向 `b8175129…` | 候选身份、证据绑定和 Release 状态需要一个单一的事实元组 |

## 建议

### KOS-SUG-PB-01：外部公测采用三档证据路径

在未来发布 Assignment 中提供一个明确的路径选择，但不新增生命周期状态：

| 路径 | 适用场景 | 最小验证形状 |
|---|---|---|
| `baseline` | 首次外部候选、重大架构/RIME/权限变化、工具链或支持系统变化 | 建立完整的候选身份、性能/内存/崩溃分类、关键真机边界和材料证据 |
| `delta` | 普通修复或低风险 UI/文案变化，且没有命中重验证触发器 | 精确候选身份、与改动路径对应的 CI/测试/真机 smoke，复用未受影响的已审证据 |
| `triggered` | 命中性能、键盘热路径、RIME、Full Access、App Group、方案交付、崩溃、工具链或支持矩阵触发器 | 只重跑受影响的 TD 或边界；必要时升级为 `baseline` |

`delta` 不是自动豁免。每次选择都必须记录为什么旧证据仍与当前 claim、environment、artifact 和 contract 相容；无法证明时保持 `UNKNOWN` 或进入 `triggered`。

### KOS-SUG-PB-02：冻结“候选事实元组”

在候选证据开始前，建立一个只读可核对的 Candidate Fact Tuple：

```text
source_commit: <full SHA>
rc_tag: <immutable tag or UNKNOWN>
version_build: <marketing version / build>
cloud_workflow_build: <workflow / build ID>
archive_sha256: <SHA-256>
store_or_ad_hoc_package_sha256: <SHA-256>
app_uuid: <UUID>
keyboard_uuid: <UUID>
app_dsym_uuid: <UUID>
keyboard_dsym_uuid: <UUID>
rime_manifest_digest: <digest>
toolchain: <Xcode / SDK / Swift>
```

候选事实元组只回答“这次证据属于哪个构建”，不代表 Quality Pass 或 Product 接受风险。任何 source/build/UUID 变化都至少需要新的 artifact mapping；是否需要完整重测由变更触发器决定。

### KOS-SUG-PB-03：增加“复用/补测”证据台账

每条未来 release claim 建议增加以下字段：

```text
claim: <精确行为>
evidence_grade: <provenance grade>
outcome: pass | partial | fail | inconclusive | not-run
candidate_tuple: <Fact Tuple ID>
environment: <device / OS / host / access / schema>
reusable_as: comparator | current-proof | none
revalidation_trigger: <具体触发条件>
next_slice: <一个有界补测或 UNKNOWN>
```

旧证据默认只能作为 comparator；只有在候选身份、环境、行为合同和证据新鲜度均满足条件时，才可作为当前 claim 的 proof。这样可以明确解释“做过一轮但仍未关闭”，也能阻止“CI 全绿”覆盖到未被 CI 覆盖的新候选。

### KOS-SUG-PB-04：为人工真机操作生成发布专用行动包

发布前的 Human action package 建议固定为：

1. 一页 manifest：候选身份、设备/OS、schema、Full Access、宿主和隐私边界；
2. readiness review：逐条确认需要的字段能否读取；
3. 一次人工 round：固定合成输入、固定观察点、固定停止条件；
4. 只针对 `next_slice` 操作，不重做已通过的无关 Gate；
5. 运行后只记录 content-free 诊断、观察结果、缺失字段和 `inconclusive` 原因。

这与已采纳的人工可观测性边界保持一致；本建议只提出把它包装进 release delta 流程，不重新采纳或扩大现有 KOS-SUG-07/08 合同。

### KOS-SUG-PB-05：把 Release Gate 拆成三层结果

建议所有外部候选 handoff 显式区分：

```text
scoped_evidence: <具体路径是否通过>
independent_quality: pass | fail | blocked | pending
product_release_gate: pass | fail | blocked | pending
external_action: upload-only | internal-distribution | external-distribution | beta-review | not-authorized
```

例如，Build 55 雾凇九宫格可以是 `scoped_evidence=pass`，但并不因此推导出 `independent_quality=pass` 或 `product_release_gate=pass`。上传、分组分发和 Beta Review 也必须继续分开授权。

### KOS-SUG-PB-06：把“首次候选”与“后续 Beta”分开维护

建议在 release handoff 中维护两张表：

- `Candidate Baseline`：首次建立的性能、崩溃分类、共享容器、首次安装和支持矩阵证据；
- `Candidate Delta`：当前 build 相对基线命中的变更、复用证据、补测结果和未变化理由。

全新安装只在 onboarding、App Group、RIME 部署/方案下载、用户词典或安装生命周期变化时重新触发；TD-003/004/005 也按触发器重新验证，而不是按 build number 自动全量重跑。

本建议稿仍保持「建议稿；未采纳」。任何后续有界实现切片不在本文记录，也不把本稿升级为 KOS 规则或 Release Gate。

## 建议的后续 Beta 最小路径

在不命中重大触发器时，未来一个普通外部 Beta 可按以下顺序：

1. 生成并核对 Candidate Fact Tuple；
2. 跑 CI 和改动路径测试；
3. 只做受影响路径的最小真机 smoke；
4. 更新复用/补测台账和残余风险；
5. 独立 Quality 审查差异；
6. Product Lead 决定是否进入对应外部动作。

命中性能、RIME、Full Access、App Group、方案交付、崩溃/Jetsam、工具链或支持范围变化时，再按 `triggered` 或 `baseline` 路径升级。

## 采用前必须回答的问题

1. 哪些变更路径一定触发 `baseline`，哪些只触发 `delta`？
2. 证据“可复用”需要哪些固定字段和有效期？
3. Candidate Fact Tuple 的唯一主文档应属于 Release Acceptance、Assignment 还是新的 handoff 模板？
4. 如何在不接受更广泛外部风险的前提下表达有限内部测试的例外？
5. 是否需要为这套路径创建新的 bounded implementation Assignment、模板和独立 Architecture/Quality review？

## 明确不改变的内容

- 不修改 KOS 2.0 frozen constitution。
- 不把 KOS 2.2 advisory validator 变成 required，也不把校验绿升级为 Release 通过。
- 不自动关闭、跳过或接受 TD-003/004/005。
- 不把历史 Build 7 证据自动迁移为 Build 55 证据。
- 不授权任何代码、测试、真机数据、App Group 清理、commit、push、merge、TestFlight 上传、分发或 Beta Review。
- 任何 `Adopted` 方向都必须另建明确的 Product Assignment，并经过适用的 Architecture/Quality 审查。

## 参考资料

- [Build 55 公测候选证据审查交接](../evidence/release-2026-09-13-build55-public-beta-readiness-handoff.md)
- [Release Checklist](../RELEASE_CHECKLIST.md)
- [Performance Baseline](../PERFORMANCE_BASELINE.md)
- [RELEASE-2026-0801 umbrella Assignment](../assignments/release-2026-08-01.md)
- [RELEASE-2026-0801-04 device/performance Assignment](../assignments/release-2026-08-01-04-device-performance.md)
- [Crash/Jetsam/Symbolication procedure](../CRASH_JETSAM_SYMBOLICATION.md)
