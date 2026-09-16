# Evidence: KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001 — read-only Preflight

## Current Status

| Field | Value |
|---|---|
| Status | Executor-recorded F-001 read-only Preflight complete; no code change identified |
| Assignment | [`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001`](../assignments/kos-release-evidence-implementation-001-p1-f001.md) |
| Authorization | [`AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001.md), active and consumed by this bounded re-verification receipt |
| Baseline / HEAD | `5692cf60c344d79b428d50430422a7c76832df06` / `5692cf60c344d79b428d50430422a7c76832df06` |
| Implementation surface | Adapter, focused test and fixture are byte-identical to the baseline; no F-001 code change was made |
| Evidence grade | `Executor-recorded` |
| Non-claims | No independent Architecture/Quality conclusion, current-proof authority, Product/Quality/Release Gate, TestFlight, App Store Connect, merge or Release decision |

This receipt records the bounded read-only Preflight requested for F-001. It does
not close the historical `Needs work` finding. The next required handoff is a fresh
independent Architecture review followed by a fresh independent Quality review of
the exact package and this receipt.

## Scope and boundary

The Preflight used only the F-001 source-identity boundary:

- [`kos_release_evidence_adapter.py`](../../scripts/release/kos_release_evidence_adapter.py)
- [`test_kos_release_evidence_adapter.py`](../../scripts/release/tests/test_kos_release_evidence_adapter.py)
- [`kos_release_evidence_cases.json`](../../scripts/release/fixtures/kos_release_evidence_cases.json)
- [`release-evidence-profile.md`](../kos/release-evidence-profile.md)
- the historical [`F-001 Architecture review`](../reviews/KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-p1-architecture-remediation-exact-digest-review-2026-09-14.md)
- [`REP-Q-01 / hosted provenance receipt`](kos-release-evidence-implementation-001-p1-rep-q-01-hosted-provenance-2026-09-15.md), read-only predecessor input

No Main-App store/UI, ADR 0027, App Group, Keyboard Extension, RIME, device,
archive/export, external service or release operation was accessed or changed.
No raw keyboard text, candidate text, host text, credentials or full logs were
included in the receipt.

## Exact identity and changed-surface check

The working branch is `codex/uk-005-f001-remediation`. The repository was at the
requested clean baseline before the governance records and this receipt were added.
The F-001 implementation allowlist has no diff from the baseline:

| File | Current Git blob | Baseline Git blob | Result |
|---|---|---|---|
| `scripts/release/kos_release_evidence_adapter.py` | `47464ef0d1a8a9227a37f03a8b543fe2bd9d2899` | `47464ef0d1a8a9227a37f03a8b543fe2bd9d2899` | match |
| `scripts/release/tests/test_kos_release_evidence_adapter.py` | `84e7be28d5430dffeccd5ff80cb8db89b8ec9e2e` | `84e7be28d5430dffeccd5ff80cb8db89b8ec9e2e` | match |
| `scripts/release/fixtures/kos_release_evidence_cases.json` | `196a7255b5fad666eec39fa39c7d1dd360481323` | `196a7255b5fad666eec39fa39c7d1dd360481323` | match |

The working tree changes are limited to the previously established governance
records/mirrors plus this receipt; they are not an implementation diff for F-001.

## Exact review package

The independent Architecture and Quality reviews must use the same ordered,
raw-byte package below. The Preflight receipt itself is excluded to avoid a
self-referential digest; it is handed off separately and must be verified by
its own SHA-256 before review.

1. `.kos/project.json`
2. `docs/ACTIVE_WORK.md`
3. `docs/ENGINEERING_DASHBOARD.md`
4. `docs/KNOWLEDGE_INDEX.md`
5. `docs/assignments/kos-release-evidence-implementation-001-p1-f001.md`
6. `docs/authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1-F001.md`
7. `scripts/release/kos_release_evidence_adapter.py`
8. `scripts/release/run_kos_release_evidence_fixtures.py`
9. `scripts/release/fixtures/kos_release_evidence_cases.json`
10. `scripts/release/tests/test_kos_release_evidence_adapter.py`
11. `docs/kos/release-evidence-profile.md`
12. `docs/reviews/KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-p1-architecture-remediation-exact-digest-review-2026-09-14.md`
13. `docs/evidence/kos-release-evidence-implementation-001-p1-rep-q-01-hosted-provenance-2026-09-15.md`

Ordered raw-byte package SHA-256:

`e931d2e71a10555b21d325420a71db8e373da6d2953d927be443d33d5cdaf4d4`

The independent reviewer must also record the SHA-256 of this receipt at the
time it is consumed. Any change to a package member invalidates the package
digest and requires a new review handoff.

## Pinned inputs

The local pinned KOS Kit checkout was `/Users/doubleshy0n/Dev/kos-agent-kit` with
working tree `clean` and adoption metadata commit:

```text
actual_head=f5c88d57f599d7ef352322ea7664f637fb288d60
candidate_tree_digest=fec6889e81ea0807b284de45027e0270a70938e220041a8c367fd41a081a88c9
contract_digest=f7ec8d9363cc37e53201e8bf990af80ba77fc9f88b7f78371d2c39f453a78673
schema_digest=4e48bcf127edb87e67c4d390a3baec93af26ef72aa251e8172cb1044dca893ce
evaluator_digest=a45145681306c2da581f1054f002b7becd909d1bb4a8329ad14892f17839b9d9
```

The project adapter SHA-256 observed by the fixture runner was:

```text
bf61230f7a1c4fbc2d15c381bc6d50c45cd07bdd58f18273aef05784dc785477
```

## Commands and results

All Python commands used `PYTHONDONTWRITEBYTECODE=1` so the read-only Preflight did
not create repository bytecode artifacts. The fixture runner used a temporary
working directory under `/private/tmp` and invoked the pinned evaluator with the
fixture's explicit `--as-of=2026-09-14T12:00:00+08:00`.

### Focused adapter tests

```bash
PYTHONDONTWRITEBYTECODE=1 \
  python3 -m unittest \
  scripts/release/tests/test_kos_release_evidence_adapter.py -v
```

Result: exit `0`; `25` tests run, `25` passed, `0` failed.

### Pinned Envelope and Delta fixture matrix

```bash
PYTHONDONTWRITEBYTECODE=1 \
  python3 scripts/release/run_kos_release_evidence_fixtures.py \
  --kos-kit-root /Users/doubleshy0n/Dev/kos-agent-kit \
  --work-dir /private/tmp/uk005-f001-preflight.xgDy4u/runner \
  --output /private/tmp/uk005-f001-preflight.xgDy4u/fixture-report.json
```

Result: exit `0`; `52/52` Envelope cases and `24/24` Delta cases passed,
`76/76` total. The temporary report is not treated as a durable release artifact.

## F-001 evidence matrix

| Boundary | Input / fixture | Observed result | Interpretation |
|---|---|---|---|
| Existing unresolved source seam | `UK-RE-FX-001` `daily-source-binding-unresolved-none` | Adapter/evaluator path passed; derived status `none` | An unresolved source seam cannot yield current-proof |
| Canonical unresolved spelling | `UK-RE-FX-035` `UNKNOWN` | Adapter exit `2`; `main_app_source.record_id is unresolved` | Reject before Envelope construction |
| Case-folded unresolved spelling | `UK-RE-FX-048` `unknown` | Adapter exit `2`; `main_app_source.record_id is unresolved` | Historical F-001 reproduction no longer occurs |
| Case/whitespace variants | In-memory `unknown`, ` UNKNOWN `, `TODO`, `todo`, `TBD`, `tbd` | All rejected with unresolved error | Case-folded unresolved predicate is effective |
| Canonical source identity | `SRC-MAIN-STORE` | Accepted as the only canonical identity | Parser preserves the named source seam |
| Foreign/case-variant source | `src-main-store`, `SRC-OTHER`, `unknown`, missing field | All rejected | Source identity is exact and fail-closed |
| Extra or caller-controlled binding | Extra source field; `binding_status`, `is_verified`, `verified` | All rejected | Caller cannot opt into verified binding |
| Code-controlled owner state | `MAIN_APP_SOURCE_BINDING_STATE=unresolved` | Passing source steps map to `inconclusive`; base evaluator result is not current-proof | No caller payload or fixture result promotes the seam |

The direct source-identity probe was in-memory only and wrote no repository file.
The existing `REP-Q-01` receipt was read for owner/candidate context only; its
source-owner conclusion was not transferred to this F-001 package and did not
change the adapter's code-controlled unresolved state.

## Preflight decision

**F-001 was not reproduced on the exact `5692cf6` baseline during this bounded
Executor Preflight. No adapter/test/fixture patch is identified at this stage.**

This is a re-verification result, not an independent closure:

- the historical review remains a `Needs work` record for its old exact package;
- the current baseline's guard and negative coverage satisfy the F-001 checks run here;
- fresh independent Architecture and Quality reviewers must assess this exact
  re-verification package before the Assignment can advance toward `Reviewed` or
  `Closed`;
- no `current-proof`, Product Gate, Quality/Release Gate or Release conclusion is
  produced by these tests or this receipt.

## Lifecycle and handoff

Because authorized work has started and the bounded re-verification receipt is now
recorded, the Assignment lifecycle is `Active` and the Authorization remains
`active` with `consumption_state=consumed`. The next handoff is:

```text
fresh independent Architecture review
  -> fresh independent Quality review
       -> Product Lead lifecycle decision
```

Build 55 TD-003, TD-004 and TD-005 remain open. This receipt does not change their
status and does not authorize any device, TestFlight, publication, merge or Release
action.
