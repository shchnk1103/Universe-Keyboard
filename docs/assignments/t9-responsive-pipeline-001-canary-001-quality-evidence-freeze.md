# Quality Evidence Freeze: T9-RESPONSIVE-PIPELINE-001 / CANARY-001

| Field | Value |
|---|---|
| Contract ID | `T9-RESPONSIVE-PIPELINE-001/CANARY-001/QEF-01` |
| Contract version | `1.0.0` |
| Status | **Frozen — bounded build/test evidence activated 2026-08-03; physical device not authorized** |
| Date | 2026-08-03 Asia/Shanghai |
| Owner | Independent Quality, Performance & Release Maintainer `/root/canary_quality_review` |
| Parent Assignment | [`CANARY-001`](t9-responsive-pipeline-001-production-shaped-canary-001.md) |
| Architecture input | [`CANARY-001 Architecture design freeze`](t9-responsive-pipeline-001-canary-001-architecture-design-freeze.md) |
| Static inventory | [`CANARY-001 live-session API inventory`](t9-responsive-pipeline-001-canary-001-live-session-api-inventory.md) |
| ADR boundary | ADR 0004 Accepted; ADR 0025 remains Proposed |

Repository Change Type: `Contract` only. This record defines how future work is
proved. It does not authorize implementation, build, test, install, log capture
or device action.

The Product Lead subsequently activated only the frozen local build/automated
test matrix and Simulator on 2026-08-03. The exact immutable manifest and result
paths are frozen in the parent Assignment. This activation does not include raw
runtime logging, physical-device work, App Group/userdb cleanup, production
wiring, commit, push or Product Gate.

## 1. Purpose and evidence layers

The contract separates:

1. frozen product/architecture rules;
2. deterministic implementation evidence;
3. target/Simulator real-RIME evidence;
4. physical-device evidence;
5. Product/ADR/Release decisions.

Passing a lower layer never upgrades a higher layer. P2-PERF-03 is directional
predecessor evidence only. Its PAINT, Full Access, host/time, post-hoc tokenless
geometry, privacy-scope and small-sample residuals cannot be inherited as a
CANARY-001 pass.

Every future run uses a new `runID` and fresh opaque token. Data from different
runs, builds, destinations, schema identities, gate states or log windows must
not be combined. Invalid or blocked runs remain in history and are not overwritten
by a successful retry.

## 2. Two readiness gates

CANARY-001 avoids a circular requirement where implementation artifacts would
be required before implementation can begin.

### Implementation Ready (`I-Ready`)

Required before production/test code changes:

- Architecture design freeze cross-reviewed with no unresolved P0/P1;
- live-session API inventory classified or an explicit implementation allowlist
  showing how every unresolved entry will be closed;
- marker, validator, privacy, geometry and restore **schemas** frozen by ID,
  required fields, reason enums and fail-closed rules;
- exact changed-file allowlist and preservation rule for ambient worktree dirt;
- executable design/test mapping for every known API-P1 and public ObjC entry;
- default-off baseline definition and ordinary restore artifact source defined;
- deterministic test matrix and build/Simulator command families defined without
  hardcoded destination or test-count claims;
- independent Architecture/Quality roles preserved.

Schema/source SHA values that cannot exist before implementation are marked
`pending-implementation`, not fabricated.

### Evidence Capture Ready (`E-Ready`)

Required after implementation and independent code review, before any target or
run evidence is captured:

- final source and changed-file fingerprint;
- independent API inventory re-audit against the final implementation diff;
- actual marker/validator/privacy/geometry/restore artifact versions and source
  SHA values;
- immutable command manifest and discovered destination identity;
- implementation-focused and baseline verification results accepted for entry;
- frozen run header, privacy scope/quarantine, archive destination and restore
  artifact hashes;
- no unresolved P0/P1 and no mismatch with the Architecture freeze.

Physical-device capture adds its own Product activation, Environment/Human
acknowledgement and immutable device envelope.

## 3. Run header

Before any `ACCEPT`, every run binds one content-free `RUN_HEADER`:

| Category | Required fields |
|---|---|
| Contract | contract ID/version; runID; fresh token; phase; fixture ID/version/digest; marker schema |
| Source/build | full source SHA; tracked/untracked fingerprints; worktree state; configuration; all injected conditions; evaluated enable/kill values; App/Extension executable SHA-256 |
| Environment | target type; Simulator model/UDID/runtime or approved opaque device ID; OS; Xcode/SDK/Swift; RIME artifact/schema/deployment-health identity; Main-App deployment/maintenance/probe state; start/end/timezone/log window |
| Access/host | Full Access `observed(on/off)` or `unavailable(reason)`; opaque host/container identity or `unavailable(reason)` |
| Geometry | pre-input normalized tokenless digest; prepared/execution tokenized digests; geometry schema/version |
| Tools/restore | command-manifest hash; validator ID/source SHA/schema; privacy scanner/allow-list version; ordinary restore package hashes; archive/manifest identity |

Full Access, host, time, geometry, destination, flags and hashes are current-run
facts. They cannot be inherited from P2 or another arm. `Unavailable` remains a
blocking/partial observation according to the matrix; it is never replaced by
operator recollection.

## 4. Versioned schema contracts

| Artifact | Frozen specification |
|---|---|
| Marker | `T9RESP-CANARY-MARKERS-v1`: field list, required/optional rules, transition/terminal reason enums, prohibited fields, schema hash |
| Validator | `T9ResponsiveCanaryEvidenceValidator`: input manifest, failure codes, machine-readable reasons, source SHA after implementation |
| Privacy | `T9RESP-CANARY-PRIVACY-v1`: scanner/allow-list version, scope manifest, quarantine and publication rules |
| Geometry | `T9RESP-CANARY-GEOMETRY-v1`: canonical field order, token exclusion and pre-input binding |
| Restore | `T9RESP-CANARY-RESTORE-v1`: ordinary package identity, replacement order, gate verification and bounded smoke |

The implementation phase may refine concrete encoding without weakening these
semantics. Any field/removal/reason change after `E-Ready` requires a new schema
version and runID.

## 5. Retention and privacy

Retained repository evidence may contain only:

- content-free marker subset;
- run header and manifest/hash;
- validator/privacy summary;
- reviewed performance aggregates;
- content-free Human integrity/subjective report when separately activated.

It must not contain raw input, pinyin, candidates, committed or host text,
screenshots, UI hierarchy, userdb content or unfiltered diagnostic export.

The scanner records the exact retained scope. A token-subset pass never means
the raw attachment passed. Scanner hit, unrepeatable scanner, unknown scope or
quarantine failure blocks publication; retain only content-free incident
metadata, digest, time and owner.

## 6. Runtime and terminal receipts

Required identity on runtime markers includes `runID`, `modeGeneration`,
`sessionEpoch`, `revision` where applicable, fixture and schema version.
Transition receipts additionally share the exact key
`{runID, modeGeneration, fenceID, canarySessionInstance}`.

```text
ACCEPT
  -> owner terminal / PUBLISH
      -> VISIBILITY_DISPOSITION
          -> PAINT_TERMINAL
```

### Accepted-action terminal

Every `ACCEPT` has exactly one ACCEPT terminal:

| ACCEPT terminal | Required execution/publication | Required presentation accounting |
|---|---|---|
| `published` | work executed and exactly one `PUBLISH(completion=published)` | exactly one visibility disposition and matching PAINT terminal |
| `staleAfterFence` | work executed FIFO and exactly one `PUBLISH(completion=staleAfterFence)`; payload rejected from UI/host | exactly one `notVisible(fencedBeforeVisible)` and one `failed(fencedBeforeVisible)` |
| `abandonedVisibility` | ADR 0002 visibility exit only; execution not required and no PUBLISH | no PAINT terminal; complete at ACCEPT layer |

A future enum value requires Product + Architecture contract revision. A
PUBLISH-less `published`/`staleAfterFence`, or a fabricated PUBLISH/PAINT for
`abandonedVisibility`, is a contract failure.

Explicit kill does not permit cancellation: it fences new acceptance and drains
the existing accepted FIFO. Timeout yields transition failure/
`FencedUnavailable`, not a cancellation or baseline-recovery pass.

### Presentation terminal

Every `PUBLISH`, keyed by `{runID, modeGeneration, sessionEpoch, revision}`, has
exactly one visibility disposition and exactly one `PAINT_TERMINAL`:

| Visibility disposition | Canonical VISIBLE count | Required PAINT terminal |
|---|---:|---|
| `visible(presentationRevision)` | exactly 1 | `painted` or bounded `failed(reason)` |
| `notVisible(coalescedInto: replacementRevision)` | 0 | `coalesced(absorbedRevisionRange, replacementRevision)` |
| `notVisible(fencedBeforeVisible)` | 0 | `failed(fencedBeforeVisible)` |

The PAINT terminal enum is therefore:

- `painted`
- `coalesced(absorbedRevisionRange, replacementRevision)`
- `failed(reason)`

Missing, duplicate, cross-epoch, unbounded reason or coalesced-without-range
terminal makes Presentation `Blocked`. It does not erase an independently valid
owner-completion result.

Repeated UIKit layout/display callbacks do not create additional canonical
VISIBLE markers. A revision with an existing PAINT terminal cannot later be
reclassified `staleAfterFence`. The validator rejects any PUBLISH with zero or
multiple visibility dispositions, any disposition/PAINT mismatch, and any
`abandonedVisibility` carrying PUBLISH, VISIBLE or PAINT.

### Transition terminals

Every canary exit records:

- fence identity and accepted-through watermark;
- owner-destroyed result;
- mailbox terminal;
- delivery-drained terminal;
- baseline recovery start and success/failure;
- `FencedUnavailable` reason when any positive terminal is missing.

Timeout is never rewritten as successful destruction.

The positive order is
`ownerDestroyed -> mailboxTerminal -> deliveryDrained -> baselineRecoveryStarted`.
Each receipt must match the same transition key. Missing, duplicate,
out-of-order or mismatched receipts enter `FencedUnavailable` and prohibit
baseline creation.

Abrupt process death records `RUN_TERMINAL=processTerminated` when observable.
That run cannot pass drain, restore or baseline-recovery gates. A later fresh
process may provide a separately identified clean-start lifecycle observation;
it cannot retroactively complete the terminated run.

## 7. Layered evidence matrix

| Layer | Minimum proof | Blocking result |
|---|---|---|
| Contract/preflight | complete header/schema pins/allowlist/command manifest/restore identity; no mixed run | run does not start |
| Gate-off | ordinary Release has no compiled/reachable canary capability; internal artifact absent, invalid, corrupt, expired and pre-start kill config resolves to ADR 0004 | default-path claim blocked |
| Single owner | inventory covers all create/read/write/reset/recover/suspend/resume/destroy paths as same-owner/fail-closed | owner safety blocked |
| Ordering/capacity | accepted FIFO; refusal before ACCEPT; bounded depth; control not starved | ordering/capacity blocked |
| Kill/lifecycle | pre-start kill creates no owner; active kill fences/drains; idle, queued, in-flight, active composition, owner-not-ready, timeout, visibility, process death and teardown reach their frozen terminal states | kill/lifecycle blocked |
| Presentation | complete one-to-one PUBLISH to PAINT_TERMINAL accounting | presentation blocked |
| Privacy/provenance | scanner covers actual retained scope; all header fields current-run observed/unavailable/contradicted | affected claim partial/blocked |
| Restore | canary teardown, ordinary replacement, hashes, gate-off identity and bounded smoke | closure blocked |
| Physical device | separate Product activation, Human report, Full Access/host and immutable device header | `NotRun` until activated |

No latency or memory pass/fail threshold is defined. If performance data is
later collected, report sample count, median, worst observed, cold/warm state and
confounds under the same environment. One favorable result, P2's sub-millisecond
immediate path or a subjective score is not an SLO.

## 8. Deterministic matrix required for I-Ready

The implementation plan must map tests to at least:

- ordinary default-off and every invalid/expired/kill configuration;
- ordinary Release compile/runtime unreachability and internal-artifact
  runtime fail-closed behavior;
- baseline-to-canary and canary-to-baseline exclusive transitions;
- owner start failure and positive destruction requirements;
- explicit kill while idle, queued and in-flight;
- ADR 0002 visibility abandonment and clean resume;
- timeout to `FencedUnavailable` without baseline takeover;
- accepted FIFO, pre-accept bound refusal and control behavior;
- Delete, replace/Path, candidate/global selection, paging, reset/recover and
  session-dependent reads;
- implicit processKey session recreation;
- stale mode/epoch/revision delivery rejection;
- one owner terminal per ACCEPT and one presentation terminal per PUBLISH;
- exactly one visibility disposition per PUBLISH, with the frozen VISIBLE count
  and disposition/PAINT pairing;
- typo-correction sidecar fail-closed behavior;
- reversible auto-anchor suppressed/fail-closed before live access;
- ObjC public highlight/current-output/commit entry compile/runtime fail-closed
  behavior and static direct-call prohibition;
- Main-App maintenance/probe overlap classification;
- privacy/manifest/parser failure and restore-state classification.

Test names and exact counts are not frozen in this contract.

## 9. Command manifest

Before any build/test/install/log action, Quality publishes an immutable
command manifest. Each command records:

```text
commandID / exact argv / workdir / source SHA / build configuration /
injected conditions / scheme / destination-discovery output hash /
chosen destination or generic target / expected artifacts /
Environment Executor / restore boundary
```

Rules:

- discover installed Simulator destinations before selecting one;
- run real bridge contracts through iOS Simulator `RimeBridgeTests`, not direct
  macOS SwiftPM RimeBridge tests;
- choose KeyboardCore, app/Extension and strict Swift 6 commands from the final
  changed-file allowlist;
- results from commands outside the manifest cannot fill the matrix;
- rebuild, reinstall, destination/OS/schema/gate/host/access change creates a
  new run identity where the evidence template requires it;
- physical-device commands remain absent until separately activated;
- third-party physical keyboard input remains Human + content-free diagnostics,
  never coordinate automation.

## 10. Capacity, lifecycle and restore observation

- Architecture freezes mailbox depth before evidence; Quality verifies accepted
  FIFO below it, reasoned pre-accept refusal at it and non-starved control.
- Record queue high-water, refusal, control dispatch, memory trend before/after
  fixed bursts and unexplained termination. Do not infer a leak or budget from
  one sample.
- Lifecycle matrix covers Delete, Path/replace, selection/page, reset/recover,
  visibility and process teardown, not only `processKey`.
- Restore never wipes App Group, userdb or host data. It replaces with the
  identified ordinary package, verifies bundle hashes and gate-off bounded smoke.
- Restore smoke is not full lifecycle, jetsam, Release or Product Gate evidence.

## 11. Quality stop conditions

Stop before or during evidence when:

- Assignment phase, Environment Executor or required input is unavailable;
- header/schema/manifest/restore identity is incomplete;
- source/build/destination/run scopes would be mixed;
- raw/private content appears or scanner scope is uncertain;
- owner/transition/presentation terminal accounting is incomplete;
- a tool failure is being treated as observed absence;
- a lower layer is being promoted to device/Product/Release proof;
- a numeric SLO or accepted cancellation is invented from the evidence;
- independent review would require self-review by Executor/Environment Executor.

## 12. Quality disposition

This contract passed independent Architecture cross-review with no P0/P1 and is
frozen for I-Ready. It does not make CANARY-001 `E-Ready`, authorize a run or
promote any evidence layer. Implementation-produced schemas/hashes, final API
re-audit and immutable command manifest remain later E-Ready conditions.

## 13. Frozen implementation and evidence boundaries

The exact maximum source/test allowlist and ordinary Release comparison identity
are frozen in Architecture design freeze §11. Quality adopts that allowlist;
any additional source invalidates `I-Ready` until both independent reviewers
revalidate it.

At `I-Ready`, source identity is the current inventory snapshot plus that
allowlist and the executable closure mappings in Architecture §7. Implementation-
produced source SHA, changed-file fingerprint, executable hashes, restore hashes
and final-diff API re-audit are `E-Ready` inputs. They must never be guessed or
required circularly before implementation exists.
