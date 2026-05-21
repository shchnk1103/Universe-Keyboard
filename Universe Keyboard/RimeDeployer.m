#import "RimeDeployer.h"
#include "rime_api.h"

@implementation RimeDeployer {
    RimeApi *_api;
    BOOL _cleanedUp;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _api = rime_get_api();
        _cleanedUp = NO;
    }
    return self;
}

- (BOOL)deployWithSharedDataDir:(NSString *)sharedDir
                    userDataDir:(NSString *)userDir {
    if (!_api) return NO;

    // 1. setup traits
    RIME_STRUCT(RimeTraits, traits);
    traits.shared_data_dir = [sharedDir UTF8String];
    traits.user_data_dir = [userDir UTF8String];
    traits.distribution_name = "UniverseKeyboard";
    traits.distribution_code_name = "UniverseKeyboard";
    traits.distribution_version = "1.0.0";
    traits.app_name = "rime.UniverseKeyboard";

    // 2. 加载核心模块（不需要 Lua——部署只编译 YAML → .bin）
    const char* modules[] = { "core", "dict", "gears", NULL };
    traits.modules = modules;

    _api->setup(&traits);

    // 3. 初始化引擎（不创建 session，不处理输入）
    _api->initialize(NULL);

    // 4. 全量部署
    BOOL ok = _api->start_maintenance(/*full_check=*/True);
    if (ok) {
        _api->join_maintenance_thread();
    }

    // 5. 清理
    [self cleanup];

    return ok;
}

- (NSString *)librimeVersion {
    if (!_api) return @"(no api)";
    const char *v = _api->get_version();
    return v ? [NSString stringWithUTF8String:v] : @"(unknown)";
}

- (void)cleanup {
    if (_api && !_cleanedUp) {
        _api->finalize();
        _cleanedUp = YES;
    }
}

- (void)dealloc {
    [self cleanup];
}

@end
