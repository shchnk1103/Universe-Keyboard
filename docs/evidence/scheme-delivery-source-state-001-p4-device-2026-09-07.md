# SCHEME-DELIVERY-SOURCE-STATE-001 Human device observations (P4 active uninstall) — 2026-09-07

**Assignment:** [`SCHEME-DELIVERY-SOURCE-STATE-001`](../assignments/scheme-delivery-source-state-001.md)
**Evidence grade:** `Human-attested` (conversation report). **Not** `Device-attested`.
**Collection date / timezone:** `2026-09-07 Asia/Shanghai`
**Operator:** Human Product Owner
**Recorder:** Grok iOS开发大师 session
**Engineering HEAD at report time:** `afa0c0ef8caca04579f8f0dfa1b1122110463557` (`codex/scheme-delivery-fix`, P4 + CI fixes)

This record is an index of Human statements. It is not a frozen payload manifest, not a journal paste, and not a Product Gate.

## Frozen engineering inputs (machine-known)

| Item | Value |
|---|---|
| Clone | `/private/tmp/uk-scheme-delivery-fix` |
| Branch / PR | `codex/scheme-delivery-fix` · [PR #100](https://github.com/shchnk1103/Universe-Keyboard/pull/100) draft |
| P4 engineering commit | `e213a25` — fail-closed active scheme uninstall |
| CI fix commits | `eed453d`, `afa0c0e` |
| CI | green |
| Related Human P3 device | [`p3-device`](scheme-delivery-source-state-001-p3-device-2026-09-07.md) |

## Missing identity (explicitly unavailable)

The Human-operated evidence profile was **not** satisfied. The following are `UNKNOWN` and keep this grade at Human-attested:

| Boundary | Status |
|---|---|
| Device / OS | not stated |
| Installed Main App UUID / SHA-256 / size | not captured |
| Keyboard Extension UUID / SHA-256 / size | not captured |
| Debug payload identity | not captured |
| Build configuration (Debug/Release, SDK, signing) | not captured |
| Scheme / config fingerprint | not captured |
| Full Access | not stated |
| Host app / field type | not stated |
| Operation ID / journal phases | not pasted |
| App Group live SHA of scheme files | not read |

Do not upgrade this file to `Device-attested` without a new run that fills those fields.

## Observation 1 — Active Ice uninstall smoke

Human Product Owner observed an **active Ice uninstall**:

| Step | Human result | Bound interpretation |
|---|---|---|
| Start uninstall while Ice active | proceeded (Human) | Matches P4 contract intent to leave active Ice only after Luna path |
| First switches to Luna | observed (Human) | Consistent with deploy-Luna-before-delete ordering |
| Error during switch / uninstall | none (Human) | Smoke only; not a failure-injection matrix |
| Luna input after uninstall | works (Human) | Smoke only; not F-02 quality re-gate |
| Settings shows Ice | `未安装` (Human) | UI state consistent with successful uninstall; not a file-tree audit |

## Explicitly not tested

- **Failure rollback** was **not** tested (Luna deploy failure, staging failure, or commit failure keeping the original scheme/files).

## Non-claims

- Not Product Gate Passed, not Device-attested, not ADR 0034 Accepted, not merge, not TestFlight / App Release.
- Not Wanxiang P4 upgrade/uninstall closure.
- Not proof of live App Group file removal beyond Settings `未安装`.
- Not proof of journal phases, lease ownership, or rollback correctness on device.
- Grade remains **Human-attested ONLY**.

## Relation to P4 engineering

P4 engineering (`e213a25`): active uninstall acquires commit lease, deploys Luna under that lease when target is active, stages removals, then commits; any failure keeps original selection/files. Unit coverage includes active success and failure paths. CI fixes `eed453d` / `afa0c0e` are green on this HEAD.

This Human report is **consistent with** the happy-path active uninstall ordering. It does **not** replace unit tests, does **not** cover failure rollback on device, and does **not** close Product Gate or independent Quality review.

## Next

Independent Quality review; Wanxiang P4 / upgrade contract; device Product Gate only under separate Human authorization. ADR 0034 remains Proposed.
