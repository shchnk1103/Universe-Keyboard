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
- Global RIME preferences and deployment status remain on the top-level page because they are not owned by a single scheme.

Scheme detail page:

- Shows scheme source, version, download size, installed state, and capabilities such as Lua requirement.
- Installed schemes can be set as the current scheme.
- Downloaded schemes may expose download, update, redownload, uninstall, and license actions.
- Built-in schemes should not expose destructive download-management actions.

This keeps the top-level page short when more open-source schemes are added.

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

- "正在应用 RIME 设置..."
- "RIME 设置已应用。"
- "下载失败，请稍后再试。"

Scheme rows should show stable status only. Do not add permanent rows for the latest transient operation result.

## Extension Rule For Future Schemes

When adding a new open-source scheme:

- Add its metadata, distribution, storage keys, and installation plan to the scheme catalog/state model.
- Keep its scheme-specific actions inside the scheme detail page.
- Reuse shared buttons and status rows instead of one-off styling.
- Keep global preferences, such as candidate count and simplification, outside individual scheme details unless the preference is genuinely scheme-specific.
- If the scheme has user dictionary learning support, connect it through the per-scheme candidate-learning model documented in `docs/RIME_USER_DICTIONARY.md`.
- Add tests for catalog metadata, version/update comparison, install/uninstall cleanup, and any special skip rules before exposing the scheme in the UI.
