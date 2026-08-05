# P2-PERF-01 真机诊断 — 规范人工输入（部分导出，2026-08-01）

**Status:** `Canonical human report; partial content-free export; diagnosis usable`

本记录承接 [`P2-PERF-01 partial`](t9-responsive-pipeline-p2-perf-01-partial-2026-08-01.md)。本轮 Human
确认按声明的长九宫格序列输入，未出现漏键、重复、候选消失、键盘退出
或数字泄漏；主观上仍偶尔感到按键卡顿。附件只保留内容脱敏诊断字段。

## Run header

| Field | Value |
|---|---|
| Assignment | `T9-RESPONSIVE-PIPELINE-001 / P2-PERF-01` |
| Device | iPhone 13 Pro (`iPhone14,2`) |
| OS | iOS 27.0 (`24A5390f`) |
| Host | Reminders empty-title workflow; software keyboard; Universe Chinese nine-key |
| Build | Debug, Swift 6, `-Onone`, bundle `com.DoubleShy0N.Universe-Keyboard`, `1.0 (1)` |
| App executable SHA-256 | `8739c47f1fc512ac048ccd147032d24d7c2695206e9547aeca39f410606fc4ca` |
| Extension executable SHA-256 | `302fb213f8bd9da6abdf342e54fb46487217b435657d71ef4a845d3da21bcca7` |
| Source HEAD | `3585a540ba8389673acd49128d87040ac9619f27` |
| Captured attachment SHA-256 | `5fce05c30bca5b1b8ce53a5efb257c977fa86ec6dcd6869a9aa5075add05d88a` |
| Log window | `22:38:48.628`–`22:38:54.618` (local time) |

## Completeness and integrity

The Human reports the declared 39-tap fixture was completed. The retained
export contains a contiguous `T9SEG` range `action=6...39` / `event=6...39`
(34 retained samples); actions 1–5 are absent from the supplied attachment.
The observed raw length runs from 6 to 41. The jump from raw length 17 to 20
at event 18 is consistent with the existing one-anchor Debug diagnostic arm
adding two anchored slots; it is not a host commit.

All retained rows report:

- `committed=false`;
- the same valid native session (`4455878104`);
- 12 candidates;
- no session invalidation or composition reset.

The missing first five records limit the completeness of the length curve, but
do not prevent attribution of the retained slow events.

## Stage timing for retained samples

| Stage | Median | P95 | Worst |
|---|---:|---:|---:|
| `total` | 12.9 ms | 175.3 ms | 205.6 ms |
| `rime` | 5.45 ms | 173.0 ms | 203.2 ms |
| `pathLocal` | 1.05 ms | 1.7 ms | 2.1 ms |
| `pathUI` | 3.75 ms | 5.9 ms | 7.3 ms |
| `candUI` | 0.4 ms | 0.7 ms | 0.8 ms |
| `ui` | 4.7 ms | 7.0 ms | 8.6 ms |

There are four retained `total >= 50 ms` events:

| Action / raw length | `total` | `rime` | `processKey api` | `collect` | UI (`pathUI+candUI`) |
|---:|---:|---:|---:|---:|---:|
| 16 / 16 | 175.3 ms | 173.0 ms | 172.7 ms | 0.2 ms | 1.1 ms |
| 25 / 27 | 165.3 ms | 163.0 ms | 162.7 ms | 0.1 ms | 1.1 ms |
| 33 / 35 | 205.6 ms | 203.2 ms | 203.0 ms | 0.1 ms | 1.1 ms |
| 35 / 37 | 189.6 ms | 187.3 ms | 187.1 ms | 0.1 ms | 1.0 ms |

The stalls recur at several composition lengths rather than one isolated UI
refresh. In each retained slow event, the RIME API accounts for approximately
99% of the total duration.

## Shadow/anchor and path observations

- One content-free `T9AUTO status=accepted` was recorded at event 18:
  `anchorSyllables=2`, `anchorSlots=7`, `unresolvedSlots=11`,
  `applyMs≈2.35`.
- The later raw lengths 27, 35 and 37 still contain large RIME API stalls.
  This shows that the existing one-anchor Debug arm does not eliminate the
  residual failure class; it is not an A/B efficacy result.
- `T9SHADOW` remains structurally `candidateSetIncomplete` during the
  unconfirmed composition. That status is not evidence of candidate-row
  disappearance, consistent with the Human report.
- No `T9RESP marker=PATH/READY` appears in the export. This run therefore does
  not prove that the off-main thread-affine owner was active.

## Bounded conclusion

This is the strongest current P2-PERF-01 observation: on the real iPhone 13
Pro, with the correct manual fixture and no functional integrity regression,
subjective stalls coincide with `librime processKey` API spans of roughly
163–203 ms while Path/Candidate UI work stays around 1 ms. The evidence
supports Arch P1-3 as the primary next engineering question and argues against
making Path/Candidate reloads the first remediation lever for this failure
class.

It does **not** prove a product SLO, Release behavior, jetsam safety, off-main
success, ADR 0025 acceptance, Product Gate or default-on readiness. The
ordinary gate-off restoration and independent Architecture/Quality handoff are
now recorded below; the Assignment remains `In Progress` only for the explicit
partial-export/provenance and Human-score conditions listed by the reviewers.

## Ordinary gate-off restoration

After this diagnostic arm, a normal Release build was built from the same
working source and installed by replacement. The first temporary restore
attempt did not produce a complete app and was not installed; the second
attempt completed successfully.

| Field | Value |
|---|---|
| Configuration | `Release`, `CONFIGURATION=Release`, Swift 6, iPhoneOS 27.0 SDK |
| Preflight conditions | No `SWIFT_ACTIVE_COMPILATION_CONDITIONS` or `GCC_PREPROCESSOR_DEFINITIONS` were returned by Release build settings; no diagnostic `T9SEG/T9AUTO/T9SHADOW` strings in the Extension binary |
| App executable SHA-256 | `d4d1dbe4527044052e6c5b07b6775364b54e14915743cbcb7bf84b927be0c427` |
| Extension executable SHA-256 | `81d15c284b97726acd782b5fd720b56ec6b7d6938e8d810ad4e64593130f4874` |
| Install result | `devicectl device install app` succeeded; bundle `1.0 (1)` present on the iPhone 13 Pro |
| Install database sequence | `3600` |

This restores the ordinary gate-off/device state. No further Human input is
required for this Assignment unless a complete 39-record export is needed for
a stricter length curve.

## Independent review handoff

- [Architecture review](../assignments/t9-responsive-pipeline-001-p2-perf-01-architecture-review.md): **Pass with conditions** — bounded engine-attribution observation only; P0/P1/P2/P3 = 0/0/3/1.
- [Quality review](../assignments/t9-responsive-pipeline-001-p2-perf-01-quality-review.md): **Pass with conditions** — bounded diagnostic attribution only; P0/P1/P2/P3 = 0/0/4/0.

Both reviews agree that the retained slow rows support prioritizing the
synchronous RIME `processKey` path, while action 1–5, readable raw attachment
bytes, complete run provenance and the Human 0–4 score remain missing. Neither
review authorizes production wiring, ADR acceptance, Product Gate or default-on
behavior.
