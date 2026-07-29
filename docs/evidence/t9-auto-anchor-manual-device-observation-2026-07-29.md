# T9 Auto-Anchor Manual Device Observation

## Purpose And Evidence Boundary

This runbook replaces further physical coordinate-driver retries for the
current iteration. It answers two practical questions:

1. Does automatic shadow anchoring make long nine-key composition feel
   smoother on the declared iPhone?
2. Does it introduce a visible functional regression?

It is paired Human experience evidence. It is not a fixed-cadence performance
benchmark, does not satisfy the abandoned `5 × A/B` automated matrix, and does
not by itself grant Product Gate.

## Frozen Comparison

- device: the same iPhone 13 Pro;
- host: Reminders, exact disposable list
  `Universe Keyboard S6A 20260728`;
- layout: Universe Keyboard Chinese nine-key software keyboard, portrait;
- fixture: `jintiandetianqihenbucuowomenchuquwanba`;
- A: common instrumentation present, automatic anchor gate off;
- B: the same source/configuration/instrumentation, automatic anchor gate on;
- interaction: letter-group keys only; do not tap Path, candidates, Space,
  Delete or Return during an arm;
- start state: a newly created empty reminder title and empty composition;
- end state: wait two seconds after the final key tap without selecting a
  candidate.

Each A/B artifact must be independently identified before installation.
Install only by replacement. Never uninstall the app, delete its container,
reset userdb or delete Reminders state.

## Stop-Fast Procedure

Start with one valid pair. Expand to three pairs only when the first comparison
is unclear or needs confirmation.

1. Use the keyboard normally for one unrecorded warm-up of the fixture. Do not
   score it.
2. Install the declared first arm by replacement.
3. Start a screen recording. Use the same recording state for both arms.
4. Create a new empty title and type the exact fixture once at a comfortable,
   continuous real-world pace.
5. Wait two seconds, stop recording and complete the row below.
6. Install the paired arm by replacement and repeat in a new empty title.
7. Use order `A → B` for pair 1, `B → A` for pair 2 and `A → B` for pair 3.
8. Stop after pair 1 if the direction is obvious and no regression appears.
   Otherwise continue until three valid pairs exist.

An arm is invalid when the wrong layout/build is used, the starting title or
composition is non-empty, a non-letter-group control is touched, an
interruption occurs, a typo changes the intended key sequence, or the keyboard
disappears. Keep invalid rows with their reason; do not silently replace them.

## What To Observe

Score each valid arm immediately after typing:

- `Key response`: key highlight follows the finger without a visible delay;
- `Composition`: the composing text updates progressively rather than freezing
  and catching up in a burst;
- `Candidates`: the candidate row remains responsive and does not disappear;
- `Final settle`: approximate delay after the last tap until the UI stops
  changing;
- `Integrity`: no missing/duplicated input, unexpected commit, internal digit,
  Path takeover, native-session loss or keyboard termination;
- `Stall severity`:
  - `0` — none noticed;
  - `1` — slight, does not disturb typing;
  - `2` — clearly noticeable;
  - `3` — repeated pauses or catch-up bursts;
  - `4` — typing becomes impractical or input is lost.

Do not record private text. The disposable list and recordings must contain
only the repository-declared synthetic fixture.

## Observation Sheet

| Pair | Arm | Build/marker | Order | Valid? | Stall severity 0–4 | Final settle | Key/composition/candidate notes | Integrity regression | Recording |
|---:|---|---|---:|---|---:|---|---|---|---|
| 1 | A |  | 1 |  |  |  |  |  |  |
| 1 | B |  | 2 |  |  |  |  |  |  |
| 2 | B |  | 1 |  |  |  |  |  |  |
| 2 | A |  | 2 |  |  |  |  |  |  |
| 3 | A |  | 1 |  |  |  |  |  |  |
| 3 | B |  | 2 |  |  |  |  |  |  |

## Decision Rule

Call the direction promising when B has lower stall severity in the first
valid pair and the result repeats in a second valid pair, with no integrity
regression. Treat a one-point difference seen only once as inconclusive.

Any missing input, unexpected commit, internal digit, Path takeover,
candidate disappearance, session loss or keyboard termination in B is a stop
condition regardless of perceived smoothness.

The final report must state:

- how many valid pairs were completed;
- the per-arm rows above;
- whether the result is `promising`, `inconclusive` or `regressed`;
- that manual cadence and perception limit precision;
- whether an ordinary signed Release was restored by replacement afterward.
