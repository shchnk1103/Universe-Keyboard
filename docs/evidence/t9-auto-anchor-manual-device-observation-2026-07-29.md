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
| 1 | A | `7b324c9…b94d` / `T9DEVICE_DISABLED` | 1 | Yes | Not numerically scored; noticeable | Not reported | Stall began near `women`; candidates remained visible | None reported | Content-free performance log retained |
| 1 | B | `a0b7d0c…f1cb` / `T9DEVICE_ENABLED` | 2 | Yes | Not numerically scored; still noticeable | Not reported | Stall remained at similar fixture positions | None reported in performance records | Content-free performance log retained |
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

## Pair 1 A Observation

The Human operator manually typed the exact 38-action fixture once on the
physical iPhone 13 Pro. They reported no missing or duplicate input, candidate
disappearance or keyboard termination, but noticed a stall around `women`.

The App's Performance-filter export contains 38 contiguous `T9SEG` records
with local `event=1...38`. The retained source attachment is outside the
repository and has SHA256
`1c2385fd36e3ce6926eb76bff911dd00cc57b517763362d9464afcd88715851f`.
This record retains only the content-free aggregate needed for review:

| Scope | Samples | Total median | Total p95 | Total worst | `≥50 ms` |
|---|---:|---:|---:|---:|---:|
| All actions | 38 | 13.15 ms | 189.0 ms | 191.9 ms | 4 |
| Continuous actions excluding first-key warm-up | 37 | 13.1 ms | 189.0 ms | 191.9 ms | 3 |

The three continuous stalls were:

| Raw length | Fixture boundary | Total | RIME | Path local | UI |
|---:|---|---:|---:|---:|---:|
| 24 | first `w` of `women` | 189.0 ms | 187.4 ms | 0.2 ms | 1.3 ms |
| 32 | `...womenchuq` | 191.9 ms | 190.3 ms | 0.2 ms | 1.3 ms |
| 34 | `...womenchuquw` | 155.9 ms | 154.5 ms | 0.2 ms | 1.2 ms |

RIME accounts for `99.2%`, `99.2%` and `99.1%` of those stalls. Across the
37 continuous actions, RIME median was `5.9 ms`; UI median/p95/worst were
`5.7 / 8.4 / 9.1 ms`. Every record kept the same valid native session,
reported `committed=false`, 12 candidates and no functional integrity loss.
This isolates the observed A stalls to discrete librime `process_key` work;
the log alone does not identify Lua as the cause.

The inherited preflight sample ordinal continued at `action=39...76`, while
the new controller's event identity correctly covered `event=1...38`.
Manual comparison therefore keys this arm by the contiguous local event range,
session identity and raw length rather than treating the stale ordinal as a
new automated arm. It remains manual diagnostic evidence, not a valid S6-A
coordinate arm.

## Pair 1 B Artifact

The B candidate was built from clean HEAD
`8f70eccb6a0950becd0b633221da801be06b3c12`. Relative to the reviewed A
artifact source checkpoint `7c8a79896fe8646e9a8df06bb014acfc011b9f9e`,
only this manual runbook, the paused S6-A Assignment and the run5 evidence
changed; product, test, project and scheme sources are unchanged.

The signed Release/generic-iOS build uses the same common
`T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` condition and adds only
`T9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED`. Its held-local identity is:

- DerivedData:
  `/private/tmp/universe-keyboard-s6a-manual-device-b-8f70ecc`;
- final successful quiet-log SHA256:
  `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`;
- App executable SHA256:
  `694ef2d53149a56884381fb377f78b64f375f7e675a39dc23989f4fd82c5d698`;
- embedded/standalone Extension executable SHA256:
  `a0b7d0cbcbd7939310ddd5067a4572b3dbfd83c72774c5ebf8a9fbc8be47f1cb`;
- App/Extension UUID:
  `7A1F20C3-2B83-39B8-8EFE-8218D56931B4` /
  `E253CB5A-F95A-3480-B18B-C2B1005D3E22`;
- Team ID: `C33N6HTS9N`; App and Extension are arm64;
- Extension inventory: `T9DEVICE_ENABLED` plus the two common preflight
  store keys, with no `T9DEVICE_DISABLED`.

Architecture and Quality independently returned `Pass`, P0–P3 none. Host
strict verification retains the known `CSSMERR_TP_NOT_TRUSTED` beta-host
warning and is not claimed as strict success. No XCTest or coordinate driver
will run. Replacement installation and one Human B observation require a
fresh device precheck and Human readiness; ordinary same-source signed Release
restoration remains mandatory afterward.

## Pair 1 B Observation And Comparison

After the reviewed B was installed by replacement, the Human operator manually
typed the same 38-action fixture once and reported that perceptible stalls
remained at approximately the same positions. The Performance-filter export
has SHA256
`6c23d48ba5c948c677873ba4ee5c907d581ec1dca04c8a87a3f286c28b6b7aed`
and contains 38 contiguous `event=1...38` `T9SEG` records.

B emitted exactly one automatic outcome before the 18th key completed:

```text
status=accepted baseline=5 result=5 overlap=5 anchorSlots=7 unresolvedSlots=11
```

The accepted transaction changed the live raw length from 17 before event 18
to 20 afterward. Subsequent comparison therefore uses local event identity,
not equal raw lengths; the added segmentation increased B's reported raw
length by two without changing the 38 physical action identities.

| Continuous scope | A | B | Direction |
|---|---:|---:|---:|
| total median | 13.1 ms | 10.4 ms | `-20.6%` |
| total p95 | 189.0 ms | 147.4 ms | lower, still visible |
| total worst | 191.9 ms | 156.6 ms | lower, still visible |
| total `≥50 ms` | 3 / 37 | 3 / 37 | unchanged count |
| RIME median | 5.9 ms | 5.7 ms | `-3.4%` |
| 37-action total | 953.0 ms | 785.2 ms | `-17.6%` |
| 37-action RIME total | 746.4 ms | 631.3 ms | `-15.4%` |

The matched continuous spike positions were:

| Event / fixture boundary | A total / RIME | B total / RIME | Total change |
|---|---:|---:|---:|
| 24 / first `w` of `women` | 189.0 / 187.4 ms | 147.4 / 146.0 ms | `-22.0%` |
| 32 / `...womenchuq` | 191.9 / 190.3 ms | 156.6 / 155.1 ms | `-18.4%` |
| 34 / `...womenchuquw` | 155.9 / 154.5 ms | 137.1 / 135.9 ms | `-12.1%` |

The auto-anchor direction produced a measurable one-sample reduction, but
every matched stall remained above `100 ms` and approximately `99%`
RIME-dominated. The Human still perceived the same failure class. Pair 1 is
therefore classified `inconclusive / insufficient for the product goal`, not
`promising`, `regressed` or accepted. It supports the diagnosis that one
accepted, seven-slot anchor with eleven unresolved slots is too weak to
eliminate long-composition search spikes. It does not yet authorize repeated
automatic replacement or a broader anchor policy.

Both arms kept one stable valid native session, 12 candidates and zero
commits across all 38 records. This comparison remains sensitive to manual
cadence and contains only one pair; the numerical deltas are diagnostic
direction, not a performance budget or Product Gate.
