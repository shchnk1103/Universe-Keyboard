#import "RimeOctagramModuleShim.h"

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

#ifdef RIME_HAS_OCTAGRAM
// librime's RIME_REGISTER_MODULE(octagram) emits a C++ symbol, not extern "C".
void rime_require_module_octagram(void);
#endif

void RimeEnsureOctagramModuleLinked(void) {
#ifdef RIME_HAS_OCTAGRAM
    rime_require_module_octagram();
#endif
}

void RimeEnsureOctagramComponentsLoaded(void) {
#ifdef RIME_HAS_OCTAGRAM
    RimeEnsureOctagramModuleLinked();
    const char* modules[] = { "octagram", NULL };
    rime::LoadModules(modules);
#endif
}

bool RimeOctagramComponentRegistered(const char *componentName) {
#ifdef RIME_HAS_OCTAGRAM
    if (!componentName) return false;
    return rime::Registry::instance().Find(std::string(componentName)) != nullptr;
#else
    return false;
#endif
}
