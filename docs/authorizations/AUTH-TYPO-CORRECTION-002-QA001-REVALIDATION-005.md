# Authorization: QA-001 revalidation 005

## Current Status

- Status: `consumed — inconclusive; actual composition contained one extra n`.
- Issuer: Human Product Owner / Product Lead, current task, 2026-09-20, explicit authorization to proceed and pause for manual actions.
- Parent: [four-lane Assignment](../assignments/typo-correction-002-parent-revalidation-002.md), Active.
- Case: TC2-CASE-QA-001 / TC2-CTR-QA-001.
- Run ID: TC2-SIM-20260920-223706-QA001-REVAL-06.
- Executor / Domain Owner: Input Intelligence Maintainer.
- Environment Executor: Quality, Performance & Release Maintainer; Human Product Owner operates manual setup/input.
- Reviewers: independent Architecture & Knowledge Steward and Quality, Performance & Release Maintainer under the parent Assignment.
- Handoff: independent reviews, then Product Lead. No reviewer conclusion is created by this AUTH.

## Exact binding

- Worktree: /private/tmp/universe-keyboard-typo-correction-002-parent-revalidation-003.
- Documentation HEAD: 0d6638fabdc6b3db8164b881464a9f96f16c8dce plus bounded docs changes.
- Installed package source snapshot: 3f9f2652b03279a99537639f4382b48bb58548ca.
- Simulator: iPhone 17 Pro Max / iOS 27.0, 06C5BC3E-7599-4761-A1A2-71DAEA991474.
- Host: Messages, synthetic conversation +1 (888) 555-1212; never send.
- App: com.DoubleShy0N.Universe-Keyboard; extension: com.DoubleShy0N.Universe-Keyboard.Keyboard.
- Package and schema authority: [deployment receipt](../evidence/typo-correction-002-sim-run-2026-09-20-rime-ice-deployment-smoke-01.md).
- Accepted limitations: [Product residual decision](../product-decisions/TYPO-CORRECTION-002-RIME-ICE-DEPLOYMENT-PRODUCT-RESIDUAL.md).
- This is a new authorization, not reuse of superseded QA AUTH 004 or stopped signed-rebuild AUTH.

## Allowed procedure and stops

1. Read-only verify live installed package hashes and runtime provenance.
2. Enable the existing first-screen high-fidelity diagnostic window through the app UI; manually establish Full Access, Universe Keyboard and Messages with empty composition.
3. Before the phrase, confirm a readable fresh extension diagnostic stream and unexpired high-fidelity window. A setup probe key, if necessary, must be explicitly labelled and cleared before the phrase.
4. Human enters exactly wimenjintianquhongyuan using Universe Keyboard and pauses. No speed/180 ms requirement. Preserve deviations as observed; do not silently normalize them.
5. Observe target 我们今天去公园. Select only if visibly present and when specifically instructed. If absent, retain an inconclusive QA result and do not substitute another candidate.
6. If selection succeeds, record applicable interaction checks under the existing QA contract; avoid Return if it would send a message. Mark any unrun check.
7. Bind content-free diagnostics, process/time window, screenshots of the synthetic case when needed, and raw SHA-256 to this Run.

Stop on package/provenance mismatch, unclear active keyboard, missing fresh diagnostics, expired diagnostic window or unintended input.
A rebuild, reinstall, schema change or restarted capture requires a new Run ID.
No typeText, pasteboard, host injection, synthetic fixture, code edit, INT-003 or performance result, publication, merge, Gate or parent closure.

## Preflight checkpoint — 2026-09-20 22:37–22:39 Asia/Shanghai

Evidence grade: Executor-recorded. No formal QA input yet.

- Designated simulator is Booted; UI shows 雾凇拼音 / 当前使用 / 已部署 / 配置已生效.
- Host-side simctl get_app_container located the live installation in Bundle/Application/46E5EAF5-167A-4F71-A8A5-806400590630. Sandbox lookup failed; host lookup succeeded.
- Live App executable SHA-256: 9f1c360daccd157144830fdcc92b9f4a02dd32ed9aa84e9c7ecab503b8d3af04.
- Live App debug dylib SHA-256: 0b7983d92d44671111554795c1f4cbb840deb5e9e6d4b6db6bbfb9e17dcc6778.
- Live Keyboard executable SHA-256: 2bfd0a0a00da2d0e014054ce32bd70fd6ea61f7d4388825dcbe6e368dd46a353.
- Live Keyboard debug dylib SHA-256: 92f148f18d6bf0c2268af44326199afd397fc733d8a9a3bba396ad03d3f2a028.
- All four match the accepted deployment receipt.
- Live provenance JSON SHA-256: 771adec0e83414bf1e204c5b253c1b23d1cbe5fce5c93a8f223c7e5811e4d9a1, unchanged from deployment receipt.
- Shared preference diagnostics_high_fidelity_expiration: key absent on read. No active diagnostic window established.
- Scoped filename discovery found no jsonl/diagnostic/journal path in this shared container; fresh extension diagnostics remain unproven until activation.
- Human setup required next: enable first-screen high-fidelity diagnostics, confirm Full Access, then open Messages and select Universe Keyboard with empty composition. Do not enter the test phrase yet.

## Consumption

### Preflight update — 2026-09-20 22:40 Asia/Shanghai

- Human confirms diagnostics enabled, Messages and Universe Keyboard ready.
- Shared diagnostic expiration is 2026-09-20T15:09:21Z (23:09:21 +08), still in the future.
- Fresh journal: Diagnostics/v1/g1/open/keyboard_extension-5CC03041-4BAA-46A1-912C-77357E4FD052-20260920T14-0.jsonl.
- Sequence 1–6 at 14:39:44–45Z shows presentation.appeared and high_fidelity_enabled=true; startup query_route=unavailable is retained.
- UI snapshot identifies the designated Messages conversation and empty message field. Its next-keyboard label alone is not used to reject Human keyboard confirmation.
- Before the phrase, request one manual q followed by the same keyboard's Delete as an explicit setup probe. Verify fresh key/engine events before proceeding. This probe is excluded from formal phrase evidence.

### Probe verified — 2026-09-20 22:41:09 Asia/Shanghai

Human reports q/Delete probe completed. The same extension process journal
records sequences 7–16 at 14:40:54–56Z: touch events, rime.owner.published,
ui.applied and candidate visibility activity. Candidate count returns to zero
at revision 3 and the candidate bar becomes hidden. This corroborates the
Human probe and confirms fresh input-path observability, not phrase recovery.
Sequences 1–16 are setup-only and excluded from formal phrase evidence.
The high-fidelity window remains valid until 15:09:21Z. Proceed with one
manual phrase input in the same session; preserve any input deviations.

### Consumption receipt — 2026-09-20 22:44 Asia/Shanghai

- Evidence: [`QA-001 revalidation 06 Run Receipt`](../evidence/typo-correction-002-sim-run-2026-09-20-qa001-reval-06-inconclusive.md)
- Formal segment: journal sequences 17–238, same extension process.
- Actual visible composition: `winmenjintianquhongyuan`; requested:
  `wimenjintianquhongyuan`.
- Human initially noticed no mistouch or deletion, then accepted that an
  unnoticed accidental tap may have occurred and requested a repeat.
- Result: `inconclusive`. Target visibility is not decided for the registered
  case, candidate selection and interaction checks are not-run.
- This Authorization is consumed and cannot authorize the repeat.
