# P4 remaining ownership and upgrade matrix

> **Superseded decision note (2026-09-08):** The historical peer-prefer B
> fallback below is superseded by the current cross-scheme contract's
> Luna-only A policy for CS-07/08. This document remains an investigation
> record; see `scheme-delivery-cross-scheme-matrix-contract-2026-09-08.md` for
> the current decision and Assignment for lifecycle state.

Executor read-only investigation, 2026-09-08; checkout `/private/tmp/uk-scheme-delivery-fix`, base `bf9de51` plus rollback double-failure correction. This document does not authorize new deletion rules or accept ADR 0034.

## Reverified facts

- CNB Wanxiang 17.5.9 archive `/private/tmp/rime-wanxiang-1759/cnb.zip` SHA-256 is `9bfcf60e62d85dd168cd2748e5b2d126fcb3355939969eb80455ba71cbf67732`, matching the recorded pin.
- Extracted Lua tree contains 43 files. Current plan admits `lua/` but its removal list contains only named schema/config files and `dicts`; Lua files remain after uninstall.
- `SchemaManager+Download.swift` verifies staged content before installation, but production installer replaces files individually. Failure handling cleans download/extraction temporaries; it does not restore the previous installed generation. Verified archive identity alone therefore does not prove rollback-safe upgrade.
- Current known-file removal rules are not a per-installation ownership receipt. Adding broad directory deletion would not establish ownership of future or user-created files.

## Proposed execution slices

| Slice | Required behavior/evidence |
|---|---|
| Uninstall recovery delta | Independent review of checkpoint retention and manager stop behavior; no successful-recovery claim when restore fails |
| Wanxiang ownership | Exact pinned installed-path inventory; preserve unknown files, shared Prelude/OpenCC, Ice Lua, user custom files and dictionaries |
| Upgrade rollback | Preserve previous files and metadata until new deployment succeeds; injected copy/deploy/restore failures must leave an old generation or an explicit retained recovery checkpoint |
| Cross-scheme matrix | Ice then Wanxiang and reverse; repeat install; uninstall active/inactive target; retained scheme and Luna deploy/input evidence |
| Recovery persistence | Separate explicit design for crash/restart, retained-checkpoint discovery, re-entry and cleanup; current in-process retry fixture is not this feature |

Product proposal for the upgrade slice: failed upgrades retain the prior scheme version and selection; no successful new-version receipt until deployment succeeds. If restoration itself fails, retain recovery data and surface a recovery-required state. This remains a proposal, not an inferred approval or an implemented guarantee.

Required validation: real pinned artifacts and production installer paths, exact ownership assertions, shared/user-file preservation, injected mid-operation failures, strict App/Keyboard gates, independent review. Physical-device and release decisions remain separate.

## Progress note (2026-09-08)

- Wanxiang exact-hash Lua ownership unit tests are **committed** (`8147034` and follow-ups on `codex/scheme-delivery-fix`). Evidence: [`../evidence/scheme-delivery-wanxiang-lua-ownership-2026-09-08.md`](../evidence/scheme-delivery-wanxiang-lua-ownership-2026-09-08.md). Ownership slice still open for full Wanxiang P4; not Product Gate / ADR Accept / merge.
- **Upgrade-rollback** Independent Quality **Pass with conditions**; **Q-UR-P2-01 Closed** (`d1c88e3`): [`../reviews/scheme-delivery-wanxiang-upgrade-rollback-quality-2026-09-08.md`](../reviews/scheme-delivery-wanxiang-upgrade-rollback-quality-2026-09-08.md) / [`../reviews/scheme-delivery-wanxiang-upgrade-rollback-quality-rereview-qurp201.md`](../reviews/scheme-delivery-wanxiang-upgrade-rollback-quality-rereview-qurp201.md). Contract: [`scheme-delivery-wanxiang-upgrade-rollback-contract-2026-09-08.md`](scheme-delivery-wanxiang-upgrade-rollback-contract-2026-09-08.md). **no push / undraft / TestFlight / ADR Accept**.

- **Cross-scheme matrix** contract **Human Approved** (2026-09-08): [`scheme-delivery-cross-scheme-matrix-contract-2026-09-08.md`](scheme-delivery-cross-scheme-matrix-contract-2026-09-08.md). This historical note originally recorded fallback **B** (prefer retained peer else Luna; CS-07/08 deferred). The current Human decision supersedes it with **A: Luna only**, and CS-07/08 is now an authorized slice. Other defaults remain: activate just-installed, idempotent repeat, both install orders, CNB `9bfcf60e…` only, engineering done = automation + IQ (device → Product Gate), **no** ADR Accept / Recovery persistence / push / undraft / TestFlight.
- **Cross-scheme CS-03/CS-04** landed **locally** (not pushed) on isolation checkout `/private/tmp/uk-scheme-delivery-fix`: identical-receipt idempotent no-op seam (`SchemaManager.shouldSkipIdenticalReinstall` + `fetchAndDownload` gate; force bypasses); coexistence tests `testCS03_…` / `testCS04_…` (same-identity no-op + Wanxiang identity-change upgrade preserves Ice). Base before slice: `944477a`. CS-01/02 remain at `2813428`. **Pause for Codex**; next named slice **CS-05+**. Peer-prefer **B** still deferred to CS-07/08. PR #100 draft; no undraft/merge/TestFlight/ADR Accept.
