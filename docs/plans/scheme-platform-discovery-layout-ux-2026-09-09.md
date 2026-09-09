# Scheme Platform — Discovery layout-page UX (Human Approved)

**Status:** **Human Approved** UX rules (`2026-09-09 Asia/Shanghai`) for a **later** Installed Capability Discovery / layout-picker Assignment (not yet drafted).  
**Nature:** Product UX contract for the keyboard **layout settings page** (26-key / nine-key / future). **Docs only** — not this Assignment’s P1 UI; not Swift; not push.  
**Carrier (P1 seams only):** [`SCHEME-DELIVERY-SCHEME-PLATFORM-001`](../assignments/scheme-delivery-scheme-platform-001.md) — P1 = capability **query** seams; **not** this layout-page UI.  
**Pointer from P0:** [`scheme-platform-p0-interfaces-2026-09-09.md`](scheme-platform-p0-interfaces-2026-09-09.md) §2 Layout.

---

## Priority (later Discovery Assignment)

**P1 of `SCHEME-DELIVERY-SCHEME-PLATFORM-001`:** declarative LayoutCapability + adapter **query** seams only — **not** this UI.

**This layout-page UX** ships in a **later Discovery Assignment** (not yet drafted; separate Human Active).

---

## Layout settings page — Sections A / B

Applies per layout (26-key / nine-key / future): scheme picker honesty driven by installed + supported capabilities.

### Section A — Confirmed

Authority order (highest first):

1. **User override** (explicit user choice / prior confirmed binding)
2. **Package capability manifest**
3. **Catalog adapter declaration**

Eligibility: scheme is **installed** and **`supported = true`** for that layout.

Section A is the only source that may drive a **confirmed** binding write for the layout.

### Section B — Filename suggestions (try)

- Weak **filename / `schema_id` hints** only (e.g. `t9` / `nine` → candidate for nine-key).
- Labeled **unverified**; user **may try**.
- **Never auto-write binding** from filename alone.
- Successful try **or** explicit user confirm **promotes** the choice into **user override** (Section A).

### Filename never sole authority

Filename / `schema_id` string shape is **never** sole authority for layout capability or binding.

**RIME wiki conclusion (brief):** RIME has **no official layout-naming constraint** on schema ids / filenames that would make a name alone prove 26-key vs nine-key (or future) support. Hints are convenience only; capability still comes from A’s override / manifest / adapter path (or explicit user confirm promoting into A).

---

## Wanxiang nine-key (still deferred)

- Wanxiang nine-key **productization** remains **deferred** (later Assignment; may ride Discovery later or stay further deferred).
- Until productized, both `wanxiang_t9*` may appear in **Section B** (unverified try) later — **not** as Section A confirmed capability, and **not** via auto-bind from filename.

---

## Non-goals (this record)

- Implementing the layout-page UI in Scheme Platform P1
- Auto-binding from filename / `schema_id` alone
- Treating filename as sole capability authority
- Enabling Wanxiang nine-key productization in P1/P2
- Push / ADR Accept / Product Gate / TF / Swift implied by this UX approval

---

## History

- `2026-09-09 Asia/Shanghai`: Human approved layout settings page A/B UX for later Discovery Assignment; P1 remains capability query seams only; local docs + commit only; no push.
