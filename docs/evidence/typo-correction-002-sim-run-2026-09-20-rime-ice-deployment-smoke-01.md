# Run Receipt — RIME Ice deployment smoke

## Receipt identity

| Field | Value |
|---|---|
| Run ID | `TC2-SIM-20260920-RIME-ICE-SMOKE-01` |
| Captured | `2026-09-20` / Asia/Shanghai; deployment terminal log `20:51:34` |
| Evidence grade | `Executor-recorded; independent Architecture/Quality review not yet requested` |
| Run status | `bounded pass — RIME deployment precondition only` |
| Parent Assignment | [`TYPO-CORRECTION-002-PARENT-REVALIDATION-002`](../assignments/typo-correction-002-parent-revalidation-002.md) |
| Authorization | [`AUTH-TYPO-CORRECTION-002-RIME-ICE-DEPLOYMENT-SMOKE-001`](../authorizations/AUTH-TYPO-CORRECTION-002-RIME-ICE-DEPLOYMENT-SMOKE-001.md) |

This receipt records one setup smoke. It establishes that the current
Simulator package can deploy and activate the pinned `rime_ice` resource in
the shared App Group. It does not establish candidate recovery, INT-003,
QA-001, paired performance, or any Product/Quality/Release Gate.

## Execution identity

| Field | Bound value |
|---|---|
| Worktree | `/private/tmp/universe-keyboard-typo-correction-002-parent-revalidation-003` |
| Branch | `codex/typo-correction-002-parent-revalidation-003` |
| Code/source snapshot used by package | `3f9f2652b03279a99537639f4382b48bb58548ca` |
| Installed package | `/private/tmp/universe-keyboard-typo-correction-002-parent-revalidation-003-signed-app-derived/Build/Products/Debug-iphonesimulator/Universe Keyboard.app` |
| Target | iPhone 17 Pro Max / iOS 27.0 Simulator / `06C5BC3E-7599-4761-A1A2-71DAEA991474` |
| Host | Not used in this smoke; no Messages input |
| Build/install boundary | No rebuild or reinstall under this Authorization; the pre-existing package was used |

### Package hashes

| Package member | SHA-256 |
|---|---|
| App executable | `9f1c360daccd157144830fdcc92b9f4a02dd32ed9aa84e9c7ecab503b8d3af04` |
| App debug dylib | `0b7983d92d44671111554795c1f4cbb840deb5e9e6d4b6db6bbfb9e17dcc6778` |
| Keyboard executable | `2bfd0a0a00da2d0e014054ce32bd70fd6ea61f7d4388825dcbe6e368dd46a353` |
| Keyboard debug dylib | `92f148f18d6bf0c2268af44326199afd397fc733d8a9a3bba396ad03d3f2a028` |

These hashes were re-read after the human deployment action and still match
the Authorization-bound package identity.

## Human action and UI result

The Human Product Owner performed the one authorized main-app action: selected
the pinned 雾凇 scheme and waited for the deployment result. No Messages
session was opened, no keyboard input was entered, and no candidate was
selected.

The post-action UI snapshot reported:

| UI observation | Result |
|---|---|
| Scheme row | `雾凇拼音, 16 MB · 2026.06.30, 当前使用` |
| Resource state | `已部署` |
| Completion message | `配置已生效 ✓` |
| Deployment log | `部署日志 (1 条)` |

The UI result is corroborated below by the fresh App Group receipt and the
deployment terminal log; it is not used alone as provenance proof.

## Fresh runtime provenance

The receipt was read from the current Simulator App Group:

`AppGroup/97BEB20F-951C-42E0-A493-0B1F8C9404B5/Rime/user/rime-runtime-provenance.json`

| Field | Observed value |
|---|---|
| Provenance file SHA-256 | `771adec0e83414bf1e204c5b253c1b23d1cbe5fce5c93a8f223c7e5811e4d9a1` |
| Receipt ID | `67A0C52E-A975-47C8-9C09-4ADA1320DF87` |
| Generated at | `2026-09-20T12:51:34Z` |
| Scheme / active schema | `rime_ice / rime_ice` |
| Source / variant | `downloaded / nju` |
| Artifact identity / version | `rime-ice-20260630-675d23b0 / 2026.06.30` |
| Upstream revision | `6810e8916d160498620a16fef2135956fecbd485` |
| Archive SHA-256 | `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` |
| Installation plan / post-processing | `rime-ice-plan-2 / rime-ice-post-2` |
| Staged identity / content SHA-256 | `rime-ice-20260630-plan2-post2 / 781f61ce95526bf117cc3316dde014b1ab8cd941be9ecbf0c975b2e7a9a57701` |
| Installed-content SHA-256 | `2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26` |
| Runtime / Lua smoke | `true / true` |
| librime | `1.16.1` |
| Installed manifest entries | `70` |

### Independent installed-content check

The 70 manifest entries were read from the live App Group and checked without
trusting only the receipt's aggregate field:

- Missing files: `0`
- Per-file byte-count/hash mismatches: `0`
- Recomputed digest using `SchemaArtifactSecurity.contentSHA256`'s path,
  NUL separator, big-endian byte-count, file bytes and trailing NUL contract:
  `2e906d14853255cd0eba534e2b40791008c2cee65fa5a6e50b40bbd159cb6c26`
- Recomputed digest matches the runtime receipt: `yes`

The archive SHA is the pinned identity carried by the fresh runtime receipt.
This smoke did not separately export and re-hash the downloaded archive file;
that remains a provenance-detail non-claim rather than a deployment failure.

## Deployment terminal evidence

The app-owned runtime log was captured through the existing XcodeBuildMCP
helper log, without copying user input or candidate text:

| Artifact | SHA-256 |
|---|---|
| XcodeBuildMCP helper log | `3dd4377cd17f80e332a1466c1202047f14cc0fc74a8418977b0dd4d35c19d009` |
| `installation.yaml` | `b17578da77e1ba66995350f1e729f7824a718e873f1422129362b2411090596e` |
| Shared `rime_ice.schema.yaml` | `a30a65af2c4af68623d4ed2518f251454bef36fb7dff5e742f02350d8a6aea12` |
| Built `rime_ice.schema.yaml` | `e1bb4644c5887511d1a41f2e64e50da54a7aaabd58d40d0c03e06a8ec45943` |

The fresh deployment sequence records:

- `rime_ice` schema update and dictionary preparation;
- `dictionary 'rime_ice' is ready`;
- `finished updating schemas: 4 success, 0 failure`;
- `3 tasks ran: 3 success, 0 failure`;
- subsequent engine initialization loading `rime_ice.schema.yaml` and
  `rime_ice.table.bin`.

The live App Group preference audit also reported:

| Preference | Value |
|---|---|
| `rime_active_schema` | `rime_ice` |
| `rime_ice_installed` | `true` |
| `rime_deployed` | `true` |
| `rime_deploying` | `false` |
| `rime_needs_deploy` | `false` |
| `rime_ice_checksum` | `675d23b070be00e1b800f9a6db033ef98f4493cd5b568ed8aa3b3541769c46ac` |
| `rime_ice_staged_content_checksum` | `781f61ce95526bf117cc3316dde014b1ab8cd941be9ecbf0c975b2e7a9a57701` |

## Bounded disposition

**Pass for the RIME deployment precondition.** The same installed package
reached the current App Group, deployed the pinned `rime_ice` artifact, wrote
fresh runtime provenance, produced a matching live content digest, and left
the scheme active.

This is not a conclusion about:

- sidecar query behavior or route counts;
- INT-003's 180 ms cadence;
- QA-001 target-candidate visibility or selection;
- paired baseline/treatment comparability or latency;
- physical-device signing, VoiceOver, nine-key behavior, Product/Quality/
  Release Gates, TestFlight, merge or parent closure.

## Next handoff

Request independent Architecture and Quality read-only review of this bounded
deployment receipt. After that review, any QA-001 or paired-performance retry
must use its own fresh Authorization and Run ID; this smoke Authorization
cannot be reused for input capture.
