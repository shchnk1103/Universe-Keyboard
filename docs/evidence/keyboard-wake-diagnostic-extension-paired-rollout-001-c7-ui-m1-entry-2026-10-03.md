# M1 新实例与Maps入口 Entry — 2026-10-03

Human明确仅授权M1并确认原模拟器独占；已在Maps空搜索框叫出Universe Keyboard，“观测”按钮可见、完全访问开启。root仅只读核设备／进程／安装产物／有限配置／M0备份，未操作UI、发送信号、启动或终止进程、LLDB、arm或输入。

工作树branch codex/keyboard-wake-v3-compatibility-gate、HEAD84b9c19227330b0fe6ff391be001ee398010fd6a；1279源输入无漂移。设备405D994F-28CB-4F89-BB22-B64AD81C05A2 iPhone18Pro/iOS27.0 Booted。精确新PID3626在原UDID/原容器下，执行路径及SHA237d9a…匹配，旧已消费88188未复用；进程非调试暂停，开头/收尾同一PID。已装78文件、6MachO SHA/UUID、main/appex strict签名均匹配固定43d85d…，容器与M0一致。Maps version1.0/build2972.30.6.12.58；系统Maps executable路径不单独证明PID的UDID，宿主UI由Human原设备确认绑定。

两诊断键当前ABSENT/off，rime_deployed=true、rime_needs_deploy=false、rime_is_deploying ABSENT。配置rime_active_schema缺省，对应SchemaManager默认luna_pinyin；26键slot绑定luna_pinyin，keyboard_layout_style缺省，对应默认twentySixKey。它们是配置而非runtime realized engine schema；本M1不附加调试器读取内部状态。M0备份956文件摘要及结构/链接再次核验，无缺失；该备份是M启动前恢复点，不声称Maps启动后所有live数据未改。

阶段依赖明确：已安装MachO身份在M1核验；**实际loaded路径/UUID、explicit session及自身断点**需M2单独授权后、arm之前核验，当前UNKNOWN。当前还待Human只看确认26键／空候选／仍观测／未点击未输入；不能把配置默认值代人工界面实测。M1最终入口核验未齐之前不进入M2 Ready，M2尚未授权。

## Human视觉入口补齐

Human回复“确认”，对应已下发只看问题：26键拼音字母布局、空候选、仍观测、本轮未点击未输入。M1范围入口／核验已齐；只将本M1记完成，不填runtime engine schema/loaded UUID为实测，不进入M2 Ready。
