# Product Decision: SCHEME-LICENSE-DOWNLOAD-CTA-001 — Human Product Gate

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-SCHEME-LICENSE-DOWNLOAD-CTA-001-PRODUCT-GATE",
  "record_type": "decision",
  "title": "Accept the scheme license download CTA Product Gate with conditions",
  "status": "accepted",
  "updated_at": "2026-09-23T22:48:52+08:00",
  "revalidation_triggers": ["product_contract_changed", "candidate_identity_changed", "quality_receipt_changed", "human_observation_changed", "authority_revoked"],
  "parent_refs": ["SCHEME-LICENSE-DOWNLOAD-CTA-001", "PD-SCHEME-LICENSE-DOWNLOAD-CTA-001"],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "Current session: explicit verdict ‘Pass with conditions’ and confirmation ‘是的，全部接受’ for the four listed conditions",
    "scope": "Accept the bounded Product Gate for the first-download license CTA contract on the uncommitted candidate identified below; accept SLD-CTA-GATE-01 through SLD-CTA-GATE-04; close the parent and Product Gate Assignments.",
    "outcome": "Human Product Gate Pass with conditions; all four evidence conditions accepted; parent and Gate Assignments Closed; commit and publication remain unauthorized",
    "expires_at": null
  }
}
```

- **Decision ID:** `PD-SCHEME-LICENSE-DOWNLOAD-CTA-001-PRODUCT-GATE`
- **Status:** Accepted
- **Decision date:** `2026-09-23 Asia/Shanghai`
- **Parent Assignment:** [`SCHEME-LICENSE-DOWNLOAD-CTA-001`](../assignments/scheme-license-download-cta-001.md) — Closed
- **Gate Assignment:** [`SCHEME-LICENSE-DOWNLOAD-CTA-PRODUCT-GATE-001`](../assignments/scheme-license-download-cta-product-gate-001.md) — Closed
- **Authorization:** [`AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-PRODUCT-GATE-DECISION-001`](../authorizations/AUTH-SCHEME-LICENSE-DOWNLOAD-CTA-PRODUCT-GATE-DECISION-001.md)
- **Product Contract:** [`PD-SCHEME-LICENSE-DOWNLOAD-CTA-001`](SCHEME-LICENSE-DOWNLOAD-CTA-001-authorization.md)
- **Gate packet:** [`decision packet`](../evidence/scheme-license-download-cta-product-gate-packet-2026-09-23.md)

## Bound candidate and evidence

| Item | Bound identity / result |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-scheme-license-download-cta-001` |
| Branch / HEAD | `grok/scheme-license-download-cta-001` / `80091f35cc5411b292eca78662f39e2b91694045` |
| Candidate state | Uncommitted local worktree snapshot at Gate decision time |
| Independent Quality package | 22-file SHA-256 `4f097b709ef993b0c81eb879f8d093c99213ae766c8397582a67ff1ada5f9f3e` |
| Quality receipt | [`revalidation`](../reviews/scheme-license-download-cta-quality-revalidation-001.md), SHA-256 `04f7a8cd731096513fb0f9b8cd06a0432a79489cce8f204563aef01597445937`; **Pass with conditions** |
| Human observation | [`Simulator observation`](../evidence/scheme-license-download-cta-simulator-observation-2026-09-23.md), SHA-256 `3f0da5b886222673807fd8fb6f382834a250893bb1b01525434028a521b1cbc0`; Human-attested |

The decision accepts the product behavior for this candidate and the evidence at the grades and boundaries stated above. It does not certify a live network download or RIME deployment, and it does not upgrade the Human-attested Simulator observation to Device-attested. The Quality receipt applies to its exact pre-writeback 22-file package. Closing the parent Assignment changes that package member; the receipt is not a review of the resulting post-writeback documentation tree.

## Accepted evidence conditions

| ID | Condition | Human disposition | Boundary retained |
|---|---|---|---|
| `SLD-CTA-GATE-01` | No live network download or subsequent RIME deployment was exercised. | `accept` | Gate accepts the tested UI/effect-ordering contract only; no successful external download or deployment is claimed. |
| `SLD-CTA-GATE-02` | Human's three-entry Simulator observation has no named model/OS or installed payload identity. | `accept` | Observation remains Human-attested; it is not Device-attested or payload-bound. |
| `SLD-CTA-GATE-03` | Quality Debug run skipped 9 non-CTA tests: 6 fixture-dependent scheme-resource tests and 3 physical-device TD-012 tests. | `accept` | No CTA test was skipped; the skipped areas remain outside this Gate's proof. |
| `SLD-CTA-GATE-04` | Candidate is an uncommitted local worktree snapshot; publication readiness was not assessed. | `accept` | Gate applies only to the local snapshot; commit, push, PR, merge, TestFlight, and Release remain separately unauthorized. |

## Product outcome

Human Product Owner's decision is **Pass with conditions**, with all four evidence conditions explicitly accepted. This closes only the bounded first-download CTA Product Gate and its parent Assignment. The accepted conditions remain visible in the parent Assignment as non-blocking residuals.

No source or test file was changed while recording this decision. The lifecycle writeback changed the parent Assignment, which was a member of the pre-writeback Quality package; no claim is made that the post-writeback 22-file documentation package received another independent Quality review.
