# RIME-BUILTIN-LUNA-QUALITY-001 — Architecture & Knowledge Steward Review

**Review date:** `2026-08-29 Asia/Shanghai`
**Reviewer:** Architecture & Knowledge Steward (independent review)
**Evidence grade:** This is an Architecture review, not a `Quality-reverified`
or `Device-attested` validation result.
**Assignment:** [`RIME-BUILTIN-LUNA-QUALITY-001`](rime-builtin-luna-quality-001.md)

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | Assignment `Active`; this review is not the Assignment SoT |
| **Phase** | Independent Architecture re-review of PR #93 HEAD `ecd3446` complete |
| **Verdict** | **Architecture `Pass with conditions` for the Human Product Gate packet.** KOS P1 freeze residual is closed. Merge, Exit, TestFlight and Release remain Human/Quality authorities. |
| **Non-claims** | No merge, Assignment Exit, TestFlight, Release, legal acceptance, or OpenCC four-profile/Stroke reverse-lookup closure |
| **PR boundary** | PR [#93](https://github.com/shchnk1103/Universe-Keyboard/pull/93) HEAD `ecd3446` includes merged `origin/main` (historical PR #91 already on `main`). This review inspected the F-02 overlay-authorization guard after that merge; it does not re-open RIME-SYNC-001 |
| **Next handoff** | Human Product Owner: Product Gate on remaining residuals. Coordinator does not infer merge |
| **Residuals** | See [HEAD `ecd3446` re-review](#independent-architecture-re-review--ecd3446--2026-09-03) |

> **S-03:** The 2026-08-29 `Pass for Ready` and the 2026-09-02 KOS-consistency P1 describe earlier phases. They are not current merge-packet truth.

This review does not change the Assignment lifecycle or authorize
implementation. The original pre-ADR `Pass with conditions — not Ready`
interpretation is superseded by the [Architecture follow-up addendum](#architecture-follow-up-addendum--adr-0033-and-lifecycle-correction):
design readiness is separated from implementation/Exit evidence. Candidate
upstream pins and the existing minimal bundle are still not accepted production
assets.

## Task Boundary and Required Sources

The review follows the RIMEBridge playbook sequence:

`Task Boundary` → `Observed RIME State` → `Bridge Evidence` → `Verification` →
`Extension Safety` → `Residual Risk`.

The governing sources were read before this conclusion:

- [Assignment](rime-builtin-luna-quality-001.md), [official runtime-closure Product Decision](../product-decisions/RIME-BUILTIN-LUNA-QUALITY-001-official-runtime-closure.md) and [Assignment bindings Product Decision](../product-decisions/RIME-BUILTIN-LUNA-QUALITY-001-assignment-bindings.md)
- [F-02 reproduction/resource audit](../evidence/rime-builtin-luna-quality-f02-2026-08-29.md) and [upstream pin/manifest audit](../evidence/rime-builtin-luna-quality-f02-upstream-pin-audit-2026-08-29.md)
- [RIMEBridge playbook](../playbooks/rime-bridge.md), [Context Scout playbook](../playbooks/context-scout.md), [shared-container lifecycle](../architecture/shared-container-and-rime-lifecycle.md), and [OpenCC integration](../architecture/opencc-integration.md)
- ADR [0001](../architecture/decisions/0001-main-app-owns-rime-deployment.md), [0003](../architecture/decisions/0003-shared-container-ownership.md), [0004](../architecture/decisions/0004-rime-runtime-session-model.md) and [0008](../architecture/decisions/0008-fallback-engine-product-semantics.md)
- [RIME binary artifacts](../architecture/rime-artifacts.md), [documentation governance](../DOCUMENTATION_GOVERNANCE.md), [KOS 2.1 operational maturity](../kos/kos-2.1-operational-maturity.md) and [KOS upgrade status](../kos/UPGRADE_STATUS.md)

The Product Decisions authorize the selected offline closure and task
responsibilities. They do not authorize implementation, a resource download,
PR #91 action, Octagram expansion, merge or release.

## Executive Verdict

| Review question | Result | Binding condition |
|---|---|---|
| Official Luna/Essay/Prelude/Stroke/OpenCC closure | **Pass with conditions** | Materialize one exact dependency graph and distinguish direct, retained, optional and prohibited assets; record generated outputs and notices |
| `OpenCC@25350017` compatibility with the current vendor | **Pass with conditions** | Treat it as the compatibility boundary, not yet as a production acceptance; record the exact generator/toolchain and output receipts |
| Move built-in resources from `Keyboard.appex` to the main App | **Pass with conditions** | Make the main App the sole bundled source and prove the Extension has no duplicate deployable copy |
| Official bytes plus thin custom overlay | **Pass with conditions** | Keep upstream bytes immutable; move product behavior to bounded custom overlays and correct the official switch path |
| Prebuilt versus source compilation | **Pass with conditions** | Prefer one reproducible prebuilt release path; source-only is allowed only after fresh-device latency/recovery evidence |
| Octagram | **Pass** | Preserve capability-only G1; no `.gram`, grammar patch, model or TD-012 reopening |
| New ADR | **Required before `Ready`** | Record the durable source-of-truth, cross-target ownership and generation strategy in a new ADR; do not rewrite accepted ADRs |

The architecture is therefore viable, but the current repository state is not
Ready: the checked-in resource set is a smaller historical closure, generated
receipts are incomplete, and the current deployment path still reads sources
from the Extension bundle.

## Task Boundary

### In scope

1. One offline, license-complete, hash-verifiable built-in `luna_pinyin`
   closure rooted in the pinned official Luna, Essay, Prelude and Stroke
   sources and the enabled OpenCC profiles.
2. A single immutable source copy owned by the main App, with deployment into
   the existing App Group and runtime consumption by the Extension.
3. A thin Universe iOS overlay for the shipped schema list, product defaults,
   platform bindings and managed fuzzy behavior.
4. A deterministic decision about shipped prebuilt artifacts versus on-device
   source compilation, including a fail-closed recovery path.
5. Notices, source attribution, manifest receipts and offline/fresh-container
   acceptance evidence.

### Out of scope

- PR #91 and its merge/lifecycle state.
- Downloadable third-party schemes, Rime-ice, Wanxiang, T9, sync changes or
  unrelated candidate-ranking redesign.
- Adding an Octagram model, `.gram` file, `grammar.language` configuration or
  a user-facing grammar feature.
- Moving full deployment, repair, hashing, downloads or maintenance into the
  Keyboard Extension.
- Treating fallback candidates, simulator smoke or successful deployment as
  proof of real-RIME candidate quality.

## Observed RIME State

The current evidence supports the following facts:

- The physical-device result is `Device-attested` for iPhone 13 Pro,
  iOS `27.0 (24A5424a)`, on a local development build. `sanjiaoxing` can
  produce `三角形`, but the normal `ni`/`nihao` candidates are polluted by rare
  characters. This is not a Quality re-run and does not close the historical
  Build 7 claim.
- The read-only repository/resource audit is `Executor-recorded`: the current
  full deployment can compile a broad dictionary without `essay.txt`, and the
  observed `ni` order begins with rare characters before `你`. This establishes
  a credible functional cause for the present candidate-quality defect.
- The current checked-in Luna dictionary/schema and binaries are not the
  selected official revisions. In particular, the current dictionary is
  `282450` bytes while the selected official Luna dictionary is `889896` bytes;
  the current source set has no `essay.txt`, `pinyin.yaml` or Stroke closure.
- The current resource root is `Keyboard/Resources`, which is filesystem
  synchronized into `Keyboard.appex`. `SchemaArchiveInstaller` reaches into
  that embedded bundle when the main App prepares deployment. This is an
  implementation fact to be corrected by the bounded ownership migration, not
  a reason to add another copy to the Extension.
- The current deployment path can write a text fallback under a missing binary
  `.bin` or `.ocd2` name. That behavior is incompatible with a verifiable
  closure and must fail before reporting deployment success.

These facts are sufficient to accept the repair direction, but not to accept a
particular generated table or an installed device artifact.

## Dependency Closure Review

The accepted closure is the selected official Luna product path, not the whole
RIME preset catalog. A source is required because it is reachable from the
enabled schema/configuration or because the Product Decision explicitly keeps
the shared capability; it is not required merely because it exists upstream.

| Layer | Required closure | Classification and review rule |
|---|---|---|
| Entry schema | Pinned official `luna_pinyin.schema.yaml` and the one selected Luna entry schema | Required. Preserve the upstream schema ID and record the exact selected file; unselected Luna variants remain out of scope unless Product adds them |
| Luna core | `luna_pinyin.dict.yaml`, `pinyin.yaml` | Required, from the same Luna revision. Do not retain the old hand-authored/minimal schema as a second Source of Truth |
| Preset weighting | Pinned official `essay.txt` | Required. It is the normal preset vocabulary input and must be available on first offline deployment; no “download if missing” path is allowed |
| Prelude | `default.yaml`, `key_bindings.yaml`, `punctuation.yaml`, `symbols.yaml` | Required for the official imports used by the selected schema. Keep them byte-identical; use a custom overlay to narrow `schema_list` and adapt product behavior |
| Stroke | `stroke.schema.yaml`, `stroke.dict.yaml` and its generated outputs where produced | Required while Luna retains its dependency/reverse lookup. The Stroke dictionary also declares preset vocabulary, so the same Essay input must participate in its generation |
| OpenCC | Enabled profile configs and reachable data: T2S, T2HK, T2TW; retained S2T capability and its data while the shared runtime exposes it | Required by enabled/retained capability. The manifest must label direct Luna references separately from retained shared capability; removal of S2T is a Product capability decision, not an optimization |
| Generated RIME | `luna_pinyin.table.bin`, `luna_pinyin.prism.bin`, `luna_pinyin.reverse.bin`; corresponding Stroke outputs if produced | Required only for the prebuilt strategy. Every output needs generator identity, inputs, byte length and SHA-256; source-only must explicitly omit and compile deterministically on-device |
| Generated OpenCC | Six selected `.ocd2` outputs for TSPhrases, TSCharacters, HKVariants, TWVariants, STPhrases and STCharacters | Required for the corresponding configs. Source-input hashes do not stand in for generated-output hashes |
| Runtime configuration | `installation.yaml`, bounded `default.custom.yaml`, `luna_pinyin.custom.yaml` and any intentionally generated config | Generated/runtime state, not upstream source. It must have ownership and invalidation rules and must not mutate the official source bytes |
| Notices and receipts | Licenses, AUTHORS/attribution and source/package manifest | Required. Luna-only notice coverage is insufficient for Essay, Prelude, Stroke, OpenCC and incorporated data |
| Official variants/catalog | Fluency, simplified, Taiwan, quanpin and unrelated Prelude preset schemas | Not required for the selected product unless their schema IDs are registered and their complete closures are bundled and tested |
| Grammar/Octagram model | `*.gram`, grammar patch or user-facing grammar configuration | Prohibited by this Assignment. Keep the already linked module at capability-only G1 |

### Closure completeness finding

The official dependency classification is complete enough to proceed with
implementation planning, but the closure is not yet materialized as an
accepted production manifest. In particular, the final manifest must state:

- the selected schema IDs and every active `dictionary`, `import_preset`,
  `__include`, `__patch`, OpenCC and runtime-module edge;
- whether each OpenCC file is directly referenced by Luna or retained for the
  shared runtime;
- the expected presence/absence of every generated RIME and OpenCC output;
- why unselected official schema variants and grammar assets are absent; and
- a zero-network first-run proof from an empty App Group.

The candidate revision set being reviewed is the immutable set recorded by the
upstream audit: Luna `56b934b099dfbeab842320f13aa8b461a6ab3e42`, Essay
`e9b1a374a6ea015fca5bdd04318924b4483ac35a`, Prelude
`082425ea0684bca36474415d4a0e8db9b016487e`, Stroke
`1e8fff9b9494ddec23b0cbc526bcfd8171a6fd48`, OpenCC
`25350017e81b40aa9e3e66c18446b57f83b0607d` and the existing librime vendor
pin `1300e568967feeeedd72028c7cb5ef9151f7fb37`. These remain candidate inputs
until the residual receipts and independent review close.

The expected runtime edges are also bounded: the selected Luna schema resolves
its Luna dictionary and `pinyin.yaml`, imports the selected Prelude presets,
uses Stroke for reverse lookup, and resolves each enabled simplifier profile to
the pinned OpenCC config/data. Luna and Stroke dictionaries both require the
preset-vocabulary input. The final effective `default.custom.yaml` must replace
the upstream catalog's unsupported schema list rather than append to it; an
unbundled schema reference is a closure failure.

## OpenCC Pin and Compatibility

### Decision

`BYVoid/OpenCC@25350017e81b40aa9e3e66c18446b57f83b0607d` is an acceptable
compatibility boundary for this Assignment because the existing byte-recovered
`libopencc` source receipt is tied to that revision. The recovered device
archive is recorded as `488aa4c7ba4714f056bc5dbf350c8ca1b93a724db0f2a986984d02d77a9d9500`,
while the existing complete vendor archive remains
`d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`.

This is a compatibility pin, not an assertion that all future data files or
generated outputs have already been accepted. The current upstream
`OpenCC@26753884…` changes the JSON/data closure, including additional
normalization/dictionaries. Mixing those files with the current vendor would
be an unreviewed toolchain/data upgrade.

### Required proof before `Ready`

1. Record the exact OpenCC generator binary or source revision, build recipe,
   host/toolchain identity and command line.
2. Generate the six selected `.ocd2` outputs from the pinned text inputs and
   record each output's byte length and SHA-256 in a separate receipt.
3. Prove each enabled config resolves only to packaged data and succeeds with
   the shipped `libopencc` on the iOS device/simulator slices covered by the
   vendor contract.
4. Keep any later OpenCC upgrade atomic across binary, generator, configs and
   all referenced dictionaries; it requires a new review and source receipt.

The source hashes in the upstream audit are necessary provenance but are not
generated-output hashes and cannot close this condition.

## Main-App Resource Ownership

### Existing state

The architecture already says that only the main App prepares persistent RIME
resources and calls full deployment (ADR 0001/0003). The current source layout
violates the intended single-source packaging boundary by placing the immutable
input files under the Extension's synchronized `Keyboard/Resources` root and
having the main App discover that embedded bundle.

### Accepted target state

- The main App owns one bundled immutable RIME resource directory (or a
  dedicated resource bundle referenced only by the main App target).
- The main App validates, stages and deploys those bytes into `Rime/shared`;
  generated custom overlays and user/runtime data retain the ownership rules
  in ADR 0003.
- The Keyboard Extension carries no duplicate deployable RIME source, schema,
  Essay, OpenCC or generated table copy. It resolves only the prepared App
  Group directories, creates or recovers a process-local session, and processes
  input.
- A failed/missing/corrupt source or generated asset stops before deployment
  success and preserves the last known good state. It must not write a text
  placeholder with a binary extension.

### Required ownership evidence

The implementation must show target membership and built-product inspection
for both `.app` and `.appex`, verify that only the `.app` has the deployable
source copy, and record the deployed file hashes. The target migration is a
durable cross-target ownership change; it is not closed by changing a path in
one Swift function.

## Official Bytes and Thin Overlay

### Accepted model

The official YAML/JSON/text inputs remain byte-identical to the selected pinned
upstream revisions. Universe behavior is expressed in small, named custom
overlays, principally:

- `default.custom.yaml`: register only built-in and actually installed
  optional schemas, product page/default settings and supported platform
  bindings;
- `luna_pinyin.custom.yaml`: managed fuzzy rules, simplification choice and
  other explicitly owned Luna behavior; and
- additional schema-specific custom files only when an enabled schema requires
  them and their ownership is recorded.

The overlay may narrow an upstream preset catalog, but may not copy/fork the
full official files or silently replace their dictionary content. Source hashes
must remain valid after deployment because product changes live beside the
source, not inside it.

### Concrete incompatibility to fix

The current minimal schema writer assumes the simplification switch is at
`switches/@1`. The selected official Luna schema uses the `zh_hans` switch at
`switches/@2`. The implementation must use a named/verified path or a
schema-aware patch and compile-test the effective configuration. A fuzzy patch
must likewise stop post-processing the official schema in place.

The test must prove both fuzzy-on and fuzzy-off exact spelling, including
`ni → 你`, `nihao → 你好` and `sanjiaoxing → 三角形`; a successful “some Han
character” result is insufficient.

## Prebuilt versus Source Compilation

### Architecture recommendation

Use prebuilt RIME dictionary artifacts as the first-run release strategy,
provided they are generated from the exact selected Luna/Essay/Stroke closure
with the iOS-compatible pinned toolchain and carry a complete generator
receipt. This gives the smallest and most predictable first keyboard startup.

The source-only strategy remains architecturally allowed, but only after the
fresh-device gate measures first deployment time, memory/latency, interruption
recovery and failure rollback on the supported device matrix. Source-only is
not a way to avoid recording artifact provenance.

### Non-negotiable generation rules

- The source dictionary, Essay input, schema and any prebuilt `table/prism/reverse`
  output are one generation; stale binaries cannot silently survive a source
  change.
- If both source and prebuilt files ship, the manifest must identify one source
  of truth, validate compatibility and define cache invalidation. There may not
  be two independent runtime authorities.
- A macOS/Homebrew or otherwise unproven host output cannot be called iOS
  compatible merely because librime can read the file format. The output must
  be tied to the pinned iOS vendor/toolchain and verified in the actual runtime.
- If a required asset is missing, deployment fails closed and retains the last
  known good state; it must not compile a text fallback under a binary name.

The existing minimal binaries are therefore not reusable as acceptance
evidence for the selected official closure until their inputs and generation
receipt match it.

## Verification and Extension Safety

### Required verification sequence

The Quality handoff should independently check, with explicit evidence grades:

1. `Executor-recorded`: immutable source/package manifest, generator receipts,
   license/attribution closure, target membership and built-product inventory.
2. `Quality-reverified`: clean isolated build/deploy, table/config identity,
   OpenCC profile resolution, candidate-order fixtures, missing/corrupt asset
   fail-closed behavior and last-known-good preservation.
3. `Device-attested`: named physical device/OS/build, Full Access off/on,
   Extension restart, offline fresh deployment and exact candidate results.

The independent Quality review must not convert the current human screenshots
or simulator smoke into a re-run claim.

### Extension safety invariant

The Extension must receive a prepared, coherent App Group state. It may create
or recover its process-local RIME session, but it must not deploy, download,
repair, hash, scan or replace persistent resource files in the input path. The
main App remains the only full-deployment writer. Fallback behavior remains a
degraded mode under ADR 0008 and cannot mask an incomplete built-in closure.

## Octagram / G1 Boundary

**Pass.** The existing vendor set includes `librime-octagram`, and G1 is the
capability/module-registration proof already recorded in
[RIME artifacts](../architecture/rime-artifacts.md) and the TD-012 G1 evidence.
F-02 does not need to alter that artifact set.

The accepted implementation must continue to prove:

- the module can be registered/discovered;
- no `.gram` model is bundled, downloaded or deployed;
- no `grammar.language` or optional `grammar:/hant?` path is activated by the
  selected product overlay; and
- no user-facing grammar/“整句增强” feature is implied.

Changing the vendor, adding a grammar model, or re-opening TD-012 G2–G6 is a
separate Product Decision and is prohibited in F-02.

## ADR Disposition

**A new ADR is required before implementation enters `Ready`.** This work
introduces a durable choice among viable source/generation strategies and a
cross-target/persistent resource ownership boundary. The OpenCC integration
Source of Truth explicitly requires ADR review for this ownership change, and
the documentation governance rules require an ADR for long-term architecture,
RIME/OpenCC strategy and cross-target lifecycle decisions.

The new ADR should record, at minimum:

- the selected official dependency closure and the rule for direct versus
  retained OpenCC capability;
- main-App ownership and the no-duplicate Extension contract;
- official-byte-plus-thin-overlay Source of Truth and overlay invalidation;
- prebuilt/source generation strategy, receipts and failure/rollback boundary;
- license/notice and manifest ownership; and
- alternatives rejected, especially the old minimal schema, Extension-owned
  sources, unverified macOS-generated binaries and a full upstream preset
  catalog.

The Coordinator/Architecture owner should allocate the next available ADR
number. ADR 0001, 0003, 0004 and 0008 remain valid; this review does not edit or
silently supersede them. ADR 0006's future atomic install/rollback requirement
also remains open and is not claimed solved by F-02.

## Architecture Residuals

The initial review tracked the following as `fix` residuals without yet
separating design-entry work from implementation/Exit evidence. The lifecycle
classification is corrected and superseded by the [Architecture follow-up
addendum](#architecture-follow-up-addendum--adr-0033-and-lifecycle-correction)
below; no residual is being silently accepted as a Product or legal exception.

| Residual ID | Owner | Disposition | Pointer / required closure |
|---|---|---|---|
| `AR-F02-01` | Domain Owner + Executor | `fix` | [upstream audit](../evidence/rime-builtin-luna-quality-f02-upstream-pin-audit-2026-08-29.md): materialize the exact dependency graph and selected schema IDs |
| `AR-F02-02` | Domain Owner | `fix` | [upstream audit](../evidence/rime-builtin-luna-quality-f02-upstream-pin-audit-2026-08-29.md): add deterministic RIME and six OpenCC generated-output receipts with byte lengths/hashes |
| `AR-F02-03` | App & Data Operations + Executor | `fix` | [shared-container lifecycle](../architecture/shared-container-and-rime-lifecycle.md): make main App the sole bundled source owner and prove no Extension duplicate |
| `AR-F02-04` | Domain Owner + Executor | `fix` | [upstream audit](../evidence/rime-builtin-luna-quality-f02-upstream-pin-audit-2026-08-29.md): replace in-place schema mutation and `switches/@1` assumption with tested overlays |
| `AR-F02-05` | Domain Owner + Quality | `fix` | [RIME artifacts](../architecture/rime-artifacts.md): choose/receipt one prebuilt or measured source-only generation path; reject stale/mismatched binaries |
| `AR-F02-06` | App & Data Operations + Product/notice owner | `fix` | [upstream audit](../evidence/rime-builtin-luna-quality-f02-upstream-pin-audit-2026-08-29.md): add Essay, Prelude, Stroke, OpenCC and incorporated-data notices/attribution |
| `AR-F02-07` | Domain Owner + Quality | `fix` | [Assignment exit criteria](rime-builtin-luna-quality-001.md): fresh empty-container/airplane-mode, fail-closed/last-good and exact candidate-order evidence |
| `AR-F02-08` | Architecture/Coordinator | `fix` | [documentation governance](../DOCUMENTATION_GOVERNANCE.md): accept the new ADR before `Ready`; retain Octagram at G1 only |

KOS 2.1 M-03 is satisfied by assigning an owner, an explicit `fix`
disposition and a source pointer to every residual. The Assignment cannot be
closed while any required receipt or review condition is merely described as
“planned.”

## Allowed Design Space

The implementation may choose among the following without reopening Product
scope, provided the residuals close:

- a dedicated main-App resource bundle or an equivalent main-App-owned
  filesystem-synchronized resource directory;
- deterministic prebuilt RIME tables or source-only first deployment, subject
  to the generation and fresh-device evidence gates;
- named `.custom.yaml` overlays or schema-aware indexed patches, provided they
  preserve official source bytes and test the effective configuration;
- retaining S2T data for the shared runtime, or proposing its removal through a
  separate Product capability review; and
- a compact manifest/receipt format that records the same immutable inputs,
  outputs, licenses and target/deployed identity.

## Prohibited Changes

- Do not copy the entire Prelude catalog or unselected Luna variants just to
  make a directory scan pass.
- Do not remove Essay/common vocabulary to save bundle size or accept rare
  characters as a normal candidate.
- Do not mix OpenCC current-master data with the pinned vendor binary.
- Do not modify upstream source files in place, use a fake text fallback for a
  binary artifact, or leave stale prebuilt files active after source changes.
- Do not put deployment, repair, download, hashing or heavy file work in the
  Extension.
- Do not add `.gram`, grammar patches, Octagram user-facing behavior, PR #91
  changes or unrelated scheme/sync work.
- Do not claim `Ready`, Product acceptance, Quality acceptance, TestFlight
  acceptance, merge readiness or release readiness from this review alone.

## Handoff

The next owner is the Domain Owner/Executor for the `fix` residuals, followed
by an independent Quality review. The handoff packet must include the new ADR,
exact dependency graph, immutable source and generated receipts, notices,
target/build inventory, overlay/effective-config tests, fresh offline evidence,
candidate-order fixtures, last-known-good failure evidence and named physical
device results. Any revision to the source pins, generated artifacts, OpenCC
profiles, target membership, App/Extension ownership or vendor/toolchain
revalidates this review.

No code, resource, existing document or PR #91 was changed by this review.

## Architecture Follow-up Addendum — ADR 0033 and Lifecycle Correction

**Follow-up date:** `2026-08-29 Asia/Shanghai`
**Review target:** Proposed [ADR 0033 — Main-App-Owned Offline RIME Resource Closure](../architecture/decisions/0033-main-app-owned-offline-rime-resource-closure.md)

### 1. ADR 0033 disposition

ADR 0033 is **acceptable as `Accepted; implementation pending`**. It has the
required `Status`, `Context`, `Decision`, `Alternatives Considered`,
`Consequences`, `Risks`, `Follow-up Work` and `Related Documents` sections. Its
decisions are consistent with the Product Decision and ADR 0001/0003/0004/0008:

- one main-App-owned immutable source copy and no deployable Extension copy;
- the selected official Luna/Essay/Prelude/Stroke/OpenCC closure rather than
  the whole preset catalog;
- official bytes plus bounded overlays;
- prebuilt artifacts as this release's deployment strategy, with explicit
  provenance and no stale generation;
- manifest-driven fail-closed staging with last-known-good preservation; and
- capability-only Octagram G1 with no `.gram` model or grammar feature.

The existing `Proposed` status is the remaining administrative state. The
Coordinator/Architecture owner may record `Accepted; implementation pending`
without claiming that generated hashes, bundle membership, runtime behavior,
device evidence, CI or legal acceptance already exist. This addendum does not
edit ADR 0033, and acceptance does not authorize implementation, merge,
TestFlight or Release.

### 2. Ready versus Active/Exit evidence

The earlier residual table used `fix` correctly as a close disposition but
incorrectly read every item as a pre-`Ready` implementation-evidence blocker.
KOS lifecycle semantics are: `Ready` means Assignment/design/authority
completeness; `Active` begins authorized implementation; `Completed` delivers
outputs; `Reviewed` and the owning Product/Quality gates assess them. The
following table supersedes that lifecycle reading while preserving the original
residual IDs and `fix` dispositions.

| Residual | Must be closed by design documents before `Ready` | Belongs to `Active` → `Exit` → independent re-review |
|---|---|---|
| `AR-F02-01` | Exact selected schema IDs, dependency graph, direct versus retained OpenCC capability, source pins and expected closure manifest. | Re-check the graph and receipts after any source/schema/profile change; no implementation output is required to enter `Ready`. |
| `AR-F02-02` | Deterministic generation contract, expected RIME/OpenCC output inventory, source-to-output mapping and receipt schema. | Actual generated byte lengths/SHA-256/entry counts, two clean-output reproducibility runs and runtime acceptance. Generated hashes are not a `Ready` prerequisite. |
| `AR-F02-03` | Main-App ownership contract, target-membership plan, no-duplicate Extension rule and expected bundle/deployed manifest fields. | Xcode target membership, built `.app`/`.appex` inspection, packaged/deployed hashes and last-good fault evidence after implementation. |
| `AR-F02-04` | Official-byte-plus-thin-overlay Source of Truth, schema-aware `zh_hans` (`@2`) rule, ownership and invalidation/revalidation rules. | Compiled effective-config tests, overlay behavior, fuzzy-on/off candidate fixtures and no-source-mutation checks. |
| `AR-F02-05` | The prebuilt first-run decision, one source of truth, generator/toolchain compatibility boundary and the rule that source-only needs a superseding ADR. | Actual generator receipt, stale-artifact invalidation, iOS runtime compatibility, first-deploy latency/recovery and performance evidence. |
| `AR-F02-06` | License/attribution matrix, source/commit/hash mapping, notice ownership and explicit Human Product Owner/legal boundary. | Actual bundled notice files, UI/catalog-to-bundle parity and Human Product/legal decision; engineering evidence must not claim legal sufficiency. |
| `AR-F02-07` | Executable Quality fixture/evidence matrix, exact acceptance predicates, no-network/failure expectations and owner/handoff plan. | Fresh empty App Group + airplane mode, exact candidate order, OpenCC/Stroke behavior, fail-closed/last-good, physical-device and release-like evidence. |
| `AR-F02-08` | ADR 0033 recorded as `Accepted; implementation pending`; the G1/no-`.gram` boundary remains explicit. | Architecture/Quality re-review of the implementation and proof that no vendor/model/TD-012 expansion occurred. |

The source manifest's already recorded source-file byte lengths/SHA-256 values
are design/provenance inputs and may be used for `Ready`. The generated-output
hashes are deliberately `UNKNOWN` until `Active`; they must be produced and
reviewed before `Completed`/`Reviewed`, not fabricated to satisfy Entry
Criteria. Likewise, actual bundle inspection, deployed identity, true-device
results and hosted CI are downstream Exit/re-review gates. A reviewed *expected*
manifest and test plan are required before `Ready`; a built-product manifest is
not.

The Architecture gate does not override the independent Quality conclusion.
Quality must accept the executable validation plan for the Assignment to enter
`Ready`; Quality, Human Product and Release conclusions remain later gates.
If the Assignment's Entry wording is later read as requiring a built-product
manifest or generated hashes before `Ready`, the Coordinator should reconcile
that wording under KOS state-sync rules. This follow-up intentionally does not
edit the Assignment.

### 3. Architecture gate result

**Architecture result: Pass for `Ready`, conditional only on the ADR status
transition and the design-only closures above; no implementation evidence is a
condition of this Architecture result.**

There is an important distinction between “current checkout” and “current
Architecture decision”: while ADR 0033 still says `Proposed`, the package is not
administratively ready to advance. Once the ADR is recorded as
`Accepted; implementation pending`, the reviewed source/graph/overlay/
ownership/generation/notice/test-plan documents provide the Architecture basis
for `Ready`. The Assignment itself remains `Assignment Pending` until its
Product/assignment and independent Quality-plan requirements are recorded.

The next safe sequence is therefore:

1. record ADR 0033 as `Accepted; implementation pending`;
2. record/close the design-only residual portions above and obtain Quality plan
   review; then
3. allow the Assignment to enter `Ready`, followed by explicit implementation
   authorization and `Active` evidence work.

Do not move generated hashes, bundle inspection, true-device/Full-Access,
performance, hosted CI or legal/product acceptance into the `Ready` checklist;
they belong to implementation `Exit` and independent re-review. No code,
resource, ADR, Assignment or PR #91 was changed by this follow-up.

### Post-sync note — 2026-08-29

The administrative condition is now closed: ADR 0033 is recorded as
`Accepted; implementation pending`, and the Assignment Entry/Exit lifecycle
wording has been synchronized. The Architecture `Pass for Ready` conclusion is
effective. Implementation, Exit evidence and Release/Product acceptance remain
outstanding and are not implied by this sync.

## Post-implementation Review — `09659a7` — 2026-08-30

**Independent verdict: `Fail` for implementation re-review.** This does not
revoke ADR 0033 or the prior `Pass for Ready`; the current implementation cannot
advance to physical-device handoff or Exit until the P1 findings are fixed and
independently re-reviewed. P0: none.

### P1 findings

1. `RimeBuiltinResourceInstaller.swift:106-139` validates staging but does not
   validate the final deployed `shared` set/hash or reject stale unexpected
   deployed artifacts after replacement.
2. `RimeConfigManager+DeploymentResources.swift:28-40` writes
   `installation.yaml` after the closure transaction/receipt. A failure there
   returns failure while leaving the new generation installed, outside the
   claimed last-known-good boundary.
3. `RimeConfigManager+DeploymentResources.swift:90-114` locates only declared
   flattened bundle members and does not enumerate/reject additional bundle
   resources, so the evidence claim “rejects extra” is not established.
4. `RimeBuiltinResourceInstaller.swift:27-45,164-205` does not validate the
   non-empty shape/key set of `sourcePins`, `generators`, optional provenance or
   per-entry `role`; metadata can be emptied or altered while unchanged payload
   bytes still install.
5. The manifest and installer do not bind generated `default.custom.yaml` /
   `luna_pinyin.custom.yaml` overlays to the installed generation/receipt. The
   thin-overlay claim therefore lacks generation identity and revalidation.

### P2 findings / pending evidence

- Hidden extra files are skipped by resource enumeration; rollback uses
  best-effort `try?` without reporting/revalidating rollback success.
- The manifest/evidence lacks a complete machine-readable host/toolchain,
  exact generator command and two clean-output receipt identity.
- Bundle target membership, raw Extension duplicate output, actual Extension
  consumption, iOS 18 runtime, physical-device/offline/Full Access/performance,
  hosted CI and Human Product Gate remain pending.

The reviewer confirmed a read-only inspection, no build/network/write actions
and no access or change to PR #91.

## Final implementation re-review — `fa5dbaf` / `786f4c7` — 2026-08-31

**Independent verdict: `Pass with conditions`.** P0: none. P1: none. The
reviewed implementation commit is
`fa5dbaf1fded3e25ac39a6c0c675cddc786f01bb`; the reviewed evidence commit is
`786f4c720949784f4f66515228778bf6a012b952`.

The reviewer confirmed that the previous base/overlay atomicity condition is
closed: main-App deployment installs the immutable generation and runs managed
overlay synchronization inside one recoverable production boundary, while the
Extension only consumes a receipt-authorized generation and does not perform a
34 MB closure hash at keyboard startup. The frozen candidate vectors now assert
the complete first-page order, and the recorded App aggregate is
`255 total / 252 passed / 3 physical-only skipped / 0 failed`.

### Remaining Architecture residuals

| ID | Severity | Owner / disposition | Remaining requirement |
|---|---|---|---|
| `F02-A-P2-PROVENANCE-001` | P2 | RIME Platform Maintainer / `fix` | Extend the machine-readable receipt with source repository, input SHA-256, complete toolchain identity and exact generator arguments before provenance/Exit is claimed. |
| `F02-A-P2-TD001` | P2 | Main App/Data Ops / `tech_debt:TD-001` | Process-death or cross-process whole-tree atomicity remains governed by ADR 0006 and TD-001; F-02 only claims synchronous failure recovery. |
| `F02-A-P2-DOCSYNC-001` | P2 | Architecture/Coordinator / `fix` | Closed by the 2026-08-31 synchronization of `shared-container-and-rime-lifecycle.md`, which now records bounded resource/overlay receipt authorization and fail-closed Extension consumption. |

Physical fresh-App-Group/offline deployment, Full Access off/on, Extension
lifecycle, iOS 18 physical evidence, performance/size, hosted CI, exact
archive/build provenance, license/legal review and Human Product Gate remain
pending. Simulator App Group warnings are not physical-device evidence.

Architecture permits preparation of an exact installable build and a physical
device handoff matrix because the independent Quality reviewer also permits
that preparation. This is not device execution, Assignment Exit, merge,
TestFlight or Release authorization.

**Independence statement:** the reviewer performed a read-only review in the
isolated F-02 worktree, did not modify files or run build/test/network/device
actions, did not touch the main checkout and did not inspect or operate PR #91.

## Provenance closure re-review — `bb43c5f` — 2026-08-31

**Independent verdict: `Pass with conditions`.** P0: none. P1: none.

`F02-A-P2-PROVENANCE-001` is engineering-closed (`accept`): manifest v3 binds
five source pins, 20 source-input hashes, generator/toolchain identity,
normalized replayable commands and the explicit
`payload-tree-excluding-manifest` digest scope. Runtime validation rejects
receipt shape, command-template, digest-scope and directly packaged source
tampering. The current manifest SHA-256 is
`6aa2d28918b9146cdf417ddb369ba57907e5bbcc3e2ce2c9bc1280f1a6e7b233`.

`F02-A-P2-CANDIDATE-SUPERSEDE-001` is also closed: the `d4572d9`
candidate is historical only and explicitly forbidden from installation. A
clean replacement candidate may now be prepared and frozen; installation,
physical execution, hosted CI, archive, Product Gate, merge and Release remain
unauthorized. `F02-A-P2-TD001` remains `tech_debt:TD-001` and is unchanged.

**Independence statement:** this was a read-only review of `bb43c5f`; no files,
builds, tests, network, devices, main checkout or PR #91 were touched.

## Independent Architecture re-review — `b1d81fd` — 2026-09-02

**Independent verdict: code `Pass` + KOS-consistency P1.** P0: none. P1 (governance consistency): 1.

### Reviewed object

- Branch `codex/f02-rime-builtin-quality-assignment`, HEAD `b1d81fd2f61522001bc1d15490563097bd581016` (2026-09-02 20:01, Cowork 3P), parent `688a8fe`, worktree clean.
- Scope `git diff 688a8fe..b1d81fd`: 3 Swift files (`RimeConfigManager+CustomYaml.swift`, `RimeConfigManager+Preferences.swift`, `RimeBuiltinResourceInstallerTests.swift`).

### Code review

- Simplification preference is centralized in one resolver; a missing `rime_simplification` key defaults to simplified (`reset=1`), explicit `false` still writes `reset=0`: `RimeConfigManager+Preferences.swift`.
- The production wrapper still parses from the App Group then delegates to the internal overload; no new production deployment entry; the `nil`-overlay semantics (write the reset patch only when non-nil) is unchanged: `RimeConfigManager+CustomYaml.swift`.
- New installer tests cover missing-key → `reset: 1`, explicit traditional → `reset: 0`, both continuing through `validateInstalledRuntime` overlay-receipt validation: `RimeBuiltinResourceInstallerTests.swift:695-752, 909-930`.
- The main-App deployment / Extension session-only boundary is not broken.

### KOS-consistency P1 — freeze supersession (matches Quality `KOS-001`)

- `c5f3004` (08-31) is a docs commit whose source is equivalent to its parent `bb43c5f`; `688a8fe` froze the replacement signed candidate against clean `c5f3004`. `b1d81fd` (09-02) is a child of `688a8fe` that changes `RimeConfigManager` overlay generation — a source change landed after the freeze.
- The `688a8fe` freeze record itself states any source rebuild invalidates the freeze; `b1d81fd` is exactly such a post-freeze source change, so the `c5f3004` identity table no longer represents the current branch source. No docs/evidence commit records the new test result, a re-freeze, or a supersession after `b1d81fd`.
- Resolution is binary: rebuild + re-freeze the signed candidate from clean `b1d81fd` (re-record App/Extension/manifest/AUTHORS identity + deep/strict signature + affected-gate evidence), or record an explicit defer (keep the `c5f3004` freeze valid and defer the missing-key behavior). Until resolved, installation stays HOLD, `c5f3004` must not be installed, and Exit/merge/TestFlight/Release are not authorized.
- Decision 2026-09-02: Human Product Owner authorized re-freeze from clean `b1d81fd` (see Assignment History). Rebuild + identity re-recording remain pending Executor execution.

### Remaining Architecture residuals

| ID | Severity | Owner / disposition | Remaining requirement |
|---|---|---|---|
| `F02-A-P1-FREEZE-001` | P1 | Human Product Owner + Executor / `fix` | Re-freeze from clean `b1d81fd` (decided) — rebuild + identity re-recording pending. |
| `F02-A-P2-TD001` | P2 | Main App/Data Ops / `tech_debt:TD-001` | unchanged. |

### Independence statement

The codex Architecture reviewer (`/root/f02_arch_kos_review`) completed a read-only review of `b1d81fd`; no files, builds, tests, network, devices, main checkout or PR #91 were touched. This addendum was recorded by Claude Code (replacement coordinator) from that reviewer's returned verdict after codex went idle.

## Independent Architecture re-review — `ecd3446` — 2026-09-03

**Independent verdict: `Pass with conditions`.** P0: none. P1: none remaining.

### Reviewed object

- Branch `codex/f02-rime-builtin-quality-assignment`, HEAD `ecd3446a242f6309b5150f0d751fb6d4f155faa6` (merge of `2490431` + `origin/main` `29736b5`).
- Scope: freeze supersession evidence after `b1d81fd`, physical-device handoff ledger, and the `RimeSyncViewModel` merge that kept the F-02 overlay-authorization guard.

### Closed P1 — freeze supersession (`F02-A-P1-FREEZE-001` / Quality `KOS-001`)

Human Product Owner authorized re-freeze from clean `b1d81fd` on 2026-09-02. Executor recorded the replacement signed Debug identity in the [device handoff](../evidence/rime-builtin-luna-quality-f02-device-handoff-2026-08-31.md) with an S-03 banner over the `c5f3004` freeze:

- App CDHash `ed46a655e08d615fbc2d576837ae05fc3f37c579`; Extension CDHash `a3814d38e5d36c4ebb0bc4cb1f8eab9333083d60`
- Manifest SHA-256 `6aa2d28918b9146cdf417ddb369ba57907e5bbcc3e2ce2c9bc1280f1a6e7b233`; OpenCC AUTHORS SHA-256 `cb34e252fa994679bcbfc8355581e821ceda44bd857875e2cfe15b7ec4eec006`
- Extension runtime-resource duplicate count `0`; `codesign --verify --deep --strict` recorded as passed

`F02-A-P1-FREEZE-001` is `fix` / closed. Do not install the superseded `c5f3004` candidate.

### Merge invariant

`ecd3446` resolved `Universe Keyboard/Models/RimeSyncViewModel.swift` by keeping both the RIME-SYNC cancellation phase and the F-02 receipt guard: `syncCustomYamlFiles()` still runs inside `runCancellablePhase`, and `overlaysAuthorized == false` still throws `invalidInstallationConfiguration` before librime standard sync. That preserves main-App overlay authorization; the Extension remains a session consumer.

### ADR 0033

The Accepted architecture (main-App-owned immutable closure, thin overlay, fail-closed manifest, Octagram G1 only) is implemented on this branch. The ADR status line `Accepted; implementation pending` is stale relative to the landed code and is updated in the ADR itself. Follow-up evidence items that Product has not yet accepted (four-profile OpenCC, Stroke reverse lookup, first-launch autodeploy, release-like performance) remain Product Gate residuals, not Architecture P0/P1 defects.

ADR 0033 already requires explicit Product capability review before disabling a conversion profile or omitting its data. `F02-CONVERSION-LOOKUP-NOT-WIRED-001` is that review, not a silent architecture exception.

### Remaining Architecture residuals (M-03)

| ID | Severity | Owner / disposition | Remaining requirement |
|---|---|---|---|
| `F02-A-P2-TD001` | P2 | Main App/Data Ops / `tech_debt:TD-001` | Process-death / cross-process whole-tree atomicity stays ADR 0006 / TD-001. F-02 claims synchronous failure recovery only. |
| `F02-A-P2-OPENCC-SCOPE-001` | P2 | Human Product Owner / open (Product Gate) | Device finding `F02-CONVERSION-LOOKUP-NOT-WIRED-001`: deployed Luna wires `t2s` only; `s2t` bundled-not-wired; `t2hk`/`t2tw` and Stroke reverse lookup not wired. Requires `accept` (enabled-profile scope) or `fix`. |
| `F02-A-P2-AUTODEPLOY-001` | P2 | Human Product Owner / open (Product Gate) | Device finding `F02-FIRST-LAUNCH-AUTODEPLOY-001`: first launch does not seed `rime_needs_deploy`. Bundled bytes exist; activation is still a manual main-App deploy. Not a download Stop Condition. Requires `accept`, `fix`, or `tech_debt:<ID>`. |

Physical Q-01/Q-02/Q-04/Q-08 results are Quality/Device evidence, not Architecture re-execution.

This review does not authorize merge, Exit, TestFlight or Release.

### Independence statement

Replacement Architecture reviewer (Grok 4.6) performed a read-only review of `ecd3446` in worktree `/private/tmp/universe-keyboard-f02-assignment`. No Swift production edits, builds, tests, network or device actions were taken for this verdict. Documentation records of this addendum are Coordinator/Architecture hygiene, not a Product Gate.
