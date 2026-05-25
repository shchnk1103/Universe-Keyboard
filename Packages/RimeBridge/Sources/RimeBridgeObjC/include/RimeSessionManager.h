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

/// 删除 composition 中最后一个字符
/// @return 同 processKey 的返回格式
- (NSDictionary *)deleteBackward;

/// 提交当前 composition（不选候选，直接上屏拼音）
- (NSDictionary *)commitComposition;

/// 清除当前 composition
- (void)clearComposition;

/// 当前是否有活跃的 composition
- (BOOL)isComposing;

/// 关闭引擎（释放所有资源）
- (void)finalize;

@end

// MARK: - 返回字典的 key 常量

/// composition.preedit — 正在编辑的拼音串，如 "ni hao"
extern NSString * const RimeKeyPreedit;
/// composition.cursorPos — 光标位置（NSNumber int）
extern NSString * const RimeKeyCursorPos;
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

NS_ASSUME_NONNULL_END
