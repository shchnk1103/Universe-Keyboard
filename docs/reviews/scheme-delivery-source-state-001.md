# SCHEME-DELIVERY-SOURCE-STATE-001 independent review

Date: 2026-09-07. Frozen implementation `905c50ee69cf4698c43b9912937a69ba1592752b`, base `4c9f424e06c316578f1b97ae5ecfbcd9afdeb2e4`.

## Continuity and independence

The original Architecture (`01a07653-4fd0-7e43-a436-8c55de5e91c3`) and Quality (`01a07653-5060-7c70-860c-8df3fa791bef`) runtimes ended on account quota without final conclusions. They were unavailable when resuming. The replacement runtimes below did not implement the changes and performed bounded read-only review in the same logical lanes. Original attempts remain incomplete; they are not passes.

## Architecture

Replacement: Ohm, `01a07a02-186c-7dc0-b2f9-ea08182b8fc8`.

Conclusion excerpt: “静态架构复核结论：未发现阻塞性问题。”

Reviewer checked the two-source race/cancellation and fail-closed behavior, finite rejection reasons, dated archive/staged identity bindings, pre-selection manifest/revision validation, content-free typed diagnostics with optional backward-readable field, and stable schemaID filtering across consumers. Artifact authenticity assessment explicitly relies on the executor's successful actual-download and staged-verifier evidence; the reviewer did not rerun it.

## Quality

Replacement: Carver, `01a07a02-1902-7562-b41f-2b91b6eccadd`.

Conclusion excerpt: “只读审查结论：无阻塞性发现。”

Reviewer checked drift-vs-transport/HTTP/redirect classification, cancellation and successful alternatives, real archive processing for both sources and Lua modes, cleanup/fallback coverage, failure identity/replacement tests, old-nightly update and typed diagnostic serialization. The tests exercise state consumers; human detail-page navigation remains separately required.

Record observations: the evidence's stale pending-test sentence was corrected using actual passing logs/hosted results. The fixture variable documentation now explicitly distinguishes launch-side `TEST_RUNNER_SCHEME_PIN_ARCHIVE_ROOT` from test-process `SCHEME_PIN_ARCHIVE_ROOT`, verified by the non-skipped fixture test. No runtime code was changed for either record clarification.

Neither review performed tests, granted Human/Product acceptance, or approved device installation, merge or TestFlight/App Release. Later changes are evidence/review/status records only and need link/diff validation; any implementation change reopens the applicable review.

## P2/P3 Architecture review — 2026-09-07 takeover

Reviewer: Ohm, `01a07a02-186c-7dc0-b2f9-ea08182b8fc8`; independent read-only review of `b90d236` plus the current worktree.

Initial conclusion: **Fail; ADR 0034 must remain Proposed.** P1: known-pollution restoration occurred before the install mutation ledger, so a later failure did not restore the transaction's original bytes. P2: backup used one static path without operation identity. Wanxiang P4 ownership/uninstall remained incomplete.

Executor corrected only the existing P3 transaction: recovery uses the current `.builtin-backup-<UUID>` root and appends the recovery as the first mutation. Reverse rollback restores normal install mutations and then the exact pre-transaction polluted bytes. A failure-injection test covers the sequence and backup cleanup.

Delta conclusion: **original P1/P2 closed; no new blocking finding in the transaction increment.** Residuals remain best-effort backup cleanup observability, Wanxiang P4, Ice dynamic `dofile/loadfile`, Human-attested device identity, Quality and Product/ADR decisions. The reviewer did not run tests and did not accept ADR 0034 or Product Gate.

## P2/P3 Quality review — 2026-09-07 takeover

Reviewer: Carver, `01a07a02-1902-7562-b41f-2b91b6eccadd`; independent read-only review of `b90d236` plus the transaction delta.

Initial conclusion: **Fail.** The reviewer found one blocking fail-closed defect: `try? Data(contentsOf: receiptURL)` treated a present-but-unreadable resource receipt as if no receipt existed, which could authorize a clean-install overwrite of unknown live bytes. It also requested explicit real-archive assertions for all four rewritten Ice schemas, a combined known-recovery plus partial-overlay rollback test, and plan progress reconciliation.

Executor remediated all four points. Receipt absence is now distinguished from read failure before any runtime mutation; unreadable state throws `.fileOperationFailed`. The combined test restores the original pollution bytes and both prior receipts after overlay replacement fails partway through. The opt-in two-source/two-Lua archive test now rejects remaining `__include: default:/` and `import_preset: default` references in all four adapted schemas. The plan now distinguishes historical entry rules from completed P0–P3 work.

Two requested delta-review turns completed without returning any review text through the task interface. A second independent reviewer turn behaved the same way. Therefore the remediation has executor test evidence but **no retrievable independent Quality delta conclusion**; Quality remains pending and no Pass is claimed.

## P4 Quality review — 2026-09-07

Reviewer: independent Quality Reviewer（本会话）；冻结 tip `18f0d07b14f46c35ec95253e46051c2caa49024a`（含 P4 `e213a25`、transaction/receipt `a01dbd3`、CI `eed453d`/`afa0c0e`、Human-attested P4 device docs）。

全文：[`scheme-delivery-source-state-001-p4-quality-review.md`](scheme-delivery-source-state-001-p4-quality-review.md)。

**Verdict: Pass with conditions**（P0=0 · P1=0 · P2=1 · P3=4）。P4 活跃卸载在 lease 内等待 Luna 部署成功后再 stage→commit；失败保留原选择与文件，restore redeploy 同 lease await。Human-attested 仅绑定成功烟雾；失败回滚未真机测；非 Product Gate。

**Prior Quality pending（不可读 receipt）：已关闭。** 本审查在冻结 tip 上复核 `a01dbd3` 代码 + `testUnreadableReceiptObjectFailsBeforeUnknownRuntimeMutation` 等测试后，对该 residual 单独结论为 **Pass**。此前缺失的 delta-review 文本不再阻挡关闭。

未 Accept ADR 0034；未 merge / undraft PR #100；Wanxiang P4、Ice Lua `dofile`、Device-attested、Product Gate / TestFlight 仍开放。

## Limited P4 Product Gate — 2026-09-08

Human Product Owner limited / conditional gate: [`scheme-delivery-source-state-001-p4-product-gate-2026-09-08.md`](../evidence/scheme-delivery-source-state-001-p4-product-gate-2026-09-08.md).

**Grade:** **Limited Product Gate Passed (automation-backed failure rollback)**. Device failure-rollback untested; automation-backed (unit tests + Q-P2-01 / `0315908` + CI). Quality docs: `372ad8c` / `bf9de51`. Success path: [`p4-device`](../evidence/scheme-delivery-source-state-001-p4-device-2026-09-07.md).

Does **not** undraft/merge PR #100, Accept ADR 0034, close Wanxiang P4, authorize TestFlight/App Release, or upgrade to Device-attested / full Product Gate.
