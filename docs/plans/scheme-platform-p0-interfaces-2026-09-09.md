# Scheme Platform P0 — Proposed interfaces / seams (2026-09-09)

**Status:** P0 docs draft (Assignment Active). **Not** Swift; **not** ADR Accept; **not** Product Gate / TF.  
**Assignment:** [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](../assignments/scheme-delivery-scheme-platform-001.md)  
**North star:** [`scheme-platform-ice-reference-target-2026-09-09.md`](scheme-platform-ice-reference-target-2026-09-09.md) (Human Approved)  
**Companion matrix:** [`../evidence/scheme-platform-p0-ice-wanxiang-matrix-2026-09-09.md`](../evidence/scheme-platform-p0-ice-wanxiang-matrix-2026-09-09.md)  
**Frozen tip base:** `origin/main` @ `814abfd`; branch `codex/scheme-platform-001`

**Legend:** **Decided** = Human-approved target / existing production contract to preserve. **Proposed (P0)** = interface shape for P1 extract review. **TBD** = needs Human/Architecture before Swift.

Ice is the **reference implementation**. P1 extracts Ice hooks into these seams with **Ice behavior unchanged**. Wanxiang migrates in P2 via adapters — not a second platform.

---

## 0. Design rules (Decided)

1. Minimize production `if schemaID == …`. Scheme divergence lives in **manifest + adapters**.
2. Never whole-directory wipe of `lua/` or `opencc/`.
3. Never overwrite Prelude / official `default.yaml`.
4. Active uninstall → **Luna-only** (await successful Luna deploy before stage→commit); peers may remain installed but are **not** auto-selected.
5. Fail-closed at every mutation boundary: no success receipt until deploy; restore selection + files / keep upgrade checkpoint per existing contracts.
6. Cross-scheme preserve rules: [`scheme-delivery-cross-scheme-matrix-contract-2026-09-08.md`](scheme-delivery-cross-scheme-matrix-contract-2026-09-08.md).

---

## 1. Lifecycle seam

### 1.1 Pipeline (Decided shape; Proposed API names)

Unified mutation pipeline for install / upgrade / uninstall:

| Step | Responsibility | Ice reference today | Platform note |
|---|---|---|---|
| **download** | Pinned source variant / digest / staged identity | `SchemaManager+Download` + catalog manifest variants | Keep pin / staged-identity gates |
| **filter plan** | Admit / skip / rewrite per plan | `RimeSchemeInstallationPlan.shouldInstall` | Plan stays declarative |
| **stage-verify** | Content + ownership checks before commit | Staged identity SHA; post-process then verify | Fail-closed before live replace |
| **upgrade checkpoint** | Prior generation when replacing | Ice has install path; Wanxiang `createUpgradeCheckpoint` | **Proposed:** one `UpgradeCheckpointing` protocol; Ice + Wanxiang both call it |
| **install** | Commit lease; write owned paths only | `installSchemaFiles(plan:luaAvailable:)` | Lease unchanged (ADR 0001/0018 boundaries) |
| **deploy** | Main App deploy before claiming success | Deploy phase in download pipeline | No success UI/receipt until deploy OK |
| **receipt** | Success only after deploy | Existing success state | Unchanged contract |
| **fail-closed restore** | No success receipt; restore selection+files / keep checkpoint | Active-uninstall Luna fail; Wanxiang upgrade rollback | Shared restore orchestration |

### 1.2 Proposed types (P0 sketch — P1 names may rename)

```text
protocol SchemeLifecycleCoordinator {
  func install(scheme: SchemeIdentity, intent: SchemeMutationIntent) async throws -> SchemeMutationReceipt
  func upgrade(scheme: SchemeIdentity, intent: SchemeMutationIntent) async throws -> SchemeMutationReceipt
  func uninstall(scheme: SchemeIdentity, mode: UninstallMode) async throws -> SchemeMutationReceipt
}

enum UninstallMode { case activeLunaOnly; case inactivePreservePeers }

protocol UpgradeCheckpointing {
  func createCheckpoint(plan: InstallationPlanView, sharedRoot: URL) throws -> UpgradeCheckpoint?
  func restore(_ checkpoint: UpgradeCheckpoint) throws
  func commit(_ checkpoint: UpgradeCheckpoint)  // success path only
}

protocol UninstallStaging {
  func stage(plan: InstallationPlanView, ownership: ResourceOwnershipStrategy) throws -> StagingHandle
  func commit(_ handle: StagingHandle) throws
  func rollback(_ handle: StagingHandle) throws
}
```

| Item | Status |
|---|---|
| Pipeline order download→…→receipt | **Decided** |
| Active vs inactive uninstall outcomes | **Decided** (§2.2 target plan) |
| Exact protocol / type names in Swift | **TBD** (P1 naming) |
| Whether Ice upgrade checkpoint must match Wanxiang byte-for-byte API on day-1 extract | **TBD** — P1 may wrap Ice path first, unify signatures in P1.1 |

### 1.3 Fail-closed invariants (Decided)

- Mid-copy / mid-deploy failure with peer installed → peer generation retained; no success receipt (`CS-F1`).
- Active-uninstall Luna/fallback deploy failure → original selection + files retained (`CS-F2`).
- Staging mid-move failure → target restored; peer untouched (`CS-F3`).
- Double-failure on uninstall rollback → keep staging checkpoint (existing repair contract).

---

## 2. Layout capability seam

### 2.1 Problem (Ice reference / current forks)

Today nine-key is effectively Ice-shaped:

- `RimeRuntimeSelection.isNineKeyCapable` → only `"t9"`.
- T9 enable path writes `schemeBinding9 = "t9"` and depends on Ice install / readiness (`SchemaManager+T9Layout`, route `dependencySchemaIDs: ["rime_ice"]`).
- `RimeSchemeCapabilityMatrix.normalizeSchemaID`: `"t9"` → `"rime_ice"`.
- Wanxiang ships `wanxiang_t9.schema.yaml` / `wanxiang_t9i.schema.yaml` in plan **allowedFiles**, but product nine-key capability is **not** Ice-parity.

### 2.2 Proposed capability model

```text
struct LayoutCapability: Equatable, Sendable {
  var supports26Key: Bool
  var supports9Key: Bool
  var nineKeySchemaIDs: [String]     // e.g. ["t9"] for Ice; future ["wanxiang_t9", ...]
  var twentySixKeySchemaIDs: [String]
  var nineKeyDependencies: [String]  // schemes that must be installed/ready
}

protocol SchemeLayoutAdapter {
  var layout: LayoutCapability { get }
  // Human-approved uninstall layout-fallback (2026-09-09): warn → ready A-only rebind among
  // remaining installed (override > Universe package manifest > adapter; never B; unready A
  // not auto-rebind) → else 26-key + Luna/luna_pinyin (+ clear invalid nine-key) → then uninstall.
  // Luna always on 26-key A; never nine-key A. See discovery-layout-ux doc.
  func onUninstallPrepare(layoutBindings: inout LayoutBindingState) // Ice: prepareRimeIceUninstallWithLayoutFallback
  func normalizeSettingsSchemaID(_ raw: String) -> String
}
```

| Item | Status |
|---|---|
| 26 / 9 / future layouts are **declarative / plugin**, not `if schemaID == rime_ice` product logic | **Decided** = **P1 seams** (this Assignment) |
| Ice `t9` + readiness + binding9 behavior as reference *shape*; adapter lookup replaces `isNineKeyCapable == t9` with **identical Ice-only answers** | **Decided** = **P1 seams** |
| Wanxiang adapter `supportsNineKey = false` (no enablement in P1/P2) | **Decided** = **P1 seams** |
| Wanxiang nine-key productization (which schema id, readiness, chrome) | **Human deferred** — later Assignment (not yet drafted); may ride Discovery later or stay further deferred. `wanxiang_t9*` may stay in plan ownership; product capability stays false |
| **Installed Capability Discovery / layout-picker** (dynamically enumerate installed schemes’ capabilities for layout UI) | **Human deferred** — later Assignment (not yet drafted); **separate Human Active**; **not** P1 |
| **Discovery layout-page UX** (26 / 9 / future settings page) | **Decided** for later Discovery Assignment — see [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md): **A Confirmed** = user override > package capability manifest ([`universe-capabilities/v1`](scheme-platform-universe-capabilities-v1-2026-09-09.md); Universe convention, not RIME built-in; validation failure voids entire manifest) > catalog adapter declaration (installed + `supported=true`); **B Filename suggestions (try)** = weak filename/`schema_id` hints (e.g. t9/nine), labeled unverified, user may try; **never auto-write binding** from filename alone; confirm/success **promotes** to A; filename never sole authority / **not** a manifest field (RIME has no official layout-naming constraint); catalog may generate equivalent; default unsupported if none. Wanxiang nine-key still deferred (`wanxiang_t9*` may appear in B later). **Luna:** always on 26-key A; never on nine-key A; not a B suggestion; builtin exception. **Readiness:** confirmed-but-unready → greyed in A with reason (prefer grey over hide); click guides fix; no direct binding until ready. **Not P1 UI** (P1 may add readiness **query** seams if needed) |
| **Uninstall layout-fallback** (scheme backs current binding(s)) | **Decided** — [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md): **warn** (not silent) → **ready** A-only among remaining installed (**never** B; unready A not auto-rebind) → rebind (previously used > primary > stable default) **or else** 26-key + Luna (`luna_pinyin`) + clear invalid nine-key → then uninstall; Luna-only active-uninstall still applies. Consumed by `onUninstallPrepare` / UninstallHooks |
| Future layouts beyond 26/9 | **TBD** — reserve capability flags only |

### 2.3 P1 extract guidance（Human-approved `2026-09-09`）

- Extract declarative `LayoutCapability` from Ice’s current T9 path without changing Ice UX (**P1 seams**).
- Replace hardcoded `isNineKeyCapable == (id == "t9")` with adapter lookup **backed by Ice adapter returning the same Ice-only nine-key answers**.
- Wanxiang adapter: **`supportsNineKey = false`** — do **not** enable Wanxiang nine-key in P1/P2.
- **Out of P1:** Installed Capability Discovery / layout-picker (dynamic enumeration of installed schemes for layout UI) — **later Assignment (not yet drafted)**; separate Human Active. Today’s asymmetry note: `isTwentySixKeyCapable` ≈ “not `t9`” vs nine-key hardcode `== "t9"`; Discovery Assignment owns picker honesty, not this extract.
- **Decided Discovery UX (later Assignment; not P1 UI):** layout settings page Sections **A/B** — A Confirmed authority = user override > package capability manifest ([`universe-capabilities/v1`](scheme-platform-universe-capabilities-v1-2026-09-09.md); Universe convention, not RIME built-in; void on validation failure) > catalog adapter declaration (installed + `supported=true`; catalog may generate equivalent) > default unsupported; B = filename/`schema_id` suggestions (try), labeled unverified, **never auto-bind**, confirm→promote to A; filename never sole authority (RIME no official layout-naming constraint). **Luna** always on 26-key A; never on nine-key A; not a B suggestion; builtin exception. **Confirmed-but-unready** → greyed in A with reason (prefer grey over hide); click guides fix; no direct binding until ready. Full rules: [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md). **P1** may add readiness **query** seams if needed (not the UI).
- **Decided uninstall layout-fallback (hook contract):** when uninstall deletes a scheme backing current layout binding(s) — warn → **ready** A-only rebind among remaining installed (**never** B; unready A not auto-rebind) → else 26-key + Luna/`luna_pinyin` (+ clear invalid nine-key) → then uninstall; Luna-only active-uninstall still applies. `onUninstallPrepare` / UninstallHooks must follow [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md).

---

## 3. Resource ownership seam (lua / opencc / dicts)（Human Decided `2026-09-09`）

### 3.1 Ice reference today

- Plan `removableFiles` / `removableDirectories` / `removableBuildFileSubstrings` list Ice-owned lua scripts, emoji opencc files, `cn_dicts`/`en_dicts`, etc. (`rime-ice-plan-2`) — **`namedList`** strategy (Ice reference).
- Uninstall staging moves plan paths only (plus Wanxiang exact-hash hook when plan matches Wanxiang).
- `lua/` and `opencc/` prefixes are **allowlists for install**, not ownership proofs.
- Unknown / user / peer / Prelude baselines preserved (matrix §3).

### 3.2 Wanxiang today

- Plan removable list covers named schemas/dicts + `dicts/` directory; **lua not on removableFiles**.
- `WanxiangLuaOwnership.sha256ByPath` + `matchingWanxiangLuaPaths` (gated by `wanxiang.schema.yaml` + `wanxiang-plan-1`) adds **`exactHash`** lua paths at checkpoint/uninstall.
- Unknown or edited lua bytes left untouched.
- **OpenCC:** Wanxiang may keep **`admitted=false`** (no wholesale opencc admit); still uses the **same** ResourceOwnership / ResourceCapability API.

### 3.3 Proposed unified API

```text
protocol ResourceOwnershipStrategy {
  /// Paths eligible for uninstall / upgrade-checkpoint capture under preserve rules.
  func ownedPaths(sharedRoot: URL, plan: InstallationPlanView) throws -> [OwnedPath]

  /// Install admission already covered by plan; optional extra checks.
  func verifyAdmission(stagedRoot: URL, plan: InstallationPlanView) throws
}

enum OwnershipMatch {
  case namedList                 // Ice reference — plan removable / named paths
  case exactHash(String)         // Wanxiang — exact content hash
  case directoryOwned            // e.g. cn_dicts / dicts — still not whole lua/opencc
}

struct OwnedPath {
  var relativePath: String
  var match: OwnershipMatch
}
```

| Item | Status |
|---|---|
| Unify behind one **ResourceOwnership** / ResourceCapability API (P1 extract) | **Decided** (`2026-09-09`) |
| **Long-term dual strategies:** Ice **`namedList`** + Wanxiang **`exactHash`** — **not** forced to one | **Decided** |
| Forbid whole-`lua/` / `opencc/` wipe | **Decided** |
| **No** dangerous filename heuristics auto-removing lua/opencc | **Decided** |
| Settings: confirmed ownership/strategy honesty; optional user marking for third-party; heuristics only as confirm-gated hints if ever | **Decided** |
| OpenCC: Wanxiang may keep `admitted=false`; same API | **Decided** |
| **P1:** wire Ice+Wanxiang strategies; behavior unchanged | **Decided** |
| **P2:** Wanxiang uses platform path **keeping `exactHash`** (Ownership stays dual; contrast SharedDefault → `privatePreset`) | **Decided** |
| Exact strategy registration mechanism (manifest pointer vs code plugin table) | **Proposed (P0)** — prefer manifest pointer + small plugin registry |
| Opencc shared-with-builtin files (e.g. Ice `s2t.json` share case) uninstall policy | **TBD** if not already covered by plan omit — do not invent counters (ADR §5.1) |
| Generalizing `exactHash` beyond Wanxiang pin | **TBD** — pin-bound until Human extends |
| **Product-surface honesty for Lua/OpenCC** (UI that dynamically reflects installed ownership/capabilities) | **Human deferred** — later Assignment with Installed Capability Discovery (not yet drafted); **not** P1 seam extract |

### 3.4 P1 extract guidance（Human-approved `2026-09-09`）

- Introduce `ResourceOwnershipStrategy` / ResourceCapability ownership seams; Ice strategy = **`namedList`** (plan removable / named paths); Wanxiang strategy = **`exactHash`**; Lua/OpenCC ownership via **strategy APIs** (**P1 seams**).
- Keep `matchingWanxiangLuaPaths` as Wanxiang **`exactHash`** strategy **called through the same API** (may still live behind Wanxiang adapter in P1 without behavior change).
- **Do not** auto-remove lua/opencc via dangerous filename heuristics; Settings honesty = confirmed ownership/strategy; optional user marking for third-party; heuristics only as confirm-gated hints if ever.
- Delete the `schemaFileName == wanxiang…` special-case only when Wanxiang adapter is registered (P2 preferred; P1 may leave a thin bridge). **P2** migrates Wanxiang onto the platform path **keeping `exactHash`** — Ownership does **not** consolidate to a single strategy (unlike SharedDefault → `privatePreset`).
- **Out of P1:** product-surface Discovery honesty for Lua/OpenCC (enumerate installed ownership/capabilities in UI) — **later Assignment (not yet drafted)** with layout-picker Discovery; separate Human Active.

---

## 4. Shared-default / preset policy seam

### 4.1 Ice reference (P2+ production)

`RimeIceSharedDefaultAdapter`:

- Copy upstream `default.yaml` → `rime_ice_preset.yaml`.
- Rewrite `__include: default:/` and `import_preset: default` in admitted schemas (`rime_ice`, `t9`, `melt_eng`, `radical_pinyin`).
- Plan `skippedFiles` includes `default.yaml` so Prelude is never installed over.
- Hook: `SchemaManager+Download` `if schemaID == "rime_ice" { adaptIceSharedDefault }`.

### 4.2 Wanxiang today (transitional — not end-state)

- Plan skips `default.yaml` (Candidate A) / may surface as skip or `consumePrelude`-shaped transitional adapter.
- **No** private preset rewrite adapter **yet**.
- Product does not claim Ice-parity shared defaults **today**.
- **Human Decided (`2026-09-09`):** this skip/`consumePrelude` shape is **P1 transitional only**; **P2 end-state** = Ice-shaped **`privatePreset`** (same mode as Ice). `consumePrelude` is **not** Wanxiang end-state.

### 4.3 Proposed policy + adapter

```text
enum SharedDefaultPolicy {
  case neverInstallDefaultYAML          // both Ice + Wanxiang (always)
  case privatePreset(PrivatePresetSpec) // Ice reference = third-party SharedDefault end-state
  case skipOnly                         // Wanxiang transitional (P1); not end-state
  case consumePrelude                   // Wanxiang transitional label (P1 bridge); not end-state
}

struct PrivatePresetSpec {
  var presetConfigName: String   // "rime_ice_preset"
  var presetFileName: String     // "rime_ice_preset.yaml"
  var schemaFilesToRewrite: [String]
}

protocol SharedDefaultAdapter {
  var policy: SharedDefaultPolicy { get }
  func applyPostExtract(in extractionDirectory: URL) throws
}
```

| Item | Status |
|---|---|
| Never overwrite Prelude `default.yaml` | **Decided** |
| SharedDefault **end-state** for third-party schemes = Ice-shaped **`privatePreset`** (reference mode) | **Decided** (`2026-09-09`) |
| **P1:** extract Ice `privatePreset` only; Wanxiang may temporarily keep skip / `consumePrelude` as transitional adapter | **Decided** |
| **P2:** Wanxiang migrates to `privatePreset` (same mode as Ice); `consumePrelude` is **not** Wanxiang end-state | **Decided** |
| Luna may remain Prelude / builtin exception | **Decided** |
| Wanxiang preset migration **fidelity risk** → needs **product regression** (not a silent change) | **Decided** note |
| Moving `RimeIceSharedDefaultAdapter` behind `SharedDefaultAdapter` without Ice behavior change | **Proposed (P0)** — P1 extract |

---

## 5. Per-scheme adapter surface + manifest

### 5.1 Manifest (Decided roles; Proposed fields)

Each third-party scheme contributes a declarative manifest (today mostly `RimeSchemeCatalogEntry` + `RimeSchemeInstallationPlan` + distribution pins):

| Field group | Examples today | Platform |
|---|---|---|
| Identity | `schemaID`, version, license | Keep |
| Pin / staged identity | source variants, archive SHA, staged content SHA, plan/post revisions | Keep |
| Install plan | allowed/skipped/removable sets | Keep as `InstallationPlanView` |
| Layout capabilities | **missing as data** — hardcoded elsewhere | **Add** `LayoutCapability`; on-disk / query via Human-finalized [`universe-capabilities/v1`](scheme-platform-universe-capabilities-v1-2026-09-09.md) (`layouts.twentySixKey` / `nineKey`) |
| Ownership strategy id | Ice = **`namedList`**; Wanxiang = **`exactHash`** (long-term dual) | **Add** strategy id(s); manifest `resources.lua.strategy` = `named-list`\|`exact-hash`\|`none`; `resources.opencc.admitted` (+ optional `namedFiles`) |
| Shared-default policy | Ice post-2 adapter; Wanxiang skip | **Add** policy id; manifest `sharedDefault.mode` = `private-preset`\|`consume-prelude` (+ `presetFile` when private-preset) |
| Package capability file | **missing** | **Decided** — `universe-capabilities.yaml` at package root → shared dir; `format: universe-capabilities/v1`; validation failure **voids entire manifest**; priority user override > manifest > catalog adapter > default unsupported; catalog may generate equivalent via adapters; community ships file or import wizard; filename heuristics **not** manifest fields |
| Post-process revision | `rime-ice-post-2` / `wanxiang-post-1` | Keep; bind to adapter |

### 5.2 Optional adapters (Proposed registry)

```text
struct SchemePlatformAdapters {
  var sharedDefault: SharedDefaultAdapter?
  var layout: SchemeLayoutAdapter
  var ownership: ResourceOwnershipStrategy
  var postProcess: SchemePostProcessAdapter?   // fuzzy/advanced/T9 prepare hooks
  var uninstallHooks: SchemeUninstallHooks?    // layout fallback, license flags, UI state
}

protocol SchemePostProcessAdapter {
  var revision: String { get }
  func apply(in extractionDirectory: URL, luaAvailable: Bool) throws
}
```

| Adapter | Ice reference | Wanxiang today → P2 |
|---|---|---|
| SharedDefault | `RimeIceSharedDefaultAdapter` (`privatePreset`) | P1 transitional skip/`consumePrelude` → **P2 end-state `privatePreset`** (same as Ice); not optional |
| Layout | T9 readiness + binding9=`t9` + uninstall layout fallback | 26-key only productized; nine-key **Human deferred** (later Assignment; not P1/P2 enablement) |
| Ownership | **`namedList`** (Ice reference) | **`exactHash`** (`WanxiangLuaOwnership`) — **long-term dual**; P2 keeps `exactHash` on platform path (contrast SharedDefault → `privatePreset`) |
| PostProcess | Ice shared-default + existing Ice post | `wanxiang-post-1` (keep) |
| UninstallHooks | `prepareRimeIceUninstallWithLayoutFallback` (**Human-approved fallback:** warn → ready A-only rebind / else Luna+26; see discovery-layout-ux), Ice license/version UI | generic path; fewer Ice-only UI forks |

### 5.3 Catalog / coordinator boundary (Proposed)

```text
protocol SchemePlatformCatalog {
  func entry(schemaID: String) -> SchemePlatformEntry?
  func adapters(for schemaID: String) -> SchemePlatformAdapters
}

// P1: thin façade over RimeSchemeCatalog + hardcoded Ice adapters.
// P2: Wanxiang adapters registered; Download/Installation stop branching on schemaID for these concerns.
```

| Item | Status |
|---|---|
| Manifest + optional adapters per scheme | **Decided** (target §3) |
| Ice adapters are reference | **Decided** |
| Exact module placement (KeyboardCore vs Main App Services) | **TBD** — prefer keep Main-App mutation in Services; pure adapters in KeyboardCore when already there (`RimeIceSharedDefaultAdapter`) |
| UI download-state still named `rimeIceDownloadState` | **TBD** cleanup in P3 (not P1 behavior) |

---

## 6. P1 extract map (docs guidance only)

Ordered for **Ice behavior unchanged**:

1. **SharedDefaultAdapter** — wrap `RimeIceSharedDefaultAdapter` (`privatePreset`); replace `schemaID == "rime_ice"` post-process call with adapter lookup. Wanxiang stays transitional skip/`consumePrelude` in P1; **P2** migrates Wanxiang to `privatePreset`.
2. **ResourceOwnershipStrategy** — wire Ice **`namedList`** + Wanxiang **`exactHash`** through same protocol without changing hashes/pins/behavior; **long-term dual** (not forced to one). P2 Wanxiang uses platform path keeping `exactHash`.
3. **Lifecycle helpers** — `UpgradeCheckpointing` + uninstall staging already mostly plan-driven; remove Wanxiang-only private helpers from installer core where safe.
4. **LayoutCapability** — P1 seams: Ice nine-key answers identical via adapter lookup; Wanxiang `supportsNineKey=false`; no Wanxiang nine-key enablement. Discovery / layout-picker = later Assignment (not this extract).
5. **Regression** — Ice install/uninstall/T9/active-uninstall automation + authorized IQ.

Stop if Ice UX/install/uninstall drifts without Human accept.

---

## 7. Non-goals (this P0 doc)

- Swift implementation / P1 coding without separate auth  
- ADR 0034 Accept  
- Product Gate / TestFlight  
- Rewriting Wanxiang content to Ice  
- **Wanxiang nine-key productization** — **Human deferred** to later Assignment (not yet drafted); may ride Discovery later or stay further deferred; P1/P2 must not enable  
- **Installed Capability Discovery / layout-picker** (and Lua/OpenCC product-surface honesty) — **Human deferred** later Assignment (not yet drafted); separate Human Active; **not** P1 UI. **Layout-page A/B UX + uninstall layout-fallback + Luna presence + readiness greying Decided** — [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md); package capability manifest format [`universe-capabilities/v1`](scheme-platform-universe-capabilities-v1-2026-09-09.md); P1 may add readiness **query** seams if needed
- Closing A34-R1 / unpausing Wanxiang P4  
- Ice `dofile` full close (A34-R2 / TD-011), Recovery persistence, peer-prefer B  

---

## 8. History

- `2026-09-09 Asia/Shanghai`: P0 interface draft authored on `codex/scheme-platform-001` (docs only; local commit; no push).
- `2026-09-09 Asia/Shanghai`: Human deferred Wanxiang nine-key productization to later Assignment; marked former TBD as **Human deferred** (not open for this Assignment); P1/P2 must not enable (local commit only; no push).
- `2026-09-09 Asia/Shanghai`: Human approved **P1↔Discovery split** — Decided P1 seams = LayoutCapability + ResourceCapability/ownership (adapter lookup; Ice-only nine-key; Wanxiang `supportsNineKey=false`; strategy APIs). Discovery UI / layout-picker = later Assignment (not yet drafted). Local commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human approved **Discovery layout-page A/B UX** (later Assignment) — Decided pointer in §2; full rules in [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md). P1 remains query seams only (not this UI). Local commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human approved **uninstall layout-fallback** — Decided pointer in §2 / `onUninstallPrepare` / UninstallHooks; full rules in [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md) (warn → A-only among remaining / else 26-key+Luna; manifest = Universe convention not RIME built-in). Local commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human SharedDefault decision recorded in §4 (end-state `privatePreset`; P1 Ice only; P2 Wanxiang migrate). Local commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human **Lua/OpenCC Ownership** decision — unified ResourceOwnership/ResourceCapability; **long-term dual** `namedList` + `exactHash` (not forced to one); no dangerous filename heuristics auto-remove; no whole-dir wipe; Settings confirmed honesty + optional user marking; OpenCC Wanxiang may `admitted=false`; P1 wire both unchanged; P2 Wanxiang platform path keeps `exactHash`; contrast SharedDefault → `privatePreset`. Local commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human approved **Luna presence + readiness greying** — Decided pointer in §2; Luna always on 26-key A / never nine-key A / not B / builtin; confirmed-but-unready greyed in A with reason (prefer grey over hide; no binding until ready); uninstall auto-rebind **ready** A only. Full rules in [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md). Local commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human finalized **`universe-capabilities/v1`** — Decided in §5.1 / §2 Discovery pointer; full schema + Ice/Wanxiang examples in [`scheme-platform-universe-capabilities-v1-2026-09-09.md`](scheme-platform-universe-capabilities-v1-2026-09-09.md). Validation failure voids entire manifest; priority user override > manifest > catalog adapter > default unsupported; filename heuristics not manifest fields. Local commit only; no push.
