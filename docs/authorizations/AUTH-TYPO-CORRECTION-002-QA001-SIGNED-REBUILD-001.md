# Authorization: AUTH-TYPO-CORRECTION-002-QA001-SIGNED-REBUILD-001

> **Reconciliation notice — 2026-09-20:** The original interpretation below
> treated the normal `codesign --entitlements` output as proof that the
> Simulator Mach-O lacked App Group entitlement. That interpretation is
> superseded by [`Simulator App Group/signing reconciliation`](../evidence/typo-correction-002-simulator-app-group-signing-reconciliation-2026-09-20.md):
> the current Simulator App and Keyboard Mach-O sections contain the shared
> App Group, and the runtime log reaches the shared container. This historical
> Authorization remains stopped and non-reusable; the notice does not consume,
> reopen or expand it, and does not establish physical-device signing.

## Current Status

| Field | Value |
|---|---|
| Status | `stopped — unconsumed; no local Apple Development identity; do not reuse` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Purpose | Establish an App Group-capable signed Simulator package before a new QA-001 capture |
| Issuer | Human Product Owner / Product Lead, current Codex task, `2026-09-20 Asia/Shanghai` |
| Rebuild Run ID | `TC2-SIM-20260920-200549-SIGNED-REBUILD-01` |
| Replaces | Unconsumed `AUTH-TYPO-CORRECTION-002-QA001-REVALIDATION-004`, whose unsigned package lacked runtime App Group entitlement |

This Authorization permits one bounded signing rebuild and reinstall in the
isolated execution worktree. It exists because the prior Simulator package was
built with `CODE_SIGNING_ALLOWED=NO`; that package cannot establish the App
Group runtime boundary and must not be used for QA evidence.

The authorized attempt was stopped after the resulting package reported
`Signature=adhoc`, `TeamIdentifier=not set` and empty entitlements for both the
App and Keyboard Extension. The host still reported `0 valid identities found`
for codesigning, so no App Group-capable package was accepted and this
Authorization must not be reused.

## Exact source and target boundary

- Worktree: `/private/tmp/universe-keyboard-typo-correction-002-parent-revalidation-003`
- Branch: `codex/typo-correction-002-parent-revalidation-003`
- Code-source commit: `3f9f2652b03279a99537639f4382b48bb58548ca`
- Execution checkout: `19bc90f` (only the Authorization document was added after the code snapshot)
- Designated target: iPhone 17 Pro Max / iOS 27.0 Simulator,
  UDID `06C5BC3E-7599-4761-A1A2-71DAEA991474`
- Scheme: `Universe Keyboard`, configuration `Debug`
- Team: `C33N6HTS9N`
- Signing mode: Xcode Automatic signing using the existing Apple Developer account
- App bundle: `com.DoubleShy0N.Universe-Keyboard`
- Keyboard bundle: `com.DoubleShy0N.Universe-Keyboard.Keyboard`
- Entitlement required in both bundles: `group.com.DoubleShy0N.Universe-Keyboard`
- RIME vendor manifest remains fixed at
  `rime-vendor-ios-1.16.1-lua.1-octagram.1` with archive SHA-256
  `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`

## Allowed actions

- Build the existing App and Keyboard Extension with signing enabled; do not
  change Swift, entitlements, bundle identifiers, Team settings or RIME
  manifest.
- Reinstall the resulting signed package on the designated Simulator. Do not
  erase the Simulator or alter unrelated applications.
- Read and record the signed App/Extension identity, executable hashes,
  signing authority and `com.apple.security.application-groups` entitlement.
- Read-only verify that the App Group container is available to the signed
  installation.
- If the signed package passes those checks, allow the user-facing RIME
  settings to retry the already-pinned `rime_ice` deployment. The deployment
  result is setup evidence only; it is not QA-001 evidence by itself.

## Stop conditions and non-claims

- Stop if no Apple Development signing identity or valid provisioning state is
  available. Do not create certificates, edit project signing settings or
  change the Team under this Authorization; request a separate human setup
  action instead.
- Stop if either bundle lacks the App Group entitlement or the container cannot
  be read after installation. Do not retry RIME downloads as a substitute.
- A successful signed rebuild does not prove sidecar observability, candidate
  recovery, INT-003, paired performance, Product/Quality/Release Gates or
  parent closure.
- This Authorization does not authorize a new QA input capture, commit, push,
  PR, merge, TestFlight, Release or Assignment closure. A successful rebuild
  requires a separate fresh QA-001 Authorization and Run ID.
