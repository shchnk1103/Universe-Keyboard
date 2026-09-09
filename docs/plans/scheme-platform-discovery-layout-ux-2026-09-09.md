# Scheme Platform — Discovery layout-page UX (Human Approved)

**Status:** **Human Approved** UX rules (`2026-09-09 Asia/Shanghai`) for a **later** Installed Capability Discovery / layout-picker Assignment (not yet drafted) — includes **layout settings page A/B**, **uninstall layout-fallback**, **Luna (builtin) presence**, and **confirmed-but-unready greying**.  
**Nature:** Product UX / binding contract for keyboard **layout** (26-key / nine-key / future) honesty + uninstall rebind. **Docs only** — not this Assignment’s P1 UI; not Swift; not push.  
**Carrier (P1 seams only):** [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](../assignments/scheme-delivery-scheme-platform-001.md) — P1 = capability **query** seams (+ readiness query if needed) + uninstall hook shape; **not** the Discovery layout-page UI.  
**Pointer from P0:** [`scheme-platform-p0-interfaces-2026-09-09.md`](scheme-platform-p0-interfaces-2026-09-09.md) §2 Layout (`onUninstallPrepare` / UninstallHooks).

---

## Priority (later Discovery Assignment)

**P1 of `SCHEME-DELIVERY-SCHEME-PLATFORM-001`:** declarative LayoutCapability + adapter **query** seams only (+ readiness query if needed) — **not** this UI.

**This layout-page UX** ships in a **later Discovery Assignment** (not yet drafted; separate Human Active).

---

## Layout settings page — Sections A / B

Applies per layout (26-key / nine-key / future): scheme picker honesty driven by installed + supported capabilities.

### Section A — Confirmed

Authority order (highest first):

1. **User override** (explicit user choice / prior confirmed binding)
2. **Package capability manifest** — **Universe convention** (app/package-declared layout capability), **not** a RIME built-in schema field. Format: [`universe-capabilities/v1`](scheme-platform-universe-capabilities-v1-2026-09-09.md) (`universe-capabilities.yaml` at package root → shared dir). Validation failure voids entire manifest (no partial apply).
3. **Catalog adapter declaration**

Eligibility: scheme is **installed** and **`supported = true`** for that layout.

**Readiness (Human Approved `2026-09-09`):** a scheme may be **confirmed** for Section A yet **unready** (missing deps / not deployable / readiness fail). Such entries stay in **Section A greyed with reason** (prefer **grey over hide** for honesty); click guides the user to fix; **no direct layout binding** until ready. Only **ready** A entries may receive a confirmed binding write.

Section A is the only source that may drive a **confirmed** binding write for the layout (and only when **ready**).

### Section B — Filename suggestions (try)

- Weak **filename / `schema_id` hints** only (e.g. `t9` / `nine` → candidate for nine-key).
- Labeled **unverified**; user **may try**.
- **Never auto-write binding** from filename alone.
- Successful try **or** explicit user confirm **promotes** the choice into **user override** (Section A).

### Filename never sole authority

Filename / `schema_id` string shape is **never** sole authority for layout capability or binding.

**RIME wiki conclusion (brief):** RIME has **no official layout-naming constraint** on schema ids / filenames that would make a name alone prove 26-key vs nine-key (or future) support. Hints are convenience only; capability still comes from A’s override / manifest / adapter path (or explicit user confirm promoting into A).

---

## Luna (`luna_pinyin`) — builtin exception (Human Approved)

**Luna** is a **builtin / Prelude exception**, not a normal third-party package candidate.

| Rule | Decision |
|---|---|
| **26-key Section A** | Luna is **always present** on 26-key Section A |
| **Nine-key Section A** | Luna is **never** on nine-key Section A |
| **Section B** | Luna is **not** a B filename suggestion |
| **Uninstall fallback** | Already aligned: else → **26-key + Luna (`luna_pinyin`)** (+ clear invalid nine-key) |

---

## Uninstall layout-fallback (Human Approved)

When **deleting / uninstalling** a scheme that **backs the current layout binding(s)** (26-key and/or nine-key), platform uninstall must **not** silently leave orphaned bindings.

**Applies via:** `SchemeLayoutAdapter.onUninstallPrepare` / `SchemeUninstallHooks` (see P0 §2 / §5.2). Warn UI may live in uninstall flow and/or later Discovery surfaces — **must not be silent**.

### Steps (order)

1. **Warn the user** before delete — uninstall that affects current layout binding(s) **must not be silent**.
2. Among **remaining installed** schemes, find **confirmed Section A** supporters of that layout that are **ready** (same readiness bar as binding: not greyed/unready), using the same authority order: **user override > package capability manifest > catalog adapter**. **Never** auto-pick **Section B** filename suggestions for rebind. **Unready** A entries are **not** auto-rebind candidates.
3. If at least one **ready** A candidate exists → **rebind** to the chosen candidate. Preference among candidates: **previously used > primary > stable default**.
4. Else (no **ready** A candidate) → fall back to **26-key + Luna (`luna_pinyin`)**; **clear** any invalid nine-key binding if needed.
5. **Then** proceed with uninstall. Existing **Luna-only active-uninstall** rules still apply (await successful Luna deploy before stage→commit when the uninstalled scheme was active; peers may remain installed but are not auto-selected as active).

### Non-negotiables

- No silent layout orphan after deleting the scheme that backs a binding.
- No auto-rebind from filename / Section B alone.
- Auto-rebind only among **ready** confirmed A candidates (align with readiness greying).
- Package capability manifest used in step 2 is **Universe convention**, not RIME built-in — see [`universe-capabilities/v1`](scheme-platform-universe-capabilities-v1-2026-09-09.md).
- Luna always on 26-key A; never on nine-key A; not a B suggestion; builtin exception.

---

## Section B try-failure (stub)

**Stub only** (not fully specified this record): if a Section B “try” fails (schema missing, deploy/session fail, or user abandons), **do not** promote into Section A; leave the suggestion **unverified**; keep any prior confirmed A binding unchanged. Full try-failure UX can be drafted with the later Discovery Assignment.

---

## Wanxiang nine-key (still deferred)

- Wanxiang nine-key **productization** remains **deferred** (later Assignment; may ride Discovery later or stay further deferred).
- Until productized, both `wanxiang_t9*` may appear in **Section B** (unverified try) later — **not** as Section A confirmed capability, and **not** via auto-bind from filename.

---

## Non-goals (this record)

- Implementing the layout-page UI in Scheme Platform P1
- Auto-binding / auto-rebind from filename / `schema_id` / Section B alone
- Auto-rebind to **unready** / greyed Section A candidates
- Hiding confirmed-but-unready entries instead of greying with reason
- Direct layout binding while confirmed-but-unready
- Treating Luna as a nine-key A candidate or as a Section B filename suggestion
- Treating filename as sole capability authority
- Treating package capability manifest as a RIME built-in field
- Putting filename heuristics into `universe-capabilities.yaml` (Section B App only)
- Silent uninstall when the deleted scheme backs current layout binding(s)
- Enabling Wanxiang nine-key productization in P1/P2
- Fully specifying Section B try-failure UX (stub only above)
- Push / ADR Accept / Product Gate / TF / Swift implied by this UX approval

---

## History

- `2026-09-09 Asia/Shanghai`: Human approved layout settings page A/B UX for later Discovery Assignment; P1 remains capability query seams only; local docs + commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human approved **uninstall layout-fallback** (warn → A-only rebind among remaining installed → else 26-key + Luna/`luna_pinyin` + clear invalid nine-key → then uninstall; Luna-only active-uninstall still applies). Package capability manifest = **Universe convention**, not RIME built-in. Section B try-failure stubbed. Local docs + commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human approved **Luna presence + readiness greying**: Luna **always** on **26-key Section A**; **never** on nine-key A; **not** a B filename suggestion; **builtin exception**; uninstall fallback already → 26+Luna. Confirmed-but-unready (missing deps / not deployable / readiness fail) → **greyed in A with reason** (prefer grey over hide); click guides fix; **no direct layout binding** until ready. Uninstall auto-rebind only among **ready** A candidates. Discovery Assignment scope; P1 only seams if needed for readiness query. Local docs + commit only; no push.
- `2026-09-09 Asia/Shanghai`: Human finalized **`universe-capabilities/v1`** as the package capability manifest format (Section A authority #2). Pointer: [`scheme-platform-universe-capabilities-v1-2026-09-09.md`](scheme-platform-universe-capabilities-v1-2026-09-09.md). Filename heuristics remain App Section B only (not manifest fields). Local docs + commit only; no push.
