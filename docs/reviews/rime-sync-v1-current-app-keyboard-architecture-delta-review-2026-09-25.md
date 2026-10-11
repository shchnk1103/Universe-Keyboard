# RIME-SYNC-001 — Current App + Keyboard Architecture Delta Review — 2026-09-25

## Verdict

**Accept with conditions** for the approved iOS V1 local-folder scope and exact
snapshot below. No new code-level architecture blocker was found. Provider
deletion evidence and `TD-002` remain open; the parent Assignment remains
`Active`.

## Snapshot and reviewer boundary

| Item | Value |
|---|---|
| HEAD | `4a51228fc8e435d538e9a5f7342ae325502e1e66` |
| Candidate paths | 53, excluding the two 2026-09-25 Current App + Keyboard review receipts |
| Manifest SHA-256 | `eb3ab8b044421895c2b298520c39c485ebcf961f8c0c145127391f3cd05f2920` |
| Reviewer identity | Independent Architecture reviewer; visible model family GPT-6; exact variant/runtime identity **UNKNOWN** |

At review time, the candidate manifest used the C-locale sorted union of
tracked changes and untracked files relative to HEAD, excluding the then-
existing `rime-sync-v1-current-app-keyboard-quality-review-2026-09-25.md` and
`rime-sync-v1-current-app-keyboard-architecture-review-2026-09-25.md`. Each
remaining path was hashed with `shasum -a 256`; complete output lines were
joined with LF, then SHA-256 hashed. The reviewer reported the same 53-path
digest as the independent Quality review; the coordinator reproduced it.
These two delta-review receipts were authored after the review and are not
members of its candidate. Reproduction from the later worktree also excludes
the two delta-receipt files named here.

The review was read-only. No tests were run, no Simulator/device state was
changed, and no files were modified. The exact GPT-6 Luna variant and runtime
identity could not be independently attested.

## Findings and dispositions

- `ARCH-RIME-SYNC-001-CURRENT-2026-09-25-R1` remains **open**: real Files/File
  Provider metadata and durable deletion propagation are not evidenced and
  must be resolved or separately dispositioned before parent close.
- `ARCH-RIME-SYNC-001-CURRENT-2026-09-25-R2` remains
  `tech_debt:TD-002`: a Main-App process gate does not prove mutual exclusion
  against the Keyboard Extension/librime access to `Rime/user`.
- `ARCH-RIME-SYNC-001-CURRENT-2026-09-25-R3` and `R4` are **resolved**: the
  Assignment Exit Criteria and Dashboard now distinguish the historical
  398/387 run from the current 401/391/10 run, and consistently record Product's
  exact-run acceptance of the 402/401 reporting residual.
- Product acceptance does not explain or repair the MCP count cause, extend to
  future runs, or convert skipped tests into passes.

No new architecture or documentation consistency finding was identified.

## Non-claims

This review does not establish provider-side deletion propagation,
cross-process safety, live WebDAV, CloudKit, physical-device behavior for this
snapshot, natural BGTask delivery, cross-platform compatibility, debt
resolution, Product Gate, lifecycle closure, merge, TestFlight or Release.
