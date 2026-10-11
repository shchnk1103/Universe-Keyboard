# Authorization: QA-001 revalidation 006

## Current Status

- Status: `consumed — inconclusive; exact input observed, target absent`.
- Issuer: Human Product Owner / Product Lead, current task,
  `2026-09-20 Asia/Shanghai`; explicit request to repeat after possible
  unnoticed mistouch.
- Parent: [`four-lane Assignment`](../assignments/typo-correction-002-parent-revalidation-002.md), Active.
- Case: `TC2-CASE-QA-001` / `TC2-CTR-QA-001`.
- Run ID: `TC2-SIM-20260920-224421-QA001-REVAL-07`.
- Supersedes only the consumed, inconclusive
  [`revalidation 06 Run`](../evidence/typo-correction-002-sim-run-2026-09-20-qa001-reval-06-inconclusive.md);
  its raw evidence remains immutable.
- Executor / Domain Owner: Input Intelligence Maintainer.
- Environment Executor: Quality, Performance & Release Maintainer; Human
  Product Owner performs manual clearing and input.
- Handoff: independent Architecture and Quality review, then Product Lead.

## Exact reusable preconditions

- Worktree:
  `/private/tmp/universe-keyboard-typo-correction-002-parent-revalidation-003`
- Documentation HEAD: `0d6638fabdc6b3db8164b881464a9f96f16c8dce` plus bounded docs changes.
- Installed package source:
  `3f9f2652b03279a99537639f4382b48bb58548ca`.
- Simulator: iPhone 17 Pro Max / iOS 27.0 /
  `06C5BC3E-7599-4761-A1A2-71DAEA991474`.
- Host: Messages conversation `+1 (888) 555-1212`; never send.
- RIME and package identity remain bound by the
  [`deployment receipt`](../evidence/typo-correction-002-sim-run-2026-09-20-rime-ice-deployment-smoke-01.md).
- Existing high-fidelity window expires at `2026-09-20T15:09:21Z`.
- Existing keyboard process may be reused only if it stays readable and its
  identity remains stable. A new process is allowed only when recorded before
  formal input.

## Authorized reset and capture

1. Human clears the entire prior composition using Universe Keyboard and
   pauses. Executor verifies a zero-candidate/hidden-bar state and records the
   next journal sequence as the new Run boundary.
2. Human then enters exactly `wimenjintianquhongyuan` at normal speed and
   pauses without Space, candidate selection or Send.
3. Executor verifies the visible composition before deciding candidate
   visibility. If it differs again, stop and preserve this Run as
   inconclusive.
4. Human reports whether `我们今天去公园` is visibly present. Select only if
   it is present and the Executor specifically asks for selection.
5. If selected, run only safe interaction checks; never use Return when it
   could send the message.
6. Preserve content-free diagnostics, process/time boundary, screenshot and
   raw SHA-256.

No speed or 180 ms requirement applies. No `typeText`, pasteboard, host
injection, `documentContext`, `setMarkedText`, fake provider or synthetic RIME
fixture may substitute for keyboard input.

Stop on package/provenance change, unreadable diagnostics, expired
high-fidelity window, unclear keyboard identity or unintended input. A rebuild,
reinstall, schema change or another restarted formal capture requires another
Authorization and Run ID.

No INT-003, paired-performance, Product/Quality/Release Gate, publication,
merge or parent-close authority is granted.

## Consumption

### Reset checkpoint — 2026-09-20 22:46:16 Asia/Shanghai

- Human reports the prior composition cleared.
- Messages UI snapshot shows an empty message field.
- The same keyboard process remains active and readable.
- Journal sequence 301 reports zero candidates; sequence 302 reports zero
  visible candidates and candidate_bar_visible=false at revision 72.
- Sequence 303 is the terminal touch event for reset. Formal evidence for this
  Run starts at sequence 304.
- High-fidelity expiry remains 2026-09-20T15:09:21Z.

### Consumption receipt — 2026-09-20 22:48:13 Asia/Shanghai

- Evidence: [`QA-001 revalidation 07 Run Receipt`](../evidence/typo-correction-002-sim-run-2026-09-20-qa001-reval-07-inconclusive.md)
- Formal segment: journal sequences 304–516, same keyboard process.
- Messages UI and diagnostics consistently establish the exact 22-letter
  composition `wimenjintianquhongyuan`.
- Human observation: `我们今天去公园` was not visible.
- Candidate selection and interaction checks: not-run because the target was
  absent.
- Result: `inconclusive` for `TC2-CASE-QA-001`; no general product-failure or
  performance conclusion.
- This Authorization is consumed and cannot authorize another capture.
