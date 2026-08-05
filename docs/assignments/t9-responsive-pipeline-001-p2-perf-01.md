# Assignment: T9-RESPONSIVE-PIPELINE-001 / P2-PERF-01

Policy version: 1.0.0  
Lifecycle status: **In Progress — canonical partial evidence, restore and independent reviews complete; exit conditions remain open**  
Date: 2026-08-01 Asia/Shanghai

## Authority

- Assignment Authority: Product Lead
- Decision Source / Date: Human Product Lead authorization in the current Codex task, 2026-08-01 Asia/Shanghai
- Product Approver: Human Product Owner / Product Lead
- Parent assignment: [`T9-RESPONSIVE-PIPELINE-001`](t9-responsive-rime-pipeline-001.md)
- Related residual: [`P2-Regression-Matrix-001`](t9-responsive-pipeline-001-p2-regression-matrix.md) `P2-PERF-01`
- Architecture boundary: [`ADR 0025`](../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md) remains Proposed

## Boundary

### Scope

1. Freeze one diagnostic run on the connected iPhone 13 Pro, including source
   identity, build configuration, device/OS, schema/readiness, Full Access,
   host field and synthetic fixture identity.
2. Build and install a diagnostic/internal variant by replacement only; do not
   uninstall the app, reset RIME, clear user dictionaries or delete host data.
3. Have the Human Product Lead manually type the declared T9 fixture in an
   otherwise-empty Reminders title field using the software keyboard and
   Universe Chinese nine-key.
4. Export only content-free App diagnostics and correlate `T9SEG`, `SLOW
   T9SEG`, `SLOW RIME`, session and integrity markers with the Human report.
5. Produce a bounded evidence record describing observed latency attribution,
   subjective feel and all unverified claims.

### Declared fixture

Logical pinyin fixture:

`jintiandetianqizhenbucuowomenchuquwanba`

The Human taps only visible nine-key letter-group keys. No numeric page,
Path-selection tap or candidate-selection tap is part of this run.

### Non-goals

- No production source, KeyboardCore state semantics, RIME bridge or Lua change.
- No responsive gate change, auto-anchor change, ADR 0025 acceptance or Product Gate.
- No automated coordinate typing, Computer Use typing, guessed tap coordinates or
  accessibility-based claims about the third-party keyboard UI.
- No release approval, TestFlight/App Store decision, jetsam conclusion or
  numeric performance SLO.
- No raw host text, candidate text, pinyin payload or user dictionary content in
  retained evidence.

## Assignment

- Domain Owner: Test / Release Maintainer for evidence validity; Keyboard UI and RIME owners consulted
- Executor: Current Codex task for freeze/build/log analysis
- Environment Executor: Current Codex task for local Xcode/device tooling
- Human Dependency: Human Product Lead for device trust, keyboard selection, manual fixture input, subjective score and diagnostics export
- Architecture Reviewer: Independent Architecture & Knowledge Steward
- Quality Reviewer: Independent Quality, Performance & Release Maintainer

## Entry criteria

- The connected device is the declared iPhone 13 Pro and is unlocked/trusted.
- Universe Keyboard is enabled; required Full Access and RIME readiness state are
  observed, not inferred from source settings.
- A diagnostic/internal build identity can be recorded before installation.
- The App Diagnostics view can export content-free records.
- Human confirms an empty Reminders title field and software-keyboard mode.

## Exit criteria

1. Run ID, commit/worktree fingerprint, build configuration, device/OS,
   installed bundle identity, schema/readiness, Full Access and host are recorded.
2. Human reports ordered input outcome, visible stall locations, candidate/Path
   flicker, missing/duplicate input, keyboard exit and a 0–4 subjective stall score.
3. Diagnostics export is preserved or attached by hash and contains only
   content-free timing/session/integrity markers.
4. `T9SEG`/`SLOW RIME` are summarized by stage (`rime`, `pathLocal`, `preedit`,
   `pathUI`, `candUI`, `total`) without inventing a product budget.
5. The device is restored to the ordinary gate-off build by replacement and the
   installed bundle identity is manually confirmed.
6. Evidence is handed to independent Architecture and Quality reviewers; this
   Assignment stops before any Product Gate or Release decision.

## Stop conditions

- Device, build, schema, access or host identity cannot be observed or changes mid-run.
- Installation requires deleting/resetting user data or changing production behavior.
- Logs contain raw user/host/candidate content and cannot be safely filtered.
- Human input cannot be performed manually, or the keyboard is not software-keyboard
  driven in the declared host field.
- A failure would require editing production logic; record the evidence and stop.
- The requested conclusion expands to release, jetsam, Product Gate, ADR Accept or
  default-on authorization.

## Handoff

- Handoff Target: Independent Quality reviewer, with Architecture review of any
  boundary or source-fingerprint concern
- Required Handoff Content: immutable run header, build/install provenance,
  content-free diagnostic artifact/hash, Human score, parsed stage metrics,
  limitations and a bounded recommendation
- Revalidation Trigger: source/build/gate/schema/device/OS/Full Access/host change,
  new diagnostic schema, or any request to compare a different arm

## Current evidence

- Partial, non-canonical manual export: [`P2-PERF-01 partial device evidence`](../evidence/t9-responsive-pipeline-p2-perf-01-partial-2026-08-01.md)
- Canonical Human report with partial export: [`P2-PERF-01 canonical partial device evidence`](../evidence/t9-responsive-pipeline-p2-perf-01-canonical-partial-2026-08-01.md)
- Independent Architecture review: [`P2-PERF-01 Architecture review`](t9-responsive-pipeline-001-p2-perf-01-architecture-review.md)
- Independent Quality review: [`P2-PERF-01 Quality review`](t9-responsive-pipeline-001-p2-perf-01-quality-review.md)
- The attachment contains two RIME-API-dominated stalls, but the Human did not
  enter the exact declared fixture in the first run. The second Human run
  reports the exact fixture and has a contiguous action 6–39 export, but the
  first five records are absent from the supplied attachment. The ordinary
  Release gate-off build was subsequently restored by replacement. Both
  independent reviews returned **Pass with conditions** for bounded diagnostic
  attribution only. The Assignment remains open for the missing prefix/provenance
  and Human-score fields; these artifacts do not authorize a product conclusion.
