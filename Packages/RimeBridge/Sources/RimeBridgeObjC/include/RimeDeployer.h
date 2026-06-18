#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 主 App 端最小 RIME 部署封装。
/// 仅负责全量部署（start_maintenance + join_maintenance_thread），
/// 将耗时编译从键盘扩展移到主 App 中执行。
@interface RimeDeployer : NSObject

/// 当前部署器会传给 librime 的模块列表。
+ (NSArray<NSString *> *)configuredModules;

/// 当前二进制是否在 ObjC 桥接层启用了 Lua 模块。
+ (BOOL)luaModuleCompiledIn;

/// 执行全量部署。
/// @param sharedDir RIME shared_data_dir（App Group 中 Rime/shared）
/// @param userDir RIME user_data_dir（App Group 中 Rime/user）
/// @return 是否成功
- (BOOL)deployWithSharedDataDir:(NSString *)sharedDir
                    userDataDir:(NSString *)userDir;

/// 返回 librime 版本号
- (NSString *)librimeVersion;

@end

NS_ASSUME_NONNULL_END
