# U1 新实例单轮 — Prepared，未授权执行

原PID80843的probe已单次frozen；不得直接继续输入n、重复点取证或修改状态rearm。原轮Incomplete/原始13call账本保留。Human界面恢复/标题确认先完成。

建议仅新增一次正常扩展进程退出与新U1单轮权限，不重装/部署/改变完全访问或两诊断。执行前要求Human继续独占，关闭主App回主屏让键盘收起；root只读核确切当前PID与原UDID当前installed路径/78SHA。若扩展未退出，必须按届时明确授权仅对该已核进程发一次SIGTERM并验证退出，不kill其他进程、不自动强杀或重复发信号。Human再打开原App搜索页叫出键盘，形成新进程；freshPID/source/payload/diagnostics/loaded路径UUID绑定全部重核。若进程复用或probe已消费，停止，不绕过。

沿原U1合同，一步一回报：arm后只确认取证文字，root下一步才输入一次n，再下一步才freeze；每卡显著提示“不要再点取证，等下一步”。不把整轮提前合并给Human。真实停点唯一hit1，caller有限backtrace/静态两参数/一次176..11352有界read、TTL600秒、root停点工作120秒及完整账本不变。

工具cleanup修正：若用LLDB breakpoint set创建，直接在同session用breakpoint delete OWN_ID，再用breakpoint list OWN_ID核其已删除，然后continue/detach；不使用DAP registry remove。任一步失败及时记录并优先continue/detach，不能为补清理读其他任务session。工具UDID标签原冲突保留，实际路径+UUID绑定补正仍适用，所有操作显式session，不改defaults。

当前仅Prepared，无SIGTERM/新launch/再次attach或重采授权；需Human批准新实例与新一轮U1。无源码、测试、安装、Maps、独立审查或Release权限。若需数据回滚另冻结具体恢复范围。
