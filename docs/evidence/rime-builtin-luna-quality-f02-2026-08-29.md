# RIME Built-In Luna F-02 Reproduction And Resource Audit — 2026-08-29

**Evidence type:** Human physical-device observation plus read-only repository,
bundle-resource and isolated RIME table audit

**Assignment:** [`RIME-BUILTIN-LUNA-QUALITY-001`](../assignments/rime-builtin-luna-quality-001.md)

## Evidence Header

| Field | Value |
|---|---|
| Device | iPhone 13 Pro |
| OS | iOS `27.0 (24A5424a)` |
| Host App | Apple Notes |
| Layout / schema | Chinese 26-key / built-in `luna_pinyin` |
| Distribution | Local development build after the background-sync repair; not TestFlight |
| Evidence-associated checkout | `efa009fbe1ad360b393480d617e7452272d4eb6b` (`docs: record background sync reviews and KOS status`) |
| Binary implementation provenance | PR [#91](https://github.com/shchnk1103/Universe-Keyboard/pull/91), repair commit `e3e5d77`; PR remains unmerged and is out of scope for this Assignment |
| Project version in the inspected checkout | `MARKETING_VERSION=1.0`, `CURRENT_PROJECT_VERSION=1` |
| Exact installed binary commit/build metadata | `UNKNOWN` — the checkout and PR identify provenance, but the installed binary did not expose an independently captured commit receipt |
| Input privacy | Only synthetic strings `ni`, `nihao`, `li`, `sanjiaoxing`; no private user text recorded |

## Human A/B Results

### Full Access

With Full Access off and on, `sanjiaoxing` produced `三角形`. The current
development build on this device therefore did not reproduce the historical
Build 7 claim that multi-character composition always failed with Full Access
off. This does not invalidate the original iPhone 16 Pro / iOS 18 observation;
the build, device and OS differ.

### Managed fuzzy pinyin

With fuzzy pinyin enabled, `ni` and `nihao` were polluted by the `li` candidate
path. A separate `li` screenshot showed the same rare-character family, which
is consistent with the default managed `n / l` derive rules.

After fuzzy pinyin was disabled and main-App deployment completed:

- `ni` began with rare characters rather than `你`;
- the visible order matched `㘈、㞾、䁥、䛏、䦧、伱、伲`;
- `nihao` began with `㘈好` rather than `你好`;
- `li` remained a separate `li` candidate path, proving that disabling fuzzy
  changed expansion but did not repair baseline weighting.

The screenshots were supplied as `IMG_7939.PNG` through `IMG_7945.PNG` in the
human-controlled local evidence handoff. Repository evidence records only the
non-private observations and filenames; it does not copy unrelated Photos or
Notes data into source control.

## Repository And Artifact Correlation

The bundled dictionary declares `sort: by_weight` and
`use_preset_vocabulary: true`, but the inspected repository contains no
`essay.txt`. Deployment preparation copies `luna_pinyin.dict.yaml` and three
precompiled binaries, while no preset vocabulary is copied.

The checked-in resources at `origin/main` (`7f20f3a`) were:

| Resource | Bytes | SHA-256 |
|---|---:|---|
| `luna_pinyin.dict.yaml` | 282450 | `971baa1f38a42d3d82f858b5bbdcad6482371f8d93a2f5d5c4ab341046419e3b` |
| `luna_pinyin.schema.yaml` | 699 | `8155d20d2b4233554f25f9504b193b1d20d28c90e218b77d055f4bc74135d563` |
| `luna_pinyin.table.bin` | 10968 | `90c3afaee64b47bea4a76b8162fda0696e87022271501f5e6b5ec6757f5609aa` |
| `luna_pinyin.prism.bin` | 2364 | `ae374c44c68f6968444c6fc54f5f70f7d93c0fe16f7c0f7e4394ba63b7740eb8` |
| `luna_pinyin.reverse.bin` | 9396 | `3c5fd7f1b11e5008ab7e78606a698a309febecf85053f13240e9a20dc0d355fba1` |

Decompiling the checked-in table reported only 225 entries and included the
small common baseline `你` and `你好`. By contrast, an isolated full deployment
from the checked-in 29k-line dictionary without `essay.txt` produced 29,226
entries. Its `ni` range began exactly:

```text
㘈  ni
㞾  ni
䁥  ni
䛏  ni
䦧  ni
伱  ni
伲  ni
你  ni
```

That order matches the post-fuzzy-off physical-device candidates. The evidence
therefore establishes a functional cause: full deployment generated a broad
table without the expected preset weighting. The exact device-container hashes
were not extracted, so the precise overwrite timing remains an implementation
verification item rather than a completed device-artifact claim.

## Resource Closure Audit

Official RIME packages classify Prelude and Essay as essentials. The official
Luna package carries its dictionary/schema plus `pinyin.yaml`; its current full
schema also references Prelude presets, Stroke reverse lookup and multiple
OpenCC profiles. The current App instead writes a smaller app-owned schema and
generated `default.yaml`, so the implementation must choose one coherent
strategy rather than mix partial files from both.

Current minimal-schema mandatory closure:

- generated `default.yaml`, `installation.yaml` and authoritative Luna schema;
- pinned Luna dictionary;
- pinned official `essay.txt`;
- T2S OpenCC config plus `TSPhrases.ocd2` and `TSCharacters.ocd2`;
- retained S2T config/data while that shared conversion capability is shipped;
- matching or deliberately omitted precompiled table/prism/reverse artifacts;
- license, attribution and immutable source/hash receipts.

Additional closure if the official full Luna schema is adopted:

- Luna `pinyin.yaml`;
- Prelude `default.yaml`, `key_bindings.yaml`, `punctuation.yaml`, `symbols.yaml`
  unless each reference is replaced by a tested app-owned equivalent;
- Stroke schema/dictionary while the dependency/reverse lookup remains;
- all OpenCC configs/dictionaries referenced by enabled Hans/Hant/HK/TW filters;
- grammar/model artifacts only under a separate Product/Architecture decision.

The official sources used for the dependency classification are:

- <https://github.com/rime/rime-luna-pinyin>
- <https://github.com/rime/rime-essay>
- <https://github.com/rime/rime-prelude>
- <https://github.com/rime/rime-stroke>
- <https://github.com/rime/plum>

No upstream branch, tag or commit is selected by this audit. Immutable pins,
byte lengths, SHA-256 and license review are Entry Criteria for implementation.

## Conclusion

- **Current candidate-quality reproduction:** `Established`.
- **Functional cause:** preset weighting absent from the full compiled table;
  managed fuzzy pinyin amplifies but does not create the failure.
- **Historical Build 7 exact multi-character root cause:** `UNKNOWN`.
- **Release impact:** `P1`; the built-in offline scheme cannot be
  considered normal-user-ready while common inputs rank rare characters first.
- **Implementation status:** not authorized; Assignment responsibilities and
  immutable resource pins remain pending.
