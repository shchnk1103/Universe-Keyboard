#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Forces the linker to keep the librime-lua module registration object.
///
/// librime discovers plugins through static module registration. Static archives
/// can be linked without pulling in the object that owns that registration, so
/// this shim creates an explicit reference to librime-lua's require symbol.
FOUNDATION_EXPORT void RimeEnsureLuaModuleLinked(void);
FOUNDATION_EXPORT void RimeEnsureLuaComponentsLoaded(void);
FOUNDATION_EXPORT bool RimeLuaComponentRegistered(const char *componentName);

NS_ASSUME_NONNULL_END
