# RIME Built-In Luna F-02 Upstream Pin And Manifest Audit — 2026-08-29

**Evidence grade:** Executor-recorded read-only repository and upstream audit

**Assignment:** [`RIME-BUILTIN-LUNA-QUALITY-001`](../assignments/rime-builtin-luna-quality-001.md)

**Product decisions:**
[`official runtime closure`](../product-decisions/RIME-BUILTIN-LUNA-QUALITY-001-official-runtime-closure.md) ·
[`Assignment bindings`](../product-decisions/RIME-BUILTIN-LUNA-QUALITY-001-assignment-bindings.md)

## Scope And Non-Claims

This audit proposes immutable **candidate** revisions and the exact source
closure for Architecture review. Official repositories were shallow-cloned to
an isolated temporary directory; no upstream bytes were copied into the
product, no generated artifact was replaced, and no implementation or runtime
claim is made.

The candidates are not accepted production pins until the dependency manifest,
license disposition, fixture deployment and independent Architecture review
pass. This audit is engineering provenance, not legal advice.

## Candidate Revision Set

| Component | Candidate immutable revision | Commit date | Disposition |
|---|---|---|---|
| RIME Luna Pinyin | `rime/rime-luna-pinyin@56b934b099dfbeab842320f13aa8b461a6ab3e42` | `2026-07-12` | Candidate; official current schema/dictionary/pinyin source |
| RIME Essay | `rime/rime-essay@e9b1a374a6ea015fca5bdd04318924b4483ac35a` | `2026-07-13` | Candidate; required preset vocabulary |
| RIME Prelude | `rime/rime-prelude@082425ea0684bca36474415d4a0e8db9b016487e` | `2026-05-09` | Candidate; required default/key/punctuation/symbol presets |
| RIME Stroke | `rime/rime-stroke@1e8fff9b9494ddec23b0cbc526bcfd8171a6fd48` | `2026-08-26` | Candidate; Luna dependency and reverse-lookup dictionary |
| OpenCC runtime/data | `BYVoid/OpenCC@25350017e81b40aa9e3e66c18446b57f83b0607d` | `2026-05-14` | Candidate tied to the existing byte-recovered `libopencc` source receipt |
| librime | `rime/librime@1300e568967feeeedd72028c7cb5ef9151f7fb37` | `2026-05-09` | Existing accepted binary source pin; no change proposed |
| iOS vendor artifact | `rime-vendor-ios-1.16.1-lua.1-octagram.1`, SHA-256 `d17aab9a8b08b5901ab583c143b0a8a03994e36fe092309fd14c5bee31399dd9` | existing | Existing accepted binary pin; no rebuild or model activation proposed |

Plum `b1be1969f914cc005add4090631b855db00c2591` was used only to confirm
official package classification. Plum is not a runtime asset and is not a
candidate bundled dependency.

### Why OpenCC Does Not Follow Current `master`

The existing vendor provenance binds the shipped `libopencc` archive to
`OpenCC@25350017…`. The current upstream `OpenCC@26753884…` changes its JSON
closure to include normalization and additional dictionaries such as
`CJK_Compatibility_Ideographs.ocd2` and `TSCharactersExt.ocd2`. Mixing those
new configs/data with the current binary and four-file legacy deployment would
create an unreviewed toolchain/data upgrade.

F-02 therefore proposes the byte-recovered `25350017…` revision. A later OpenCC
upgrade must move the binary, generator, configs and all referenced dictionaries
as one separately reviewed artifact set.

## Exact Upstream Source Manifest

### Luna Pinyin — LGPL-3.0

| Path | Bytes | SHA-256 |
|---|---:|---|
| `luna_pinyin.schema.yaml` | 2,809 | `668b4d4957e4cc8f9cea32ed3f08f0ecf4a7be8cdba058700507487bd96dd5c7` |
| `luna_pinyin.dict.yaml` | 889,896 | `75bcf6eb3ff62b129882ed89cc22b2d80a5347aa72bcfa2ccc839bac298e7314` |
| `pinyin.yaml` | 4,895 | `caa220b05172bf35775db07fed6ead7719c742e6139232d9797040dbe65f746c` |
| `LICENSE` | 7,651 | `da7eabb7bafdf7d3ae5e9f223aa5bdc1eece45ac569dc21b3b037520b4464768` |
| `AUTHORS` | 273 | `dbf21183999dcd06d4b0f0fe08f7396fcb47cc6f734fd97c3dd851777f1b28f8` |

The product keeps schema ID `luna_pinyin`; the unselected fluency, simplified,
Taiwan and quanpin entry schemas are not runtime dependencies. Simplified
default behavior belongs in the Universe custom overlay rather than a forked
upstream schema.

### Essay — LGPL-3.0

| Path | Bytes | SHA-256 |
|---|---:|---|
| `essay.txt` | 5,887,417 | `a6f8409c261e5d21bd78e6cbcde8f8e1ef7f68c07ff1c2692c07dd4ff4151cea` |
| `LICENSE` | 7,651 | `da7eabb7bafdf7d3ae5e9f223aa5bdc1eece45ac569dc21b3b037520b4464768` |
| `AUTHORS` | 393 | `4ab2f81451ff4819f2b0e346583b49cee37aec72a01f8ecd96be1711c4204b75` |

### Prelude — LGPL-3.0

| Path | Bytes | SHA-256 |
|---|---:|---|
| `default.yaml` | 1,593 | `0628ada16651d56c4cdfcb8e45ddba23d4d585cc8be0580a62c4e077c0bcc141` |
| `key_bindings.yaml` | 3,117 | `ee2476598b4cae89068b823868196eb07b5f72007a600814fe5804b39008b3ed` |
| `punctuation.yaml` | 2,107 | `d6f89592149098f0a2d0ed3e5c83f49adb6226cdf1d967b0bc0d293f4e5c496a` |
| `symbols.yaml` | 28,473 | `6d08969525bd66c67abf1791c99928079356bd0e673386c49c1959d2a52fdbba` |
| `LICENSE` | 7,651 | `da7eabb7bafdf7d3ae5e9f223aa5bdc1eece45ac569dc21b3b037520b4464768` |
| `AUTHORS` | 142 | `9296a3509f1bcaee9e316ff70fccf76bf3a1f19c089b795710808ea5b6a0e6e7` |

Official `default.yaml` remains immutable. Universe generates
`default.custom.yaml` to register only built-in plus actually installed
optional schemes and to set the product page size; it must not regenerate a
second full `default.yaml`.

### Stroke — LGPL-3.0

| Path | Bytes | SHA-256 |
|---|---:|---|
| `stroke.schema.yaml` | 3,056 | `06f680cf7c9d9a69948681ee25e9f6aeccfde4d8d590f93e179d4c4b3caee879` |
| `stroke.dict.yaml` | 3,396,330 | `b3e93dce89c185f45c3d6e189b86b3a8626913352cc85e1094c786579a665791` |
| `LICENSE` | 7,651 | `da7eabb7bafdf7d3ae5e9f223aa5bdc1eece45ac569dc21b3b037520b4464768` |
| `AUTHORS` | 273 | `f0cbba217e049471ccb40751b7d2e1c98144bb2ad4ec15b9f5af057121ec99d6` |

Stroke also declares `use_preset_vocabulary: true`; the same pinned Essay input
must participate when its table is generated. Stroke remains bundled while
Luna's dependency and reverse lookup remain enabled.

### OpenCC — Apache-2.0

The selected Luna schema exposes traditional, simplified, Hong Kong and Taiwan
profiles. Existing S2T resources are retained because the shared runtime also
serves installed schemes; removing them is outside this F-02 boundary.

| Source path | Packaged output | Bytes | SHA-256 |
|---|---|---:|---|
| `data/config/t2s.json` | `opencc/t2s.json` | 424 | `18d64a23de26c39d0e247d36e12d585653f44f2e231c3397050456565581a819` |
| `data/config/t2hk.json` | `opencc/t2hk.json` | 322 | `3d5c1c7540992e821fef56858a001d8ea2720a394975b915fb5944fe42efc0fd` |
| `data/config/t2tw.json` | `opencc/t2tw.json` | 320 | `7b2eb8aa8b76c1e2b1a41e8ce38a327d0aac5e49cfcefe763744b17fdeefb7b5` |
| `data/config/s2t.json` | `opencc/s2t.json` | 424 | `0b86f3aa92c72ac5fcb11bc9df21914ed42f6847416a1d4d7f52f8b5eb861e74` |
| `data/dictionary/TSPhrases.txt` | `opencc/TSPhrases.ocd2` | 5,414 | `c2f9fa5cdc28629b3b9abb480958fa083df82d91be1f4f21e62ae372d8a9dae0` |
| `data/dictionary/TSCharacters.txt` | `opencc/TSCharacters.ocd2` | 34,889 | `ad870b4feeb494cfa7b3b05242bd79af574b22f6b2bdeb89a1633e4b50ed0a3c` |
| `data/dictionary/HKVariants.txt` | `opencc/HKVariants.ocd2` | 770 | `a5ea8ec2061f066bc7c2b4679ea32efb8e169b9b0ce3fb8d0ce6caed65d7df4f` |
| `data/dictionary/TWVariants.txt` | `opencc/TWVariants.ocd2` | 562 | `89473e96e3f61e9bd3f2e303b9d88ac9caa61effb1faadcef94ff5e65b8ed54b` |
| `data/dictionary/STPhrases.txt` | `opencc/STPhrases.ocd2` | 1,007,880 | `fac97e31e69489b38e961d9cbea076326f8ece9daa45d0c386e3ec2a3f2c67cf` |
| `data/dictionary/STCharacters.txt` | `opencc/STCharacters.ocd2` | 34,615 | `9cedfb8bf13a220087103d9a96d9f56050c341c24a809cbce5c85c9045456557` |
| `LICENSE` | offline license document | 9,165 | `b534e465949558eec2597b04f5092b5e161236a68dfbfd04d547592ac3964308` |
| `AUTHORS` | offline attribution | 277 | `cb34e252fa994679bcbfc8355581e821ceda44bd857875e2cfe15b7ec4eec006` |

The SHA-256 values above identify source inputs. Generated `.ocd2` bytes need a
separate receipt recording the exact OpenCC generator binary/source, command,
output byte length and SHA-256. Source hashes must never be substituted for
generated-output hashes.

## Bundle And Overlay Findings

1. Current Luna/OpenCC resources live under `Keyboard/Resources`, which is the
   filesystem-synchronized resource root of `Keyboard.appex`, not the main App
   target. `SchemaArchiveInstaller` reaches into the embedded extension bundle
   and passes that bundle to main-App deployment.
2. The accepted direction moves the single deployable source copy into a
   main-App-owned resource directory. The Extension continues to consume only
   deployed App Group state and must not bundle a second copy.
3. Current deployment overwrites official `default.yaml`, Luna schema and
   OpenCC JSON with Swift string templates. The accepted closure instead keeps
   upstream files byte-identical and expresses product settings through bounded
   `.custom.yaml` overlays.
4. Current managed fuzzy deployment post-processes the shared upstream schema
   in place. It must move to a generated `luna_pinyin.custom.yaml` patch so the
   pinned source hash remains verifiable.
5. The official conversion switch is `switches/@2`, not the minimal schema's
   `switches/@1`; existing simplification custom-patch writers must be migrated
   and covered by a compiled-schema behavior test.
6. Current missing-resource handling writes a text fallback into any missing
   destination, including binary `.bin` or `.ocd2` names. The implementation
   must fail before deployment success and preserve the last known good state;
   it must never manufacture text under a binary resource name.

## Generated Artifact Closure Still Required

Before implementation can enter `Ready`, the plan must name the deterministic
generation path and expected outputs for both dictionaries:

- `luna_pinyin.table.bin`, `luna_pinyin.prism.bin`,
  `luna_pinyin.reverse.bin`;
- `stroke.table.bin`, `stroke.prism.bin`, `stroke.reverse.bin` where produced;
- the six selected OpenCC `.ocd2` files;
- any compiled config files intentionally shipped as prebuilt data.

Every generated output requires byte length and SHA-256. If compiled config
files are not shipped because user/product overlays must be compiled on-device,
that omission must be explicit and first-deploy latency/recovery must be
measured.

The selected upstream source assets total 11,305,513 bytes before licenses,
generated RIME/OpenCC outputs and archive compression. Final App and Extension
size deltas remain `UNKNOWN` until an isolated build is authorized and measured.

## License Disposition

- Luna, Essay, Prelude and Stroke each carry LGPL-3.0 plus distinct `AUTHORS`
  attribution. The existing Luna notice does not cover Essay, Prelude and
  Stroke by name; their notices/attributions must be added to the in-App
  third-party license surface.
- Luna and Essay identify incorporated upstream data including Chewing,
  Android Pinyin IME, OpenCC and moedict; the existing composite-source notice
  must be refreshed against the selected files rather than reduced to a generic
  LGPL label.
- Stroke identifies CNS11643-derived and other contributed data; its `AUTHORS`
  record must remain available with the distributed source/artifacts.
- OpenCC remains Apache-2.0 and needs its license plus attribution preserved.
- No legal sufficiency claim is made by this engineering audit.

## Architecture Review Questions

1. Accept `OpenCC@25350017…` as the data/generator compatibility pin for the
   current byte-recovered `libopencc`, instead of adopting current master.
2. Accept moving immutable built-in sources from `Keyboard.appex` to the main
   App bundle, with no duplicate Extension copy.
3. Accept official byte-identical YAML/JSON plus generated `.custom.yaml`
   overlays as the Source-of-Truth model.
4. Decide whether prebuilt dictionary binaries remain the first-run strategy or
   whether source compilation can meet measured deployment and recovery gates.
5. Confirm that the absent grammar configuration/model leaves the already
   linked octagram component at capability-only G1 and does not reopen TD-012.
