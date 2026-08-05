# T9-RESPONSIVE-PIPELINE-001 / P3-D1-R03
# iPhone 13 Pro gate-off baseline：独立 Quality / Performance 只读复核

状态：`Completed — independent Quality review; bounded baseline remains Partial`

复核日期：2026-08-03

复核角色：独立 Quality / Performance reviewer（只读）

## 1. 复核范围与停止边界

本复核只覆盖以下材料：

- `docs/assignments/t9-responsive-pipeline-001-p3-d1-r03-device-baseline.md`
- `docs/evidence/t9-responsive-pipeline-p3-d1-r03-device-2026-08-03.md`
- `docs/assignments/t9-responsive-pipeline-001-p3-d1-runtime-lifecycle-matrix.md` 中 P3-D1-R03 相关行及其运行/隐私约束
- `docs/assignments/t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md`

本次没有修改生产逻辑、没有改变任何 gate 默认值、没有执行 B、没有做 A/B、没有使用真机补测，也没有把本证据升级为 Architecture 通过、Product Gate 或 Release 证据。

## 2. Verdict

**Verdict：条件通过（bounded gate-off baseline）；P3-D1-R03 仍为 `Partial`，不得宣称 Product Gate / Release。**

本次材料足以证明一个范围明确的事实：在 iPhone 13 Pro、iOS 27、Release、响应式/线程亲和 gate 均关闭的情况下，人工完成了冻结的 39-key 九宫格观测，记录到连续的 39 个 `T9SEG`，并观察到明显卡顿；本次同步路径的长尾主要出现在 RIME/processKey 段。这是有效的 A 基线方向性证据。

本次材料不足以让独立 Quality 重新计算全部统计、重新执行隐私/令牌隔离校验，或完整复现恢复后的键盘 smoke check。因此，结论只能保持 `Partial`。

严重度计数（本复核发现的残余）：

| P0 | P1 | P2 | P3 |
|---:|---:|---:|---:|
| 0 | 0 | 3 | 2 |

P2/P3 是证据完整性与可复核性残余，不是对用户数据泄漏或生产默认开启的断言。

## 3. 已证实的内容

### 3.1 Gate-off 与运行身份（有界通过）

- 运行边界明确为 gate-off A baseline；未注入 `T9_AUTO_ANCHOR_*_ENABLED`、`T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`。
- `T9DEVICE marker=T9DEVICE_DISABLED gate=off measurement=on` 证明设备测量 gate 关闭。
- `T9RESP path=sync dualGateRequested=0 dualGateActive=0` 证明本次走普通同步路径，而不是响应式/线程亲和路径。
- App 与 Keyboard.appex 均有 SHA-256；设备型号、OS、UDID、CoreDevice、Release 配置和源码/工作区指纹已记录。
- 因此可以把本次结果用于“同步 gate-off A 基线”，不能把它用于证明 B 或 off-main RIME。

### 3.2 39/39 输入完整性（执行者证据有界通过）

- `T9SEG` 数量为 39，action/event 为连续 `1…39`。
- session `5787163992` 稳定；39 个动作的 `validBefore/validAfter` 均为 `true`。
- 39 个动作均为 `committed=false`，符合本 fixture 不包含 commit/space/delete 的约束。
- `T9ARM actions=38` 被正确解释为历史 checkpoint，而不是漏掉第 39 个动作。
- Human report 未观察到漏键、重复、候选消失或键盘退出。

因此，材料内部没有显示 P0/P1 级输入完整性故障。但由于原始诊断附件没有随审查材料可重新打开，以下“独立重算”仍有条件限制，见 P2-R03-Q1。

### 3.3 令牌隔离与旧日志边界（设计/摘要通过，独立重算受限）

- 本次使用唯一的 `Run ID` 与设备预检 token；证据明确把较早的日志片段排除在当前 token 范围之外。
- 证据没有把旧日志数值混入当前 39-action 统计。
- 旧日志未删除，符合可追溯性和非破坏性边界。

这说明隔离规则被正确应用于摘要；但没有原始附件、marker 样本清单或 validator 输出，Quality 无法独立证明每一条纳入统计的记录都绑定到该 token。

### 3.4 性能统计的合理边界

- `total`：median 14.2 ms，max 187.8 ms。
- `rime`：median 7.7 ms，max 186.6 ms。
- `ui`：median 5.3 ms，max 7.7 ms。
- slow-RIME 标记为 6 个动作（1、14、16、25、33、35）；峰值为 action 33。

这些数字支持一个谨慎的方向性判断：本次同步路径的长尾与 `processKey`/RIME bridge 时间高度重合，而不是在已记录的 UI segment 中出现同量级峰值。证据使用了“归因范围收窄”“当前数据不支持……”等限定语，没有把它写成因果证明或用户 SLO。

## 4. Quality 残余与改进要求

### P2-R03-Q1：原始诊断附件不可独立重开，validator/privacy 结果不可复算

证据只提供外部附件 SHA-256 与 content-free 摘要，没有提供可由 reviewer 重新读取的附件路径/字节数/副本，也没有本次对该附件运行 `T9ResponsiveEvidenceValidator` 的输出。证据还说明仅做了 ASCII 扫描；ASCII-only 不能单独证明不存在 ASCII 形式的原始拼音、候选或 host text。

这不等于发现了隐私泄漏；它表示独立 Quality 只能审阅声明，不能重算 39/39、token isolation、timing 聚合或 privacy deny-list 结果。

改进：为下一次同类 run 保存受控的 content-free validator 输出（包含 path/bytes/SHA/privacy decision 与 token/action 汇总），或让 reviewer 能在受控临时位置按给出的 SHA 重开同一附件；不得把原始用户文本复制进仓库。

### P2-R03-Q2：source/build/restore 的不可变绑定仍不完整

已记录源码 HEAD、tracked diff fingerprint、untracked-name fingerprint 和安装包 SHA，但 dirty worktree 的 untracked fingerprint 只对名称做摘要，没有证明 untracked 内容；同时未给出 SDK/Xcode/toolchain、deployment target、签名身份或可重放的 build command。恢复包有 app/appex SHA 和安装 DB sequence，但没有同等完整的 restore source/build identity。

另外，契约要求的恢复后 keyboard-switch smoke check 在材料中没有明确记录为 `observed` 或 `unavailable`。现有恢复证明足以支持“同一设备上恢复普通 gate-off 包、未做破坏性清理、未见诊断 marker”的有限结论，不能升级为完整 lifecycle restore proof。

改进：下次 run header 补齐构建身份与 restoreRef；对 dirty worktree 绑定可重建的内容指纹；明确记录恢复后 smoke check 的结果。

### P2-R03-Q3：fixture/host/run-header 的契约字段没有完整落在本 run evidence

证据写明“父矩阵的 39-key fixture”，但没有在本证据中显式绑定 `fixtureID`、fixture digest、cadence/case ID。Reminders 列表、software keyboard、中文九宫格等人工条件有描述，但没有记录隐私安全的 opaque host/list ID、Full Access/runtime/schema/readiness、时间窗口等完整 run-header 字段。

这会削弱后续 A/B 对齐以及第三方 reviewer 对“确实是同一个冻结 fixture、同一个 host envelope”的复核能力；不代表本次人工报告无效。

改进：在不记录用户文本的前提下，把 fixture ID/digest、host opaque ID、keyboard/runtime/readiness、Full Access 状态和时间窗口写入 content-free run header。

### P3-R03-Q4：单次 39-action 观测不能代表重复样本或用户可感 SLO

本 run 有明确的峰值和 slow-RIME ordinal，但只有一组 39-action A baseline；没有重复 run、分位数置信范围、掉帧/主线程 frame evidence，也没有 Human numeric `stallScore`（材料正确地记录为主观“明显卡顿”，没有擅自填 0）。

因此统计只能作为 baseline 与后续 B 比较的输入，不能单独证明“主观不卡顿”、不能建立因果结论，也不能作为 Product Gate。

### P3-R03-Q5：B/A-B 与真实 off-main production 仍未验证（授权边界内的开放项）

B、同源 A/B、真实 librime off-main、Extension jetsam/memory、iOS 26 RC、ADR 0025、用户可感 SLO 均明确未执行。这里没有把“未执行”误报成缺陷；它们是下一阶段授权前必须保持可见的残余。

## 5. P2-PERF-02 契约对照

| 契约层 | 本次判断 | 说明 |
|---|---|---|
| Runtime facts | 有界通过 | 39 个 `T9SEG`、session、时间统计和 marker 摘要已给出；原始附件不可重算。 |
| Runtime identity | 有界通过 | Run/device/app/appex/source 指纹存在；完整 build/dirty/restore 绑定仍有 P2-Q2。 |
| Human result | 部分通过 | 人工条件与完整性报告存在；stallScore 数字未提供，按契约应保持 unavailable。 |
| Lifecycle restore | 部分通过 | 同设备替换与普通 gate-off hash/marker 结果存在；post-restore smoke 与完整 restore identity 缺失。 |
| Privacy/content-free | 部分通过 | 证据摘要不含用户文本；validator/deny-list 结果无法由本次 reviewer 重算。 |
| Gate/path proof | 有界通过 | `T9DEVICE` + `T9RESP sync/dualGate=0` 支持 A gate-off；不支持 B。 |
| A/B comparability | 未执行 | B 不在本次授权内。 |

依照契约，任一必需层不完整时保持 `Partial`；`Partial` 不得升级为 Complete、ADR Accepted、Product Gate 或 Release。

## 6. 下一步授权建议（不执行）

1. 将 P3-D1-R03 作为**可用但有界的 gate-off A baseline**保留，不改父矩阵的 `Partial` 语义。
2. 在授权 B 之前，先补齐 P2-R03-Q1～Q3 的证据合同字段：content-free validator 输出与 artifact 可重开、完整 run/fixture/host/build/restore identity，以及 post-restore smoke 结果。
3. 若 Product Lead 需要 B，对同一源码/设备/OS/fixture/host envelope 新建独立 B run ID 和 token；只注入显式 B flag，保持 Release 默认关闭，不把 A 与 B 的统计混在同一 token 中。
4. B 完成后再交独立 Architecture 与 Quality 复审；在此之前不得宣布 off-main 生产接线、ADR 0025 Accept、Product Gate 或 Release。

## 7. 停止声明

本复核已完成且停止。没有修改生产逻辑或默认 gate，没有执行 B 或真机补测，也没有做 Product/Release 决策。
