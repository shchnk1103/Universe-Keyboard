# Assignment: RIME-BUILTIN-LUNA-QUALITY-001 — Offline Built-In Luna Candidate Quality

**Policy version:** `1.0.0`
**Parent:** [`RELEASE-2026-0801-11` F-02](release-2026-08-01-11-internal-testflight-feedback.md)
**Priority:** `P1` — Product Lead advanced F-02 ahead of RC reconciliation

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Active` |
| **Phase** | Final independent Architecture and Quality re-reviews both returned `Pass with conditions` for `fa5dbaf` / `786f4c7`, with no P0/P1 findings. The Extension lifecycle documentation is synchronized and the physical-device handoff packet is prepared on HOLD pending an exact signed candidate identity and Human authorization. |
| **Non-claims** | No Assignment Exit, exact signed build, hosted CI, physical-device/Full Access/lifecycle/performance pass, legal acceptance, Human Product Gate, TestFlight acceptance, merge or Release; the historical Build 7 multi-character symptom is not claimed reproduced. |
| **Next** | Freeze a clean exact signed candidate and its App/Keyboard UUID/hash/receipt, then obtain Human Product Owner authorization for the single physical-device Run ID. Do not begin device actions while any candidate identity field is `UNKNOWN`. |
| **Residuals** | [`Architecture final re-review`](rime-builtin-luna-quality-001-architecture-review.md#final-implementation-re-review--fa5dbaf--786f4c7--2026-08-31) · [`Quality final re-review`](rime-builtin-luna-quality-001-quality-review.md#final-implementation-re-review--fa5dbaf--786f4c7--2026-08-31) · [`implementation evidence`](../evidence/rime-builtin-luna-quality-f02-implementation-2026-08-30.md) · [`physical-device handoff`](../evidence/rime-builtin-luna-quality-f02-device-handoff-2026-08-31.md) |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner in the active Codex task,
  `2026-08-29 Asia/Shanghai`, authorized creation of the F-02 repair Assignment
  and required `rime-essay` plus every other necessary built-in RIME resource to
  ship inside the App without any additional user download.
- **Product Approver:** Human Product Owner acting as Product Lead
- **Accepted Product Decision:**
  [`PD-RIME-BUILTIN-LUNA-QUALITY-001-CLOSURE`](../product-decisions/RIME-BUILTIN-LUNA-QUALITY-001-official-runtime-closure.md)
  selects the pinned official Luna runtime closure plus a thin Universe iOS
  overlay. It does not authorize implementation.
- **Accepted Assignment Decision:**
  [`PD-RIME-BUILTIN-LUNA-QUALITY-001-ASSIGNMENT`](../product-decisions/RIME-BUILTIN-LUNA-QUALITY-001-assignment-bindings.md)
  binds the task-level owner, Executor, environment operations, Human
  Dependency and independent reviewers.

## Problem Statement

The built-in `luna_pinyin` path can compose multiple syllables, but a fresh
deployed table without the expected preset vocabulary ranks rare characters
ahead of normal words. With managed `n / l` fuzzy pinyin enabled, `ni` is
polluted by the same unweighted `li` path; with fuzzy pinyin disabled, the
candidate order begins with `㘈、㞾、䁥、䛏、䦧、伱、伲` and only then reaches
`你`. `nihao` consequently begins with `㘈好` instead of `你好`.

This is an out-of-box candidate-quality failure, not evidence that the current
engine cannot segment all multi-character input. The exact historical Build 7
failure remains a separate unknown until reproduced on its original or an
equivalent environment.

## Boundary

### Scope

1. Establish one immutable, license-complete and hash-verifiable offline
   resource closure rooted in pinned official Luna Pinyin, Essay, Prelude and
   Stroke revisions, following every active schema reference into required
   OpenCC and generated RIME artifacts.
2. Bundle the pinned official `rime-essay` preset vocabulary and every other
   resource in that closure inside the main App bundle for App-owned
   deployment. The user must not download any resource needed for the built-in
   scheme; the Keyboard Extension must not carry a second deployable copy.
3. Keep main-App-owned deployment and Keyboard-Extension session ownership
   unchanged. The main App stages and compiles; the Extension only consumes the
   last known good deployed state.
4. Make source YAML, preset vocabulary and any shipped precompiled
   `table/prism/reverse` artifacts one reproducible, matching generation. Remove
   or replace stale/minimal artifacts rather than allowing full deployment to
   silently produce a different candidate table.
5. Preserve exact-spelling candidate quality when managed fuzzy pinyin is on;
   a derived pronunciation must not displace the expected normal result for
   `ni`, `nihao` or equivalent baseline inputs.
6. Add isolated fresh-container deployment and runtime quality gates that test
   candidate identity and order, not merely the existence of any Han candidate.
7. Complete notices, source attribution, immutable commit/version receipts,
   byte sizes and SHA-256 records for all newly bundled upstream assets.

### Binding Product Constraint: No Additional Download

- All resources required to activate and use the built-in scheme are installed
  with the App and available offline on first run.
- First-run or repair UI must not ask the user to download `rime-essay`, Prelude,
  Luna dictionaries, OpenCC data, a reverse-lookup dependency or compiled RIME
  artifacts.
- Downloadable third-party schemes remain separate optional products. Their
  availability cannot be used to excuse a broken built-in scheme.

### Non-goals

- No change, review, merge, update or lifecycle action for PR
  [#91](https://github.com/shchnk1103/Universe-Keyboard/pull/91). Its commit is
  evidence provenance only.
- No implementation outside the explicitly authorized F-02 boundary.
- No network request or deployment from Keyboard Extension.
- No automatic download of supposedly missing built-in resources.
- No unrelated redesign of 雾凇、万象、T9, user sync or scheme delivery.
- No Octagram model enablement or reopening of TD-012 Product Hold without a
  separate Product Decision.
- No silent upstream `master` dependency, mutable asset, unverified binary or
  license/attribution shortcut.
- No claim that simulator smoke or a successful deploy alone proves candidate
  quality.

## Offline Resource Closure

The closure is derived from the selected schema and every referenced
`dictionary`, `import_preset`, `__include`, `__patch`, `opencc_config`, runtime
module and compiled artifact. Files are not classified as required merely
because they appear in an upstream repository.

### Accepted official runtime closure

The selected Source of Truth is not the former app-owned minimal schema. The
implementation must pin and bundle the complete active dependency closure:

| Resource family | Requirement |
|---|---|
| Official Luna Pinyin | Authoritative `luna_pinyin.schema.yaml`, `luna_pinyin.dict.yaml`, `pinyin.yaml` and the selected official Luna entry schema, all from one pinned revision |
| Official Essay | Pinned `essay.txt`, mandatory for the dictionary's preset vocabulary and normal candidate weighting |
| Official Prelude | Required `default.yaml`, `key_bindings.yaml`, `punctuation.yaml` and `symbols.yaml` definitions; the Universe overlay may replace the schema list and unsupported desktop behavior but must not copy/fork the complete upstream files |
| Official Stroke | Pinned schema and dictionary remain bundled while Luna declares the dependency or exposes reverse lookup, even if the App does not yet expose Stroke as a separately selectable product |
| OpenCC | Every config and data file reachable from the enabled simplified/traditional/HK/TW conversion profiles; disabling a profile and removing its data requires explicit Product capability review |
| Universe iOS overlay | Small, reviewable patch that registers shipped schemes, selects product defaults, adapts platform bindings and controls fuzzy behavior; it may not silently fork upstream dictionary/schema content |
| Generated RIME artifacts | Any shipped table, prism and reverse binaries are regenerated from this exact closure and carry source/generator receipts; source-only deployment is allowed only after fresh-device latency and recovery acceptance |
| License and attribution documents | Include Luna, Essay, Prelude, Stroke, OpenCC and every incorporated upstream work in the in-App third-party license surface |
| Resource manifest/receipt | Pin repository, commit, path, byte size and SHA-256 for source and packaged artifacts; verify bundle membership and deployed-file identity |

The official Prelude preset catalog is not itself a product commitment. The
Universe overlay registers only schemes whose complete runtime closure ships in
the App. Unrelated Prelude schemes and Plum recipes must not enter the bundle
merely because they are listed upstream.

The optional upstream grammar patch must be explicitly disabled or remain
unresolved as an inactive optional patch. No `.gram` model belongs to this
closure; adding one requires a separate Product Decision and Architecture
clearance of the existing Octagram boundary.

`custom_phrase` user data, learned user dictionaries, deployment metadata and
third-party downloadable scheme archives are runtime/user state, not immutable
built-in assets.

## Required Inputs

- [`2026-08-29 F-02 evidence`](../evidence/rime-builtin-luna-quality-f02-2026-08-29.md)
- [`2026-08-29 upstream pin and manifest audit`](../evidence/rime-builtin-luna-quality-f02-upstream-pin-audit-2026-08-29.md)
- [`RIME_SCHEME_MANAGEMENT.md`](../RIME_SCHEME_MANAGEMENT.md)
- [`RIME_FUZZY_PINYIN.md`](../RIME_FUZZY_PINYIN.md)
- [`shared-container-and-rime-lifecycle.md`](../architecture/shared-container-and-rime-lifecycle.md)
- ADR 0001, 0003, 0004 and 0008
- [`RIME artifacts`](../architecture/rime-artifacts.md)
- [`ADR 0033`](../architecture/decisions/0033-main-app-owned-offline-rime-resource-closure.md)
- [`RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md)
- current bundle membership, deployment preparation, schema smoke and license UI
- [`official runtime closure Product Decision`](../product-decisions/RIME-BUILTIN-LUNA-QUALITY-001-official-runtime-closure.md)
- pinned upstream Luna, Essay, Prelude, Stroke and OpenCC sources selected by
  the accepted dependency closure
- exact clean checkout/base commit and an isolated implementation branch that
  does not modify PR #91

## Assignment

- **Domain Owner:** RIME Platform Maintainer — owns schema/resource compilation,
  OpenCC and generated artifact correctness.
- **Executor:** Current Codex task on
  `codex/f02-rime-builtin-quality-assignment`, operating under the RIME Platform
  Maintainer playbook; implementation remains gated by `Ready` and a later
  explicit implementation authorization.
- **Environment Executor:** Current Codex task on the isolated F-02 worktree for
  repository fixtures, local builds and Simulator evidence only.
- **Human Dependency:** Human Product Owner supplies Product decisions, physical
  device actions and final Product Gate; the original Build 7 tester remains a
  dependency only if the historical symptom must be separately closed.
- **Architecture Reviewer:** Architecture & Knowledge Steward — independently
  reviews resource closure, source/binary consistency, App/Extension ownership,
  licensing route and compatibility with Accepted ADRs.
- **Quality Reviewer:** Quality, Performance & Release Maintainer — independently
  reviews candidate-order fixtures, fresh-install/offline deployment,
  performance and physical-device evidence.
- **Consulted Secondary:** App & Data Operations Maintainer for main-App bundle
  membership and deployment orchestration; this does not split primary domain
  ownership.
- **Handoff Target:** Architecture & Knowledge Steward for closure review, then
  Quality, Performance & Release Maintainer for the verification plan.

## Gates

### Entry Criteria for `Ready`

- [x] The accepted Assignment Decision remains current and both reviewers can
  execute independently from the implementation Executor.
- [x] ADR 0033 translates the accepted official runtime closure into one exact
  dependency graph, main-App ownership contract, prebuilt generation strategy
  and thin, reviewable Universe iOS overlay.
- [x] Every required upstream source has an immutable revision, byte size,
  SHA-256, license and redistribution/notice disposition in the accepted pin
  audit. Generated-output hashes correctly remain post-`Ready` evidence.
- [x] The expected manifest fields and target contract enumerate the complete
  main-App-owned closure, prohibit an Extension duplicate and provide no
  network acquisition path. Actual `.app`/`.appex` and deployed manifests are
  Exit evidence, not fabricated Entry evidence.
- [x] Architecture accepted ADR 0033 as `Accepted; implementation pending`,
  returned `Pass for Ready` and confirmed TD-012/Octagram remains G1 only.
- [x] Quality froze Q-01–Q-10 acceptance predicates, evidence formats, owners
  and failure boundaries and returned `Pass with conditions for Ready`; the
  existing implementation and Release evidence remain `Fail`.
- [x] The implementation worktree is isolated from PR #91 and unrelated active
  work. No implementation begins without a later explicit authorization.

### Exit Criteria

- Fresh empty App Group plus airplane-mode first deployment succeeds using only
  bundled resources.
- A clean, non-learned runtime produces expected first-page/Top-1 results for at
  least `ni -> 你`, `nihao -> 你好`, `sanjiaoxing -> 三角形`, plus a reviewed
  representative sentence set.
- The exact-spelling results remain primary with managed fuzzy groups on and
  off; fuzzy variants remain discoverable without replacing normal Top-1.
- Decompiling or querying the produced table proves it matches the pinned
  resource closure; bundled and deployed hashes/entry counts are recorded.
- Smoke tests fail when the first normal candidate is a rare/unexpected Han
  character, even though some Han candidate exists.
- Missing/corrupt bundle assets fail before success is recorded and preserve the
  last known good deployment with an actionable main-App error.
- Full Access off/on behavior, Extension restart and main-App redeploy are
  verified on named OS/device builds without Extension-side file mutation.
- Bundle-size and first-deploy duration deltas are recorded and accepted.
- License UI and source attribution include every added asset.
- Focused tests, full local CI-equivalent gates, hosted CI, independent
  Architecture/Quality reviews and Human Product Gate are complete before merge
  or release readiness is claimed.

### Stop Conditions

- Any required built-in resource would be downloaded after installation.
- A mutable branch, unpinned release, unknown license or unverified binary enters
  the bundle.
- Source YAML, Essay and precompiled artifacts do not describe one reproducible
  generation.
- A shortcut removes common vocabulary merely to reduce bundle size.
- The Extension performs deployment, repair, download or synchronous heavy file
  work while handling input.
- A proposal broadens into third-party scheme delivery, PR #91, Octagram model
  activation or unrelated candidate/Typo redesign.
- Tests accept “any Han candidate” as sufficient for a normal-input quality
  claim.

## Handoff

- **Required Handoff Content:** Assignment Decision; selected schema strategy;
  full dependency graph; immutable upstream receipts; license disposition;
  bundle/deployed manifest; implementation diff; candidate-order fixtures;
  fresh-container offline evidence; Full Access matrix; build/CI results;
  independent reviews; skipped gates and residual risks.
- **Revalidation Trigger:** any change to Luna/Essay/Prelude/Stroke/OpenCC source
  revision, schema references, fuzzy defaults, RIME/librime version, generated or
  precompiled artifact, bundle target membership, App/Extension ownership,
  supported script conversion, iOS version or release channel.

## History

- `2026-08-29 Asia/Shanghai` — Human Product Owner required a fully bundled
  offline resource closure and authorized creation of this Assignment. Read-only
  reproduction established the current unweighted candidate-order failure; no
  implementation was authorized.
- `2026-08-29 Asia/Shanghai` — Human Product Owner selected a pinned official
  Luna runtime closure plus a thin Universe iOS overlay. The decision excludes
  unrelated preset schemes, Octagram, PR #91 and implementation authorization.
- `2026-08-29 Asia/Shanghai` — Human Product Owner accepted the recommended
  responsibility configuration. Assignment completeness is no longer blocked
  by `UNKNOWN` roles. The named Executor acknowledged the bounded Assignment;
  the lifecycle passed through `Assigned` and `Acknowledged` while production
  pin acceptance, generated manifest design and reviews remained pending.
- `2026-08-29 Asia/Shanghai` — Executor completed the read-only candidate pin,
  source manifest and license audit. Generated output receipts, Architecture
  acceptance and Quality plan review remain pending; no assets were changed.
- `2026-08-29 Asia/Shanghai` — Independent Architecture review returned
  `Pass for Ready` and accepted ADR 0033 as `Accepted; implementation pending`.
  Independent Quality review returned `Pass with conditions for Ready` while
  retaining `Fail` for the current implementation, Exit, TestFlight and
  Release evidence.
- `2026-08-29 Asia/Shanghai` — Coordinator reconciled Entry versus Exit gates
  and advanced the complete Assignment to `Ready` under the Product-approved
  scope and responsibility decisions. This transition does not infer the
  separate implementation authorization required to enter `Active`.
- `2026-08-29 Asia/Shanghai` — Human Product Owner explicitly authorized F-02
  to enter `Active` and begin code plus built-in resource implementation under
  KOS. PR #91, Octagram model activation, third-party schemes, merge,
  TestFlight and Release remain outside this authorization.
- `2026-08-30 Asia/Shanghai` — Executor created implementation commit `09659a7`.
  Deterministic generation, exact manifest/bundle hashes, App-only ownership,
  focused integration, full iOS 27 App/Keyboard tests, Debug and Release builds
  passed locally. Assignment remains `Active`; independent re-reviews,
  physical-device Q-01/Q-02/Q-04/Q-07/Q-08 evidence, hosted CI, Human Product
  Gate, merge and Release remain open.
- `2026-08-30 Asia/Shanghai` — The Coordinator issued one bounded, read-only
  review execution for each bound independent reviewer. Neither returned an
  auditable conclusion within the fixed window; both were interrupted, no
  files were modified, and no replacement was inferred. Per Assignment Stop
  Conditions, F-02 moved from `Active` to `Blocked` pending a Product Lead
  decision on an executable independent-review route.
- `2026-08-30 Asia/Shanghai` — Human Product Owner directed the same independent
  subagents to continue. Both completed read-only reviews without touching PR
  #91: Architecture `Fail` (no P0; five P1) and Quality `Fail` (one P0; four
  P1). The earlier wait-timeout inference was corrected, reviewer availability
  is restored, and F-02 returned to `Active` for findings remediation.
- `2026-08-30 Asia/Shanghai` — Executor froze findings remediation as commit
  `1755006`. Manifest/receipt/deployed/overlay identity, transactional rollback,
  deterministic provenance and the frozen candidate/OpenCC/Stroke/fault vectors
  pass focused local gates; Debug and Release builds pass on iPhone 17 Pro Max
  Simulator / iOS 27.0. The current full App suite is not green: after 80 tests
  passed it blocked in the pre-existing
  `NineKeyEnableTransactionTests.testCancellingDownloadWaitingForNineKeyLeaseCannotCommitAfterRelease`
  following a simulator App Group entitlement failure and was interrupted after
  852.710 seconds. Assignment remains `Active` pending independent re-review;
  no unrelated NineKey fix, physical-device claim, hosted CI, merge or Release
  action is inferred.
- `2026-08-30 Asia/Shanghai` — Independent re-review of `1755006` returned
  `Pass with conditions` from both Architecture and Quality. Executor closed
  the in-scope bundle-extra, normal overlay rollback, exact first-page candidate
  order and Stroke session-isolation conditions in `85d0249`. Final focused
  actual-bundle integration, 86-test RimeBridge suite, 1,068-test KeyboardCore
  suite and Debug/Release builds pass. A diagnostic App rerun that skipped only
  the original hanging NineKey case still failed 15 of 254 tests after the
  unsigned simulator host could not resolve the App Group; the aggregate stays
  blocked and is not presented as F-02 green. Assignment remains `Active`
  pending final independent re-review; no physical-device, hosted-CI, merge or
  Release claim is inferred.
- `2026-08-30 Asia/Shanghai` — Final review conditions were remediated in
  `fa5dbaf`: the production base-resource and overlay installation paths now
  share one recoverable boundary, Extension consumption is receipt-authorized,
  and every frozen quality vector has exact complete first-page expectations.
  The final local aggregate is 255 total / 252 passed / 3 physical-only skips /
  0 failures; RimeBridge is 87 total / 67 passed / 20 existing skips, and
  KeyboardCore 1,068/1,068 plus Debug/Release builds pass. Assignment remains
  `Active` pending final independent Architecture/Quality review and the Human
  physical-device gates; no hosted-CI, merge or Release claim is inferred.
