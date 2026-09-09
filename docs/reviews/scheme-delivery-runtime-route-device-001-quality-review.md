# SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001 独立 Quality 复审

日期：2026-09-09 Asia/Shanghai
复审 lane：KOS Quality / Performance / Release
复审类型：独立、只读；本轮唯一新增文件为本审查文档
复审基线：`/private/tmp/uk-scheme-delivery-fix`，`codex/scheme-delivery-fix`，
`HEAD=f9060fc55264b66c2479592885d40690000b4e14`

## Scope

本复审核查：

- [`SCHEME-DELIVERY-RUNTIME-ROUTE-DEVICE-001`](../assignments/scheme-delivery-runtime-route-device-001.md) 的 Assignment、Exit Criteria、Stop Conditions 与残余处置；
- [`2026-09-09 device evidence`](../evidence/scheme-delivery-runtime-route-device-001-2026-09-09.md) 的真机身份、两条 active-uninstall 观察和隐私边界；
- 当前工作树的 route transaction / diagnostics diff；
- [`P1 final independent review`](scheme-delivery-runtime-route-integration-001-p1-final-independent-review.md) 及其自动化验证结论；
- 前一轮 [`CS09-10-02 failing device evidence`](../evidence/scheme-delivery-cross-scheme-cs09-cs10-device-2026-09-08.md) 所记录的对照症状。

本复审没有运行测试、操作设备、读取 App Group 原始目录、读取候选文字或修改生产代码、测试代码、Assignment 和 Active Work。未把诊断列表中可见的 code/time/level/category 当作 payload 证据。

## Verdict

**CS09-10-02 candidate 的功能性设备结果：Pass。** 两条由 Human Device Operator 提供的二元观察均显示：

| active 方案卸载 | Main App 路由 | Keyboard Extension 对受控 `ni` 的观察 |
|---|---|---|
| Rime Ice | 切换到 Luna | 有正常中文候选 |
| Wanxiang | 切换到 Luna | 有正常中文候选 |

这两条观察足以证明当前签名 Debug candidate 在记录的 iPhone 13 Pro / iOS 27.0 环境中，没有重现上一轮“主 App 报告 Luna 部署成功、Extension 对 `ni` 无中文候选”的功能故障。它们不证明每个 route payload 字段，也不证明一般性能结果或真实 App Group 崩溃原子性。

**Quality 结论：Pass with conditions。** 当前复审没有发现新的 P0 或 P1；计数为 **P0: 0 · P1: 0**。Assignment 仍不能因本复审直接变成 Closed，因为 operation-correlated payload 仍无法从现有诊断 UI 中核验，且耗时对照没有获得。

## Evidence matrix

| 检查项 | 证据 | 结论 |
|---|---|---|
| Candidate / device identity | signed Debug `Universe Keyboard`、bundle `com.DoubleShy0N.Universe-Keyboard`、wired iPhone 13 Pro (`iPhone14,2`)、iOS 27.0 (`24A5430a`)、CoreDevice install/launch success | 通过；为本轮设备记录的环境身份 |
| Ice active-uninstall | Main App 切 Luna；Extension 对受控 `ni` 报告有正常中文候选 | 通过；Human-attested functional observation |
| Wanxiang active-uninstall | Main App 切 Luna；Extension 对受控 `ni` 报告有正常中文候选 | 通过；Human-attested functional observation |
| Route event visibility | 诊断列表显示十条 `runtime_route.phase_changed`，分属两个时间簇 | 仅证明 producer/persistence presence；不证明 payload details |
| Operation correlation | 列表未展示 operation UUID，未取得 JSONL payload | 未获得；不得声称两组事件已按 UUID 关联 |
| Phase / result / route fields | 列表未展示 phase、result、schema、layout、state | 未获得；不得从 generic code 推导字段值 |
| Elapsed / normal Luna comparison | 没有可见 `elapsed_ms`，也没有普通 Luna deploy 对照 | **暂无获得**；不判断 fallback 是否比普通 Luna 慢或是否已修复 |
| Privacy boundary | 未记录候选文字、宿主内容、截图、App Group 文件、路径、URL 或用户数据 | 通过；符合本 Assignment 的最小数据边界 |

## Runtime-route diagnostics boundary

当前诊断页的十条记录都是同一个 event code：`runtime_route.phase_changed`。因此它们只能回答“新的 route event producer 在两个时间簇中有记录”，不能回答：

- 每条记录属于哪个 operation UUID；
- 发生了哪一个 phase/result；
- 记录时的 schema、layout、runtime state 是什么；
- `elapsed_ms` 的具体值，或是否存在普通 Luna 对照。

前一份 P1 独立复审已经在代码、journal round-trip、统一测试 helper 和 live lease seam 层面核查了有限 payload 的生产合同；本次真机列表观察不能把那份自动化证据升级成设备端 payload 读取证据。真机功能 Pass 与 payload 详情不可见必须同时保留。

## Findings and residual disposition

没有新的 P0/P1 finding。以下两项是 Assignment 已登记、仍未闭合的观察性残余；它们都有明确 owner 和 disposition，符合 KOS residual disposition 要求：

| ID | 现状 | Owner | Disposition | 复审判断 |
|---|---|---|---|---|
| `RTRD-01` | 诊断列表只显示 code/time/level/category，未在点击后展示有限 runtime-route payload | Main App UI / Diagnostics | `fix` | 保持开放；后续独立 UI Assignment 可实现底部详情窗口，只展示 UUID、phase/result、schema/layout/state、有限耗时等字段 |
| `RTRD-02` | 普通 Luna 与 fallback 的 `elapsed_ms` 对照暂无获得；复制/列表也未展开 payload | Main App UI / Diagnostics | `fix` | 保持开放；需要可审计的 payload 读取路径和一次普通 Luna 对照后再作性能判断 |

`RTRD-01` / `RTRD-02` 的 `fix` 不是本轮真机证据失败，也不应被改写成 `accept`；它们阻止 Assignment 完全关闭，但不否定两条候选输入的功能性 Pass。

## Draft push decision

**允许将当前候选作为 draft PR candidate 推送。** 理由是：

1. 当前实现已经有前序独立 P1 复审结论，且该复审未发现 P0/P1 阻断；
2. 本轮两条 active-uninstall 方向均通过 Human-attested functional observation；
3. `RTRD-01` 与 `RTRD-02` 已有 owner、`fix` disposition 和明确后续边界；
4. 未把耗时不可见性包装成性能修复结论。

该决定只覆盖 draft candidate 的分支推送，不等于 PR merge、Product Gate、TestFlight、Release、ADR 接受或 Assignment Closed。推送前仍应由 Coordinator 按仓库硬门槛保留 Swift format 通过证据，并在交接中链接本复审、设备证据和 P1 final review。

## Non-claims

本复审不声明：

- fallback Luna 部署耗时已经恢复到普通 Luna 部署水平；
- 十条 generic event code 已提供十条可读 payload；
- 真机已经证明 operation UUID、phase/result、route state 或 `elapsed_ms`；
- 已完成 `RTRD-01` / `RTRD-02`；
- 已完成 Product Gate、PR merge、TestFlight、Release 或 ADR 接受。

## Handoff

Coordinator 可据此把本 Assignment 交给 Product Owner：功能性 candidate outcome 为 Pass，设备观察为 Pass with conditions，耗时保持 unavailable，诊断 UI 与性能测量分别由 `RTRD-01` / `RTRD-02` 继续承接。若后续修改 source/build/device/OS、重新安装 candidate、改变诊断 schema 或增加手工输入轮次，必须重新执行本 Assignment 的设备复核。
