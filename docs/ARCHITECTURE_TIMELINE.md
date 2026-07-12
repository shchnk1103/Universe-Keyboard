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
