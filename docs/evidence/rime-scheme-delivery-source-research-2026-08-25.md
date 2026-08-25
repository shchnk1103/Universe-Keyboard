# RIME-SCHEME-DELIVERY-001 — Source Research And Current-Path Audit

> **Collected:** `2026-08-25 Asia/Shanghai`
> **Repository base:** local branch `codex/task11-reproduction-details`, parent
> commit `b5d6b55`
> **Method:** read-only source search plus first-party/upstream and provider
> documentation review
> **Evidence grade:** `Executor-recorded`
> **Superseded for endpoint behavior:** the bounded pilot is recorded in
> [`rime-scheme-delivery-endpoint-pilot-2026-08-25.md`](rime-scheme-delivery-endpoint-pilot-2026-08-25.md).
> Source/operator research below remains current until an upstream
> distribution-link or provider-terms change.

## Current App Path

The current catalog stores one GitHub owner/repository and asset name per
downloadable scheme. Download performs a GitHub `releases/latest` API request
with a 15-second timeout and then downloads the returned asset with a 300-second
timeout. A non-`DownloadError` failure is surfaced using the raw
`error.localizedDescription`, which can expose untranslated system text.

Repository searches found a per-scheme checksum storage key, but no SHA-256
calculation or expected-digest comparison in the scheme download/install path.
The current archive gate checks download response/size, ZIP extraction and the
presence of the expected schema file. Therefore “valid ZIP with expected
filename” is currently stronger evidence than “verified upstream bytes”; these
must not be treated as equivalent.

Reproduction commands:

```bash
rg -n "releases/latest|timeoutInterval|error.localizedDescription" \
  "Universe Keyboard/Services/SchemaManagerDependencies.swift" \
  "Universe Keyboard/Services/SchemaManager+Download.swift"
rg -n "checksum|SHA256|CryptoKit" \
  "Universe Keyboard/Services" "Universe Keyboard/Models" -g '*.swift'
```

## First-Party And Upstream Findings

### 雾凇拼音

- The 雾凇 upstream README lists both its GitHub latest `full.zip` and an NJU
  “大陆镜像加速” URL:
  <https://github.com/iDvel/rime-ice/blob/main/README.md#安装>.
- NJU documents a GitHub Release mirror layout with per-release directories and
  `LatestRelease`:
  <https://help.mirror.nju.edu.cn/github-release/?mirror=NJU>.
- The mirror currently exposes the 雾凇 release tree and `full.zip`, but the
  research did not locate terms explicitly authorizing sustained automatic
  third-party App traffic. Upstream endorsement supports a pilot, not a final
  operator-permission claim.

**Pilot update:** GitHub + the exact NJU `nightly build` path returned matching
size and SHA-256. NJU `LatestRelease` returned different bytes and is ineligible.
See the bounded endpoint pilot for commands and limits. Mutable `nightly` still
requires manifest-bound size and digest verification.

### 万象拼音

- The 万象 upstream GitHub Release pages publish SHA-256 values for release assets
  and link a “万象 CNB 国内镜像源”:
  <https://github.com/amzxyz/rime-wanxiang/releases>.
- The linked domestic repository exists at
  <https://cnb.cool/amzxyz/rime-wanxiang> and exposes Release artifacts.
- CNB documents public Release attachment download permission and Release event
  metadata including asset size and digest:
  <https://docs.cnb.cool/zh/guide/role-permissions.html> and
  <https://docs.cnb.cool/zh/develops/openapi-event.html>.

**Pilot update:** the CNB stable attachment URL, anonymous redirect, Range and
published digest were verified, but its `v17.5.9` bytes differed from GitHub's
same-tag asset and the two Release records pointed to different commits. CNB
therefore cannot be a transparent fallback under the GitHub digest. Its own
digest remains valid evidence only for the separate CNB artifact.

## Platform Alternatives

| Candidate | Verified first-party capability | Assessment |
|---|---|---|
| GitCode | Release attachments and a tagged attachment-download API are documented: <https://docs.gitcode.com/v1-docs/docs/repo/code/release/> and <https://docs.gitcode.com/docs/apis/get-api-v-5-repos-owner-repo-releases-attach-files-file-name-download/> | Viable reserve for a Universe-owned mirror; not preferred over scheme-maintainer-linked sources until anonymous direct-link, quotas and sync operation pass a pilot |
| Gitee | Official material documents GitHub repository mirroring and Release attachment APIs, but repository mirroring covers branches/tags/commits rather than proving Release asset synchronization: <https://blog.gitee.com/2021/07/15/repo-mirror/> and <https://gitee.com/sdk/gitee5j/releases> | Source mirroring alone is insufficient; a separately operated asset publication pipeline would be required |
| Alibaba Cloud OSS | Mainland regions, HTTP object download and default/custom domains are supported; a Mainland Bucket custom domain requires ICP filing: <https://help.aliyun.com/zh/oss/user-guide/access-buckets-via-custom-domain-names> | Strong managed fallback candidate when Product authorizes account, recurring egress cost, publication automation and compliance work |
| Tencent Cloud COS/CDN | Mainland COS regions and public default domains are documented; a custom domain on Mainland CDN requires filing: <https://cloud.tencent.com/document/product/436/6224> and <https://intl.cloud.tencent.com/zh/document/product/436/18670> | Same managed-fallback class as OSS; select only after cost, domain/compliance and operational ownership review |

## Recommendation

1. Pilot maintainer-linked sources first: GitHub + NJU for 雾凇, GitHub + CNB
   for 万象.
2. Treat endpoint choice and release identity separately: a manifest pins
   version, asset name, byte length and SHA-256; endpoint racing only chooses
   where to fetch those exact bytes.
3. Run the race only after explicit download intent, with at most two concurrent
   tasks and a bounded initial sample; exact timing/byte thresholds are pilot
   outputs rather than guessed release constants.
4. Add a Universe-controlled OSS/COS fallback only if upstream-linked mirrors
   fail availability/permission requirements or Product needs an enforceable
   service level.
5. Keep GitCode/Gitee as reserve publication targets, not as implicit trusted
   mirrors of GitHub Release assets.

## Unresolved Evidence

- NJU lag/mutation behavior and third-party App-use acceptability.
- A byte-identical Mainland 万象 mirror, or a Product/Architecture decision to
  treat the CNB artifact as a separate canonical artifact.
- Mainland China cellular/Wi-Fi and non-Mainland first-byte/download evidence.
- Cost and legal/operational owner for any Universe-controlled mirror.
- Architecture decision for manifest authority/signing and rollout/rollback.
