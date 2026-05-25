#import "RimeSessionManager.h"
#include "rime_api.h"
#include <string.h>

// MARK: - Dictionary keys

NSString * const RimeKeyPreedit          = @"preedit";
NSString * const RimeKeyCursorPos        = @"cursorPos";
NSString * const RimeKeyCandidates       = @"candidates";
NSString * const RimeKeyCandidateText    = @"text";
NSString * const RimeKeyCandidateComment = @"comment";
NSString * const RimeKeyCommit           = @"commit";
NSString * const RimeKeyIsLastPage       = @"isLastPage";
NSString * const RimeKeyHighlightedIndex = @"highlightedIndex";
NSString * const RimeKeyPageNo           = @"pageNo";

// MARK: - Private interface

@interface RimeSessionManager ()
@property (nonatomic, assign) RimeSessionId sessionId;
@property (nonatomic, assign) BOOL setupDone;
@property (nonatomic, assign) BOOL initialized;
@end

@implementation RimeSessionManager {
    RimeApi *_api;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _api = rime_get_api();
        _sessionId = 0;
        _setupDone = NO;
        _initialized = NO;
    }
    return self;
}

// MARK: - Setup

- (BOOL)setupWithSharedDataDir:(NSString *)sharedDataDir
                   userDataDir:(NSString *)userDataDir {
    if (_setupDone) return YES;

    RIME_STRUCT(RimeTraits, traits);
    traits.shared_data_dir = [sharedDataDir UTF8String];
    traits.user_data_dir = [userDataDir UTF8String];
    traits.distribution_name = "UniverseKeyboard";
    traits.distribution_code_name = "UniverseKeyboard";
    traits.distribution_version = "1.0.0";
    traits.app_name = "rime.UniverseKeyboard";

    _api->setup(&traits);
    _setupDone = YES;
    return YES;
}

- (BOOL)initializeEngine {
    if (_initialized) return YES;
    if (!_setupDone) return NO;

    _api->initialize(NULL);

    // 首次运行时检查是否需要 full deploy
    if (_api->start_maintenance(/*full_check=*/False)) {
        _api->join_maintenance_thread();
    }

    _initialized = YES;
    return YES;
}

// MARK: - Session

- (BOOL)createSession {
    if (!_initialized) return NO;
    if (_sessionId != 0) return YES; // already has session

    _sessionId = _api->create_session();
    return _sessionId != 0;
}

- (BOOL)destroySession {
    if (_sessionId == 0) return NO;
    _api->destroy_session(_sessionId);
    _sessionId = 0;
    return YES;
}

- (BOOL)restartEngineAndCreateSession {
    if (_sessionId != 0) {
        _api->destroy_session(_sessionId);
        _sessionId = 0;
    }
    if (_initialized) {
        _api->finalize();
        _initialized = NO;
    }
    if (![self initializeEngine]) return NO;
    return [self createSession];
}

// MARK: - Input

- (NSDictionary *)processKey:(int)keycode modifiers:(int)modifiers {
    if (_sessionId == 0) return [self emptyOutput];

    _api->process_key(_sessionId, keycode, modifiers);
    return [self collectOutput];
}

- (NSDictionary *)selectCandidateAtIndex:(int)index {
    if (_sessionId == 0) return [self emptyOutput];

    _api->select_candidate_on_current_page(_sessionId, index);
    return [self collectOutput];
}

- (NSDictionary *)deleteBackward {
    if (_sessionId == 0) return [self emptyOutput];

    // XK_BackSpace = 0xFF08
    _api->process_key(_sessionId, 0xFF08, 0);
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

// MARK: - Cleanup

- (void)finalize {
    if (_sessionId != 0) {
        [self destroySession];
    }
    if (_initialized) {
        _api->finalize();
        _initialized = NO;
    }
}

- (void)dealloc {
    [self finalize];
}

@end
