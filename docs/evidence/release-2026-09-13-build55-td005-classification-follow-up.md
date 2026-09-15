# RELEASE-2026-0801-04 — Build 55 TD-005 只读分类复核回执

> **Run ID:** `RELEASE-2026-0801-04-B55-TD005-CLASSIFICATION-REVIEW-20260913`
> **Status:** `Completed — read-only artifact classification; TD-005 remains Blocked; Archive build metadata discrepancy recorded`
> **Evidence grade:** `Executor-recorded`
> **Collected:** `2026-09-13 Asia/Shanghai`
> **Assignment:** [`RELEASE-2026-0801-04`](../assignments/release-2026-08-01-04-device-performance.md)
> **Preceding query:** [`Build 55 TD-005 systemCrashLogs query`](release-2026-09-13-build55-td005-system-crash-query.md)
> **Handbook:** [`CRASH_JETSAM_SYMBOLICATION.md`](../CRASH_JETSAM_SYMBOLICATION.md)
> **Subsequent artifact reconciliation:** [`Build 55 Archive ↔ export reconciliation`](release-2026-09-13-build55-archive-export-reconciliation.md)

## Scope and boundary

本回执只复核已经保留的系统报告、Archive、dSYM 以及 Store/Ad Hoc 导出包，目标是完成 TD-005 的
报告分类和候选身份交叉核对。没有访问或改变 iPhone，没有安装、卸载、启动、终止、清理 App Group/RIME/
user dictionary，也没有执行 Git、上传、分发或发布动作。

原始系统报告仍只保存在 git-ignored 的受控 evidence 目录；本回执只记录分类所需字段、UUID、哈希和
元数据差异，不记录用户输入、宿主文字或候选内容。

## Read-only methods

- 重新计算前一份回执中的五个原始报告副本 SHA-256，并与既有回执核对。
- 使用 `/usr/bin/jq` 解析四份 Jetsam JSON 的报告级和产品进程行，只输出 `bug_type`、`pageSize`、
  `largestProcess`、进程状态、`rpages`、`lifetimeMax` 以及 victim/reason 相关字段。
- 使用 `xcrun dwarfdump --uuid` 对 Archive 内 App/Keyboard 可执行文件、Store/Ad Hoc 导出包中的
  App/Keyboard 可执行文件和两份 dSYM 做 UUID 交叉核对。
- 重新计算 App/Keyboard dSYM DWARF 文件 SHA-256，并读取 Archive、嵌入 App、dSYM、导出
  `DistributionSummary.plist` 与 `ExportOptions.plist` 的版本/构建字段。

## Frozen candidate reference

| Boundary | Recorded value |
|---|---|
| Candidate source | `main` @ `b8175129f26f787a6c7fee0be5977ebec46edf60` |
| Candidate | Xcode Cloud `Archive Pilot (No Distribution)` Build `55`; version `1.0 (55)` |
| App executable UUID | `6898B44F-EF4F-3B46-93C8-BCE83668270A` |
| Keyboard executable UUID | `C6C1758B-ECA2-3784-8EFA-22AF59B6CF25` |
| Device reports | Existing query artifacts from iPhone 13 Pro / iOS `27.0 (24A435)` |
| Local artifact audit root | `/private/tmp/uk-build55-audit.DNj3jv/` (outside the repository; read-only) |

## Report classification

所有四份 Jetsam 报告均为 `bug_type=298`、`pageSize=16384`。三份含有 Build 55 App/Keyboard UUID 的报告
都没有在 Keyboard 产品行中出现 `victim`、`jettisoned`、`killed` 或进程级 `reason`。依照 handbook，
仅有进程存在、进程状态、最大进程或内存页数不足以证明 Keyboard 被系统终止，因此保留为
`unclassified`。

| Report time | Largest process | Build 55 product rows | Keyboard observed fields | Classification |
|---|---|---|---|---|
| `2026-09-12 19:17:22 +0800` | `WeChat` | none | — | unrelated snapshot |
| `2026-09-12 20:28:57.16 +0800` | `com.apple.dt.instruments.dtsecur` | App and Keyboard UUIDs match | `active,frontmost`; `rpages=1645`; `lifetimeMax=1645` | `unclassified`; no product victim evidence |
| `2026-09-12 22:26:07.06 +0800` | `WeChat` | App and Keyboard UUIDs match | `suspended`; `rpages=2769`; `lifetimeMax=2776` | `unclassified`; no product victim evidence |
| `2026-09-13 09:51:46.25 +0800` | `WeChat` | App and Keyboard UUIDs match | `suspended`; `rpages=2746`; `lifetimeMax=3000` | `unclassified`; no product victim evidence |

对应的 Keyboard resident/lifetime-max 值（以 `rpages × pageSize` 计算）为：

| Report time | Keyboard resident | Keyboard lifetime max |
|---|---:|---:|
| `2026-09-12 20:28:57.16 +0800` | `26,951,680` bytes | `26,951,680` bytes |
| `2026-09-12 22:26:07.06 +0800` | `45,367,296` bytes | `45,481,984` bytes |
| `2026-09-13 09:51:46.25 +0800` | `44,990,464` bytes | `49,152,000` bytes |

前一份查询中的 `Universe Keyboard-2026-09-11-191458.ips` 是 Build `1`、App UUID
`7e8336d3-adcd-3268-a212-724f57a14ac1` 的 `EXC_CRASH`/`SIGKILL` 报告；它不是 Build 55，继续排除，
本复核没有 Build 55 crash 可供分类。

## Candidate identity cross-check

### UUID and dSYM mapping

| Artifact family | App UUID | Keyboard UUID | Result |
|---|---|---|---|
| Archive executable | `6898B44F-EF4F-3B46-93C8-BCE83668270A` | `C6C1758B-ECA2-3784-8EFA-22AF59B6CF25` | match |
| Store IPA executable | same | same | match |
| Ad Hoc IPA executable | same | same | match |
| App/Keyboard dSYM | same | same | exact UUID match |

重新计算的 dSYM DWARF SHA-256：

| dSYM | UUID | DWARF SHA-256 |
|---|---|---|
| `Universe Keyboard.app.dSYM` | `6898B44F-EF4F-3B46-93C8-BCE83668270A` | `e93313058a4983af7a8d5f5d75aff751a53899becceb3329a7a9eea9bd88d5d0` |
| `Keyboard.appex.dSYM` | `C6C1758B-ECA2-3784-8EFA-22AF59B6CF25` | `d82a1ca71fec466acf23fd7be12431fd794392e8b7b77211732cda034434ec0f` |

这证明了代码映像 UUID 与 dSYM 在 UUID 层可以相互绑定，也与三份 Jetsam 产品行相符；它不等于报告
已经证明了 Keyboard 是 victim，也不替代精确的 Archive 元数据校验。

### Archive/export build metadata discrepancy

本次只读复核发现一个必须保留的身份差异：

| Source | Version | Build field |
|---|---|---|
| Archive top-level `Info.plist` | `1.0` | `CFBundleVersion=1` |
| Archive embedded App `Info.plist` | `1.0` | `CFBundleVersion=1` |
| App dSYM / Keyboard dSYM `Info.plist` | `1.0` | `CFBundleVersion=1` |
| Exported Store IPA App/Extension | `1.0` | `CFBundleVersion=55` |
| Exported Ad Hoc IPA App/Extension | `1.0` | `CFBundleVersion=55` |
| Store `DistributionSummary.plist` | `1.0` | `buildNumber=55` |
| Ad Hoc `DistributionSummary.plist` | `1.0` | `buildNumber=55` |
| Store `ExportOptions.plist` | `1.0` | `buildNumber=55`; `manageAppVersionAndBuildNumber=false` |

Archive 与导出包/ dSYM 的 App/Keyboard 可执行文件 UUID 相同，但 Archive 自身及其 dSYM 元数据报告的
`CFBundleVersion=1`，而导出包与导出摘要报告 `55`。本回执不推断造成差异的原因，也不把 UUID 相同
自动解释为 Archive 已经是 Build 55；精确的 Archive ↔ Build 55 关系需要 Release/Artifact owner
进一步对照权威产物。

## Outcome

| Claim | Outcome | Boundary |
|---|---|---|
| Existing raw report copies are intact | `pass` | Five SHA-256 values re-computed and matched the prior query receipt |
| Build 55 process UUID correlation | `pass at UUID layer` | Three Jetsam rows match both frozen App/Keyboard UUIDs |
| dSYM UUID mapping | `pass` | App and Keyboard dSYM UUIDs match the executable UUIDs and prior receipt hashes |
| Build 55 crash classification | `not available` | Only named crash report is Build 1 and is excluded |
| Keyboard Jetsam victim classification | `blocked / unclassified` | No victim/jettisoned/killed/reason marker in any matching row |
| Exact Archive ↔ Build 55 metadata mapping | `blocked` | Archive/dSYM metadata says build `1`; exports say build `55` |
| Symbolication | `not run` | No causally identified victim and exact Archive identity remains unresolved |
| TD-005 | **`Blocked; no closure`** | Acquisition and UUID/dSYM review advanced, but classification and exact artifact identity remain open |

## Raw artifact pointers and hashes

原始报告位于既有 git-ignored 受控目录：
`evidence/release-2026-0801-04-build55/2026-09-13/raw/td005-system-crash-logs/`。
下列值在本次复核中重新计算，并与前一份查询回执一致：

| Artifact | SHA-256 |
|---|---|
| `unrelated-universe-keyboard-2026-09-11-191458.ips` | `8637a8716967c50dd8df8229280a38c374ee7884a1030bca9471a6ed3e732184` |
| `jetsam-2026-09-12-191722.ips` | `c71b7ba218faecc7f7d0fdbb44dbbf9f97eba3d32ce2874961e4792086c2bca1` |
| `jetsam-2026-09-12-202857.ips` | `486d647bcc513edbbfba4a9b998cb5be94e4e92325b7e3f93353b31bf421aac7` |
| `jetsam-2026-09-12-222607.ips` | `c2e70724d1e4e067de9f8f24471d5d3416576574081066bfde93a2c95bb5e3b1` |
| `jetsam-2026-09-13-095146.ips` | `e9fd9ce2f0356fa14f457b3ef8559907a24f95d1d1c6d142dee7491c5da98929` |
| `device-apps.json` | `8ccd0043a979f1b0767ee4f946ae9d040dcd94fa8ea3be10f0ef870104af3a80` |
| `device-details.json` | `fa1c161911413b98dc64df19ef4b60007ef6281f057dfef2e601c8cf9b472be2` |
| `system-crash-logs-search-universe.json` | `18c5862147b3682a1408a30b1ea2db898f62b5ad6fc04d3f767d519b27ac3aae` |
| `system-crash-logs-search-jetsam.json` | `84c162dee9208dde4d031063b0d0f54880648ce8c79082f59c670a3b9b12ceea` |
| `system-crash-logs-search-crash.json` | `32821268cde20bb9f82fbc469e8a0d6f061a0196677e09e200bc24a70532b517` |

补充的导出包哈希为：Store IPA `b178c05530b92a207eb8aaf4e701c1db803fec728c3df702424c89944ee1c6fd`，
Ad Hoc IPA `ec02dc4a959549d6ba2b36224a405740b4eeb7ca2cfbcdcbab5b0932ae069ebc`。这些哈希只用于本地
artifact 交叉核对，不改变当前 TestFlight/Release 授权边界。

## Handoff and next action

本只读切片完成了现有报告的分类复核和 UUID/dSYM 交叉核对，但没有关闭 TD-005：

1. Release/Artifact owner 需要对照权威产物，解释并解决 Archive/dSYM 的 `CFBundleVersion=1` 与导出包
   /摘要的 `buildNumber=55` 差异；如果 Archive 实际属于 Build 1，应取得真正的 Build 55 Archive/dSYM
   并重新建立映射。
2. 即使身份差异被解决，三份现有 Jetsam 仍没有 victim 标记，不能据此声称 Keyboard 被系统终止；后续
   分类或 symbolication 必须建立在新的、字段足够的报告或明确授权的证据路径上。
3. 本授权范围内不再诱发新的终止场景，不进行设备重试或发布动作；身份收敛后交回独立 Quality/Release
   Reviewer 复核。

因此，TD-005 继续为 **Blocked**，整体更广泛外部公测门禁也继续保持 **Blocked**。

> **历史快照说明：** 本回执保留分类复核当时的“Archive ↔ Build 55 元数据关系待核对”结论；后续只读
> 核对已确认代码映像 UUID/资源链和导出阶段 `buildNumber=55` 的来源，但 Archive 自身仍报告
> `CFBundleVersion=1`。当前分层结论以 [`Archive ↔ export reconciliation`](release-2026-09-13-build55-archive-export-reconciliation.md)
> 为准；Jetsam victim 分类仍未关闭。
