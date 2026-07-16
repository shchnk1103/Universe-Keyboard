# Post-Commit Continuation Quality Contract

> **Version:** `1.3.0`
>
> **Status:** Active synthetic regression baseline
>
> **Product source:** [`POST_COMMIT_CONTINUATION.md`](POST_COMMIT_CONTINUATION.md)
>
> **Assignment:** [`POST-COMMIT-CONTINUATION-001`](assignments/post-commit-continuation-001.md)

## Purpose

This document defines what the V1.3 continuation benchmark can and cannot prove. Its immediate purpose is to prevent reviewed common scenarios, first-candidate naturalness and ambiguous-suffix suppression from regressing.

## Evidence Classes

### Synthetic Fixture Evidence

The current cases are manually written, non-user examples. Each case declares a category, synthetic committed context and a small set of acceptable top-three suggestions. Passing proves only that the current provider produces one declared acceptable suggestion in the first three positions for that case.

Synthetic fixtures do not prove:

- real-user or population coverage;
- suggestion acceptance rate;
- naturalness outside the registered examples;
- latency, memory or physical-device usability;
- corpus frequency or demographic/language representativeness.

### Runtime And Device Evidence

Startup, commit-path cost, candidate refresh, memory, visual behavior and actual selection usefulness require separate physical-device evidence. No runtime text, surrounding host context or selection telemetry may be collected to satisfy this contract.

## V1.3 Registered Baseline

- Bundled content: 250 manually authored synthetic contexts in a 22,728-byte JSON resource at the initial V1.3 snapshot.
- Representative fixture: 60 cases, exactly four in each of meal, schedule, greeting, acknowledgement, work, travel, care, logistics, question, emotion, family, shopping, study, entertainment and weather.
- Naturalness fixture: 15 reviewed exact Top-1 cases, one in each declared category.
- Suppression fixture: eight synthetic unrelated contexts ending in retired high-ambiguity single-character suffixes must produce no continuation.
- Positive gate: every registered case produces at least one suggestion and at least one reviewed expectation within the top three.
- Negative gate: registered unknown synthetic suffixes produce no fabricated fallback.
- Resource gate: strict validation rejects invalid format version/content version, oversize files, excessive entries, excessive suggestion counts, duplicate/empty/line-breaking content and text beyond the runtime context bound.

These inventory values describe the initial V1.3 baseline, not a permanent performance budget or a claim that the fixtures prove general language quality.

## Content Review Rules

Every proposed entry must be reviewed for:

- ordinary conversational usefulness and grammatical continuity;
- ranking diversity instead of near-duplicate candidates;
- absence of personal names, phone numbers, addresses, credentials and reconstructable private text;
- absence of advertising, tracking URLs, discriminatory language, harassment and unsafe instructions;
- bounded context/suggestion length and deterministic ordering;
- a synthetic positive or negative regression case when the behavior is important enough to protect.

## Expansion Workflow

1. Record the content source and license or mark the entry as manually authored synthetic content.
2. Review privacy, safety, naturalness and ranking diversity before editing the shipping resource.
3. Run strict resource validation and the complete synthetic benchmark.
4. Compare resource size, provider initialization and commit/candidate behavior with the previous accepted build.
5. Review representative suggestions on a physical device before release.
6. Update this baseline when the accepted inventory or evidence class changes.

Any use of a downloaded corpus, host context, personal learning, telemetry or a language model requires separate product/data review before implementation.
