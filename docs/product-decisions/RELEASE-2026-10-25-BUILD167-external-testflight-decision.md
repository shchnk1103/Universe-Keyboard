# 1.0 (167) 外部 TestFlight 发布决定

## Decision / Status

Human 2026-10-25 原话：“接受上述风险，Build 167 发给外部测试组。”候选 1.0 (167)，源提交 `3962cae109a42b9fcdfa4a6214fd08cf6d276533`。本记录补入库，原件外置。Human 决定使用已批准的测试者说明并加入与 Build 132 相同的外部测试组。

Human 接受：TD-003 速度无有效样本、内存仅短窗口；TD-005 无真实崩溃/Jetsam 分类实例、App Store Connect 符号接收未确认；S7 真机未遇到真实恢复事务；TD-004 有范围跳过、TD-002 有操作范围约束；长路径、长 Partial、478/484 和无障碍等未覆盖；安装载荷身份仅到版本/构建号。Build 94 的 TD-003/TD-004 有界延期及 TD-005 留债是先例；本决定是对 Build 167 的单独决定。

## Evidence

- Human 决定：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/PF031-EVIDENCE-REVIEW-001/reports/human-release-decision-2026-10-25.md`，SHA-256 `972ede334f9665586304f680f26f9175c78e2d68495bce033f9b938cba6a3ba8`（外置，不入库）。
- 测试者说明：`/Users/doubleshy0n/.kos-work/Universe-Keyboard/PF031-S5-TESTER-NOTES/tester-notes-final.md`，SHA-256 `173a82e462c1527ab96fb0b93b64c4e1f2869074490c4f8379f992efd9ed1e19`（外置，不入库）。

## Non-claims

不关闭任何技术债，相关债务继续 Open；不是 Product Gate 或正式上架许可。

## Related PRs / Assignments

[Build 94 先例](RELEASE-2026-09-25-BUILD94-public-beta-decision.md)；[发布准备 Assignment](../assignments/release-2026-10-external-testflight-001.md)；[Build 177 决定](RELEASE-2026-10-27-BUILD177-external-testflight-decision.md)。
