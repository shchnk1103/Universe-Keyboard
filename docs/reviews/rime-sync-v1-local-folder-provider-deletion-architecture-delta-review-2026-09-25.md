# RIME-SYNC-001 — local-folder provider deletion architecture delta review — 2026-09-25

## Verdict

**Accept with conditions — architecture boundary only, for the recorded iOS Simulator Files local-storage provider path.** The later read-only snapshot strengthens the observed provider-state evidence: the private package root was absent while the RIME standard-data directory remained present. Its delayed capture and the unresolved possibility of intervening modification prevent attributing that state conclusively to the production delete operation. The XCTest remains failed (`1 failed / 0 passed`) at its post-delete Files UI query and is not a passing end-to-end result.

This is an independent Architecture review of the exact candidate below. It does not inherit earlier review verdicts. It makes no Product lifecycle decision.

## Exact identity and candidate hash

- Repository: `/Users/doubleshy0n/.codex/worktrees/rime-sync-docs-close-20260923/Universe Keyboard`
- HEAD: `4a51228fc8e435d538e9a5f7342ae325502e1e66`
- Candidate: tracked changes relative to HEAD, union untracked non-ignored files, excluding only:
  - `docs/reviews/rime-sync-v1-local-folder-provider-deletion-quality-delta-review-2026-09-25.md`
  - `docs/reviews/rime-sync-v1-local-folder-provider-deletion-architecture-delta-review-2026-09-25.md`
- Candidate path count: `61`
- Candidate SHA-256: `d76298f2fb7e4e5b61847f074b17a40fd6124daf17f207a361c52ef057e05dc7`

## Independent hash reproduction

I independently enumerated `git diff HEAD --name-only -z` and `git ls-files --others --exclude-standard -z`, formed their path union, removed the two exclusions above, and byte-sorted the remaining paths (equivalent to UTF-8 byte ordering under `LC_ALL=C`). For each path I captured the complete `shasum -a 256 <path>` output line, including its terminating LF, concatenated those lines in sorted order, then SHA-256 hashed the resulting bytes. The independently obtained count and digest match the supplied identity exactly. No mismatch stop condition was triggered.

## Reviewer identity

- Reviewer: independent Architecture reviewer assigned to this receipt.
- Model/runtime identity: `UNKNOWN` (not independently attestable).

## Reviewed sources

- Repository entry and authority: `AGENTS.md`, `docs/KNOWLEDGE_INDEX.md`, `docs/READING_MAPS.md`, `docs/ASSIGNMENT_POLICY.md`, `docs/kos/kos-2.1-operational-maturity.md`, and `docs/assignments/rime-sync-001.md`.
- Role playbooks: `docs/playbooks/main-app-ui.md` and `docs/playbooks/rime-bridge.md`.
- Architecture and contract: `docs/PROJECT_CONTEXT.md`, `docs/RIME_SYNC.md`, ADR 0012, ADR 0013, ADR 0003, and `docs/architecture/shared-container-and-rime-lifecycle.md`.
- Current evidence: `docs/evidence/rime-sync-v1-local-folder-provider-state-reinspection-2026-09-25.md` and `docs/evidence/rime-sync-v1-local-folder-provider-deletion-attempt-2026-09-25.md`.
- Implementation: `Universe Keyboard/Services/RimeSyncTransport.swift`, `Universe Keyboard/Models/RimeSyncViewModel.swift`, and `Universe Keyboard/Views/Settings/RimeSyncSettingsView.swift`.
- Debt boundary: `docs/TECH_DEBT.md`, including TD-002, TD-008, TD-013, TD-017, and TD-019.

## Boundary analysis

The deletion confirmation describes deletion of the `universe-rime-sync` encrypted settings package and removal of the local encryption key, while preserving the RIME standard-sync directory and other-device data. In `RimeSyncViewModel.disconnect(deleteRemoteData:)`, the transport deletion completes before local provider/bookmark and sync preferences are cleared; when deleting, the encryption key is removed. The local-folder transport resolves exactly `<selected folder>/universe-rime-sync` and removes that package root under coordinated folder write access. It does not target the provider root or the sibling `universe-ios-*` standard-data directory.

The RIME standard layer is configured through the selected directory as librime `sync_dir`; its files are distinct from the Universe private package. The production delete path does not call `sync_user_data`, remove the standard-data directory, or mutate `Rime/user`. This remains consistent with ADR 0013's separation between the plaintext RIME interoperability layer and the encrypted Universe-private layer, and with ADR 0003's main-App ownership boundary. No evidence in this slice changes the architecture boundary conclusion.

The later snapshot, captured at `2026-09-25 02:21:25 +08:00`, directly records `universe-rime-sync` absent and the standard-data directory present. Its root and standard-directory mtimes (`01:54:31` and `01:54:22 +08:00`) are near the original attempt window. That temporal consistency is corroborative only: the snapshot followed the operation, did not inspect standard-directory children or contents, and cannot exclude an intervening actor or establish causality. The original attempt separately records a post-operation host inspection listing standard-data files; neither record establishes a Files UI refresh assertion.

TD-002 remains open. It concerns possible overlap between Main-App operations and librime/Keyboard Extension writes to `Rime/user`; the deletion path reviewed here removes the separate private package and gives no new cross-process exclusion evidence. The evidence also does not repay or otherwise change TD-008, TD-013, TD-017, or TD-019.

## Findings and conditions

1. **Provider-state evidence is corroborative, with a remaining timing/provenance limit.** The new snapshot adds a narrowly scoped observation of the same unique Simulator folder and is consistent with private-package deletion plus standard-directory retention. Because it was not captured contemporaneously and does not prove no intermediate modification, it cannot alone establish causal attribution. **Disposition:** `fix` — if Quality or Product requires stronger attribution, capture provider state in the same isolated operation window, without rewriting the failed XCTest outcome.
2. **The test outcome remains failed.** Production UI flow reaching “尚未配置” and the provider filesystem observation do not make the failed post-delete Files UI assertion pass. Keep the UI failure visible in any lifecycle/readiness summary.
3. **Scope remains one Simulator local-storage provider.** This review supports no generalized deletion claim for physical devices, iCloud Drive, third-party File Providers, WebDAV, CloudKit, or other provider implementations.
4. **No concurrency-debt disposition follows.** TD-002 remains open and must not be represented as mitigated or closed by this private-package deletion observation.

## Non-claims

- No test, build, Simulator, or device operation was performed for this review.
- No passing end-to-end deletion test, Files UI refresh, cross-device propagation, cloud/provider durability, physical-device behavior, interruption recovery, or live WebDAV behavior is established.
- The standard-data directory's presence in the later snapshot does not establish its contents or prove that every standard RIME file remained unchanged.
- No claim is made that TD-002 or any other linked technical debt is resolved.
- This receipt does not authorize or decide `Active → Completed → Reviewed → Closed`, merge, TestFlight, or Release.

## Conditions and handoff

Retain the exact failed-test status and the delayed-snapshot limitation in the evidence record. The Architecture conclusion is limited to the code boundary and the corroborated, single-provider state observation above. Quality independently determines evidence adequacy for its assigned gate; Product Lead alone decides lifecycle disposition after required reviews and residual handling.
