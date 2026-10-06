# C7 UI H2 host Entry

Human授权“执行H2吧”。root Environment Executor唯一repo writer；scope仅普通Debug/Release generic Simulator SDK配对构建及probe UI/出口排除证据，无test/device/install/runtime/LLDB/Maps/Release发布。

原worktree、branch codex/keyboard-wake-v3-compatibility-gate、HEAD84b9c19227330b0fe6ff391be001ee398010fd6a已确认。H1冻结source571/Vendor630逐项匹配。旧C7-B1有Presentation.swift和T9PinyinPathTests.swift两项内容差异，不复用旧build结果；本次两模式重新构建。before2860文件/full dirty777/staged0完整保存在private scratch，不清理旧改动。

工具链沿H1 Xcode27.0/SDK27.0/Swift6.4，同语言6和warnings-as-errors，arm64及ad-hoc签名；普通Debug保留DEBUG但移除KEYBOARD_WAKE_OWNER_PROBE，Release不追加DEBUG/probe，核实际compiler line。两模式全新独立DerivedData与xcresult，复用H1已解析SourcePackages路径，不resolve/update下载。scratch /private/tmp/ukey-wake-probe-ui-h2-20261002，预记录结构化argv保持literal inherited。

Exit：两build实际exit/log/xcresult与每个MachO UUID/hash/nm核验，普通Debug/Release不得含installWakeOwnerProbeButton/wakeOwnerProbeExportReady，H1专用模式作阳性对照。普通Debug Core DEBUG hooks可保留且默认未arm，不把它们当成UI/导出入口或零开销证明。输入漂移、缺失、构建失败、nm读取失败或排除条件不满足则停止，不猜修。当前Entry无必需UNKNOWN；后续Q/T/I/U/M仍独立授权与fresh Entry。
