# Post-Commit Continuation Product Contract

> **Version:** `1.3.0`
>
> **Status:** V1.3 closed on `2026-07-16`; implementation, independent review and physical-device acceptance are recorded
>
> **Product authority:** Human Product Owner authorization in the active Codex task, `2026-07-15 Asia/Shanghai`
>
> **Assignment:** [`POST-COMMIT-CONTINUATION-001`](assignments/post-commit-continuation-001.md)
>
> **Architecture decision:** [ADR 0017](architecture/decisions/0017-ephemeral-post-commit-continuation.md)

## Purpose

Post-Commit Continuation keeps the candidate bar useful after Chinese text is committed. It offers a small ranked list of common continuations, punctuation and selected emoji without treating those items as active RIME composition candidates.

## Product Behavior

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

## V1.1 Quality Foundation

- The bundled content pack expands from 30 to 100 manually curated, synthetic common contexts without using real user input.
- The resource format remains version 1 and declares content version `1.1.0`.
- A strict loader rejects duplicate contexts or suggestions, empty/control-line text, more than eight suggestions per context, more than 4,096 entries, text longer than 32 `Character` values or a resource larger than 512 KiB.
- A test-only representative benchmark covers ten conversation categories and checks that reviewed expected continuations remain within the top three.
- Unknown synthetic suffixes must remain empty; V1.1 does not add a generic single-character or remote fallback.
- Fixture results are regression evidence for registered scenarios only. They are not real-user coverage, acceptance-rate or population-quality evidence.

Quality definitions, provenance and expansion rules are owned by [`POST_COMMIT_CONTINUATION_QUALITY.md`](POST_COMMIT_CONTINUATION_QUALITY.md).

## V1.2 Quality Expansion

- The manually authored synthetic content pack expands from 100 to 250 unique contexts while keeping the same format and safety ceilings.
- The representative Top-3 fixture expands from 30 to 60 cases, with four cases in each of 15 declared everyday categories.
- New contexts prioritize specific multi-character endings for meals, schedules, greetings, acknowledgement, work, travel, care, logistics, questions, emotion, family, shopping, study, entertainment and weather.
- Ranking remains deterministic and resource-authored. V1.2 does not infer frequency, inspect host text, learn from selections or add a generic fallback.
- Simulator behavior with the installed `rime_ice` scheme is recorded separately from physical-device, performance and population-quality evidence.

## V1.3 Naturalness Refinement

- The bundled inventory stays fixed at 250 contexts. V1.3 replaces eight high-ambiguity single-character suffixes with eight specific multi-character contexts instead of increasing resource breadth.
- Each declared category gains one reviewed exact Top-1 naturalness guard in addition to the existing Top-3 regression baseline.
- Synthetic suppression fixtures protect the retired one-character suffixes from producing noisy fallback recommendations in unrelated text.
- Runtime lookup, ordering and privacy behavior are unchanged. V1.3 still uses longest exact suffix plus resource order and introduces no learned or inferred ranking.
- Simulator behavior evidence must follow the ordered environment preflight in the active V1.3 plan before any typing conclusion is recorded.
- The ordered preflight passed on the iOS 27.0 iPhone 17 Pro Max Simulator on `2026-07-16`: normal signing and App Group access were valid, `rime_ice` was installed/current/healthy, and Universe Keyboard was selectable in Messages. `吃了 -> 吗 -> ？` and `我在地铁 -> 上` worked through real key taps and candidate selection; the single-character `我` case produced no continuation. This remains Simulator evidence only.

## V1.3 Physical-Device Evidence

- The human owner accepted candidate behavior on a physical iPhone 13 Pro running iOS 27.0 beta 3 and provided the unlocked wired device for paired Release measurement.
- Disabled/enabled steady-state runs repeated the same `chile -> 吃了` flow three times in Activity Monitor and three times in Time Profiler. Enabled runs exposed the exact V1.3 resource sequence; disabled runs preserved normal RIME commit behavior and left the post-commit bar empty.
- Paired cold-process runs began after explicit Extension termination and both completed a real RIME commit after Universe Keyboard was selected again.
- CPU samples, physical footprint and 250-ms hang rows showed no unexplained regression attributable to the enabled feature in this bounded snapshot. The exact values, environment, local trace bundle names, integrity summaries, exclusions and non-claims are recorded in the [2026-07-16 physical-device acceptance record](evidence/post-commit-continuation-v1.3-physical-device-2026-07-16.md).
- The snapshot does not establish a permanent performance budget, leak/jetsam proof, broad compatibility or population language-quality claim. Independent Quality/Architecture review remains required before Assignment closure.

## Ranking Contract

- Matching uses the longest exact suffix present in the bundled resource.
- The resource order is authoritative for V1–V1.3 ranking.
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
