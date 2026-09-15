# Product Decision: KOS-UPGRADE-UK-005 — Adopt `kos.release-evidence` v1.0 prospectively

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "PD-KOS-UPGRADE-UK-005-RELEASE-EVIDENCE",
  "record_type": "decision",
  "title": "Adopt kos.release-evidence v1.0 for new release-evidence records and handoffs",
  "status": "accepted",
  "updated_at": "2026-09-14T17:23:45+08:00",
  "revalidation_triggers": [
    "upstream_candidate_changed",
    "hosted_provenance_rechecked",
    "scope_changed",
    "required_mode_requested",
    "rep_q_01_finalized",
    "publication_boundary_changed",
    "privacy_owner_changed"
  ],
  "decision": {
    "authority_role": "Human Product Owner",
    "decision_source": "Current Codex session, 2026-09-14 Asia/Shanghai: Adopted",
    "scope": "Adopt kos.release-evidence v1.0 prospectively for new release-evidence records and handoffs, with explicit opt-in and no historical migration",
    "outcome": "Adopted as a project-level optional contract; current kos-agent-kit v0.8.0 advisory pin remains unchanged and the untagged candidate is not represented as a Kit Release",
    "expires_at": null
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | accepted |
| Decision | Adopted prospectively for new release-evidence records and handoffs |
| Non-claims | Not a new Kit Release; no historical migration; no `required`; no Product/Quality/Release Gate, commit, push, merge or Release authorization |

Human Product Owner, current session `2026-09-14 Asia/Shanghai`: **“Adopted，继续。”**

## Decision

Universe Keyboard adopts the `kos.release-evidence` v1.0 contract using the exact
candidate reviewed by [`KOS-UPGRADE-UK-005`](../assignments/kos-upgrade-uk-005-release-evidence-v1.md).
This is an adoption of the contract semantics and a pinned upstream candidate, not a
claim that the upstream repository has published a new Kit tag or GitHub Release.

| Upstream input | Adopted identity |
|---|---|
| Implementation commit | `8e55551a3b56b57e7fc5ab5544d653f9c6854df9` |
| Adoption metadata commit | `f5c88d57f599d7ef352322ea7664f637fb288d60` |
| Candidate tree digest | `fec6889e81ea0807b284de45027e0270a70938e220041a8c367fd41a081a88c9` |
| Contract source digest | `f7ec8d9363cc37e53201e8bf990af80ba77fc9f88b7f78371d2c39f453a78673` |
| Standalone schema digest | `4e48bcf127edb87e67c4d390a3baec93af26ef72aa251e8172cb1044dca893ce` |
| Reference evaluator digest | `a45145681306c2da581f1054f002b7becd909d1bb4a8329ad14892f17839b9d9` |
| Reviewed Universe packet digest | `18eb208bec1bd4ee29968bc9bf1989000ceea51c50848a5f74da47ee2eeb9d3a` |

The independent Architecture and Quality re-reviews both passed for the exact
Universe packet digest. Their scope remains limited to the contract/adoption packet;
they are not Product, Release or implementation acceptance.

## Adoption boundary

- Adoption applies only to new release-evidence records and handoffs that explicitly
  opt into the contract and name the project adopter Profile.
- The project-owned Source of Truth remains the Universe release-evidence owner; the
  KOS evaluator is a structural/semantic checker and never a Product, Quality, Gate,
  merge or Release authority.
- Daily Beta evidence may support a later external candidate only with exact candidate,
  artifact/input, context, freshness, coverage and comparison bindings. Otherwise it
  remains `comparator`, `pending` or `none` and cannot authorize publication.
- First external promotion requires a verified baseline; subsequent promotion requires
  a different previous receipt with the same declared stage/context/profile/contract
  bindings and resolved history identity keys.
- The adopted Profile must remain content-free and Main-App-owned. It must not store
  raw keyboard text, candidate text, host text, credentials, full logs or unrelated
  user data; the Keyboard Extension has no synchronous file-I/O or runtime-network
  dependency for this contract.
- Existing Active Assignments, historical Build evidence and the current release-evidence
  worktree are not migrated or backfilled.

## KOS v0.8.0 contract selection

The following project-level opt-in is authorized for the future implementation
Assignment, while `required` remains unauthorized:

| Contract | Selection | Boundary |
|---|---|---|
| E-01 claim-bound observation | Adopted for new release-evidence observations | Content-free claims, outcomes, timestamps, coverage and evidence references only |
| P-01 publication facts | Adopted for future publication handoffs | Local/published/hosted heads and relation must be explicit; unknown is fail-closed |
| D-01 final-documentation receipt | Adopted for future final validation | Final tree, checker/version/scope, baseline, time, result and output must be bound |
| A-01 / B-01 authorization chain and briefing | Not applicable in this implementation slice | Publication, merge and Release authorization remain separate human-owned actions |

## Accepted residual boundary

| Residual | Decision | Owner / required follow-up |
|---|---|---|
| `REP-Q-01` has no final SHA, actual base/head pair or hosted-CI provenance for the Universe implementation | Accepted only for this adoption decision; it blocks publication readiness and implementation handoff closure | Release-evidence owner; close with a final-tree/P-01 receipt before any Ready or external publication claim |
| Hosted tag/Release probe was unavailable because the network command failed | Accepted as an adoption non-claim, not as proof of absence | Executor must re-run the exact probe before `Ready`, implementation closure or project publication handoff |

## Non-goals

- Do not change the adopted Kit pin `v0.8.0`, enable `required`, or adopt H-02/W-01.
- Do not migrate existing Active Assignments or backfill historical evidence.
- Do not treat the untagged candidate as a released Kit version.
- Do not modify Swift, Keyboard Extension hot-path behavior, App Group ownership,
  App Store Connect/TestFlight state or Release Gates in this decision.
- Do not authorize commit, push, merge, tag, external publication or Release.

## Handoff

The implementation handoff is [`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001`](../assignments/kos-release-evidence-implementation-001.md).
It must first create the project adopter Profile/owner map and preserve the exact
candidate pins above. Any runtime integration, final SHA, hosted-CI handoff or external
publication is a separately evidenced stage and remains subject to the Assignment's
independent Architecture/Quality review and Product/Release authority.

## Revalidation

This decision must be re-opened if the upstream candidate, contract/schema/evaluator
digest, Profile scope, privacy/runtime boundary, `REP-Q-01` provenance, or requested
`required`/publication scope changes.
