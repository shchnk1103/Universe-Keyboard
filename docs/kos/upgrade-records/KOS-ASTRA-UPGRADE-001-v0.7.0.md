# KOS v0.7.0 adoption record

> **Superseded for current pin:** [PD-KOS-UPGRADE-UK-004](../../product-decisions/KOS-UPGRADE-UK-004-adoption.md) adopted `v0.8.0` advisory; PR [#99](https://github.com/shchnk1103/Universe-Keyboard/pull/99) merged `4c9f424`. Text below is the historical v0.7.0 record.

- Owner: Human Product Owner; executor: current Codex runtime.
- From: v0.6.0 advisory, `a16c93281718f97cb580935c5043562c39f3a1d1`.
- Target: [v0.7.0 Release](https://github.com/shchnk1103/kos-agent-kit/releases/tag/v0.7.0), `f7f4dad6750b59dc827c1366fcd276447b2820b2`.
- Disposition: Historical Adopted `v0.7.0` advisory. Default-branch publication landed as PR [#99](https://github.com/shchnk1103/Universe-Keyboard/pull/99) merged `4c9f424`. Current pin is `v0.8.0`.
- Authority: after the recommendation to resolve local parity and update the exact v0.7.0 pin, Human Product Owner replied “OK，那你觉得接下来最优先做的事情是什么？你直接开始吧”, then “额度已恢复，请继续本次未完成的任务吧”. This authorized the v0.7.0 project upgrade implementation; the earlier Kit #5 approval alone did not.

## Impact and boundaries

Optional execution hygiene clarifies current authorization, stage dependencies, progressive reading, verification reuse and economical delegation. Frozen core, schema and validator are unchanged. Keep advisory; do not instantiate an orchestration plan or migrate existing Active Assignments. Real task token/latency savings remain unmeasured.

## Verification

PR #99 input `31bfbed1a5214b1519558501cbe19ea4672d6036` has a successful full [hosted run](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/33975144350). Local Xcode beta App crashes also reproduce on unchanged baseline; this is not a local pass. Matching stable Xcode requires its missing iOS 26.5 simulator component. Installation completed. Stable Xcode 26.6 is incompatible with host macOS 27 beta. On supported local Xcode 27 beta with iOS 26.5, all required test/build commands succeeded; see the new evidence below.

Independent reviews and frozen content bindings: [review status](../../reviews/kos-execution-001-review-status.md), [evidence](../../evidence/kos-astra-upgrade-001.md).

Profile and entry mirrors now pin the released Kit. Structural validation and final PR checks must cover this adoption delta. Existing task baselines remain unchanged.

Local gate: [2026-09-06 evidence](../../evidence/kos-astra-local-gate-2026-09-06.md).
