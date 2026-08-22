# RIME Binary Artifacts

## Required Inventory

`Packages/RimeBridge/Vendor/` is intentionally gitignored. A complete installation contains these 12 frameworks:

- `librime.xcframework`, `librime-lua.xcframework`, `librime-octagram.xcframework`, `liblua.xcframework`
- `boost_atomic.xcframework`, `boost_filesystem.xcframework`, `boost_regex.xcframework`
- `libglog.xcframework`, `libleveldb.xcframework`, `libmarisa.xcframework`
- `libopencc.xcframework`, `libyaml-cpp.xcframework`

## Canonical Platform And Slice Contract

This section is the Source of Truth for the platform and architecture slices required by the pinned artifact declared in `config/rime-vendor-manifest.env`. It supports artifact restoration and dependency-resolution verification only; it does not change the artifact, package integration or product deployment target.

Every framework must contain an iOS device `arm64` static-library slice and the listed iOS Simulator slice:

| XCFramework | iOS device entry | iOS Simulator entry |
|---|---|---|
| `boost_atomic.xcframework` | `ios-arm64` (`arm64`) | `ios-arm64-simulator` (`arm64`) |
| `boost_filesystem.xcframework` | `ios-arm64` (`arm64`) | `ios-arm64-simulator` (`arm64`) |
| `boost_regex.xcframework` | `ios-arm64` (`arm64`) | `ios-arm64-simulator` (`arm64`) |
| `libglog.xcframework` | `ios-arm64` (`arm64`) | `ios-arm64_x86_64-simulator` (`arm64`, `x86_64`) |
| `libleveldb.xcframework` | `ios-arm64` (`arm64`) | `ios-arm64_x86_64-simulator` (`arm64`, `x86_64`) |
| `liblua.xcframework` | `ios-arm64` (`arm64`) | `ios-arm64_x86_64-simulator` (`arm64`, `x86_64`) |
| `libmarisa.xcframework` | `ios-arm64` (`arm64`) | `ios-arm64_x86_64-simulator` (`arm64`, `x86_64`) |
| `libopencc.xcframework` | `ios-arm64` (`arm64`) | `ios-arm64_x86_64-simulator` (`arm64`, `x86_64`) |
| `librime-lua.xcframework` | `ios-arm64` (`arm64`) | `ios-arm64_x86_64-simulator` (`arm64`, `x86_64`) |
| `librime-octagram.xcframework` | `ios-arm64` (`arm64`) | `ios-arm64_x86_64-simulator` (`arm64`, `x86_64`) |
| `librime.xcframework` | `ios-arm64` (`arm64`) | `ios-arm64_x86_64-simulator` (`arm64`, `x86_64`) |
| `libyaml-cpp.xcframework` | `ios-arm64` (`arm64`) | `ios-arm64_x86_64-simulator` (`arm64`, `x86_64`) |

Contract rules:

- `SupportedPlatform` must be `ios`; the simulator entry must also declare `SupportedPlatformVariant=simulator`.
- The declared architectures in each XCFramework `Info.plist` and the architectures in its static-library payload must agree with the table.
- All 12 frameworks must satisfy the matrix as one artifact set. A partial intersection is not sufficient.
- Non-iOS entries present in the pinned archive do not satisfy an iOS requirement and are outside the required integration surface. They may remain only as bytes already covered by the pinned archive checksum.
- Homebrew, macOS libraries, source builds and locally substituted slices cannot satisfy this contract.
- Version, URL, archive checksum and framework identity remain owned by `config/rime-vendor-manifest.env`; checksum verification remains mandatory in addition to slice verification.
- Any change to a required platform, architecture set or framework row is an integration-boundary change and requires Architecture and Product revalidation before the manifest or artifact changes.

## Pinned Delivery

Publish a zip archive containing the framework directories at its root as a versioned GitHub Release asset. Record
the exact release asset URL and SHA-256 in the checked-in manifest:

- `config/rime-vendor-manifest.env`

The URL must point to an immutable versioned release asset. Updating the RIME toolchain requires a new release
asset and a reviewed manifest update; never reuse an existing version tag with changed bytes. Until an archive has
actually been published and hashed, the manifest intentionally contains `UNCONFIGURED`. CI must fail in that state;
do not enter placeholder URLs or invented digests to make builds green.

The manifest also lists the exact framework inventory. After a successful download, the verifier checks:

- the archive checksum against the reviewed manifest;
- the receipt stored beside the extracted binaries against that version and checksum;
- the required `.xcframework` directories, valid `Info.plist` files and static library payloads;
- that no additional `.xcframework` appears outside the reviewed inventory.

An existing local `Vendor/` directory without a matching receipt is not considered provenance-verified, even when
its directory names are structurally valid.

## Current Pinned Release

- Release tag: `rime-vendor-ios-1.16.1-lua.1-octagram.1`
- Asset: `universe-keyboard-rime-vendor-ios-1.16.1-lua.1-octagram.1.zip`
- SHA-256: `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`
- Release URL: <https://github.com/shchnk1103/Universe-Keyboard/releases/tag/rime-vendor-ios-1.16.1-lua.1-octagram.1>
- Rollback baseline (no octagram): `rime-vendor-ios-1.16.1-lua.1` /
  SHA-256 `c299f36eae4966a8c22f83046c7015a04b3f047abcc4bab9355ca19ac840436c`

### Grammar / octagram Capability (G1)

The current pin **includes** the static `librime-octagram` plugin and the
module-registration path used by the App and Keyboard (`core + dict + gears +
lua + octagram`). G1 proves only that the concrete `grammar` component can be
discovered after module load.

G1 still does **not** ship, download, deploy, or advertise any `*.gram` model
file, schema patch, or user-facing “整句增强” feature. Those remain TD-012
G2–G6. Build pins and recipe live in
`config/rime-octagram-vendor-build.env` and
`scripts/build_rime_octagram_plugin.sh`. Supporting evidence:

- [TD-012 G0 octagram artifact audit](../evidence/td-012-g0-octagram-artifact-audit-2026-08-09.md) (baseline No-Go)
- [octagram license provenance](../evidence/td-012-octagram-license-provenance-audit-2026-08-09.md)
- [G1 vendor build evidence](../evidence/td-012-g1-octagram-vendor-build-2026-08-10.md)

## Commands

```bash
# Validate an installed pinned artifact and its receipt.
bash scripts/ensure_rime_vendor.sh verify

# Fetch the archive declared in config/rime-vendor-manifest.env.
bash scripts/ensure_rime_vendor.sh fetch
```

The fetch command downloads to a temporary path, checks SHA-256 before extraction, and verifies all required
framework directories before allowing a build to proceed. It is idempotent only when the existing extracted
directory carries a receipt matching the checked-in manifest.

## Xcode Cloud Bootstrap

`ci_scripts/ci_post_clone.sh` is the checked-in Xcode Cloud integration point. It resolves the primary repository
from `CI_PRIMARY_REPOSITORY_PATH`, falls back to the directory containing the local checkout for offline validation,
and invokes the same `scripts/ensure_rime_vendor.sh fetch` contract used by repository CI. It must remain executable
and fail closed when the bootstrap script, manifest, archive checksum, receipt or framework inventory is invalid.

This hook only makes the pinned binary dependencies available to a build. It does not configure an Xcode Cloud
workflow, select an Xcode version, grant repository access, sign an archive, retain dSYMs or authorize TestFlight
distribution. Those properties require a separate Cloud pilot and release evidence against the frozen candidate.

## Publishing Checklist

1. Build the full 12-framework archive, including `liblua.xcframework`,
   `librime-lua.xcframework`, and `librime-octagram.xcframework` (see
   `scripts/build_rime_octagram_plugin.sh` +
   `scripts/assemble_rime_vendor_with_octagram.sh` for the octagram extension path).
2. Upload it as an immutable versioned GitHub Release asset.
3. Calculate SHA-256 from the uploaded archive bytes.
4. Replace all `UNCONFIGURED` values in `config/rime-vendor-manifest.env` in a reviewed change.
5. Run `bash scripts/ensure_rime_vendor.sh fetch`, the simulator bridge tests, a
   Lua-capable schema smoke test, and the octagram capability tests (module +
   `grammar` registry, with no `.gram` file).
