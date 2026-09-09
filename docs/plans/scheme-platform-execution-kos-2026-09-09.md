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
| PR vehicle | **New** draft PR — **not** #101; leave #101 alone |
| P0 | Interface draft + 「Ice already satisfies / Wanxiang gaps」 matrix (docs only) |
| P1 | Extract Ice hooks → platform; Ice behavior unchanged (needs separate Swift auth beyond Gate 0 docs slice). **Human-approved P1 scope:** LayoutCapability + ResourceCapability/ownership seams; adapter lookup (Ice-only nine-key; Wanxiang `supportsNineKey=false`); Lua/OpenCC strategy APIs; **SharedDefault = extract Ice `privatePreset` only** (Wanxiang may keep skip/`consumePrelude` transitional); **Ownership = wire Ice `namedList` + Wanxiang `exactHash`** (behavior unchanged; no filename-heuristic auto-remove; no whole-dir wipe). **Not P1:** Installed Capability Discovery / layout-picker (later Assignment, not yet drafted) |
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
