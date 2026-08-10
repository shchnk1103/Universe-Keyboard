# TD-012-OCTAGRAM-VENDOR-G1 — Architecture / Quality Review Handoff

Prepared by: Executor (Grok)  
Handoff target: 🏛️ Architecture & Knowledge Steward, then 🧪 Quality, Performance & Release Maintainer  
Date / timezone: `2026-08-10 Asia/Shanghai`  
Publication: merged to `main` as PR [#63](https://github.com/shchnk1103/Universe-Keyboard/pull/63) (`84250c5`)

> Assignment is **executor-complete and published**. This handoff requests **independent**
> Architecture and Quality conclusions. It does **not** self-approve Architecture,
> Quality, Product Gate, model download, or App Store readiness.

## Authority

| Item | Link |
|---|---|
| Product Decision | [`PD-TD-012-OCTAGRAM-VENDOR-G1`](../product-decisions/TD-012-OCTAGRAM-VENDOR-G1-authorization.md) |
| Assignment | [`td-012-octagram-vendor-g1.md`](td-012-octagram-vendor-g1.md) |
| Parent debt | [`TD-012`](../TECH_DEBT.md#td-012-optional-rime-grammar-model-万象-lmdg--gram-integration) |
| G0 (old pin No-Go) | [`td-012-g0-octagram-artifact-audit-2026-08-09.md`](../evidence/td-012-g0-octagram-artifact-audit-2026-08-09.md) |
| License / provenance | [`td-012-octagram-license-provenance-audit-2026-08-09.md`](../evidence/td-012-octagram-license-provenance-audit-2026-08-09.md) |
| G1 build evidence | [`td-012-g1-octagram-vendor-build-2026-08-10.md`](../evidence/td-012-g1-octagram-vendor-build-2026-08-10.md) |
| Artifact contract | [`rime-artifacts.md`](../architecture/rime-artifacts.md) |
| Readiness plan | [`td-012-octagram-vendor-readiness-plan.md`](../plans/td-012-octagram-vendor-readiness-plan.md) |
| Supply-chain gate template | [KOS 2.1 G-01](https://github.com/shchnk1103/kos-agent-kit/blob/v0.4.0/ops/third-party-artifact-gate.md) |

## What was delivered (G1 only)

1. **Immutable vendor pin** `rime-vendor-ios-1.16.1-lua.1-octagram.1`
   - Asset: `universe-keyboard-rime-vendor-ios-1.16.1-lua.1-octagram.1.zip`
   - SHA-256: `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`
   - Release: <https://github.com/shchnk1103/Universe-Keyboard/releases/tag/rime-vendor-ios-1.16.1-lua.1-octagram.1>
   - Inventory: baseline **11** frameworks (bytes from rollback pin) + **`librime-octagram.xcframework`**
   - Rollback baseline retained: `rime-vendor-ios-1.16.1-lua.1` / `c299f36e…c840436c`

2. **Reproducible recipe (no floating HEAD)**
   - Input ledger: `config/rime-octagram-vendor-build.env`
   - Build: `scripts/build_rime_octagram_plugin.sh`
   - Assemble: `scripts/assemble_rime_vendor_with_octagram.sh`
   - Pins: librime `1300e568…`, octagram `bfb168ca…`, Boost 1.91.0 headers, plugin iOS DT **15.0**

3. **RimeBridge wiring (mirror of Lua path)**
   - SwiftPM binary `librimeOctagramRIME` + `RIME_HAS_OCTAGRAM`
   - `RimeOctagramModuleShim` → `rime_require_module_octagram`
   - Keyboard `-force_load` for `librime-octagram` **and** `libglog` (extension debug-dylib link requires explicit glog when octagram objects are force-loaded)
   - Traits modules: `core + dict + gears + lua + octagram`
   - Capability APIs: `octagramModuleCompiledIn` / `octagramModuleRegistered` / `grammarComponentRegistered`

4. **Capability proof without model file**
   - `RimeOctagramCapabilityTests`: empty shared/user dirs, **no** `.gram`, registry exposes `grammar`, Lua still registers

## Explicit non-claims

| Claim | Status |
|---|---|
| Concrete `grammar` component loadable | **In scope; executor asserts with tests** |
| Any `*.gram` works / improves ranking | **Out of scope** |
| Schema, download, settings, “整句增强” UX | **Out of scope** |
| Extension memory / Jetsam budget | **Out of scope** |
| Legal opinion on relicense residual | **Out of scope** (notice retained; Product already accepted engineering basis) |
| App Store / release readiness | **Out of scope** |

## Review entry points

### Artifact / supply chain

- `config/rime-vendor-manifest.env`
- `config/rime-octagram-vendor-build.env`
- `scripts/build_rime_octagram_plugin.sh`
- `scripts/assemble_rime_vendor_with_octagram.sh`
- `scripts/ensure_rime_vendor.sh`
- `docs/architecture/rime-artifacts.md`
- Vendor notice in release: `THIRD_PARTY_OCTAGRAM_NOTICE.txt`

### Runtime / link

- `Packages/RimeBridge/Package.swift`
- `Packages/RimeBridge/Sources/RimeBridgeObjC/RimeOctagramModuleShim.{h,mm}`
- `Packages/RimeBridge/Sources/RimeBridgeObjC/RimeDeployer.m`
- `Packages/RimeBridge/Sources/RimeBridgeObjC/RimeSessionManager.m`
- `Packages/RimeBridge/Sources/RimeBridge/RimeBridgeCapabilities.swift`
- `Universe Keyboard.xcodeproj/project.pbxproj` (Keyboard `OTHER_LDFLAGS` force-load)
- `Packages/RimeBridge/Tests/RimeBridgeTests/RimeOctagramCapabilityTests.swift`

## Architecture questions (force independent answers)

1. **Boundary:** Does loading `octagram` in both Main-App deploy traits and Extension session traits preserve “Main App deploys / Extension session-only,” without a second bridge or cross-thread RIME ownership change?
2. **ABI / recipe:** Is pinning octagram as a **separate** static plugin against baseline `librime.a` bytes (librime peer commit `1300e568…`) an acceptable G1 strategy versus rebuilding the entire 11-framework set?
3. **Link retention:** Are `RimeOctagramModuleShim` + Keyboard `-force_load` (octagram + glog) sufficient and necessary, consistent with the Lua pattern, and free of unsafe concurrency / `@unchecked Sendable` shortcuts?
4. **Failure semantics:** If the new pin or module were unavailable, does base `core/dict/gears/lua` remain the documented recovery path, and is rollback to `rime-vendor-ios-1.16.1-lua.1` operationally clear?
5. **Scope leak:** Confirm no `.gram` path, schema patch, App Group model contract, or product copy was introduced under G1.
6. **Provenance residual:** Is retaining the BSD-3-Clause notice + documented stale GPLv3 file-header residual acceptable for this engineering pin, or must G1 stay blocked pending upstream header sync?

## Quality questions (force independent answers)

1. Re-run (do not trust executor summary alone):
   - `bash scripts/ensure_rime_vendor.sh verify` (or `fetch` on clean Vendor)
   - `RimeBridgeTests` including `RimeOctagramCapabilityTests`
   - `Universe Keyboard` scheme `test` (App + Keyboard)
   - Debug and Release builds
2. Confirm slices: device `arm64`; simulator fat `arm64` + `x86_64`; symbol `rime_require_module_octagram` present.
3. Confirm published release asset SHA-256 matches `config/rime-vendor-manifest.env` **from downloaded bytes**.
4. Confirm CI run on PR #63 (`build-and-test` + GitGuardian) is green and covers the merged tip on `main`.
5. Confirm no `.gram` in the vendor zip, repo, or runtime config paths introduced by this change.
6. Assess whether Keyboard dual force-load (octagram + glog) introduces link-size or Jetsam risk that must be measured before any model phase (note: G1 does not authorize that measurement claim).

## Executor verification record (not a substitute for independent re-run)

| Check | Result | Notes |
|---|---|---|
| Recipe build device + sim arm64 + sim x86_64 | Pass | Formal script after Codex probe |
| Release publish + manifest pin | Pass | Tag `rime-vendor-ios-1.16.1-lua.1-octagram.1` |
| `ensure_rime_vendor verify` | Pass | 12 frameworks |
| RimeBridgeTests (iPhone 17 Pro, iOS 26.5) | Pass | Incl. 3 octagram capability tests |
| App Debug / Release build | Pass | Same destination |
| App + Keyboard scheme tests | Pass | After glog force-load |
| PR #63 CI `build-and-test` | Pass | Merged `84250c5` |
| GitGuardian on #63 | Pass | |

## Stop-condition status

No Assignment stop condition was claimed by the executor:

- Provenance and build inputs are pinned (not floating HEAD).
- Main-App / Extension ownership boundary is asserted unchanged.
- No `.gram` / schema / user feature entered the change.
- Independent review is **now** the blocking gate for `Reviewed` / `Closed`.

## Residuals for reviewers to accept, reject, or escalate

1. Upstream `grammar_module.cc` stale GPLv3 file header residual (documented).
2. Plugin compile deployment target **15.0** vs app target **26.4** (explicit artifact contract change).
3. Keyboard must force-load **glog** when force-loading octagram (extension link graph quirk).
4. Full model quality, disk policy, and memory budget remain **TD-012 model G2+** with separate Product Decision.

## Required handoff outcomes

| Reviewer | Required output |
|---|---|
| 🏛️ Architecture | Written accept / reject / conditional; list boundary residuals |
| 🧪 Quality | Written accept / reject / conditional; list re-run receipts or waive with reason |
| Product (later) | Only after both above: `Reviewed` / `Closed` or new gate |

Do **not** start model download, schema wiring, or user-visible “整句增强” from this handoff.

## History

- `2026-08-10`: Architecture Conditional Accept + Quality Conditional Accept filed;
  Assignment lifecycle → `Closed`. Residuals disposed under M-03.
- `2026-08-10`: PR #63 merged to `main` (`84250c5`); remote feature branch deleted; this handoff issued for Architecture → Quality.
