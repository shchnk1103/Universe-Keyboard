# RIME Scheme Delivery — Wanxiang Integrity Failure Evidence — 2026-08-26

**Assignment:**
[`RIME-SCHEME-DELIVERY-INTEGRITY-001`](../assignments/rime-scheme-delivery-integrity-001.md)
**Parent:** [`RIME-SCHEME-DELIVERY-001`](../assignments/rime-scheme-delivery-001.md)
**Collection date / timezone:** `2026-08-26 Asia/Shanghai`
**Privacy boundary:** no typed content, contact value, credential, sensitive URL
query or complete local user path is recorded.

## Human Physical-Device Observation

**Evidence grade:** `Device-attested`

The Human Product Owner supplied a screenshot from the previous evening showing
the Wanxiang detail page after a failed download. The durable failure row read:

> 下载内容未通过完整性校验，已停止安装，请稍后重试

The page did not show an installed version, archive size or archive SHA-256.
The original attachment remains in the active Codex task and is not copied into
the repository.

| Field | Observed value |
|---|---|
| Scheme | 万象拼音 |
| Result | Download stopped before installation with the generic integrity message |
| Device / OS | `UNKNOWN` — not supplied with this screenshot |
| App build / commit | `UNKNOWN` — do not infer PR #83 HEAD from the repository checkout |
| Network / region | `UNKNOWN` for this attempt |
| Selected source | `UNKNOWN` — transient source UI was not captured |
| Integrity phase | `UNKNOWN` — the current error collapses archive-size, archive-digest and staged-content mismatch |

This proves a user-visible failure, not its source or root cause. It blocks the
Wanxiang physical-device delivery claim for PR #83 until classified and
remediated or explicitly dispositioned by Product.

## Executor Static Trace

**Evidence grade:** `Executor-recorded`
**Inspected implementation snapshot:** `bcf6c1c46ff374cfea20ec2552ca273161cb8d76`

The current path in `SchemaManager+Download.swift` and
`SchemaArtifactSecurity.swift` establishes:

1. archive verification first compares exact byte count, then streaming
   SHA-256;
2. either mismatch becomes the same `DownloadError.integrityMismatch`;
3. `downloadFirstValidArchive` immediately rethrows that error rather than
   trying the next independently pinned source;
4. after extraction and deterministic post-processing, guarded staged-content
   digest mismatch also becomes the same error and user-facing text;
5. therefore the screenshot cannot distinguish transport artifact corruption
   from post-processing/allowlist drift.

## Current Endpoint Reverification

**Evidence grade:** `Executor-recorded`
**Environment:** current macOS command-line environment, `2026-08-26`; this is
not Mainland cellular or physical-iOS evidence.

Fresh downloads of both fixed Wanxiang `v17.5.9` archives matched the manifest:

| Source | Actual bytes | Actual SHA-256 | Result |
|---|---:|---|---|
| CNB | `35,027,247` | `9bfcf60e62d85dd168cd2748e5b2d126fcb3355939969eb80455ba71cbf67732` | Exact manifest match |
| GitHub | `35,020,530` | `73f8c9da0f09b982629aae3cbc4a8ca33640e1bdaf7557ded49b71f94b7b2c87` | Exact manifest match |

The production allowlist and Lua post-processing algorithm were reproduced
against both extracted archives. Both sources converged on the manifest's
guarded staged-content identities:

| Runtime path | CNB | GitHub | Expected |
|---|---|---|---|
| Lua enabled | `5b182801298152236c790e29fd190d41b509c7da373babb0c02e65fa4eaf07cf` | same | exact match |
| Lua disabled | `289929084bd8ebc751a9ef9e936327331bf14670be5eeae4722221c0bf810682` | same | exact match |

The three CNB-only `custom/wanxiang_pure*` files are excluded by the production
installation plan. They change the source-specific archive receipt but do not
enter or alter the guarded staged-content receipt. Current evidence therefore
rejects “CNB has three extra Pure files” as the direct cause of this failure.

## Conclusion And Evidence Boundary

- Current server artifacts and compiled receipts agree from the Executor
  environment.
- The physical-device failure remains real but unclassified.
- Plausible classes include a damaged/truncated artifact on that network path,
  an exact-build/manifest difference, or a device-only extraction/post-processing
  discrepancy. None is promoted to root cause without phase/source evidence.
- The present observability gap and immediate archive-integrity rethrow prevent
  the multi-source design from recovering or explaining this attempt.

The bounded remediation and its Stop Conditions are owned by
[`RIME-SCHEME-DELIVERY-INTEGRITY-001`](../assignments/rime-scheme-delivery-integrity-001.md).
