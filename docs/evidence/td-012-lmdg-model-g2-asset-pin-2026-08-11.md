# TD-012-LMDG-MODEL-G2 — G2-A Asset Pin Evidence

| Field | Value |
|---|---|
| **Run ID** | `TD012-G2A-20260811T222509+0800` |
| **Date / timezone** | `2026-08-11 22:25 Asia/Shanghai` |
| **Repository base** | `9a177ab` (`main` after PR #67) |
| **Working branch** | `codex/td-012-lmdg-model-g2` |
| **Assignment** | [`TD-012-LMDG-MODEL-G2`](../assignments/td-012-lmdg-model-g2.md) |
| **Evidence grade** | `Executor-recorded` |
| **Result** | **Pass — G2-A asset bytes are pinned; G2-B remains blocked on Human Device Operator gate** |

## Scope And Non-claims

This run acquired one upstream simplified-Chinese model into a repository-external temporary directory,
verified exact bytes and SHA-256, recorded license/source metadata, and removed the temporary copy.

It does **not** prove model loading, ranking quality, Extension memory/Jetsam safety, schema configuration,
product installation, App Group placement, Architecture acceptance, Quality acceptance or Product Gate.

## Source Metadata Snapshot

Queried through the GitHub Releases API immediately before download:

| Field | Value |
|---|---|
| Repository | [`amzxyz/RIME-LMDG`](https://github.com/amzxyz/RIME-LMDG) |
| Release tag / ID | `LTS` / `268075342` |
| Asset ID | `508872749` |
| Asset name | `wanxiang-lts-zh-hans.gram` |
| Asset API URL | `https://api.github.com/repos/amzxyz/RIME-LMDG/releases/assets/508872749` |
| Browser URL | `https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram` |
| Exact size | `420251692` bytes (`400.783 MiB`) |
| GitHub digest | `sha256:90d2385f65337f8b8c7b1ba5cbe874df3f2d91b462d68fa2f9fe90c57aa3bc66` |
| Asset created / updated | `2026-08-10T14:49:40Z` / `2026-08-10T14:55:14Z` |
| Release published | `2025-12-07T07:13:21Z` |

The asset was created months after the Release publication date. Therefore the `LTS` tag/browser URL is
explicitly treated as mutable discovery metadata, not the reproducibility identity. The accepted G2-A
identity is asset metadata plus the locally verified SHA-256 above.

## Byte Verification

Temporary location during the run:

`/private/tmp/universe-lmdg-g2.wHf8lp/wanxiang-lts-zh-hans.gram`

Commands:

```sh
curl --fail --location --retry 2 --connect-timeout 20 \
  --output /private/tmp/universe-lmdg-g2.wHf8lp/wanxiang-lts-zh-hans.gram \
  https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram
stat -f 'bytes=%z' /private/tmp/universe-lmdg-g2.wHf8lp/wanxiang-lts-zh-hans.gram
shasum -a 256 /private/tmp/universe-lmdg-g2.wHf8lp/wanxiang-lts-zh-hans.gram
```

| Check | Result | Evidence grade | Receipt |
|---|---|---|---|
| Exact byte count | Pass | `Executor-recorded` | `420251692` |
| Local SHA-256 vs GitHub digest | Pass | `Executor-recorded` | `90d2385f…3bc66` = match |
| File remained outside repository | Pass | `Executor-recorded` | only the explicit `/private/tmp/...` path was used |
| Git-tracked `.gram` absence | Pass | `Executor-recorded` | `git ls-files '*.gram'` returned empty |
| Workspace `.gram` absence | Pass | `Executor-recorded` | `find . -type f -name '*.gram'` returned empty |
| App Group write | Not performed | `Executor-recorded` | no App Group path was used by this run |

## License And Attribution Boundary

- GitHub repository metadata identifies the project license as **CC BY 4.0**.
- Upstream LICENSE source:
  [`RIME-LMDG/LICENSE`](https://github.com/amzxyz/RIME-LMDG/blob/wanxiang/LICENSE),
  Git blob `4ea99c213c5c0c005ae4e80df8e52169d06896ec` at the metadata snapshot.
- Any future distribution must preserve creator/source identification, license notice/link, warranty
  disclaimer reference, source URI and modification indication when applicable.
- This is an engineering attribution receipt, **not** a legal opinion or App Store compliance decision.

## Cleanup Receipt

The temporary model and its dedicated temporary directory were removed after hashing. A post-cleanup check
confirmed the path no longer existed. No `.gram` was retained in the repository or App Group by this run.

## G2-A Decision

**Pass** for the bounded asset-pin question:

- exact bytes can be acquired today;
- local SHA-256 matches the candidate digest;
- the mutable `LTS` locator can be made fail-closed by checking the fixed digest;
- model bytes remain outside product state.

G2-A does not authorize G3. The next boundary is G2-B preparation and the Human Device Operator gate.
