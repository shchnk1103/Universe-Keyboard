# Evidence: KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001 — Coverage-R1

## Current Status

| Field | Value |
|---|---|
| Status | Executor-recorded durable negative coverage complete; fresh independent Architecture review pending |
| Assignment | [`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001`](../assignments/kos-release-evidence-implementation-001-p1-f001.md) |
| Authorization | [`AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001-COVERAGE-R1`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001-COVERAGE-R1.md), active and consumed by this bounded update |
| Baseline / HEAD | `5692cf60c344d79b428d50430422a7c76832df06` / `5692cf60c344d79b428d50430422a7c76832df06` |
| Implementation change | Adapter and fixture runner are byte-identical to the baseline; only focused test assertions and fixture-driven F-001 input data changed |
| Evidence grade | `Executor-recorded` |
| Non-claims | No independent Architecture/Quality closure, current-proof authority, Product/Quality/Release Gate, TestFlight, App Store Connect, merge or Release decision |

This receipt records the bounded Coverage-R1 update authorized after the prior
Architecture `request_changes` finding. It does not itself close F-001. The
fresh Architecture reviewer must consume the exact package below and this
receipt's separately verified SHA-256.

## Scope and changed surface

Coverage-R1 persists the F-001 negative inputs in the existing fixture JSON and
uses them from the focused adapter test. No adapter behavior or fixture-runner
behavior was changed.

| File | Change |
|---|---|
| `scripts/release/tests/test_kos_release_evidence_adapter.py` | Expanded unresolved, source identity, exact-key and caller-alias negative assertions; added missing-key coverage |
| `scripts/release/fixtures/kos_release_evidence_cases.json` | Added content-free `f001_negative_coverage` input sets consumed by the focused tests |
| `scripts/release/kos_release_evidence_adapter.py` | No diff from baseline |
| `scripts/release/run_kos_release_evidence_fixtures.py` | No diff from baseline |

No Main-App store/UI, ADR 0027, App Group, Keyboard Extension, RIME, device,
archive/export, external service or release operation was accessed or changed.
No raw keyboard text, candidate text, host text, credentials or full logs were
included in the fixture data or this receipt.

## Durable F-001 coverage

The fixture-driven set contains:

- unresolved record IDs: `UNKNOWN`, `unknown`, ` UNKNOWN `, `TODO`, `todo`,
  `TBD`, `tbd` and ` Tbd `;
- foreign or case-variant source identities: `SRC-OTHER`, `unknown` and
  `src-main-store`;
- each missing canonical `main_app_source` key: `source_identity`, `record_id`,
  `operation_id`, `sha256` and `retention_class`;
- caller-controlled aliases: `binding_status`, `is_verified` and `verified`;
- an extra source key: `unexpected`.

The focused test executes every value from this fixture-driven set and expects
`AdapterInputError` before Envelope construction. The existing code-controlled
`MAIN_APP_SOURCE_BINDING_STATE=unresolved` assertion remains in the same test
suite; no caller field can change it.

## Exact review package

The fresh Architecture review must use the following ordered raw-byte package.
This Coverage-R1 receipt is excluded to avoid a self-referential digest and is
handed off separately.

1. `.kos/project.json`
2. `docs/ACTIVE_WORK.md`
3. `docs/ENGINEERING_DASHBOARD.md`
4. `docs/KNOWLEDGE_INDEX.md`
5. `docs/assignments/kos-release-evidence-implementation-001-p1-f001.md`
6. `docs/authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001.md`
7. `docs/authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001-COVERAGE-R1.md`
8. `scripts/release/kos_release_evidence_adapter.py`
9. `scripts/release/run_kos_release_evidence_fixtures.py`
10. `scripts/release/fixtures/kos_release_evidence_cases.json`
11. `scripts/release/tests/test_kos_release_evidence_adapter.py`
12. `docs/kos/release-evidence-profile.md`
13. `docs/reviews/KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-p1-f001-architecture-review-2026-09-16.md`
14. `docs/reviews/KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-p1-architecture-remediation-exact-digest-review-2026-09-14.md`
15. `docs/evidence/kos-release-evidence-implementation-001-p1-rep-q-01-hosted-provenance-2026-09-15.md`

Ordered raw-byte package SHA-256:

`30e80bc4c870300b10a19bb23f87a0412b2967189b0c057804e5030268455d92`

The reviewer must verify the package digest and this receipt's independent
SHA-256 before assessing the content. Any package member change invalidates
this handoff and requires a new exact-digest review.

## Pinned inputs and commands

The local pinned KOS Kit checkout is `/Users/doubleshy0n/Dev/kos-agent-kit` with
the same clean pin used by the Preflight:

```text
actual_head=f5c88d57f599d7ef352322ea7664f637fb288d60
candidate_tree_digest=fec6889e81ea0807b284de45027e0270a70938e220041a8c367fd41a081a88c9
contract_digest=f7ec8d9363cc37e53201e8bf990af80ba77fc9f88b7f78371d2c39f453a78673
schema_digest=4e48bcf127edb87e67c4d390a3baec93af26ef72aa251e8172cb1044dca893ce
evaluator_digest=a45145681306c2da581f1054f002b7becd909d1bb4a8329ad14892f17839b9d9
adapter_sha256=bf61230f7a1c4fbc2d15c381bc6d50c45cd07bdd58f18273aef05784dc785477
```

Focused adapter tests:

```bash
PYTHONDONTWRITEBYTECODE=1 \
  python3 -m unittest \
  scripts/release/tests/test_kos_release_evidence_adapter.py -v
```

Result: exit `0`; `26` tests run, `26` passed, `0` failed.

Pinned Envelope and Delta fixture matrix:

```bash
PYTHONDONTWRITEBYTECODE=1 \
  python3 scripts/release/run_kos_release_evidence_fixtures.py \
  --kos-kit-root /Users/doubleshy0n/Dev/kos-agent-kit \
  --work-dir /private/tmp/uk005-f001-coverage-r1.sSZWMt/runner \
  --output /private/tmp/uk005-f001-coverage-r1.sSZWMt/fixture-report.json
```

Result: exit `0`; `52/52` Envelope cases and `24/24` Delta cases passed,
`76/76` total. The temporary report is not a durable release artifact.

Additional local checks: fixture JSON parse exit `0`; `git diff --check` exit
`0`. No Swift/source target changed, so no xcodebuild was run for this
documentation/Python evidence slice.

## Coverage-R1 decision

**Durable F-001 negative coverage is complete for this bounded update.** The
implementation allowlist remains unchanged and the adapter's existing
fail-closed behavior was not altered.

This receipt is an executor result, not an independent Architecture conclusion.
The next handoff is a fresh Architecture review of package
`30e80bc4c870300b10a19bb23f87a0412b2967189b0c057804e5030268455d92`; Quality
review remains a later, separately authorized step.

Build 55 TD-003, TD-004 and TD-005 remain open. This receipt does not authorize
device, TestFlight, publication, merge or Release actions.
