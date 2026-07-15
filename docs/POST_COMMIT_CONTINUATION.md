# Post-Commit Continuation Product Contract

> **Version:** `1.0.0`
>
> **Status:** Accepted; automated implementation complete, physical-device acceptance pending
>
> **Product authority:** Human Product Owner authorization in the active Codex task, `2026-07-15 Asia/Shanghai`
>
> **Assignment:** [`POST-COMMIT-CONTINUATION-001`](assignments/post-commit-continuation-001.md)
>
> **Architecture decision:** [ADR 0017](architecture/decisions/0017-ephemeral-post-commit-continuation.md)

## Purpose

Post-Commit Continuation keeps the candidate bar useful after Chinese text is committed. It offers a small ranked list of common continuations, punctuation and selected emoji without treating those items as active RIME composition candidates.

## V1 Product Behavior

- The feature is enabled by default and can be disabled in the main App.
- It operates only in Chinese mode and uses text committed by the current Keyboard Extension process.
- A successful final commit refreshes continuation candidates. Selecting one commits it exactly once and immediately refreshes the next set.
- Active RIME composition and typo-correction candidates always take priority over continuation candidates.
- Starting composition hides continuation candidates without discarding the short context. Host deletion, English mode, keyboard visibility changes, process death, disabling the feature and newline commits clear it.
- Suggestions reuse the existing candidate bar geometry and presentation.

## Data And Privacy Contract

- V1 uses a bundled, read-only common-continuation resource.
- Recent committed context exists only in process memory, is limited to 32 Swift `Character` values and is never persisted, logged, synchronized or uploaded.
- V1 does not read `documentContextBeforeInput`, clipboard content, host identity, RIME user dictionaries or Typing Intelligence aggregates.
- The only persisted value is the user-facing enabled preference.
- Resource failure disables suggestions safely and must never affect typing.

## Ranking Contract

- Matching uses the longest exact suffix present in the bundled resource.
- The resource order is authoritative for V1 ranking.
- Results are deduplicated, empty values are discarded and at most eight suggestions are exposed.
- No match produces an empty result; V1 does not fabricate or query a remote fallback.

## Non-Goals

- No host surrounding-text reconstruction or continuation after process restart.
- No personal learning, n-gram persistence, language model, network service or analytics.
- No librime prediction plugin, RIME deployment or session-protocol change.
- No English next-word prediction.

## Acceptance Contract

- Representative chains such as `吃了 -> 吗 -> ？` work through the existing candidate bar.
- Every continuation selection commits exactly once and preserves existing marked-text, Partial Commit, RIME and Typing Intelligence semantics.
- Resource loading and lookup add no synchronous file work to the key path and show no unexplained startup, key-latency or memory regression.
- Visibility, deletion, mode and setting changes never expose stale continuation state across the documented boundaries.
- Automated Core/UI contracts and physical-device candidate-bar acceptance are recorded before release.

## Future Boundary

Reading host context, learning from user choices, persisting phrases or adding a local model requires a new Product Decision, privacy review and superseding or additional ADR.
