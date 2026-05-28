# RIME Binary Artifacts

## Required Inventory

`Packages/RimeBridge/Vendor/` is intentionally gitignored. A complete installation contains these 11 frameworks:

- `librime.xcframework`, `librime-lua.xcframework`, `liblua.xcframework`
- `boost_atomic.xcframework`, `boost_filesystem.xcframework`, `boost_regex.xcframework`
- `libglog.xcframework`, `libleveldb.xcframework`, `libmarisa.xcframework`
- `libopencc.xcframework`, `libyaml-cpp.xcframework`

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
