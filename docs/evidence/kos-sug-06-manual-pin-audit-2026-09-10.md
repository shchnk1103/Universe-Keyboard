# KOS-SUG-06 — 手工 pin 一致性审计（2026-09-10）

**Status:** `Executor-recorded` manual documentation audit; not a Product,
Quality Gate, CI, publication, or upstream-release check.

**Assignment:** [KOS-SUG-PIN-AUDIT-001](../assignments/kos-sug-pin-audit-001.md)
**Scope:** Current local documentation and JSON mirrors only.

## Canonical expected values

| Field | Canonical source | Expected value |
|---|---|---|
| Adopted version | [`UPGRADE_STATUS.md`](../kos/UPGRADE_STATUS.md), [`.kos/project.json`](../../.kos/project.json) | `v0.8.0` |
| Adopted commit | [`.kos/project.json`](../../.kos/project.json) | `2c9907565bf6b6fcd00e698cc539d9e2db573bc5` |
| Envelope mode | [`.kos/project.json`](../../.kos/project.json) | `advisory` |
| Optional-contract boundary | Both canonical sources | E-01, A-01/B-01, P-01 and D-01 require explicit opt-in on new records only; existing Active Assignments do not migrate; H-02/W-01 and `required` are outside adoption |

## Method

1. Read the two canonical sources above without querying upstream or changing
   their values.
2. Compare their version, mode and optional-contract boundary with each named
   current mirror below.
3. Mark each mirror `match`, `mismatch`, or `not-applicable`. Retain a mismatch
   as a finding for Product/Assignment handling; do not normalize it silently.

## Results

| Mirror | Result | Observed current wording / basis |
|---|---|---|
| [`AGENTS.md`](../../AGENTS.md) | `match` | `v0.8.0`, `advisory`, explicit new-record opt-in for E-01/A-01/B-01/P-01/D-01, and no `required` |
| [`KNOWLEDGE_OS.md`](../KNOWLEDGE_OS.md) | `match` | `v0.8.0` advisory; named opt-in contracts; points to `UPGRADE_STATUS.md` and `.kos/project.json` |
| [`docs/kos/README.md`](../kos/README.md) | `match` | `v0.8.0` advisory; named opt-in contracts; no KOS 2.0 replacement or `required` claim |
| [`READING_MAPS.md`](../READING_MAPS.md) | `match` | Current entry directs to `UPGRADE_STATUS.md` and UK-004; describes advisory-only boundary |
| [`CI_CHANGE_CLASSIFICATION.md`](../CI_CHANGE_CLASSIFICATION.md) | `match` | Uses `kos-agent-kit@v0.8.0` for the advisory CI validation boundary; does not claim required checks or upstream validation |

**Audit result:** `match` for all five named mirrors. No mismatch was found in
the authorized local scope.

## Evidence grade

`Executor-recorded` — the executor read the named local sources. Quality has
not independently re-run this audit until its linked review records that fact.

## Exclusions and revalidation

- No network call or upstream-release discovery occurred; this audit does not
  establish that `v0.8.0` is upstream-latest.
- No CI/workflow/script automation, historical migration, device/data action,
  commit, push, PR, merge, TestFlight, Release, or D-01 receipt occurred.
- Re-run this manual audit after any adopted version/mode/optional-contract
  change, current-mirror wording change, or separately authorized upstream
  release check. A future automated checker needs its own Assignment and
  Authorization.
