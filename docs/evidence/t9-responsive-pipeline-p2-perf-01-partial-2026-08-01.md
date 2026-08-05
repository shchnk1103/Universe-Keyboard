# P2-PERF-01 真机诊断 — 非规范部分证据（2026-08-01）

**Status:** `Partial — non-canonical manual run; Assignment remains open`

**Boundary:** 本记录只保留内容脱敏的阶段耗时、会话与事务计数。它不保存
宿主文本、候选文本、拼音载荷或截图，也不改变生产逻辑、Gate、ADR 0025
或 Product Gate 状态。

## Run header

| Field | Value |
|---|---|
| Assignment | `T9-RESPONSIVE-PIPELINE-001 / P2-PERF-01` |
| Device | iPhone 13 Pro (`iPhone14,2`) |
| OS | iOS 27.0 (`24A5390f`) |
| Host | Reminders empty-title workflow; Human reported software-keyboard path |
| Build | Debug, Swift 6, `-Onone`, bundle `com.DoubleShy0N.Universe-Keyboard`, `1.0 (1)` |
| App executable SHA-256 | `8739c47f1fc512ac048ccd147032d24d7c2695206e9547aeca39f410606fc4ca` |
| Extension executable SHA-256 | `302fb213f8bd9da6abdf342e54fb46487217b435657d71ef4a845d3da21bcca7` |
| Source HEAD | `3585a540ba8389673acd49128d87040ac9619f27` |
| Captured attachment SHA-256 | `55d9413bb7ee90cd801bc3e40790cb3e4298a06cd65115e4d47447f2c3daea0e` |
| Log window | `22:22:54.271`–`22:23:01.654` (local time) |

## Validity classification

The Human reported that the declared long nine-key sequence was not entered
exactly. The export starts at `action=8`, contains only 32 `T9SEG` samples
(`action=8...39`), and has a composition reset between the two observed
segments:

| Segment | Actions | Observed raw length | Samples |
|---|---:|---:|---:|
| A | 8–25 | 8–27 | 18 |
| B | 26–39 | 1–14 | 14 |

The log contains no `committed=true` sample and all retained `T9SEG` rows keep
the same valid session identity. The reset itself is observable, but its human
cause cannot be inferred from this content-free export. No subjective 0–4
score or complete integrity report was supplied with this attachment.

Therefore this run is **not** a valid exact-fixture curve, A/B comparison, or
Product Gate evidence. It is retained as a bounded engine-attribution
observation only.

## Observed stage timing

### Segment A (`action=8...25`)

| Stage | Median | Worst |
|---|---:|---:|
| `total` | 14.9 ms | 211.0 ms |
| `rime` | 5.7 ms | 208.7 ms |
| `pathLocal` | 1.1 ms | 2.0 ms |
| `preedit` | 0.1 ms | 0.1 ms |
| `pathUI` | 4.5 ms | 6.5 ms |
| `candUI` | 0.5 ms | 0.9 ms |

The content-free slow records were:

| Action / raw length | `total` | `rime` | `processKey api` | `collect` | UI (`pathUI+candUI`) |
|---:|---:|---:|---:|---:|---:|
| 14 / 14 | 37.4 ms | 32.6 ms | 31.9 ms | 0.4 ms | 2.4 ms |
| 16 / 16 | 211.0 ms | 208.7 ms | 208.5 ms | 0.2 ms | 1.1 ms |
| 25 / 27 | 174.0 ms | 171.8 ms | 171.6 ms | 0.1 ms | 1.1 ms |

### Segment B (`action=26...39`)

There were no `total >= 50 ms` samples. The worst sample was action 33,
`rawLen=8`, `total=24.1 ms`, `rime=18.7 ms`, with UI `3.2 ms`.

## Interpretation

1. The two visible-scale stalls in Segment A are overwhelmingly inside the
   RIME `processKey` API (`208.5 ms` and `171.6 ms`), while `collect` and UI
   stages remain around 0–1 ms. This supports the existing Arch P1-3 diagnosis:
   a synchronous/main-thread librime call can directly create a subjective
   keyboard stall.
2. The export has no `T9RESP marker=PATH/READY` line. It therefore does not
   prove that the off-main thread-affine pipeline was active; it must not be
   reported as an off-main success or a fix for Arch P1-3.
3. One content-free `T9AUTO status=accepted` event was observed before action
   18 (`applyMs≈1.26`, one-anchor Debug diagnostic arm). The later 211 ms and
   174 ms RIME spikes do not establish anchor efficacy or failure because the
   input sequence was non-canonical and there is no matched control arm.
4. `candidateSetIncomplete` in `T9SHADOW` is structural diagnostic state for
   an unconfirmed, unselected T9 composition; it is not by itself proof that
   the candidate UI disappeared.

## What this evidence proves / does not prove

**Proves, within this partial run:**

- The captured Debug device path produced content-free per-key timing records.
- At least two large stalls were RIME API-dominated rather than Path/Candidate
  UI-dominated.
- The sampled native session stayed valid and no retained row reported a commit.

**Does not prove:**

- The exact declared fixture was entered, or that all physical actions were
  captured (actions 1–7 are absent).
- A fixed-cadence latency curve, a comparison against another build, a numeric
  SLO, or a product-level “不卡顿” result.
- Off-main librime ownership, real-device jetsam safety, Release behavior,
  ADR 0025 acceptance, Product Gate, or Release readiness.

## Follow-up boundary

This partial artifact is sufficient to prioritize the off-main/thread-affine
P1-3 spike as the next engineering question, but it does not close
P2-PERF-01. A single corrected manual run is needed only if the team requires
an exact-fixture event curve or an evidence row that satisfies all Assignment
exit criteria. No production change is authorized by this artifact.
