# RIME-SYNC-001 publication Quality review — 2026-09-27

## Decision

**Pass with conditions.** The independent Quality lane covered Q1–Q6 for the
bounded iOS V1 local-folder publication candidate. The final Q5 freshness
check closed finding `QR-RIME-SYNC-PUB-20260926-Q5-01` (P1, Quality & Release
Maintainer) with disposition `fix` — resolved. This is a pre-publication
Quality conclusion only; it is not merge, TestFlight, Product Gate or Release
approval.

## Reviewed identity

| Field | Value |
| --- | --- |
| Work item / lane / round | `RIME-SYNC-001` / `RIME-SYNC-001/publication-20260926/quality` / `4` |
| Branch / base | `codex/rime-sync-v1-local-folder-pr` / `9838c092672dae60c63b34e4d9be6dffafc3869f` |
| Candidate at review | 79 staged paths; full staged diff SHA-256 `add6e4421963a426e7a210c2bc970b4a42eaa3fbf79fbc3379915e9d5a280785` |
| Implementation/test/workflow scope SHA-256 | `a6f99ceca98a7c1331f7289efd3847a4f6a886e5a9f562f052c678ac96e3f284` |
| Base packet SHA-256 | `2a8aa3fb3f917d73b150b7bc796754c61da1a51ffe61b507aaa5089b0cdbd741` |
| Complete round-4 packet SHA-256 | `ab5e816e8384a7d6809d9edfb538390828a1c1add58df171ace2dadef9839267` (base packet + budget and fresh-evidence supplements) |

The 79-path candidate and implementation digest above are the reviewer target.
This receipt is a coordinator-created record written after the lane finished;
it was not part of that target and is not represented as reviewed by the lane.

## Coverage and evidence

| Criterion | Result |
| --- | --- |
| Q1 — branch, base, candidate path count/digest, packet identity and scope | Covered; independently matched for the frozen candidate. |
| Q2 — applicability and exact test/build outcomes | Covered; retained skips remain skips and are not counted as passes. |
| Q3 — Files picker failure, Cell-query correction, focused/full signed UI runs | Covered; the earlier 14/15 failure remains recorded as failed history. |
| Q4 — Keychain denial mapping, user guidance, persisted terminal code, CI alignment | Covered. |
| Q5 — fresh changed-Markdown links, KOS structure, formatting/whitespace and scope claims | Covered by the fresh log below; the finding is resolved. |
| Q6 — publication conditions and remaining limitations | Covered; no publication blocker remained within the authorized boundary. |

Fresh Q5 log: `/private/tmp/rime-sync-publish-preflight.mfN43t/Lightweight-post-final-docs-2026-09-27.log`, SHA-256
`b7d6711d8a6e53374637c10083ca85096c710ef69f88e8040d7ed570006dee69`.
The log was generated after the last pre-review candidate Markdown edits and
records 62 changed-Markdown links passing, 12 CI helper unit tests passing,
and the pinned KOS structural validator passing. The reviewer independently
matched its digest and freshness against the frozen candidate. The review lane
did not run tests or modify the candidate.

## Conditions and limitations

- Keep all 10 skipped App + Keyboard tests and 20 skipped RimeBridge tests
  explicitly classified as skips, not passes.
- The evidence is bounded to the accepted iOS V1 local-folder scope. It does
  not prove a live WebDAV server, provider deletion/propagation, CloudKit,
  cross-platform portability, future automatic-sync cadence, or physical-device
  provider behavior.
- Preserve open `tech_debt:TD-002`, `TD-008`, `TD-013`, `TD-017`, and `TD-019`
  and the accepted residuals in the [Assignment close decision](../product-decisions/RIME-SYNC-001-ASSIGNMENT-CLOSE-2026-09-25.md).
- This conclusion permits only the already authorized commit, push and PR
  preparation when local gates pass. It does not authorize merge, TestFlight,
  App Store submission or Release.

## Usage

The Human Product Owner authorized 30 calls or 20 active minutes, whichever
came first. Final usage was **30/30 calls and about 10/20 active minutes**;
the call ceiling was reached. The fresh Q5 supplement completed the remaining
coverage within that authorization.

## Archive relocation note — 2026-09-29

> Append-only note. The review above is unchanged, including the recorded SHA-256 value.

The raw directory `/private/tmp/rime-sync-publish-preflight.mfN43t/`, which held the fresh Q5 log cited above, was archived on `2026-09-29 22:05:18 Asia/Shanghai`. The archive is host-local and not in Git: `~/.kos-work/Universe-Keyboard/archive/rime-sync-publish-preflight-mfN43t/rime-sync-publish-preflight-mfN43t-evidence.tar.zst` on `DoubleShy0Ns-MacBook-Pro-66.local`, SHA-256 `8fde4f4303ef2f3e7f26c5fc7c6566d684bc8f2f0f3b12fe77258d1c19790461`. The original directory was deleted after full-extraction verification. `Lightweight-post-final-docs-2026-09-27.log` was present in the archive, and its SHA-256 matched the `b7d6711d8a6e53374637c10083ca85096c710ef69f88e8040d7ed570006dee69` recorded above. Full archive facts, exclusions and provenance are in the [preflight record's Archive relocation section](../evidence/rime-sync-v1-publication-preflight-2026-09-25.md#archive-relocation--2026-09-29). This note is not a new review and does not change the conclusion above.
