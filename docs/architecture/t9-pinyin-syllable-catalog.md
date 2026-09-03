# T9 Pinyin Syllable Catalog — Source, License, and Generation

**Status:** Accepted for KEYBOARD-LAYOUT-9KEY-PINYIN-004 under ADR 0023  
**Owner:** Input Intelligence Maintainer  
**Date:** 2026-07-22

## Source

| Field | Value |
|---|---|
| In-repo path | `Universe Keyboard/RimeBuiltin/luna_pinyin.dict.yaml` |
| Declared name | `luna_pinyin` |
| Declared version | `2024.02.10` |
| SHA-256 | `75bcf6eb3ff62b129882ed89cc22b2d80a5347aa72bcfa2ccc839bac298e7314` |
| Upstream project | [rime/rime-luna-pinyin](https://github.com/rime/rime-luna-pinyin) |

The dictionary ships in the main App-owned built-in RIME closure. The catalog
generator does not download network resources, and the keyboard extension does
not package the source dictionary.

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

F-02 official Luna baseline after filtering: **424** legal syllables (425 raw
unique tokens minus `xx`). ADR 0023 retains the historical 417 baseline for its
original source; ADR 0033 authorizes this pinned upstream replacement.

Changing the baseline count is an intentional review event (ADR + tests + this document).

## Runtime guarantees

- Extension hot path never reads or parses the YAML/JSON source.
- Path legality queries use the compile-time map only (max 6-digit focus prefixes).
- RIME remains the sole Chinese candidate ranking engine.
