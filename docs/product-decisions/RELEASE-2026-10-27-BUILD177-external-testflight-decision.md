# 1.0 (177) 外部 TestFlight 发布决定

## Decision / Status

Human 2026-10-27 原话：“接受与 Build 167 相同的已知风险（TD-003、TD-005、S7 真机恢复事务未遇到、TD-004/TD-002 有范围约束），将 Build 1.0 (177) 发给外部测试组。这不关闭任何技术债，不是 Product Gate 或正式上架许可。现在用户已经可以安装到 Build 177 了。”本记录补入库，原件外置。

候选 1.0 (177)，源提交 `1c9a906c2d0baf12aa62cbb207740bcc16e87efb`：Human 陈述已在 Xcode Cloud 确认，PM 未核验。Beta App Review 已批准且用户可安装是 Human 陈述，未在 App Store Connect 核验。Human 陈述用户群公告已发，不在小红书宣发；公告草稿见下方外置证据。

Human 观察内部冒烟 7 项通过；第 6 项后半“曾开启值失效”是否可验证取决于此前是否开启过，未确认。测试者说明 v2 草稿由发布准备产出，末尾标注待 Human 批准；Human 是否批准及 TestFlight 实际使用的文字 UNKNOWN，待 Human 补充。

Build 167 之后的 first-parent 合并：[#241](https://github.com/shchnk1103/Universe-Keyboard/pull/241) `143f02c`；[#242](https://github.com/shchnk1103/Universe-Keyboard/pull/242) `a97f539`；[#243](https://github.com/shchnk1103/Universe-Keyboard/pull/243) `930bf55`；[#245](https://github.com/shchnk1103/Universe-Keyboard/pull/245) `aeb1d91`；[#244](https://github.com/shchnk1103/Universe-Keyboard/pull/244) `eda15a5`；[#246](https://github.com/shchnk1103/Universe-Keyboard/pull/246) `4c026d5`；[#247](https://github.com/shchnk1103/Universe-Keyboard/pull/247) `cd16fcb`；[#248](https://github.com/shchnk1103/Universe-Keyboard/pull/248) `4477435`；[#249](https://github.com/shchnk1103/Universe-Keyboard/pull/249) `1c9a906`。`release_evidence.py plan` 判定 triggered，CI 仍为 full。候选 main run `40347923968` success：引用 ci-evidence.md（PM 只读取自 GitHub，2026-10-27）。

| 沿用风险 | 状态 |
|---|---|
| TD-003 | 速度无有效样本、内存仅短窗口，未解决 |
| TD-005 | 无真实崩溃/Jetsam 分类实例，ASC 符号接收未确认，未解决 |
| S7 恢复事务 | 真机未遇到真实恢复事务，未解决 |
| TD-004 / TD-002 | 仅完全访问开启测试；恢复/重置先关闭键盘手动操作，范围约束仍在 |
| 长路径、长 Partial、478/484、无障碍 | 未覆盖 |
| 安装载荷身份 | 仅到版本/build |

## Evidence

- Human 决定：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-NEXT-BUILD-PREP-001/reports/human-release-decision-2026-10-27.md`，SHA-256 `72f81d3cadaa4e287952d647c0fe539e8ead3f422cc08df64df4a07dc82e33de`（外置，不入库）。
- 候选与 PR：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-NEXT-BUILD-PREP-001/reports/candidate-identity.md`，SHA-256 `24283be6cce288fc35d4dccdd109be13b89e2ea11b4ffaa0e5fa70fcbdcfdc68`（外置，不入库）；CI：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-CLOSEOUT-177-001/instructions/ci-evidence.md`，SHA-256 `91b8b036aa7e2fed5fd6e2774b5c97c6279ea0985a4fb139fba9a262f58885b2`（外置，不入库）。
- 证据矩阵：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-NEXT-BUILD-PREP-001/reports/evidence-matrix.md`，SHA-256 `de576763010b8ef00adc59f25322b9cf23f81b74eda3c1d1131fd812950f6b40`（外置，不入库）；计划：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-NEXT-BUILD-PREP-001/reports/validation-plan-summary.md`，SHA-256 `42f06734aa5e0167405dc91aa2727fcde33526c421d991e7113770dc38e2c3bb`（外置，不入库）。
- 冒烟清单：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-NEXT-BUILD-PREP-001/reports/human-smoke-checklist.md`，SHA-256 `d905e6875dc600d248311ea23410f58b9671c85ab23e4c6823cd0121e3ecdc91`（外置，不入库）；测试者说明 v2 草稿：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-NEXT-BUILD-PREP-001/reports/tester-notes-v2-draft.md`，SHA-256 `e2b5756d13fa4c9599020afd49bf2aa1dc55ed27b6e0da4ab8c0bd37d2964420`（外置，不入库）；Quality 复核：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-NEXT-BUILD-PREP-001/reports/quality-review.md`，SHA-256 `0ad62e5bce8ec686d68c9fa56626ab47f828bc5ee4faafbdedc3d63bac004f23`（外置，不入库）。
- 用户群公告草稿：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/RELEASE-NEXT-BUILD-PREP-001/reports/group-announcement-v1.md`，SHA-256 `627a8932ddf634f23a3c1a4ee477fb353963115371f69f5cf730ac8f51476abd`（外置，不入库）。

## Non-claims

CI 绿不等于真机或 Gate 通过；Human 观察不是测量。不声明 D4 已被诊断证明解决、性能提升、零崩溃或关闭完全访问可用。不关闭任何技术债；不是 Product Gate 或正式上架许可。

## Related PRs / Assignments

[Build 167 决定](RELEASE-2026-10-25-BUILD167-external-testflight-decision.md)；[D4 Assignment](../assignments/build167-d4-touch-row-shift-001.md)；[Liquid Glass Assignment](../assignments/liquid-glass-debug-only-001.md)。
