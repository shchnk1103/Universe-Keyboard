# T9-RESPONSIVE-PIPELINE-001 / P3-D1-R03 真机 Gate-off 基线证据

状态：**Partial（gate-off A 基线与 bounded Evidence Hardening 已完成；B 对照与 Product Gate 不在本授权内）**  
日期：2026-08-03（Asia/Shanghai）  
Assignment：[`P3-D1-R03 iPhone 13 Pro Gate-off Baseline`](../assignments/t9-responsive-pipeline-001-p3-d1-r03-device-baseline.md)

## 运行边界

- 本次只运行 gate-off 基线；没有开启 responsive/thread-affine 路径、A/B 对照、自动点击或
  坐标驱动，也没有修改生产逻辑、默认设置、RIME/Lua 或用户数据。
- Human 在提醒事项输入位置手动完成父矩阵声明的 39-key 九宫格 fixture；没有点数字页、
  Path 或候选。诊断记录只保留内容无关 marker、长度、计数、时序、session 和 geometry。
- Human 报告：无漏键、无重键、无候选消失、无键盘退出；主观上不够流畅，出现按键卡顿。

## 不可变 provenance

| 字段 | 值 |
|---|---|
| Run ID | `P3D1-R03-OFF-20260803-001` |
| Device preflight token | `S6A-976A047CA1BB477AA5BAC6836278209B` |
| Source HEAD | `3585a540ba8389673acd49128d87040ac9619f27` |
| Worktree | dirty；86 个条目；本次未覆盖、未暂存、未提交既有改动 |
| Tracked diff fingerprint | `5f67fc561b8e2494c895a6176909fc2602dad4492f275eed839a36eda40c45be` |
| Untracked-name fingerprint | `ce8fbc520ed5e98eeb9a602ac95522941cd8373a381dc09653fbff8370513e0f` |
| Build | Release；命令行只注入 `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` |
| Explicitly absent | `T9_AUTO_ANCHOR_*_ENABLED`、`T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED`；普通 responsive/thread-affine gate 仍为默认 `false` |
| App executable SHA-256 | `36f1138bda3e8e2a3942eb099782acb2f449a401d97767a7046a57f3abc7165e` |
| Keyboard.appex executable SHA-256 | `ec0f05193114b3cf0d98683608a8a225a4b09b3ad6bb7ed3e6bb0aaa65122d0f` |
| Device | iPhone 13 Pro / `iPhone14,2` |
| OS | iOS `27.0 (24A5390f)` |
| Device UDID | `00008110-000A08440198801E` |
| CoreDevice identifier | `DE65EBE1-463E-5EB4-9694-F6DCBFC04028` |
| Connection | wired / paired / connected / booted / Developer Mode enabled |
| Diagnostic attachment SHA-256 | `6cc87c38e1f682a26d5cf1ad85aadeacfcda6b353b371dda131f576691fa4d76` |

## Teardown / restore proof

为避免设备继续运行诊断专用包，证据采集后用同一 source HEAD 构建了未注入
`T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` 的普通 Release 包，并以替换安装方式恢复到同一台
iPhone 13 Pro。构建成功，安装结果为 `success`，device install database sequence 为
`3744`。恢复包指纹如下：

| 字段 | 值 |
|---|---|
| Restore build | Release；未注入诊断 compilation condition |
| Restore app executable SHA-256 | `b5a6ee5fe1ba8ac19ff3342d96dc0ba0c11ec53007494938eab80cc35cbefce8` |
| Restore Keyboard.appex executable SHA-256 | `8f24558f195c57201e51059608af53f8193219aca1df217ad4b964ea71c5fd4a` |
| Restore marker scan | 未发现 `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` 或 `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` |
| Destructive cleanup | 未执行；未卸载、未清空 App Group/userdb、未清空提醒事项、未抹除设备 |

恢复后 Human 最小 smoke check：键盘出现、单个九宫格字母键生效、键盘未退出且保持稳定；
`stallScore=0`（仅代表这个单键 smoke check 完全不卡，不代表长句性能 SLO）。详见
[`Evidence Hardening follow-up`](t9-responsive-pipeline-p3-d1-r03-evidence-hardening-followup-2026-08-03.md)。

## Gate/path/geometry proof

本次附件在当前 token 范围内包含：

- `T9DEVICE ... marker=T9DEVICE_DISABLED ... gate=off measurement=on`：证明 auto-anchor
  设备测量 gate 关闭；它不单独等价于 responsive B gate。
- `T9RESP ... path=sync dualGateRequested=0 dualGateActive=0`：证明本次实际走普通同步路径，
  没有启用 responsive/thread-affine 诊断路径。
- `T9GEOM phase=prepared` 与 `phase=execution` 使用同一 digest
  `a87fed1f933a4f4a95a6be393c12ba2844f386d1d55c85036502eee921eb068e`；本次人工输入不使用
  坐标驱动，因此 geometry 只作为设备布局观察，不是自动化输入证明。

## 运行结果（仅当前 token）

| 指标 | 结果 |
|---|---|
| `T9SEG` 数量 | 39；action/event `1…39` 连续 |
| `T9ARM` checkpoint | 在最后一个 action 前记录 `actions=38`；随后仍有 action 39，不构成漏键 |
| Session | `5787163992`；39 条均 `validBefore=true`、`validAfter=true`，保持稳定 |
| Commit | 39 条均 `committed=false` |
| `total` | 中位数 14.2ms；最大 187.8ms |
| `rime` | 中位数 7.7ms；最大 186.6ms |
| `ui` | 中位数 5.3ms；最大 7.7ms |
| 慢 RIME 次数 | 6 次（action 1、14、16、25、33、35；阈值按现有诊断 marker） |
| 慢 RIME 峰值 | action 33：`processKey≈186.6ms`，整键 `total≈187.8ms` |

因此，这次真实设备基线把卡顿归因范围收窄到：**同步 `processKey`/RIME bridge 占用按键热路径**。
当前数据不支持把卡顿归因于候选 UI 或 Path bar：UI 段在峰值 RIME 调用期间约 1ms，整次运行
UI 最大约 7.7ms。

附件开头还有多个更早的诊断片段（例如 09:03 的 170ms 行）；它们不属于本 Run ID，分析时已
按 `T9DEVICE` token 隔离，没有把它们混入本次统计。

## 隐私与证据完整性

- 附件 ASCII 扫描未发现非 ASCII 内容；未发现 raw pinyin、候选文本、提醒事项文本、用户词典
  或凭据。
- 本次未清空 App Diagnostics；保留旧日志以避免删除已存在证据，当前结果通过 run token 隔离。
- 诊断附件是用户提供的外部文本；仓库只记录其 SHA-256 和内容无关摘要，不复制原始日志。
- Evidence Hardening follow-up 已在受控临时目录对外部附件按当前 run token 重新执行
  `T9ResponsiveEvidenceValidator`：`complete`，39/39 action/event 连续，geometry digest
  匹配，session 有效且稳定，`sawPrivacyViolation=false`；只把 content-free 摘要写入
  [`follow-up`](t9-responsive-pipeline-p3-d1-r03-evidence-hardening-followup-2026-08-03.md)，
  不复制原始附件。历史复审中对 `candidates=12` 计数字段的误报风险仍保留为实现注意事项，
  但本次实际 validator 结果没有触发 privacy violation。

## 已证明与未证明

已证明：在真实 iPhone 13 Pro、gate-off 同步路径和 39-key 人工 fixture 下，输入完整性保持，
session/geometry 稳定；按键卡顿与 RIME `processKey` 的 150ms+ 峰值同向出现。

未证明：thread-affine B 是否改善主观流畅度、A/B 同源比较、真实 off-main 生产接线、jetsam/
memory、iOS 26.0 Release RC、Product Gate、ADR 0025 接受或任何用户可见 SLO。

## Handoff

- Parent matrix 的 `P3-D1-R03` 应标记为 **Partial — gate-off baseline captured**，并链接本证据。
- 独立复核已完成：[`Architecture review`](../assignments/t9-responsive-pipeline-001-p3-d1-r03-device-architecture-review.md)
  判定为本证据层 **Pass with conditions**（P0/P1=0）；[`Quality review`](../assignments/t9-responsive-pipeline-001-p3-d1-r03-device-quality-review.md)
  判定为 bounded gate-off A baseline（P0/P1=0）。两份复核均保留 `Partial`，并明确未接受
  ADR 0025、未打开 B、未形成 Product Gate 或 Release 结论。
- Architecture 残余：时间相关不能替代因果隔离；诊断注入 Release 构建不能替代 Release/RC
  证明。
- Quality 残余：完整 source/build/restore 绑定不全；fixture/host/run-header 字段不完整；
  单次 39-action 不能形成 SLO；B/A、真实 off-main、jetsam 等仍未验证。附件复算与恢复后
  smoke 已由 follow-up 闭合，不改变 Q2/Q3 残余。
- Q2/Q3 证据字段的只读补录见 [`Q2/Q3 Evidence Hardening addendum`](../assignments/t9-responsive-pipeline-001-p3-d1-r03-q2-q3-evidence-hardening.md)：
  build/restore identity 与 observed marker fixture ID 已补录；canonical human fixture digest
  映射未建立，历史未捕获的 untracked content、host opaque ID、Full Access、runtime/readiness
  和原始时间窗保持 `unavailable`，不做补猜。
- 若要证明方向二是否改善主观卡顿，需要另行授权同源 gate-on/thread-affine B 对照，不得把
  本次 A 基线当作 off-main 已完成。
- 本 Assignment 在证据交付处停止，不宣布 Product Gate、Release 或默认开启。
