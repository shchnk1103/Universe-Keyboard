# RIME Fuzzy Pinyin

## Purpose

This document covers traditional RIME fuzzy pinyin rules, not small-screen typo correction.

Traditional fuzzy pinyin expands accepted pinyin spellings through RIME `speller/algebra` derive rules. It lets common regional pronunciation pairs produce candidates from the active schema, for example `zongguo` matching candidates that normally come from `zhongguo`.

Typo correction remains a separate KeyboardCore feature documented by `docs/TYPO_BENCHMARK.md`.

## Current Scope

Phase 1 supports four initial-consonant groups:

| Setting | App Group key | Rules |
|---|---|---|
| `zh / z` | `rime_fuzzy_zh_z_enabled` | `derive/^zh/z/`, `derive/^z/zh/` |
| `ch / c` | `rime_fuzzy_ch_c_enabled` | `derive/^ch/c/`, `derive/^c/ch/` |
| `sh / s` | `rime_fuzzy_sh_s_enabled` | `derive/^sh/s/`, `derive/^s/sh/` |
| `n / l` | `rime_fuzzy_n_l_enabled` | `derive/^n/l/`, `derive/^l/n/` |

All four groups default to enabled.

## Deployment Model

Fuzzy pinyin settings are saved by the main App in App Group `UserDefaults`. Toggle changes only mark RIME as needing deployment.

The rules take effect only after the user taps **应用并重新部署** in the main App:

1. Main App prepares the RIME shared and user directories.
2. Main App writes `default.custom.yaml` and schema custom YAML.
3. Main App post-processes the current active schema file:
   - `Rime/shared/{activeSchema}.schema.yaml`
4. Main App runs full librime deployment.
5. Keyboard Extension only reads the compiled result during runtime.

Keyboard Extension must not write YAML, repair schema files, or run deployment for fuzzy pinyin.

## Managed Schema Block

The post-processor preserves existing `speller/algebra` rules and owns only this managed block:

```yaml
speller:
  algebra:
    # universe:fuzzy-pinyin begin
    - derive/^zh/z/
    - derive/^z/zh/
    # universe:fuzzy-pinyin end
```

The processor is idempotent. Running deployment repeatedly updates the existing managed block instead of duplicating rules.

If all fuzzy pinyin settings are disabled, the managed block is removed and original schema rules are left unchanged.

If the active schema has `speller:` but no `algebra:`, deployment creates `speller/algebra` and inserts the managed block.

If the active schema has no `speller:`, deployment skips fuzzy pinyin post-processing and logs a warning without blocking deployment.

## Boundaries

Phase 1 does not implement:

- final-vowel fuzzy pairs such as `en/eng`, `in/ing`, `an/ang`.
- candidate ranking changes.
- typo correction changes.
- Partial Commit changes.
- keyboard UI or candidate bar style changes.
- runtime schema modification inside the Keyboard Extension.

## Validation Matrix

Manual validation should cover both `luna_pinyin` and `rime_ice` as active schemas:

- With `zh / z` enabled, `zongguo` can produce `中国` or related candidates.
- With `sh / s` enabled, `sijie` can produce `世界` or related candidates.
- With `n / l` enabled, `lihao` can produce `你好` or related candidates.
- Disabling the corresponding setting and redeploying removes that fuzzy path.
- Normal inputs such as `zhongguo`, `shijie`, and `nihao` still produce their original candidates.

Because fuzzy pinyin expands spelling acceptance, candidate sets may become wider and noisier. Prefer conservative defaults and keep future expansion benchmark-driven.
