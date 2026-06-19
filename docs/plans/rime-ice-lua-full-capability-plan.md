# 雾凇拼音 Lua 完整能力实施计划

> 日期：2026-06-18
> 状态：进行中；阶段 1/2 已完成，阶段 6 状态与恢复子集已完成，真实 Lua smoke test 尚未完成

## 目标

让 Universe Keyboard 支持雾凇拼音的完整 Lua 能力，而不是只针对 `rq` 做特例。

用户层目标：

- 用户能在主 App 中理解「雾凇拼音增强功能」是什么。
- 用户能看到当前设备是否支持这些增强功能。
- 用户能开启或关闭增强功能，并知道开启后需要重新部署 RIME。
- 当增强功能不可用时，主 App 给出普通用户能理解的说明，而不是暴露 `librime-lua`、`lua_translator` 等内部术语。

技术层目标：

- `rime_ice` 的 Lua processor / translator / filter 能按上游 schema 正常加载。
- `lua/` 目录和相关依赖文件在支持 Lua 时完整安装。
- 主 App 部署阶段和 Keyboard Extension 输入阶段对 Lua 模块的加载策略一致。
- 输入 `rq`、`sj`、`xq`、`dt`、`ts`、`rqzh`、`rqen` 等雾凇日期时间触发词时产生动态候选。
- 计算器、数字金额大写、Unicode、农历、UUID、候选过滤等雾凇 Lua 能力不被我们的安装或后处理破坏。

## 当前事实

本计划基于 2026-06-18 的阅读结果：

- RIME vendor 清单已经包含 `librime-lua.xcframework` 和 `liblua.xcframework`。
- `RimeSessionManager` 在 `RIME_HAS_LUA` 下会把 `"lua"` 加入输入 session 的模块列表。
- `RimeDeployer` 已在 `RIME_HAS_LUA` 下和 `RimeSessionManager` 一样加载 `"lua"`，并有测试保护部署模块列表。
- `rime_ice` catalog 标记为 `requiresLua: true`，并且安装计划有 `luaDirectoryPrefix: "lua/"`。
- 当 `rime_lua_available == false` 时，下载后处理会剥离 `lua_translator` / `lua_filter` / `lua_processor`，安装器也会跳过 `lua/` 目录。
- 内置 `luna_pinyin` schema 没有挂载 Lua 日期 translator，所以当前使用内置方案时 `rq` 不出日期是符合现状的。
- 项目文档仍记录「完整 Lua 行为需要真实 schema smoke test」。

## 当前进度

2026-06-18：

- 已增加主 App 侧 `RimeLuaCapabilityDiagnostic`，可区分未安装、未切换到雾凇、引擎不可用、schema 缺失、schema 已被剥离、Lua 文件缺失、需要重新部署、可用等状态。
- 诊断只读取 App Group 中已安装的 schema 和 `lua/` 文件，不调用会写文件的部署目录准备逻辑，也不进入 Keyboard Extension 输入热路径。
- 已暴露 `RimeBridgeCapabilities`，用于确认 ObjC 桥接层是否启用 Lua，以及主 App 部署器实际传给 librime 的模块列表。
- 已修正 `RimeDeployer`，在 `RIME_HAS_LUA` 下加载 `"lua"`，使主 App 部署阶段与 Keyboard Extension session 阶段的基础模块一致。
- 已补充 `RimeBridgeTests` 和 `SchemaManagerTests` 覆盖上述能力探测、部署模块列表和主要诊断状态。
- 已在雾凇拼音详情页增加 `高级输入功能` 状态区，展示基础检查、未安装、未使用、需要重新部署、暂不可用等普通用户文案。
- 已提供 `设为当前方案`、`重新部署`、`重新下载雾凇拼音` 和 `查看诊断日志` 等恢复入口。
- 状态文案保持保守：即使文件与部署标记完整，也只显示 `基础检查通过`，不在真实 Lua smoke test 前宣称动态候选已可用。
- 已将 Lua 文件完整性诊断扩展为从 `rime_ice.schema.yaml` 的 `lua_processor` / `lua_translator` / `lua_filter` 引用反推 `lua/*.lua` 文件，不只检查单个日期脚本。
- 已让重新下载雾凇拼音前清理安装计划声明的相关 RIME build cache，降低旧编译产物影响恢复的风险。
- 已增加 iOS Simulator 可运行的真实 Lua smoke test 骨架；没有提供 runtime fixture 时自动跳过，提供 `UK_RIME_LUA_SMOKE_SHARED_DIR` / `UK_RIME_LUA_SMOKE_USER_DIR` 后会测试 `rq`、`sj`、`xq`、`dt`、`ts`、`R123`、`cC1+1`。
- 尚未完成真实 `rime_ice` Lua smoke test；因此 `rq` / `sj` / `xq` / `dt` / `ts` 等真实动态候选仍不能标记为已验收。

## 非目标

- 不在 KeyboardCore 中硬编码 `rq -> 日期候选`。这会绕过 RIME schema，破坏雾凇自定义触发词和候选排序模型。
- 不在 Keyboard Extension 输入热路径下载、修复、复制、部署 schema。
- 不把雾凇上游 schema 改写成一个本项目私有 fork，除非只做必要的兼容补丁且有测试覆盖。
- 不在设置页展示内部实现名，例如 `lua_translator`、`RIME_HAS_LUA`、`librime-lua`。

## 用户体验方案

### 主 App 展示位置

建议放在：

- `设置 > RIME 方案设置 > 雾凇拼音详情`

原因：

- Lua 增强能力是雾凇方案自己的能力，不是所有 schema 的通用设置。
- `docs/RIME_SCHEME_MANAGEMENT.md` 已规定方案专属能力放在方案详情页。

### 开关命名

建议开关标题：

- `高级输入功能`

辅助说明：

- `开启后可输入日期、时间、计算器、数字大写等动态候选。`

不可用状态说明：

- `当前版本的键盘引擎未启用高级输入功能，请更新 App 后重试。`

需要重新部署时的提示：

- `更改后需要重新部署。`

下载前说明：

- `雾凇拼音包含更多词库和高级输入功能，首次启用需要下载并应用。`

### 状态展示

建议主 App 用三个普通用户能理解的状态：

- `可用`：引擎支持 Lua，schema 安装完整，增强功能开关开启，最近一次烟测通过。
- `未开启`：引擎支持 Lua，schema 安装完整，但用户关闭了增强功能。
- `需要重新部署`：设置或 schema 文件变化后，还没有重新部署。
- `暂不可用`：引擎不支持 Lua、schema 文件缺失、部署失败或烟测失败。

内部日志可以继续保留真实原因：

- `lua module not loaded`
- `date_translator.lua missing`
- `rime_ice.schema.yaml missing lua_translator@*date_translator`
- `rq smoke test produced no date candidate`

## 架构原则

第一性原理拆解：

- 输入：用户按键序列，例如 `rq`。
- 状态：当前 active schema、schema YAML、Lua 脚本文件、RIME build cache、用户设置、部署标记。
- 副作用：主 App 下载/安装/部署文件；Keyboard Extension 只创建 session 并处理输入。
- 输出：RIME 候选列表中出现动态候选。

因此实现必须分层：

- 主 App：下载、安装、写设置、部署、烟测、展示状态。
- Keyboard Extension：读取已部署结果、创建 session、处理按键。
- KeyboardCore：保留纯逻辑和可测试后处理，不直接理解某个 Lua 功能的业务含义。
- RimeBridge：提供部署、session、schema 选择、烟测所需的最小桥接 API。

## 实施阶段

### 阶段 1：能力探测与诊断（已完成最小实现）

目标：先证明当前环境到底缺在哪一层。

任务：

- 增加主 App 侧 Lua 能力诊断模型。
- 诊断以下项目：
  - vendor 是否包含 `librime-lua` / `liblua`。
  - `RIME_HAS_LUA` 编译宏是否生效。
  - 部署器是否加载 `"lua"` 模块。
  - `rime_lua_available` 当前持久化值。
  - `rime_ice.schema.yaml` 是否包含 Lua processor / translator / filter。
  - `lua/date_translator.lua` 及其依赖是否存在。
  - active schema 是否为 `rime_ice`。
- 诊断结果写入开发日志和主 App 内部状态，不进入键盘热路径。

完成标准：

- 在诊断日志里能明确区分「引擎不支持」「schema 被剥离」「Lua 文件缺失」「未重新部署」「烟测失败」。
- 不改变用户输入行为。

### 阶段 2：部署器 Lua 模块一致性（已完成）

目标：主 App 部署阶段和 Keyboard Extension session 阶段加载同样的基础模块。

任务：

- 评估 `RimeDeployer` 是否应在 `RIME_HAS_LUA` 下加载 `"lua"`。
- 如果需要，调整部署器模块列表，使含 Lua 组件的 schema 能在部署阶段被正确编译。
- 保留 `rime_lua_available` 作为实际能力状态，但避免它被旧部署结果误导。

完成标准：

- `rime_ice` 完整 schema 可部署成功。
- 部署失败时主 App 显示普通用户可理解错误，日志保留内部原因。
- 不影响 `luna_pinyin` 部署。

### 阶段 3：安装策略与后处理收敛（完整性诊断与恢复缓存清理已完成）

目标：支持 Lua 时完整安装雾凇；不支持 Lua 时有明确降级策略。

任务：

- 确认 `rime_lua_available` 默认值和写入时机，避免首次下载前误判。
- 支持 Lua 时：
  - 不剥离 Lua processor / translator / filter。
  - 不跳过 `lua/` 目录。
  - 保留雾凇 schema 的完整能力。
- 不支持 Lua 时：
  - 不宣传「高级输入功能」可用。
  - 可以保留现有剥离/最小 schema 降级，但 UI 必须说明高级功能暂不可用。
- 对旧安装状态做兼容：
  - 如果发现旧版已经剥离 Lua，需要提示重新下载或自动重新下载。
  - 清理旧 build cache，避免继续加载旧编译产物。

完成标准：

- 新下载的 `rime_ice` 在支持 Lua 时保留完整 Lua 配置和 `lua/` 文件。
- 旧剥离安装能被识别并恢复。

### 阶段 4：主 App 用户开关

目标：让用户控制雾凇增强功能，同时不暴露内部术语。

任务：

- 在雾凇方案详情页增加 `高级输入功能` 开关。
- 开关只控制雾凇增强能力，不影响内置 `luna_pinyin`。
- 开关关闭时，通过 schema custom YAML 或受控补丁禁用 Lua 增强组件。
- 开关开启时，恢复完整雾凇 Lua 组件。
- 切换后标记 `rime_needs_deploy = true`，并引导用户重新部署，或沿用现有自动部署模式。

完成标准：

- 用户可以开启/关闭增强功能。
- 开关文案普通用户可理解。
- 设置变化不会在 Keyboard Extension 输入热路径中写文件。

### 阶段 5：真实 Lua 烟测（测试骨架已完成，真实 runtime 待执行）

目标：用真实 RIME bridge 验证能力，而不是只看文件。

任务：

- 增加一个 iOS Simulator 可运行的 RIME Lua smoke test。
- 测试输入：
  - `rq`：应出现当天日期的多种格式。
  - `sj`：应出现当前时间。
  - `xq`：应出现星期。
  - `dt`：应出现日期时间。
  - `ts`：应出现时间戳。
  - `R123`：应出现数字/金额大写候选。
  - `cC1+1`：应出现计算器候选。
- 测试不应该依赖固定日期字符串，日期类用当天日期格式匹配。
- 测试完成后清理 composition/session 状态。

完成标准：

- smoke test 能在本地 simulator 通过。
- 失败时能定位到部署、schema、Lua 文件或候选输出。

### 阶段 6：设置页状态与错误恢复（状态与恢复子集已完成）

目标：让普通用户知道该怎么处理。

任务：

- 在雾凇详情页展示增强功能状态。
- 下载/部署失败时给出可操作动作：
  - `重新部署`
  - `重新下载雾凇拼音`
  - `查看诊断日志`
- 如果完整能力缺失但基础输入可用，状态应区分：
  - `基础输入可用`
  - `高级输入功能暂不可用`

完成标准：

- 用户不需要理解 Lua，也能知道功能是否可用和下一步该点什么。
- 开发者能从日志还原真实失败原因。

### 阶段 7：文档与发布验收

目标：把能力边界写进项目文档，避免后续回归。

任务：

- 更新 `docs/RIME_SCHEME_MANAGEMENT.md`：
  - 记录雾凇增强功能开关。
  - 记录状态展示和部署边界。
- 更新 `docs/architecture/swift6-manual-acceptance.md`：
  - 补上 Lua-enabled schema smoke test 结果。
- 如代码改动完成，更新 `CHANGELOG.md`。

完成标准：

- 文档与实际 UI/行为一致。
- 发布前验收矩阵不再把 Lua smoke test 标为 blocked。

## 测试计划

### Lua smoke test 使用说明

当前 `RimeBridgeTests` 中已有可选真实 Lua smoke test：

```bash
UK_RIME_LUA_SMOKE_SHARED_DIR=/path/to/Rime/shared \
UK_RIME_LUA_SMOKE_USER_DIR=/path/to/Rime/user \
xcodebuild test \
  -project "Universe Keyboard.xcodeproj" \
  -scheme RimeBridgeTests \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:RimeBridgeTests/RimeLuaSmokeTests
```

目录要求：

- `UK_RIME_LUA_SMOKE_SHARED_DIR` 指向已安装并部署过的 RIME shared 目录。
- 该目录至少包含 `rime_ice.schema.yaml` 和 `lua/date_translator.lua`。
- `UK_RIME_LUA_SMOKE_USER_DIR` 指向对应的 RIME user 目录。

结果解释：

- `SKIP`：没有提供 runtime 目录，或目录不完整；这不代表功能失败。
- `PASS`：真实 `rime_ice` session 对 smoke test 输入产生了预期候选。
- `FAIL`：真实 session 没有产生预期候选，需要结合主 App 诊断状态、部署日志和 schema 文件继续定位。

单元测试：

- `RimeConfigPostProcessor`：
  - 支持 Lua 时不剥离。
  - 不支持 Lua 时剥离完整且 schema 仍可用。
  - 旧剥离 schema 可识别。
- Schema catalog：
  - `rime_ice.requiresLua == true`。
  - 安装计划在 Lua 可用时不跳过 `lua/`。
  - 安装计划在 Lua 不可用时跳过 `lua/` 并降级。
- 设置模型：
  - 开关变更会标记需要部署。
  - 状态文案和内部原因映射正确。

集成测试：

- RIME deployer 在 Lua 可用时可部署完整 `rime_ice`。
- RIME session 选择 `rime_ice` 后，`ni` 仍有基础候选。
- 输入 `rq` 后产生日期候选。
- 输入 `sj` / `xq` / `dt` / `ts` 后产生动态候选。

手动验收：

- 主 App 下载雾凇。
- 开启高级输入功能。
- 应用 RIME 设置。
- 在键盘中切换到雾凇拼音。
- 输入 `rq`，候选栏出现当天日期。
- 关闭高级输入功能并重新部署，`rq` 不再出现日期候选，但基础拼音仍可输入。
- 重新开启后恢复。

性能检查：

- 下载、解压、后处理、部署只在主 App 发生。
- Keyboard Extension 启动只创建 session，不做文件扫描、下载或部署。
- 按键热路径不增加同步文件 IO。

## 风险与应对

风险：部署器不加载 `"lua"` 导致完整 schema 部署失败。

应对：阶段 2 优先验证并修正部署器模块列表。

风险：上游雾凇 schema 变更导致我们基于字符串的剥离/修复误伤配置。

应对：尽量减少后处理；支持 Lua 时保留上游原样；必要补丁采用可测试的托管 block 或结构化 YAML 处理。

风险：Lua 功能依赖的脚本文件不止 `date_translator.lua`。

应对：支持 Lua 时完整安装 `lua/` 目录，不做按文件白名单裁剪。

风险：用户关闭增强功能后，schema custom YAML 补丁难以干净禁用所有 Lua 组件。

应对：优先选择最小可维护策略。若不能安全 patch，上层开关可先定义为「启用完整雾凇增强能力 / 使用基础兼容模式」，通过重新安装或受控 schema 替换实现。

风险：日期时间测试受时区和当天日期影响。

应对：测试使用当前本地日期格式匹配，不写死具体日期。

## 建议执行顺序

1. 先做阶段 1 + 阶段 5 的最小诊断/烟测骨架，确认当前失败点。
2. 如果失败点是部署器模块列表，先做阶段 2。
3. 修正安装与旧状态恢复，完成阶段 3。
4. 做主 App 开关与状态文案，完成阶段 4 + 阶段 6。
5. 最后补齐文档和验收记录，完成阶段 7。

## 每阶段交付格式

每完成一个阶段，需要记录：

- 改了什么。
- 为什么这样改。
- 验证了什么。
- 哪些验证未执行及原因。
- 是否需要更新 `CHANGELOG.md` 或架构文档。
