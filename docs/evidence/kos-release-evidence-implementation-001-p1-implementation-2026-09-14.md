# KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1 — Implementation receipt

## Receipt identity and authority boundary

| Field | Value |
|---|---|
| Receipt type | Executor-recorded P1-A implementation and validation receipt |
| Assignment | [`KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1`](../assignments/kos-release-evidence-implementation-001-p1.md) |
| Authorization | [`AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1`](../authorizations/AUTH-KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-P1.md) |
| Worktree | `/private/tmp/universe-keyboard-kos-upgrade-uk-005` |
| Branch | `codex/kos-upgrade-uk-005-release-evidence` |
| Git HEAD during implementation | `3139f8d3bdb6be6622504ea731988f42681896fb` |
| Receipt observed at | `2026-09-14T23:34:13+08:00` Asia/Shanghai; implementation, remediation checks, fixture rerun and independent reviews were completed on the same working tree |
| External Git action | None; no commit, push, merge, tag, Release, TestFlight or App Store Connect action was authorized or performed |

This receipt records the P1-A implementation slice only. The worktree already contained
the authorized KOS P0/P1 documentation changes; they were preserved. No file in the
main worktree was edited. The receipt itself is not included in the implementation package
digest below, and independent reviewers must review the exact package digest rather than
trusting this prose alone.

## Implemented slice

| Area | Implemented result |
|---|---|
| New-record mapping | `kos_release_evidence_adapter.py` maps the existing Main-App `ReleaseEvidenceExport` shape (`recordType`, camel-case run fields) to a KOS v1 Envelope with bounded IDs, identities, timestamps and pointer grammar. |
| Main-App reconciliation | The adapter consumes an explicitly supplied `main_app_source` pointer and does not read the Main-App store. It accepts only the canonical `release_evidence_run` wrapper, requires `SRC-MAIN-STORE`, exact `nonClaims`, exact run/step allowlists and a resolved record/operation/digest binding, discards source `note`/narrative content, rejects an outer outcome that contradicts the Main-App step-derived outcome, and keeps all adapter-generated pass observations `inconclusive` while the code-controlled source-binding gate remains unresolved. |
| Claim registry | Seven explicit Main-App scopes map to stable claim/coverage IDs; the daily lane requires the three base scopes, while external-candidate records add reuse/readiness and the selected triggered/baseline boundary. |
| P-01/D-01 boundary | Missing delivery/final receipts default to `not-run`/`UNKNOWN`; supplied receipts are copied only through the bounded allowlist. The adapter never manufactures a passing delivery or final-validation fact. |
| Daily Beta → external candidate | Fixed first-target and subsequent-target helpers bind same-candidate baseline or different-candidate previous receipt, preserving `release_lineage` as the only previous-history key. A baseline must be an explicit current-candidate-bound review-record object; Boolean shortcuts and unused baseline references are rejected. |
| Delta-aware reuse | `plan_delta` requires base/head, candidate identity, Profile/source/basis and freshness inputs; it invalidates touched or dependency-affected keys, preserves exact fresh untouched keys, rejects duplicate/ambiguous surfaces and equal base/head bindings, and exposes `stop_before_current_proof`. The actual Main-App store owner path is a release dependency. Release evidence scope and repository CI tier are separate outputs, with CI classification aligned to the repository classifier while release-validation dependencies remain full. |
| Fixture execution | The runner verifies the pinned Kit implementation/adoption commits, ancestor relation, exact HEAD, clean worktree, raw-byte candidate tree digest and semantic source digests; it creates bounded envelope inputs, invokes the evaluator with an explicit `--as-of` for every envelope case, invokes the delta adapter for every delta case, and records per-case output, exit code and non-claim. |

The implementation does not add a Main-App UI, storage actor, `records.json` write path,
retention/clear behavior, export service, migration, App Group ownership, Keyboard
Extension I/O, runtime network dependency or release-service integration. P1-B remains
separately unauthorized.

## Exact implementation package

The implementation package is the ordered raw-byte concatenation of the six files below,
without separators or filename bytes. The receipt and all review artifacts are excluded
from this digest so the package identity is stable while the handoff record evolves.

| Order | File | File SHA-256 |
|---:|---|---|
| 1 | [`scripts/release/kos_release_evidence_adapter.py`](../../scripts/release/kos_release_evidence_adapter.py) | `bf61230f7a1c4fbc2d15c381bc6d50c45cd07bdd58f18273aef05784dc785477` |
| 2 | [`scripts/release/run_kos_release_evidence_fixtures.py`](../../scripts/release/run_kos_release_evidence_fixtures.py) | `7fe337bcc0b4585ec58b8415ff565be01ffc32dfc6351d9665e483f74c16c499` |
| 3 | [`scripts/release/fixtures/kos_release_evidence_cases.json`](../../scripts/release/fixtures/kos_release_evidence_cases.json) | `27ac1eb93f81985b1bd06be8e45cf34bd9c72dbb71f00b4704ba1dc60e93d66e` |
| 4 | [`scripts/release/tests/test_kos_release_evidence_adapter.py`](../../scripts/release/tests/test_kos_release_evidence_adapter.py) | `c6f21cef787696fd575a8d40c91a74b92307d1521b4983c788e968ce0272f7c4` |
| 5 | [`docs/kos/release-evidence-profile.md`](../kos/release-evidence-profile.md) | `d0cf8334d28674871e65f710d526f96ed311b9bc0b3970c686f4a9fe1b37d9e0` |
| 6 | [`docs/RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md) | `de12736db38b5ad6cb197787984531c08bce175fbd0011fb34649ffcba9350ab` |

Exact package digest:

```text
45afdbf879c6b0054790342861254abbc6d9cde846f61b43a160bd22064d0382
```

Reproduction algorithm:

```bash
python3 -c 'import hashlib; from pathlib import Path; p=["scripts/release/kos_release_evidence_adapter.py","scripts/release/run_kos_release_evidence_fixtures.py","scripts/release/fixtures/kos_release_evidence_cases.json","scripts/release/tests/test_kos_release_evidence_adapter.py","docs/kos/release-evidence-profile.md","docs/RELEASE_CHECKLIST.md"]; h=hashlib.sha256(); [h.update(Path(x).read_bytes()) for x in p]; print(h.hexdigest())'
```

## Pinned evaluator identity

The fixture runner used the local checkout `/Users/doubleshy0n/Dev/kos-agent-kit` and
verified these exact source digests before executing any case:

| Source | Path | Expected and observed SHA-256 |
|---|---|---|
| Contract | `ops/release-evidence.md` | `f7ec8d9363cc37e53201e8bf990af80ba77fc9f88b7f78371d2c39f453a78673` |
| Schema | `schemas/release-evidence-v1.schema.json` | `4e48bcf127edb87e67c4d390a3baec93af26ef72aa251e8172cb1044dca893ce` |
| Evaluator | `scripts/validate_release_evidence.py` | `a45145681306c2da581f1054f002b7becd909d1bb4a8329ad14892f17839b9d9` |

The adopted metadata remains `kos-agent-kit v0.8.0` advisory with implementation candidate
`8e55551a3b56b57e7fc5ab5544d653f9` and adoption metadata / Kit HEAD
`f5c88d57f599d7ef352322ea7664f637fb288d60`. The runner verified that the implementation
commit is an ancestor of that HEAD, the Kit worktree is clean, and the raw-byte digest of
the ten-file candidate manifest is
`fec6889e81ea0807b284de45027e0270a70938e220041a8c367fd41a081a88c9`. The evaluator is
read-only; it does not contact a service or create authority.

## Commands and aggregate results

### Focused Python tests

```text
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s scripts/release/tests -p 'test_*.py'
```

Result: **exit 0**, `Ran 25 tests`, `OK`.

The repository CI classification tests also passed: **exit 0**, `Ran 12 tests`, `OK`.
The three Python implementation/runner files passed `py_compile`, and
`bash scripts/ensure_rime_vendor.sh verify` passed the structural inventory of 12 RIME
framework artifacts.

### Historical fixed fixture matrix (superseded)

```text
PYTHONDONTWRITEBYTECODE=1 python3 scripts/release/run_kos_release_evidence_fixtures.py --kos-kit-root /Users/doubleshy0n/Dev/kos-agent-kit --work-dir /private/tmp/uk-kos-kos-fixtures-fix7 --output /private/tmp/uk-kos-kos-fixtures-fix7/report.json
```

Result: **exit 0**, fixed inventory **45 Envelope cases + 21 delta cases**, envelope
matrix **45/45**, delta matrix **21/21**, aggregate **66/66**. This is retained as a
historical pre-remediation receipt; the package digest and current fixed matrix below
supersede it.
The exact machine report SHA-256 is:

```text
59138dbb7128184037d32db2fcaea9b914cc36af6e9145281d5ff2f66621c199  /private/tmp/uk-kos-kos-fixtures-fix7/report.json
```

The old directory was not reused as current evidence.

### Current fixed fixture matrix (fix10)

The current fixed matrix was run with a fresh temporary output directory and the same
pinned sources after the source-binding and canonical-path remediation:

```text
PYTHONDONTWRITEBYTECODE=1 python3 scripts/release/run_kos_release_evidence_fixtures.py --kos-kit-root /Users/doubleshy0n/Dev/kos-agent-kit --work-dir /private/tmp/uk-kos-kos-fixtures-fix10 --output /private/tmp/uk-kos-kos-fixtures-fix10/report.json
```

Result: **exit 0**, fixed inventory **52 Envelope cases + 24 delta cases**, envelope
matrix **52/52**, delta matrix **24/24**, aggregate **76/76**. The report records the
explicit evaluator `--as-of=2026-09-14T12:00:00+08:00`, the exact candidate pins and
tree digest, the Main-App wrapper/step/outcome boundary cases `FX-046` through `FX-052`,
and the diff-binding/dependency cases `DELTA-022` through `DELTA-024`. Because the
adapter's source-binding gate is code-controlled and remains `unresolved` pending
`REP-Q-01`, no adapter-generated Envelope is allowed to carry a passing observation as
current-proof in this report. The exact machine report SHA-256 is:

```text
2398180e02bf7cf1338b773e0ebfd3920c98b477d3ef36b1d1798adda53b9a3c  /private/tmp/uk-kos-kos-fixtures-fix10/report.json
```

### Full local quality gate baseline

The repository classifies `scripts/release/**` as a non-doc change, so the full local
quality gate was run for the implementation slice even though it contains no Swift
changes. This gate completed before the final Python/JSON/Markdown remediation; no
Swift or runtime source changed afterward. The current post-remediation checks are the
25 focused release tests, 12 CI classification tests, `py_compile`, RIME vendor verify,
changed-path whitespace checks and the `fix10` 76-case fixture matrix recorded above:

| Check | Result |
|---|---|
| `bash scripts/ensure_rime_vendor.sh fetch` | exit `0`; structural inventory verified 12 RIME framework artifacts |
| `swift test --package-path Packages/KeyboardCore` | exit `0`; 1125 tests passed, 0 failed |
| XcodeBuildMCP `test_sim`, `RimeBridgeTests`, Debug, `iPhone 17 Pro` | succeeded; 81 passed, 0 failed, 20 skipped |
| XcodeBuildMCP `test_sim`, `Universe Keyboard`, Debug, `iPhone 17 Pro` | succeeded; 359 passed, 0 failed, 9 skipped; 2 SDK precompiled-module cache warnings |
| XcodeBuildMCP `build_sim`, `Universe Keyboard`, Debug | succeeded; no reported warnings or errors |
| XcodeBuildMCP `build_sim`, `Universe Keyboard`, Release | succeeded; 4 SDK precompiled-module cache warnings, 0 errors |
| `KOS_AS_OF=2026-09-14T23:32:36+08:00 bash /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate-kos.sh /private/tmp/universe-keyboard-kos-upgrade-uk-005` | exit `0`; structural KOS checks passed; only pre-existing repository warnings, no new as-of warnings for this Assignment |

The Swift-format hard gate was not invoked because the implementation package has no
`.swift` file changes. The cache warnings are build-environment diagnostics; they did
not produce a test or build failure.

Every envelope evaluator command below uses the explicit fixture-specific `--as-of`.
`current-proof`, `pending`, `comparator` and `none` are derived evaluator outputs only.
For invalid input the evaluator emitted no derived classification and exited `2`.

### Historical envelope evaluator matrix (fix7, superseded)

The following per-case table is retained only to show the pre-source-gate evaluator
behavior. It is not current proof. The authoritative current per-case record is the
machine-readable `fix10` report above; its adapter-generated passing observations are
deliberately downgraded while `REP-Q-01` remains unresolved.

| Fixture | Exact evaluator command | Output | Exit | Non-claim |
|---|---|---|---:|---|
| `UK-RE-FX-001` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-001.json --as-of 2026-09-14T12:00:00+08:00` | `current-proof`; claims `pass/pass/pass` | `0` | derived evaluator status is not Product, Quality, Gate or Release acceptance |
| `UK-RE-FX-002` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-002.json --as-of 2026-09-14T12:00:00+08:00` | no classification | `2` | invalid input emits no derived classification |
| `UK-RE-FX-003` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-003.json --as-of 2026-09-14T12:00:00+08:00` | no classification | `2` | unknown keys are rejected |
| `UK-RE-FX-004` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-004.json --as-of 2026-09-14T12:00:00+08:00` | no classification | `2` | policy shape failure is not relabeled as a runtime result |
| `UK-RE-FX-005` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-005.json --as-of 2026-09-14T12:00:00` | no classification | `2` | timezone-less as-of is invalid |
| `UK-RE-FX-006` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-006.json --as-of 2026-09-14T12:00:00+08:00` | `pending`; claims `pass/pass/pass/pass/pass/pass` | `0` | pending does not authorize upload or publication |
| `UK-RE-FX-007` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-007.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass/pass/pass/pass` | `0` | bound-target promotion failure is not pending or pass |
| `UK-RE-FX-008` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-008.json --as-of 2026-09-14T12:00:00+08:00` | `comparator`; claims `non-comparable/non-comparable/non-comparable` | `0` | comparator is historical comparison only |
| `UK-RE-FX-009` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-009.json --as-of 2026-09-14T12:00:00+08:00` | `none`; mixed `non-comparable/missing/pass` | `0` | mixed claim state cannot be treated as comparator |
| `UK-RE-FX-010` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-010.json --as-of 2026-09-14T12:00:00+08:00` | `current-proof`; claims `pass/pass/pass/pass/pass/pass` | `0` | current-proof remains a derived input classification, not a Release decision |
| `UK-RE-FX-011` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-011.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass/pass/pass/pass` | `0` | first target cannot carry previous target history |
| `UK-RE-FX-012` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-012.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass/pass/pass/pass` | `0` | subsequent target cannot carry first-target baseline |
| `UK-RE-FX-013` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-013.json --as-of 2026-09-14T12:00:00+08:00` | `current-proof`; claims `pass/pass/pass/pass/pass/pass` | `0` | history reuse does not collapse external delivery or human gates |
| `UK-RE-FX-014` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-014.json --as-of 2026-09-14T12:00:00+08:00` | `none`; previous receipt lacks `release_lineage` | `0` | missing release_lineage prevents subsequent promotion proof |
| `UK-RE-FX-015` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-015.json --as-of 2026-09-14T12:00:00+08:00` | `comparator`; claims `non-comparable/non-comparable/non-comparable` | `0` | candidate mismatch cannot support current proof |
| `UK-RE-FX-016` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-016.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `blocked/blocked/blocked` | `0` | future observations cannot support proof |
| `UK-RE-FX-017` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-017.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass` | `0` | future delivery facts cannot support P-01 |
| `UK-RE-FX-018` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-018.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass` | `0` | future final validation cannot support D-01 |
| `UK-RE-FX-019` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-019.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass` | `0` | future provenance cannot support current proof |
| `UK-RE-FX-020` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-020.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `stale/stale/stale` | `0` | stale observation is not invalid input and cannot support proof |
| `UK-RE-FX-021` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-021.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass` | `0` | stale delivery is not current P-01 |
| `UK-RE-FX-022` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-022.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass` | `0` | stale final validation is not current D-01 |
| `UK-RE-FX-023` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-023.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass` | `0` | stale provenance is not current proof |
| `UK-RE-FX-024` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-024.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `stale/stale/stale` | `0` | expired valid_until cannot support proof |
| `UK-RE-FX-025` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-025.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass` | `0` | P-01 requires all exact heads |
| `UK-RE-FX-026` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-026.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass` | `0` | unequal heads are not same-head delivery |
| `UK-RE-FX-027` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-027.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass` | `0` | hosted CI failure is not a passing P-01 fact |
| `UK-RE-FX-028` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-028.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass` | `0` | P-01 comparison basis must equal candidate basis |
| `UK-RE-FX-029` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-029.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass` | `0` | D-01 must bind the exact candidate final tree |
| `UK-RE-FX-030` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-030.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass` | `0` | D-01 checker identity is required |
| `UK-RE-FX-031` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-031.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass` | `0` | D-01 requires exit code zero |
| `UK-RE-FX-032` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-032.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass` | `0` | D-01 non-pass result cannot support proof |
| `UK-RE-FX-033` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-033.json --as-of 2026-09-14T12:00:00+08:00` | `none`; claims `pass/pass/pass` | `0` | unresolved candidate identity is fail-closed |
| `UK-RE-FX-034` | `python3 /Users/doubleshy0n/Dev/kos-agent-kit/scripts/validate_release_evidence.py /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-034.json --as-of 2026-09-14T12:00:00+08:00` | `comparator`; claims `non-comparable/non-comparable/non-comparable` | `0` | comparator precedence does not make delivery current |

The remediation boundary cases were executed from the same fixed report directory:

| Fixture | Exact command / input | Output | Exit | Non-claim |
|---|---|---|---:|---|
| `UK-RE-FX-035` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py envelope --input /private/tmp/uk-kos-kos-fixtures-fix7/adapter-inputs/UK-RE-FX-035.json --output /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-035.json` | adapter rejected unresolved source identity | `2` | unresolved Main-App source cannot produce current-proof |
| `UK-RE-FX-036` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py envelope --input /private/tmp/uk-kos-kos-fixtures-fix7/adapter-inputs/UK-RE-FX-036.json --output /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-036.json` | adapter rejected foreign wrapper schema | `2` | source schema mismatch is not an evaluator result |
| `UK-RE-FX-037` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py envelope --input /private/tmp/uk-kos-kos-fixtures-fix7/adapter-inputs/UK-RE-FX-037.json --output /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-037.json` | adapter rejected foreign wrapper contract | `2` | source contract mismatch is not a proof state |
| `UK-RE-FX-038` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py envelope --input /private/tmp/uk-kos-kos-fixtures-fix7/adapter-inputs/UK-RE-FX-038.json --output /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-038.json` | adapter rejected direct-run bypass | `2` | direct run input cannot bypass the Main-App wrapper |
| `UK-RE-FX-039` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py envelope --input /private/tmp/uk-kos-kos-fixtures-fix7/adapter-inputs/UK-RE-FX-039.json --output /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-039.json` | adapter rejected extra artifact identity | `2` | unallowlisted identity data is not accepted |
| `UK-RE-FX-040` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py envelope --input /private/tmp/uk-kos-kos-fixtures-fix7/adapter-inputs/UK-RE-FX-040.json --output /private/tmp/uk-kos-kos-fixtures-fix7/envelopes/UK-RE-FX-040.json` | adapter rejected narrative checker field | `2` | final-validation receipt fields remain opaque tokens |
| `UK-RE-FX-041` | same adapter command shape with `adapter-inputs/UK-RE-FX-041.json` | adapter rejected mismatched `release_lineage` | `2` | subsequent history cannot cross release lineages |
| `UK-RE-FX-042` | evaluator on `envelopes/UK-RE-FX-042.json`, `--as-of 2026-09-14T12:00:00+08:00` | `none`; checker version unresolved | `0` | D-01 unresolved checker identity is not current |
| `UK-RE-FX-043` | evaluator on `envelopes/UK-RE-FX-043.json`, `--as-of 2026-09-14T12:00:00+08:00` | `none`; scope unresolved | `0` | D-01 unresolved checker scope is not current |
| `UK-RE-FX-044` | evaluator on `envelopes/UK-RE-FX-044.json`, `--as-of 2026-09-14T12:00:00+08:00` | `none`; comparison baseline unresolved | `0` | D-01 unresolved baseline is not current |
| `UK-RE-FX-045` | evaluator on `envelopes/UK-RE-FX-045.json`, `--as-of 2026-09-14T12:00:00+08:00` | no classification; invalid `UNKNOWN` output for pass | `2` | the pinned schema rejects this invalid receipt shape |

The evaluator's invalid-input stderr was also captured in the machine report: FX-002
rejected malformed JSON; FX-003 rejected the unknown top-level key; FX-004 rejected the
missing policy claim binding; FX-005 rejected the timezone-less `as_of`. None emitted a
derived classification.

### Historical delta planner matrix (fix7, superseded)

The following table is retained as the earlier delta handoff. The authoritative current
per-case record is the machine-readable `fix10` report above, including the canonical
path, repository-CI-tier and fail-closed binding cases.

Each command below was executed with the same pinned adapter and a generated input under
`/private/tmp/uk-kos-kos-fixtures-fix7/delta/`; each command exited `0`. `reusable` and
`invalidated` list exact evidence keys; `stop` is `stop_before_current_proof`.

| Fixture | Exact command | Profile | CI tier | Reusable | Invalidated | Stop | Non-claim |
|---|---|---|---|---|---|:---:|---|
| `UK-RE-DELTA-001` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py delta --input /private/tmp/uk-kos-kos-fixtures-fix7/delta/UK-RE-DELTA-001-input.json` | `delta` | `full` | candidate identity | changed path, affected smoke | `true` | ordinary Main-App changes require affected claims to rerun; CI remains full |
| `UK-RE-DELTA-002` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py delta --input /private/tmp/uk-kos-kos-fixtures-fix7/delta/UK-RE-DELTA-002-input.json` | `delta` | `docs_only` | all three keys | none | `false` | docs-only reuse is not a release or Product approval |
| `UK-RE-DELTA-003` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py delta --input /private/tmp/uk-kos-kos-fixtures-fix7/delta/UK-RE-DELTA-003-input.json` | `full` | `full` | none | all three keys | `true` | candidate binding changes cannot reuse prior evidence |
| `UK-RE-DELTA-004` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py delta --input /private/tmp/uk-kos-kos-fixtures-fix7/delta/UK-RE-DELTA-004-input.json` | `full` | `full` | none | all three keys | `true` | privacy or source-owner changes require a new complete review path |
| `UK-RE-DELTA-005` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py delta --input /private/tmp/uk-kos-kos-fixtures-fix7/delta/UK-RE-DELTA-005-input.json` | `full` | `full` | none | all three keys | `true` | freshness policy changes invalidate prior freshness conclusions |
| `UK-RE-DELTA-006` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py delta --input /private/tmp/uk-kos-kos-fixtures-fix7/delta/UK-RE-DELTA-006-input.json` | `full` | `full` | none | all three keys | `true` | promotion history is not reused across a changed rule |
| `UK-RE-DELTA-007` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py delta --input /private/tmp/uk-kos-kos-fixtures-fix7/delta/UK-RE-DELTA-007-input.json` | `full` | `full` | none | all three keys | `true` | schema changes require complete contract validation and fresh review |
| `UK-RE-DELTA-008` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py delta --input /private/tmp/uk-kos-kos-fixtures-fix7/delta/UK-RE-DELTA-008-input.json` | `triggered` | `full` | all three keys | none | `true` | P-01 delivery facts must be freshly produced even when observations remain reusable |
| `UK-RE-DELTA-009` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py delta --input /private/tmp/uk-kos-kos-fixtures-fix7/delta/UK-RE-DELTA-009-input.json` | `triggered` | `full` | all three keys | none | `true` | D-01 final-validation facts must be freshly produced |
| `UK-RE-DELTA-010` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py delta --input /private/tmp/uk-kos-kos-fixtures-fix7/delta/UK-RE-DELTA-010-input.json` | `full` | `full` | none | all three keys | `true` | unknown paths cannot be classified as safe reuse or docs-only |
| `UK-RE-DELTA-011` | `python3 /private/tmp/universe-keyboard-kos-upgrade-uk-005/scripts/release/kos_release_evidence_adapter.py delta --input /private/tmp/uk-kos-kos-fixtures-fix7/delta/UK-RE-DELTA-011-input.json` | `delta` | `docs_only` | none | all three keys | `true` | stale evidence is invalidated even when the changed path is documentation-only |

The remediation delta cases extended the same matrix and all exited `0`:

| Fixture | Changed surface | Profile | CI tier | Reusable | Invalidated | Stop | Non-claim |
|---|---|---|---|---|---|:---:|---|
| `UK-RE-DELTA-012` | `docs/kos/release-evidence-profile.md` | `full` | `docs_only` | none | all three keys | `true` | Profile changes are release dependencies even when repository CI classifies the path as docs-only |
| `UK-RE-DELTA-013` | `.kos/project.json` | `full` | `docs_only` | none | all three keys | `true` | KOS machine-state changes cannot reuse evidence even when repository CI classifies the path as docs-only |
| `UK-RE-DELTA-014` | checklist + wrong claim | `full` | `full` | none | all three keys | `true` | wrong claim binding is fail-closed |
| `UK-RE-DELTA-015` | checklist + missing coverage | `full` | `full` | none | all three keys | `true` | missing coverage binding is fail-closed |
| `UK-RE-DELTA-016` | checklist + unknown scope | `full` | `full` | none | all three keys | `true` | unknown scope is fail-closed |
| `UK-RE-DELTA-017` | checklist + extra evidence field | `full` | `full` | none | all three keys | `true` | extra evidence data is not silently skipped |
| `UK-RE-DELTA-018` | `Keyboard/Views/KeyboardView.swift` | `triggered` | `full` | candidate identity | changed path, affected smoke | `true` | keyboard-boundary change expands affected evidence |
| `UK-RE-DELTA-019` | `source_owner` | `full` | `full` | none | all three keys | `true` | source-owner changes require full review |
| `UK-RE-DELTA-020` | `../escape.swift` | `full` | `full` | none | all three keys | `true` | unsafe path input invalidates every evidence key before reuse |
| `UK-RE-DELTA-021` | empty path list | `full` | `full` | none | all three keys | `true` | missing changed-surface coverage invalidates every evidence key before reuse |

The current rerun also covers these three newly added fail-closed bindings; each exited
`0` and is included in the `fix10` report:

| Fixture | Changed surface | Result | Non-claim |
|---|---|---|---|
| `UK-RE-DELTA-022` | `Universe Keyboard/Services/ReleaseEvidenceStore.swift` | `full`, no reuse, all three invalidated, stop `true` | the real Main-App source-owner path is a release dependency |
| `UK-RE-DELTA-023` | docs path with equal base/head | `full`, no reuse, all three invalidated, stop `true` | equal diff heads cannot justify reuse for a non-empty surface |
| `UK-RE-DELTA-024` | duplicate docs path | `full`, no reuse, all three invalidated, stop `true` | duplicate/ambiguous changed surface fails closed |

The delta matrix is the direct demonstration that a small change need not rerun every
release-evidence claim, while a candidate/binding/policy or proof-boundary change cannot
silently reuse stale or unrelated facts. Repository CI classification and release-
validation dependency policy are reported separately: docs and `.kos/**` may be
`docs_only` for CI, while Profile/KOS dependency changes still force a `full` release-
validation profile and stop before current proof.

## Main-App source-seam reconciliation

The executor read the existing Main-worktree implementation as an input only:

- `Universe Keyboard/Services/ReleaseEvidenceStore.swift` defines the Main-App-owned
  `ReleaseEvidenceFileStore`, the `ReleaseEvidenceExport` wrapper with
  `recordType = release_evidence_run`, `nonClaims`, and the camel-case `run` fields.
- The existing owner boundary remains ADR 0027's
  `Diagnostics/v1/release-evidence/records.json`; the Keyboard Extension does not own
  this store and no P1-A code reads or writes it.
- The adapter's fixture uses the same `recordType` and field names, accepts the bounded
  source pointer separately, and verifies that Main-App notes do not enter the Envelope.
- The adapter keeps `MAIN_APP_SOURCE_BINDING_STATE = unresolved` as a code-controlled
  gate. A caller-supplied binding flag cannot enable it; mapped pass observations are
  downgraded to `inconclusive` until the owner-attested `REP-Q-01` contract is reviewed.
- The Main-worktree implementation remains uncommitted and lacks the final exact
  implementation SHA/base-head/hosted provenance required by `REP-Q-01`. Therefore
  `SRC-MAIN-STORE` is reconciled as a source seam only, not promoted to current-proof
  provenance by this receipt; the current `fix10` report contains no adapter-generated
  current-proof result.

## Privacy, hot-path and authority checks

| Check | Result |
|---|---|
| Output allowlist | Pass: output contains bounded identity, digest, outcome, timestamp, pointer, receipt and derived-contract fields only. Fixture assertion confirms `note`, `nonClaims` and `raw_user_input` are absent from the Envelope. |
| Pointer boundary | Pass: `appdiag://`, `opaque://` and `repo://` pointers require SHA-256 and an explicit retention class; `repo://` uses canonical relative path segments only, `appdiag://` uses a canonical UUID, source identity is fixed to `SRC-MAIN-STORE`; a baseline must carry an explicit `;class=review-record` pointer; unresolved `UNKNOWN` is limited to permitted `not-run` fields. |
| Main-App ownership | Pass as a static boundary: no second store, no `records.json` write, no App Group access and no change to clear/retention semantics. Runtime/device proof is not claimed. |
| Keyboard Extension hot path | Pass as a static boundary: no Swift or Extension code changed; the Python adapter is invoked only by the release/evidence workflow and performs no runtime input handling. |
| Network/credentials | Pass as a static boundary: implementation imports only Python standard-library modules needed for bounded local JSON and subprocess work; it has no network client, credential, clipboard or user-text path. |
| Authority | Pass: the runner reports evaluator classifications only; it does not upload, assign testers, submit Beta Review, approve Product/Quality/Release, or mutate external state. |

## Non-claims and residuals

- The historical positive `current-proof` fixture cases only show that the pinned
  evaluator recognizes a structurally valid, fresh, bound synthetic Envelope. The
  current `fix10` adapter path intentionally emits no adapter-generated current-proof
  while `REP-Q-01` is unresolved. None of these fixtures is an actual Build 56 release,
  device run, archive, hosted CI run, Beta Review submission, TestFlight availability or
  Release Pass.
- `REP-Q-01` remains open for the actual Main-App implementation identity, final SHA,
  base/head and hosted provenance. The source seam is not a current-proof source until
  that residual is closed.
- `HOSTED-PROVENANCE` remains open for any later hosted tag/Release or CI relation.
- P1-B Main-App Diagnostics UI/storage, history migration, background sync, App Group
  changes and any new user-facing diagnostics feature remain outside this receipt.
- Swift-format was not run because no `.swift` file changed; the full local quality gate
  baseline did run KeyboardCore, RimeBridgeTests, Universe Keyboard simulator tests, and
  Debug/Release simulator builds as recorded above. The latest remediation reran the
  Python/fixture/static checks but did not rerun Xcode because no Swift or runtime file
  changed. Physical-device validation,
  performance/memory profiling, archive/export, App Store Connect, TestFlight, Beta
  Review, commit, push, merge, tag or Release action were not performed. Hosted CI and
  the owning human gates remain required before any later merge/push authorization.
- `CHANGELOG.md` was not changed: this slice changes release-process tooling and
  contract evidence, not shipped product behavior. The release checklist and adopter
  Profile were updated because their ownership/validation invariants changed.

## Handoff

Implementation package digest for fresh independent Architecture and Quality review:

```text
45afdbf879c6b0054790342861254abbc6d9cde846f61b43a160bd22064d0382
```

The earlier exact-digest reviews for `82a2061cf277ecf248d521f8f2f532ad404e84f6db8c677dd5d3877abc795242`
and `35a055a4341dbd77bb2aec74fbae7699449d23c700d7c8c226b0e693c385421d` remain historical
and do not transfer automatically. The current machine-readable fixture evidence is
`2398180e02bf7cf1338b773e0ebfd3920c98b477d3ef36b1d1798adda53b9a3c` for
`/private/tmp/uk-kos-kos-fixtures-fix10/report.json`. The fresh exact-digest independent
Architecture and Quality/Performance/Release reviews both passed:

- [Architecture r4 review](../reviews/KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-p1-architecture-final-exact-digest-review-2026-09-14-r4.md)
- [Quality/Release r4 review](../reviews/KOS-RELEASE-EVIDENCE-IMPLEMENTATION-001-p1-quality-final-exact-digest-review-2026-09-14-r4.md)

Review report SHA-256: Architecture `84dcf37713864c7e34de2ac7694d29bbf9cd08d7d8e1f0c6c20cb4e5139d4e31`;
Quality/Release `7f69f2d75e782366c5746868ae9270f49a0dc4fe76554352593b9400173a8efe`.

The reviews do not close `REP-Q-01`, hosted provenance, current-proof or publication
readiness, and do not authorize commit, push or merge.
