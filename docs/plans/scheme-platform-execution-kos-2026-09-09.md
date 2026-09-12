# Scheme Platform — Execution / KOS cadence (2026-09-09)

**Assignment:** [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](../assignments/scheme-delivery-scheme-platform-001.md) (**Active**)
**Frozen tip:** `origin/main` @ `814abfd7c03002256978d7658c176b80002d2539`
**Branch:** `codex/scheme-platform-001` (created from `origin/main`; **not** PR #101 branch)
**Related:** [`SCHEME-DELIVERY-WANXIANG-P4-CLOSURE-001`](../assignments/scheme-delivery-wanxiang-p4-closure-001.md) (**Paused** — shelved for Scheme Platform; A34-R1 still open — NOT Closed/Done)

## Cadence

| Step | Rule |
|---|---|
| Update docs | Allowed on this Active Assignment (governance / P0 docs / pointers) |
| Local commit | Allowed |
| First push / PR | **Ask Human before first push/PR**; no ongoing draft push auth |
| PR vehicle | **New** draft PR — **not** #101; leave #101 alone (Human: leave draft #101 until platform progresses; keep #101≠#102; no Accept ADR 0034 now; Accept prep/cross-links later) |
| P0 | Interface draft + 「Ice already satisfies / Wanxiang gaps」 matrix (docs only) |
| P1 | Extract Ice hooks → platform; Ice behavior unchanged. **Human-approved order (`2026-09-10`):** P1-0→P1-6 — see [`scheme-platform-p1-extract-plan-2026-09-10.md`](scheme-platform-p1-extract-plan-2026-09-10.md). **P1-0…P1-6 (done on #102 tip `cd4fa65` / CI full green):** registry → LayoutCapability → SharedDefault Ice `privatePreset` → ResourceOwnership dual → UninstallHooks Ice fallback → summary + IQ **Pass with conditions**（freeze `3cfa355`）。**SP-P1-IQ-01 `fix`**（KOS residual close；runs `34628171114` + `34629774209`）。keep Active；next P2 awaiting auth；ask before push；no silent close of remaining residuals；no ADR Accept；no undraft/merge #102 without auth. Scope: LayoutCapability + ResourceCapability/ownership; adapter lookup (Ice-only nine-key; Wanxiang `supportsNineKey=false`); SharedDefault = Ice `privatePreset` only; Ownership = `namedList`+`exactHash`; UninstallHooks = Ice layout fallback. **Not P1 UI:** Discovery / layout-picker |
| P2 | **Done (`2026-09-12`) tip `7c93904`:** Wanxiang on platform (lua / layout / **SharedDefault → `privatePreset`** — `wanxiang_preset.yaml`; **Ownership dual / `exactHash`**); plan/post `wanxiang-plan-2`/`wanxiang-post-2`; hosted CI run `34672873379` full green; Simulator product smoke Pass; keep Active |
| P3 | **In progress (`2026-09-12`):** Remove redundant forks per [`scheme-platform-p3-fork-cleanup-2026-09-12.md`](scheme-platform-p3-fork-cleanup-2026-09-12.md) — DELETE `downloadState` rename + registry `postProcessingRevision` + `SchemePostExtractHooks` Ice T9; KEEP list written (display names / license·version mirrors / Discovery / nine-key / A34-R1…). Exit = plan complete **or** Human written keep-list (both supplied). **Only after P3** revisit A34-R1 / ADR Accept path (**no Accept this slice**); **ask before push**; keep Active |
| Wanxiang P4 | **Paused**; A34-R1 writeback **later** — Pause ≠ Closed/Done |
| Non-claims (Gate 0 slice) | No ADR Accept; no Product Gate / TestFlight; no Swift |

## Gate 0 slice boundary

Governance + bring docs + embed this execution plan. Do **not** Accept ADR 0034, open Product Gate/TF, or write Swift in this slice.

## History

- `2026-09-09 Asia/Shanghai`: Human Gate 0 authorized Active platform + Pause Wanxiang P4; local branch `codex/scheme-platform-001` from `814abfd`; ask-before-first-push/PR.
- `2026-09-09 Asia/Shanghai`: P0 docs complete (interfaces + Ice/Wanxiang matrix); local commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human approved P1↔Discovery split recorded (P1 seams vs later Discovery Assignment); local commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human approved Discovery layout-page A/B UX (later Assignment; P1 = query seams only); see [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md); local commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human approved uninstall layout-fallback (warn → A-only rebind / else 26-key+Luna; Universe package manifest ≠ RIME built-in); see [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md); local commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human SharedDefault decision — end-state Ice-shaped `privatePreset` for third-party; P1 extract Ice only (Wanxiang skip/`consumePrelude` transitional); P2 Wanxiang → `privatePreset` (`consumePrelude` not end-state); Luna Prelude/builtin exception OK; fidelity risk → product regression; local commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human Lua/OpenCC Ownership decision — unified ResourceOwnership/ResourceCapability; long-term dual `namedList` + `exactHash` (not forced to one); no dangerous filename heuristics auto-remove; no whole-dir wipe; Settings confirmed honesty + optional user marking; OpenCC Wanxiang may `admitted=false`; P1 wire both unchanged; P2 keep `exactHash` on platform; contrast SharedDefault → `privatePreset`; local commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human approved Luna presence + readiness greying (Luna always 26-key A / never nine-key A / not B / builtin; confirmed-but-unready greyed in A with reason; uninstall auto-rebind ready A only; P1 readiness query seams if needed); see [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md); local commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human finalized [`universe-capabilities/v1`](scheme-platform-universe-capabilities-v1-2026-09-09.md) (`universe-capabilities.yaml`; fail-closed whole-manifest validation; authority priority; no filename heuristics in manifest; adapter/community distribution rules); local commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human ADR/#101 — leave draft #101 until platform progresses; no Accept ADR 0034 now; keep #101≠#102; Accept prep/cross-links (A34-R8-style) later; local commit only; no push.
- `2026-09-10 Asia/Shanghai`: Human finalized Section B try-failure state machine (idle→trying→succeeded_pending_confirm|failed→idle; snapshot; no binding until confirm; deps pre-block; fail→restore stay B; success+confirm→promote A; hide-from-B manual only; B never uninstall auto-rebind; P1 may add rollback try-deploy seam); see [`scheme-platform-discovery-layout-ux-2026-09-09.md`](scheme-platform-discovery-layout-ux-2026-09-09.md); local commit only; no push.
- `2026-09-10 Asia/Shanghai`: Human approved P1-0→P1-6 extract order; P1-0 plan + Ice regression checklist landed ([`scheme-platform-p1-extract-plan-2026-09-10.md`](scheme-platform-p1-extract-plan-2026-09-10.md)); local commit only; no push; no Swift; ask before P1-1 Swift.
- `2026-09-10 Asia/Shanghai`: P1-1 SchemeAdapter registry landed locally (Ice/Wanxiang/Luna + tests; thin postProcessingRevision bridge); no push; no ADR Accept; no Wanxiang nine-key; no Discovery UI; next P1-2.
- `2026-09-11 Asia/Shanghai`: P1-2 LayoutCapability pushed on #102 tip `5bba4d2` (CI green); Ice T9 unchanged; Wanxiang nine=false.
- `2026-09-11 Asia/Shanghai`: P1-3 SharedDefault Ice `privatePreset` seam landed locally (registry applicator; Wanxiang consumePrelude unchanged); local commit only; ask before push; next P1-4 awaiting auth.
- `2026-09-11 Asia/Shanghai`: P1-4 ResourceOwnership dual strategies landed locally (namedList+exactHash via registry; installer staging calls strategies; Wanxiang OpenCC admitted=false); prior P1-3 tip `22c6b79`/`d8e8299` CI green; local commit only; ask before push; next P1-5 awaiting auth.
- `2026-09-12 Asia/Shanghai`: P1-5 UninstallHooks Ice layout fallback landed locally (`SchemeUninstallHooks` + registry `prepareUninstallLayoutFallback`; Ice behavior unchanged; no Discovery UI); P1-4 tip `5c42546`/`82bdd60` CI fully green; local commit only; ask before push; next P1-6 summary+IQ awaiting auth.
- `2026-09-12 Asia/Shanghai`: P1-6 summary + Independent Quality (**Pass with conditions** on freeze `3cfa355`); keep Platform Active; next P2 awaiting Human auth; local commit only; ask before push; no ADR Accept; no Assignment Close; no Product Gate/TF.
- `2026-09-12 Asia/Shanghai`: **SP-P1-IQ-01 closed** (`fix`) per Human KOS residual writeback; evidence `3cfa355` run `34628171114` + tip `cd4fa65` run `34629774209` full green; ask before push; keep Active; no undraft/merge #102.
- `2026-09-12 Asia/Shanghai`: **P2 landed locally** — Wanxiang SharedDefault → `privatePreset` (`wanxiang_preset`); ownership stays `exactHash`; catalog plan2/post2 + recomputed staged SHA; local commit only; ask before push; keep Active; next after push = CI / product regression note; no Wanxiang nine-key; no Discovery UI; no ADR Accept; no Assignment Close.
- `2026-09-12 Asia/Shanghai`: **P2 Done** tip `7c93904` (CI `34672873379` green; Simulator smoke Pass) + **P3 started** — plan + DELETE D1–D4 + KEEP K1–K12; local commit only; ask before push; keep Active; A34-R1 revisit path note only (no Accept); no Assignment Close; leave #101; no undraft/merge #102; no Wanxiang nine-key; no Discovery UI.
