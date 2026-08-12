#import "RimeOctagramModuleShim.h"

#include <map>
#include <string>
#include "rime_api.h"

// The pinned xcframework exposes the real registry/component declarations but
// omits Boost's header-only transitive includes from rime/common.h. Supply only
// the std aliases those two headers consume, then compile their exact classes.
#define RIME_COMMON_H_
namespace rime {
using std::map;
using std::string;
}
#include "rime/component.h"
#undef RIME_COMMON_H_

#include "rime/setup.h"
#ifdef RIME_DIAGNOSTICS
#define GLOG_EXPORT
#define GLOG_NO_EXPORT
#include <glog/logging.h>
#include <atomic>
#include <cstdlib>
#include <memory>
#include <mutex>
#endif

namespace rime {
#ifdef RIME_DIAGNOSTICS
class Config;

// Exact private interface from pinned librime 1.16.1. The distributed vendor
// headers omit rime/gear/grammar.h, but the registered component ABI uses it.
class Grammar : public Class<Grammar, Config*> {
public:
    virtual ~Grammar() {}
    virtual double Query(
        const std::string& context,
        const std::string& word,
        bool isRear
    ) = 0;
};
#endif
}

namespace {

#ifdef RIME_DIAGNOSTICS
struct GrammarModelReceiptState {
    std::mutex mutex;
    std::string expectedFileName;
    std::atomic<bool> armed{false};
    bool awaitingTargetArray = false;
    bool loadStarted = false;
    bool validDoubleArrayObserved = false;
    uint64_t doubleArraySize = 0;
};

GrammarModelReceiptState& GrammarModelReceipt() {
    static GrammarModelReceiptState state;
    return state;
}

bool EndsWith(const std::string& value, const std::string& suffix) {
    return value.size() >= suffix.size()
        && value.compare(value.size() - suffix.size(), suffix.size(), suffix) == 0;
}

void ConsumeGrammarModelLogLine(const std::string& line) {
    static const std::string loadPrefix = "loading gram db: ";
    static const std::string arrayPrefix = "found double array image of size ";
    auto& state = GrammarModelReceipt();
    std::lock_guard<std::mutex> lock(state.mutex);
    if (!state.armed.load(std::memory_order_relaxed)) return;

    if (line.compare(0, loadPrefix.size(), loadPrefix) == 0) {
        if (EndsWith(line, state.expectedFileName)) {
            state.loadStarted = true;
            state.awaitingTargetArray = true;
            state.validDoubleArrayObserved = false;
            state.doubleArraySize = 0;
        } else if (state.awaitingTargetArray) {
            // A different model started before the target array receipt. Do
            // not associate that model's next array line with our target.
            state.loadStarted = false;
            state.awaitingTargetArray = false;
            state.validDoubleArrayObserved = false;
            state.doubleArraySize = 0;
            state.armed.store(false, std::memory_order_release);
        }
        return;
    }
    if (!state.awaitingTargetArray
        || line.compare(0, arrayPrefix.size(), arrayPrefix) != 0) {
        return;
    }

    const char *digits = line.c_str() + arrayPrefix.size();
    char *end = nullptr;
    const unsigned long long parsedSize = std::strtoull(digits, &end, 10);
    const bool exactNumericMessage = end != digits && end[0] == '.' && end[1] == '\0';
    if (exactNumericMessage && parsedSize > 0) {
        state.validDoubleArrayObserved = true;
        state.doubleArraySize = parsedSize;
    } else {
        state.loadStarted = false;
    }
    state.awaitingTargetArray = false;
    state.armed.store(false, std::memory_order_release);
}

class GrammarModelLoadSink final : public google::LogSink {
public:
    void send(
        google::LogSeverity,
        const char *,
        const char *,
        int,
        const google::LogMessageTime&,
        const char *message,
        size_t messageLength
    ) override {
        if (!GrammarModelReceipt().armed.load(std::memory_order_acquire)) return;
        const std::string line(message, messageLength);
        ConsumeGrammarModelLogLine(line);
    }
};

GrammarModelLoadSink& GrammarModelSink() {
    static GrammarModelLoadSink sink;
    return sink;
}

void InstallGrammarModelSinkOnce() {
    static std::once_flag once;
    std::call_once(once, [] {
        google::AddLogSink(&GrammarModelSink());
    });
}

#endif

}  // namespace

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

#ifdef RIME_DIAGNOSTICS
void RimeResetGrammarModelLoadReceipt(const char *modelFileName) {
    InstallGrammarModelSinkOnce();
    auto& state = GrammarModelReceipt();
    std::lock_guard<std::mutex> lock(state.mutex);
    state.expectedFileName = modelFileName ? modelFileName : "";
    state.awaitingTargetArray = false;
    state.loadStarted = false;
    state.validDoubleArrayObserved = false;
    state.doubleArraySize = 0;
    state.armed.store(!state.expectedFileName.empty(), std::memory_order_release);
}

RimeGrammarModelLoadReceipt RimeCopyGrammarModelLoadReceipt(void) {
    auto& state = GrammarModelReceipt();
    std::lock_guard<std::mutex> lock(state.mutex);
    state.armed.store(false, std::memory_order_release);
    state.awaitingTargetArray = false;
    return {
        state.loadStarted,
        state.validDoubleArrayObserved,
        state.doubleArraySize,
    };
}

bool RimeProbeGrammarModelLoad(const char *language) {
#ifdef RIME_HAS_OCTAGRAM
    if (!language) return false;
    RimeApi *api = rime_get_api();
    if (!api
        || !RIME_API_AVAILABLE(api, config_init)
        || !RIME_API_AVAILABLE(api, config_set_string)
        || !RIME_API_AVAILABLE(api, config_close)) {
        return false;
    }

    RimeConfig config = {};
    if (!api->config_init(&config)) return false;

    bool constructed = false;
    if (api->config_set_string(&config, "grammar/language", language)) {
        if (auto *component = rime::Grammar::Require("grammar")) {
            std::unique_ptr<rime::Grammar> grammar(
                component->Create(reinterpret_cast<rime::Config *>(config.ptr))
            );
            constructed = grammar != nullptr;
        }
    }
    api->config_close(&config);
    return constructed;
#else
    return false;
#endif
}

void RimeConsumeGrammarModelLogLineForTesting(const char *line) {
    if (!line) return;
    ConsumeGrammarModelLogLine(std::string(line));
}
#endif
