# Assignment: T9-RESPONSIVE-PIPELINE-001 / P3-D1-R03 Q2/Q3 Evidence Hardening

Policy version: 1.0.0  
Lifecycle status: **Completed — bounded hardening recorded; historical Q2/Q3 gaps remain; B not authorized**  
Date: 2026-08-03 Asia/Shanghai

## Authority and boundary

- Assignment Authority: Product Lead, follow-up direction “开始接下来的工作吧”，2026-08-03
  Asia/Shanghai；parent scope remains P3-D1-R03 gate-off baseline.
- Parent evidence: [`P3-D1-R03 device baseline`](t9-responsive-pipeline-001-p3-d1-r03-device-baseline.md)
  and [`Evidence Hardening follow-up`](../evidence/t9-responsive-pipeline-p3-d1-r03-evidence-hardening-followup-2026-08-03.md).
- Scope: close as many P2-R03-Q2/Q3 evidence fields as can be established from existing build,
  source, fixture and restore records; mark historical omissions `unavailable` rather than infer.
- Non-goals: no production logic, RIME/Lua, default gate, ADR 0025, B arm, A/B comparison, new
  long-sequence device run, destructive cleanup or Product Gate/Release decision.

## Evidence owner and dependencies

- Executor: Current Codex task for read-only provenance collection and documentation.
- Human dependency: existing R03 manual report and post-restore smoke report; no new long fixture.
- Architecture / Quality: existing independent R03 reviews remain authoritative; this document is
  a bounded evidence addendum, not a replacement review.

## Source and build binding

### Original R03 immutable values

| Field | Value |
|---|---|
| Source HEAD | `3585a540ba8389673acd49128d87040ac9619f27` |
| Original dirty entry count | `86` |
| Original tracked diff SHA-256 | `5f67fc561b8e2494c895a6176909fc2602dad4492f275eed839a36eda40c45be` |
| Original untracked-name SHA-256 | `ce8fbc520ed5e98eeb9a602ac95522941cd8373a381dc09653fbff8370513e0f` |
| Original untracked-content SHA-256 | `unavailable` — not captured before the device build |

### Build and restore identity observed from the existing build record

| Field | Value |
|---|---|
| Xcode | `27.0 (27A5228h)` |
| SDK | `iphoneos27.0` at `/Applications/Xcode-beta.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS27.0.sdk` |
| Deployment target | `26.4` |
| Swift | `6.0` |
| Configuration | `Release` |
| Bundle IDs | `com.DoubleShy0N.Universe-Keyboard`; `com.DoubleShy0N.Universe-Keyboard.Keyboard` |
| Code-sign settings | `CODE_SIGN_IDENTITY=Apple Development`; `DEVELOPMENT_TEAM=C33N6HTS9N`; `CODE_SIGN_STYLE=Automatic` |
| Diagnostic build flags | `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` only; responsive and auto-anchor enabled flags absent |
| Diagnostic app SHA-256 | `36f1138bda3e8e2a3942eb099782acb2f449a401d97767a7046a57f3abc7165e` |
| Diagnostic Keyboard.appex SHA-256 | `ec0f05193114b3cf0d98683608a8a225a4b09b3ad6bb7ed3e6bb0aaa65122d0f` |
| Restore app SHA-256 | `b5a6ee5fe1ba8ac19ff3342d96dc0ba0c11ec53007494938eab80cc35cbefce8` |
| Restore Keyboard.appex SHA-256 | `8f24558f195c57201e51059608af53f8193219aca1df217ad4b964ea71c5fd4a` |
| Restore app CDHash | `932926adda5d1898ba439f1585cde48d494e7e63` |
| Restore Keyboard.appex CDHash | `910b911760e798e262fe76222ea0df8d38f745dd` |
| Restore install sequence | `3744` |

The exact commands used for this run were:

```text
xcodebuild -project 'Universe Keyboard.xcodeproj' -scheme 'Universe Keyboard' -configuration Release -destination 'id=00008110-000A08440198801E' -derivedDataPath '/private/tmp/P3D1-R03-tGaMMj' SWIFT_ACTIVE_COMPILATION_CONDITIONS='T9_AUTO_ANCHOR_DEVICE_PREFLIGHT' build
xcodebuild -project 'Universe Keyboard.xcodeproj' -scheme 'Universe Keyboard' -configuration Release -destination 'id=00008110-000A08440198801E' -derivedDataPath '/private/tmp/P3D1-R03-restore-nOjY4M' build
xcrun devicectl device install app --device 00008110-000A08440198801E '/private/tmp/P3D1-R03-restore-nOjY4M/Build/Products/Release-iphoneos/Universe Keyboard.app' --timeout 60 --json-output - --quiet
```

This addendum does not rebuild or reinstall the device. `Authority` is not recoverable from the
local `codesign -dv` output, so only the observed code-sign settings and Team ID are recorded.

### Provenance classes

- `observed-at-run`: original R03 marker/session/geometry/action facts, device identity and the
  original package hashes already present in the R03 evidence.
- `observed-post-hoc`: Xcode/SDK/build settings, restore CDHash/install sequence and the exact
  commands recovered from the existing build/install record after the run.
- `derived`: the `ccb155…` hash calculated after the run from the declared synthetic text; it has no
  frozen canonical-byte specification and cannot replace the P2 contract digest.
- `unavailable`: original untracked-content fingerprint, host opaque ID, Full Access,
  runtime/readiness and original time window; no other run is used to fill them.

## Fixture / host / runtime binding

| Field | Value | State |
|---|---|---|
| Observed marker fixture ID | `T9RESP-R5P` | observed in validator expectation and R03 markers; legacy/preflight identity |
| Canonical contract fixture | `T9-RESP-PERF-39-V1` / digest `772b4bb30cb831d04550e8311a2f64e66aad4ab55c4597544f0cc9364f9d7286` | frozen by P2-PERF-02 contract; not captured in the original R03 run header |
| Post-hoc derived fixture digest | `ccb15564c8efcfba5e5fae3a5d0e8857735329d40545094db32c4e181b9abd9a` | derived from the declared text after the run; input normalization/version not frozen; **not evidence of canonical equivalence** |
| Action count | `39` | observed `T9SEG` range `1…39` |
| Input method | `manual-software-keyboard` | Human report |
| Host | Reminders, empty list/title, software keyboard | Human setup/report |
| Opaque host/list ID | `unavailable` | not captured before the original run; not invented retroactively |
| Full Access | `unavailable` | not explicitly captured in the original run header |
| Runtime/schema/readiness | `schema/runtime/readiness unavailable` for the original sync A run; `T9RESP path=sync` observed | not inferred as B-ready |
| Run time window / cadence | `unavailable` / manual cadence | no timing window was captured in the original header |

## Disposition

- Q2 build/restore identity is materially strengthened, but historical untracked-content binding,
  reproducible original command output and complete restore manifest were not captured before the
  run; **Q2 remains Partial**.
- Q3 observed marker fixture ID and action count are now recorded, but canonical fixture digest
  binding is not established; host opaque ID, Full Access, runtime/readiness and time window were
  not observed for the original run; **Q3 remains Partial**.
- The validator and post-restore smoke gaps are closed by the linked follow-up, but this does not
  upgrade R03 beyond `Partial`.
- B/A, real off-main, jetsam/memory, iOS 26.0 Release RC, ADR 0025 and Product Gate remain
  `NotRun`/out of scope.

For a future new Run ID, the run header must freeze the P2 canonical human fixture
(`T9-RESP-PERF-39-V1` / `772b4b…`) separately from the observed marker fixture (`T9RESP-R5P`),
and include an explicit mapping or `unavailable` reason. Every unavailable field must also carry
`owner` and `retry` metadata; this historical run cannot be retroactively repaired by memory or by
another arm.

## Independent review disposition

- [`Architecture review`](t9-responsive-pipeline-001-p3-d1-r03-q2-q3-architecture-review.md)：
  **Pass with conditions**；P0/P1=0，P2=2，P3=2。
- [`Quality review`](t9-responsive-pipeline-001-p3-d1-r03-q2-q3-quality-review.md)：
  **Bounded pass with conditions**；P0/P1=0，P2=2，P3=3。
- 两份复核均确认：本 addendum 不重写历史 run header、不接受 ADR 0025、不打开 B，不形成
  Release 或 Product Gate 结论。

## Verification and stop point

- `git diff --check`: passed.
- Existing attachment validator follow-up: `complete`; no privacy violation; see linked JSON.
- No production source/test/Xcode project change; only evidence/assignment documents were added or
  updated. No device action was taken in this addendum.
- Stop here. Further Q2/Q3 closure would require a new run header captured before a fresh authorized
  device run; B requires a separate explicit authorization and Run ID.
