# KEYBOARD-LAYOUT-9KEY-001 — Codex Review Handoff (Amendment Package)

Prepared by: Grok (Executor)
Handoff target: Codex (Architecture + Quality re-review)
Date: 2026-07-16 Asia/Shanghai
Branch: `feature/keyboard-layout-9key-spike`
Plan: [`docs/plans/keyboard-layout-9key-implementation-plan.md`](../plans/keyboard-layout-9key-implementation-plan.md)
Assignment: [`docs/assignments/keyboard-layout-9key-001.md`](../assignments/keyboard-layout-9key-001.md)

## Review response status

Codex conclusions on the first Spike package were accepted as the current Architecture/Quality gate:

| Item | First package | Amendment package |
|---|---|---|
| Spike technical direction | Conditional pass | Retained |
| Assignment `Active` | Rejected | Corrected to **`Ready`** with verifiable Decision Source |
| ADR 0018 | Not accepted (`Proposed` cannot authorize implementation) | Revised → **`Accepted; implementation pending`** |
| Spike evidence archival | Insufficient (weak asserts, unbound commit, vendor `|| true`) | Hardened; re-run bound to harness commit |
| Product implementation | Blocked | Still blocked until this amendment package is accepted and Executor enters `Active` under Entry Criteria |

Product code for steps 3–10 has **not** started.

---

## Codex P1/P2 remediation map

| ID | Issue | Resolution |
|---|---|---|
| P1 | Assignment Decision Source only pointed at the plan | Decision Source now cites Human Product Owner task instruction + Codex review conclusions; plan is labeled non-authority input; Product Approver = Human Product Owner |
| P1 | Proposed ADR allowed formal implementation | ADR no longer authorizes work while Proposed; status is `Accepted; implementation pending` only after required contract amendments |
| P1 | Readiness boolean / incomplete uninstall order | Versioned readiness marker (ready + compatibilityVersion + resourceFingerprint); ordered enable/disable; base-scheme switch keeps readiness when T9 files intact |
| P1 | No-candidate path could commit raw digits | Unconditional rule: during T9 composition, Return / language / auto-English never commit raw digits; table defines keep vs abandon |
| P2 | Spike OR assert allowed raw-only pass | Test now requires non-empty candidates **and** non-empty preedit; records first candidate comment |
| P2 | Evidence unbound to harness commit | Runner fails if HEAD lacks harness files or harness is dirty; records harness commit + log/vendor/schema SHA-256 |
| P2 | Vendor verify swallowed | `ensure_rime_vendor.sh verify` non-zero fails Spike |

---

## Section 13 checklist (amendment package)

### 1. Assignment and ADR paths

| Item | Path | Status |
|---|---|---|
| Assignment | `docs/assignments/keyboard-layout-9key-001.md` | Lifecycle **`Ready`** (not Active) |
| ADR | `docs/architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md` | **`Accepted; implementation pending`** |
| Domain doc | `docs/KEYBOARD_LAYOUT.md` | Updated for versioned readiness + no-raw-digit commit |
| Handoff | this file | Amendment package |

### 2. Changed-file allowlist (amendment + Spike harness)

```text
docs/assignments/keyboard-layout-9key-001.md
docs/architecture/decisions/0018-keyboard-layout-nine-key-and-t9-runtime.md
docs/KEYBOARD_LAYOUT.md
docs/KNOWLEDGE_INDEX.md
docs/READING_MAPS.md
docs/plans/keyboard-layout-9key-implementation-plan.md
docs/evidence/keyboard-layout-9key-001-codex-handoff.md
docs/evidence/keyboard-layout-9key-001/*
Packages/RimeBridge/Tests/RimeBridgeTests/RimeT9CompatibilitySpikeTests.swift
scripts/run_t9_compatibility_spike.sh
```

No product KeyboardCore / Extension / main-App settings implementation files.

### 3–4. Upstream / Spike results (hardened re-run)

| Field | Value |
|---|---|
| Status | **PASSED** |
| Harness commit | `337dd30ab443ad2d2af497648910946d6beb1a35` |
| Local full run | `evidence/keyboard-layout-9key-spike/20260716-195542/` |
| Full xcodebuild log SHA-256 | `784ac88f775d414cc7f181f55e9c7cdb0127b00c8d9d68a79eb59097c7ebe651` |
| Vendor verify log SHA-256 | `03fd59b207427813f241bb2217f226ac161e682885d370421269bff6e51b17e4` |
| Upstream schema SHA-256 | `56bc593d2c846666361b3394bdc0bdb0c6f1a663f1fd810dceab2d222b5bf8f6` |
| Patched schema SHA-256 | `176a01aefcfeba856906ba6e83a9cf147fbd57d39f9923c70b36879c8bb5d57b` |
| Machine summary | `schema=t9 rawAfter64=64 preeditAfter64=64 candidateCount=9 firstCandidateComment=ni rawAfterDelete=6` |

Tracked under `docs/evidence/keyboard-layout-9key-001/`:

- `upstream-t9.schema.yaml`
- `patched-t9.schema.yaml`
- `provenance.md`
- `spike-result.md`
- `archive-hashes.md`
- `rime-vendor-verify.log`
- `xcodebuild-t9-spike-excerpt.log`

### 5–7. Product tests / screenshots / device

Still **not executed** — product implementation not authorized to start until amendment package closes the Architecture gate and Assignment becomes `Active` under Entry Criteria.

### 8. Known residual risks

- `essay` read-only warning during deploy still needs product packaging investigation.
- First-candidate comment may be empty even when candidates exist; display must still fall back to raw digits for preedit only, never for host commit.
- Physical-device acceptance remains Human Product Owner dependency.

---

## Recommended Codex re-review outcomes

1. Accept Assignment lifecycle `Ready` and Decision Source wording, or request further identity/reference formatting.
2. Accept ADR 0018 as `Accepted; implementation pending`, or mark residual ADR edits.
3. Accept hardened Spike archive if harness commit + SHA-256 fields are complete.
4. Authorize Executor to move Assignment `Ready -> Active` for plan steps 3–10 **without** a librime upgrade task.
