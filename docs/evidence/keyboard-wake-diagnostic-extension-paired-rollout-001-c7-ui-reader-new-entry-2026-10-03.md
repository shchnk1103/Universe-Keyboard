# C7 UI 更换独立审查者 / reader先行 Entry

Human明确授权更换独立审查者，先核清reader，再完成同一candidate A1/A2。新GPT6 Luna runtime arch_reader_candidate未参与源码/reader实现、构建或旧review；root唯一repo writer，root提供只读reader但不替代独立审查。新lane ARCH-C7-UI-READER-AND-CANDIDATE round1见[先冻结packet](../reviews/c7-ui-reader-candidate-architecture-r1-packet-2026-10-03.json)，不是续旧R3预算。

原worktree/branch/HEAD和candidate43d85d…全相同；旧24内容、78payload、2generated xcent、1201source/Vendor hash-only均匹配。新reader.py/newEntry/R3stop receipt追加已固定hash。before2926files/dirty843/staged0在private scratch保全，无必需UNKNOWN。

顺序：R0独立静态核reader路径→SHA合同、MachO字段位置、边界/唯一UUID及原sectionbytes→plist，再独立运行正例与6负例；仅R0Covered后才能读候选执行--verify。A1实际两executable hash/UUID/section原byte→归档与实际xcent，A2四项binding/78payload/pairedInfo/signature/6UUID加3源码局部impact。root自检只验证工具基本可执行，不能代R0或A1/A2独立意见。

新8calls/1200s hard、780s soft，首toolUTC/mono持久化，call2工具audit检查点（可用tool小摘要，不新增消息调用），保留2calls/180s收尾。建议3calls交付、简短report与真实全轮usage一并写。到最早限停止，不自动续审；工具有实质缺口停R0/依赖部分，不反复生成大parser、不改frozen文件。所有访问只读，reviewer仅写专属scratch，无repo/built文件修改。

旧R1超时、R2consistency-only、R3无效初稿及预算/账本缺口全部保留。新范围不是产品实施；没有build/test/simulator/container/install/UI/LLDB/Maps/Git/Release授权，下一T/I/U/M仍另授权fresh Entry。
