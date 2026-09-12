# Product Decision: KOS-IMPROVEMENT-SUGGESTIONS-001 — 九项建议处置

## Current Status

| Field | Value |
|---|---|
| Status | Accepted — eight directions Adopted; KOS-SUG-04 Deferred |
| Decision | Adopt SUG-01/02/03/05/06/07/08/09 within the ledger's narrow boundaries; defer SUG-04 to its explicit observability trigger |
| Non-claims | No implementation, rule/template/CI/privacy/diagnostics/device/publication change, `required` enablement, or Active-Assignment migration |
| Next | New bounded implementation Assignment only when a specific adopted direction is selected for execution; reconsider SUG-04 only at its recorded trigger |

---

**Product Approver:** Human Product Owner / Product Lead

**Decision source / date:** Current session `2026-09-10 Asia/Shanghai`, “按照你的建议继续吧”

**Assignment:** [KOS-IMPROVEMENT-SUGGESTIONS-001](../assignments/kos-improvement-suggestions-001.md)
**Independent inputs:** [Architecture review](../reviews/KOS-IMPROVEMENT-SUGGESTIONS-001-architecture-review.md) and [Quality review](../reviews/KOS-IMPROVEMENT-SUGGESTIONS-001-quality-review.md)

The Human Product Owner accepts the recommended dispositions recorded in the
[decision ledger](../kos/kos-improvement-suggestions-scheme-delivery-2026-09-09-disposition-ledger.md):

| Disposition | IDs | Effective boundary |
|---|---|---|
| Adopted | KOS-SUG-01, 02, 03, 05, 06, 07, 08, 09 | Direction and applicability only; each item remains inactive until a new, bounded implementation Assignment supplies scope, migration, validation and matching authorization. |
| Deferred | KOS-SUG-04 | Reconsider only after SUG-07 preflight proves the required content-free fields are readable and a specific human-device claim still needs the diagnostic manifest. |

This Decision does not change KOS 2.0/2.1, activate a v0.8.0 contract globally,
approve a template or script change, or authorize an implementation, data read,
device action, commit, push, PR, merge, TestFlight, or Release. The original
proposal remains historical context; this Decision and the ledger are current
disposition sources.
