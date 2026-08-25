# RIME Scheme Management

This document records the product and implementation boundary for RIME multi-scheme management in the main App.

## Scope

RIME scheme management V1 supports a scalable settings structure for the built-in/default scheme and downloaded open-source schemes:

- `luna_pinyin` (built-in)
- `rime_ice` (downloadable)
- `wanxiang` (downloadable 万象拼音全拼 — [`PD-RIME-SCHEME-WANXIANG-001`](product-decisions/RIME-SCHEME-WANXIANG-001-authorization.md))

Future schemes should be added to the same list-and-detail model instead of creating separate top-level settings blocks for each scheme.

Chinese nine-key is **not** a separate user-visible base scheme. When fog-song (`rime_ice`) is installed, deployment may also compile a Universe-compatible `t9` schema (ADR 0018). Layout preference and versioned T9 readiness select `t9` at runtime; do not persist `t9` into `rime_active_schema`.

## User-Facing Model

普通用户只需要理解三件事：

- 当前使用：键盘正在使用这个输入方案。
- 已安装：这个方案已经准备好，可以切换使用。
- 可下载：这个方案还没有安装，进入详情页后可以下载。

Avoid exposing internal RIME terms such as schema IDs, deployment stages, or YAML file names in the main row copy. Internal details can remain in logs or developer documentation.

## UI Design

The main RIME settings page is organized around schemes first.

Top-level screen:

- Shows one compact row per scheme.
- Each row shows the scheme name, short metadata, current status text, and a compact status icon.
- Tapping a row opens the scheme detail page.
- Deployment status remains on the top-level page. User-facing advanced-input switches live in the main Settings tab so this page can stay focused on schemes.

Scheme detail page:

- Shows scheme source, version, download size, installed state, and capabilities such as Lua requirement.
- Installed schemes can be set as the current scheme.
- Downloaded schemes may expose download, update, redownload, uninstall, and license actions.
- Built-in schemes should not expose destructive download-management actions.
- `rime_ice` may show an "高级输入功能" status section because Lua-backed dynamic candidates are a scheme-specific capability. This section should use plain status copy, not internal RIME terms.

This keeps the top-level page short when more open-source schemes are added.

## Advanced Input Settings

高级输入功能使用「全局偏好 + 当前方案能力」模型，不属于某一个方案详情页的私有设置。

User-facing settings live in the main Settings tab:

- The settings entry is visible even when the current scheme does not support advanced input.
- Feature switches are disabled when the active scheme does not support them.
- Copy should say plain feature names such as 日期与时间、计算器、数字大写、随机编号, not internal terms such as Lua, translator, filter, or processor.
- The settings page should include short "how to use" examples, such as `rq` / `sj` / `xq` / `dt` for date and time candidates, simple expressions for calculation results, and numbers for uppercase or amount-format candidates.
- Each feature row should show concrete input examples when the upstream scheme has a known trigger, such as `R1234.56`, `cC1+2*3`, `uuid`, or `U62fc`.
- The app preserves the user's choices while an unsupported scheme is active. Those choices become controllable and deployable after switching to a supported scheme.

Scheme detail pages may show a compact advanced-input status, but should not duplicate the shared settings entry.
Do not duplicate the full switch list on every scheme detail page.
When adding multiple actions inside a scheme detail status section, keep them as separate Form rows so each row owns a stable tap target.

Current scheme support (productized in Universe today):

- `rime_ice`: supports the advanced-input feature set (fog module names + triggers such as `rq`).
- `luna_pinyin`: does not support these advanced-input features.
- `wanxiang`: **upstream ships its own Lua suite** (e.g. `wanxiang.shijian` with `/rq`·`orq`, `V` calculator) but Universe **does not** map fog product toggles onto 万象 modules. **Product freeze A (2026-08-08):** keep native triggers; settings「怎么使用」follows `RimeSchemeNativeUsageGuide`. Full control/diagnose still [`TD-011`](TECH_DEBT.md#td-011-multi-scheme-lua--advanced-input-compatibility-雾凇--万象) remaining phases.
- **Settings honesty (TD-010):** main-App fuzzy / advanced-input pages gate on layout-bound capability matrix (`RimeSchemeCapabilityMatrix`); unsupported schemes show off/disabled + status copy, preferences preserved.

The main App may inspect already-installed files and shared deployment flags to show:

- `基础检查通过`: engine capability, scheme files, dynamic-input scripts, deployment flags, and basic runtime smoke look ready.
- `未开启`: the user turned off advanced input.
- `安装后可用`: `rime_ice` is not installed.
- `未使用`: `rime_ice` is installed but not the active scheme.
- `需要重新部署`: files are ready, but RIME has not been redeployed with the latest state.
- `暂不可用`: engine support is missing, the scheme file is missing, the scheme was stripped, or dynamic-input files are missing.

Lua file completeness should be inferred from the installed schema's `lua_processor`, `lua_segmentor`,
`lua_translator`, and `lua_filter` references. Avoid maintaining a hard-coded upstream file list in the UI layer;
upstream scheme changes should be visible through diagnostics instead of silently ignored.

Recovery actions stay on the scheme detail page:

- `设为当前方案` for inactive `rime_ice`.
- `重新部署` for pending deployment.
- `重新下载雾凇拼音` when the installed schema or Lua files are incomplete.
- 设置 → 诊断 → 查看记录 for developer-readable details; force_gc schema tools under 诊断 → 高级.

Deployment should derive the effective feature set as:

`user preference` + `active scheme support` + `successful main-App deployment`.

The Keyboard Extension must not evaluate individual feature switches while typing.

## Runtime Boundary

Full RIME deployment remains a main-App responsibility.

- The main App can switch schemes, download scheme files, update metadata, uninstall downloaded schemes, and trigger deployment.
- The Keyboard Extension only opens the already prepared runtime data and creates RIME sessions.
- The Keyboard Extension must not download, update, repair, uninstall, or redeploy schemes while typing.

## Scheme Catalog Infrastructure

Each scheme is described by a catalog entry in the main App code. The catalog is the source of truth for:

- Display metadata: name, description, source, download size, installed size, license name, Lua requirement, and whether candidate learning is supported.
- Download distribution: GitHub owner/repository, release asset name, cached archive file name, and extraction directory name.
- License disclosure: project name, SPDX-style license name, attribution, local modification notice, upstream/source links and an acknowledgement revision.
- Storage keys: installed flag, version, per-scheme license acknowledgement revision, ETag, and checksum keys.
- Installation plan: required schema file, files/directories to skip while installing, files/directories to remove while uninstalling, and build-cache filename fragments to clean.

Downloadable open-source schemes use the generic catalog, distribution, storage, and installation-plan model (`rime_ice`, `wanxiang`, …).

**万象 V1 pin:** GitHub `amzxyz/rime-wanxiang` asset `rime-wanxiang-base.zip`, schema_id `wanxiang`, license CC BY 4.0. Optional grammar `.gram` is **not** auto-installed.

**Grammar model (research only):** “万象语法模型” is the RIME **`.gram`** file from [RIME-LMDG](https://github.com/amzxyz/RIME-LMDG) (e.g. `wanxiang-lts-zh-hans.gram`), loaded via schema `grammar.language`. It can be referenced by **other pinyin schemes** (community: 雾凇/白霜 + same gram) with param tuning; best with 万象词库. Large optional download; needs librime grammar/octagram support + memory budget. Phased plan: [`TD-012`](TECH_DEBT.md#td-012-optional-rime-grammar-model-万象-lmdg--gram-integration).

The user-facing UI should read from `SchemaMetadata`. It should not duplicate package size, license, version, Lua capability, or support flags in the view layer.

### License disclosure contract

- 下载、更新和重新下载必须从所选方案的 catalog entry 取得许可证描述；任何 SwiftUI 页面都不得按方案 ID 硬编码许可证正文。
- 许可证弹窗使用所选方案作为 `.sheet(item:)` 的唯一展示状态，确保弹窗内容、接受动作和随后启动的下载属于同一方案。
- 接受记录绑定 `schemaID + acceptanceRevision`。许可证、来源、署名或本地修改说明发生实质变化时必须提升 revision，旧确认随即失效。
- 旧版布尔确认只可在“旧弹窗确实展示了该方案正确许可证”时迁移。当前仅迁移雾凇；万象曾共用错误的雾凇弹窗，因此必须重新确认。
- 服务层同样在 `startDownload` / `forceRedownload` 前 fail closed；UI 绕过不能直接发起未确认许可证的下载。
- 设置中的“开源软件与内容”是安装后的持久查看入口，列出可选下载方案、内置输入内容和随 App 提供的 RIME 组件；完整许可证与署名资料随 App 打包并可离线阅读，外部来源链接仅作补充。链接由主 App 在用户点击时打开，Keyboard Extension 不访问网络。
- Luna 词典按其实际文件头作为复合内容处理：除 LGPL-3.0 与其引用的 GPLv3 外，单独保留 CC-CEDICT、Android PinyinIME、Chewing、三拼简繁词库与 OpenCC 等来源署名，不把它们错误折叠成单一许可证。

## Toast Feedback

Transient scheme operations should use the shared global bottom toast pattern.

**Target copy** should use the **active scheme display name** from the catalog (雾凇 / 万象 / …), not a single hard-coded brand:

- "正在下载{方案名}… {progress}%" (or indeterminate while progress is unavailable)
- "正在解压{方案名}…"
- "正在部署{方案名}…"
- "{方案名}已下载并部署。"
- "正在应用 RIME 设置..."
- "RIME 设置已应用。"
- Download failures use a Simplified Chinese, actionable category instead of
  presenting an untranslated raw system error as the primary message:
  - network unavailable or unreachable: explain that the network connection is
    unavailable and offer retry/check-network actions;
  - timeout or server/resource temporarily unavailable: identify the temporary
    condition and offer retry/later actions;
  - package integrity verification failure: state that package verification
    failed and require a clean retry; do not mislabel it as a network failure;
  - insufficient storage, extraction or deployment failure: identify the
    corresponding local phase and route to the relevant recovery action;
  - unknown failure: use a localized generic fallback and retain a retry action.

Sanitized diagnostics may retain the error domain/code, URL host and operation
phase for diagnosis. They must not include credentials, private input or
sensitive URL query values. Exact UI copy remains an implementation-Assignment
deliverable and must be verified in Simplified Chinese before the corresponding
release gate closes.

**Toast (TD-009, 2026-08-08):** download phases use catalog scheme display names; progress fraction when known, otherwise indeterminate (no fake 0%).

Scheme rows should show stable status only. Do not add permanent rows for the latest transient operation result.
The top-level app shell owns the toast trigger so feedback is not lost when the user leaves a scheme detail page.
Scheme detail pages should not duplicate download progress once the global toast is available; they may keep durable
failure recovery rows such as retry actions.

## Extension Rule For Future Schemes

When adding a new open-source scheme:

- Add its metadata, distribution, storage keys, and installation plan to the scheme catalog/state model.
- Add a source-verified license descriptor and a new acknowledgement revision; do not reuse another scheme's disclosure.
- Keep its scheme-specific actions inside the scheme detail page.
- Reuse shared buttons and status rows instead of one-off styling.
- Keep global preferences, such as candidate count and simplification, outside individual scheme details unless the preference is genuinely scheme-specific.
- If the scheme has user dictionary learning support, connect it through the per-scheme candidate-learning model documented in `docs/RIME_USER_DICTIONARY.md`.
- Add tests for catalog metadata, version/update comparison, install/uninstall cleanup, and any special skip rules before exposing the scheme in the UI.
