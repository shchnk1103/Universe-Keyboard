# UK-005 — P-01 delivery/publication facts receipt

> **Receipt status:** `recorded`; delivery classification is `same-head`.
>
> This post-Hosted-CI revision supersedes the earlier pre-push snapshot preserved in
> Git history. It is an executor-recorded, content-free P-01 fact receipt for the
> frozen governance-document candidate. It records delivery provenance only. It is
> not a Product Gate, Quality Gate, Release Pass, current-proof, merge approval or
> external publication authorization.

## Receipt identity and scope

| Field | Value |
|---|---|
| Assignment | [`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P01-D01`](../assignments/kos-release-evidence-implementation-001-p01-d01.md) |
| Authorization | [`AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P01-D01`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P01-D01.md) |
| Receipt type | P-01 delivery/publication facts only |
| Observed at | `2026-09-16T21:15:38+08:00` Asia/Shanghai |
| Candidate branch | `codex/uk-005-p01-d01-facts` |
| Comparison baseline | `d5c53f2cbda85e16721b9eafae09a763f6a04471` |
| Frozen local candidate | commit `07b4a4346f178a770531dbfcb8f33373a896f223`; tree `421c313dea6082c5e5c4bb85e225b855224e7294` |
| Git boundary | Candidate `07b4a434…` was pushed to the named remote branch and covered by Hosted CI; no PR, merge, tag or Release was performed |

The frozen candidate is the ten-file governance-document commit identified above. This
receipt was generated after that freeze and is an evidence artifact, not a member of the
frozen candidate tree.

## Required P-01 facts

| Fact | Observed value |
|---|---|
| `local_candidate` | `07b4a4346f178a770531dbfcb8f33373a896f223` |
| `published_head` | `07b4a4346f178a770531dbfcb8f33373a896f223` — remote branch `codex/uk-005-p01-d01-facts`, as bound by Run [#490](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/35099850845) |
| `hosted_ci_head` | `07b4a4346f178a770531dbfcb8f33373a896f223` — Run [#490](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/35099850845) commit `07b4a43` |
| `hosted_ci_result` | `green` — Run [#490](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/35099850845) conclusion `success` |
| `coverage` | `same-head` — `local_candidate == published_head == hosted_ci_head` |
| `pr_state` | `none` |
| `local_ahead_of_published` | `0` for the frozen candidate; the local branch tip additionally contains the receipt-only commit `ab3f9b2…`, which is outside the candidate |

## Provenance observations

- The frozen candidate remains commit `07b4a4346f178a770531dbfcb8f33373a896f223` with tree `421c313dea6082c5e5c4bb85e225b855224e7294`.
- The local candidate classification was `docs_only`, `requires_full=false`, with ten
  changed paths in the lightweight allowlist.
- Hosted CI Run [#490](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/35099850845)
  was manually dispatched on the candidate branch with comparison base
  `d5c53f2cbda85e16721b9eafae09a763f6a04471`; `classify-change`, `lightweight-checks`
  and `final-quality-gate` succeeded, while `format-swift`, the three test jobs and
  `build-release` were skipped by the `docs_only` classification.
- No PR creation, merge, device operation, archive/export, signing, App Store Connect,
  TestFlight or external distribution was performed.

## Non-claims

- `coverage=same-head` records candidate/remote/Hosted-CI identity only; it is not a
  Product, Quality or Release approval.
- Build 55 public testing is not used as a substitute for this candidate's P-01 facts;
  TD-003, TD-004 and TD-005 remain `open`.
- This receipt does not authorize or conclude Product, Quality, Release, current-proof,
  merge, publication or external availability.
