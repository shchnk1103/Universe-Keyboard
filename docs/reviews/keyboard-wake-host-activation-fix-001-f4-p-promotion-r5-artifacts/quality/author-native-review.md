按 root 转交的 flat reader 原文逐条比对，四条记录的 Original stdout 路径、Paired stdout 路径和 argv[-1] 完全相同；UUID 两两相同；每条 Universe Keyboard.app/ 后缀都与 Module 完全一致；Candidate SHA 与 Paired SHA 也相同：

| Module | UUID | 完整路径 | Candidate SHA = Paired SHA |
|---|---|---|---|
| Universe Keyboard | 664DE45A-5859-34F1-892C-3DD2D9DE7B98 | /private/tmp/ukey-host-activation-fix-f4-p-build-20261005/CandidateDerivedData/Build/Products/Debug-iphonesimulator/Universe Keyboard.app/Universe Keyboard | 38cbdd01d7b664db0c435452086dd209447135f886906bab8181610a6a7e6feb |
| Universe Keyboard.debug.dylib | C19CE509-A814-30AB-88F1-CE5416FDDC33 | /private/tmp/ukey-host-activation-fix-f4-p-build-20261005/CandidateDerivedData/Build/Products/Debug-iphonesimulator/Universe Keyboard.app/Universe Keyboard.debug.dylib | c00095f4d2016cf31b876ed5f3f17f53c5ec97d64704829b629d23ab7a57e200 |
| PlugIns/Keyboard.appex/Keyboard | CD0C6F02-6094-3726-B598-F03F42ABB468 | /private/tmp/ukey-host-activation-fix-f4-p-build-20261005/CandidateDerivedData/Build/Products/Debug-iphonesimulator/Universe Keyboard.app/PlugIns/Keyboard.appex/Keyboard | e681da52516441c044c98419a7c9750d7a90b282cb69bd27e220284376922860 |
| PlugIns/Keyboard.appex/Keyboard.debug.dylib | 4B207746-89A7-321F-83C4-91477259BB26 | /private/tmp/ukey-host-activation-fix-f4-p-build-20261005/CandidateDerivedData/Build/Products/Debug-iphonesimulator/Universe Keyboard.app/PlugIns/Keyboard.appex/Keyboard.debug.dylib | 773c4eff9640b2623036e3f819301ead3914cb99b66c9c1496ece5986e762aab |

据此，Q-P1 的完整路径绑定与一致性检查可判 Covered；R3 的 Uncovered 标签可针对这一项由本轮结论 supersede，R3 历史文件保持不变。结论只涉及转交文本中的静态记录，不代表我现场读取或验证了 flat reader 文件，也不支持 runtime、安装 Ready、Maps 或 Release 结论。standalone 与 Q-P2/3/4 不在本次判断内。

允许 root 机械保存这份 native 判断和调用账本，但须标明依据是转交的平文及其所报 SHA 3b4d849c172d5dfc3325c2bb789dd567a3e854de67963557b3f31875e2a9de69，不能标成我现场读取、写入或读回成功。实际工具调用为 2（1 个 wrapper、1 个嵌套命令）；开始时间记录为 2026-10-05T05:12:52.806117Z，结束时间未单独采集。ACK 写入失败，因此正式交付仍为 Partial，待收件方决定。
