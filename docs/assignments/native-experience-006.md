# Assignment: NATIVE-EXPERIENCE-006 — 通用 RIME 首键预热可行性与契约

**Policy version:** `1.0.0`

**Decision source / date:** Human Product Owner requires a safe first-key optimization that benefits current and future pinyin schemes without a `rime_ice` allowlist / `2026-07-14 Asia/Shanghai`

**Lifecycle status:** `Completed`

**Repository change types:** `Contract`, `Evidence`

## Authority

- **Assignment Authority:** Product Lead
- **Product Approver:** Product Lead acting under the human owner's explicit universal-scheme direction
- **Assignment Revalidation Authority:** Product Lead
- **Product source:** Controlled Debug physical-device first-key baseline and the human owner's universal-scheme requirement

## Assignment

- **Domain Owner:** RIME Platform Maintainer
- **Executor:** RIME Platform Maintainer
- **Environment Executor:** Not Applicable — this bounded task is source and artifact feasibility review only; it does not operate a device or deployment environment.
- **Human Dependency:** Not Applicable — the Product direction is supplied above; later vendor implementation requires a separate Product decision.
- **Architecture Reviewer:** Architecture & Knowledge Steward
- **Quality Reviewer:** Quality, Performance & Release Maintainer
- **Product Approver:** Product Lead
- **Handoff Target:** Product Lead for the vendor-ownership and implementation decision

## Objective

Determine whether the currently pinned librime artifact exposes a supported, schema-agnostic, input-free capability that can move first-key initialization work before the user's first real key without changing composition, commit, learning, user data or Extension lifecycle semantics.

## Scope

1. Inspect the pinned librime C API, exported symbols and exact `1.16.1` upstream implementation for a session warm-up capability.
2. Trace schema selection and first-key processing enough to identify whether an input-free bridge call can warm the observed cost.
3. Define the minimum contract required for all present and future pinyin schemes to participate without hard-coded schema IDs or synthetic keys.
4. Identify the artifact, ownership and validation boundary for any later implementation.

## Non-goals

- No Keyboard, RimeBridge, vendor, test, build, deployment or manifest implementation change.
- No synthetic `process_key`, hidden composition, candidate selection, host insertion, user-dictionary write, maintenance, deployment or file scan.
- No use of undocumented C++ ABI as a production bridge contract.
- No performance acceptance claim or Release performance budget.
- No modification of the frozen NATIVE-EXPERIENCE-001 evidence chain.
- No overwrite or cleanup of unrelated dirty-worktree changes.

## Required Inputs

- `AGENTS.md`
- `docs/ASSIGNMENT_POLICY.md`
- `docs/kos/zero-context-startup.md`
- `docs/kos/knowledge-os-2.0-specification.md`
- `docs/architecture/shared-container-and-rime-lifecycle.md`
- ADR 0004
- `docs/architecture/rime-artifacts.md`
- `docs/playbooks/rime-bridge.md`
- pinned `librime.xcframework` headers, symbols and `config/rime-vendor-manifest.env`
- librime `1.16.1` upstream `service.cc`, `engine.cc`, `engine.h` and `translator.h`

## Entry Criteria

- Product direction requires every current and future pinyin scheme to use one common mechanism rather than a schema allowlist.
- Three controlled Debug physical-device cold samples identify the dominant first-key cost inside librime `process_key`.
- This task can remain read-only and does not enter any runtime or vendor implementation path.

## Exit Criteria

- A supported-capability conclusion distinguishes public C API from incidental C++ symbols.
- The conclusion names whether current schema selection already performs component construction.
- Any proposed universal contract states input, state, side-effect and verification guarantees.
- Vendor/artifact changes, if required, have a separate owner and Product decision boundary.
- No runtime behavior changes are made.

## Stop Conditions

Stop and return to Product Lead before implementation if:

- the only available trigger is synthetic input or an undocumented C++ ABI;
- a universal contract would require scheme-specific test strings, allowlists or guessed component behavior;
- vendor source, artifact version, manifest, checksum, slice matrix or release asset must change;
- the work changes Extension lifecycle, thread ownership, session ownership, user-data behavior or the accepted ADR 0004 boundary;
- a Product decision is needed to maintain an upstream patch, fork or new artifact release.

## Handoff

Provide the public-API result, exact first-key path, minimum universal contract, artifact implications, blocked implementation boundary, validation requirements and the next Product decision.

## Revalidation Trigger

Revalidate this Assignment if the pinned librime version changes, upstream adds an official warm-up API, a new scheme/component contract is introduced, or Product authorizes a vendor fork or artifact release.

## Completion Record

- The controlled Debug iPhone 13 Pro baseline used a local blank note, `rime_ice` and one synthetic Chinese-mode key after device reboot. Across three valid new-session samples, median first-key librime processing was `55.8ms`, output collection `2.0ms`, bridge duration `58.4ms`, end-to-end key duration `62.4ms` and UI duration `1.7ms`. This is diagnostic evidence only, not a Release budget.
- The pinned `RimeApi` has session creation, input processing, output, schema and maintenance APIs, but no session/engine warm-up or preheat API.
- `rime::Session::Activate()` is present in the binary but is not a valid substitute: librime `1.16.1` implements it solely as `last_active_time_ = time(NULL)`, and both `CreateSession` and `GetSession` already call it.
- `select_schema` calls `Session::ApplySchema`; `Engine::ApplySchema` clears context and constructs processor, segmentor, translator, filter and formatter instances. It is already included in the measured startup schema phase.
- The first real key reaches `Session::ProcessKey` and then the processor chain. Context updates cause segmentation and translator `Query(input, segment)` calls. The public `Engine` and `Translator` interfaces have no input-free warm-up hook, so a generic bridge call cannot guarantee warming each scheme's first real query.
- Therefore a `warm_up_session` wrapper around existing APIs would either be a no-op or depend on synthetic input. Neither meets the universal-scheme safety contract.
- A correct future design requires a supported librime extension: an input-free, idempotent component warm-up lifecycle hook plus a C ABI capability/result. Built-in pinyin components can implement it; custom/future components must explicitly report support or remain safely unpreheated. The Keyboard must never fall back to synthetic input.
- The repository currently consumes a pinned static `librime.xcframework`. The checked-in build script documents the librime build stage as requiring real CMake linkage rather than providing a reproducible vendor build, while `docs/architecture/rime-artifacts.md` requires a new immutable artifact, checksum and Architecture/Product revalidation for artifact-boundary changes.
- Implementation is intentionally not authorized by this Assignment. A successor Assignment must first obtain Product approval for upstream contribution versus maintained vendor fork, define the source/rebuild/release path, and obtain Architecture review before modifying the artifact or runtime bridge.
