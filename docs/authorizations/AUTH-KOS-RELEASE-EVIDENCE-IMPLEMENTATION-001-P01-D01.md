# Authorization: AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P01-D01 — fact-only handoff

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P01-D01",
  "record_type": "authorization",
  "title": "Authorize UK-005 P-01 publication facts and D-01 final-documentation receipt",
  "status": "consumed",
  "updated_at": "2026-09-16T21:23:13+08:00",
  "revalidation_triggers": [
    "candidate_head_changed",
    "final_tree_changed",
    "scope_changed",
    "hosted_ci_rechecked",
    "checker_or_scope_changed",
    "publication_boundary_changed",
    "authority_revoked"
  ],
  "parent_refs": [
    "KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001",
    "KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1",
    "PD-KOS-UPGRADE-UK-005-RELEASE-EVIDENCE"
  ],
  "authorization": {
    "action": "produce_uk005_p01_d01_facts",
    "target": "KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P01-D01",
    "artifact_bindings": [
      {"kind": "file", "identity": "docs/assignments/kos-release-evidence-implementation-001-p01-d01.md"},
      {"kind": "file", "identity": "docs/authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P01-D01.md"}
    ],
    "scope": "Create and later produce only content-free P-01 delivery/publication facts and D-01 final-documentation facts for a freshly frozen UK-005 candidate. The observed creation snapshot is main/origin main d5c53f2cbda85e16721b9eafae09a763f6a04471; it is not a final candidate binding. Read-only Git/GitHub provenance observation and exact local documentation checks are allowed. A final commit or published head that does not exist must remain unknown/not-run.",
    "exclusions": [
      "Build 55 TD-003, TD-004 and TD-005 status or evidence",
      "historical Build 55 backfill or reinterpretation",
      "F-001 through F-004 implementation or re-review",
      "Quality P1-01/P1-02 and P1-B Diagnostics UI/storage",
      "Swift, UI, test, adapter, fixture-runner, Profile, contract, schema or evaluator changes",
      "raw keyboard text, candidate text, host text, credentials, full logs or unrelated user data",
      "device operation, signing, archive/export or release environment",
      "App Store Connect, TestFlight, Beta Review or external distribution",
      "Product Gate, Quality Gate, Release Pass, current-proof or publication approval",
      "commit, push, pull request, merge, tag, branch deletion or remote mutation",
      "KOS required mode, historical Envelope migration or contract-scope changes"
    ],
    "issuer_role": "Human Product Owner acting as Product Lead",
    "decision_source": "in-session 2026-09-16 Asia/Shanghai explicit authorization: create a new Assignment/Authorization that only produces UK-005 P-01/D-01 fact receipts; no Release, merge or external publication is authorized",
    "issued_at": "2026-09-16T18:50:05+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

## Current Status

| Field | Value |
|---|---|
| Status | consumed |
| Consumption | Consumed by the recorded P-01/D-01 receipts for candidate `07b4a434…`; Hosted CI Run [#490](https://github.com/shchnk1103/Universe-Keyboard/actions/runs/35099850845) is same-head green and D-01 is Pass for the fact-only handoff |

## Authorized actions

1. Maintain the matching Assignment and its content-free status mirrors.
2. At a separately recorded candidate freeze, observe local, published and hosted
   heads and record the P-01 facts exactly as observed. Missing, unequal or stale
   identities must remain `unknown` or `mismatched`.
3. After the last documentation edit of the handoff, run the named local checks and
   record the D-01 final commit/tree, baseline, checker/version/scope, output, time and
   result. A generic `git diff --check` alone is not a D-01 receipt.
4. Record a bounded receipt and hand it to the UK-005 release-evidence owner. This
   handoff does not authorize the recipient or the Executor to publish or release.

> **Consumed:** [KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P01-D01](../assignments/kos-release-evidence-implementation-001-p01-d01.md)
> after the P-01/D-01 receipts were recorded. This Authorization is not reusable for
> Product Gate, Quality/Release conclusion, PR, merge, upload, TestFlight, App Store
> Connect or Release.

## Human authority boundary

This Authorization is a scoped permission to produce facts, not a bearer token for
GitHub, devices or release services. The issuer retains Product, Release and external
publication authority. The Executor may not infer a same-head relation from a green
check on another SHA, infer a final tree from an uncommitted worktree, or turn either
receipt into a Product/Quality/Release conclusion.

Any commit or remote publication needed to establish a future candidate is a separate
authorization. Until such a candidate exists, the fact receipt must say `unknown` or
`not-run`; this record does not grant that missing action.

## Revalidation and consumption

Revalidate before receipt production if the candidate, final tree, Hosted CI result,
checker scope, privacy boundary or requested action changes. This Authorization was
consumed on `2026-09-16T21:23:13+08:00` after the bounded P-01/D-01 receipts were
recorded. Later Product/Release actions need a new Assignment and matching
Authorization.
