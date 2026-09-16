# UK-005 — P-01 delivery/publication facts receipt

> **Receipt status:** `recorded`; delivery classification is `unknown`.
>
> This is an executor-recorded, content-free P-01 fact receipt for the frozen
> governance-document candidate. It records delivery provenance only. It is not a
> Product Gate, Quality Gate, Release Pass, current-proof, merge approval or external
> publication authorization.

## Receipt identity and scope

| Field | Value |
|---|---|
| Assignment | [`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P01-D01`](../assignments/kos-release-evidence-implementation-001-p01-d01.md) |
| Authorization | [`AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P01-D01`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P01-D01.md) |
| Receipt type | P-01 delivery/publication facts only |
| Observed at | `2026-09-16T20:35:38+08:00` Asia/Shanghai |
| Candidate branch | `codex/uk-005-p01-d01-facts` |
| Comparison baseline | `d5c53f2cbda85e16721b9eafae09a763f6a04471` |
| Frozen local candidate | commit `07b4a4346f178a770531dbfcb8f33373a896f223`; tree `421c313dea6082c5e5c4bb85e225b855224e7294` |
| Git boundary | Local commit was authorized and performed; push, PR, merge, tag and Release were not performed |

The frozen candidate is the ten-file governance-document commit identified above. This
receipt was generated after that freeze and is an evidence artifact, not a member of the
frozen candidate tree.

## Required P-01 facts

| Fact | Observed value |
|---|---|
| `local_candidate` | `07b4a4346f178a770531dbfcb8f33373a896f223` |
| `published_head` | `none` — read-only `git ls-remote --heads origin codex/uk-005-p01-d01-facts` returned no ref |
| `hosted_ci_head` | `unknown` — no Hosted CI run was created for this unpushed commit |
| `hosted_ci_result` | `unknown` (`not-run`) |
| `coverage` | `unknown` — one required head is `none` and another is `unknown` |
| `pr_state` | `none` |
| `local_ahead_of_published` | `unknown` — no published branch exists to compare |

## Provenance observations

- Before receipt generation, the candidate worktree was clean at `07b4a434…`.
- The local candidate classification was `docs_only`, `requires_full=false`, with ten
  changed paths in the lightweight allowlist.
- No remote mutation, Hosted CI dispatch, PR creation, device operation, archive/export,
  signing, App Store Connect, TestFlight or external distribution was performed.

## Non-claims

- `coverage=unknown` is not a same-head pass and does not establish hosted provenance.
- Build 55 public testing is not used as a substitute for this candidate's P-01 facts;
  TD-003, TD-004 and TD-005 remain `open`.
- This receipt does not authorize or conclude Product, Quality, Release, current-proof,
  merge, publication or external availability.
