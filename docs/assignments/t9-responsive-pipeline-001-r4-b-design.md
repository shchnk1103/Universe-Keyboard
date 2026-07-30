# T9-RESPONSIVE-PIPELINE-001 / R4-B design

**Status:** `Closed for R4-B proof scope — dual independent review Pass with conditions; gate off; no Extension wire; ADR 0025 remains Proposed`  
**Date:** `2026-07-31 Asia/Shanghai`  
**Role author:** 🏛️ Architecture & Knowledge Steward  
**Parent Assignment:** [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)  
**Product authority:** [`PD-T9-RESPONSIVE-PIPELINE-001`](../product-decisions/T9-RESPONSIVE-PIPELINE-001-authorization.md) (R4-B)  
**Predecessor:** R4-Owner `768d680` (D1–D3 Closed on Fake path)  
**Closes residual:** Arch P2-later-1 (real RimeBridge / `RimeEngineImpl` bootstrap) as far as **proof**, not production wiring

---

## 1. Decision boundary

### In scope

1. **Concrete Sendable bootstrap** for real `RimeEngineImpl`:
   - carries only path / schema configuration values;
   - materializes the engine **only** on the thread-affine owner thread;
   - never stores a live engine on MainActor or in the mailbox.
2. **RimeBridgeTests** (iOS Simulator) proving:
   - short real `processKey` sequence through `ThreadAffineRimeSpikeOwner`;
   - engine create / call affinity flags from existing owner result diagnostics;
   - ordered delivery of accepted keys;
   - explicit shutdown / deinit stop still works with real engine teardown;
   - missing fixture → **XCTSkip** (honest non-claim), not fabricated Pass.
3. **Gate-off baseline:** responsive gate remains default `false`; direct
   26-key / `rime_ice` (or equivalent) path is not broken by R4-B code.
4. Minimal **KeyboardCore availability** adjustment so thread-affine owner APIs
   are available on iOS (currently annotated macOS-only for `Mutex` APIs).

### Out of scope

- Extension / `KeyboardController` production wire of the thread-affine owner;
- Release default-on; ADR 0025 Accept; Product Gate; R5 device A/B;
- Full session API production routing (Delete / Path / select / page / recover);
- Subjective non-stutter SLO; formal jetsam numbers;
- Mutating the user's formal App Group runtime as the sole test directory
  (tests must use isolated dirs or documented env fixtures).

### Domain ownership

| Concern | Owner |
|---|---|
| Real `RimeEngineImpl` bootstrap + RimeBridge tests | 🔧 RIME Platform Maintainer |
| Thread-affine owner contract / iOS availability | 🧠 Input Intelligence Maintainer |
| Deploy orchestration remains Main App | 📱 App & Data Operations (not changed here) |

---

## 2. Frozen decisions

### D1 — Config-only real bootstrap

```text
Sendable ThreadAffineRimeEngineImplBootstrap
  sharedDataDir: String
  userDataDir: String
  preferredSchemaID: String?   // e.g. "t9" or "rime_ice"
        │
        ▼ transferred into owner Thread
makeEngineOnOwnerThread()
  → RimeEngineImpl(sharedDataDir:userDataDir:)
  → optional selectSchema(preferredSchemaID)
  → return as any RimeEngine
```

Rules:

1. Bootstrap is a pure `Sendable` value type in `Packages/RimeBridge`.
2. No `RimeEngineImpl` instance may be captured by the bootstrap.
3. Deploy / fullCheck of the isolated runtime happens **before** owner start
   (test harness / Main-App-shaped deploy service), not inside `processKey`.
4. Engine finalize/teardown must occur when the owner loop releases its local
   engine (same owner thread), via normal ARC + `RimeEngineImpl.deinit`.

### D2 — Evidence matrix (minimum Pass)

| Case | Requirement |
|---|---|
| M1 | With fixture: owner accepts ≥3 processKey events; all results
  report `engineCreatedOffMainThread == true` and
  `engineCallStayedOnCreationThread == true` |
| M2 | Delivery order matches accept actionID order (FIFO) |
| M3 | After shutdown, owner stops; no hang within test timeout |
| M4 | Without fixture env: tests **skip**, evidence records skip (not Fail) |
| M5 | Gate-off baseline: `isResponsiveRimePipelineEnabled` default false still
  holds in KeyboardCore; R4-B does not enable gate |

Optional stretch (not required for Pass if environment blocks):

| Case | Requirement |
|---|---|
| S1 | Short T9 digit algebra sequence (`t9` schema) yields non-empty
  composition or candidates (content-free count only in logs) |
| S2 | Content-free wall-time observation that MainActor accept does not block
  on a deliberately slow real key (hard on real librime; Fake already proved) |

### D3 — Fixture policy

Reuse the established isolated-runtime pattern from T9 spikes:

- Env: `UK_RIME_T9_SPIKE_SHARED_DIR` / `UK_RIME_T9_SPIKE_USER_DIR`
  (and `TEST_RUNNER_` / `SIMCTL_CHILD_` variants as needed);
- Or a dedicated R4-B runner that copies a known Simulator App Group shared
  tree into a temp directory (read-only source).

Never claim Pass when the only available path was “skip all real tests”.

### D4 — Availability

`ThreadAffineRime*` APIs must be available on **iOS** (project floor 26.4) and
macOS 15+ (for existing `swift test` KeyboardCore suite). Prefer:

```swift
@available(iOS 18.0, macOS 15.0, *)
```

(or tighter matching `Synchronization` / OS floors). Do not leave owner APIs
macOS-only while RimeBridge is iOS-only.

---

## 3. Implementation sketch

| Artifact | Location |
|---|---|
| Bootstrap type | `Packages/RimeBridge/Sources/RimeBridge/ThreadAffineRimeEngineImplBootstrap.swift` |
| Real-engine tests | `Packages/RimeBridge/Tests/RimeBridgeTests/ThreadAffineRimeRealEngineTests.swift` |
| Optional harness | `scripts/run_t9_responsive_r4b.sh` |
| Evidence | `docs/evidence/t9-responsive-pipeline-r4-b-2026-07-31.md` |
| iOS availability | `Packages/KeyboardCore/.../ThreadAffineRimeSpike.swift` (+ tests) |

---

## 4. Relationship to ADR 0004 / 0025

- ADR 0004 remains production Extension law until ADR 0025 is Accepted **and**
  a Product-authorized migration wires the owner.
- R4-B only **proves** real-engine thread affinity is feasible under the
  R4-Owner contract. It does **not** Accept ADR 0025.
- R2/R3 MainActor deferred gate path stays default-off experimental ceiling.

---

## 5. Stop conditions

Stop and escalate if:

- Swift 6 requires `@unchecked Sendable` to hold `RimeEngineImpl` off-main;
- real engine must be constructed on MainActor then shuttled;
- harness would overwrite formal App Group user data without isolation;
- Product asks for gate default-on as a side effect of green tests.

---

## 6. Handoff

| From | To | Payload |
|---|---|---|
| 🧭 Product | 🏛️ Architecture | R4-B authorization (done) |
| 🏛️ Architecture | 🔧 Executor | This design freeze |
| 🔧 Executor | 🏛️ + 🧪 | Code, harness, evidence, skip honesty |
| Reviewers | 🧭 Product | Pass/Fail + residual for optional wiring knife |
