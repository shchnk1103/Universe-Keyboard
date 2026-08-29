# Assignment: RIME-BUILTIN-LUNA-QUALITY-001 — Offline Built-In Luna Candidate Quality

**Policy version:** `1.0.0`
**Parent:** [`RELEASE-2026-0801-11` F-02](release-2026-08-01-11-internal-testflight-feedback.md)
**Priority:** `P1` — Product Lead advanced F-02 ahead of RC reconciliation

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Assignment Pending` |
| **Phase** | F-02 current-development-build reproduction and resource-closure audit complete; implementation responsibility and immutable upstream pins remain unassigned |
| **Non-claims** | No production fix, upstream asset pin, license acceptance, Architecture/Quality pass, TestFlight acceptance, merge or Release; the historical Build 7 multi-character symptom is not claimed reproduced |
| **Next** | Product Lead names the Domain Owner, implementation Executor, Environment Executor and independent reviewers; Architecture then reviews the pinned offline resource closure before implementation may enter `Ready` |
| **Residuals** | [`2026-08-29 reproduction and resource audit`](../evidence/rime-builtin-luna-quality-f02-2026-08-29.md) |

---

## Authority

- **Assignment Authority:** Product Lead
- **Decision Source / Date:** Human Product Owner in the active Codex task,
  `2026-08-29 Asia/Shanghai`, authorized creation of the F-02 repair Assignment
  and required `rime-essay` plus every other necessary built-in RIME resource to
  ship inside the App without any additional user download.
- **Product Approver:** Human Product Owner acting as Product Lead

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
   resource closure for the built-in `luna_pinyin` product path.
2. Bundle the pinned official `rime-essay` preset vocabulary and every other
   resource in that closure inside the App/Keyboard bundle. The user must not
   download any resource needed for the built-in scheme.
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
- No implementation code under the current documentation authorization.
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

### Required for the current app-owned minimal Luna schema

| Resource | Requirement |
|---|---|
| App-generated `default.yaml` and `installation.yaml` | Built in as deterministic templates; schema list, menu, key bindings, punctuation and recognizer references must resolve without Prelude downloads |
| App-owned or pinned `luna_pinyin.schema.yaml` | Exact source schema used by deployment; no checked-in compiled `__build_info` file may masquerade as the authoritative source |
| Pinned `luna_pinyin.dict.yaml` | Immutable official/source-reviewed dictionary with commit, byte length, SHA-256, license and attribution |
| Pinned official `essay.txt` | Mandatory bundled preset vocabulary for the current dictionary's `use_preset_vocabulary: true`; no user download |
| `opencc/t2s.json`, `TSPhrases.ocd2`, `TSCharacters.ocd2` | Mandatory for the current simplified-output filter |
| `opencc/s2t.json`, `STPhrases.ocd2`, `STCharacters.ocd2` | Retain as a bundled, verified pair while the product ships or claims reverse conversion/shared S2T capability; otherwise removal requires explicit capability review |
| `luna_pinyin.table.bin`, `.prism.bin`, `.reverse.bin` | If shipped, regenerate reproducibly from the exact schema/dictionary/essay closure and verify hashes/runtime output; if intentionally not shipped, fresh-device deployment latency and failure recovery must prove source compilation is sufficient |
| License and attribution documents | Include Luna, Essay, OpenCC and every incorporated upstream work in the in-App third-party license surface |
| Resource manifest/receipt | Pin source repository, commit/tag, file path, byte size and SHA-256; verify bundle membership and deployed-file identity |

### Conditional closure if adopting the current official full Luna schema

The current official Luna schema references more than the two Luna YAML files.
If implementation adopts it rather than retaining the app-owned minimal schema,
the same App build must additionally bundle and verify:

- `pinyin.yaml` from the pinned Luna package for spelling/algebra patches;
- the used RIME Prelude components: `default.yaml`, `key_bindings.yaml`,
  `punctuation.yaml` and `symbols.yaml`, unless an app-owned generated equivalent
  deliberately removes each reference and has parity tests;
- the pinned Stroke schema and dictionary if `dependencies: [stroke]` and
  reverse lookup remain enabled;
- every OpenCC config and `.ocd2` dictionary actually referenced by the selected
  simplified/traditional/HK/TW filters;
- any grammar configuration and model only if Product separately authorizes
  that capability and Architecture clears the existing Octagram boundary.

`custom_phrase` user data, learned user dictionaries, deployment metadata and
third-party downloadable scheme archives are runtime/user state, not immutable
built-in assets.

## Required Inputs

- [`2026-08-29 F-02 evidence`](../evidence/rime-builtin-luna-quality-f02-2026-08-29.md)
- [`RIME_SCHEME_MANAGEMENT.md`](../RIME_SCHEME_MANAGEMENT.md)
- [`RIME_FUZZY_PINYIN.md`](../RIME_FUZZY_PINYIN.md)
- [`shared-container-and-rime-lifecycle.md`](../architecture/shared-container-and-rime-lifecycle.md)
- ADR 0001, 0003, 0004 and 0008
- [`RIME artifacts`](../architecture/rime-artifacts.md)
- [`RELEASE_CHECKLIST.md`](../RELEASE_CHECKLIST.md)
- current bundle membership, deployment preparation, schema smoke and license UI
- pinned upstream Luna, Essay, Prelude, Stroke and OpenCC sources only to the
  extent selected by the final dependency closure
- exact clean checkout/base commit and an isolated implementation branch that
  does not modify PR #91

## Assignment

- **Domain Owner:** `UNKNOWN` — recommended primary route is RIME Platform
  Maintainer because the defect is in schema/resource compilation and artifact
  correctness; Product Lead must make the Assignment Decision.
- **Executor:** Current Codex task for Assignment/evidence documentation only;
  implementation Executor is `UNKNOWN`.
- **Environment Executor:** `UNKNOWN` — must own isolated fixture builds,
  Simulator and named physical-device fresh-install/deployment evidence.
- **Human Dependency:** Human Product Owner supplies Product decisions, physical
  device actions and final Product Gate; the original Build 7 tester remains a
  dependency only if the historical symptom must be separately closed.
- **Architecture Reviewer:** `UNKNOWN` — must independently review resource
  closure, source/binary consistency, App/Extension ownership, licensing route
  and any decision to adopt the full official schema.
- **Quality Reviewer:** `UNKNOWN` — must independently review candidate-order
  fixtures, fresh-install/offline deployment and physical-device evidence.
- **Handoff Target:** Human Product Owner for the missing Assignment Decision;
  then the named RIME Domain Owner and reviewers.

## Gates

### Entry Criteria for `Ready`

- Product Lead explicitly names every `UNKNOWN` responsibility.
- One source-of-truth schema strategy is selected: app-owned minimal Luna or a
  pinned official full Luna closure.
- Every required upstream resource has an immutable source revision, byte size,
  SHA-256, license and redistribution/notice disposition.
- The resource manifest proves the entire dependency closure is inside the App
  build; no required built-in resource has a network acquisition path.
- Architecture Reviewer accepts the closure and confirms TD-012/Octagram is not
  implicitly reopened.
- Implementation uses a branch/worktree isolated from PR #91 and unrelated
  active work.

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
