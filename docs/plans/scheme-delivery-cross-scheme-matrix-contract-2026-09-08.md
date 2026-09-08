# Cross-scheme matrix contract (Ice ↔ Wanxiang) (Human Approved)

Contract proposal for the **cross-scheme matrix** remaining-matrix row, 2026-09-08 (Asia/Shanghai). Checkout `/private/tmp/uk-scheme-delivery-fix`, branch `codex/scheme-delivery-fix` (tip ~`87bf24e`).

**Status:** **Human Approved** (2026-09-08 Asia/Shanghai) for **minimal implementation slices** only (§6.2 fixture dual-install harness + §6.3 CS-01/CS-02 happy paths). Recorded Human defaults: (1) active-uninstall fallback **(B) prefer retained peer** if deployable, else Luna; (2) post-install **activate the scheme just installed**; (3) repeat install when identity unchanged → **idempotent no-op**; (4) first freeze must include **both** Ice→Wanxiang and Wanxiang→Ice orders; (5) engineering done = automation + Independent Quality; device deferred to Product Gate; (6) Wanxiang pin: **CNB `9bfcf60e…` / `17.5.9` only**; (7) **No** ADR 0034 Accept; **no** Recovery persistence. §6.6 (CS-07/08 peer-prefer fallback B) is **approved** but **not** in this first coding freeze. Still **not** authorized: push (unless later asked), undraft/merge, TestFlight, ADR Accept, Product Gate.

Related inputs:

- Remaining matrix: [`scheme-delivery-p4-remaining-matrix-2026-09-08.md`](scheme-delivery-p4-remaining-matrix-2026-09-08.md)
- Style / prior approved slice: [`scheme-delivery-wanxiang-upgrade-rollback-contract-2026-09-08.md`](scheme-delivery-wanxiang-upgrade-rollback-contract-2026-09-08.md)
- Assignment: [`SCHEME-DELIVERY-SOURCE-STATE-001`](../assignments/scheme-delivery-source-state-001.md)
- Coexistence plan: [`scheme-resource-ownership-and-coexistence-plan.md`](scheme-resource-ownership-and-coexistence-plan.md)
- ADR 0034 **Proposed**: [`0034-multi-scheme-resource-ownership.md`](../architecture/decisions/0034-multi-scheme-resource-ownership.md)
- Wanxiang Lua ownership evidence: [`scheme-delivery-wanxiang-lua-ownership-2026-09-08.md`](../evidence/scheme-delivery-wanxiang-lua-ownership-2026-09-08.md)

Matrix row under contract (verbatim from remaining matrix):

> Cross-scheme matrix | Ice then Wanxiang and reverse; repeat install; uninstall active/inactive target; retained scheme and Luna deploy/input evidence

Pins assumed unless Human extends (same as upgrade-rollback slice where applicable):

| Field | Ice | Wanxiang | Builtin fallback |
|---|---|---|---|
| Scheme id | `rime_ice` / Ice (雾凇) | `wanxiang` | `luna_pinyin` |
| Plan / post | `rime-ice-plan-2` / `rime-ice-post-2` (current P2+) | `wanxiang-plan-1` / `wanxiang-post-1` | N/A (builtin) |
| Archive pin | Ice dated pin already used by P0–P4 slices | CNB SHA-256 `9bfcf60e62d85dd168cd2748e5b2d126fcb3355939969eb80455ba71cbf67732` / `17.5.9` | Builtin generation |

---

## 1. Problem / gap — multi-scheme sequences not yet evidenced

Single-scheme slices already covered important contracts, but **do not** prove Ice and Wanxiang can share one live shared tree across install order, reinstall, and selective uninstall.

### 1.1 Already covered (do not re-litigate in this slice)

| Area | What exists | Limit |
|---|---|---|
| Ice active uninstall → Luna | Unit: await Luna deploy before stage→commit; Luna fail / staging fail restore selection+files; non-active uninstall without Luna | Mostly **one** downloaded scheme present; Human-attested success path only; device failure-rollback Limited Product Gate (automation-backed) |
| Ice uninstall staging mid-move | `testIceUninstallStagingMidMoveFailureRestoresOwnedFiles` / Q-P2-01 Closed | Ice-owned paths only |
| Ice preset / Prelude | P2 skips installing Ice `default.yaml`; P3 recovers known Ice pollution of Prelude | Not a dual-scheme install matrix |
| Wanxiang Lua ownership | Exact-hash uninstall inventory unit tests committed | Ownership inventory ≠ coexistence sequence |
| Wanxiang upgrade-rollback | Human-approved contract; Independent Quality Pass with conditions / Q-UR-P2-01 Closed | **Wanxiang-only** generation replace; matrix explicitly deferred cross-scheme |

Representative existing automation (single-scheme / active-uninstall focus):

- `testActiveUninstallAwaitsLunaDeployBeforeCommittingFiles`
- `testActiveUninstallKeepsFilesAndRestoresSchemaWhenLunaDeployFails`
- `testActiveUninstallRestoresSchemaWhenStagingFailsAfterLunaDeploy`
- `testNonActiveUninstallStillRemovesFilesWithoutLunaFallback`
- `testNonActiveUninstallKeepsFilesWhenStagingFails`
- Ice staging rollback / pollution recovery tests
- Wanxiang exact-hash Lua ownership tests
- Wanxiang upgrade-rollback failure-injection suite (copy / deploy / restore)

### 1.2 Gaps this contract must close (normative intent)

Multi-scheme sequences that are **not** yet evidenced as a coherent matrix:

1. **Ice → Wanxiang** install while Ice remains installed and usable.
2. **Wanxiang → Ice** install while Wanxiang remains installed and usable.
3. **Repeat install** of an already-installed scheme while the other remains (idempotent / upgrade-or-reinstall semantics without damaging the peer).
4. **Uninstall inactive** peer while the other stays **active** (no Luna switch required; retained active scheme + input).
5. **Uninstall active** peer while the other is installed but inactive — Luna fallback vs auto-select retained peer (Human decision; see §7).
6. After uninstall of one, **retained scheme** still deploys and accepts input; shared Prelude/OpenCC/Ice Lua/Wanxiang exact-hash/user files obey preserve rules.
7. **Selection / input expectations** at each stable checkpoint (which schema is selected; whether Luna is temporary fallback only).

Without this matrix, “both schemes installed” and “uninstall one, keep the other” remain product claims without sequence evidence.

---

## 2. Normative contract cases (table)

All cases assume production installer paths (`SchemaManager` + `SharedContainerSchemaArchiveInstaller` / existing commit-lease rules), real pinned plans, and preserve rules in §3. Success means: target receipt/selection match the row; peer scheme files that should remain are present and hash-consistent with ownership rules; no silent mixed tree; no new success receipt for a failed operation.

| ID | Sequence | Precondition | Required outcome | Selection / input |
|---|---|---|---|---|
| **CS-01** | Ice then Wanxiang | Clean or Luna-only baseline → install Ice (success) → install Wanxiang | Both installed; Ice-owned + Wanxiang-owned inventories coexist; Prelude/OpenCC baselines intact per P2/P3; Ice Lua retained; Wanxiang exact-hash set present; unknown/user files untouched | After Wanxiang install: selection is Wanxiang **or** explicit last-installed policy (Human confirm §7); both schemes selectable; input works for selected scheme |
| **CS-02** | Wanxiang then Ice | Baseline → install Wanxiang → install Ice | Symmetric to CS-01; Ice must not reclaim `default.yaml` into Prelude; Wanxiang files not deleted by Ice install | After Ice install: selection per policy (§7); peer Wanxiang remains installed and selectable |
| **CS-03** | Repeat install Ice (Wanxiang retained) | CS-01 or CS-02 state; Wanxiang installed | Reinstall/upgrade Ice does not remove Wanxiang-owned paths; Ice ownership restored/updated; no whole-`lua/` wipe | Selection: prefer keep current selection unless operation explicitly activates Ice; Wanxiang still input-capable when selected |
| **CS-04** | Repeat install Wanxiang (Ice retained) | Dual-installed; Ice installed | Reinstall/upgrade Wanxiang uses upgrade-rollback contract when prior Wanxiang generation present; Ice Lua / Ice-owned paths preserved; unknown/user preserved | Same selection discipline as CS-03 with roles reversed |
| **CS-05** | Uninstall **inactive** Ice (Wanxiang active) | Dual-installed; selection = Wanxiang | Ice-owned removable set removed per plan/exact rules; Wanxiang retained; **no** Luna deploy required for inactive uninstall; staging fail restores Ice files | Selection stays Wanxiang; Wanxiang input evidence; Luna not forced |
| **CS-06** | Uninstall **inactive** Wanxiang (Ice active) | Dual-installed; selection = Ice | Wanxiang exact-hash owned paths removed; Ice retained (including Ice Lua); unknown/user preserved | Selection stays Ice; Ice input evidence |
| **CS-07** | Uninstall **active** Ice (Wanxiang installed, inactive) | Dual-installed; selection = Ice | Fail-closed active uninstall: await successful **fallback deploy** before stage→commit; on any failure keep Ice selection+files | **Fallback policy (§7):** (A) Luna only (current single-scheme P4), or (B) prefer retained Wanxiang if deployable, else Luna. Input works on post-success selection; Ice marked 未安装 |
| **CS-08** | Uninstall **active** Wanxiang (Ice installed, inactive) | Dual-installed; selection = Wanxiang | Symmetric to CS-07 with Wanxiang as target | Same fallback policy as CS-07 with roles reversed |
| **CS-09** | Uninstall last downloaded scheme (active) | Only Ice **or** only Wanxiang + builtin | Existing P4 Luna path remains valid; this matrix may **reuse** evidence rather than re-implement | Luna selected + deploy/input after success |
| **CS-10** | Post-uninstall retained-scheme deploy/input | After CS-05–CS-08 success | Retained scheme files still match ownership; deploy of retained scheme succeeds; input path does not require reinstall | Settings show retained scheme installed; uninstalled peer 未安装 |

**Failure overlays** (apply on CS-01–CS-08 where mutation exists):

| ID | Injection | Required |
|---|---|---|
| **CS-F1** | Mid-install copy/deploy failure while peer already installed | Peer generation retained; no success receipt for failed install; temps cleaned; no mixed claim of new version |
| **CS-F2** | Active-uninstall Luna/fallback deploy failure | Original active selection + files retained (existing P4 semantics) |
| **CS-F3** | Staging mid-move failure during uninstall with peer present | Target files restored; peer untouched; selection unchanged |

---

## 3. Preserve rules (non-negotiable)

Across every matrix case, operations must **not**:

1. **Unknown files** — delete or rewrite paths not admitted by the acting scheme’s pinned plan / exact-hash ownership map.
2. **Prelude / official OpenCC baselines** — touch except via already-approved Ice P2/P3 rules (Ice skips installing `default.yaml`; Wanxiang continues to skip `default.yaml`; no whole-directory `opencc/` deletion).
3. **Ice Lua** — remove or overwrite Ice Lua / Ice-owned Lua paths when acting on Wanxiang install, upgrade, or uninstall.
4. **Wanxiang exact-hash ownership** — delete Wanxiang Lua/config bytes that fail exact-hash ownership match when uninstalling Wanxiang; when Ice is the actor, do not remove Wanxiang-owned paths at all.
5. **User files** — delete user custom files, user dictionaries, or user-edited scheme files outside ownership receipts.

Whole-directory `lua/` or `opencc/` deletion remains **forbidden**. Cross-scheme success is not license to broaden removal lists.

---

## 4. Evidence matrix (automation vs device)

Claiming “cross-scheme matrix contract implemented” requires the automation column below. Device column is for Independent Quality / Human Product Gate later — **not** implied by design approval.

| Evidence | Automation | Device / Independent Quality |
|---|---|---|
| CS-01 Ice→Wanxiang both installed + peer file assertions | **Required** | Optional Human-attested later |
| CS-02 Wanxiang→Ice both installed + peer file assertions | **Required** | Optional |
| CS-03 / CS-04 repeat install with peer retained | **Required** | Optional |
| CS-05 / CS-06 inactive uninstall + retained active input hook/flags | **Required** | IQ: confirm no Luna forced when inactive |
| CS-07 / CS-08 active uninstall with peer present + fallback deploy | **Required** (policy A or B per Human) | IQ: sequence + selection; device input strongly recommended before full Product Gate |
| CS-F1–F3 failure injections with peer present | **Required** | Device failure-rollback **not** required to call engineering done (mirror Limited P4 precedent) |
| Preserve assertions (unknown / Prelude-OpenCC / Ice Lua / Wanxiang exact-hash / user) on install+uninstall paths | **Required** | IQ checklist item |
| Strict App + Keyboard local gates | **Required** | — |
| Independent review (Architecture and/or Quality delta on this matrix only) | **Required** before “slice done” | IQ owns verdict; non-claims §5 |
| Physical device dual-scheme input after CS-01/02 and after CS-07/08 | Not required for engineering “done” | **Needed** for any future full Product Gate / Device-attested upgrade of this row |
| ADR 0034 Accept / merge / TestFlight | Not required | Separate Human authority |

**Independent Quality needs (minimum packet):**

- This contract freeze id + Human approval note (when granted).
- Test names mapped to CS-01…CS-10 / CS-F\* with pass logs.
- Explicit statement of fallback policy (Luna-only vs prefer retained peer).
- Preserve-rule assertion list and any skipped dynamic Ice Lua `dofile` residuals called out (not silently closed).
- Non-claims block identical to §5.

---

## 5. Non-goals (explicit)

This design does **not** authorize or claim:

- **Recovery persistence** across crash/restart / retained-checkpoint discovery after process death (separate matrix row).
- ADR 0034 **Accept**.
- PR #100 undraft / merge, TestFlight, App Release, or **full Product Gate**.
- Replacing the Wanxiang upgrade-rollback slice or reopening Q-UR-P2-01.
- Broad digest-cleaning-as-general-policy or whole-`lua/` deletion.
- New schemes beyond Ice ↔ Wanxiang ↔ Luna builtin fallback.
- Changing keyboard hot path / candidate ranking / RIME binary.

---

## 6. Ordered implementation slices

**Authorization (2026-09-08):** Human approved starting **minimal** slices **§6.2–§6.3 only** (fixture dual-install harness + CS-01/CS-02). Later slices remain planning until separately named. §6.6 (CS-07/08 peer-prefer fallback **B**) is approved as the policy answer but **deferred** from this first coding freeze.

Smallest increments. Do not expand beyond the Human-named freeze without a new authorization.

1. **Design freeze** — Human approval (or revision) of this document; record in Assignment Progress; keep ADR Proposed.
2. **Fixture dual-install harness** — Deterministic container with Ice + Wanxiang pinned plans; peer inventory helpers; no production behavior change yet beyond test seams if already present. **← authorized in first coding freeze**
3. **CS-01 / CS-02 happy paths** — Install order matrix + preserve assertions. **← authorized in first coding freeze**
4. **CS-03 / CS-04 repeat install** — Peer retention; wire Wanxiang path through existing upgrade-rollback when prior generation exists.
5. **CS-05 / CS-06 inactive uninstall with peer** — Extend current non-active uninstall coverage to assert peer retention + no Luna.
6. **CS-07 / CS-08 active uninstall with peer** — Implement Human-chosen fallback policy **(B) prefer retained peer if deployable, else Luna**; failure overlays CS-F2/F3. **Policy approved; implementation deferred from first coding freeze.**
7. **App + Keyboard gates + Independent review** — Delta only; non-claims §5.
8. **Later (separate authorizations)** — Device-attested dual-scheme input; Recovery persistence; Product Gate; ADR Accept; merge/TestFlight.

---

## 7. Human answers (recorded 2026-09-08)

1. **Active-uninstall fallback when a peer scheme is installed:** **(B) prefer retained peer** if deployable, else Luna. *(Approved; CS-07/08 production implementation **not** in first coding freeze — see §6.6.)*
2. **Post-install selection after CS-01/CS-02:** **activate the scheme just installed**.
3. **Repeat install semantics:** **idempotent no-op** when identity unchanged (cheaper path; not full upgrade-rollback unless identity changes).
4. **First freeze order coverage:** **both** Ice→Wanxiang (**CS-01**) and Wanxiang→Ice (**CS-02**) must be included.
5. **Device evidence:** engineering “done” = automation + Independent Quality; **device deferred to Product Gate** (matching upgrade-rollback).
6. **Wanxiang pin:** **CNB `9bfcf60e…` / `17.5.9` only** (GitHub variant deferred).
7. **Scope guard:** **No** ADR 0034 Accept; **no** Recovery persistence required for this matrix ship.

---

## 8. Authorization record

**Human Approved** 2026-09-08 (Asia/Shanghai) with the seven defaults in the Status block and §7.

**Authorized now:** §6.2–§6.3 only (fixture dual-install harness + CS-01/CS-02 happy paths). Prefer extending `SchemeResourcePreparationCoexistenceTests` (or SchemaManagerTests) with clear CS-01/CS-02 names. Tiny in-harness selection helper for “activate just-installed” is allowed when needed for those tests. **No** CS-05–CS-08 / peer-prefer fallback **production** changes in this freeze.

**Still NOT authorized:** push (unless later asked); undraft/merge PR #100; TestFlight; ADR 0034 Accept; Recovery persistence; Product Gate; removal-list broadening; CS-07/08 production fallback B (policy approved, coding deferred).

Residuals outside the named freeze remain open.
