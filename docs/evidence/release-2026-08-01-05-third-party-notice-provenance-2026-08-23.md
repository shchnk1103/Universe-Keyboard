# RELEASE-2026-0801-05 — Third-Party Notice Provenance Recovery

> **Evidence grade:** `Executor-recorded`
>
> **Collected:** `2026-08-23 Asia/Shanghai`
>
> **Boundary:** engineering provenance and byte comparison; not legal advice

## Fixed binary input

- Vendor tag: `rime-vendor-ios-1.16.1-lua.1-octagram.1`
- Archive SHA-256: `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9`
- Required inventory: 12 XCFrameworks from `config/rime-vendor-manifest.env`

## Recovered byte-identical build sources

The device `arm64` static archives below were compared by SHA-256 between the
retained clean local build tree and `Packages/RimeBridge/Vendor`. Matching
bytes bind the recorded source checkout to the shipped archive more strongly
than a project-name-only inference.

| Component | Source revision / input | Device archive SHA-256 |
|---|---|---|
| librime | `rime/librime@1300e568967feeeedd72028c7cb5ef9151f7fb37` | `92c0da52643a7584f020362637dc84f43cf072216b196598a0c825f1392fe8c9` |
| Google glog | `google/glog@53d58e4531c7c90f71ddab503d915e027432447a` | `dfad2c22b7623901dd397d1c67ce8be0b587ef627ba06d9aec32c1bd6ae1f5f6` |
| LevelDB | `google/leveldb@7ee830d02b623e8ffe0b95d59a74db1e58da04c5` | `6aa88f3237855bdf950f3d3a84564296c802e4dd1f863ceb2a1b19a222470011` |
| yaml-cpp | `jbeder/yaml-cpp@4861d049534ed6f2c51c45b01d7c2926022e5f3f` | `829f60aa6135310b1b267f296cf0a45f27417d6d5577cc70e802badd313c86d1` |
| OpenCC | `BYVoid/OpenCC@25350017e81b40aa9e3e66c18446b57f83b0607d` | `488aa4c7ba4714f056bc5dbf350c8ca1b93a724db0f2a986984d02d77a9d9500` |
| MARISA | OpenCC clean build input `deps/marisa-0.3.1` | `c7fb7d88539e647fa52841061a576087b4f80502559938deb7c8284410b455c6` |
| Boost atomic | Boost 1.91.0 from retained `boost-iosx@488c591d305723a9e387526ef0f9ff54d8bc3273` build tree | `6eec18b3588d8071072b4e268e403304ce95463d24a92ad4a3e84ff96ab440e1` |
| Boost filesystem | same input | `49353275d82f66e7478a8dc5f9e151da9662050585c1341109909dec984c8577` |
| Boost regex | same input | `7a67003c214d8d3a3f43d9e27d41d7f507cac58cea139ef3c1c84ece91e86661` |

Octagram remains fixed separately at
`lotem/librime-octagram@bfb168ca33d8b372596fdf2007933f3da1cf360e`.
Its root BSD-3-Clause license and the accepted stale GPLv3 source-header
residual are both reproduced in the App notice resources.

## Other recoverable identities

- `liblua` headers inside the pinned XCFramework identify Lua `5.4.8` and
  `Copyright (C) 1994-2025 Lua.org, PUC-Rio`. The offline MIT notice is copied
  from the official Lua 5.4.8 source package (`lua-5.4.8.tar.gz`, SHA-256
  `4f18ddae154e793e46eeab727c59ef1c0c0c2b744e7b94219710d76f530629ae`).
- `librime-lua` is now bounded to
  `hchunhui/librime-lua@ec52e48ea18f11af37717a01c337f853215cf70b`
  plus a locally reproduced empty `opencc_init` stub: 9/10 members match
  byte-for-byte on device arm64 and Simulator arm64/x86_64. The remaining
  `types.o` object uses Boost.Regex `re_detail_500`. Official 1.88.0 (500)
  and 1.89.0 (600) header inputs were tested against the fixed receipt and
  did not match SHA-256; the exact header tag is a bounded no-match. See the
  dedicated Phase A evidence before making any exact whole-archive claim.

## Content resources

- Rime-ice GPL-3.0-only notice snapshot: `iDvel/rime-ice@75e6572bebc05b49021e842949ce947882e3e4b2`.
- Wanxiang CC BY 4.0 notice snapshot: `amzxyz/rime-wanxiang@c8ab41bf87f4dcf0496e2512c086c58e87a5e4b7`.
- Luna upstream license snapshot inspected at `rime/rime-luna-pinyin@56b934b099dfbeab842320f13aa8b461a6ab3e42`.
- The bundled `luna_pinyin.dict.yaml` Git blob
  `19181e3c3e609f075f0f2ceaf6c97d52d241ad96` is exactly derived from official
  `rime/brise@496683543269746670ee0886fc9c36e31e4a11bf` blob
  `728f883f4dada54841a299ca9fc93ac7ade3cbb7`, with only the Chewing attribution
  URL changed from `chewing.csie.net` to `chewing.im`. Enumeration found no
  exact all-bytes match among 116 split-repository and 132 predecessor blobs.
- Its own header names Rime Developers, CC-CEDICT, Android PinyinIME, Chewing,
  三拼簡繁詞庫 0.9 and OpenCC. The App reproduces that header as a separate
  offline attribution document instead of representing the composite data as
  a single-license work.
- Rime-ice and Wanxiang are fetched only after user action. Their license
  snapshots are pinned to the audit commits recorded in the App catalog
  evidence; a material upstream license/source change requires a new
  `acceptanceRevision`.

## App notice resource verification

- The main App catalog references 15 offline `.txt` resources covering every
  downloadable scheme, bundled Luna content and packaged binary component.
- Luna's detail page links both the LGPL-3.0 text and the GPLv3 text it
  incorporates, plus the separate composite-dictionary attribution record.
- Xcode 27 beta Debug and Release generic iOS Simulator builds succeeded. The
  built Debug `.app` contained all 15 files; the catalog-to-bundle XCTest passed
  on iPhone 17 Pro / iOS 26.0 and verified every referenced file is readable,
  non-empty UTF-8.
- The complete `SchemaManagerTests` runtime attempt passed its first eight tests,
  then the hosted App process hit a native `malloc` invalid-free crash in
  `testDownloadIsBlockedUntilCurrentLicenseRevisionIsAccepted`; Xcode restarted
  and crashed again in the following test. The run was interrupted to stop the
  restart loop and is not claimed as a suite pass. `build-for-testing` passed.

## Residuals

1. `librime-lua`'s `types.o` has no official Boost.Regex tag with an exact
   SHA-256 match; the 1.88.0/1.89.0 header-version boundary is recorded. The
   plugin revision and local OpenCC stub are otherwise byte-supported across
   all shipped architectures.
2. Luna has a complete derivation receipt rather than an exact upstream blob:
   official `brise` blob `728f883…` plus one attribution-URL patch.
3. Human Product Owner accepted both residuals as an external TestFlight
   candidate residual under
   [`PD-RELEASE-2026-0801-05-PROVENANCE-A-ACCEPT`](../product-decisions/RELEASE-2026-0801-05-provenance-a-accept.md)
   and reported saving App Store Connect content rights “Yes”, primary
   category `工具` and secondary category `效率`. This engineering inventory
   is still not legal advice.
