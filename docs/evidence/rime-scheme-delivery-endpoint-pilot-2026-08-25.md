# RIME-SCHEME-DELIVERY-001 — Bounded Endpoint Pilot

> **Collected:** `2026-08-25 Asia/Shanghai`
> **Repository base:** local branch `codex/task11-reproduction-details`, commit
> `1af71a9`
> **Executor:** Current Codex task, bounded read-only endpoint pilot
> **Evidence grade:** `Executor-recorded`
> **Network boundary:** current Mac network path with shell proxy variables
> explicitly unset; physical location, ISP, system tunnel/Loon routing and
> Mainland China cellular behavior were not independently established
> **Privacy boundary:** public unauthenticated HTTPS only; no tester/device,
> credential, private input, SSID, IP-derived region or carrier data collected
> **Expiry:** upstream asset mutation, endpoint/path/operator change, direct
> Mainland network pilot or implementation Assignment Decision

## Authorized Scope

The Human Product Owner replied `可以，继续吧` after the proposed bounded pilot.
This authorized public read-only release metadata, bounded Range/first-byte
requests and full-stream SHA-256 verification after small probes passed. It did
not authorize production code, provider purchase, mirror creation, publication,
external contact or release distribution.

## Artifact Identity

### 雾凇 `nightly/full.zip`

| Source/path | Size | SHA-256 / evidence | Result |
|---|---:|---|---|
| GitHub API + `releases/download/nightly/full.zip` | `16,041,786` | GitHub asset digest `f60aa4f3bf5bcae5f49697cd529fa0c990c91f7349acd350073bcae75ff7410f` | Canonical upstream receipt for this pilot |
| NJU `LatestRelease/full.zip` | `16,050,491` | Full hash not run because declared size already differed | **Reject as equivalent endpoint**; mutable/stale mapping did not identify the current GitHub bytes |
| NJU `nightly%20build/full.zip` | `16,041,786` | Streamed SHA-256 `f60aa4f3bf5bcae5f49697cd529fa0c990c91f7349acd350073bcae75ff7410f` | **Byte-identical technical candidate** |

Both GitHub and the exact NJU `nightly build` path returned HTTP `206` for
`Range: bytes=0-65535`, with exactly 65,536 bytes. NJU's exact path therefore
passes anonymous access, Range and byte-identity checks on the current network.
Operator/App-use acceptability and cross-network evidence remain open.

Because upstream reuses the mutable tag `nightly`, the URL alone is not an
immutable identity. A manifest must bind any download to the expected size and
SHA-256; a later upstream or mirror update will then fail closed until a new
manifest receipt is accepted.

### 万象 `v17.5.9/rime-wanxiang-base.zip`

| Source/path | Size | SHA-256 / evidence | Result |
|---|---:|---|---|
| GitHub API + `releases/download/v17.5.9/rime-wanxiang-base.zip` | `35,020,530` | GitHub tag commit `7aefc0cc38e744e33cd18e6abd5996c00a8d2c5a`; asset digest `73f8c9da0f09b982629aae3cbc4a8ca33640e1bdaf7557ded49b71f94b7b2c87` | Canonical GitHub artifact receipt |
| CNB `releases/download/v17.5.9/rime-wanxiang-base.zip` | `35,027,247` | CNB page commit `9f0bd587f886132b1b1dabfd81fd0dcf60a5f8be`; page digest and streamed SHA-256 both `9bfcf60e62d85dd168cd2748e5b2d126fcb3355939969eb80455ba71cbf67732` | CNB artifact is independently verifiable but **not byte-identical to GitHub and not bound to the same commit** |

Both endpoints returned HTTP `206` and exactly 65,536 bytes for the bounded
Range probe. CNB redirects once to `asset.cnb.cool`; the final response supports
byte ranges. However, different size and digest mean the two artifacts cannot be
members of one byte-equivalent endpoint race under a single archive digest.

A subsequent full extraction comparison narrowed the content drift:

- GitHub contained `84` files; CNB contained `87` files.
- All `84` shared relative paths were hashed individually. `83` were byte-
  identical; only `README.md` differed.
- CNB alone contained `custom/wanxiang_pure.custom.yaml`,
  `custom/wanxiang_pure.schema.yaml` and `custom/wanxiang_pure.dict.yaml`.
- The ordinary `wanxiang` schema, dictionaries, Lua data/scripts and all other
  shared runtime files were byte-identical. No ordinary `wanxiang` file
  references `wanxiang_pure`; the extra files declare a separate optional Pure
  schema.
- Both archives declare `17.5.9` in `version.txt`, despite their different
  archive digests and source commits.

Therefore the two assets are **ordinary-Wanxiang runtime-equivalent for this
snapshot, but not artifact-equivalent**. This is narrower than substantive
dictionary/Lua drift, yet it still forbids pretending that one archive digest
identifies both. A Product/Architecture decision may instead model them as two
source variants of one upstream version. Such a contract must expose source,
tag, source commit/revision and archive-specific size/SHA-256; it must also
define whether the CNB-only Pure files are retained or excluded during guarded
staging. Transparent mid-download substitution is allowed only if the manifest
first binds both variants to the same validated installed-content identity.

## Current-Network First-Byte Samples

Each row is one sequential `Range: bytes=0-65535` request. Values include HTTPS
and any endpoint redirect. They are diagnostic samples, not release performance
budgets and not Mainland cellular evidence.

| Round | GitHub 雾凇 | NJU 雾凇 exact path | GitHub 万象 | CNB 万象 |
|---:|---:|---:|---:|---:|
| 1 | `0.919 s` | `0.199 s` | `1.028 s` | `0.526 s` |
| 2 | `0.979 s` | `0.191 s` | `0.994 s` | `0.609 s` |
| 3 | `1.062 s` | `0.203 s` | `1.000 s` | `0.611 s` |
| Median | `0.979 s` | `0.199 s` | `1.000 s` | `0.609 s` |

**Bounded inference:** a short hedge delay remains plausible. When a verified
Mainland endpoint is preferred, it may produce initial bytes before any fallback
starts; when GitHub is preferred but stalls, starting one fallback after a few
hundred milliseconds can reduce waiting. Exact delay and sample threshold remain
pilot-tuned implementation inputs, not accepted constants.

## Commands

Representative metadata and probe commands:

```bash
curl -fsSL -H 'Accept: application/vnd.github+json' \
  -H 'User-Agent: UniverseKeyboard-Pilot/1.0' \
  https://api.github.com/repos/iDvel/rime-ice/releases/latest
curl -sS -L --range 0-65535 --max-filesize 131072 \
  https://mirror.nju.edu.cn/github-release/iDvel/rime-ice/nightly%20build/full.zip
curl -fsSL \
  https://mirror.nju.edu.cn/github-release/iDvel/rime-ice/nightly%20build/full.zip \
  | shasum -a 256
curl -sS -L --range 0-65535 --max-filesize 131072 \
  https://cnb.cool/amzxyz/rime-wanxiang/-/releases/download/v17.5.9/rime-wanxiang-base.zip
curl -fsSL \
  https://cnb.cool/amzxyz/rime-wanxiang/-/releases/download/v17.5.9/rime-wanxiang-base.zip \
  | shasum -a 256
```

All live commands explicitly unset `HTTP_PROXY`, `HTTPS_PROXY`, `http_proxy`
and `https_proxy`. This prevents the obsolete local shell proxy configuration
from being used, but it does not prove that macOS system routing or Loon did not
participate.

## Gate Disposition

| Gate | Result |
|---|---|
| Public anonymous access | Pass on current network for all four exact probe URLs |
| HTTP Range / bounded traffic | Pass on current network for all four exact probe URLs |
| 雾凇 GitHub ↔ NJU byte identity | Pass only for NJU `nightly build`; `LatestRelease` fails |
| 万象 GitHub ↔ CNB byte identity | **Fail** for `v17.5.9` |
| 万象 ordinary-schema runtime identity | Pass for all shared non-README files in this snapshot; CNB has 3 additional optional Pure-schema files |
| Published/observed digest correctness | Pass for GitHub metadata, NJU streamed match and CNB page/streamed match |
| App-use permission / acceptable use | `UNKNOWN` |
| Mainland China cellular/Wi-Fi | `UNKNOWN` |
| Non-Mainland independent verification | `UNKNOWN` |
| Architecture / Quality review | `UNKNOWN` |

This pilot does not satisfy the Assignment Exit Criteria and does not authorize
implementation. It narrows the next decision to one byte-identical 雾凇 pair and
a no-new-server 万象 choice: either keep only GitHub, or accept GitHub/CNB as
explicitly identified source variants with archive-specific receipts and a
common installed-content contract.
