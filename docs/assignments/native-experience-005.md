# Assignment: NATIVE-EXPERIENCE-005 — RIME 首键分段观测

**Policy version:** `1.0.0`

**Decision source / date:** Human Product Owner authorization to add measurement-only cold-start and first-key observability / `2026-07-14 Asia/Shanghai`

**Lifecycle status:** `Active`

**Repository change types:** `Implementation`, `Evidence`

## Authority

- **Assignment Authority:** Product Lead
- **Product Approver:** Product Lead acting under the human owner's explicit measurement-only authorization
- **Assignment Revalidation Authority:** Product Lead
- **Product source:** Physical-device first-key diagnostic results and `docs/PERFORMANCE_BASELINE.md`

## Assignment

- **Domain Owner:** RIME Platform Maintainer
- **Executor:** RIME Platform Maintainer
- **Environment Executor:** Quality, Performance & Release Maintainer using the connected iPhone and user-opened Device Hub
- **Human Dependency:** Human owner for any required device unlock, trust prompt and subjective typing judgment
- **Architecture Reviewer:** Architecture & Knowledge Steward
- **Quality Reviewer:** Quality, Performance & Release Maintainer
- **Product Approver:** Product Lead
- **Handoff Target:** Human owner for the next controlled physical-device measurement run

## Objective

Split the existing aggregate RIME startup and first-key timing into content-free phases so the next optimization decision is based on evidence rather than an aggregate bridge duration.

## Scope

1. Measure the existing startup phases separately: setup, initialize, session creation and schema selection.
2. Measure the existing first-key bridge call separately: librime `process_key` and output collection.
3. Preserve one aggregate timing for continuity with existing diagnostics.
4. Add focused contract coverage for the timing helper where it is testable.
5. Validate with RimeBridge tests and strict builds; collect a new physical-device diagnostic sample only after installation.

## Non-goals

- No synthetic input, preheating, schema enumeration, deployment, maintenance or file scanning.
- No RIME session, lifecycle, schema-selection, threading, recovery or candidate behavior change.
- No input text, candidate text, host text, paths, user identifiers or user-dictionary content in diagnostics.
- No synchronous storage, flushing or new background work in startup or key paths.
- No numeric performance acceptance claim without comparable Release physical-device samples.
- No modification of the frozen NATIVE-EXPERIENCE-001 evidence chain.
- No overwrite or cleanup of unrelated dirty-worktree changes.

## Required Inputs

- `AGENTS.md`
- `docs/ASSIGNMENT_POLICY.md`
- `docs/PERFORMANCE_BASELINE.md`
- `docs/DEBUGGING.md`
- `docs/architecture/shared-container-and-rime-lifecycle.md`
- ADR 0004
- `docs/playbooks/rime-bridge.md`
- current RimeBridge timing and contract-test sources

## Entry Criteria

- Human owner explicitly authorizes measurement-only diagnostics.
- Assignment contains no `UNKNOWN` field.
- Existing aggregate logs identify the first-key delay inside the bridge boundary but do not expose private input text.
- The change can preserve the accepted main-thread, process-local session model.

## Exit Criteria

- Startup logs expose content-free timings for setup, initialize, session creation and schema selection.
- First-key logs expose content-free timings for librime processing and output collection.
- Aggregate startup and key timing remain available for continuity.
- No diagnostic is synchronously persisted from startup or input handling.
- Focused tests and strict build validation pass, or exact blockers are recorded.
- The next physical-device handoff names build, device, host, schema, access state, cold/warm definition and sample count.

## Stop Conditions

Stop and return to the owning authority if:

- measurement requires a RIME lifecycle, threading, session or schema behavior change;
- a diagnostic would include typed or candidate content, or force synchronous persistence;
- the change requires synthetic input or preheating;
- an automated check exposes a product/runtime failure outside measurement scope;
- Device Hub requires an unavailable human trust/unlock action;
- unrelated dirty changes must be overwritten.

## Handoff

Provide changed files, timing-field semantics, automated results, exact device/run metadata, skipped checks, residual uncertainty and confirmation that RIME behavior did not change.

## Revalidation Trigger

Product and Architecture revalidation are required if the work expands into input preheating, lifecycle timing, RIME threading/session ownership, schema behavior, diagnostic privacy, persistence semantics or a numeric performance budget.

## Execution Evidence In Progress

- The bridge now records startup setup/initialize/session/schema durations and only the first real `processKey` for each new session.
- `RimeBridgeTests` strict Debug test action passed on iPhone 17 Pro Simulator with Swift concurrency warnings treated as errors.
- The strict Debug physical-device build passed and was installed on the connected iPhone 13 Pro.
- A Debug physical-device sample was collected on the connected iPhone 13 Pro, in a blank local note using schema `rime_ice`: startup setup `4.2ms`, initialize `0.4ms`, session creation `65.5ms`, schema selection `13.2ms`; first real key librime processing `57.4ms`, output collection `1.2ms`, bridge total `58.6ms`, end-to-end key total `62.3ms` and UI `0.9ms`.
- This is one Debug diagnostic sample, not a performance budget or Release acceptance result. It identifies first-key librime processing as the dominant observed cost; a controlled Release sample set is still required before any numeric product claim.
- System crash-log collection after the run contains no `Keyboard` incident later than the pre-run `21:20` incident; the observed first-key run was logged at `21:38`.
- Controlled cold sample 1 (iPhone 13 Pro, Debug, local blank note, `rime_ice`, one synthetic Chinese-mode key after device reboot): startup setup `12.1ms`, initialize `0.7ms`, session creation `138.7ms`, schema selection `28.8ms`, total `180.5ms`; first-key librime processing `55.6ms`, output collection `1.9ms`, bridge `57.7ms`, end-to-end key `62.3ms`, engine `60.5ms` and UI `1.7ms`. The required new-session and `KEY BEGIN #1` markers were present.
- Controlled cold sample 2 (same device, build, host, schema and one-key protocol after device reboot): startup setup `8.1ms`, initialize `0.8ms`, session creation `116.5ms`, schema selection `26.9ms`, total `152.5ms`; first-key librime processing `61.8ms`, output collection `2.0ms`, bridge `64.0ms`, end-to-end key `68.2ms`, engine `66.3ms` and UI `1.8ms`. The required new-session and `KEY BEGIN #1` markers were present.
- Controlled cold sample 3 (same device, build, host, schema and one-key protocol after device reboot): startup setup `10.2ms`, initialize `0.4ms`, session creation `123.7ms`, schema selection `32.7ms`, total `167.2ms`; first-key librime processing `55.8ms`, output collection `2.5ms`, bridge `58.4ms`, end-to-end key `62.4ms`, engine `60.8ms` and UI `1.5ms`. The required new-session and `KEY BEGIN #1` markers were present.
- Across controlled cold samples 1–3, medians are: startup `167.2ms`, session creation `123.7ms`, first-key librime processing `55.8ms`, output collection `2.0ms`, bridge `58.4ms`, end-to-end key `62.4ms` and UI `1.7ms`. This establishes a Debug diagnostic baseline only; it does not establish a Release product budget.
- A final system crash-log collection after sample 3 contains no `Keyboard` incident later than the pre-existing `21:20` record; no new keyboard crash was observed during the three-sample protocol.
