# SCHEME-LICENSE-DOWNLOAD-CTA-001 — Product Gate packet 002

**Gate Assignment:** [`SCHEME-LICENSE-DOWNLOAD-CTA-PRODUCT-GATE-002`](../assignments/scheme-license-download-cta-product-gate-002.md)\
**Decision:** Human Product Owner accepted the four listed evidence boundaries in the current session; recorded outcome is **Pass with conditions**.\
**Product Contract:** [`PD-SCHEME-LICENSE-DOWNLOAD-CTA-001`](../product-decisions/SCHEME-LICENSE-DOWNLOAD-CTA-001-authorization.md)

This packet binds the new Product Gate decision to the post-rebase candidate. It does not replace or edit the earlier Gate record, which remains bound to its original uncommitted candidate.

## Bound candidate

| Item | Identity |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-scheme-license-download-cta-001` |
| Branch / HEAD | `grok/scheme-license-download-cta-001` / `d614b8e03006ff305137754ac118e50445938068` |
| Parent / `origin/main` | `a9b82a58cac0c28e8a5d8a957d464d803d6d92d1` |
| Candidate state | Local commit, one commit ahead of `origin/main`; not pushed; no PR |
| Quality package | 22-file manifest SHA-256 `6146c454c0f0305f0f6055bbe141db8e1473fc6c99657c525f11bb3b3ef6fe39` |

## Contract considered

1. Each first-download entry presents **「查看许可并下载」** and opens the existing license sheet.
2. **「同意并下载」** accepts the license before invoking download; dismissing the sheet does not start a download.
3. Settings detail, activation guide, and nine-key installation share the copy and flow.
4. Installed-management actions and retry behavior remain outside this first-download CTA change.

## Evidence

| Evidence | Result / grade | Boundary |
|---|---|---|
| Fresh independent Quality revalidation 002 | **Pass（有界）**; exact 22-file package above; strict lint on 9 Swift files passed; App + Keyboard Debug `394 passed / 9 skipped / 0 failed`; all five CTA flow cases passed | Receipt [`scheme-license-download-cta-quality-revalidation-002.md`](../reviews/scheme-license-download-cta-quality-revalidation-002.md), SHA-256 `2c263ca6017d2ba355a8a13c3592ff254469a6793a76197b6c16db3b26373ee5`. No XCUITest, manual UI, live download, RIME deployment, publication, or Release claim. |
| Human Simulator observation | Human reported: 「三个首次下载入口都没有问题」 | Human-attested only. Exact taps/outcomes, Simulator model/OS, and installed payload identity were not recorded. [`Observation`](scheme-license-download-cta-simulator-observation-2026-09-23.md), SHA-256 `cc3271fbea9ec76a7b68c26ec219bd4fc3328fc40c7f29f4756f7b352d53a5b9`. |
| Product contract/code-path assessment | The independent receipt reviewed the three routes, shared CTA, and accept-before-download effect ordering | Does not prove successful external download or deployment. |

## Accepted conditions

The Human Product Owner accepted all four evidence boundaries for this exact candidate:

| ID | Condition | Disposition | Boundary retained |
|---|---|---|---|
| `SLD-CTA-GATE-01` | No live network download or subsequent RIME deployment was exercised. | `accept` | Gate accepts the bounded UI and effect-ordering contract; no successful external download or deployment is claimed. |
| `SLD-CTA-GATE-02` | The Simulator observation is not bound to a named model/OS or installed executable payload. | `accept` | It remains Human-attested; it is not Device-attested or payload-bound. |
| `SLD-CTA-GATE-03` | The Debug run skipped 9 non-CTA cases: 6 fixture-dependent scheme-resource tests and 3 physical-device TD-012 tests. | `accept` | No CTA test was skipped; skipped areas remain outside this Gate's proof. |
| `SLD-CTA-GATE-04` | Candidate is a local commit, one commit ahead of `origin/main`; publication readiness was not assessed. | `accept` | Candidate remains unpublished. This Gate does not authorize commit, push, PR, merge, TestFlight, or Release. |

## Decision boundary

The recorded outcome is **Human Product Gate Pass with conditions** for commit `d614b8e03006ff305137754ac118e50445938068`, with all four conditions accepted at the evidence grades above. This is not a Quality verdict, publication Authorization, merge decision, Device-attested result, or Release Gate.
