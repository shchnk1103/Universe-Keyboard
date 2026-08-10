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

NS_ASSUME_NONNULL_END
