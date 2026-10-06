# paired-rollout 已有证据与 Exit 对照准备稿 — 2026-10-06

**Prepared / 未生效。** 本 Assignment 仍 **Active**。授权仅已有历史文件只读映射；无新采集、源码、构建、测试、安装、模拟器、LLDB、备份删除、Git 或独立续审。不把 sibling 修复任务的 E1 owner 链并入本合同，不把父 Completed 写成子 Completed。

工作树 `/Users/doubleshy0n/.codex/worktrees/paired-rollout-preflight/Universe Keyboard`，branch `codex/keyboard-wake-v3-compatibility-gate`，HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`，staged 0。输入字节核验见 [input-identity.json](keyboard-wake-diagnostic-extension-paired-rollout-001-jsonl-parent-exit-map-artifacts/input-identity.json)。

## 本对照解决什么

子任务 Current Status 的下一手是「只用已有历史 JSONL 对照父 Exit」。父任务已在 2026-10-04 完成该映射，并以 PEXIT-R1 接受 KWOPROBE 快照替代同轮 JSONL，父诊断有界 Completed。子任务当时明确保持独立 Active。

因此本准备稿做三件事：

1. 抄录父 JSONL/Exit 映射的既有结论，标明子任务不再欠一份重复的父条款表。
2. 把子任务**自身** Exit 分成「诊断 producer / 向父交接」与「全局 v5 兼容 + v6 生产 emission」两条合同，逐项对照已有证据。
3. 提出 Product 可批准的有界收尾选项。未批准前，严格全局 Exit 仍未满足，生命周期保持 Active。

## 不得混用的三条合同

| 合同 | 权威 | 本对照结论 |
|---|---|---|
| 父诊断 Exit | [父历史 Exit 对照](keyboard-wake-lifecycle-diagnostics-001-historical-exit-map-2026-10-04.md) + [父有界完成](../product-decisions/KEYBOARD-WAKE-LIFECYCLE-DIAGNOSTICS-001-bounded-completion-product-decision-2026-10-04.md) | 父侧 JSONL 严格链未通过；PEXIT-R1 已接受 KWOPROBE 替代同轮 JSONL。父 Completed 不关闭本子任务。 |
| 本子诊断交接 | Assignment Handoff：把无内容时间线与限制交给父任务 | [M2R2 独立验收与交接](keyboard-wake-diagnostic-extension-paired-rollout-001-m2r2-reexport-review-validation-2026-10-04.md) 已交付；父 Product 已把它当作实际交接。 |
| 本子全局 rollout Exit | Assignment Exit：v5 兼容门、v6 生产 emission、安装后的 v6 Maps、最终候选独立审查 | 分阶段证据存在；**生产 v6 emission 与「已审查已安装 v6 promotion 上的 Maps」未满足**。 |

HOST-ACTIVATION-FIX-001 的 E1（1496 bytes / 16 rows，两 paired attempt owner/receipt 均为 1，epoch 1→2）属于 sibling 修复 Assignment 的有界完成证据，见 [修复有界完成](../product-decisions/KEYBOARD-WAKE-HOST-ACTIVATION-FIX-001-bounded-completion-product-decision-2026-10-06.md)。该决定写明 paired-rollout 仍 Active。本对照引用 E1 只为排除混用。

## 父 JSONL → 父 Exit（已完成，不重做）

来源：[父历史 Exit 对照](keyboard-wake-lifecycle-diagnostics-001-historical-exit-map-2026-10-04.md)。本表不改写该原件。

| 父条款 | 已有材料 | 父对照结论 | 对本子任务的含义 |
|---|---|---|---|
| 1 baseline / failure / recovery | M2R2 双 attempt；9/27 旧恢复属旧候选 | Partial：当前恢复未跨候选补齐 | 子交接已给出失败 schedule 边界；完整恢复仍未证 |
| 2 可观测生命周期 / owner / engine / UI | M2R2 suspend/teardown + schedule | Partial：缺 resume/engine/publication/UI 同轮覆盖 | 子任务不得把「无 resume 标记」写成系统回调未发生 |
| 3 源 / 产物 / 环境 / access | 43d85d 窗口分别记账 | 有界齐；schema 仅 configured | 保持原窗口身份，不与后来修复安装混绑 |
| 4 JSONL 来源身份与 arm/writer preflight | 9/27 有 capture-time 路径但原始段未归档；C5/C6 投影无 raw 段 SHA；M2R2 诊断 off、来源是 KWOPROBE | **不满足严格 JSONL 条款** | 不能补造历史段 SHA；不能把 probe 缓冲写成 JSONL |
| 5 privacy / artifact hash | 固定数值 snapshot | Covered（限定工件） | 保持 |
| 6 Debug Investigator 报告 | 旧报告与 M2R2 结构 | Covered | 保持 |
| 7 独立 Architecture / Quality | M2R2 双 lane Partial；Quality 指定文件未写出 | Partial | 子残项，不因父 Completed 消失 |
| 8 领域交接 | M2R2 交接报告 | 已写交接；接收者未 ACK | 父 PD 指定 Keyboard Experience 主接 / KeyboardCore 协作 |

父 PEXIT-R1/R2/R3 已接受：KWOPROBE 替代同轮 JSONL；正常/失败 attempt 达到父诊断交接目的；poll 序号 5 / Quality 文件写出 / wall time 为父交付非阻塞残项。这些处置**仅父诊断**，不自动变成子任务全局 Exit 通过。

固定父交接工件：候选 `43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50`；UDID `405D994F-28CB-4F89-BB22-B64AD81C05A2`；PID 55759；snapshot SHA-256 `11bafebea4e558360a155d5ac3f7739161f2e4177456fd84f7322bef1b5e631e`（1056 bytes / 11 rows）；attempt1 schedule owner/receipt=1/1，teardown 后 attempt2=0/0。

## 子任务全局 Exit 逐项

依据 Assignment Exit Criteria 原文，只映射已有阶段证据。

| 完成条件 | 已有证据及范围 | 当前结论 |
|---|---|---|
| v5 兼容门：现行 v5 行为保留，生产 wake-marker 关闭 | [v5 阶段验证](keyboard-wake-diagnostic-extension-paired-rollout-001-v5-stage-validation-2026-09-30.md)；Architecture R1–R4 / Quality R1–R2；`V5-Q-001..003` 已阶段接受 | **该阶段兼容门有证据**。30 skip 未验证、不计通过。不证明后来 C7/43d85d 安装仍是同一 v5 身份。 |
| v6 emission：授权边界发出闭合码，该 writer 新记录全为 v6 | Stage A/B reader、C1–C4 本地 producer/配对版本、C5 安装切片均为分阶段授权 | **生产 v6 emission promotion 未作为已审查已安装候选完成**。C3 本地选 v6 不等于安装后的生产 emission Exit。 |
| 测试覆盖 mapping / 门控 / 异步 ingress / 临时存储 | Stage A Core 测试、C7-A host、后续 T 矩阵分窗口存在 | 分阶段测试存在；不是单一最终 promotion 候选的完整套件。App 查询路径曾 authored/not-run。 |
| v5 候选同一 Main App + Extension 身份，reader 处理 v3/v4/v5，无已安装生产 wake-marker | v5 manifest r2 绑定 | 该阶段有绑定。C5/C7/I1 的 43d85d 是后续 UI/probe 候选，不能回写为 v5 门身份。 |
| 新 v6 promotion：独立授权、配对身份、完整验证、精确候选审查之后才安装 / Maps | 无该顺序下的最终 promotion 包 | **未满足**。C6/M2/M2R2 Maps 不是「已审查 v6 promotion 安装」上的 Human 复现。 |
| 冻结一份集成源/测试候选及二进制 SHA | 多份阶段 manifest | 多候选并存；无单一最终 v6 promotion 冻结。 |
| 完整 CI 等价矩阵（含 vendor / format / Core / Bridge / App / Release） | v5、Stage B、T 等阶段矩阵；skip 分阶段接受 | 阶段矩阵可复用为历史；30 skip 原接受边界保留。sibling 修复 A2 矩阵不属于本 Exit。 |
| v6 混合版本 / 残缺 / fallback 抑制矩阵 | Stage A/B reader 测试 | 局部 reader 证据；不是已安装 v6 生产路径证明。 |
| 有界异步 ingress，proxy 不等待 journal | 分阶段静态/测试 | 有针对性证据；不声称 Release 性能。 |
| Human 在已审查已安装 v6 promotion 上做 Maps AppSwitcher | C6 变体无法唯一绑定；M2R2 为 43d85d、诊断 off、KWOPROBE；E1 属修复任务 | **本 Exit 的 v6 Maps 条款未满足**。M2R2 服务父诊断交接，不服务 v6 promotion Maps。 |
| 最终候选独立 Architecture / Quality | 多轮 Partial；M2R2 双 lane Partial | 无 overall Pass。Quality 指定文件未写出、poll 序号 5、wall time 未核验保留。 |
| 把无内容时间线与限制交给父任务 | M2R2 交接 + 父有界完成 | **诊断交接已交付并被父 Product 接受**。接收者领域 ACK、修复实施、根因仍未要求本任务完成。 |

## 子任务仍开放的残项（原件保留）

1. 严格 JSONL 段 SHA / writer-health / build 历史链：父对照已判定不可用现文件补造；M2R2 诊断 off。
2. 完整恢复、缺 resume 原因、engine / publication / UI / host / realized schema。
3. 生产 v6 emission、已审查 v6 promotion 安装与 Maps。
4. M2R2 Architecture/Quality overall Partial；Quality 文件写出与 native poll 序号 5。
5. 历史 skip 身份：各阶段 `accept` 只记录未验证 skip，不计通过。
6. C6 失败变体不能唯一绑定 machine 事件；C7-A 源/host 测试不是运行期 owner 缺失证据。
7. C7-B2 记载的旧 Hold / 格式诊断等阶段残项，不在本对照中重新接受或清除。

## 最小收尾建议（Proposed，未批准）

建议 Human Product Owner 只在本子任务上选择其一。Coordinator 不自批豁免。

**选项 A（推荐）— 有界 Completed：诊断 producer 与父交接交付。** 完成范围限定为：已授权的 v5 兼容阶段与后续分阶段 producer/reader/安装/probe 证据；M2R2 正常/失败 schedule owner/receipt 对照及独立 Partial；向父任务的无内容时间线交接（父已有界 Completed）。原全局 v6 生产 emission / 已审查 v6 Maps / 最终 overall Pass / 严格 JSONL 原文保留为未满足的历史完整 rollout 目标，接受为非阻塞未验证。独立 Partial、skip 原件、账本残项不改写。这不是 Reviewed/Closed、Quality/Product/Release Gate，也不是行为修复保证。

必须写明的残项：

- R-JSONL：同轮 JSONL 来源链未满足；沿用父 PEXIT-R1 的事实（KWOPROBE 不是 JSONL），本子任务不另称第 4 条通过。
- R-V6：生产 v6 emission 与已审查 v6 promotion Maps 未做。
- R-COV：完整恢复 / 系统回调 / engine-publication-UI 同轮覆盖未证。
- R-AUDIT：M2R2 poll 序号 5、Quality 指定文件未写出、wall time 未独立核验。
- R-SKIP：各阶段已接受的 skip 保持未验证、不计通过。

**选项 B — 保持 Active。** 不修订 Exit。下一步只能针对上表**一条**未满足条款另开精确 Entry（例如单独的 v6 promotion，或另授权的 JSONL 捕获）。禁止为凑合同重跑 E1/Maps/owner 导出。

不建议：把 E1 整数恢复链写成子任务 Exit 通过；重开已 Completed 的父诊断或宿主修复；删除备份；Git/Release。

若不批准选项 A，生命周期保持 Active，本准备稿只作对照，不降低原 Exit。

## 后续 Product 决定 — 2026-10-06

Human 已明确「接受选项 A」，详见[Product 决定](../product-decisions/KEYBOARD-WAKE-DIAGNOSTIC-EXTENSION-PAIRED-ROLLOUT-001-bounded-completion-product-decision-2026-10-06.md)。该决定取代本表 Prepared/Pending 状态，原提案字节另保全；本子任务现为 Completed — 诊断 producer 与父交接交付。严格未验证部分 / 独立 Partial 保持。不把 E1 并入本合同，不改写父诊断或宿主修复已批准合同。

## 权限边界

本 AUTH 只写对照与导航镜像。未运行 xcodebuild/测试/模拟器。五源码与 HEAD/branch/staged 未改。无 CHANGELOG/ADR/Git/Release。已有大备份未新增或删除。
