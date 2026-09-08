# SCHEME-DELIVERY-SOURCE-STATE-001 — Limited P4 Product Gate — 2026-09-08

**Assignment:** [`SCHEME-DELIVERY-SOURCE-STATE-001`](../assignments/scheme-delivery-source-state-001.md)
**Decision / grade:** **Limited Product Gate Passed (automation-backed failure rollback)**
**Not:** full Product Gate Passed · **Not** Device-attested
**Date / timezone:** `2026-09-08 Asia/Shanghai`
**Authority:** Human Product Owner (in-session reply)
**PR:** [#100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) (remains draft)
**Branch / checkout:** `codex/scheme-delivery-fix` · `/private/tmp/uk-scheme-delivery-fix`
**Recorder:** Grok executor (docs-only)

This file records a **limited / conditional** Human Product Gate for the P4 active-uninstall slice. It does **not** undraft, merge, Accept ADR 0034, close Wanxiang P4, authorize TestFlight / App Release, or upgrade evidence grade to Device-attested.

## Exact Human authorization

Human Product Owner reply (`2026-09-08 Asia/Shanghai`):

> 有限 Product Gate：接受自动化覆盖失败回滚，仍不合

Bound meaning recorded here:

| Element | Recorded interpretation |
|---|---|
| Gate kind | **Limited / conditional** Product Gate for this P4 slice |
| Accepted residual | Device **failure-rollback was NOT tested**; Human accepts that residual risk for this slice |
| Risk coverage relied on | **Automation only** — unit tests + Q-P2-01 mid-move injection + CI |
| Success path | Already **Human-attested** (Luna-first uninstall, input works, Settings shows Ice `未安装`) |
| Merge / release | **Explicitly not authorized** |

## Scope of this limited gate

In scope (accepted for this slice under the limited grade):

- Human-attested **success-path** active Ice uninstall already recorded in [`p4-device`](scheme-delivery-source-state-001-p4-device-2026-09-07.md).
- Engineering fail-closed contract for active uninstall (lease → Luna deploy await → stage → commit; failure keeps original selection/files).
- Independent Quality **Pass with conditions** on freeze `18f0d07` / `372ad8c`, plus Q-P2-01 **Closed** on freeze `0315908` with delta docs `bf9de51`.
- Human acceptance that **device failure-rollback** remains untested and is covered for this slice by automation evidence only.

Out of scope / **explicitly NOT authorized** by this reply:

- Undraft PR #100
- Merge PR #100
- TestFlight upload
- App Release
- ADR 0034 → Accepted
- Wanxiang P4 upgrade/uninstall closure
- Device-attested upgrade of evidence grade
- Assignment Closed / full Product Gate Passed

## Linked inputs

| Input | Path / identity | Role in this gate |
|---|---|---|
| Human-attested P4 device success smoke | [`scheme-delivery-source-state-001-p4-device-2026-09-07.md`](scheme-delivery-source-state-001-p4-device-2026-09-07.md) | Success path only; failure rollback explicitly untested |
| P4 Independent Quality | [`scheme-delivery-source-state-001-p4-quality-review.md`](../reviews/scheme-delivery-source-state-001-p4-quality-review.md) · commit `372ad8c` · freeze `18f0d07` | **Pass with conditions**; notes device failure rollback untested |
| Q-P2-01 remediation | commit `0315908` — mid-stage uninstall `moveItem` failure injection | Automation evidence for staging mid-failure restore |
| Q-P2-01 Independent Quality delta | [`scheme-delivery-source-state-001-p4-quality-rereview-qp201.md`](../reviews/scheme-delivery-source-state-001-p4-quality-rereview-qp201.md) · commit `bf9de51` | **Q-P2-01 Closed** (P2 residual 0 for that finding) |
| Review index | [`scheme-delivery-source-state-001.md`](../reviews/scheme-delivery-source-state-001.md) | Continuity pointer |
| PR | [#100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) | Remains draft; not undrafted by this gate |

## Accepted risks (explicit)

1. **Device failure-rollback untested.** Luna deploy failure, staging failure, and commit failure paths that should keep the original scheme selection/files were **not** exercised on a physical device.
2. For this limited gate, Human accepts that residual and relies on:
   - existing unit coverage of active success / Luna deploy failure / staging failure / non-active uninstall;
   - Q-P2-01 mid-move injection (`testIceUninstallStagingMidMoveFailureRestoresOwnedFiles` at `0315908`);
   - recorded CI green narrative on the reviewed freezes.
3. Human-attested success smoke remains **Human-attested ONLY** (no App/Extension UUID·SHA, no journal paste). This gate does **not** upgrade that grade.

## Non-claims

- **Not** full Product Gate Passed.
- **Not** Device-attested.
- **Not** ADR 0034 Accepted.
- **Not** merge / undraft / TestFlight / App Release authorization.
- **Not** Wanxiang P4 closure.
- **Not** Assignment Closed.
- **Not** proof that live App Group file removal or journal phases were audited beyond Settings `未安装` + Human report.
- Does **not** waive future revalidation if implementation, pin, environment, or scope changes.

## Grade language (canonical)

Use exactly:

> **Limited Product Gate Passed (automation-backed failure rollback)**

Do **not** paraphrase as “Product Gate Passed”, “full Product Gate”, or “Device-attested Product Gate”.

## Next (still open; separate Human authorization required)

- Wanxiang P4 upgrade/uninstall contract
- Any undraft / merge of PR #100
- TestFlight / App Release
- ADR 0034 Accept decision
- Optional Device-attested re-run (success and/or failure-rollback) if evidence grade must rise
