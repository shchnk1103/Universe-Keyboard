# Scheme Platform P3 — Redundant fork cleanup (2026-09-12)

**Assignment:** [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](../assignments/scheme-delivery-scheme-platform-001.md) (**Active**)
**Branch:** `codex/scheme-platform-001`
**P2 tip (Done):** `7c93904` — hosted CI run `34672873379` full green; Simulator product smoke Pass (`wanxiang_preset` present; schemas rewritten; Prelude default intact; typing OK)
**Exit Criteria (P3):** 「冗余 forks 删除计划完成或 Human 书面保留清单」— satisfied by this written DELETE + KEEP plan **and** completed safe deletions in this slice.
**Non-claims:** **no** ADR Accept; **no** Product Gate / TestFlight; **no** Assignment Close; **no** undraft/merge #102; leave #101 alone; leave `.codex-p4-wip.patch` untracked; **no** Wanxiang nine-key; **no** Discovery UI; **ask before push**.

## P2 closeout (context)

| Item | Value |
|---|---|
| P2 | **Done** on tip `7c93904` |
| Hosted CI | Full green — run `34672873379` |
| Product smoke | Simulator Pass — Wanxiang `privatePreset` / `wanxiang_preset`; schemas rewritten; Prelude `default.yaml` intact; typing OK |
| Assignment | Keep **Active** (Exit still needs P3 written keep-list + deletions) |
| Next | P3 (this doc + implementation) |

---

## 1. DELETE / route this slice

Safe redundant forks removed or re-routed behind registry/hooks. Behavior unchanged for production letter-schema paths.

| # | Item | Action | Evidence / notes |
|---|---|---|---|
| D1 | `SchemaManager.rimeIceDownloadState` | **Rename** → `downloadState` | P0 interfaces marked P3 TBD. Call sites: `SchemaManager` (+Download/+Installation), `RimeSettingsStore.downloadState`, tests (`SchemaManagerTests`, `RimeSettingsStoreTests`, `NineKeyEnableTransactionTests`). UI already consumed via store `downloadState`. Behavior unchanged. |
| D2 | `SchemaManager+Download.postProcessingRevision(for:)` Ice/Wanxiang-only switch | **Drop switch**; call `SchemeAdapterRegistry.postProcessingRevision(for:)` directly | Thin P1-1 bridge removed. Unknown ids → `nil`. Download production paths pass letter ids; `t9` inherits Ice revision via registry normalize (consistent with other seams). |
| D3 | Ice T9 sanitize fork `if schemaID == "rime_ice"` → `sanitizeT9SchemaIfPresent` | **Route** via `SchemePostExtractHooks` / `shouldSanitizeT9OnExtract` | New `SchemePostExtractHooks` (mirror of `SchemeUninstallHooks`). Ice only; Wanxiang/Luna/unknown = no-op. Sanitize implementation stays in App. |
| D4 | Ice `ensureCompatibleT9Schema` fork `if schemaID == "rime_ice"` pre-deploy | **Route** via `SchemePostExtractHooks` / `shouldEnsureCompatibleT9PreDeploy` | Same Ice-only hook kind `.iceT9SanitizeAndPreDeploy`. Behavior identical for Ice letter id. |

---

## 2. KEEP (explicit Human keep-list)

Intentional leftovers **not** forced this slice. Written retain reasons satisfy Exit when paired with completed D1–D4.

| # | Item | Keep reason |
|---|---|---|
| K1 | Display-name switches（`雾凇` / `万象` / `朙月`）in Settings / Home / Activation | No trivial registry display-name field yet; cosmetic only; out of P3 mutation-pipeline scope |
| K2 | `SchemeAdapterRegistry` itself + capability matrix content sources (`RimeSchemeCapabilityMatrix`, adapter field tables) | **Platform core** — not redundant forks |
| K3 | Test assertions matching schema IDs (`rime_ice` / `wanxiang` / `luna_pinyin` / `t9`) | Correctness pins; must stay literal |
| K4 | Discovery / layout-picker UI + try-failure state machine docs | Explicitly out of scope (later Assignment) |
| K5 | Wanxiang nine-key enablement (`supportsNineKey=false`, `wanxiang_t9*` ownership-only) | Human deferral; must **not** enable this Assignment |
| K6 | A34-R1 / ADR 0034 Accept | Explicitly later; Pause ≠ Done. **Revisit path after P3 only** — no Accept in this slice |
| K7 | Mirrored Ice UI booleans `rimeIceLicenseAccepted` / `rimeIceVersion` (+ uninstall clears; Settings `licenseAccepted` / `rimeIceVersion` projections) | Catalog/storage-driven `licenseAccepted(for:)` / `installedVersion(for:)` already exist; mirrored fields still feed Ice-shaped UI. Half-migrating mid-slice risks Settings/Guide regressions → **KEEP** until dedicated UI/storage cleanup slice with coverage |
| K8 | Ice-named helpers still useful as Ice reference (`forceRedownload`/`fetchAndDownload` default `"rime_ice"` entry points; `rimeIceFilesExist`) | Convenience / legacy entry points; not production `schemaID ==` pipeline forks |
| K9 | RimeBridge / deploy smoke / session-recovery Ice fallbacks | Cross-package runtime contracts; not Scheme Platform Download forks; changing needs separate regression |
| K10 | Layout Settings Ice-install gates (`schemaID == "rime_ice" && !isRimeIceInstalled`) | Product nine-key still Ice-shaped; tied to K5 deferral |
| K11 | `.codex-p4-wip.patch` (untracked) | Human: leave untracked; not part of P3 |
| K12 | Draft PR #101 / #102 undraft-merge | Leave #101 alone; no undraft/merge #102 without auth |

---

## 3. A34-R1 / ADR Accept revisit path (note only)

After P3 Exit (this plan + D1–D4 landed), Human may **revisit** A34-R1 disposition / ADR 0034 Accept prep on the Paused Wanxiang P4 track. **This slice does not Accept** ADR 0034, does not Close Wanxiang P4, and does not undraft #101/#102.

---

## 4. Tests / format (this slice)

- KeyboardCore: `SchemePostExtractHooksTests` (Ice-only hooks; Wanxiang/Luna/unknown no-op; `t9` → Ice family)
- App/unit: rename call sites for `downloadState` in existing SchemaManager / RimeSettingsStore / NineKey tests
- Prefer iOS 18 Simulator when running UI-related tests
- `xcrun swift-format format` + `lint --strict --configuration .swift-format` on touched Swift

---

## 5. Commit / push policy

- Local commit(s) only for P2 docs closeout + P3 cleanup
- **Ask before push**
- No Assignment Close; keep Active until Human confirms Exit / next phase
