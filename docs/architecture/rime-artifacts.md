# RIME Binary Artifacts

## Required Inventory

`Packages/RimeBridge/Vendor/` is intentionally gitignored. A complete installation contains these 11 frameworks:

- `librime.xcframework`, `librime-lua.xcframework`, `liblua.xcframework`
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
| `librime.xcframework` | `ios-arm64` (`arm64`) | `ios-arm64_x86_64-simulator` (`arm64`, `x86_64`) |
| `libyaml-cpp.xcframework` | `ios-arm64` (`arm64`) | `ios-arm64_x86_64-simulator` (`arm64`, `x86_64`) |

Contract rules:

- `SupportedPlatform` must be `ios`; the simulator entry must also declare `SupportedPlatformVariant=simulator`.
- The declared architectures in each XCFramework `Info.plist` and the architectures in its static-library payload must agree with the table.
- All 11 frameworks must satisfy the matrix as one artifact set. A partial intersection is not sufficient.
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

- Release tag: `rime-vendor-ios-1.16.1-lua.1`
- Asset: `universe-keyboard-rime-vendor-ios-1.16.1-lua.1.zip`
- SHA-256: `c299f36eae4966a8c22f83046c7015a04b3f047abcc4bab9355ca19ac840436c`
- Release URL: <https://github.com/shchnk1103/Universe-Keyboard/releases/tag/rime-vendor-ios-1.16.1-lua.1>

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

## Publishing Checklist

1. Build the full 11-framework archive, including `liblua.xcframework` and `librime-lua.xcframework`.
2. Upload it as an immutable versioned GitHub Release asset.
3. Calculate SHA-256 from the uploaded archive bytes.
4. Replace all `UNCONFIGURED` values in `config/rime-vendor-manifest.env` in a reviewed change.
5. Run `bash scripts/ensure_rime_vendor.sh fetch`, the simulator bridge tests and a Lua-capable schema smoke test.
