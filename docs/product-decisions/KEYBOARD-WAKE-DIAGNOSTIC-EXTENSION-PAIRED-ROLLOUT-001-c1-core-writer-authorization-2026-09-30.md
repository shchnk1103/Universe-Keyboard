# C1 five-file Core writer implementation authorization

2026-09-30 Asia/Shanghai。Human Product Owner 原文：“授权只做 C1 五文件切片，之后这个线程你都可以自行决定是否使用 subagent。”

本次承接已说明的 C1 五文件本地实施、strict format/lint、隔离 host KeyboardCore focused/full package验证与 owning Assignment / 阶段 Authorization、Entry、evidence记录。精确五路径及pre-edit hashes见阶段Entry；不扩充到WireValidator、既有reader测试、主App、Extension、工程或其他source。

生产默认writer-v5、公有默认构造和reader3/4/5/6兼容保持；v6仅为静态显式selector及临时测试。C1实现Runtime→Ingress→Journal版本传递和三个typed marker API，所有v6 writer新事件（包括typo_recall/health/既有payload）统一v6，保留历史字节、严格code/payload/origin/fields规则、原异步有界写入与锁/背压语义。不增加真实Extension producer或capture gate，不用JSON/文件I/O构造热路径事件。

阶段顺序：本C1仅Core领域ACK、当前Executor输入/写入窗口及来源核验先完成；Core实施与host验证现在执行。C2的生产callsite、paired build version绑定、独立Architecture/Quality exact-candidate评审、full CI与新鲜Simulator预约、promotion/install/Maps作为未来命名依赖，global Entry/Exit不因此成立。不自动沿用Stage B30skip接受。

复用原Core领域作者 /root/core_stage_a GPT6 Luna，scratch草拟/测试；root唯一repo source/docs writer。作者不是独立reviewer，不占用已结束Architecture/Quality review预算，不Reassign永久DomainOwner。后续使用subagent由root自主决定，但不扩展授权范围。

不授权C2、真实AppGroup写入、Simulator、安装、Maps、网络/下载、Release/Gate/parentclosure、Git stage/commit/push/PR/merge；保留所有既有dirty，仅五source/test与owning阶段docs写入。
