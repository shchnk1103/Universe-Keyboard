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
| P1 | Extract Ice hooks → platform; Ice behavior unchanged. **Human-approved order (`2026-09-10`):** P1-0→P1-6 — see [`scheme-platform-p1-extract-plan-2026-09-10.md`](scheme-platform-p1-extract-plan-2026-09-10.md). **P1-0 (done):** plan + Ice regression checklist (docs). **P1-1 (pushed on #102):** SchemeAdapter registry. **P1-2 (pushed on #102 tip `5bba4d2` / CI green):** LayoutCapability + route `isNineKeyCapable`/`isTwentySixKeyCapable` via registry；Ice T9 unchanged；Wanxiang nine=false. **P1-3 (on #102 tip `22c6b79`/`d8e8299` / CI green):** SharedDefault Ice `privatePreset` seam via registry；Wanxiang consumePrelude unchanged. **P1-4 (done locally this tip):** ResourceOwnership `namedList`+`exactHash`；uninstall/checkpoint staging via strategies；Wanxiang OpenCC admitted=false. **P1-5:** Uninstall hook shape (Ice layout fallback only; awaiting auth). **P1-6:** summary + IQ (no silent conditional close). **KOS:** local commit per slice; ask before push; no ADR Accept. Scope: LayoutCapability + ResourceCapability/ownership; adapter lookup (Ice-only nine-key; Wanxiang `supportsNineKey=false`); SharedDefault = Ice `privatePreset` only; Ownership = `namedList`+`exactHash`. **Not P1 UI:** Discovery / layout-picker |
| P2 | Migrate Wanxiang onto platform (lua / layout / **SharedDefault → `privatePreset`** same as Ice; **Ownership stays dual** — Wanxiang platform path **keeps `exactHash`**); `consumePrelude` **not** Wanxiang end-state; fidelity risk → product regression |
| P3 | Remove redundant forks; only then revisit A34-R1 disposition / ADR Accept path |
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
