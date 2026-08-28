# Evidence: Wanxiang CNB download and deploy success — 2026-08-28

**Assignments:** [`SCHEME-DELIVERY-JOURNAL-001`](../assignments/scheme-delivery-journal-001.md) · [`RIME-SCHEME-DELIVERY-INTEGRITY-001`](../assignments/rime-scheme-delivery-integrity-001.md)
**Evidence grade:** `Device-attested` (Human log paste after empty-file unzip fix)
**Collection date / timezone:** `2026-08-28 Asia/Shanghai`

## Observation

Human Product Owner reported physical-device download and deploy of 万象拼音 succeeded on the PR #83 build that includes `c87bec0` (empty stored zip entries extracted).

Operation `38b5a8d3-cd74-4322-869d-c4e4dbf2fa8d`, artifact `wanxiang_17_5_9_cnb9bfc_github73f8`, source `cnb` / `asset.cnb.cool`, attempt 1.

| Phase | Result |
|---|---|
| selecting | succeeded (`cnb`) |
| downloading | succeeded |
| verifying_archive_size | succeeded |
| verifying_archive_digest | succeeded |
| extracting | succeeded |
| post_processing | succeeded |
| verifying_staged_content | succeeded |
| installing | succeeded |
| deploying | succeeded |
| committing_receipt | succeeded |
| terminal | `completed` `installed=true` `deployed=true` |

No `integrity_failed` and no fallback. This is the same CNB identity that previously failed `staged_content` when empty `lua/data/chaifen.txt` was dropped.

## Non-claims

- Not GitHub-source evidence.
- Network/region not stated in this paste.
- Not Product Gate, merge, Release, or endpoint acceptable-use.
- Hosted full-path for the unzip-fix tip was still running when this evidence was recorded.
