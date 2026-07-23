# Architecture Timeline

## Purpose

This timeline explains major architectural movement. It is not a changelog or current-status source. Follow each milestone to its ADR and current architecture document.

## Initial Direction: Thin Extension With Testable Core

The project separated input semantics into `KeyboardCore` and kept the custom keyboard UI in the Extension. This made state/action behavior testable without `UITextDocumentProxy` and isolated UIKit presentation concerns.

Current sources: `PROJECT_CONTEXT.md`, `architecture/swift6-migration.md`.

## RIME Consolidation And Main-App Deployment

Production RIME bridge code was consolidated in `Packages/RimeBridge`. Full deployment moved to the main App because configuration generation, maintenance and cache work are incompatible with Extension startup and key latency. The Extension became session-only.

Decisions: ADR 0001 and ADR 0004. Current source: `shared-container-and-rime-lifecycle.md`.

## App Group As Explicit Ownership Boundary

RIME shared/user data, preferences and diagnostics converged on the App Group. Later work clarified that sharing a container does not imply equal writers: the main App owns structural persistent operations, while Extension writes are limited to runtime-owned state.

Decision: ADR 0003.

## Inline Preedit And Marked-Text Contract

Composition moved into the host field using marked text to provide native composing feedback. Debugging showed that equal-content finalization needs `insertText` replacement, while differing display/raw content uses marked replacement followed by unmarking.

Current source: `input-pipeline-and-marked-text.md`. Related decision: ADR 0002.

## Candidate Paging And Selection Identity

Candidate presentation evolved from simple page display to accumulated paging and expanded panels. Normal RIME candidates retained selection references/global indexes so UI accumulation would not turn visible text into an ambiguous selection identity.

Current sources: `PROJECT_CONTEXT.md`, `UI_STYLE_GUIDE.md`.

## Nine-Key Precise Refinement Gains Retained Choice Identity

The first precise-pinyin design treated current RIME comments as the only path source and used an expanded panel. Real pinned-runtime evidence showed that a single `MNO` digit could expose only comment `o`, while all three direct refinements remained valid. The architecture now uses a narrow, bounded canonical key-identity source for a single unresolved digit, retains that issued choice snapshot across successful refinement, and routes direct taps plus repeated **选拼音** presses through one transactional Core path. Multi-key Chinese candidates and ranking remain RIME-owned.

Native iOS 27 observation then exposed a second boundary: whole-composition choices (`mi / ni`) coexist with first-key choices (`m / n / o`), and an explicitly selected first key remains focused across later digits. ADR 0021 Amendment A added a segmented state machine. Pinned librime proved that raw/candidate survival alone is not authorization (`n'i` falls back); bounded per-key probes must find the requested apostrophe-delimited segment in live comments. This produces `g / h` without a static pinyin graph, restores the ambiguous raw after probing, and keeps segment confirmation separate from candidate-finalizing **选定**.

Amendment B further forbids multi-syllable whole compact labels (e.g. `ni xian zai` as one cell), exposes progressive first-syllable + first-key choices only, advances with syllable-level next sets after confirmation, and treats a **direct path tap** as immediate confirm/advance while **选拼音** remains tentative first/next/wrap only.

Amendment C closes a long-input discovery gap: the first 16 ranked candidates are not treated as an exhaustive next-syllable catalog, and a non-empty exact result no longer suppresses bounded live-authorized branches. Discovery remains capped at 48 candidates plus one physical key group, restores raw after every probe, and always publishes a newly advanced focus without selecting for the user.

Amendment D separates internal raw identity from user-visible spelling across every fallback. Spaced digit tails now align Partial Commit to the true remaining suffix, and ordinary unconfirmed Delete refines the exact visible prefix rather than exposing a newly ranked completion.

Decisions: ADR 0020 and ADR 0021 (Amendments A/B/C/D). Current source: `KEYBOARD_LAYOUT.md` and `input-pipeline-and-marked-text.md`.

## Visibility Cleanup Becomes A Product Contract

Earlier recovery thinking treated reappearance as an opportunity to restore state. The accepted model now abandons unfinished composition, marked text, Partial Commit and candidate caches because host state may no longer match the in-memory session. Active-session recovery remains separate.

Decision: ADR 0002. Current source: lifecycle architecture.

## Fallback Clarified As Degraded Mode

Fallback exists to keep the keyboard responsive when prepared RIME runtime is unavailable. It was locked as non-equivalent degraded behavior rather than silent proof that the selected schema is healthy.

Decision: ADR 0008.

## Lua Deployment And Runtime Alignment

Lua support evolved from linked artifacts and partial stripping logic toward aligned module registration in main-App deployment and Extension sessions, schema-derived file diagnostics and explicit smoke evidence. Compile-time presence remains distinct from runtime success.

Decisions: ADR 0001 and ADR 0004. Current sources: scheme management, debugging and release. Historical detail: archived Lua capability plan.

## OpenCC Through RIME Configuration

Simplified/traditional conversion remained part of the deployed RIME schema/filter pipeline, with main-App-prepared configs and dictionaries. It was not implemented as post-commit application text rewriting, preserving RIME candidate semantics.

Current sources: `PROJECT_CONTEXT.md`, lifecycle architecture, debugging/release OpenCC sections. A dedicated rationale ADR remains missing if the integration strategy is reconsidered.

## User Dictionary Safety Direction

Candidate learning and backups became main-App-managed per-schema operations. Decision lock-in added the rule that restore must first create a verified safety backup; current implementation remains behind that accepted contract.

Decision: ADR 0005. Risk sources: `RIME_USER_DICTIONARY.md`, `TECH_DEBT.md`.

## Transactional Schema Installation Direction

The existing file-by-file installer was explicitly recognized as non-atomic. The accepted future model uses staging, validation, atomic switch or equivalent commit/rollback semantics without claiming current implementation support.

Decision: ADR 0006. Risk source: `TECH_DEBT.md`.

## Knowledge OS Formation

Documentation moved from accumulated context and plans toward explicit Source of Truth ownership, accepted ADRs, operational guides, technical-debt triggers and task-based navigation. This milestone governs discoverability; it does not change production architecture.

Current sources: `KNOWLEDGE_OS.md`, `DOCUMENTATION_GOVERNANCE.md`, `DOCUMENTATION_HEALTH.md`.

## Local Typing Intelligence Boundary

Typing statistics were introduced as a final-commit observation in KeyboardCore, followed by immediate content-free classification and bounded Extension-owned aggregation. The main App receives only versioned aggregate snapshots. Raw text, RIME output, candidate generation, host context and visibility lifecycle remain outside the feature.

SwiftData was rejected as the V1 cross-process authority; an explicit store protocol, coalesced App Group backend and reset epoch preserve Extension performance and deletion semantics while allowing a future backend migration.

Decision: ADR 0011. Product source: `TYPING_INTELLIGENCE.md`. Current runtime sources: input-pipeline and shared-container architecture documents.

## Portable RIME Sync And Unified Notification Ownership

Portable synchronization adopted RIME's official `sync_dir` / `sync_user_data` snapshots as the cross-frontend path while keeping Universe-managed settings in a separate encrypted package. Automatic maintenance remains main-App-only, requires an initial confirmed standard sync and follows a user-selected cooldown plus keyboard-activity safety gate.

System notifications and App operation Toasts later moved to one root-owned main-App model. RIME standard-data and Universe-settings notifications are independently selectable but never control the underlying sync work; both settings pages reuse the same state and delivery policy. The Keyboard Extension remains outside synchronization, permission and notification ownership.

Decisions: ADR 0012, ADR 0013, ADR 0014 and ADR 0019. Current sources: `RIME_SYNC.md` and `APP_NOTIFICATIONS.md`.

## 2026-07-21 — T9 Path Bar Amendments E/F/G

`KEYBOARD-LAYOUT-9KEY-PINYIN-002` 进一步把用户确认的音节绑定到 marked text、apostrophe 锚定的 live RIME session 与候选 provenance；后续完整音节采用最多 6 位、48 次的有界 live probe。普通逐键 preedit 改为每个输入槽位最多显示一个字母，RIME 的超前预测保留在候选层。长期规则收录于 ADR 0021。

## 2026-07-22 — T9 原子展示与固定发现成本

物理设备复现证明 ADR 0021 的逐拼写 live probe 会把一个 Path 点击放大成大量同步 session 操作，并且候选选择后的旧 segmented snapshot 可覆盖新余段。ADR 0022 接受单次固定 48 项只读窗口、Core composition revision 和来源安全的 host preedit 边界；候选 transition 先失效旧焦点，只对真正缩短的嵌套余段执行一次受限恢复。Stage A/定向自动化通过，iPhone 13 Pro Product Gate 仍独立等待人工证据。

## 2026-07-23 — T9 complete Path catalog + residual-B Path cursor

`KEYBOARD-LAYOUT-9KEY-PINYIN-004` / ADR 0023 landed via PR #27: compile-time local Path catalog, atomic composition revision, fixed-height Path Bar, Gate 5 β-limited identity, and Human H5 residual Pass.

Residual-B Path-ledger **cursor** (PD residual-B) landed via PR #28 after Human device Pass: after user Path-select stack + candidate partial, peel `K=min(CJK, stack)` syllables (slots follow syllables); soft-select next user-chosen Path syllable; unselected tails have no forged selection. Nested single-syllable pure-digit partials (e.g. `qiu→球`) keep shortened-remainder behavior.

Current sources: Assignment 004, ADR 0023, `partial-commit.md` §T9 Path residual-B, remediation evidence §21–§30.
