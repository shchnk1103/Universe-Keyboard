# RIME Scheme Management

This document records the product and implementation boundary for RIME multi-scheme management in the main App.

## Scope

RIME scheme management V1 supports a scalable settings structure for the built-in/default scheme and downloaded open-source schemes:

- `luna_pinyin`
- `rime_ice`

Future schemes should be added to the same list-and-detail model instead of creating separate top-level settings blocks for each scheme.

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

Current scheme support:

- `rime_ice`: supports the advanced-input feature set.
- `luna_pinyin`: does not support these advanced-input features.

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
- `查看诊断日志` for developer-readable details.

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
- Storage keys: installed flag, version, license acceptance, ETag, and checksum keys.
- Installation plan: required schema file, files/directories to skip while installing, files/directories to remove while uninstalling, and build-cache filename fragments to clean.

V1.1 intentionally keeps `rime_ice` as the only downloadable open-source scheme, but its management path now goes through the generic catalog, distribution, storage, and installation-plan model.

The user-facing UI should read from `SchemaMetadata`. It should not duplicate package size, license, version, Lua capability, or support flags in the view layer.

## Toast Feedback

Transient scheme operations should use the shared global bottom toast pattern.

Examples:

- "正在下载雾凇拼音..."
- "正在解压雾凇拼音..."
- "正在部署雾凇拼音..."
- "雾凇拼音已下载并部署。"
- "正在应用 RIME 设置..."
- "RIME 设置已应用。"
- "下载失败，请稍后再试。"

Scheme rows should show stable status only. Do not add permanent rows for the latest transient operation result.
The top-level app shell owns the toast trigger so feedback is not lost when the user leaves a scheme detail page.
Scheme detail pages should not duplicate download progress once the global toast is available; they may keep durable
failure recovery rows such as retry actions.

## Extension Rule For Future Schemes

When adding a new open-source scheme:

- Add its metadata, distribution, storage keys, and installation plan to the scheme catalog/state model.
- Keep its scheme-specific actions inside the scheme detail page.
- Reuse shared buttons and status rows instead of one-off styling.
- Keep global preferences, such as candidate count and simplification, outside individual scheme details unless the preference is genuinely scheme-specific.
- If the scheme has user dictionary learning support, connect it through the per-scheme candidate-learning model documented in `docs/RIME_USER_DICTIONARY.md`.
- Add tests for catalog metadata, version/update comparison, install/uninstall cleanup, and any special skip rules before exposing the scheme in the UI.
