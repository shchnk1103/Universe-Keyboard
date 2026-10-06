# QUALITY-C7-UI-CANDIDATE-BINDING R2

独立只读复审；旧R1缺报告/usage，仍为Partial，本轮不倒补旧账。身份：branch `codex/keyboard-wake-v3-compatibility-gate`，HEAD `84b9c19227330b0fe6ff391be001ee398010fd6a`，candidate `43d85d612af6c606b5434dcb0a989e43e3c472bf6f296df3bd7c2fcb6220ba50`。packet摘要匹配；34内容、230构建产物、1201仓库hash-only共1465项均匹配。

|准则|结论|独立核验|
|---|---|---|
|Q1|Covered|571 source/Vendor 630 canonical与build摘要重算；manifest输入对应1201哈希。patch只有Presentation单文件3处DEBUG+probe内的候选bar刷新。|
|Q2|Covered|H1 Debug+probe正控；普通Debug仅DEBUG、Release无DEBUG/probe。3组实际编译行均Swift 6/warnings-as-errors且build/xcresult成功；普通6+2 Mach-O无12类UI/出口符号。|
|Q3|Covered|四项candidate绑定、78项H1 payload、6个Mach-O SHA/UUID、paired Info/签名；H2 Debug 78与Release 74 payload逐项匹配，无test-host。|

结论：Complete; Positive scoped artifact-binding review。仅host artifact绑定意见，不代表测试、安装、设备运行、dSYM可读性或Product/Gate通过；旧Partial/skip/runtime边界保留。原始日志含AppIntents元数据提取提示，xcresult无构建错误/警告。