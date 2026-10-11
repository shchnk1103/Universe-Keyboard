# TYPO-CORRECTION-002 Simulator QA-001 Run Receipt — Revalidation 07

> **Run ID:** `TC2-SIM-20260920-224421-QA001-REVAL-07`
>
> **Status:** `inconclusive — exact input observed; target candidate not observed`
>
> **Evidence grade:** `Executor-recorded` plus Human candidate observation; independent Architecture **bounded Pass** (evidence boundary) and Quality **Bounded Pass with conditions** (evidence completeness); `TC2-CASE-QA-001` remains inconclusive

## Binding

- Authorization: [`QA-001 revalidation 006`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-006.md)
- Parent: [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md), Active
- Case: `TC2-CASE-QA-001` / `TC2-CTR-QA-001`
- Installed package source: `3f9f2652b03279a99537639f4382b48bb58548ca`
- Simulator: iPhone 17 Pro Max / iOS 27.0 /
  `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Host: Messages, synthetic conversation `+1 (888) 555-1212`; message not sent
- RIME: `rime_ice`, artifact `rime-ice-20260630-675d23b0`,
  provenance receipt `67A0C52E-A975-47C8-9C09-4ADA1320DF87`

The live package hashes and provenance were verified before the two QA
attempts and remained bound to the accepted deployment receipt. No rebuild,
reinstall, process change or schema change occurred between reset and this
capture.

## Reset and exact input

The previous composition was cleared under the same keyboard process.
Journal sequence 301 reports zero candidates and sequence 302 reports zero
visible candidates with the candidate bar hidden. Sequence 303 is the final
reset touch event. This Run's formal segment begins at sequence 304.

The Human then entered `wimenjintianquhongyuan` at normal speed without
Space, deletion, candidate selection or Send and reported that the input field
matched exactly. The post-input Messages snapshot independently shows the same
22-letter composition.

The Human reported that `我们今天去公园` was not present in the visible
candidate bar. The screenshot corroborates an active candidate bar but is not
used to infer candidate identity beyond what is legible; the named target
observation remains Human-attested. No candidate was selected and no
post-selection interaction check was run.

## Content-free diagnostic reconciliation

The formal segment is sequences 304–516 from
`2026-09-20T14:47:14Z` through `14:47:27Z` in keyboard process
`5CC03041-4BAA-46A1-912C-77357E4FD052`.

| Observation | Result |
|---|---|
| `touch.terminal` | 44 events, consistent with 22 taps |
| `rime.owner.published` / `ui.applied` | 22 / 22 |
| Final candidate visibility | 8 candidates visible, revision 94 |
| `typo_correction.sidecar_query` | 70 |
| Route / schema | `real_rime_sidecar` / `rime_ice` |
| Input lengths seen by sidecar | 8 through 22 |
| Result boundary | `returned`, 3 of limit 3 |
| Provenance receipt | `67A0C52E-A975-47C8-9C09-4ADA1320DF87` |
| Live session | valid and stable before/after every recorded query |
| Sidecar elapsed | 1–3 ms; internal observation only, not performance evidence |

The UI composition, 22 owner/UI updates, 44 touch terminals and maximum
sidecar input length 22 form a consistent exact-input boundary. Diagnostics
remain content-free and do not record candidate text.

## Preserved raw artifacts

Raw artifacts are retained outside Git:
`/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260920-224421-QA001-REVAL-07/raw/`

| File | SHA-256 |
|---|---|
| `keyboard_extension.jsonl` | `3a9e85a3f6c32cb49a74d9a610c6e72ada56c8ba258c231e0229a3882f1394b0` |
| `qa001-screenshot.jpg` | `019925d642b89bee659a332ece3d936ab1930a7915d7120c3206fe2abb340229` |
| `rime-runtime-provenance.json` | `771adec0e83414bf1e204c5b253c1b23d1cbe5fce5c93a8f223c7e5811e4d9a1` |

## Claim disposition

| Claim | Outcome |
|---|---|
| Designated package, Simulator and `rime_ice` provenance | pass for environment sub-claim |
| Exact registered 22-letter phrase entered | pass |
| Real sidecar route and candidate UI active | pass for bounded route/visibility sub-claims |
| Target candidate visible | not observed by Human operator |
| Target selected | not-run because target was absent |
| Interaction regression checks | not-run because selection precondition was unmet |
| `TC2-CASE-QA-001` | inconclusive; requested recovery was not established |

This receipt does not turn the absent target into a general product-failure
claim and does not diagnose why the target was absent. Independent reviews:

- [`Architecture review`](../reviews/typo-correction-002-sim-run-2026-09-20-qa001-reval-07-architecture-review.md) — bounded Pass for the evidence boundary
- [`Quality review`](../reviews/typo-correction-002-sim-run-2026-09-20-qa001-reval-07-quality-review.md) — Bounded Pass with conditions for evidence completeness

QA-001, INT-003, paired performance and all Product/Quality/Release Gates
remain open. Product residual disposition is recorded as
[`PD-TYPO-CORRECTION-002-QA001-REVALIDATION-07-RESIDUAL`](../product-decisions/TYPO-CORRECTION-002-QA001-REVALIDATION-07-PRODUCT-RESIDUAL.md):
the Human-attested absent target and UNKNOWN reason are accepted; a
same-package retry is not authorized.

Any later attempt requires a new Authorization and Run ID.
