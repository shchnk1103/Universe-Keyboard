# Product Decision: RELEASE-2026-0801-08 Kaomoji Launch Catalog Authorization

**Decision ID:** `PD-RELEASE-2026-0801-08`

**Lifecycle status:** Recorded

**Date / timezone:** `2026-07-21 Asia/Shanghai`

**Assignment:** [`RELEASE-2026-0801-08`](../assignments/release-2026-08-01-08-kaomoji-content.md)
**Parent release:** [`RELEASE-2026-0801`](../assignments/release-2026-08-01.md)

## Authority

- **Product Approver / Decision maker:** Human Product Owner acting as Product Lead. The Product Owner explicitly approved a self-built offline launch catalog, prohibited third-party copyright-restricted content, and authorized the current Codex task to continue the remaining in-scope KOS 2.0 work (`2026-07-21 Asia/Shanghai`).
- **Assignment Authority:** Product Lead under [`ASSIGNMENT_POLICY.md`](../ASSIGNMENT_POLICY.md).
- **Domain Owner / Executor:** ⌨️ Keyboard Experience Maintainer / current Codex task, limited to keyboard UI, catalog presentation and insertion wiring.
- **Environment Executor:** Current Codex task for simulator validation; Human Product Owner for physical-device interaction and final Product Gate.
- **Independent review:** 🧪 Quality, Performance & Release Maintainer supplies the Quality conclusion. Architecture review is required only if the approved no-storage/no-network boundary changes.

## Bound Product Decisions

1. V1.0 ships a **self-built, bundled, offline** catalog of 48 kaomoji: four user-visible categories with 12 entries each.
2. The catalog is source code bundled with the Keyboard Extension. It has no network request, third-party catalog import, account, analytics, synchronization, learning, recent-history or user-editable/persisted content.
3. The initial categories are `常用`、`开心`、`互动` and `情绪`. Each entry is a short, self-built Unicode text expression selected for ordinary conversational use.
4. The existing `^_^` control must truthfully open the catalog. Selecting an entry inserts that exact text through the existing final-commit path; it must not bypass marked-text cleanup, local typing statistics, or the RIME session boundary.
5. The catalog must be usable on supported iPhone and iPad keyboard layouts, in light/dark appearance, with semantic VoiceOver labels. Dynamic Type review remains a required Quality check.

## Content And License Boundary

- The launch list is created and maintained in this repository. It does not copy a third-party catalog, character-art collection, branded phrase, artwork, name, logo or attribution-required dataset.
- The catalog contains text expressions only. It contains no image, font, audio, remote asset or user content.
- The Unicode characters themselves are used as ordinary text input. This decision does not make a claim about ownership of Unicode standards or system fonts.

## Non-goals

- User-created, imported, synchronized, ranked or recent kaomoji
- A network-delivered catalog or content service
- Main-App settings, account, analytics or persistence
- Changes to RIME deployment, candidate semantics or nine-key pinyin behavior
- App Store Connect submission, public metadata publication or final Product Gate acceptance

## Gates And Revalidation

- The catalog must remain bounded and bundled. Any source, storage, synchronization, account, personalization, analytics, content-policy or cross-target change requires Product Lead revalidation.
- Any change to marked-text finalization, statistics source classification, RIME session ownership or keyboard lifecycle requires Architecture review before implementation continues.
- Completion of implementation is not Quality or Product acceptance; independent evidence remains required by the Assignment.
