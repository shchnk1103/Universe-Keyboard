# TYPO-CORRECTION-002 Simulator QA-001 Run Receipt — Revalidation 06

> **Run ID:** `TC2-SIM-20260920-223706-QA001-REVAL-06`
>
> **Status:** `inconclusive — actual composition contained one extra n`
>
> **Evidence grade:** `Executor-recorded` plus named Human observations

## Binding

- Authorization: [`QA-001 revalidation 005`](../authorizations/AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-005.md)
- Parent: [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md), still Active
- Installed package source: `3f9f2652b03279a99537639f4382b48bb58548ca`
- Simulator: iPhone 17 Pro Max / iOS 27.0 /
  `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Host: Messages, synthetic conversation `+1 (888) 555-1212`; message not sent
- RIME: `rime_ice`, artifact `rime-ice-20260630-675d23b0`,
  provenance receipt `67A0C52E-A975-47C8-9C09-4ADA1320DF87`

The live package hashes and provenance SHA were checked before capture and
matched the accepted deployment receipt. No rebuild, reinstall or schema
change occurred.

## Human input and observed UI

The requested phrase was `wimenjintianquhongyuan` (22 letters). The Human
initially reported that the phrase had been entered without a noticed mistouch
or deletion and that `我们今天去公园` was not visible.

The post-input UI snapshot instead shows
`winmenjintianquhongyuan` (23 letters), with one extra `n` after `wi`.
After seeing this evidence, the Human stated that an unnoticed accidental tap
may have occurred and requested a new attempt. Both statements are retained;
this receipt does not infer the exact cause of the extra input.

The target candidate was not selected. Interaction checks were not run.

## Content-free diagnostic reconciliation

The same keyboard-extension process
`5CC03041-4BAA-46A1-912C-77357E4FD052` remained active. Setup evidence is
sequences 1–16; the formal phrase segment is sequences 17–238 from
`2026-09-20T14:41:34Z` through `14:41:47Z`.

| Observation | Result |
|---|---|
| `touch.terminal` | 46 events, consistent with 23 taps |
| `rime.owner.published` / `ui.applied` | 23 / 23 |
| Final candidate visibility | 8 candidates visible, revision 26 |
| `typo_correction.sidecar_query` | 72 |
| Route / schema | `real_rime_sidecar` / `rime_ice` |
| Input lengths seen by sidecar | 8 through 23 |
| Result boundary | `returned`, 3 of limit 3 |
| Live session | valid and stable before/after each recorded query |
| Sidecar elapsed | 1–6 ms; internal observation only, not performance evidence |

The diagnostic count and UI composition independently agree that the formal
input had 23 characters. Because the tested composition differs from the
registered QA phrase, absence of the target candidate cannot decide QA-001.

## Preserved raw artifacts

Raw artifacts are retained outside Git:
`/private/tmp/typo-correction-002-sim-runs/TC2-SIM-20260920-223706-QA001-REVAL-06/raw/`

| File | SHA-256 |
|---|---|
| `keyboard_extension.jsonl` | `786dcfd02ca93a56b0caceb323fe829e5bbe3465ad2aefbffa3fb554aa359da9` |
| `qa001-screenshot.jpg` | `e51b55e2782c42d339dbbe9d85f6a233e06ce375786b64c1392c7e69684fc0e7` |
| `rime-runtime-provenance.json` | `771adec0e83414bf1e204c5b253c1b23d1cbe5fce5c93a8f223c7e5811e4d9a1` |

## Disposition

| Claim | Outcome |
|---|---|
| Designated package, Simulator and RIME provenance | bounded precondition pass |
| Real Universe Keyboard input and sidecar route observed | pass for this sub-claim |
| Exact registered phrase entered | fail for run validity; actual input differed |
| Target candidate visibility | not decided |
| Target candidate selection / interaction checks | not-run |
| `TC2-CASE-QA-001` | inconclusive; no QA pass or product-failure conclusion |

This Authorization is consumed and cannot be reused. A repeat requires a new
Authorization and Run ID. QA-001, INT-003, paired performance and all
Product/Quality/Release Gates remain open.
