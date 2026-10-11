# ARCH-C7-UI-CANDIDATE-BINDING R1

状态：**Complete / Positive（限本轮 artifact binding 与局部 impact）**。Packet SHA-256 `1aa7200ae5f93243fe3619649c994fe395eae3c0985dba8db7ccd0a6a1cdc3f6` 已核对。基线 `codex/keyboard-wake-v3-compatibility-gate` / `84b9c19227330b0fe6ff391be001ee398010fd6a`；candidate `43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50`。

| Criterion | 结果 | 独立证据 |
|---|---|---|
| A1 | Covered | 19/19 内容输入、1201/1201 hash-only 输入及 78/78 payload SHA 匹配。最终 App/Keyboard executable SHA 分别为 `7ecd73750fa88485447ec25aaae5887e6da6d91cf35a430305c620cf85b1259e` / `237d9a890d96a18ebaa9427ac2836595d8e8fc7767be63712a6870a22643efe0`，均匹配 allowlist。自写 Mach-O64 load-command parser 解析 arm64、LC_UUID 与原始 `__TEXT,__entitlements` section；App offset/size 13432/414，Keyboard 10282/423。原始 bytes 分别与归档及 packet-listed generated xcent 完全相等，SHA 为 `6610a8c02dfe5b877f5be595941b807a687c7838e2f4b54a80b4c6726b821a6c` / `1b5eca79f033b12423739696ae50c8dfcd679ed6484803e2e340787aee149b7b`；App Group 与 application-identifier 均与对应 xcent 相同。 |
| A2 | Covered | 四项 binding（manifest `0c2ab27d…e8d47d61`、command `6e7dd9cc…e907cddca`、payload `784c0569…fe422aca`、entitlement rows `920e7844…34e15ea1`）重算匹配；规范化 binding SHA 得 candidate `43d85d…6220ba50`。App 与 appex Info bundle/version/build 为 `com.DoubleShy0N.Universe-Keyboard`、`com.DoubleShy0N.Universe-Keyboard.Keyboard`，均 1.0/build 1；`codesign --verify --deep --strict` 均 exit 0。6/6 Mach-O SHA、我解析的 LC_UUID 与 `dwarfdump --uuid` 匹配：Keyboard `C3FC7115-4215-3801-ABBB-C8A648ED0C32` / `77BD18E2-E090-37D7-865F-84D762E69F70` / `984A99F0-EDBC-3181-8D6A-151FC3FF26B3`；App `8DD28672-CD37-3408-93FB-C3CA3F4465E9` / `742720C7-983C-38A6-BE2E-76AD327EEA30` / `3157B785-8C10-368F-A3C4-DB591625C61D`。 |

局部 diff 仅在 `KeyboardViewController+Presentation.swift:94,139,155` 新增三个 `refreshWakeOwnerProbeControls()` 调用，各处均受 `DEBUG && KEYBOARD_WAKE_OWNER_PROBE` 条件编译保护；限定 diff 未改 RIME、部署或并发合同。旧 Partial 不变。本意见不代表 runtime、安装、Product Gate 或 Release 通过；未做设备、Simulator、构建、测试或 repo 写入。
