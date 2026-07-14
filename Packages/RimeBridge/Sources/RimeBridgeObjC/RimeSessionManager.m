#import "RimeSessionManager.h"
#import "RimeDeployer.h"
#import "RimeLuaModuleShim.h"
#include "rime_api.h"
#include <string.h>

#ifdef RIME_DIAGNOSTICS
#define RIME_DIAGNOSTIC_LOG(...) NSLog(__VA_ARGS__)
#else
#define RIME_DIAGNOSTIC_LOG(...) do { } while (0)
#endif

// MARK: - Dictionary keys

NSString * const RimeKeyPreedit          = @"preedit";
NSString * const RimeKeyCursorPos        = @"cursorPos";
NSString * const RimeKeyRawInput         = @"rawInput";
NSString * const RimeKeyCandidates       = @"candidates";
NSString * const RimeKeyCandidateText    = @"text";
NSString * const RimeKeyCandidateComment = @"comment";
NSString * const RimeKeyCommit           = @"commit";
NSString * const RimeKeyIsLastPage       = @"isLastPage";
NSString * const RimeKeyHighlightedIndex = @"highlightedIndex";
NSString * const RimeKeyPageNo           = @"pageNo";
NSString * const RimeKeyCandidateWindowStartIndex = @"startIndex";
NSString * const RimeKeyCandidateWindowNextIndex = @"nextIndex";
NSString * const RimeKeyCandidateWindowHasMore = @"hasMoreCandidates";
NSString * const RimeKeyCandidateGlobalIndex = @"globalIndex";
NSString * const RimeKeyFirstProcessKeyLibrimeDurationMs = @"firstProcessKeyLibrimeDurationMs";
NSString * const RimeKeyFirstProcessKeyOutputDurationMs = @"firstProcessKeyOutputDurationMs";
NSString * const RimeKeyFirstProcessKeyTotalDurationMs = @"firstProcessKeyTotalDurationMs";

// MARK: - Private interface

@interface RimeSessionManager ()
@property (nonatomic, assign) RimeSessionId sessionId;
@property (nonatomic, assign) BOOL setupDone;
@property (nonatomic, assign) BOOL initialized;
/// 每个新 session 仅细分首个真实 processKey，避免把常规按键路径的观测成本放大。
@property (nonatomic, assign) BOOL shouldMeasureFirstProcessKey;
- (void)claimRuntimeOwnership;
- (void)relinquishRuntimeOwnership;
@end

@implementation RimeSessionManager {
    RimeApi *_api;
}

// librime exposes one process-wide runtime through rime_get_api(). UIKit may keep an
// old keyboard controller alive while creating a replacement controller, so treating
// each manager as an independent runtime can leave the old instance holding database
// locks. Keep one explicit owner and retire it before another manager calls setup or
// initialize. All keyboard RIME calls are required to stay on the main thread.
static __weak RimeSessionManager *RimeActiveRuntimeOwner = nil;

#ifdef RIME_DIAGNOSTICS
static NSString *RimeSessionLogDirectory(NSString *userDir) {
    NSString *logDir = [userDir stringByAppendingPathComponent:@"logs"];
    [[NSFileManager defaultManager] createDirectoryAtPath:logDir
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    return logDir;
}
#endif

- (instancetype)init {
    self = [super init];
    if (self) {
        RimeEnsureLuaModuleLinked();
        _api = rime_get_api();
        _sessionId = 0;
        _setupDone = NO;
        _initialized = NO;
        _shouldMeasureFirstProcessKey = NO;
    }
    return self;
}

// MARK: - Setup

- (BOOL)setupWithSharedDataDir:(NSString *)sharedDataDir
                   userDataDir:(NSString *)userDataDir {
    if (_setupDone) return YES;
    [self claimRuntimeOwnership];
    RimeEnsureLuaModuleLinked();

    RIME_STRUCT(RimeTraits, traits);
    traits.shared_data_dir = [sharedDataDir UTF8String];
    traits.user_data_dir = [userDataDir UTF8String];
    traits.distribution_name = "UniverseKeyboard";
    traits.distribution_code_name = "UniverseKeyboard";
    traits.distribution_version = "1.0.0";
    traits.app_name = "rime.UniverseKeyboard";
#ifdef RIME_DIAGNOSTICS
    traits.min_log_level = 0;
    traits.log_dir = [RimeSessionLogDirectory(userDataDir) UTF8String];
#else
    // Release 启动只保留 librime ERROR/FATAL，并写入 stderr，避免创建日志目录和文件。
    traits.min_log_level = 2;
    traits.log_dir = "";
#endif

    // 加载模块：core, dict, gears 为基础模块
    // 当 librime-lua 插件已编译链接时，添加 "lua" 到列表中
#ifdef RIME_HAS_LUA
    const char* modules[] = { "core", "dict", "gears", "lua", NULL };
#else
    const char* modules[] = { "core", "dict", "gears", NULL };
#endif
    traits.modules = modules;

    RIME_DIAGNOSTIC_LOG(@"[RIME] keyboard setup: modules=%@ luaCompiledIn=%@ luaModuleRegisteredBeforeSetup=%@",
                        [[RimeDeployer configuredModules] componentsJoinedByString:@"+"],
                        [RimeDeployer luaModuleCompiledIn] ? @"YES" : @"NO",
                        [RimeDeployer luaModuleRegistered] ? @"YES" : @"NO");

    _api->setup(&traits);
    RimeEnsureLuaComponentsLoaded();
    RIME_DIAGNOSTIC_LOG(@"[RIME] keyboard setup complete: luaModuleRegisteredAfterSetup=%@ luaComponents=%@",
                        [RimeDeployer luaModuleRegistered] ? @"YES" : @"NO",
                        [[RimeDeployer luaComponentRegistrySummary] componentsJoinedByString:@"+"]);
    _setupDone = YES;
    return YES;
}

- (BOOL)initializeEngine {
    if (_initialized) return YES;
    if (!_setupDone) return NO;

    [self claimRuntimeOwnership];

    _api->initialize(NULL);
    RIME_DIAGNOSTIC_LOG(@"[RIME] keyboard initialize complete: luaModuleRegisteredAfterInitialize=%@ luaComponents=%@",
                        [RimeDeployer luaModuleRegistered] ? @"YES" : @"NO",
                        [[RimeDeployer luaComponentRegistrySummary] componentsJoinedByString:@"+"]);

    // 部署与共享偏好写入均由主 App 完成；扩展启动只创建可输入的 session。

    _initialized = YES;
    return YES;
}

// MARK: - Session

- (BOOL)createSession {
    if (!_initialized) return NO;
    if (_sessionId != 0) return YES; // already has session

    _sessionId = _api->create_session();
    _shouldMeasureFirstProcessKey = _sessionId != 0;
    RIME_DIAGNOSTIC_LOG(@"[RIME] createSession: sessionId=%lu", (unsigned long) _sessionId);
    return _sessionId != 0;
}

- (BOOL)destroySession {
    if (_sessionId == 0) return NO;
    RIME_DIAGNOSTIC_LOG(@"[RIME] destroySession: sessionId=%lu", (unsigned long) _sessionId);
    _api->destroy_session(_sessionId);
    _sessionId = 0;
    return YES;
}

- (BOOL)restartEngineAndCreateSession {
    NSLog(@"[RIME] restartEngineAndCreateSession: reinitializing librime");
    if (_sessionId != 0) {
        _api->destroy_session(_sessionId);
        _sessionId = 0;
    }
    if (_initialized) {
        _api->finalize();
        _initialized = NO;
    }
    if (![self initializeEngine]) {
        NSLog(@"[RIME] restartEngineAndCreateSession: initializeEngine failed");
        return NO;
    }
    return [self createSession];
}

// MARK: - Input

- (NSDictionary *)processKey:(int)keycode modifiers:(int)modifiers {
    if (_sessionId == 0) {
        NSLog(@"[RIME] ⚠️ processKey(keycode=%d) called with sessionId=0 — attempting auto-recovery", keycode);
        if (!_initialized) {
            NSLog(@"[RIME] ⚠️ processKey: engine not initialized, cannot recover");
            return [self emptyOutput];
        }
        _sessionId = _api->create_session();
        if (_sessionId == 0) {
            NSLog(@"[RIME] ⚠️ processKey: session auto-recreation FAILED");
            return [self emptyOutput];
        }
        _shouldMeasureFirstProcessKey = YES;
        RIME_DIAGNOSTIC_LOG(@"[RIME] processKey: auto-recreated session, new sessionId=%lu", (unsigned long) _sessionId);
        // 重新选择上次激活的方案
        NSUserDefaults *defs = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.DoubleShy0N.Universe-Keyboard"];
        NSString *schema = [defs stringForKey:@"rime_active_schema"] ?: @"luna_pinyin";
        if (!_api->select_schema(_sessionId, [schema UTF8String])) {
            NSLog(@"[RIME] ⚠️ processKey: select_schema('%@') failed after session recovery", schema);
        }
    }

    if (!_shouldMeasureFirstProcessKey) {
        _api->process_key(_sessionId, keycode, modifiers);
        return [self collectOutput];
    }

    // 首键的候选引擎可能触发延迟加载。只记录阶段耗时，绝不记录按键或候选内容。
    _shouldMeasureFirstProcessKey = NO;
    CFAbsoluteTime totalStart = CFAbsoluteTimeGetCurrent();
    _api->process_key(_sessionId, keycode, modifiers);
    CFAbsoluteTime outputStart = CFAbsoluteTimeGetCurrent();
    NSDictionary *output = [self collectOutput];
    CFAbsoluteTime outputEnd = CFAbsoluteTimeGetCurrent();

    NSMutableDictionary *timedOutput = [output mutableCopy];
    timedOutput[RimeKeyFirstProcessKeyLibrimeDurationMs] = @((outputStart - totalStart) * 1000.0);
    timedOutput[RimeKeyFirstProcessKeyOutputDurationMs] = @((outputEnd - outputStart) * 1000.0);
    timedOutput[RimeKeyFirstProcessKeyTotalDurationMs] = @((outputEnd - totalStart) * 1000.0);
    return timedOutput;
}

- (NSDictionary *)selectCandidateAtIndex:(int)index {
    if (_sessionId == 0) return [self emptyOutput];

    _api->select_candidate_on_current_page(_sessionId, index);
    return [self collectOutput];
}

- (NSDictionary *)selectCandidateAtGlobalIndex:(int)index {
    if (_sessionId == 0) return [self emptyOutput];
    if (index < 0) return [self collectOutput];
    if (!RIME_API_AVAILABLE(_api, select_candidate)) {
        NSLog(@"[RIME] ⚠️ select_candidate API unavailable");
        return [self collectOutput];
    }

    if (!_api->select_candidate(_sessionId, (size_t)index)) {
        NSLog(@"[RIME] ⚠️ select_candidate(%d) failed", index);
    }
    return [self collectOutput];
}

- (NSDictionary *)candidatesFromIndex:(int)index limit:(int)limit {
    NSMutableDictionary *window = [NSMutableDictionary dictionary];
    int safeIndex = MAX(0, index);
    int safeLimit = MAX(0, limit);
    window[RimeKeyCandidateWindowStartIndex] = @(safeIndex);
    window[RimeKeyCandidateWindowNextIndex] = @(safeIndex);
    window[RimeKeyCandidateWindowHasMore] = @NO;
    window[RimeKeyCandidates] = @[];

    if (_sessionId == 0 || safeLimit == 0) return window;
    if (!RIME_API_AVAILABLE(_api, candidate_list_from_index)) {
        NSLog(@"[RIME] ⚠️ candidate_list_from_index API unavailable");
        return window;
    }

    RimeCandidateListIterator iterator = {0};
    if (!_api->candidate_list_from_index(_sessionId, &iterator, safeIndex)) {
        return window;
    }

    NSMutableArray *candidates = [NSMutableArray arrayWithCapacity:safeLimit];
    int consumed = 0;
    int lastGlobalIndex = safeIndex - 1;
    BOOL hasMore = NO;
    do {
        if (consumed >= safeLimit) {
            hasMore = YES;
            break;
        }
        NSMutableDictionary *item = [NSMutableDictionary dictionary];
        if (iterator.candidate.text) {
            item[RimeKeyCandidateText] = [NSString stringWithUTF8String:iterator.candidate.text];
        }
        if (iterator.candidate.comment) {
            item[RimeKeyCandidateComment] = [NSString stringWithUTF8String:iterator.candidate.comment];
        }
        item[RimeKeyCandidateGlobalIndex] = @(iterator.index);
        [candidates addObject:item];
        lastGlobalIndex = iterator.index;
        consumed += 1;
    } while (_api->candidate_list_next(&iterator));

    _api->candidate_list_end(&iterator);
    window[RimeKeyCandidates] = candidates;
    window[RimeKeyCandidateWindowNextIndex] = @(consumed > 0 ? lastGlobalIndex + 1 : safeIndex);
    window[RimeKeyCandidateWindowHasMore] = @(hasMore);
    return window;
}

- (NSDictionary *)deleteBackward {
    if (_sessionId == 0) return [self emptyOutput];

    // XK_BackSpace = 0xFF08
    _api->process_key(_sessionId, 0xFF08, 0);
    return [self collectOutput];
}

- (NSDictionary *)replaceInput:(NSString *)input {
    if (_sessionId == 0) return [self emptyOutput];

    _api->set_input(_sessionId, [input UTF8String]);
    return [self collectOutput];
}

- (NSDictionary *)commitComposition {
    if (_sessionId == 0) return [self emptyOutput];

    _api->commit_composition(_sessionId);
    return [self collectOutput];
}

- (void)clearComposition {
    if (_sessionId == 0) return;
    _api->clear_composition(_sessionId);
}

- (NSString *)librimeVersion {
    if (!_api) return @"(no api)";
    const char *v = _api->get_version();
    return v ? [NSString stringWithUTF8String:v] : @"(unknown)";
}

- (NSString *)availableSchemas {
    if (!_initialized) return @"(未初始化)";
    RimeSchemaList list;
    if (!_api->get_schema_list(&list)) return @"(获取失败)";
    NSMutableArray *items = [NSMutableArray array];
    for (size_t i = 0; i < list.size && i < 20; i++) {
        [items addObject:[NSString stringWithFormat:@"%s — %s",
                          list.list[i].schema_id, list.list[i].name]];
    }
    _api->free_schema_list(&list);
    return items.count ? [items componentsJoinedByString:@", "] : @"(空)";
}

- (BOOL)isComposing {
    if (_sessionId == 0) return NO;

    RIME_STRUCT(RimeStatus, status);
    if (!_api->get_status(_sessionId, &status)) return NO;
    BOOL composing = status.is_composing;
    _api->free_status(&status);
    return composing;
}

// MARK: - Output collection

/// 收集 RIME context 和 commit，转为 NSDictionary 返回给 Swift 层。
/// 关键：在返回 NSDictionary 之前调用 free_context/free_commit，
/// 将 C 字符串数据复制到 NSString 中，避免悬挂指针。
- (NSDictionary *)collectOutput {
    NSMutableDictionary *output = [NSMutableDictionary dictionary];

    // --- Raw input ---
    // 与可能包含分段空格的 preedit 分离，供未来 composition 恢复使用。
    const char *rawInput = _api->get_input(_sessionId);
    if (rawInput && strlen(rawInput) > 0) {
        output[RimeKeyRawInput] = [NSString stringWithUTF8String:rawInput];
    }

    // --- Commit text ---
    RIME_STRUCT(RimeCommit, commit);
    if (_api->get_commit(_sessionId, &commit)) {
        if (commit.text) {
            output[RimeKeyCommit] = [NSString stringWithUTF8String:commit.text];
        }
        _api->free_commit(&commit);
    }

    // --- Context (composition + candidates) ---
    RIME_STRUCT(RimeContext, ctx);
    if (_api->get_context(_sessionId, &ctx)) {
        // Composition (preedit)
        if (ctx.composition.preedit && strlen(ctx.composition.preedit) > 0) {
            output[RimeKeyPreedit] = [NSString stringWithUTF8String:ctx.composition.preedit];
            output[RimeKeyCursorPos] = @(ctx.composition.cursor_pos);
        }

        // Candidates
        if (ctx.menu.num_candidates > 0) {
            NSMutableArray *candidates = [NSMutableArray arrayWithCapacity:ctx.menu.num_candidates];
            for (int i = 0; i < ctx.menu.num_candidates; i++) {
                RimeCandidate *c = &ctx.menu.candidates[i];
                NSMutableDictionary *item = [NSMutableDictionary dictionary];
                if (c->text) item[RimeKeyCandidateText] = [NSString stringWithUTF8String:c->text];
                if (c->comment) item[RimeKeyCandidateComment] = [NSString stringWithUTF8String:c->comment];
                [candidates addObject:item];
            }
            output[RimeKeyCandidates] = candidates;
            output[RimeKeyHighlightedIndex] = @(ctx.menu.highlighted_candidate_index);
            output[RimeKeyIsLastPage] = @(ctx.menu.is_last_page);
            output[RimeKeyPageNo] = @(ctx.menu.page_no);
        }

        _api->free_context(&ctx);
    }

    return output;
}

/// 返回空输出（无 composition、无 candidates）
- (NSDictionary *)emptyOutput {
    return @{};
}

// MARK: - Schema switching

- (BOOL)selectSchema:(NSString *)schemaID {
    if (_sessionId == 0) return NO;
    return _api->select_schema(_sessionId, [schemaID UTF8String]);
}

- (NSString *)currentSchemaID {
    if (_sessionId == 0) return nil;
    char buffer[256] = {0};
    if (_api->get_current_schema(_sessionId, buffer, sizeof(buffer))) {
        return [NSString stringWithUTF8String:buffer];
    }
    return nil;
}

// MARK: - Cleanup

/// Makes this manager the sole owner of librime's process-global runtime.
///
/// A replacement keyboard controller can be constructed without the previous
/// controller receiving viewWillDisappear. Retiring the previous owner here keeps
/// setup/initialize calls ordered and prevents stale managers from finalizing a newer
/// controller's runtime later from dealloc.
- (void)claimRuntimeOwnership {
    RIME_DIAGNOSTIC_LOG(@"[RIME] claiming process runtime on %@ thread",
                        [NSThread isMainThread] ? @"main" : @"non-main");

    RimeSessionManager *previousOwner = RimeActiveRuntimeOwner;
    if (previousOwner == self) return;

    [previousOwner relinquishRuntimeOwnership];
    RimeActiveRuntimeOwner = self;
}

- (void)relinquishRuntimeOwnership {
    if (_sessionId != 0) {
        _api->destroy_session(_sessionId);
        _sessionId = 0;
    }
    if (_initialized) {
        _api->finalize();
        _initialized = NO;
    }
    if (RimeActiveRuntimeOwner == self) {
        RimeActiveRuntimeOwner = nil;
    }
}

- (void)finalize {
    // A stale controller must never destroy or finalize the current controller's
    // process-global runtime. Its local flags were cleared when ownership moved.
    if (RimeActiveRuntimeOwner != self) {
        _sessionId = 0;
        _initialized = NO;
        return;
    }

    [self relinquishRuntimeOwnership];
}

- (void)dealloc {
    [self finalize];
}

@end
