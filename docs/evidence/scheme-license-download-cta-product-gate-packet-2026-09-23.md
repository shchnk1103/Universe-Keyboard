# SCHEME-LICENSE-DOWNLOAD-CTA-001 — Product Gate decision packet

**Gate Assignment:** [`SCHEME-LICENSE-DOWNLOAD-CTA-PRODUCT-GATE-001`](../assignments/scheme-license-download-cta-product-gate-001.md)\
**Status:** `Pending Human Product Owner decision`\
**Product Contract:** [`PD-SCHEME-LICENSE-DOWNLOAD-CTA-001`](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-authorization.md)

This packet organizes the current evidence for the Human Product Owner. It is not a Product Decision and does not record a Gate outcome.

## Bound candidate

| Item | Identity |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-scheme-license-download-cta-001` |
| Branch / HEAD | `grok/scheme-license-download-cta-001` / `80091f35cc5411b292eca78662f39e2b91694045` |
| Candidate state | Uncommitted worktree snapshot |
| Quality package | 22-file SHA-256 `4f097b709ef993b0c81eb879f8d093c99213ae766c8397582a67ff1ada5f9f3e` |

The Product Gate may consider only this bounded candidate and its linked evidence. No commit or publication is implied.

## Contract acceptance question

Does the Human Product Owner accept the implementation for the locked first-download CTA contract?

1. Each first-download entry offers one **「查看许可并下载」** action and opens the existing license sheet.
2. The sheet's **「同意并下载」** action accepts the license before invoking the download; dismissing the sheet does not initiate download.
3. Settings detail, activation guide, and nine-key installation use the shared copy/flow.
4. Already-installed management actions and retry behavior remain outside this first-download CTA change.

## Evidence available

| Evidence | Result / grade | Boundary |
|---|---|---|
| Independent exact-package Quality | **Pass with conditions**; strict lint passed; App + Keyboard Debug passed (`UniverseKeyboardTests` 379 passed / 9 skipped; `KeyboardTests` 15 passed) | Bound to the 22-file package above. Five CTA flow tests passed. No CTA test was skipped. Six fixture-dependent scheme-resource tests and three physical-device TD-012 tests were skipped. Receipt: [`Quality revalidation`](../reviews/scheme-license-download-cta-quality-revalidation-001.md). |
| Human Simulator observation | Human Product Owner reported: 「三个首次下载入口都没有问题」 | Human-attested only. Exact taps/outcomes were not itemized; Simulator model/OS and installed payload identity were not reported/captured. Record: [`observation`](scheme-license-download-cta-simulator-observation-2026-09-23.md). |
| Source/test contract review | Existing receipt found the three production routes use the tested shared flow and preserve acceptance-before-download ordering | Code-path/test evidence only; not proof of live network completion or real RIME deployment. |

## Open evidence conditions requiring Product disposition

| ID | Condition | Available choice |
|---|---|---|
| `SLD-CTA-GATE-01` | No live network download or subsequent RIME deployment was exercised. Tests verify route/effect ordering, not successful external download/deployment. | `accept` for this bounded UI/flow Gate; or `require evidence` before a verdict. |
| `SLD-CTA-GATE-02` | The Simulator observation is not bound to a named model/OS or installed executable; it cannot be upgraded to Device-attested. | `accept` the Human-attested entry-point observation at this grade; or `require a new scoped Simulator/device evidence task`. |
| `SLD-CTA-GATE-03` | The independent Debug run skipped 9 non-CTA cases (6 fixture-dependent resource tests; 3 physical-device TD-012 tests). | `accept` because no CTA test was skipped; or `require additional evidence` if those areas are prerequisites for this Product decision. |
| `SLD-CTA-GATE-04` | Candidate is an uncommitted worktree snapshot; no merge/publication readiness was assessed. | `accept` a Gate on this local candidate only; any commit/push/PR/merge remains separately authorized. |

No condition is pre-accepted. `accept` means only a Product disposition for this bounded Gate and does not upgrade evidence grade or authorize publication.

## Human decision required

Choose one:

- **Pass with conditions:** explicitly `accept` each Gate condition above, optionally with a named owner or follow-up; no other behavior is implied.
- **Needs work / defer:** identify the condition(s) that require evidence or remediation; the Gate remains open pending a new scoped Assignment/Authorization.
- **Reject:** state which locked Product Contract behavior is unacceptable.

No verdict, residual acceptance, parent Assignment Close, or publication action is recorded until the Human Product Owner explicitly decides. Decision writeback and any lifecycle change require a matching authorization.
