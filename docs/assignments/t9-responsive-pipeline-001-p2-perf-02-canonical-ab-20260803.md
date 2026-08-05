# Assignment: T9-RESPONSIVE-PIPELINE-001 / P2-PERF-02 Canonical-bound A/B

Policy version: 1.0.0
Lifecycle status: **Reviewed — bounded Product-authorized diagnostic A/B; no production change**
Date: 2026-08-03 Asia/Shanghai

## Authority and boundary

- Assignment Authority: Human Product Owner / Product Lead
- Decision Source: current task authorization to run a new canonical-fixture-bound A/B
  comparison on the connected iPhone 13 Pro
- Parent contract: [`P2-PERF-02 Evidence Contract`](t9-responsive-pipeline-001-p2-perf-02-evidence-contract.md)
- Architecture boundary: [`ADR 0025`](../../architecture/decisions/0025-responsive-rime-serial-input-pipeline.md)
  remains **Proposed**; this Assignment does not accept it, change Product Gate, or enable
  any Release default
- Production scope: **none**. The two arms are separately compiled diagnostic packages;
  no source, Lua, schema, bridge, pipeline, UI, setting, or test logic is modified by this run.

## Objective

Compare, under the same source snapshot, device, host, software-keyboard setup and 39-action
Human fixture, the observed responsiveness and content-free runtime markers of:

| Arm | Compile conditions | Expected path | Meaning |
|---|---|---|---|
| A | `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` | `sync`, `dualGateRequested=0`, `dualGateActive=0` | gate-off baseline with equal diagnostic instrumentation |
| B | `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT` + `T9_RESPONSIVE_DEVICE_PREFLIGHT_ENABLED` | `thread-affine`, `dualGateRequested=1`, `dualGateActive=1`, `READY` | explicit internal thread-affine spike arm only |

Both arms must **not** include `T9_AUTO_ANCHOR_DEVICE_PREFLIGHT_ENABLED`,
`T9_AUTO_ANCHOR_ROLLING_PREFLIGHT_ENABLED`, `T9_AUTO_ANCHOR_TRIPLE_ROLLING_PREFLIGHT_ENABLED`,
or `T9_AUTO_ANCHOR_EARLIER_FIRST_PREFLIGHT_ENABLED`. No auto-anchor product behavior is being
compared here; the A/B variable is the responsive RIME ownership path.

## Frozen Pair and canonical fixture

| Field | Frozen value |
|---|---|
| Pair ID | `P2P02-CANONICAL-AB-20260803-001` |
| Human fixture ID | `T9-RESP-PERF-39-V1` |
| Human fixture digest | `772b4bb30cb831d04550e8311a2f64e66aad4ab55c4597544f0cc9364f9d7286` |
| Action count | `39` |
| Runtime marker fixture | `T9RESP-R5P` |
| Marker-to-human mapping | Declared by this protocol; must be checked from both exports. If the mapping cannot be proven, the Pair remains `Partial` and no latency comparison is promoted to a pass claim. |
| Human input | Manual taps on visible Chinese nine-key letter groups; software keyboard; no numeric-key, Path, candidate, space, commit, Delete, or coordinate automation |
| Host | One opaque disposable empty Reminders list, kept equivalent for A and B; no list title or document text in evidence |
| Full Access | `unavailable` until observed; do not infer from a prior run |

The fixture's raw sequence is not copied into runtime logs, exported evidence, summaries,
screenshots, UI hierarchy, or this Assignment. The canonical ID and digest are the comparison
identity.

### Run tokens

| Arm | Run ID | Canonical device-preflight token |
|---|---|---|
| A | `P2P02-CANONICAL-A-20260803-001` | `S6A-3E1F0F062F414CBFA571CEEA8E92F281` |
| B | `P2P02-CANONICAL-B-20260803-001` | `S6A-0644586F078C44AAA8DAA4E45F882E43` |

Each token is fresh, canonical (`S6A-` plus 32 uppercase hexadecimal characters), and must
appear only in its own arm. Do not reuse a token or clear the retained diagnostic log to force
reuse.

## Pre-run source/toolchain/device fingerprint

Captured before adding this Assignment and before either diagnostic build:

| Field | Observed value |
|---|---|
| Source HEAD | `3585a540ba8389673acd49128d87040ac9619f27` |
| Worktree dirty entry count | `91` |
| Tracked diff SHA-256 | `5f67fc561b8e2494c895a6176909fc2602dad4492f275eed839a36eda40c45be` |
| Untracked-name SHA-256 | `e69a4b2b1f03c302816e78e7fbf53f74d492e3efe264bdc93aa2d7de47ac0afe` |
| Xcode | `27.0 (27A5228h)` |
| iPhoneOS SDK | `27.0` |
| Swift toolchain | `Apple Swift 6.4 (swift-driver 1.168.5)` |
| Device | iPhone 13 Pro / `iPhone14,2` / physical |
| Device UDID | `00008110-000A08440198801E` |
| CoreDevice ID | `DE65EBE1-463E-5EB4-9694-F6DCBFC04028` |
| OS | iOS `27.0 (24A5390f)` |
| Connection | wired, paired, connected, booted, Developer Mode enabled |

The untracked-name fingerprint is a pre-run provenance value, not a claim that later evidence
files were present during the build. The build source remains the same application source
snapshot for A and B; newly written records are documentation only.

## Human protocol

1. Codex installs and launches one arm with its token prepared in the main App.
2. Human opens the same empty Reminders list, selects the software keyboard and
   Universe Keyboard 中文九宫格, then manually enters the frozen 39-action fixture once.
3. Human does not select Path/candidates or use numeric keys. Do not paste the sequence.
4. Human reports only: `missingKeys`, `duplicateKeys`, `candidateDisappeared`,
   `keyboardExited`, `stallScore` (0 = completely smooth, 4 = severe stalls), and a short
   content-free note. Do not report or paste the resulting text.
5. Human exports/copies the App's content-free diagnostic evidence for that token. Do not clear
   the log between A and B; token isolation is the separation mechanism. If the export contains
   host text or raw input, stop and do not send it.
6. Codex records A, then installs B and repeats exactly the same protocol. The host list should
   remain equivalent; if Reminders was closed by installation, Human is told explicitly to
   reopen it before the next arm.

## Stop and exit rules

- Stop immediately on lost/duplicated input, candidate disappearance, keyboard exit, privacy
  leakage, wrong device, or inability to prove the arm/path token.
- No coordinate automation, Computer Use typing, numeric-key taps, Path/candidate selection,
  uninstall, App Group wipe, userdb reset, Reminders deletion, or device erase.
- A/B is only directionally comparable when source/device/OS/host/fixture and both arm evidence
  are complete. Missing canonical mapping, Full Access, runtime path, geometry, session, or
  restore identity keeps the result `Partial`.
- After B evidence, restore a fresh ordinary Release package built from the same source snapshot,
  record app/appex hashes, and perform only a one-key keyboard-switch smoke check. This is not a
  release or Product Gate decision.

## Evidence handoff (to complete)

Expected records:

```text
docs/assignments/t9-responsive-pipeline-001-p2-perf-02-canonical-ab-20260803.md
docs/evidence/t9-responsive-pipeline-p2-perf-02-canonical-ab-2026-08-03.md
docs/evidence/t9-responsive-pipeline-p2-perf-02-canonical-ab-summary-2026-08-03.json
```

The raw device export remains outside the repository. Only privacy-scanned, content-free,
hash-bound summaries may be retained under `docs/evidence/`. Independent Architecture and
Quality review will occur after both arms and ordinary-package restore; neither review may
declare ADR 0025 accepted or authorize a default-on path.

## Execution result

| Item | Result |
|---|---|
| A human integrity | Missing/duplicate/candidate disappearance/keyboard exit: all `no`; stall score `2/4` |
| B human integrity | Missing/duplicate/candidate disappearance/keyboard exit: all `no`; stall score `0.5/4` |
| A runtime | `sync`; T9SEG total max `181.8ms`; RIME max `180.4ms` |
| B runtime | `thread-affine`; T9SEG total max `0.7ms`; ACCEPT/PUBLISH `39/39`; engine VISIBLE lag max `160.0ms` |
| Privacy | A/B marker subsets passed content-free allow-list; raw exports remain outside repository |
| Ordinary restore | Fresh ordinary Release installed at database sequence `3768`; one-key smoke passed |
| Production changes | None; no default gate, ADR 0025 acceptance, Product Gate, or Release claim authorized |

The result is a bounded directional device observation. It is handed to independent
Architecture and Quality review; it is not a pass/fail Product Gate decision.

## Independent review disposition

| Review | Result |
|---|---|
| Architecture | [`canonical-ab-architecture-review`](t9-responsive-pipeline-001-p2-perf-02-canonical-ab-architecture-review.md) — `Pass with conditions`; restore addendum closes the bounded restore finding; residual P2/P3 evidence limits remain |
| Quality / Performance | [`canonical-ab-quality-review`](t9-responsive-pipeline-001-p2-perf-02-canonical-ab-quality-review.md) — `Partial / bounded pass`; P0/P1 `0/0`, residual P2/P3 `3/3`; restore addendum records lifecycle bounded pass |
| Governance | ADR 0025 remains `Proposed`; default gate remains off; Product Gate/Release approval not authorized |

This Assignment is complete as a bounded evidence handoff, not as a Product Gate or shipping
approval. Any production接线、重复样本、完整 manifest、PAINT coalescing contract or release
validation requires a new Product Lead authorization and a new Pair/Run identity.
