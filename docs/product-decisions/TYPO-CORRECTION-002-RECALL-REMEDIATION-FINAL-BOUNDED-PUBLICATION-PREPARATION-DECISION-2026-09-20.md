# TYPO-CORRECTION-002 recall remediation
# Final bounded Product publication-preparation decision

## Product 结论

**Bounded Accept with conditions：允许继续 publication preparation，但不允许据此发布。**

在下列 exact snapshot 与独立 Architecture/Quality review 边界内，Product 接受所列工程证据作为继续 publication preparation 的 bounded residual。该接受只表示可以进入另行授权的准备阶段；不把工程质量矩阵提升为运行时、设备、产品或发布结论。

## Exact binding

| 项目 | 精确值 |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-recall-publication-staging-001` |
| HEAD | `162b09fd58ba60538a944026b1902efa405c75aa` |
| HEAD tree | `92c5047c5d1a6dd6a751eb5344117f8138c14ef2` |
| Source manifest | `docs/evidence/typo-correction-002-recall-remediation-publication-staging-source-manifest-2026-09-20-002.txt` |
| Manifest SHA-256 | `e2b4373c0797a0959b0b0da10c1db01cf4fa81cfe25903c7d9726942edab465c` |
| Architecture review | `docs/reviews/typo-correction-002-recall-remediation-final-architecture-review-2026-09-20.md` |
| Architecture review SHA-256 | `25dba823b50d12c3090346f408ae681719c852e998b3044a6751f525b9d4412b` |
| Quality review | `docs/reviews/typo-correction-002-recall-remediation-final-quality-review-2026-09-20.md` |
| Quality review SHA-256 | `a7070f9ff8c5e26312eed45cc9a6207de187acd99f086caa58036b95ac0a5692` |
| Quality Run | `TC2-RECALL-QUALITY-20260920-002` |

本次只读复核确认：Architecture 与 Quality review、Quality Run 002 receipt 对上述
HEAD/tree、manifest identity 与 Run ID 的绑定一致；manifest 实际为 652 bytes、5 行
LF 文本、末字节为 `0a`，实际 SHA-256 与授权值一致。

## 可接受的 bounded residual

以下仅作为继续 publication preparation 的有条件工程 residual 接受，并保留其原始边界：

- App + Keyboard 的权威结果为 **387 = 378 passed + 9 skipped + 0 failed**。外层记录的
  **388 仅是 wrapper/discovery observation**，不得作为权威总数、coverage denominator
  或额外通过项。
- KeyboardCore 为 **1139 tests / 0 failures**；RimeBridge 为 **81 passed / 0 failed /
  20 skipped**；Release 为 **`BUILD SUCCEEDED`**。这些均是本地工程证据，不是运行时或
  发布证据。
- 20 个 RimeBridge skipped 与 9 个 App + Keyboard skipped 继续按 skipped 保留，不得
  当作 passed。
- 当前 Run 002 的 AppIntents metadata warnings 继续保留为 warning residual；Quality
  review 记录的出现位置为 App Debug 4 次、RimeBridge 1 次、Release 2 次。
- KeyboardCore 的 optional-interpolation warning 继续保留为 warning residual。
- `CODE_SIGNING_ALLOWED=NO` 是本次验证环境边界，不能被解释为签名、安装或设备验收
  证据。

## 不接受的扩大解释

本 Product decision **不接受**将上述证据扩大为以下任何结论：

- production runtime wiring 或 runtime acceptance；
- device acceptance；
- 真实 RIME 候选召回或真实 RIME 集成验收；
- INT-003、QA-001、paired performance、180 ms 或 contextual 7/8；
- 任何 Product Gate、Quality Gate 或 Release Gate。

Quality Run 002、独立 Architecture review 与独立 Quality review 均不改变这些
non-claims。parent/child Assignment 的生命周期也不因本 decision 改变。

## Authorization boundary

本 decision 只记录 bounded Product publication-preparation disposition，**不授权**：

- publication；
- commit、push、PR 或 merge；
- TestFlight 或 Release；
- 任何 Assignment close。

本 decision 也不授权修改 Swift、测试、工程、RIME/vendor、Assignment、状态镜像、review
或其他 Authorization，不授权 build/test/format/vendor/install/deploy 或新的 Run。

## 下一步建议

如需继续推进实际 publication 流程，唯一建议是**另立独立 publication Authorization**，
并重新绑定准确的 HEAD/tree、manifest、文件范围、所需门禁与发布动作。该独立
Authorization 未在本 decision 中创建、授权或消费；在其明确授权前，不得执行任何外部
发布动作。
