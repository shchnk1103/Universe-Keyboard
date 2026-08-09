# Assignment: TD-012-OCTAGRAM-VENDOR-G1 — Reproducible iOS octagram Vendor Capability

Policy version: 1.0.0

## Current Status

| Field | Value |
|---|---|
| **Lifecycle** | `Ready` — complete Assignment; implementation begins only after this record is on `main` |
| **Phase** | G1 vendor artifact, link and module-registration capability only |
| **Non-claims** | No `.gram`, schema, user setting, download, deployment, memory claim or product release |
| **Next** | 🔧 RIME Platform Maintainer builds the reproducible candidate artifact and records executor evidence |
| **Residuals** | Source header residual retained in [provenance audit](../evidence/td-012-octagram-license-provenance-audit-2026-08-09.md); G2–G6 remain TD-012 debt phases |

---

**Task ID:** `TD-012-OCTAGRAM-VENDOR-G1`
**Date / timezone:** `2026-08-09 Asia/Shanghai`
**Repository Change Type:** `Binary artifact + RimeBridge integration`
**Product Decision source:** [`PD-TD-012-OCTAGRAM-VENDOR-G1`](../product-decisions/TD-012-OCTAGRAM-VENDOR-G1-authorization.md)

## Authority

- **Assignment Authority:** 🧭 Product Lead
- **Decision source / date:** Human Product Lead in-session, `2026-08-09 Asia/Shanghai`
- **Product Approver:** 🧭 Product Lead

## Boundary

### Scope

1. Establish a reproducible, immutable iOS vendor build from the current pinned
   librime ABI and octagram source at
   `bfb168ca33d8b372596fdf2007933f3da1cf360e` or an audited descendant.
2. Add the resulting octagram static artifact to the reviewed vendor inventory,
   manifest, Package dependency graph and Xcode link settings.
3. Add a narrow, explicit module-link/registration path and load `octagram` with
   existing base modules; verify the `grammar` component without recording user text.
4. Publish a new immutable GitHub Release artifact with checksum/receipt, while
   retaining the current vendor release as a rollback point.
5. Run the artifact verifier, strict simulator suites, Debug/Release builds and
   content-free failure-path tests required by this Assignment.

### Non-goals

- Downloading, bundling, deploying, configuring or testing any `*.gram` file.
- Schema changes, candidate-ranking claims, user-facing settings or install UX.
- Main-App/Extension ownership changes, a second RIME bridge, unsafe concurrency,
  raw user-input logging, or automatic activation for any schema/layout.
- Declaring a legal conclusion, product acceptance, device memory budget or release
  readiness from executor evidence alone.

### Required Inputs

- [TD-012 G0 artifact audit](../evidence/td-012-g0-octagram-artifact-audit-2026-08-09.md)
  and [license provenance audit](../evidence/td-012-octagram-license-provenance-audit-2026-08-09.md).
- [G1 readiness plan](../plans/td-012-octagram-vendor-readiness-plan.md),
  [RIME artifact contract](../architecture/rime-artifacts.md), `ADR 0001`, `ADR 0003`,
  `ADR 0004`, `ADR 0008`, the RimeBridge reading map and playbook.
- Current verified vendor `rime-vendor-ios-1.16.1-lua.1` as rollback baseline.
- [KOS 2.1 G-01 artifact Gate](https://github.com/shchnk1103/kos-agent-kit/blob/v0.4.0/ops/third-party-artifact-gate.md).

## Assignment

- **Domain Owner:** 🔧 RIME Platform Maintainer
- **Executor:** Current agent
- **Environment Executor:** Current agent — fixed build host, iOS Simulator and GitHub Release publication only
- **Human Dependency:** `Not Applicable` — G1 excludes physical device, model and user-visible operations
- **Architecture Reviewer:** 🏛️ Architecture & Knowledge Steward
- **Quality Reviewer:** 🧪 Quality, Performance & Release Maintainer

## Gates

### Entry Criteria

- [x] Product Decision records source disposition and G1-only scope.
- [x] Source pin is at/after the public relicense merge and notice residual is recorded.
- [x] Existing `RIME-SCHEME-WANXIANG-001` is `Completed`, so Active Work remains ≤10.
- [x] Current vendor is verified and retained as the rollback baseline.
- [x] Architecture and Quality reviewer roles are named and remain independent from the Executor.

### Exit Criteria

- Reproducible build inputs, toolchain versions, patches, dependency identities and
  source notices are recorded in the vendor provenance Source of Truth.
- A new immutable archive has valid device and simulator slices, a checksum, receipt
  and reviewed inventory; old artifact restoration remains possible.
- Static link evidence proves octagram registration object retention and controlled
  runtime evidence proves `octagram` loads `grammar` without user content.
- Missing/incompatible artifact or module preserves base RIME and Lua behavior.
- `ensure_rime_vendor`, RimeBridgeTests, App/Keyboard strict tests and Debug/Release
  builds pass at the changed pin; no `.gram` appears in the artifact, repo, App Group
  contract or runtime configuration.
- Executor records evidence; independent Architecture and Quality conclusions are
  handed off before `Reviewed`/`Closed` is claimed.

### Stop Conditions

- Source provenance, notice obligations, immutable build inputs or ABI compatibility
  cannot be established.
- A build needs floating upstream HEAD, unreviewed binary substitution or an
  unrecorded patch.
- Module activation changes the Main-App/Extension ownership boundary, makes basic
  input/Lua unavailable, or requires unsafe concurrency.
- Any request introduces a `.gram` file, schema/user feature, device-memory claim or
  release/product claim without a new Product Decision.
- Required independent review is unavailable at the `Completed` handoff boundary.

## Handoff

- **Handoff Target:** 🏛️ Architecture & Knowledge Steward, then 🧪 Quality,
  Performance & Release Maintainer.
- **Required Handoff Content:** source/provenance ledger; build recipe and artifact
  checksum; inventory/slice/symbol/module evidence; failure/rollback result; complete
  test/build receipts; unchanged-boundary statement; residuals and G2–G6 non-claims.
- **Revalidation Trigger:** octagram/librime source or license change, toolchain/ABI
  change, artifact replacement, any `.gram`/schema scope request, or reviewer finding.

## History

- `2026-08-09`: Product authorized this dedicated G1 after TD-012 G0 No-Go and
  accepted the public upstream relicense provenance as its bounded source basis.
