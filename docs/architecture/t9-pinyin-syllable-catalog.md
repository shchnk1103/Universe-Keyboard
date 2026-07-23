# T9 Pinyin Syllable Catalog — Source, License, and Generation

**Status:** Accepted for KEYBOARD-LAYOUT-9KEY-PINYIN-004 under ADR 0023  
**Owner:** Input Intelligence Maintainer  
**Date:** 2026-07-22

## Source

| Field | Value |
|---|---|
| In-repo path | `Keyboard/Resources/luna_pinyin.dict.yaml` |
| Declared name | `luna_pinyin` |
| Declared version | `0.12.20120711` |
| SHA-256 | `971baa1f38a42d3d82f858b5bbdcad6482371f8d93a2f5d5c4ab341046419e3b` |
| Upstream project | [rime/rime-luna-pinyin](https://github.com/rime/rime-luna-pinyin) |

The dictionary is already shipped inside this application’s keyboard resources for RIME. The catalog generator does not download network resources.

## License and attribution

- Upstream `rime-luna-pinyin` is published under **LGPL-3.0** (see the upstream repository license file).
- The in-repo YAML header attributes Rime Developers and lists component data sources (CC-CEDICT, Android PinyinIME lineage, Chewing, OpenCC, etc.).
- The compile-time Swift catalog (`T9PinyinSyllableCatalog.generated.swift`) is a **derived table of unique legal syllable spellings** extracted from that dictionary’s code column. It does not embed Chinese headwords or full dictionary entries.
- Distribution of the generated table remains subject to the same LGPL-3.0 obligations that already apply to shipping the source dictionary with the app (or the project’s existing RIME resource license policy). If legal counsel requires a separate NOTICE entry, add it under the main license inventory without changing runtime Path behavior.

## Generation

```bash
python3 scripts/generate_t9_pinyin_syllable_catalog.py
```

(Path is lowercase `scripts/`.)

### Syllable filter policy

1. Collect lowercase ASCII tokens from the dictionary code column after the YAML body marker (`...`).
2. **Reject** explicit unknown-reading placeholders: `xx`, `xxx`, `xxxx`.
3. **Reject** tokens with no Mandarin vowel letter in `{a,e,i,o,u,v}`.
4. De-duplicate, sort, map to T9 digit signatures, emit Swift source with provenance fields.

Baseline after filtering: **417** legal syllables (418 raw unique tokens minus `xx`).

Changing the baseline count is an intentional review event (ADR + tests + this document).

## Runtime guarantees

- Extension hot path never reads or parses the YAML/JSON source.
- Path legality queries use the compile-time map only (max 6-digit focus prefixes).
- RIME remains the sole Chinese candidate ranking engine.
