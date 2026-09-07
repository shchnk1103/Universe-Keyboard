# SCHEME-DELIVERY-SOURCE-STATE-001 P1 evidence

Executor-recorded, `2026-09-07 Asia/Shanghai`. Human authorized “继续下一步” after declining device retest. This is the §4 dependency/ownership inventory. It is not ADR 0034 acceptance, not P2 implementation, not merge.

## Frozen inputs

| Item | Value |
|---|---|
| Clone / HEAD | `/private/tmp/uk-scheme-delivery-fix` `2946030` |
| Builtin closure | `Universe Keyboard/RimeBuiltin/` generation `luna-official-2026-08-31-v3` |
| Ice processed tree | `/private/tmp/rime-ice-20260630/withLua` (Lua-on post-process; 60 admitted files) |
| Ice archive SHA | `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` |
| Plans | `rime-ice-plan-1`, `wanxiang-plan-1` in `SchemaManagerTypes.swift` |
| Wanxiang 17.5.9 zip | **absent** this host; recursive Wanxiang refs unresolved |

Should-install logic copied from production `RimeSchemeInstallationPlan.shouldInstall`. Lua-off Ice admits 30 files (drops `lua/`).

## 1. Same-path collisions (installed ∩ installed)

Builtin deployed set: 26 files (manifest members; not `RimeBuiltin.manifest.json`). Ice Lua-on admitted set: 60 files.

| logical path | builtin bytes / SHA-256 | Ice bytes / SHA-256 | kind |
|---|---|---|---|
| `default.yaml` | 1593 / `0628ada1…c0bcc141` | 14842 / `0dacfbac…aca37cd` | **different bytes** |

No other same-path overlap between builtin required paths and Ice admitted paths. Ice `opencc/emoji.json` does not collide with builtin `opencc/s2t.json` etc.

Ice schema `traditionalize.opencc_config: s2t.json` therefore **consumes the builtin file** when both are present. That is approved shared OpenCC, not a second copy.

## 2. Install vs uninstall ownership (Ice)

Ice Lua-on install writes 60 files. `removableFiles` + `removableDirectories` (`cn_dicts`, `en_dicts`) do **not** cover:

| leftover class | count | examples |
|---|---|---|
| `default.yaml` | 1 | shared Prelude collision; P0 `byteCountMismatch` |
| `lua/**` | 30 | flat `date_translator.lua`, `lua/cold_word_drop/*`, `lunar.db` |
| `opencc/**` | 3 | `emoji.json`, `emoji.txt`, `others.txt` |

`rime.lua` is listed as removable but is not in the processed tree and is not admitted by `allowedFiles`. Build-cache substrings (`rime_ice`, `melt_eng`, `radical_pinyin`, `t9`) are compile outputs, not source ownership.

Wanxiang plan (no archive): skips `default.yaml`; allows `lua/` and `dicts/`; `removableDirectories` is only `dicts`. Lua leftovers are the same class of hole. Basename overlap with Ice admitted names, besides skipped `default.yaml`, is empty at the **plan allowlist** layer. `lua/` prefix overlap remains; whether `lua/data/` or root script names collide is **unresolved** without the zip.

## 3. Reference graph (static)

### Builtin

| consumer | kind | target | notes |
|---|---|---|---|
| `default.yaml` | `__include` | `punctuation:/…`, `key_bindings:/…` | official Prelude siblings |
| `luna_pinyin.schema.yaml` | `import_preset` | `default`, `symbols` | official |
| `luna_pinyin.schema.yaml` | `opencc_config` | `t2s.json`, `t2hk.json`, `t2tw.json` | bundled |
| `stroke.schema.yaml` | `import_preset` | `default` | official |
| `default.custom.yaml` (generated) | patch | `schema_list` = active + installed t9/ice/wanxiang | App overlay, user dir |

### Ice (admitted files only)

| consumer | kind | target | resolved? |
|---|---|---|---|
| `rime_ice.schema.yaml` | `__include` | `default:/punctuator` (+ full/half) | **yes, file `default.yaml`**; needs Ice `digit_separators` |
| `rime_ice.schema.yaml` | `__include` | `symbols_v:/symbols` | yes, admitted `symbols_v.yaml` |
| `rime_ice.schema.yaml` | `import_preset` | `default` (recognizer, key_binder) | **yes, file `default.yaml`** |
| `rime_ice.schema.yaml` | lua `@*` | 15 modules under `lua/*.lua` | yes, admitted |
| `rime_ice.schema.yaml` | `opencc_config` | `emoji.json` | yes, Ice `opencc/` |
| `rime_ice.schema.yaml` | `opencc_config` | `s2t.json` | **shared builtin** `opencc/s2t.json` |
| `rime_ice.dict.yaml` | `import_tables` | `cn_dicts/{8105,base,ext,tencent,others}` | yes, admitted prefix |
| `t9.schema.yaml` | `__include` | `rime_ice.schema.yaml:/` | yes |
| `t9.schema.yaml` | `import_preset` | `default` | **same `default.yaml`** |
| `t9.schema.yaml` | user_dict | `custom_phrase_t9` | file **absent** in processed tree; unresolved at runtime |
| `melt_eng.schema.yaml` | `import_preset` | `default` | **same `default.yaml`** |
| `melt_eng.schema.yaml` | `__include` | `algebra_rime_ice` etc. | **same-file YAML keys**, not missing files |
| `melt_eng.dict.yaml` | `import_tables` | `en_dicts/{en_ext,en}` | yes |
| `radical_pinyin.schema.yaml` | `__include` | `default:/key_binder?` | optional; still `default.yaml` |
| Ice `default.yaml` `schema_list` | lists | double-pinyin schemas | those `*.schema.yaml` are **not admitted** by `rime-ice-plan-1` |

Lua static `require`: `date_translator` → `convert_ar_num_to_zh`; `cold_word_drop/processor` → `cold_word_drop.metatable` / `.string`. `dofile`/`loadfile` present in those two files: remaining dynamic refs **unresolved**, not assumed rename-safe.

### Runtime overlay vs Ice `schema_list`

`default.custom.yaml` rewrites `schema_list` to the active schema plus installed `rime_ice`/`t9`/`wanxiang`. Ice’s own `schema_list` (including double-pinyin) is therefore **not** the effective list. The live conflict in `default.yaml` is punctuator / key_binder / recognizer / ascii_composer / switcher / navigator, not the listed extra schemas.

## 4. Candidate A closure check (not a decision)

Keep official Prelude `default.yaml` and give Ice a renamed preset:

| Ice/T9/melt_eng reference | if official `default.yaml` is kept unchanged | A closed? |
|---|---|---|
| `default:/punctuator` + `digit_separators` | official file has no `digit_separators` | **no** — need Ice-owned preset + rewrite |
| `import_preset: default` (key_binder, recognizer) | official bindings/patterns differ | **no** — rewrite to Ice preset |
| `opencc/s2t.json` | share builtin | yes |
| `opencc/emoji.json` | Ice-only path | yes |
| `lua/*` | Ice-owned names | yes for Ice-only; Wanxiang `lua/` still open |
| `schema_list` | already owned by `default.custom.yaml` | yes for listing |

Candidate A remains the preferred **proposal**. It is **not** reference-closed until Ice/T9/melt_eng/radical includes are rewritten to a non-`default.yaml` preset and uninstall ownership covers `lua/` and `opencc/`. Options B/C unchanged: B still undefined merge; C still enlarges session/sync.

Wanxiang recursive closure cannot be claimed without the pinned zip.

## 5. Command

Host Python 3 inventory (should-install copied from production plan; no librime). Inputs: builtin tree + Ice `withLua`. Output: counts above. Not a shipped tool.

## 6. Not done

Independent Architecture review of this inventory; Human Product on plan §5.1; P2 rewrite; device confirmation; Wanxiang zip walk; Lua dynamic `require` proof.
