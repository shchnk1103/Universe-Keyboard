# Product Decision: ADR-0035-ACCEPT — 正式采纳发布证据增量与候选晋级

**Decision ID:** `PD-ADR-0035-ACCEPT`
**Lifecycle status:** `Recorded — Human Product Owner Accept 2026-09-15; ADR 0035 Status Accepted (Conditional package)`
**Date / timezone:** `2026-09-15 Asia/Shanghai`
**Architecture target:** [`ADR 0035`](../architecture/decisions/0035-release-evidence-accumulation-and-promotion.md)
**Parent / related:** [`RELEASE-EVIDENCE-PROMOTION-001`](../assignments/release-evidence-promotion-001.md) · [`REP-Q-01 receipt`](../evidence/release-evidence-promotion-001-rep-q-01-provenance-2026-09-15.md)

## Authority

- **Product Approver / Decision maker:** Human Product Owner / Product Lead
- **Decision source / date:** In-session direction, 2026-09-15 Asia/Shanghai — **“正式采纳吧”**
- **Architecture basis:** Independent Architecture re-review — **Accept** within the remediation scope
- **Quality basis:** Independent Quality re-review — **Conditional Accept** limited to local engineering implementation and evidence contract
- **Does not transfer:** Product Gate, Quality Pass, Release Pass, device acceptance, signing, App Store Connect, TestFlight, merge or branch-cleanup authority

## Bound Product Decision

Human Product Owner formally **accepts ADR 0035** as a **binding architecture decision with the existing Conditional Accept boundaries**:

1. Ordinary low-risk changes may use delta evidence; keyboard, RIME, lifecycle, performance/crash, permission, App Group, toolchain and artifact boundaries trigger the corresponding validation scope.
2. Daily Beta evidence may support a formal external candidate only after the five-field artifact identity, behavior contract, validation profile, candidate binding, device/OS context, evidence contract and freshness are all compatible. Otherwise the record remains comparator, none or pending.
3. Main App Diagnostics remains the local, content-free evidence surface. Release-evidence storage remains Main-App-owned, bounded, atomic and isolated from diagnostic JSONL clearing.
4. Existing CI classification and full quality gates remain independent. A release profile of `delta` never waives CI, signing, device, external or Release checks.
5. The bounded implementation candidate and its provenance are recorded in [`REP-Q-01 receipt`](../evidence/release-evidence-promotion-001-rep-q-01-provenance-2026-09-15.md); adoption of the ADR does not retroactively promote any missing evidence to a pass.

## Explicit non-authorization

This Decision does **not** authorize:

- Product Gate, independent Quality Pass, Release Pass or formal App Release;
- real-device operation, signed archive/export, dSYM/UUID verification or external-only checks;
- App Store Connect upload/processing, TestFlight groups, public links or Beta Review;
- merge, branch cleanup, credentials, network upload or a change to CI required checks;
- changing KOS 2.0/2.1 frozen rules or turning KOS 2.2 advisory contracts into `required`.

## Executor follow-through

| Action | Authorized? |
|---|---|
| Flip ADR 0035 Status → **Accepted** with the Conditional Accept package wording | **Yes** |
| Record this Product Decision and acceptance evidence; synchronize Assignment and status mirrors | **Yes** |
| Treat ADR 0035 as the architecture source for future release-evidence work within this contract | **Yes** |
| Treat the local evidence page or promotion result as Product/Quality/Release approval | **No** |
| Merge, release, upload, distribute or close a separate external/device Assignment | **No** |

## Pointers

- Acceptance evidence: [`../evidence/adr-0035-accept-2026-09-15.md`](../evidence/adr-0035-accept-2026-09-15.md)
- Implementation Product Decision: [`RELEASE-EVIDENCE-PROMOTION-001`](RELEASE-EVIDENCE-PROMOTION-001-authorization.md)
- Authorization receipt: [`AUTH-RELEASE-EVIDENCE-PROMOTION-001`](../authorizations/AUTH-RELEASE-EVIDENCE-PROMOTION-001.md)
- Independent reviews: [`Architecture re-review`](../reviews/release-evidence-promotion-001-architecture-rereview.md) · [`Quality re-review`](../reviews/release-evidence-promotion-001-quality-rereview.md)
