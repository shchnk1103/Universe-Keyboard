# 独立 Architecture 复审：T9-RESPONSIVE-PIPELINE-001 / P2-PERF-02 B 臂

| 字段 | 结论 |
|---|---|
| 复审角色 | 🏛️ Architecture & Knowledge Steward（独立、只读） |
| 复审日期 | 2026-08-01（Asia/Shanghai） |
| 复审对象 | `T9-RESPONSIVE-PIPELINE-001 / P2-PERF-02` B arm |
| 主要材料 | [`Assignment`](t9-responsive-pipeline-001-p2-perf-02-release-like.md)、[`B evidence`](../evidence/t9-responsive-pipeline-p2-perf-02-b-2026-08-01.md)、附件摘要及 `performResponsivePresentationApply` / preflight marker 源码 |
| Architecture 结论 | **Partial / Pass with conditions**：B 臂的 thread-affine 行为有 bounded 旁证，但 A/B、session、geometry、完整路径与 Release 性能合同仍未闭环 |
| P0 / P1 / P2 / P3 | **0 / 0 / 4 / 1** |
| 治理结论 | ADR 0025 仍 `Proposed`；不形成 Product Gate、R6、Release 通过或默认开启结论 |

## 1. 复审范围与证据状态

本复审只读检查 B 臂是否足以支持一个受限的 thread-affine bounded 结论，以及
证据/Assignment 是否诚实保留以下缺口：

- 合法 run token 与 B flags；
- `T9RESP ACCEPT`、provisional `VISIBLE`、双 `PUBLISH` 的顺序和语义；
- `T9GEOM phase=execution run=invalid`；
- `T9SEG` / `T9ARM` 的 `session=0`、`sessionStable=false`、`sessionValid=false`；
- 只有 B 臂证据，没有可配对的 A 臂方向比较；
- 没有数值 Human stall score、完整 `PATH/READY` engine-category marker、
  queue/memory/jetsam 或 App Store Release 证据。

本复审未修改生产代码、RIME/Lua、测试、flag 默认值或设备状态，也不把 B 臂记录
改写成 ADR、Product Gate、Release 或 R6 结论。

## 2. B 臂身份与 thread-affine bounded 结论

### 2.1 可以确认的路径事实

本次 B evidence 提供了以下相互独立的身份线索：

1. Run header 声明 B 编译 flags 为
   `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` +
   `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`，没有任何
   `T9_AUTO_ANCHOR_*_ENABLED` flag；B App/Extension hash 与 raw attachment hash
   已记录。
2. 附件先出现合法 `T9DEVICE ... run=S6A-A01... gate=off measurement=on`，随后
   `T9SEG` 连续 action/event 1–39 均绑定该 token。这里的 `gate=off` 是 auto-anchor
   device measurement gate，不是 responsive B gate；Assignment 已把两者分开。
3. 每个 revision 出现 `T9RESP marker=ACCEPT pending=1`，慢调用时先出现
   `source=provisional` 的 `VISIBLE`，随后出现普通 publish，再出现第二条
   `T9RESP marker=PUBLISH fixture=T9RESP-R5P epoch=1 rev=...`。
4. 源码中第二条 preflight `PUBLISH` marker 只在
   `isThreadAffineRimeOwnerEnabled` 为真时，由
   `performResponsivePresentationApply` 发出；它不是普通 gate-off 或
   MainActor-responsive 路径的通用 marker。

据此，**可以形成以下有限结论：**在这次真实 iPhone 13 Pro B 臂运行中，至少有
一条 explicit thread-affine responsive presentation path 被激活；输入接受与
provisional 视觉反馈可以先于慢 RIME 结果出现，且后续 publish revision 保持有序。

这就是本次 Architecture 允许的 **thread-affine bounded observation**。它不是
“线程亲和性所有合同已验证”，更不是“off-main 生产迁移完成”。

### 2.2 为什么不能升级为完整 thread-affine Pass

- 导出没有 `T9RESP marker=PATH path=thread-affine` 或 `READY` 的 engine-category
  行。双 `PUBLISH` 是强旁证，但不是完整 path/bootstrap/readiness 取证。
- 所有保留 `T9SEG` 行的 `sessionBefore/After=0 valid=false`，最终 `T9ARM` 为
  `session=0 sessionStable=false sessionValid=false`。因此不能把真实 RIME session
  稳定性、跨 key identity 或 owner-session continuity 写成通过。
- `T9GEOM phase=prepared` 有合法 token，但首键前的
  `T9GEOM phase=execution run=invalid status=unavailable` 使执行几何连续性未证明。
  由于本轮是 Human 手动输入，不应把它伪装成坐标自动化失败；但也不能声称 A/B
  几何完全一致。
- B evidence 只描述 B 臂；没有同源、同设备、同 fixture 的 A 臂记录，不能得出
  “B 比 A 更流畅/减少 stall”的方向结论。

## 3. B 臂观察的内容边界

### 3.1 已证明（bounded B 行为）

- B flags 与合法 run token 的关联、1–39 连续 `T9SEG` 保留范围；
- `ACCEPT → provisional VISIBLE → publish → thread-affine-only PUBLISH` 的观测
  顺序；
- 在 `processKey` 仍有约 56.5、147.1、151.3、178.7、181.9 ms 慢调用时，
  MainActor 接受/临时视觉反馈没有等待到 engine 结果之后才出现；
- Human 报告无漏键、重复、候选消失或键盘退出，主观上“整体流畅”。这是定性
  人工报告，不是数值 SLO，也不能覆盖 session=0 的诊断缺口；
- B 臂之后已替换回 A/普通 gate-off 包并发起 cleanup；这只表示 teardown 记录，
  不等于 Release 性能通过。

### 3.2 未证明

- A/B 的方向性比较、同源 baseline、差异效应大小或任何统计显著性；
- thread-affine owner 的完整 `PATH/READY`、bootstrap/readiness、RIME session
  identity/stability、execution geometry；
- 输入事件是否在所有生命周期/恢复/abandon 场景下保序、无丢失、无重复；
- queue depth、memory、jetsam、长时间运行、其他设备/OS、iOS 26.0 Release RC；
- App Store/签名 Release 行为、Product Gate、ADR 0025 Accepted、Release default-on；
- `processKey` 结果是否更快。B 仍然观察到 150–182ms 级别的 RIME 调用，证明的
  是 UI/key acceptance 与 engine completion 解耦，不是消除 RIME 延迟。

## 4. 证据完整性与 Assignment exit criteria

### 4.1 A/B 完整性缺口（P2）

Assignment 是“两个 physically comparable Release-optimized internal arms”的
P2-PERF-02，但当前仓库只有 B 证据文件；没有同一 source/worktree/device/fixture
的 A arm evidence 可核对。因此本项不能完成 Assignment §Exit criteria 4 的方向判断，
也不能用旧的 P2-PERF-01 gate-off Debug 记录替代 A：配置、instrumentation、run
identity 与时间窗口不同。

### 4.2 B run provenance / integrity 缺口（P2）

B header 已记录 device、OS（仅 iOS 27，附件未给 minor/build）、Release 配置、
deployment target、B flags、bundle hashes 和 attachment hash，但仍缺：

- source commit/worktree fingerprint；
- 明确的 schema/readiness、Full Access 观察值；
- ordinary gate-off restore 后 A/普通包的已安装 bundle/hash 确认；
- Human 0–4 numeric stall score。

`T9GEOM` execution invalid 与 `session=0` 不是“被忽略的零值”，而是应被保留为
取证失败/未验证状态。当前 evidence 已这样记录，不能把 `committed=0` 或有效
run token 外推成 session 合同已通过。

### 4.3 Marker 与几何语义（P3）

`T9DEVICE gate=off` 容易被读者误解为“B gate off”；evidence 已解释它属于
auto-anchor measurement gate，但建议在后续 A/B 汇总表中把两个 gate 作为独立列，
避免把 `T9DEVICE_DISABLED` 读成 thread-affine 未激活。`PATH/READY` 缺失也应继续标为
“未导出/未证明”，而不是推断为失败或成功。

## 5. Gate、ADR 与 Release 边界复核

| 边界 | 复审结论 |
|---|---|
| 生产逻辑 / RIME / Lua | 未修改、未授权；本次只是 Release-optimized internal diagnostic build |
| responsive gates | project defaults 仍 `false`；B 只靠显式 compile-time preflight flag，未改变默认值 |
| auto-anchor | 没有任何 `T9_AUTO_ANCHOR_*_ENABLED` flag；`T9DEVICE gate=off` 与这一边界一致 |
| ADR 0025 | `Proposed`；B 证据不接受 ADR、不改 ADR 0004 同步路径 |
| Release | “Release-optimized internal diagnostic”不是 shipping Release；不能推导 App Store/RC 行为 |
| Product Gate / R6 | Assignment non-goal，当前未授权、未执行、未声明 |
| teardown | A/普通 gate-off replacement 与 cleanup 已记录；但恢复包 identity 未在 B evidence 中完整列出 |

未发现 P0/P1 的生产安全或治理越界。特别是第二条 `PUBLISH` 只证明本次显式
preflight B 路径发出过 thread-affine marker，不等于允许把 responsive gate 写入
Release default 或用户设置。

## 6. Findings 严重度

### P2（4 项）

1. **P2-PERF-02-E1 — 缺少 A 臂：**没有可配对 A baseline，不能完成 A/B direction
   结论，也不能声称 B 减少主观卡顿。
2. **P2-PERF-02-E2 — session/geometry/path 取证不完整：**`session=0`、
   `sessionStable=false`、`sessionValid=false`、`T9GEOM execution invalid` 和缺失
   `PATH/READY` 使完整 thread-affine/session/geometry 合同保持开放。
3. **P2-PERF-02-E3 — run/exit provenance 不完整：**B evidence 未给 source/worktree
   fingerprint、schema/readiness、Full Access、restore 后安装 identity 与数值
   Human score；Assignment exit criteria 不能全部标记完成。
4. **P2-PERF-02-E4 — 性能结论范围：**B 仍有 150–182ms RIME 调用；可证明的是
   accept/provisional 解耦，不能证明 RIME 变快、主观 SLO、Release 性能或 jetsam。

### P3（1 项）

- **Marker 语义维护：**后续汇总需始终区分 auto-anchor measurement `gate=off`、
  responsive B explicit flag 与普通 Release default-off；不要将缺失 PATH/READY
  解释成 B 未活动，也不要将双 PUBLISH 解释成全链路 readiness 已通过。

## 7. 最终判断与停止点

本 Architecture 结论是 **Partial / Pass with conditions**：

- **满足：**可以把 B 记录交给 Quality，作为“真实 iPhone 13 Pro 上显式 B arm
  产生 thread-affine-only publish，并在慢 RIME 期间先接受输入/显示 provisional”
  的 bounded evidence；
- **不满足：**P2-PERF-02 的完整 A/B exit、session/geometry/PATH/READY 合同、
  数值主观评分或 Release-like 方向性性能结论。

后续应先补 A arm 与 run/provenance/score 字段；若要宣称完整 thread-affine 合同，
还需解决 session=0、execution geometry invalid 和 PATH/READY 导出缺口。此 review
到此停止，不修改生产逻辑。

本结论不接受 ADR 0025，不宣布 Product Gate/Release ready，不授权 R6、默认开启、
用户设置或任何 shipping 决定。
