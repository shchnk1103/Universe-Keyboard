# RIME-SYNC-001 publication review packet — 2026-09-26

## Frozen identity and decision

| Field | Value |
| --- | --- |
| Work Item | `RIME-SYNC-001`, bounded iOS V1 local-folder publication |
| Branch and baseline | `codex/rime-sync-v1-local-folder-pr`; immutable candidate `HEAD = 9838c092672dae60c63b34e4d9be6dffafc3869f` (also `origin/main` at packet freeze; exact Product-authorized branch) |
| Candidate | Exact staged paths from `git diff --cached --name-only HEAD`; the full `git diff --cached --binary HEAD` SHA-256 and path count are supplied in each dispatch and must be recomputed before review |
| Packet digest | SHA-256 of this file is supplied in each dispatch and must be recomputed before review; it is not embedded here to avoid self-reference |
| Quality lane | `RIME-SYNC-001/publication-20260926/quality`, round `4` (bounded delta re-review) |
| Architecture lane | `RIME-SYNC-001/publication-20260926/architecture`, round `4` (authorization-binding delta re-review) |
| Question | Does this exact candidate satisfy the independent Quality and Architecture checks needed **before commit, push and PR creation** under the already accepted bounded scope? This is not a merge, Product Gate, TestFlight or Release decision. |

These are publication reviewer lanes after remediation. Rounds 1 and 2 ended
`Partial / incomplete` because of target-base movement and missing evidence.
Round 3 Quality covered Q1–Q4/Q6 but stopped at its call ceiling with a Q5
evidence finding. Round 3 Architecture covered A1–A5 and found the candidate
branch name differed from the Product publication authorization. The
implementation/test/workflow source digest is unchanged; branch and evidence
references now align, so round 4 is a bounded delta review. The Human Product
Owner authorized Architecture review on this bounded candidate with a
cumulative ceiling of 70 calls or 35 active minutes; round-3 usage was 59
calls/approximately 11 minutes, leaving at most 11 calls/24 minutes for this
delta. Quality round 3 exhausted its 40-call ceiling; round 4 requires an
explicit new Quality budget before dispatch. Changed staged trees require a
new frozen packet/digest and a new round; prior results remain historical. A
later remote-main advance alone does not mutate this immutable candidate
baseline, but the Coordinator must recheck PR mergeability against the
then-current target before any publication claim.

## Shared target and operation boundary

- Read the exact staged candidate named above, `AGENTS.md`, the owning
  [Assignment](../assignments/rime-sync-001.md), [sync contract](../RIME_SYNC.md),
  [publication preflight](../evidence/rime-sync-v1-publication-preflight-2026-09-25.md),
  applicable Reading Map/playbook/ADR and only the exact result bundles and
  raw outputs named by the preflight: KeyboardCore full log
  `/private/tmp/rime-sync-publish-preflight.mfN43t/KeyboardCore-current-main-host.log`,
  Release result bundle
  `/private/tmp/rime-sync-publish-preflight.mfN43t/Release-current-main-explicit.xcresult`,
  final successful Release result bundle
  `/private/tmp/rime-sync-publish-preflight.mfN43t/Release-current-main-final.xcresult`
  and full build log
  `/private/tmp/rime-sync-publish-preflight.mfN43t/Release-current-main-final.log`,
  and final lightweight log (including the exact KOS validator stdout)
  `/private/tmp/rime-sync-publish-preflight.mfN43t/Lightweight-current-main-final.log`,
  strict Swift-format and whitespace log
  `/private/tmp/rime-sync-publish-preflight.mfN43t/SwiftFormat-whitespace-authorized-branch-final.log`,
  the other named `.xcresult` bundles. The staged path manifest is the bounded
  file inventory; reading relevant unchanged context is allowed only to
  resolve a named criterion.
- Read-only file/search/hash/Git and `xcresulttool` operations are allowed.
  Do not edit or stage files, run tests/builds, operate a device/Simulator,
  change Keychain/Files/provider state, call a remote service, inspect secrets
  or user input, commit, push, create/modify a PR, merge or release.
- Neither lane reads or relies on the sibling lane's packet output or verdict.
  Prior reviews may be read as historical pointers, never substituted for
  current evidence. Personal memory and dashboard mirrors are not decision
  authority.
- If the baseline, full diff digest, packet digest, required artifact or
  permitted scope does not match, identify the exact mismatch and stop that
  claim. Do not silently expand to other worktrees, accounts or providers.

## Quality lane — claims and positive criteria

The Quality reviewer covers all `Q1`–`Q6`:

1. `Q1` — Independently match branch, baseline, staged path count, full diff
   digest and packet digest; inspect the path list for out-of-scope content.
2. `Q2` — Check current-source applicability and exact pass/fail/skip totals for
   KeyboardCore, RimeBridgeTests, App + Keyboard, signed Keychain, signed iOS
   27 RIME Settings UI and Release build. An old run or skipped test is not a
   pass for a changed source snapshot.
3. `Q3` — Trace the 2026-09-25 Files picker failure to its selected element,
   verify the two Cell queries and both the focused and full signed UI result.
   Preserve the failed run as failed.
4. `Q4` — Check the distinct Keychain error guidance and persisted automatic
   terminal failure code, including regression assertions; verify the CI
   workflow, final-gate script, `AGENTS.md` instructions and changed-path
   classification agree on the signed Keychain job and full lane.
5. `Q5` — Check the final-candidate changed-Markdown link result, KOS structural result,
   whitespace/Swift format evidence, and scope-specific residuals. Confirm
   `TD-002`, WebDAV, CloudKit, cross-platform, provider propagation and device
   limitations are not promoted into unsupported pass claims.
6. `Q6` — Name every required condition for commit/push/PR and every remaining
   limitation. `Pass` or `Pass with conditions` requires coverage of `Q1`–`Q5`
   and no open publication blocker; conditions need an M-03 disposition and
   pointer. Uncovered input yields `Partial / incomplete`, not Pass.

Quality output is a read-only task response. The Coordinator records it at
`docs/reviews/rime-sync-v1-publication-quality-review-2026-09-26.md` only after
the lane finishes, with its exact baseline/digests, criterion coverage, stable
finding IDs, severity, owner, one disposition (`fix`/`accept`/`tech_debt:<ID>`),
evidence pointers and usage record.

## Architecture lane — claims and positive criteria

The Architecture reviewer covers all `A1`–`A5`:

1. `A1` — Independently match branch, baseline, staged path count, full diff
   digest and packet digest; inspect the path list for boundary changes.
2. `A2` — Trace Main-App-only sync/RIME deployment and Extension session-only
   ownership; assess process gate behavior without treating it as resolution
   of cross-process `TD-002`.
3. `A3` — Trace Security.framework failure through `keychainAccessDenied`,
   user-facing recovery, stable local diagnostic code and distinct persisted
   automatic terminal classification. Check backward-compatible finite-code
   semantics and relevant tests.
4. `A4` — Trace remote-private-package deletion, partial local Keychain cleanup
   and retry state. Distinguish fake-transport coverage from a real WebDAV or
   File Provider propagation claim.
5. `A5` — Check the accepted parent-close decision and M-03 residual table,
   including CloudKit scope exclusion, `TD-008`, `TD-019` and other retained
   debts; determine whether the exact candidate can enter commit/push/PR.
   `Accept` or `Accept with conditions` requires complete `A1`–`A5` coverage,
   no open architecture blocker and one valid disposition/pointer per
   condition. Uncovered input yields `Partial / incomplete`.

Architecture output is a separate read-only task response. The Coordinator
records it at
`docs/reviews/rime-sync-v1-publication-architecture-review-2026-09-26.md`
only after the lane finishes, with the same identity, coverage, finding and
usage fields. It must not infer the sibling Quality verdict.

## Budget, checkpoints and stop authority

Quality has a ceiling of **40 tool calls or 25 active minutes**. Architecture
has the explicitly authorized ceiling of **70 tool calls or 35 active
minutes**. For either lane, stop at whichever limit comes first. At start and after every 10 calls or 7 active minutes,
record used calls/time and covered/uncovered criteria in its task response;
the final review receipt is the durable usage-record location. At exhaustion,
stop and report `Partial / incomplete` with the remaining coverage. No budget
or target renewal is automatic.

Stop on digest mismatch, missing required artifact, scope expansion, secret or
user-content exposure risk, attempted write, or exhausted budget. Report one
precise locator and reason for any missing input. Only the **Product Lead**,
the Assignment Authority named by `RIME-SYNC-001`, may authorize an exact scope
or budget expansion; the Coordinator and reviewers cannot self-authorize it.

## Archive relocation note — 2026-09-29

> Append-only note. The frozen packet above is unchanged. Its `/private/tmp/rime-sync-publish-preflight.mfN43t/` paths are historical read locations.

The raw directory named by this packet was archived on `2026-09-29 22:05:18 Asia/Shanghai`. The archive is host-local and not in Git: `~/.kos-work/Universe-Keyboard/archive/rime-sync-publish-preflight-mfN43t/rime-sync-publish-preflight-mfN43t-evidence.tar.zst` on `DoubleShy0Ns-MacBook-Pro-66.local`, SHA-256 `8fde4f4303ef2f3e7f26c5fc7c6566d684bc8f2f0f3b12fe77258d1c19790461`. The original directory was deleted after full-extraction verification. Every packet-named log and result bundle was among the 17 docs-referenced paths confirmed present after extraction. The recorded SHA-256 values for `SwiftFormat-whitespace-authorized-branch-final.log` and `Release-current-main-final.log` matched. Full archive facts, exclusions and provenance are in the [preflight record's Archive relocation section](../evidence/rime-sync-v1-publication-preflight-2026-09-25.md#archive-relocation--2026-09-29). This note does not reopen or extend the review lanes.
