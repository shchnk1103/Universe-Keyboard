# Technical Debt

## Purpose

This is the canonical register for known engineering risks that have an accepted direction but are not implemented or fully evidenced. A debt item is not a statement that the recommended fix already exists.

Creation, repayment and removal follow `docs/DOCUMENTATION_GOVERNANCE.md`. Plans and changelog entries may link here but must not maintain a competing debt status.

## TD-001: Atomic Schema Installation

- **Priority:** High
- **Risk:** File-by-file replacement can leave a mixed or partial scheme installation after interruption.
- **Current mitigation:** Main-App-only installation, deployment pending flags, redownload/reinstall recovery and release checks.
- **Recommended fix:** Stage and validate a complete scheme, then atomically switch directories or use an equivalent commit/rollback transaction.
- **Owner area:** Main App `SchemaArchiveInstaller` / schema deployment.
- **Trigger to resolve:** Before supporting unattended scheme updates, multiple downloadable schemes or production recovery guarantees.

## TD-002: Validate RIME/User Concurrent Access

- **Priority:** High
- **Risk:** Main-App backup/restore/configuration can overlap with Extension/librime writes to `Rime/user`.
- **Current mitigation:** Heavy user-dictionary operations remain in the main App and are not run from the key hot path; documentation advises avoiding active-session overlap.
- **Recommended fix:** Establish librime-supported cross-process semantics and add file/process coordination or an explicit quiesce workflow where required.
- **Owner area:** RimeBridge, main-App user dictionary, Extension lifecycle.
- **Trigger to resolve:** Before enabling background/automatic restore or claiming safe operation while the Keyboard Extension may be writing.

## TD-003: Collect Extension Performance Baseline

- **Priority:** High
- **Risk:** Startup, input, candidate or memory regressions cannot be judged against evidence; jetsam may be mistaken for an ordinary lifecycle exit.
- **Current mitigation:** Coarse performance logging and manual release checks.
- **Recommended fix:** Collect the metrics and traces defined in `docs/PERFORMANCE_BASELINE.md`, then review evidence before setting budgets.
- **Owner area:** Keyboard Extension, KeyboardCore, RimeBridge, test/release.
- **Trigger to resolve:** Before TestFlight expansion, App Store submission or accepting a performance-sensitive architecture change.

## TD-004: Implement Full Access Degradation Matrix

- **Priority:** High
- **Risk:** Shared features can fail silently or UI may claim a capability is active when App Group access is unavailable; design matrix may overstate RIME-off without FA on some OS builds.
- **Current mitigation:** `RequestsOpenAccess=true`, activation Guide + `ONBOARDING_ACTIVATION.md` under `RELEASE-2026-0801-03` (Conditional Product Gate). Device matrix on iPhone 13 Pro / iOS 27 beta 3 shows basic+RIME `nihao` still works with FA off when 雾凇 is pre-deployed; **haptics** are the clear FA-linked gap; no Extension degradation banner.
- **Recommended fix:** (1) Architecture-verify App Group / `runtimeDirectories` under FA off after cold Extension launch; (2) rewrite user-facing matrix around **observed** dependencies (feedback first); (3) add Extension-visible degraded cue when shared feedback/settings fail; (4) re-run on/off evidence before claiming self-diagnosing setup.
- **Owner area:** Main App onboarding/settings, Keyboard Extension bootstrap, diagnostics.
- **Trigger to resolve:** Before broad external testing or any claim that setup failures are self-diagnosing.

## TD-005: Complete Crash, Jetsam And Symbolication Handbook

- **Priority:** High
- **Risk:** Extension termination cannot be reliably classified or traced to an exact release build.
- **Current mitigation:** Minimal guidance in `docs/DEBUGGING.md` and release evidence requirements.
- **Recommended fix:** Document archive retention, dSYM mapping, device-log collection, Organizer workflow, jetsam classification and evidence storage.
- **Owner area:** Test/release and Keyboard Extension operations.
- **Trigger to resolve:** Before TestFlight or immediately after the first unexplained production/TestFlight termination.

## TD-006: Reproducible xcframework Build And SBOM

- **Priority:** High
- **Risk:** Pinned hashes verify downloaded bytes but do not prove reproducible provenance or provide dependency/security inventory.
- **Current mitigation:** Fixed release asset, SHA-256 manifest, required-framework inventory and local receipt verification.
- **Recommended fix:** Pin toolchains/sources/build flags, automate reproducibility comparison, generate an SBOM and define vulnerability response.
- **Owner area:** RimeBridge artifacts and release engineering.
- **Trigger to resolve:** Before publishing a new vendor artifact version or App Store release relying on rebuilt dependencies.

## TD-008: Complete Portable RIME Data Compatibility

- **Priority:** High
- **Risk:** Standard RIME sync now exports per-device YAML/TXT backups and merges user-dictionary snapshots, but safe cross-device YAML import, full scheme portability and evidence across iOS, macOS, Windows, Linux and Android clients remain incomplete.
- **Current mitigation:** librime handles user-dictionary snapshots; Universe keeps encrypted private settings separate and does not auto-import YAML, copy live databases or copy full scheme directories.
- **Recommended fix:** Publish cross-platform fixtures and a compatibility matrix, add allowlisted staged custom-file import with diff/recovery, then verify representative RIME frontends and scheme installers.
- **Owner area:** Main App data operations, RIME Platform and cross-platform compatibility tooling.
- **Trigger to resolve:** Before claiming full RIME configuration or learned-dictionary parity across every target platform.

## Maintenance Rules

- Update an item when priority, mitigation, owner area or trigger changes.
- Remove an item only after implementation and verification are recorded in `CHANGELOG.md` and relevant architecture docs.
- New plans must link to the debt item they resolve; plans do not replace this register.
