# Product Decision: RIME Ice deployment residuals

## Current Status

- Status: Accepted — bounded residual disposition.
- Authority: Human Product Owner / Product Lead.
- Decision source: Current task, 2026-09-20: “接手上述两个 residual，授权按照你的建议继续进行下一步”.
- Recorded at: 2026-09-20T22:34:52+08:00.
- Parent: [parent revalidation Assignment](../assignments/typo-correction-002-parent-revalidation-002.md), still Active.
- Authorization: [Product residual AUTH](../authorizations/AUTH-TYPO-CORRECTION-002-RIME-ICE-DEPLOYMENT-PRODUCT-RESIDUAL-001.md).

## Exact evidence binding

- Run: TC2-SIM-20260920-RIME-ICE-SMOKE-01.
- Installed package source: 3f9f2652b03279a99537639f4382b48bb58548ca; four package hashes remain owned by the [smoke receipt](../evidence/typo-correction-002-sim-run-2026-09-20-rime-ice-deployment-smoke-01.md).
- Documentation checkout HEAD: 0d6638fabdc6b3db8164b881464a9f96f16c8dce plus the existing bounded documentation changes.
- Environment: iPhone 17 Pro Max / iOS 27.0 Simulator, 06C5BC3E-7599-4761-A1A2-71DAEA991474.
- Review basis: [Architecture](../reviews/typo-correction-002-sim-run-2026-09-20-rime-ice-deployment-smoke-01-architecture-review.md) and [Quality](../reviews/typo-correction-002-sim-run-2026-09-20-rime-ice-deployment-smoke-01-quality-review.md), both bounded deployment-precondition Pass.

## Residual decisions

| Residual | Product disposition | Remaining evidence boundary |
|---|---|---|
| QR-01 / AR-01: downloaded archive not independently re-hashed | Accepted for this deployment precondition | The archive SHA is carried by the runtime receipt. The 70-file installed-content check supports deployed content identity; it does not establish a new independent archive hash verification. |
| QR-02: documentation HEAD differs from installed package source | Accepted with exact package binding | Reuse only the package identity recorded by the smoke receipt. Do not claim current HEAD was rebuilt or installed. Rebuild/reinstall or package mismatch requires fresh identity and Run ID. |

Acceptance records the Human Product Owner's decision; it does not repair missing measurements or upgrade the evidence grade. Quality's review was cross-document reconciliation, not an independent reread of live artifacts.

## Next action and handoff

Input Intelligence Maintainer owns the next QA-001 preparation, with Quality,
Performance & Release Maintainer as environment executor and the Human Product
Owner as manual device operator under the parent Assignment.

Prioritize one fresh QA-001 attempt on the deployed package before paired
performance. Establish a fresh QA-001 Authorization and Run ID, verify package
and provenance identity, then establish Messages, Universe Keyboard, Full
Access, diagnostic readability and an empty composition before input. Pause
for human keyboard selection when it cannot be established reliably. Human
typing has no 180 ms requirement for QA-001.

Preserve old QA-001 inconclusive receipts. If the target candidate is absent,
record that observation and stop the selection step. Do not repeatedly ask
for faster typing. INT-003 and paired performance retain their own evidence
requirements and run identities.

## Limits and revalidation

This docs-only decision closes the Product disposition of QR-01/QR-02 for the
named setup run only. Parent remains Active; QA-001, INT-003, paired performance
and Product/Quality/Release Gates remain open. No capture is performed by this
decision. No publication or merge is authorized.

Revalidate on package/schema/provenance change, contradictory evidence,
expanded scope, or any request to claim an independently verified archive or
current-HEAD build. No new ADR or CHANGELOG update is required: runtime,
architecture and product contracts are unchanged.
