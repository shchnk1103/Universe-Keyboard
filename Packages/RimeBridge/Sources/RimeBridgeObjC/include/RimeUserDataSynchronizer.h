#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 主 App 专用的 RIME 用户资料同步封装。
///
/// 该对象只调用 librime 的 `sync_user_data`：它处理用户词典快照的合并，
/// 并将用户目录中可移植的 YAML/TXT 备份到 `sync_dir`。它绝不复制运行中的
/// `*.userdb*` 文件，也不创建输入 session。
@interface RimeUserDataSynchronizer : NSObject

/// 在没有输入 session 的主 App 维护窗口内执行一次 RIME 标准同步。
/// 调用方必须先把 `sync_dir` 写入 user_data_dir/installation.yaml。
- (BOOL)syncWithSharedDataDir:(NSString *)sharedDataDir
                   userDataDir:(NSString *)userDataDir;

@end

NS_ASSUME_NONNULL_END
