# ADR 0018: Keyboard Layout Nine-Key And T9 Runtime Selection

## Status

Accepted; V1 implementation complete

Accepted after Codex Architecture/Quality review on `2026-07-16 Asia/Shanghai`. Final Spike gate re-review (`docs/evidence/keyboard-layout-9key-001-codex-rereview-2.md`) authorized Assignment `Ready -> Active` for plan steps 3–10. Implementation code-review closed (`docs/evidence/keyboard-layout-9key-001-codex-implementation-rereview-3.md`). Product Gate **PASS** (`docs/evidence/keyboard-layout-9key-001-product-gate-decision.md`); Assignment KEYBOARD-LAYOUT-9KEY-001 is `Closed`. Spike technical direction (pinned librime `1.16.1` + remove `t9_processor`) remains the V1 contract.

## Context

Universe Keyboard currently presents a 26-key layout and stores the user-visible RIME base scheme (for example `rime_ice` or `luna_pinyin`) in App Group settings. Product requires a Chinese nine-key layout that depends on rime-ice's `t9` schema, while English and automatic-English keyboard types remain on the existing QWERTY path.

Upstream rime-ice ships `t9.schema.yaml` with schema ID `t9` and digit algebra mappings (`ABC → 2`, `DEF → 3`, …). That schema also declares `t9_processor`, which is not present in the repository-pinned librime modules. Nine-key is therefore not a skin-only change: layout, effective RIME scheme, preedit display, delete and commit semantics must stay consistent, and the main App remains the only writer of RIME deployment resources (ADR 0001).

A mandatory isolated Spike proved that removing the unsupported `t9_processor` declaration is sufficient for digit input to produce composition/candidates and correct BackSpace behavior on pinned librime `1.16.1`. No librime vendor upgrade is required for V1 unless a later regression invalidates that proof.

## Decision

### 1. Stable layout setting

Introduce a public, stable layout style in KeyboardCore:

- `KeyboardLayoutStyle.twentySixKey` — default
- `KeyboardLayoutStyle.nineKey`

Persist it in App Group with a stable raw value. Missing, undecodable or unknown values always resolve to `twentySixKey`.

### 2. Base scheme vs effective scheme

Keep the user-visible base scheme in the existing `rime_active_schema` setting. Do **not** store `t9` as the user-selected base scheme.

Compute an effective runtime scheme with a pure resolver (for example `RimeRuntimeSelection`):

| Base scheme | Layout | T9 readiness matches current resources | Effective scheme | Effective layout |
|---|---|---|---|---|
| `rime_ice` | 26-key | any | `rime_ice` | 26-key |
| `rime_ice` | 9-key | yes | `t9` | 9-key |
| `rime_ice` | 9-key | no | `rime_ice` | 26-key (safe) |
| other | any | any | base scheme | 26-key (safe) |

“T9 readiness matches current resources” means the stored readiness marker is present **and** its compatibility version / resource fingerprint still matches the installed T9 artifacts (see §3). A bare historical boolean is not sufficient.

`RimeEngineImpl` and Objective-C session auto-recovery must consume the same effective-scheme result; they must not independently re-derive defaults.

### 3. Versioned T9 readiness marker

Do **not** rely on a lone opaque boolean as the long-term contract.

Persist a main-App-owned readiness marker in App Group, for example under `rime_t9_ready` with companion fields (or one versioned payload) that includes at least:

- `ready: Bool` — only `true` after successful install + deploy + T9 smoke verification
- `compatibilityVersion: String` — Universe Keyboard T9 compatibility contract version (bumped when the patch rules or required algebra change)
- `resourceFingerprint: String` — stable digest of the installed/verified T9 resources (at minimum the deployed compatible `t9.schema.yaml` bytes; may include required companion files when productized)
- optional: upstream schema version / source tag for diagnostics

Read rules:

- Extension and resolver treat readiness as **matched** only when `ready == true` **and** `compatibilityVersion` equals the current code contract **and** `resourceFingerprint` matches the on-disk verified artifacts.
- Any missing field, decode failure, version mismatch or fingerprint mismatch is **not ready** → safe 26-key behavior even if layout preference says nine-key.
- Only the main App may write or clear the marker. Keyboard Extension may read it; it must never deploy RIME resources or mutate readiness during typing.

### 4. Ordered enable / disable / uninstall / base-scheme switch

Write order is part of the product contract. Implementations must not reorder these steps ad hoc.

#### Enable nine-key (new install or re-verify)

1. Install/update T9 artifacts as needed (including compatible schema generation).
2. Main-App full deploy that includes `t9`.
3. T9 smoke verification (select `t9`, digit input produces candidates/composition, delete reduces one raw digit, session cleaned).
4. Write readiness marker (`ready=true` + compatibility version + resource fingerprint).
5. **Only then** persist layout preference `nineKey`.

If any step before 5 fails: leave layout at previous usable value (default/safe 26-key), do not write `nineKey`, and leave readiness unmatched/false. Never optimistically write `nineKey` and fix asynchronously.

#### Disable nine-key / uninstall rime-ice (or remove T9 resources)

1. Persist layout `twentySixKey` first (keyboard remains typable immediately).
2. Invalidate readiness (`ready=false` and/or clear fingerprint so the marker no longer matches).
3. Delete T9 / rime-ice resources and related build/cache artifacts as required by uninstall.
4. Show a user-visible reason when the action was forced by uninstall or failure.

#### Switch base scheme away from rime-ice (T9 files still installed)

1. Persist layout `twentySixKey` (effective runtime cannot use nine-key without rime-ice base).
2. **Do not** clear readiness solely because the base scheme changed.
3. If T9 files remain complete and the readiness fingerprint still matches, keep the readiness marker so returning to rime-ice + choosing nine-key does not force a redundant redeploy/reverify.
4. If the switch operation also removes or corrupts T9 files, invalidate readiness after layout fallback (same order as uninstall steps 1–2).

#### Switch base scheme back to rime-ice

- If readiness still matches current resources, user may select nine-key without repeating full install; a cheap integrity check against the fingerprint is still required before showing ready.
- If readiness does not match, follow the enable sequence from deploy/verify as needed.

#### Switch layout back to 26-key while keeping rime-ice

- Persist `twentySixKey` only.
- Keep rime-ice installed.
- Do **not** auto-revert base scheme to 朙月拼音.
- Keep readiness if T9 resources remain valid.

#### Interruption recovery (every boundary)

Filesystem and App Group writes are not one atomic transaction. After any crash, kill or power loss, the next main-App open must reconcile to a safe state:

| Last completed step | Recovery |
|---|---|
| Install incomplete / partial files | Treat as not ready; layout must not be `nineKey` (or force `twentySixKey`); prompt repair/reinstall |
| Deploy failed or interrupted | Readiness unmatched/false; keep previous layout; do not claim nine-key ready |
| Verify failed | Do not write readiness; do not write `nineKey` |
| Readiness written, layout not yet `nineKey` | Safe: still 26-key until user/enable path finishes; optional retry may set `nineKey` only after re-check of fingerprint |
| Layout `nineKey` written but fingerprint later mismatches | Effective layout falls back to 26-key until re-verify succeeds |
| Uninstall after layout fallback but before resource delete | Keyboard remains 26-key; residual files may be cleaned on next launch; readiness already unmatched |
| Uninstall after readiness invalidation but before full delete | Same as above; never leave effective nine-key active without matched readiness |

Resolver rule always wins at runtime: unmatched readiness → 26-key effective layout, even if a stale `nineKey` preference exists. Stale `nineKey` without matched readiness must be corrected to `twentySixKey` (or ignored by the resolver) on the next main-App reconciliation path.

### 5. Client compatibility layer

1. Validate upstream `t9.schema.yaml` source, version and required digit algebra.
2. Generate a Universe Keyboard compatible schema (and optional `t9.custom.yaml`) that removes processors unsupported by the pinned librime, starting with `t9_processor`.
3. Preserve upstream provenance and license metadata.
4. Include `rime_ice`, `t9` and existing fallback schemes in the main-App deployment list so layout switches do not require a fresh compile mid-typing.
5. The readiness fingerprint must cover the compatible artifacts actually verified, not only the unpatched upstream file.

### 6. Deployment ownership

- Main App owns download, install, deploy, T9 verification, readiness writes and uninstall cleanup (ADR 0001, ADR 0006 direction).
- Extension only opens prepared directories and runs sessions (ADR 0004).

### 7. Input semantics boundary

T9 is input semantics, not only key arrangement:

- Digits 1–9 on the Chinese nine-key alphabet page go to RIME.
- Raw digit strings remain the RIME composition source for delete/recovery.
- Visible preedit prefers highlighted/first candidate **comment** when non-empty; otherwise falls back to raw digits for **display only**. An empty composition bar is forbidden while raw digits remain.
- BackSpace deletes one raw digit via RIME.
- Letter-based typo correction must not consume T9 digit strings.
- Candidate selection continues to use RIME candidate references.

#### Unconditional no-raw-digit host commit

While a T9 composition is active (raw digit input non-empty / RIME composing under effective scheme `t9`):

- **Return**, **language switch** (中/英), and **automatic English keyboard-type switch** must **never** commit the raw digit string (for example `64426`) into the host document.
- This rule is unconditional: it does **not** depend on candidate presence or whether the visible preedit currently shows digits or comments.

Required behavior by action when T9 composition is active:

| Action | Candidates available | Required behavior |
|---|---|---|
| Space | yes | Commit highlighted candidate; if none highlighted, commit first candidate |
| Space | no | **No host commit** of raw digits; **keep composition** so the user can continue typing or delete |
| Return | yes | Commit highlighted/first candidate; do not commit raw digits |
| Return | no | **No host commit** of raw digits; **keep composition** (do not insert newline while composing T9 digits) |
| English / auto-English switch | yes or no | **No host commit** of raw digits; **abandon/clear composition** using existing abandon semantics, then show QWERTY |
| Page/lifecycle abandon | yes or no | Existing abandon semantics; **no** implicit raw-digit commit |

Display fallback to raw digits is allowed only in the composition bar. Host commit paths must never treat raw digits as commit text under T9 composition.

### 8. Failure fallback

Any incomplete nine-key transaction keeps the previous usable 26-key configuration. The keyboard must remain typable. Layout preference is persisted to `nineKey` only after readiness is written successfully (enable order §4).

## Alternatives Considered

- Ship upstream `t9` unchanged, including `t9_processor`: rejected because the pinned librime does not provide that processor.
- UI-only nine-key that maps digits locally without a RIME T9 scheme: rejected because preedit, candidates, delete and recovery would diverge from RIME state.
- Save `t9` as the user-visible active scheme: rejected because scheme management would conflate layout mode with base scheme choice and break uninstall/fallback messaging.
- Allow Extension emergency deploy to “fix” missing T9: rejected by ADR 0001.
- Upgrade/replace pinned librime before Spike: rejected; Spike proved current artifact works with a compatibility schema.
- Single boolean readiness without fingerprint: rejected by Architecture review; cannot prove which T9 resources were verified.
- Clear readiness on every non-rime_ice base-scheme switch: rejected; forces useless redeploy when returning to rime-ice with intact T9 files.
- Forbid raw-digit commit only when candidates exist: rejected; empty-candidate paths could still dump `64426` into the host.

## Consequences

- Settings and runtime must share one resolver for layout + versioned readiness + base scheme.
- rime-ice install/uninstall surfaces grow T9 artifacts, fingerprinting and ordered readiness/layout writes.
- Keyboard Extension nine-key rendering is gated by Chinese mode, alphabet page, layout preference and matched readiness.
- Product docs must state that advanced 26-key capabilities may not all apply to nine-key V1.
- Implementers have no discretion to commit raw T9 digits on Return/language switch.

## Risks

- Fingerprint definition that is too narrow may miss companion-file drift; too wide may force unnecessary reverify.
- Prism/dictionary deploy cost for `t9` may be large and must stay on the main-App path.
- `essay` read-only warnings observed during Spike deploy need investigation in product deploy packaging; they did not block the Spike.
- Users may confuse base scheme rows with layout mode if UI copy is unclear.

## Follow-up Work

- Implement KeyboardCore layout setting, versioned readiness marker and pure effective-scheme resolver.
- Implement main-App ordered enable/disable/uninstall and base-scheme switch behavior.
- Implement Bridge `T9PreeditResolver` and unconditional no-raw-digit commit paths.
- Implement Extension nine-key chrome and main-App settings thumbnails.
- Update `docs/KEYBOARD_LAYOUT.md`, `docs/RIME_SCHEME_MANAGEMENT.md`, `docs/PROJECT_CONTEXT.md`, `docs/RELEASE_CHECKLIST.md` and `CHANGELOG.md` from the final implementation.
- Keep Spike harness assertions strong (candidates and preedit required) and provenance commit-bound.

## Related Documents

- `docs/plans/keyboard-layout-9key-implementation-plan.md`
- `docs/assignments/keyboard-layout-9key-001.md`
- `docs/KEYBOARD_LAYOUT.md`
- `docs/architecture/shared-container-and-rime-lifecycle.md`
- `docs/architecture/input-pipeline-and-marked-text.md`
- `docs/architecture/rime-artifacts.md`
- ADR 0001, ADR 0003, ADR 0004, ADR 0006, ADR 0008
