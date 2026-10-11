# 固定整合候选一次验证 — Human released / consumed

Human已确认“模拟器仍独占，请你继续吧”；本轮独立AUTH已释放并消费，未复用旧AUTH。精确argv见[新binding](typo-correction-002-fixed-main-validation-001-binding.json)。原下文待授权表述是阶段前置说明，当前回执已解除本轮权限与405D独占依赖。

## 固定输入与环境

- 唯一候选：[整合manifest](../evidence/typo-correction-002-fixed-main-integration-001-candidate.json)，SHA256 `8cf4b3d3cd11dbff9baddb343cf25aa2dc3f2a2d92f864040db83286eb6d2b35`；28源、23Swift。
- writer `/Users/doubleshy0n/.codex/worktrees/int003-final-integration-592/Universe Keyboard`，固定HEAD `59272331b3627856c1c4480b0b5d7ad0ddade0ad`。
- 正式 `Xcode.app`；Simulator iPhone18Pro/iOS27.0/`405D994F-28CB-4F89-BB22-B64AD81C05A2`；必须由Human重新确认本轮独占。未确认不操作设备。
- 独立产物目录 `/private/tmp/uk-finalci592-001`，既有小型归档/证据保留，不重建SystemTrace或进行Human输入。

## 一次验证矩阵

以[已成功完整CI方案](typo-correction-002-final-ci-validation-001.md)和当前固定base的swift6-quality为命令/参数规范：先核对源28hash/index空/环境/产物预算；classifier full与docs-only、轻量质量门、Vendor verify、23strict lint；Core全套、RimeBridge、App+Keyboard默认测试、签名唯一Keychain用例、Release build各一次。不得把旧writer路径或旧manifest原样当成本轮binding。

另对当前候选的DEBUG opt-in组合执行原Core19＋hostless Extension33覆盖，命令/编译旗标来自[原52测试绑定](../evidence/typo-correction-002-int003-query-cost-p2-route-scope-validation-001.md)。这是新依赖组合的回归，不能把默认Extension6计作probe-on33；不重新录制P2。

精确argv在消费前从上述规范生成新binding并保存，不随main变化修改。每项最多一次、第一失败停止余下依赖步骤、不自动修源码或重跑。预算45分钟/可用空间不足停止；结束核对28源不变、结果/skip原因/模式/日志/xcresult摘要。允许的必要自动写入应在Human释放时一并批准：新产物及Xcode/SwiftPM缓存、已有私有合成Rime fixture、唯一Keychain测试项；不改私人配置、不部署/重置方案。

## 不追main与交付边界

验证从上述唯一候选起步，不因main继续前进rebase或循环CI。后来main相关变动仅做只读影响判定，真实冲突交回Human；原Run、通过及skip均保留。没有授权则不执行任何编译/测试/设备操作。成功只产生工程证据；commit/push/PR、hostedCI、merge、Gate/Close和Release仍分别授权。
