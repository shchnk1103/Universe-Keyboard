# Environment Digest Tool

`ENV-TOOLING-001` 的非 shipping、只读工程工具。合同语义由
[`docs/ENVIRONMENT_DIGEST_TOOLING.md`](../../docs/ENVIRONMENT_DIGEST_TOOLING.md) 唯一定义。

## 文件系统 Profile

从仓库根目录构建：

```sh
swift build --package-path Packages/EnvironmentDigestTool -c release
```

显式调用示例：

```sh
swift run --package-path Packages/EnvironmentDigestTool environment-digest \
  --profile schema \
  --root <authorized-existing-root> \
  --environment-identity <capture-bound-identity> \
  --provenance deployed-runtime \
  --authorized-caller <caller> \
  --source-classification verified_manifest \
  --implementation-commit <40-character-lowercase-commit>
```

支持的文件系统 profile 为 `schema`、`shared-runtime`、`user-configuration` 和
`effective-configuration`。Canonical manifest 写入标准输出；provenance envelope 和 exclusion
report 写入标准错误。调用方负责将两者写到输入根目录以外的 evidence archive，并计算或核对
工具返回的实际 SHA-256。工具不会发现 App Group、创建输出目录或将 fixture 提升为 Runtime Evidence。

`shared-runtime` 中的 `custom_phrase.txt` 只有在调用方已经验证其为冻结部署资产时，才可同时提供
`--custom-phrase-approval-authority <authority>` 和
`--custom-phrase-approval-evidence <evidence-reference>`。批准主体、证据引用及 environment identity
会进入 provenance envelope；缺少任一字段或 identity 不一致均 fail closed。

## Clean-state Profile

`clean-state` 通过 `EnvironmentDigest` library 的 `digestCleanState` 显式调用。调用方必须提供合同
定义的完整 typed fact 集、每个字段的 Template provenance、同一 environment identity、实现 commit
和 `.controlledFixture` 或 `.captureBound` evidence classification。该 API 不接收文件系统根目录，
也不会读取 preferences、session memory 或真实用户数据。

## 004C-R1 边界

后续 004C-R1 必须先获得独立 Assignment Revalidation，再绑定新 Run ID 和真实部署根目录调用本工具。
本 Package 的测试结果仅证明 capability，不是 Environment Capture、Benchmark 或 Task 7 Evidence。
