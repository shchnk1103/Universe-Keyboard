#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Forces the linker to keep the librime-octagram module registration object.
///
/// Same static-registration pattern as Lua: without an explicit reference and a
/// force-load path, the archive member that owns `rime_require_module_octagram`
/// can be dead-stripped and the grammar component never appears in the registry.
FOUNDATION_EXPORT void RimeEnsureOctagramModuleLinked(void);
FOUNDATION_EXPORT void RimeEnsureOctagramComponentsLoaded(void);
FOUNDATION_EXPORT bool RimeOctagramComponentRegistered(const char *componentName);

#ifdef RIME_DIAGNOSTICS
typedef struct {
    bool loadStarted;
    bool validDoubleArrayObserved;
    uint64_t doubleArraySize;
} RimeGrammarModelLoadReceipt;

/// Arms a content-free glog sink for one expected `.gram` filename.
/// The sink records only fixed loader state and a numeric double-array size.
FOUNDATION_EXPORT void RimeResetGrammarModelLoadReceipt(const char *modelFileName);
FOUNDATION_EXPORT RimeGrammarModelLoadReceipt RimeCopyGrammarModelLoadReceipt(void);

/// Constructs the registered grammar component with an in-memory language
/// config. The content-free receipt remains the authority for load success.
FOUNDATION_EXPORT bool RimeProbeGrammarModelLoad(const char *language);
FOUNDATION_EXPORT void RimeConsumeGrammarModelLogLineForTesting(const char *line);
#endif

NS_ASSUME_NONNULL_END
