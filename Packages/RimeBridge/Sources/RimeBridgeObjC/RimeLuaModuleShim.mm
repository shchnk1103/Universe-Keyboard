#import "RimeLuaModuleShim.h"

#include <string>
#include "rime/setup.h"

namespace rime {
class ComponentBase;
class Registry {
public:
    static Registry& instance();
    ComponentBase* Find(const std::string& name);
};
}

#ifdef RIME_HAS_LUA
// librime's RIME_REGISTER_MODULE(lua) emits a C++ symbol, not an extern "C"
// function. This declaration intentionally uses C++ linkage.
void rime_require_module_lua(void);
#endif

void RimeEnsureLuaModuleLinked(void) {
#ifdef RIME_HAS_LUA
    rime_require_module_lua();
#endif
}

void RimeEnsureLuaComponentsLoaded(void) {
#ifdef RIME_HAS_LUA
    RimeEnsureLuaModuleLinked();
    const char* modules[] = { "lua", NULL };
    rime::LoadModules(modules);
#endif
}

bool RimeLuaComponentRegistered(const char *componentName) {
#ifdef RIME_HAS_LUA
    if (!componentName) return false;
    return rime::Registry::instance().Find(std::string(componentName)) != nullptr;
#else
    return false;
#endif
}
