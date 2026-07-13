#import "RimeUserDataSynchronizer.h"
#include "rime_api.h"

@implementation RimeUserDataSynchronizer

- (BOOL)syncWithSharedDataDir:(NSString *)sharedDataDir
                   userDataDir:(NSString *)userDataDir {
    RimeApi *api = rime_get_api();
    if (!api || !RIME_API_AVAILABLE(api, sync_user_data)) return NO;

    RIME_STRUCT(RimeTraits, traits);
    traits.shared_data_dir = sharedDataDir.UTF8String;
    traits.user_data_dir = userDataDir.UTF8String;
    traits.distribution_name = "UniverseKeyboard";
    traits.distribution_code_name = "UniverseKeyboard";
    traits.distribution_version = "1.0.0";
    traits.app_name = "rime.UniverseKeyboard.sync";
    traits.min_log_level = 0;

    // 用户资料同步是 Deployer 任务，不是输入 session 初始化。使用
    // deployer_initialize 才会按 librime 的部署器模块集注册 user_dict_sync。
    api->deployer_initialize(&traits);

    // sync_user_data 只会安排 installation/config/dictionary 维护任务。
    // 必须等待 librime 自己的维护线程结束，不能像普通同步函数那样立即 finalize。
    BOOL succeeded = api->sync_user_data();
    if (succeeded) {
        api->join_maintenance_thread();
    }
    api->finalize();
    return succeeded;
}

@end
