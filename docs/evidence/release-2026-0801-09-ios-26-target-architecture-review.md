# RELEASE-2026-0801-09 — iOS 26.0 最低部署目标 Architecture Review

**Status:** `No-Go — implementation not authorized`

**Recorded:** `2026-07-21 Asia/Shanghai`

**Review authority:** 🏛️ Architecture & Knowledge Steward

**Product confirmation:** Human Product Owner acting as Product Lead confirmed this No-Go and required evidence publication, `2026-07-21 Asia/Shanghai`.

**Assignment:** [`RELEASE-2026-0801-09`](../assignments/release-2026-08-01-09-ios-26-target.md)

## Scope And Snapshot Metadata

- **Source commit:** `8dc04e8b60822c128248af73f56903a44f9dccca`.
- **Working-tree observation:** `docs/assignments/release-2026-08-01-04-device-performance.md` was already modified and is outside this review. No production file was changed by this review.
- **Project configuration observed:** ten `IPHONEOS_DEPLOYMENT_TARGET = 26.4` entries in `Universe Keyboard.xcodeproj/project.pbxproj`.
- **Local package declarations observed:** `Packages/KeyboardCore/Package.swift` and `Packages/RimeBridge/Package.swift` each declare iOS `26.4`.
- **Toolchain observed:** `Xcode 27.0`, build `27A5228h` (beta).
- **Simulator runtimes observed:** iOS 26.5 (`23F73`) and iOS 27.0; no iOS 26.0 runtime was installed.

This is a configuration/API preflight snapshot. It is not a signed Archive, Quality conclusion, iOS 26.0 runtime test, device test, or release proof.

## Static Preflight Completed

| Check | Method | Result | Boundary |
|---|---|---|---|
| Target inventory | `xcodebuild -list -project "Universe Keyboard.xcodeproj"` | Six project targets and the four shared schemes were discovered. | Inventory only. |
| API availability scan | `rg` scan of Swift/ObjC availability markers | The four explicit iOS-specific guards found are all `#available(iOS 26.0, *)`; no explicit 26.1–26.4 marker was found. | A source scan cannot prove runtime behavior. |
| 26.0 Debug compilation | `xcodebuild` with `IPHONEOS_DEPLOYMENT_TARGET=26.0`, strict concurrency and warnings-as-errors, signing disabled | Passed for the App/Keyboard/KeyboardCore/RimeBridge dependency graph. | Command-line override does not change the checked-in Package declarations and used the beta toolchain. |
| 26.0 Release compilation | Same as Debug, `-configuration Release`, signing disabled | Passed. | Not an Archive and not stable-toolchain evidence. |
| RIME artifact structure | `bash scripts/ensure_rime_vendor.sh verify` | Passed; 11 RIME framework artifacts were structurally present. | Does not establish a minimum iOS runtime version or runtime behavior. |
| Working-tree hygiene | `git diff --check` | Passed at observation time. | Does not include the unrelated pre-existing documentation modification as review scope. |

The Debug and Release commands used separate temporary DerivedData paths under `/private/tmp` and did not modify the project configuration, Package manifests, or production code.

## Architecture Conclusion

The authorized implementation boundary is technically bounded: the project-level/test-target deployment settings and the two local Package platform declarations must move together to iOS 26.0. The current source scan and beta-toolchain compilation did not expose an immediate unavailable-API error.

However, implementation is **not authorized now**. The Assignment requires a usable stable toolchain, and its Stop Conditions prohibit treating a beta-only build as release proof. No iOS 26.0 runtime or physical device is currently available to validate the actual minimum OS behavior. These are Entry-Criteria blockers, not risks that an Executor may accept or bypass.

## Permitted Future Change Boundary

After a new/revalidated Executor appointment, the permitted implementation scope is limited to:

1. the ten checked-in `IPHONEOS_DEPLOYMENT_TARGET` values;
2. the iOS platform declarations in the two local Package manifests; and
3. the current deployment-target statement in `docs/PROJECT_CONTEXT.md`.

Only a compiler-proven API introduced after iOS 26.0 may receive a minimal compatible alternative. Such a change requires the compiler diagnostic and an updated review of its behavior.

## Prohibited Future Changes

- Do not change RIME deployment ownership, Extension hot paths, Vendor/XCFramework contents, entitlements, signing, SDK selection, or product behavior.
- Do not suppress availability diagnostics, weaken warnings/concurrency checks, or add compatibility code without a concrete diagnostic.
- Do not use beta-only builds, a newer OS simulator, or historical evidence as iOS 26.0 release proof.
- Do not archive, upload, submit, or release under this Assignment.

## Re-entry Conditions And Handoff

The task remains blocked until all of the following are available:

1. a stable Xcode/SDK that can build the affected targets;
2. an installed iOS 26.0 Simulator runtime or an iOS 26.0 physical device; and
3. a Product Lead revalidation of the Executor appointment before implementation begins.

After re-entry, the Executor must repeat the configuration audit, Debug/Release strict builds, `KeyboardCore` tests, `RimeBridgeTests`, and the `Universe Keyboard` scheme (including `UniverseKeyboardTests` and `KeyboardTests`) on the supported environment. The Quality Reviewer then records independent results, and task 01 alone validates the final signed Archive.

## Revalidation Trigger

Revalidate this review when the stable Xcode/SDK, installed iOS 26.0 environment, project target matrix, Package platform declarations, API/dependency usage, or release Archive changes.
