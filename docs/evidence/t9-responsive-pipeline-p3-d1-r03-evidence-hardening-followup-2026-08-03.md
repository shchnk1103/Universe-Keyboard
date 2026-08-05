# P3-D1-R03 Evidence Hardening Follow-up

状态：**Completed — Q1 validator/reopenability closed; Q2/Q3 evidence residuals remain**  
日期：2026-08-03（Asia/Shanghai）  
Run：`P3D1-R03-OFF-20260803-001`  
原始证据：[R03 真机证据](t9-responsive-pipeline-p3-d1-r03-device-2026-08-03.md)

## 范围

本 follow-up 只处理 Evidence Hardening 的两项低风险闭合动作：

1. 在受控临时目录用当前 `T9ResponsiveEvidenceValidator` 对用户提供的外部附件做只读、
   run-token 隔离的 content-free 复核；仓库不复制原始日志。
2. 记录 Human 在普通 Release 恢复包上的最小键盘 smoke check。

没有修改生产逻辑、默认 gate、ADR、用户数据或设备配置；没有开启 B、没有重新输入长句、
没有删除诊断日志。

## Validator 复核

| 字段 | 值 |
|---|---|
| Attachment | 外部用户附件；不复制进仓库 |
| Attachment bytes | `20919` |
| Attachment SHA-256 | `6cc87c38e1f682a26d5cf1ad85aadeacfcda6b353b371dda131f576691fa4d76` |
| Run token | `S6A-976A047CA1BB477AA5BAC6836278209B` |
| Arm / observed marker fixture | `sync` / `T9RESP-R5P` |
| Canonical P2-PERF-02 fixture | `T9-RESP-PERF-39-V1` / digest `772b4bb30cb831d04550e8311a2f64e66aad4ab55c4597544f0cc9364f9d7286`; not bound by original run header |
| Run-bound line count | `44` |
| Validator source SHA-256 | `1a722eb59611fd3e49bff2c9fc29e03dcb827df619e8da1de025f434f4c09c92` |
| Validator build | `swift build --package-path Packages/KeyboardCore --scratch-path /private/tmp/P3D1-R03-validator-scratch`；exit 0 |
| Validator result | `complete` |
| Reasons | `[]` |
| Observed path | `sync`；`dualGateRequested=0`；`dualGateActive=0` |
| Required marker semantics | path=`true`；ready=`false`；run-bound=`true`；felt markers=`false` |
| T9SEG actions/events | `1…39` / `1…39` |
| Geometry | prepared + execution；digest match = `true` |
| Session | valid = `true`；stable = `true` |
| Commit | `false` |
| Privacy violation | `false` |

本次输出只保留上述摘要；没有把 raw pinyin、候选、宿主文本、用户词典或附件原文写入仓库。
机器可读摘要见 [`validator-summary.json`](t9-responsive-pipeline-p3-d1-r03-validator-summary-2026-08-03.json)，
其 SHA-256 为 `d5b8275f6dc06190188488cf1d47d777448f150c9d012751ab653e03377756b3`。
这关闭了 Quality 复核中的 **P2-R03-Q1（附件不可独立重开/validator 不可复算）**，但不改变
R03 的整体 `Partial` 状态。

## 恢复后 Human smoke check

Human 在普通 Release 恢复包上报告：

| 字段 | 结果 |
|---|---|
| 键盘出现 | `yes` |
| 单个九宫格字母键生效 | `yes` |
| 键盘退出 | `no` |
| 运行保持稳定 | `yes` |
| `stallScore` | `0` |
| 评分含义 | 本次只按一个键；`0` 表示该 smoke check 完全不卡，不代表长句性能 SLO |
| 原始输入/宿主文本 | 未记录 |

该结果关闭“恢复后是否可见冒烟”的观察缺口，但不是长句 A/B 或恢复生命周期完整证明。

## 仍开放的残余

- **P2-R03-Q2**：source/build/restore 的完整不可变绑定仍需更完整的 SDK/toolchain/签名/
  可重放命令和 restore identity；本 follow-up 不补猜缺失字段。
- **P2-R03-Q3**：fixture/host/run-header 的 fixture digest、opaque host ID、Full Access、
  runtime/readiness 和完整时间窗仍未落入原始 R03 run header。
- 单次 39-action A 基线仍不能证明用户 SLO、因果关系或 off-main 收益。
- B/A、真实 librime、Extension memory/jetsam、iOS 26.0 Release RC、ADR 0025 和 Product
  Gate 仍未执行。

## 结论与交接

Evidence Hardening follow-up 已完成其可在当前范围内安全完成的部分；R03 继续保持：

`Partial — gate-off baseline captured; validator and post-restore smoke hardened; B comparison not run`

下一步若要补 Q2/Q3 或执行 B，必须建立新的明确授权和独立 Run ID；本文件不接受 ADR 0025、
不改变默认 gate、不形成 Release 或 Product Gate 结论。

Q2/Q3 的只读 provenance 补录见 [`Q2/Q3 evidence hardening addendum`](../assignments/t9-responsive-pipeline-001-p3-d1-r03-q2-q3-evidence-hardening.md)。
该补录中的 `ccb155…` 仅为事后派生哈希，不能替代上述 canonical digest，也不能证明 A/B
fixture 等价性。
