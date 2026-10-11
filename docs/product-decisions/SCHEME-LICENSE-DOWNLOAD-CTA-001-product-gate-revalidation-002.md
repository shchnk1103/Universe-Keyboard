# Product Decision: SCHEME-LICENSE-DOWNLOAD-CTA-001 — post-rebase Product Gate 002

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-SCHEME-LICENSE-DOWNLOAD-CTA-001-PRODUCT-GATE-REVALIDATION-002",
  "record_type": "decision",
  "title": "Accept the post-rebase scheme license download CTA Product Gate with conditions",
  "status": "accepted",
  "updated_at": "2026-09-24T07:42:54+08:00",
  "revalidation_triggers": ["product_contract_changed", "candidate_identity_changed", "quality_receipt_changed", "human_observation_changed", "authority_revoked"],
  "parent_refs": ["SCHEME-LICENSE-DOWNLOAD-CTA-001", "PD-SCHEME-LICENSE-DOWNLOAD-CTA-001"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "Current session: Human accepted the four current-candidate evidence boundaries and said to continue under KOS",
    "scope": "Accept the bounded first-download license CTA Product Gate for exact HEAD d614b8e03006ff305137754ac118e50445938068; accept SLD-CTA-GATE-01 through SLD-CTA-GATE-04 at the evidence grades stated below; close Product Gate Assignment 002. This decision applies to the post-rebase commit and does not amend the earlier candidate-bound Product Gate record.",
    "outcome": "Human Product Gate Pass with conditions; all four current-candidate evidence conditions accepted; Product Gate Assignment 002 Closed; publication remains separately unauthorized",
    "expires_at": null
  }
}
```

- **Decision ID:** `PD-SCHEME-LICENSE-DOWNLOAD-CTA-001-PRODUCT-GATE-REVALIDATION-002`
- **Status:** Accepted — **Pass with conditions**
- **Decision date:** `2026-09-24 Asia/Shanghai`
- **Gate Assignment:** [`SCHEME-LICENSE-DOWNLOAD-CTA-PRODUCT-GATE-002`](../assignments/scheme-license-download-cta-product-gate-002.md) — Closed
- **Authorization:** [`AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-PRODUCT-GATE-002`](../authorizations/AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-PRODUCT-GATE-002.md) — consumed
- **Product Contract:** [`PD-SCHEME-LICENSE-DOWNLOAD-CTA-001`](SCHEME-LICENSE-DOWNLOAD-CTA-001-authorization.md)
- **Decision packet:** [`packet 002`](../evidence/scheme-license-download-cta-product-gate-packet-2026-09-24.md), SHA-256 `316ce3c9429011539b3eac567420282c1cd1974919a700377ee3c105d37e9848`

## Bound candidate and evidence

| Item | Bound identity / result |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-scheme-license-download-cta-001` |
| Branch / HEAD | `grok/scheme-license-download-cta-001` / `d614b8e03006ff305137754ac118e50445938068` |
| Parent / `origin/main` | `a9b82a58cac0c28e8a5d8a957d464d803d6d92d1` |
| Candidate state | Local commit, one commit ahead of `origin/main`; not pushed; no PR |
| Independent Quality package | 22-file manifest SHA-256 `6146c454c0f0305f0f6055bbe141db8e1473fc6c99657c525f11bb3b3ef6fe39` |
| Quality receipt | [`Quality revalidation 002`](../reviews/scheme-license-download-cta-quality-revalidation-002.md), SHA-256 `2c263ca6017d2ba355a8a13c3592ff254469a6793a76197b6c16db3b26373ee5`; **Pass（有界）** |
| Human observation | [`Simulator observation`](../evidence/scheme-license-download-cta-simulator-observation-2026-09-23.md), SHA-256 `cc3271fbea9ec76a7b68c26ec219bd4fc3328fc40c7f29f4756f7b352d53a5b9`; Human-attested only |

This decision is exact-candidate-bound. The Quality conclusion is limited to its 22-file package; status writeback files are outside that package. The Human Simulator observation remains at its recorded grade and is not upgraded to Device-attested.

## Accepted evidence conditions

| ID | Condition | Human disposition | Boundary retained |
|---|---|---|---|
| `SLD-CTA-GATE-01` | No live network download or subsequent RIME deployment was exercised. | `accept` | Gate accepts only the bounded UI and effect-ordering contract; no successful external download or deployment is claimed. |
| `SLD-CTA-GATE-02` | The Human Simulator observation is not bound to a named model/OS or installed executable payload. | `accept` | Observation remains Human-attested; it is not Device-attested or payload-bound. |
| `SLD-CTA-GATE-03` | Quality Debug skipped 9 non-CTA tests: 6 fixture-dependent scheme-resource tests and 3 physical-device TD-012 tests. | `accept` | No CTA test was skipped; skipped areas remain outside this Gate's proof. |
| `SLD-CTA-GATE-04` | Candidate is a local commit, one commit ahead of `origin/main`; publication readiness was not assessed. | `accept` | Candidate remains unpublished. Commit, push, PR, merge, TestFlight, and Release require separate authorization; this decision grants none. |

## Product outcome and limits

Human Product Owner's decision is **Pass with conditions**, with all four evidence conditions explicitly accepted for this candidate. This is a Product Gate decision, not a new Quality verdict, publication authorization, merge decision, Device-attested result, or Release Gate.

The earlier [`Product Gate 001`](SCHEME-LICENSE-DOWNLOAD-CTA-001-product-gate.md) remains a historical decision bound to its original uncommitted snapshot. This record supplies the new decision for `d614b8e`; it does not rewrite that history or alter the closed implementation Assignment.

## Writeback validation

- Verified branch, HEAD, parent, current `origin/main`, Quality receipt hash, observation hash, and packet hash against the bindings above.
- No source, test, project, workflow, or any of the 22 Quality package member files changed.
- Markdown links, KOS JSON records, and `git diff --check` were validated after the final status synchronization.
- No app tests, Simulator operation, commit, push, or PR were performed as part of this documentation-only decision writeback.
