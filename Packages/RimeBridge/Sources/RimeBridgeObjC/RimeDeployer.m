#import "RimeDeployer.h"
#import "RimeLuaModuleShim.h"
#include "rime_api.h"

@implementation RimeDeployer {
    RimeApi *_api;
    BOOL _cleanedUp;
}

static NSString *RimeLogDirectory(NSString *userDir) {
    NSString *logDir = [userDir stringByAppendingPathComponent:@"logs"];
    [[NSFileManager defaultManager] createDirectoryAtPath:logDir
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    return logDir;
}

+ (NSArray<NSString *> *)configuredModules {
#ifdef RIME_HAS_LUA
    return @[ @"core", @"dict", @"gears", @"lua" ];
#else
    return @[ @"core", @"dict", @"gears" ];
#endif
}

+ (BOOL)luaModuleCompiledIn {
#ifdef RIME_HAS_LUA
    return YES;
#else
    return NO;
#endif
}

+ (BOOL)luaModuleRegistered {
    RimeEnsureLuaModuleLinked();
    RimeApi *api = rime_get_api();
    if (!api || !RIME_API_AVAILABLE(api, find_module)) return NO;
    return api->find_module("lua") != NULL;
}

+ (BOOL)luaComponentsRegistered {
    return RimeLuaComponentRegistered("lua_processor")
        && RimeLuaComponentRegistered("lua_translator")
        && RimeLuaComponentRegistered("lua_filter");
}

+ (NSArray<NSString *> *)luaComponentRegistrySummary {
    NSArray<NSString *> *components = @[
        @"lua_processor",
        @"lua_translator",
        @"lua_filter",
        @"lua_segmentor",
    ];
    NSMutableArray<NSString *> *summary = [NSMutableArray arrayWithCapacity:components.count];
    for (NSString *component in components) {
        BOOL registered = RimeLuaComponentRegistered(component.UTF8String);
        [summary addObject:[NSString stringWithFormat:@"%@=%@", component, registered ? @"true" : @"false"]];
    }
    return summary;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        RimeEnsureLuaModuleLinked();
        _api = rime_get_api();
        _cleanedUp = NO;
    }
    return self;
}

- (BOOL)deployWithSharedDataDir:(NSString *)sharedDir
                    userDataDir:(NSString *)userDir {
    if (!_api) return NO;
    RimeEnsureLuaModuleLinked();

    // 1. setup traits
    RIME_STRUCT(RimeTraits, traits);
    traits.shared_data_dir = [sharedDir UTF8String];
    traits.user_data_dir = [userDir UTF8String];
    traits.distribution_name = "UniverseKeyboard";
    traits.distribution_code_name = "UniverseKeyboard";
    traits.distribution_version = "1.0.0";
    traits.app_name = "rime.UniverseKeyboard";
    traits.min_log_level = 0;
    traits.log_dir = [RimeLogDirectory(userDir) UTF8String];

#ifdef RIME_HAS_LUA
    // 2. 部署阶段也要注册 lua，否则含 Lua 组件的 schema 可能无法完整编译。
    const char* modules[] = { "core", "dict", "gears", "lua", NULL };
#else
    const char* modules[] = { "core", "dict", "gears", NULL };
#endif
    traits.modules = modules;

    NSLog(@"[RIME] deploy setup: modules=%@ luaCompiledIn=%@ luaModuleRegisteredBeforeSetup=%@",
          [[self.class configuredModules] componentsJoinedByString:@"+"],
          self.class.luaModuleCompiledIn ? @"YES" : @"NO",
          self.class.luaModuleRegistered ? @"YES" : @"NO");

    _api->setup(&traits);
    RimeEnsureLuaComponentsLoaded();
    NSLog(@"[RIME] deploy setup complete: luaComponents=%@",
          [self.class.luaComponentRegistrySummary componentsJoinedByString:@"+"]);

    // 3. 初始化引擎（不创建 session，不处理输入）
    _api->initialize(NULL);

    BOOL luaRuntimeAvailable = self.class.luaModuleCompiledIn
        && self.class.luaModuleRegistered
        && self.class.luaComponentsRegistered;

    NSLog(@"[RIME] deploy initialized: luaModuleRegisteredAfterInitialize=%@ luaComponents=%@",
          self.class.luaModuleRegistered ? @"YES" : @"NO",
          [self.class.luaComponentRegistrySummary componentsJoinedByString:@"+"]);

    // Lua 能力属于已部署运行时状态，由主 App 在交付键盘前持久化。
    // 这里必须写入运行时探测结果，而不是仅依赖编译宏，避免详情页虚报可用。
    NSUserDefaults *defs = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.DoubleShy0N.Universe-Keyboard"];
    [defs setBool:luaRuntimeAvailable forKey:@"rime_lua_available"];
    [defs synchronize];

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
