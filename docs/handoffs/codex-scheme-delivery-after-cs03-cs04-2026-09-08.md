# Codex Handoff — Scheme Delivery (after CS-03/04)

**Date:** 2026-09-08 (Asia/Shanghai)
**From:** Grok Bot (iOS开发大师)
**To:** Codex
**Assignment:** `SCHEME-DELIVERY-SOURCE-STATE-001`
**Repo:** https://github.com/shchnk1103/Universe-Keyboard
**Branch:** `codex/scheme-delivery-fix`
**PR:** [#100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) (**draft** — do not undraft/merge)
**Isolation checkout:** `/private/tmp/uk-scheme-delivery-fix`
**Also note:** User MacBook checkout `~/Dev/Universe Keyboard` may differ; prefer this isolation tree for scheme-delivery work.

---

## 1. Git tip (verify with `git rev-parse HEAD` + `git cat-file -t`)

On isolation checkout, **local tip = HEAD of this handoff commit** (run `git rev-parse HEAD` / `git log -1 --oneline`). Do not trust a stale pasted SHA.

| Ref | Full SHA (stable parents) | Message / note |
|-----|----------|----------------|
| CS-03/04 docs land | `deb873481cf41f0cfcf8de035fa4f1de62722964` | `docs: handoff CS-03/04 local land; pause for Codex` |
| CS-03/04 eng | `cb06a08a5df7f7bd231848b97dbeb9e02e2c09b1` | `feat: CS-03/04 identical-receipt no-op + dual-install evidence` |
| **origin tip** (pushed, CI green) | `944477a` | EOF blank-line fix; CS-01/02 already on origin via `2813428` |

- Expected stack: `HEAD` (this handoff) ← `deb8734` ← `cb06a08` ← `944477a`
- Working tree should be **clean**; branch **ahead of origin by 3** (CS-03/04 eng + docs land + this handoff)
- **Not pushed** — Human has not authorized push of CS-03/04 (or this handoff) yet
- Before any commit/push touching `.swift`: run
  `xcrun swift-format format --in-place …` then
  `xcrun swift-format lint --strict --configuration .swift-format`
  (AGENTS.md hard gate; draft-push exception does **not** waive format)

---

## 2. What just landed (local only)

### CS-03 / CS-04
- **CS-03:** Dual-install Ice+Wanxiang → repeat Ice same identity → **idempotent no-op**; Wanxiang peer retained; selection not thrashed.
- **CS-04:** Symmetric Wanxiang same-identity no-op; identity-change path uses existing Wanxiang upgrade-rollback and **preserves Ice peer** (+ unknown/user paths).

### Production seam
- `SchemaManager.shouldSkipIdenticalReinstall` + gate in `fetchAndDownload` **before** lease / checkpoint / replace when installed receipt matches staged digest.
- `forceRedownload` / `force: true` **bypasses** the skip.
- Evidence: `docs/evidence/scheme-delivery-cross-scheme-cs03-cs04-2026-09-08.md`
- Test log (local): `/private/tmp/uk-cross-scheme-cs03-cs04-test.log` — **TEST SUCCEEDED** (5/5), including:
  - `testCS03_RepeatIceSameIdentity_NoOpKeepsWanxiangPeerAndSelection`
  - `testCS04_RepeatWanxiangSameIdentity_NoOpKeepsIcePeerAndSelection`
  - `testCS04_WanxiangIdentityChange_UpgradeRollbackPreservesIcePeer`
  - `testShouldSkipIdenticalReinstallWhenReceiptMatchesStagedContent`
  - `testShouldSkipIdenticalReinstallRequiresInstalledSchemaPresence`

### Already on origin (before this slice)
- CS-01/02 dual-install harness + happy paths: `2813428`
- Cross-scheme contract Human Approve + authorize first freeze: `2ae3613`
- Wanxiang upgrade checkpoint + fail-closed restore: `d1c88e3` + IQ `ed9b808` (**Q-UR-P2-01 Closed**)
- Wanxiang exact Lua ownership (CNB pin), Ice P4 fail-closed active uninstall, Q-P2-01, etc. (see Assignment history)

---

## 3. Approved contract defaults (do not re-litigate)

Source: `docs/plans/scheme-delivery-cross-scheme-matrix-contract-2026-09-08.md` (**Human Approved**)

1. Active uninstall with peer → fallback **(B) prefer retained peer** if deployable, else Luna — **policy approved; production coding deferred to CS-07/08**
2. After install → **activate the scheme just installed**
3. Unchanged identity reinstall → **idempotent no-op** (CS-03/04 done locally)
4. First cut includes **both** install orders (CS-01/02 done on origin)
5. Engineering done = automation + Independent Quality; device → Product Gate later
6. Wanxiang pin: **CNB `9bfcf60e…` / `17.5.9` only**
7. **No** ADR 0034 Accept; **no** Recovery persistence

---

## 4. Recommended next slices (Human must name before coding)

Ordered:

| Slice | Intent | Status |
|-------|--------|--------|
| **CS-05 / CS-06** | Inactive uninstall with peer retained; **no** Luna forced | **Next when Human authorizes** |
| **CS-07 / CS-08** | Active uninstall with peer; implement fallback **B** | Policy approved; coding deferred until named |
| CS-09 / CS-10 | Last-scheme / post-uninstall retained deploy | Later |
| CS-F* | Failure overlays | Later |
| Independent Quality | On matrix freeze tip | After engineering slices Human names |
| Limited / full Product Gate | Device etc. | Separate Human auth |

Also still open outside matrix: Recovery persistence, Ice Lua `dofile` dynamic refs, Wanxiang P4 full close, backup/staging best-effort cleanup.

---

## 5. Hard non-claims / do-not-do

Unless Human **explicitly** authorizes each item:

- Do **not** push CS-03/04 (or any new commits) without ask
- Do **not** undraft / merge PR #100
- Do **not** TestFlight / App Release
- Do **not** Accept ADR 0034 (stays **Proposed**)
- Do **not** start Recovery persistence
- Do **not** start CS-05+ until Human names the slice
- Do **not** implement peer-prefer **B** production path until CS-07/08 is named
- Limited Product Gate on older freeze is **historical** — does not auto-cover tip

---

## 6. Key paths

| Area | Path |
|------|------|
| Assignment | `docs/assignments/scheme-delivery-source-state-001.md` |
| ACTIVE_WORK | `docs/ACTIVE_WORK.md` |
| Matrix contract | `docs/plans/scheme-delivery-cross-scheme-matrix-contract-2026-09-08.md` |
| P4 remaining / progress | `docs/plans/scheme-delivery-p4-remaining-matrix-2026-09-08.md` |
| CS-03/04 evidence | `docs/evidence/scheme-delivery-cross-scheme-cs03-cs04-2026-09-08.md` |
| Wanxiang upgrade contract | `docs/plans/scheme-delivery-wanxiang-upgrade-rollback-contract-2026-09-08.md` |
| Installer / ownership | `Universe Keyboard/Services/SchemaArchiveInstaller.swift` |
| Download / skip / upgrade | `Universe Keyboard/Services/SchemaManager+Download.swift` |
| Wanxiang Lua hashes | `Universe Keyboard/Services/WanxiangLuaOwnership.swift` |
| Coexistence tests | `UniverseKeyboardTests/SchemeResourcePreparationCoexistenceTests.swift` |
| Manager tests (upgrade inject) | `UniverseKeyboardTests/SchemaManagerTests.swift` |
| ADR | `docs/architecture/decisions/0034-multi-scheme-resource-ownership.md` |
| AGENTS format gate | `AGENTS.md` |

App Group prefix: `DoubleShy0N` → `group.com.DoubleShy0N.Universe-Keyboard`

---

## 7. Suggested first Codex steps

1. `cd /private/tmp/uk-scheme-delivery-fix && git status && git log --oneline -5 && git cat-file -t HEAD`
2. Confirm ahead-by-2 vs `origin/codex/scheme-delivery-fix`; **ask Human before push**
3. Read Assignment Current Status + this handoff + matrix contract §6–§7
4. Wait for Human to name **CS-05/06** (or push of CS-03/04) before coding
5. Keep PR #100 draft; keep ADR Proposed

---

## 8. One-liner for Human / Codex chat paste

> Isolation `HEAD` = this handoff ← `deb8734`/`cb06a08` (CS-03/04) ← origin `944477a`. CS-01/02 on origin; CS-03/04 local identical-receipt no-op + peer retain, **not pushed**. Pause for Codex. Next **CS-05/06** when named. Peer-prefer **B** → CS-07/08. No undraft/merge/TestFlight/ADR Accept/Recovery. Checkout `/private/tmp/uk-scheme-delivery-fix`, PR #100 draft.
