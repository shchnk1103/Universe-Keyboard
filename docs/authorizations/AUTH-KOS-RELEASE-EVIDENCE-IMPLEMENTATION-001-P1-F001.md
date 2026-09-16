# Authorization: AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001 — F-001 remediation

## Current Status

| Field | Value |
|---|---|
| Status | active |
| Consumption | consumed by the bounded F-001 read-only re-verification receipt; applies only to this slice, not to the remaining UK-005 findings, P1-B or Release actions |

Human Product Owner, current session `2026-09-16 Asia/Shanghai`: “以
`5692cf6` 为干净基线，先为 UK-005 的 P1 Needs work 问题建立新的
Assignment/Authorization，优先处理 F-001；Build 55 的 TD-003~005 继续保持
open，不把上次文档合并当作 Release 通过。”

```kos-record
{
  "schema_version": {"major": 1, "minor": 0},
  "record_id": "AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001",
  "record_type": "authorization",
  "title": "Authorize UK-005 P1 F-001 Main-App source identity fail-closed remediation",
  "status": "active",
    "updated_at": "2026-09-16T16:11:16+08:00",
  "revalidation_triggers": [
    "scope_changed",
    "authority_revoked",
    "base_commit_changed",
    "review_finding",
    "source_owner_or_identity_changed",
    "contract_schema_or_evaluator_changed",
    "p1a_scope_changed",
    "p1b_scope_changed"
  ],
  "parent_refs": [
    "KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1",
    "PD-KOS-UPGRADE-UK-005-P1-A-SCOPE"
  ],
  "authorization": {
    "action": "remediate_uk005_p1_f001",
    "target": "KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001",
    "artifact_bindings": [
      {"kind": "file", "identity": "scripts/release/kos_release_evidence_adapter.py"},
      {"kind": "file", "identity": "scripts/release/tests/test_kos_release_evidence_adapter.py"},
      {"kind": "file", "identity": "scripts/release/fixtures/kos_release_evidence_cases.json"}
    ],
    "scope": "From clean baseline 5692cf60c344d79b428d50430422a7c76832df06, re-verify UK-005 F-001 and, only if required, make the smallest fail-closed source-identity remediation in the adapter with bounded negative tests/fixtures; produce an executor receipt and request fresh independent Architecture and Quality review. No commit or push is authorized.",
    "exclusions": [
      "F-002 through F-004",
      "Quality P1-01 and P1-02 or other historical Needs work findings",
      "P1-B Diagnostics UI or storage, retention, clear behavior, migration, backfill or background sync",
      "Main-App store/UI implementation or ADR 0027/App Group ownership change",
      "change adopted KOS v0.8.0 pin, release-evidence Profile, contract, schema or evaluator pin",
      "raw keyboard text, candidate text, host text, credentials, full logs or unrelated user data",
      "device, Simulator, archive/export, App Store Connect, TestFlight, Beta Review or external distribution",
      "Product Gate, Quality Gate, Release Pass, current-proof authority or Release decision",
      "commit, push, pull request, merge, tag, branch deletion or publication",
      "KOS required mode or historical Envelope migration",
      "Build 55 TD-003, TD-004 and TD-005 status or evidence"
    ],
    "issuer_role": "Human Product Owner acting as Product Lead",
    "decision_source": "in-session 2026-09-16 Asia/Shanghai instruction: use clean baseline 5692cf6, establish a new UK-005 P1 Assignment/Authorization, prioritize F-001, keep TD-003/004/005 open and do not call the prior documentation merge a Release pass",
    "issued_at": "2026-09-16T15:48:21+08:00",
    "expires_at": null,
    "supersedes_ref": null,
    "consumption_state": "consumed"
  }
}
```

## Authorization outcome

This is a new, bounded F-001 authorization. It does not reuse or widen
[`AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1`](AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md),
which is a consumed predecessor Authorization. The new Assignment is `Active` after
the bounded read-only re-verification; implementation code remains unchanged and
fresh independent reviews are still required.

## Authorized actions

1. Inspect the exact baseline implementation and focused tests for the F-001
   source seam.
2. Re-verify that unresolved values are rejected after case/whitespace
   normalization, that `main_app_source` uses the exact canonical
   `SRC-MAIN-STORE` identity and key set, and that foreign or caller-controlled
   binding input cannot enable a verified source.
3. If a gap remains, modify only the three bound adapter/test/fixture files with
   the smallest fail-closed correction. If no gap remains, leave the code
   unchanged and record the bounded re-verification evidence.
4. Run the focused tests and pinned fixture/evaluator checks with an explicit
   `--as-of`; add no raw user content to inputs, output or receipts.
5. Produce a content-free executor receipt bound to the exact base/candidate
   state, changed files, fixture IDs, commands, outputs, exit codes and
   non-claims, then request fresh independent Architecture and Quality review.

The current source-owner receipt may be consumed as a read-only predecessor
input. It cannot be edited, silently transferred to a new package, or replaced
by a caller-declared `binding_status`, Boolean or other payload alias. If the
receipt cannot establish a stable owner identity, stop with a fail-closed
unresolved result.

## Human authority boundary

The issuer retains Product scope, acceptance, reassignment and Release authority.
This Authorization does not permit the Executor to:

- infer a current-proof, Product/Quality/Release Gate or Release conclusion from
  code, fixtures, evaluator output, documentation merge or hosted CI;
- change the Main-App source owner, App Group, ADR 0027, P1-B scope or adopted
  contract without a new Product Decision and matching Assignment/Authorization;
- address F-002–F-004, Quality P1-01/P1-02, other historical findings or Build 55
  TD-003–005;
- commit, push, open/modify a PR, merge, publish, upload, submit Beta Review,
  use TestFlight or release.

## Revalidation and consumption

The Authorization is `active` with `consumption_state` `consumed` after the bounded
F-001 re-verification and its executor receipt were recorded. A scope,
baseline, source-owner, contract or review change invalidates it and requires a
new Product Lead decision before continuing.
