# Product Decision: RIME-SYNC-001 UI-02 Residual Acceptance

## Decision

**Accepted — bounded residual disposition for the iOS V1 closure target only.**

The Human Product Owner accepts the following UI-02 residual risks for the
bounded iOS V1 scope. This accepts the residuals; it does not convert missing
checks into passing evidence or claim full accessibility conformance.

| Residual | Disposition | Boundary |
|---|---|---|
| Narrow-device layout was not tested against a defined target | `accept` | No narrow-device pass is claimed. Reopen if the supported-device baseline changes or a narrow-device defect is reported. |
| Physical-device observation is not bound to a frozen complete source manifest or on-device executable readback | `accept` | The iPhone 13 Pro / iOS 27.0 observation remains supplemental, limited to the reported VoiceOver and enlarged-text layout check on local Debug `1.0 (924)`. It is not reproducible source-bound evidence or a general accessibility pass. |

## Evidence and authority

- Supplemental device evidence: [UI-02 observation](../evidence/rime-sync-v1-ui02-device-accessibility-2026-09-24.md)
- Independent Quality conclusion: [fresh UI-02 review](../reviews/rime-sync-v1-ui02-device-accessibility-quality-review-2026-09-24.md) — `Pass with conditions`, limited to supplemental human observation.
- Parent Assignment: [RIME-SYNC-001](../assignments/rime-sync-001.md)
- Decision source: Human Product Owner instruction in the active task on
  `2026-09-24 Asia/Shanghai`: accepts both stated UI-02 residual risks and
  authorizes documenting that bounded disposition.

## Lifecycle and non-claims

This decision disposes only the two listed residuals. UI-02 is not marked as a
formal pass; the Quality verdict and its limitations remain unchanged. This
does not itself authorize the parent Assignment lifecycle transition, Product
Gate, commit, push, merge, TestFlight or Release. RIME-SYNC-001 remains
`Active` until the separate parent lifecycle decision and required close-time
reviews/handoff are complete.

Reopen this disposition if the supported-device baseline changes, new
accessibility evidence contradicts the observation, or a relevant UI defect is
reported.
