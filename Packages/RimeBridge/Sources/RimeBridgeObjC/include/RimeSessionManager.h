#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Objective-C 封装层：将 librime C API 暴露为 Swift 可调用的 ObjC 方法。
/// 内部使用 C++/ObjC++ 调用 librime，处理所有 C 指针和内存管理。
///
/// 线程安全：所有方法必须在同一线程调用（键盘扩展中所有事件都在主线程）。
///
/// 编译依赖：
/// - rime_api.h（已包含在本包中）
/// - librime.xcframework（需放入 Vendor/librime.xcframework/）
@interface RimeSessionManager : NSObject

/// 设置并初始化 RIME 引擎。
/// @param sharedDataDir RIME 共享数据目录（schema、dict 等 YAML 配置文件）
/// @param userDataDir RIME 用户数据目录（user.yaml、同步目录等）
/// @return 是否初始化成功
- (BOOL)setupWithSharedDataDir:(NSString *)sharedDataDir
                   userDataDir:(NSString *)userDataDir;

/// 启动引擎（在 setup 之后调用）
/// @return 是否成功
- (BOOL)initializeEngine;

/// 创建新的输入 session
/// @return 是否成功
- (BOOL)createSession;

/// 销毁当前 session
/// @return 是否成功
- (BOOL)destroySession;

/// 当 librime 无法创建新 session 时，重新初始化引擎并创建 session。
/// @return 是否成功
- (BOOL)restartEngineAndCreateSession;

/// 处理一个按键。
/// @param keycode X11 keysym 值（如 'n' = 0x006e, BackSpace = 0xFF08）
/// @param modifiers 修饰键掩码（通常为 0）
/// @return 包含 composition、candidates、commit 的字典，见下方 key 常量
- (NSDictionary *)processKey:(int)keycode modifiers:(int)modifiers;

/// 选择第 index 个候选词（0-based）
/// @return 同 processKey 的返回格式
- (NSDictionary *)selectCandidateAtIndex:(int)index;

/// 选择全局候选列表中的第 index 个候选词（0-based，不限当前页）
/// @return 同 processKey 的返回格式；选择失败时返回当前输出
- (NSDictionary *)selectCandidateAtGlobalIndex:(int)index;

/// 高亮当前页第 index 个候选（不提交）。用于 Phase 0.6 观测 per-candidate 引擎状态。
/// API 不可用时返回 currentOutput 且不修改 session。
- (NSDictionary *)highlightCandidateOnCurrentPageAtIndex:(int)index
    NS_SWIFT_NAME(highlightCandidateOnCurrentPage(at:));

/// 从全局候选列表读取候选窗口，不改变当前页。
/// 返回 @{@"startIndex": ..., @"nextIndex": ..., @"hasMoreCandidates": ..., @"candidates": ...}
- (NSDictionary *)candidatesFromIndex:(int)index limit:(int)limit;

/// 只读获取当前 session 输出，用于验证只读候选窗口不会改变 composition。
/// 不处理按键、不选择候选，也不替换输入。
- (NSDictionary *)currentOutput;

/// 删除 composition 中最后一个字符
/// @return 同 processKey 的返回格式
- (NSDictionary *)deleteBackward;

/// 用未格式化输入替换当前 composition。
/// @param input 原始输入；空字符串表示清空 composition
/// @return 同 processKey 的返回格式
- (NSDictionary *)replaceInput:(NSString *)input;

/// 在独立的旁路 session 中查询指定拼音的候选，不改变主输入 session。
/// 返回值仅包含 candidates，供有界智能纠错候选验证使用。
- (NSDictionary *)correctionCandidatesForInput:(NSString *)input limit:(int)limit;

/// 提交当前 composition（不选候选，直接上屏拼音）
- (NSDictionary *)commitComposition;

/// 清除当前 composition
- (void)clearComposition;

/// 返回 librime 版本号
- (NSString *)librimeVersion;

/// 返回可用的 schema 列表（schema_id: schema_name）
- (NSString *)availableSchemas;

/// 当前是否有活跃的 composition
- (BOOL)isComposing;

/// 选择输入方案（schema）。
/// @param schemaID schema 标识符，如 "luna_pinyin"、"rime_ice"
/// @return 是否成功
- (BOOL)selectSchema:(NSString *)schemaID;

/// 获取当前激活的 schema_id。
- (NSString *)currentSchemaID;

/// 关闭引擎（释放所有资源）
- (void)finalize;

@end

// MARK: - 返回字典的 key 常量

/// composition.preedit — 正在编辑的拼音串，如 "ni hao"
extern NSString * const RimeKeyPreedit;
/// composition.cursorPos — 光标位置（NSNumber int）
extern NSString * const RimeKeyCursorPos;
/// composition.sel_start — librime 原生选择/高亮起点（NSNumber int；Phase 0.5 只读透传）
extern NSString * const RimeKeySelStart;
/// composition.sel_end — librime 原生选择/高亮终点（NSNumber int；Phase 0.5 只读透传）
extern NSString * const RimeKeySelEnd;
/// composition.length — librime composition 长度（NSNumber int；Phase 0.6 只读）
extern NSString * const RimeKeyCompositionLength;
/// get_caret_pos — raw input 空间光标（NSNumber int；Phase 0.6 只读）
extern NSString * const RimeKeyCaretPos;
/// commit_text_preview UTF-8 字节长度（NSNumber int；仅结构观测，禁止当汉字数→槽位权威）
extern NSString * const RimeKeyCommitPreviewLen;
/// 未格式化的原始输入，如 "nihao"
extern NSString * const RimeKeyRawInput;
/// candidates — 候选词数组，每个元素是 @{@"text": ..., @"comment": ...}
extern NSString * const RimeKeyCandidates;
/// candidate.text
extern NSString * const RimeKeyCandidateText;
/// candidate.comment（可为空字符串）
extern NSString * const RimeKeyCandidateComment;
/// commit.text — 要上屏的文字
extern NSString * const RimeKeyCommit;
/// menu.isLastPage — 是否已经是最后一页
extern NSString * const RimeKeyIsLastPage;
/// menu.highlightedIndex — 当前高亮的候选索引
extern NSString * const RimeKeyHighlightedIndex;
/// menu.pageNo — 当前页码
extern NSString * const RimeKeyPageNo;
extern NSString * const RimeKeyCandidateWindowStartIndex;
extern NSString * const RimeKeyCandidateWindowNextIndex;
extern NSString * const RimeKeyCandidateWindowHasMore;
extern NSString * const RimeKeyCandidateGlobalIndex;
/// 新 session 的第一个按键中，librime `process_key` 的耗时（NSNumber double，毫秒）。
extern NSString * const RimeKeyFirstProcessKeyLibrimeDurationMs;
/// 新 session 的第一个按键中，桥接层收集输出的耗时（NSNumber double，毫秒）。
extern NSString * const RimeKeyFirstProcessKeyOutputDurationMs;
/// 新 session 的第一个按键从 `process_key` 到输出收集完成的总耗时（NSNumber double，毫秒）。
extern NSString * const RimeKeyFirstProcessKeyTotalDurationMs;
/// 每次 processKey：librime `process_key` 耗时（NSNumber double，毫秒）。
extern NSString * const RimeKeyProcessKeyLibrimeDurationMs;
/// 每次 processKey：`collectOutput` / get_context 耗时（NSNumber double，毫秒）。
extern NSString * const RimeKeyProcessKeyCollectDurationMs;

NS_ASSUME_NONNULL_END
