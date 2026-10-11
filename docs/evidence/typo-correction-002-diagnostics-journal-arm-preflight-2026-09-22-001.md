# Evidence: TYPO-CORRECTION-002 Diagnostics Journal arm/preflight — 2026-09-22-001

## Identity

| Field | Value |
|---|---|
| **Assignment** | TYPO-CORRECTION-002-DIAGNOSTICS-JOURNAL-ARM-PREFLIGHT-001 |
| **Authorization** | AUTH-TYPO-CORRECTION-002-DIAGNOSTICS-JOURNAL-ARM-PREFLIGHT-001 |
| **Run ID** | TC2-SIM-20260922-221630-DIAG-JOURNAL-ARM-001 |
| **Source tip** | e1b28aebe8f6b2f2a8587db1e525e332aa9bfe00 |
| **Worktree** | `/Users/doubleshy0n/.codex/worktrees/typo-correction-002-int003-controlled-capture-001/Universe Keyboard` |
| **Simulator** | iPhone 17 Pro Max / iOS 27 / `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| **App Group** | `group.com.DoubleShy0N.Universe-Keyboard` |
| **Diagnostics root** | `…/AppGroup/0469C0D3-0C89-4988-BD85-314F03EC34B3/Diagnostics` |
| **Executor** | Grok Bot iOS开发大师 |
| **Captured at** | 2026-09-22T22:20:43+08:00 Asia/Shanghai |

## Verdict for this Run

**Armed prefs + Human one-key attested; independent Keyboard Extension Diagnostics JSONL still absent.**

This is a **bounded diagnostic result** for journal arm/preflight. It does **not** prove INT-003, 180 ms, candidate selection, QA-001, Product/Release Gate, or parent Close. Missing JSONL under this AUTH is **not** a production writer-bug verdict.

## Arm / config (content-free)

Preference suite path used by Simulator for this domain:

`…/Devices/06C5BC3E-…/data/Library/Preferences/group.com.DoubleShy0N.Universe-Keyboard.plist`

(Same App Group keys as Main App `DiagnosticsSettingsView`.)

| Key | Observed after arm | Notes |
|---|---|---|
| `logging_enabled` | `true` / `1` | Already true before this Run; re-confirmed |
| `log_category_disp` | `true` / `1` | Display category (`Logger.Category.display` → `DISP` → key `log_category_disp`) |
| `diagnostics_high_fidelity_expiration` | present; defaults read `2026-09-22 22:45:59 +0000` | 30-minute high-fidelity window written for this Run |
| `control.json` | `{"schemaVersion":1,"currentGeneration":1}` | Unchanged mtime relative to earlier INT-003 era listing (18:39 local) |
| Writer / generation dirs | No `g1/open`, `g1/sealed`, leases, or JSONL segments | Only `v1/control.json` + `v1/locks/snapshot.lock` |

SHA-256:

| Artifact | SHA-256 |
|---|---|
| `Diagnostics/v1/control.json` | `baaa646c583ad8bb4c3d983f0069460e8afc8cbe0b3eb9212397eadc4a71fea4` |
| `Diagnostics/v1/locks/snapshot.lock` (empty) | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |

## Dynamic JSONL search

Searched under Diagnostics root (and App Group parent for `*.jsonl`):

- Pattern: `*.jsonl`
- Pattern: `keyboard_extension*`
- Pattern: dynamic segment form `keyboard_extension-<processInstanceID>-<hour>-<part>.jsonl` (and any `gN/open` / `gN/sealed`)

**Result:** zero JSONL files. No `origin` / `processInstanceID` / segment SHA to record.

Fixed-name-only search was **not** used as the sole method.

## One-key smoke

| Item | Value |
|---|---|
| Method | Human Product Owner attested one visible-key UI tap after Extension appear |
| Phrase / typeText / clipboard / host inject / candidate select | Not used |
| Agent observation of key identity | Not claimed (Human attestation only) |

## Related observation (not a journal proof)

Legacy App Group string key `rime_diag_log` remains **present** (length reported only: ~54000 characters). That path is the older Logger UserDefaults sink, **not** the independent Diagnostics JSONL journal required for INT-003-style rapid trace binding. Its presence does not substitute for JSONL and does not by itself prove or disprove the journal writer.

## Stop condition applied

Prefs were armed (`logging_enabled`, display category, high-fidelity expiry) and Human completed one visible-key tap; JSONL still absent → **stop**. No production writer or other Swift changes under this AUTH.

## Non-claims

- No INT-003 pass/fail
- No global &lt;180 ms claim
- No candidate selection / QA-001 / paired performance
- No Product / Quality / Release Gate
- No parent or child Close
- No commit / push / PR / merge
- No `RimeRuntimeProvenance.swift` restoration
- No declaration that missing JSONL is a confirmed production journal-writer defect

## Recommended next (requires new AUTH)

Draft follow-on (not authorized here):

`AUTH-TYPO-CORRECTION-002-DIAGNOSTICS-JOURNAL-WRITER-PATH-001` — investigate why Extension journal segments are not created despite armed prefs (Main App `prepareRootIfOwnedByMainApp` / Extension append path / suspend filter / rootURL resolution), still without treating this receipt as a bug verdict until that Assignment defines its own evidence bar.

## Checkout hygiene

| Checkout | Action this Run |
|---|---|
| Clean tip worktree @ `e1b28ae` | Docs-only adds (Assignment / AUTH / this evidence) |
| Home main `/Users/doubleshy0n/Dev/Universe Keyboard` | Untouched (left dirty) |
| reval-08-docs worktree (uncommitted INT-003 package) | Untouched |
