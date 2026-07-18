# KEYBOARD-LAYOUT-9KEY-PINYIN-001 — Product Gate Human Dependency Handoff

Prepared by: Grok（Executor / Domain Owner mirror under KOS 2.0）  
Handoff target: **Human Product Owner** (device capture) → Quality device review → **Product Lead** (Product Gate)  
Date / timezone: `2026-07-18 Asia/Shanghai`  
Branch: `feature/keyboard-layout-9key-pinyin-001`  
HEAD (dirty worktree baseline): `44d42130bd8e2012bce7b4c034c4bc51a149dec3`

> Assignment remains **`Active`**.  
> Architecture **Pass** and automated Quality **Pass** do **not** equal Product Gate Pass.  
> No commit / push / PR is authorized by this handoff.

---

## 1. Gate snapshot (authoritative: Codex rereview-5)

| Gate | Status | Source |
|---|---|---|
| Architecture | **Pass** | [`keyboard-layout-9key-pinyin-001-codex-rereview-5.md`](keyboard-layout-9key-pinyin-001-codex-rereview-5.md) |
| Quality (automated implementation matrix) | **Pass** | same |
| Product Gate | **Open** | Human Dependency unsatisfied |
| Publication | **Not Ready** | dirty tree; no publication authority |
| Lifecycle | **`Active`** | not Completed / Reviewed / Closed |

---

## 2. What is already proven (do not re-debate in device session)

- Paths from RIME candidate comments only; current-comment-only authorization.
- Dual revision: `rawInputGeneration` (raw lifecycle) vs `provenanceRevision` (comment authority).
- New RimeOutput apply always hard-opens provenance (including same-raw comment change).
- Soft re-scan preserves same-snapshot expanded issuance only.
- Exact usable `replaceInput` refine; fail-closed rollback; no raw host commit on mixed T9 Space/Return/language.
- Automated: KeyboardCore 615 tests (21 path tests), KeyboardTests 6, Debug/Release strict Simulator builds.

---

## 3. Human Product Owner — required Product Gate captures

Record under a dated folder, for example:

`evidence/keyboard-layout-9key-pinyin-product-gate/YYYYMMDD-HHMMSS/`

Minimum matrix (plan / Assignment exit criteria):

1. **Composition refine:** type `6` → `64` → open 选拼音 → select `ni` (or visible path) → raw becomes letter form; Chinese candidates narrow; **no** host raw commit.
2. **Mixed continue:** after path, digit (e.g. `ni` + `4` → `ni4`); Delete reduces composition correctly.
3. **Space / Return with candidates:** commits Chinese candidate text only, never digit/letter raw.
4. **Space / Return without candidates:** keeps composition; no raw host commit.
5. **Language / abandon:** abandon composition without raw leak.
6. **Path bar / panel layout:** fixed 34 pt path bar reservation; no height thrash; panel mutually exclusive with candidate expansion.
7. **Panel scroll / lazy paths:** long candidate list; expanded paths remain selectable within same composition; after engine comment change, stale panel does not authorize removed paths (if reproducible).
8. **VoiceOver:** 选拼音 control and path cells have usable labels; no business payload in a11y identity of letter keys.
9. **Key latency:** subjective/measured key-to-marked-text and candidate update on physical device; note any freeze or multi-second stalls.
10. **Native side-by-side (optional but requested):** screenshots/video vs system 九宫格 for chrome + refine expectations (product comparison, not identical engine).

Also capture: device model, iOS version, build configuration (Debug/Release), schema/runtime (`t9` / nine-key readiness).

---

## 4. Quality / Product Lead after device capture

1. Quality reviews device evidence against Stop Conditions and exit criteria.  
2. Product Lead decides Product Gate **PASS / FAIL / changes required**.  
3. Only on Product Gate PASS + Human publication authorization: form clean commit, optional Spike re-archive on clean tree, push/PR per release policy.  
4. Lifecycle `Completed` → `Reviewed` → `Closed` only via Product Lead after Gate PASS and required reviews.

---

## 5. Explicit non-actions for Executor

- Do not mark Assignment `Completed` / `Reviewed` / `Closed`.  
- Do not declare Product Gate Pass from simulator-only evidence.  
- Do not commit/push/PR without Human Product Owner publication authority.  
- Do not re-open Architecture fix loop without a new Codex Fail or product change request.

---

## 6. Related docs

- Assignment: [`keyboard-layout-9key-pinyin-001.md`](keyboard-layout-9key-pinyin-001.md)  
- Product Decision: [`../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-001-authorization.md`](../product-decisions/KEYBOARD-LAYOUT-9KEY-PINYIN-001-authorization.md)  
- ADR 0020: [`../architecture/decisions/0020-t9-precise-pinyin-path-selection.md`](../architecture/decisions/0020-t9-precise-pinyin-path-selection.md)  
- Codex Pass: [`keyboard-layout-9key-pinyin-001-codex-rereview-5.md`](keyboard-layout-9key-pinyin-001-codex-rereview-5.md)  
- Last code handoff: [`keyboard-layout-9key-pinyin-001-grok-fix-handoff-5.md`](keyboard-layout-9key-pinyin-001-grok-fix-handoff-5.md)  
- Dashboard: [`../ENGINEERING_DASHBOARD.md`](../ENGINEERING_DASHBOARD.md)
