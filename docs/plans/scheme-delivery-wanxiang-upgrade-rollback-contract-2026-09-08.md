# Wanxiang upgrade-rollback contract (Human Approved)

Contract for the Wanxiang upgrade-rollback minimal slice, 2026-09-08 (Asia/Shanghai). Checkout `/private/tmp/uk-scheme-delivery-fix`, branch `codex/scheme-delivery-fix`.

**Status:** **Human Approved** for implementation of the bounded upgrade-rollback slice. Recorded Human defaults: (a) full prior-generation file checkpoint before live replace; upgrade-only when a prior generation is present (first install → no checkpoint); restore prior scheme selection on failed upgrade; distinct `SchemaUpgradeRecoveryError` (shared fail-closed semantics with uninstall, types not reused); CNB pin `9bfcf60e…` / `17.5.9` / `wanxiang-plan-1` / `wanxiang-post-1`; **no** ADR 0034 Accept; **no** Product Gate / merge / TestFlight from this slice alone.

Related inputs:

- Remaining matrix: [`scheme-delivery-p4-remaining-matrix-2026-09-08.md`](scheme-delivery-p4-remaining-matrix-2026-09-08.md)
- Assignment: [`SCHEME-DELIVERY-SOURCE-STATE-001`](../assignments/scheme-delivery-source-state-001.md)
- ADR 0034 **Proposed**: [`0034-multi-scheme-resource-ownership.md`](../architecture/decisions/0034-multi-scheme-resource-ownership.md)
- Wanxiang Lua ownership evidence (committed slice): [`scheme-delivery-wanxiang-lua-ownership-2026-09-08.md`](../evidence/scheme-delivery-wanxiang-lua-ownership-2026-09-08.md)
- Uninstall fail-closed vocabulary reference: `SchemaUninstallRecoveryError.rollbackIncomplete` / retained staging checkpoint (`SchemaArchiveInstaller.rollbackSchemaUninstall`)

Pin under contract (unless Human explicitly extends):

| Field | Value |
|---|---|
| Scheme | Wanxiang (`wanxiang`) |
| Version | `17.5.9` |
| Installation plan revision | `wanxiang-plan-1` |
| Post-processing revision | `wanxiang-post-1` |
| Primary archive (CNB) SHA-256 | `9bfcf60e62d85dd168cd2748e5b2d126fcb3355939969eb80455ba71cbf67732` |
| Staged identity ID | `wanxiang-17.5.9-plan1-post1` |

---

## 1. Problem / gap

Current production install path (`SchemaManager+Download` → `SharedContainerSchemaArchiveInstaller.installSchemaFiles`) replaces destination files **individually**: for each plan-admitted relative path, it removes any existing live file then `copyItem`s the new bytes. On failure, the catch path **cleans download/extraction temporaries** and releases the commit lease; it does **not** restore the previous installed generation of scheme-owned files.

Consequences today:

- A mid-copy / mid-deploy failure can leave a **mixed** live tree (some new files, some old, some missing).
- Verified archive / staged-content identity (SHA gates before install) proves **what was about to be installed**, not that an upgrade is **rollback-safe**.
- Receipt commit already runs **after** successful deploy (`persistVerifiedInstallation` only on the success path). That is necessary but **not sufficient**: without generation restore, the user can lose a working prior Wanxiang install even when no new-version receipt is written.
- Uninstall already has a fail-closed staging + `rollbackIncomplete` checkpoint pattern. **Upgrade is a different slice**: uninstall moves owned paths out then restores on failure; upgrade must preserve the **prior generation** while introducing a new generation. Do not pretend uninstall staging == upgrade.

Matrix fact (reverified): *“Verified archive identity alone therefore does not prove rollback-safe upgrade.”*

---

## 2. Contract (normative proposal)

The following is the proposed Human-approvable behavior for the **Wanxiang upgrade-rollback** slice only.

### 2.1 Success criteria for a completed upgrade

An upgrade may be treated as **successful** only when **all** of the following hold:

1. Prior Wanxiang generation (if any) was checkpointed or otherwise retained until the new generation is durable.
2. New plan-admitted files are fully deployed into the live shared tree according to `wanxiang-plan-1`.
3. RIME deployment for the target selection succeeds under the existing commit-lease rules.
4. Only then may a **new-version verified installation receipt** be committed (`persistVerifiedInstallation` / equivalent).

Until (4), UI/state must not claim the new version is installed.

### 2.2 Failed upgrade — prior generation retained

If any step after mutation begins fails (copy/deploy/activate/receipt preparation), the system must leave the user with either:

- **A.** The **prior Wanxiang generation restored** to the live tree, with **prior scheme selection** retained (or restored if temporarily switched), **or**
- **B.** An explicit **upgrade recovery-required** state with a **retained recovery checkpoint** of the prior generation (see §2.3).

Under **A**, the live tree must not remain a silent mixed half-upgrade. Under **B**, the product must not claim success or write a new-version receipt.

**No successful new-version receipt until deployment succeeds** remains mandatory (already true on the happy path; must remain true under all failure exits).

### 2.3 Restoration failure — recovery-required / checkpoint retention

If restoration of the prior generation **itself** fails:

- Retain the recovery checkpoint (do not delete the only surviving prior-generation copy).
- Surface a **recovery-required** / incomplete-upgrade-recovery condition.
- Align vocabulary with uninstall’s `rollbackIncomplete` **where sensible** (fail-closed, keep checkpoint, stop further mutation, do not claim files are already restored).
- **Do not** reuse uninstall staging types as if they were the same mechanism; name upgrade checkpoint types distinctly (e.g. upgrade checkpoint / `upgradeRollbackIncomplete` — exact symbol names left to implementation after approval).

Automatic crash/restart discovery of that checkpoint is **out of scope** for this slice (see §2.6).

### 2.4 Scope bound

| In scope | Out of scope unless Human extends |
|---|---|
| Wanxiang pin `17.5.9` / plan `wanxiang-plan-1` / post `wanxiang-post-1` | Other schemes (Ice, Luna, future Wanxiang versions) |
| Upgrade when a prior Wanxiang install is present (replace generation) | Broad multi-scheme matrix closure |
| Failure injection + App/Keyboard gates for this contract | Device-attested / Product Gate / TestFlight |
| Preserve rules in §2.5 | Accepting ADR 0034 |

First-time Wanxiang install (no prior generation) should continue fail-closed on temps without inventing a “prior generation,” but must still not write a success receipt on deploy failure. Human may clarify whether first install shares the same checkpoint machinery (§5).

### 2.5 Preserve (non-negotiable for this slice)

Upgrade/rollback must **not**:

- Delete or rewrite **unknown** files (paths not admitted by the pinned plan / exact-hash ownership map).
- Touch shared **Prelude** / official **OpenCC** baselines except via already-approved Ice/P3 rules (Wanxiang continues to skip `default.yaml`).
- Remove or overwrite **Ice** Lua / Ice-owned paths.
- Delete **user custom** files, user dictionaries, or edited Wanxiang Lua bytes that fail exact-hash ownership match (same spirit as `WanxiangLuaOwnership` / exact-hash uninstall staging).

Whole-directory `lua/` deletion remains forbidden.

### 2.6 Non-goals (explicit)

This contract does **not** authorize or claim:

- Crash/restart persistence / retained-checkpoint discovery after process death (separate **Recovery persistence** slice in the matrix).
- Full Wanxiang P4 close (ownership + upgrade + uninstall + cross-scheme matrix).
- ADR 0034 **Accept**.
- PR #100 undraft/merge, TestFlight, App Release, or full Product Gate.
- Broad `lua/` directory delete or digest-cleaning-as-general-policy.
- Device-attested upgrade evidence (optional later; not required to approve this design).

---

## 3. Evidence matrix (required before claiming the slice done)

Claiming “Wanxiang upgrade-rollback contract implemented” requires **all** of the following. Until then, residual remains open.

| Evidence | Required |
|---|---|
| Injected **copy** failure mid-`installSchemaFiles` (or equivalent production seam) with prior Wanxiang generation present | Yes — prior generation restored **or** explicit retained upgrade checkpoint + recovery-required |
| Injected **deploy** failure after files mutated | Yes — same retain/restore obligation; **no** new-version receipt |
| Injected **restore** failure after upgrade failure | Yes — checkpoint retained; recovery-required / incomplete recovery surfaced; no silent checkpoint deletion |
| Old generation retained or explicit checkpoint asserted by path/content (not only “temps cleaned”) | Yes |
| Strict **App** + **Keyboard** local gates (Swift 6 / project standard used by recent P4 slices) | Yes |
| Independent review (Architecture and/or Quality delta on the upgrade slice) | Yes |
| Real pinned artifact / plan revision under test (`wanxiang-plan-1`, CNB SHA `9bfcf60e…` or recorded equivalent fixture) | Yes |
| Unknown / user / Ice / Prelude-OpenCC preservation assertions on the upgrade failure path | Yes |
| Physical **device** run | **Not required** yet for engineering “done” of this slice |
| Full **Product Gate** / TestFlight / merge | **Not required** yet; separate Human authority |
| Crash/restart persistence tests | **Not required** for this slice |
| ADR 0034 Accept | **Not required** / not implied |

---

## 4. Implementation slices (ordered; §4.2–4.5 authorized for this freeze)

Smallest shippable increments **after** Human approves this contract. Listed for planning only.

1. **Design freeze** — Human approval (or revision) of this document; record decision in Assignment Progress.
2. **Upgrade checkpoint primitive** — Before mutating live Wanxiang-owned paths, stage prior generation into an operation-scoped upgrade checkpoint (distinct from `.schema-uninstall-*`). Fail closed if checkpoint cannot be created.
3. **Atomic-enough replace + restore path** — Install new generation; on any failure before receipt, restore from checkpoint; on restore failure, keep checkpoint and report upgrade recovery-required (vocabulary aligned with uninstall `rollbackIncomplete`, types distinct).
4. **Receipt gating audit** — Prove no new-version receipt on every failure exit; success path unchanged in ordering (deploy → receipt).
5. **Failure-injection tests** — Copy / deploy / restore seams; preservation of unknown/Ice/user/Prelude; App+Keyboard gates.
6. **Independent review** — Delta review of upgrade slice only; non-claims listed in §2.6.
7. **Later (separate authorizations)** — Recovery persistence across restart; cross-scheme matrix; device evidence; Product Gate; ADR Accept.

---

## 5. Human decisions (resolved for this slice)

Resolved defaults used by the approved implementation:

1. **Checkpoint strategy:** Prefer (a) full prior-generation file checkpoint before any live replace, (b) two-phase “install to shadow tree then swap,” or (c) per-file backup-as-you-replace? Design default recommendation: **(a)** closest to existing uninstall fail-closed language and easiest to evidence.
2. **First install vs upgrade:** Should first-time Wanxiang install share checkpoint machinery, or only “prior generation present” upgrades?
3. **Selection policy on failure:** Always restore prior **scheme selection** even if the user explicitly chose Wanxiang for this operation and deploy failed after activate? Recommendation: **yes** — retain prior selection on failed upgrade (matrix product proposal).
4. **Recovery-required UX:** New dedicated error/state vs reuse uninstall incomplete-rollback messaging? Recommendation: **distinct type**, shared fail-closed semantics.
5. **Disk budget:** Is requiring roughly **extra space for a full prior-generation checkpoint** acceptable for Wanxiang (~80–120 MB installed class), or must we optimize toward shadow-swap to reduce peak disk?
6. **GitHub pin in evidence:** Engineering evidence may use CNB `9bfcf60e…` only; is GitHub variant (`73f8c9da…`) required in the same slice or deferred?
7. **Scope creep guard:** Confirm upgrade-rollback may ship as a **bounded Wanxiang pin slice** without Accepting ADR 0034 and without closing full Wanxiang P4.

---

## 6. Authorization record

Human approved this contract for the **Wanxiang upgrade-rollback minimal slice** (checkpoint + fail-closed restore + focused coexistence tests + Independent Quality). Still **not** authorized by this file alone:

- ADR 0034 Accept
- Wanxiang P4 full close
- Product Gate / Device-attested upgrade
- PR #100 undraft/merge, TestFlight, App Release
- Crash/restart recovery persistence
