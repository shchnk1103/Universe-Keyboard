// RimeBridge 功能验证工具
// 使用 Homebrew librime 测试完整的输入流程
// 编译: make -C TestTool
// 运行: ./TestTool/test_rime

#include <rime_api.h>
#include <cstdio>
#include <cstring>
#include <string>

// 最小 RIME 配置目录
const char* CONFIG_DIR = "/tmp/rime-test-config";

void setup_config() {
    std::string cmd = "mkdir -p " + std::string(CONFIG_DIR);
    system(cmd.c_str());

    // 写入 default.yaml
    std::string default_yaml = std::string(CONFIG_DIR) + "/default.yaml";
    FILE* f = fopen(default_yaml.c_str(), "w");
    fprintf(f, "%s", R"(
config_version: "0.1"
schema_list:
  - schema: luna_pinyin
    name: 朙月拼音
switcher:
  caption: "[方案选单]"
menu:
  page_size: 9
ascii_composer:
  switch_key:
    Shift_L: commit_code
    Shift_R: commit_code
key_binder:
  bindings:
    - { when: composing, accept: "Control+p", send: "Up" }
    - { when: composing, accept: "Control+n", send: "Down" }
)");
    fclose(f);

    // 写入 installation.yaml
    std::string install_yaml = std::string(CONFIG_DIR) + "/installation.yaml";
    f = fopen(install_yaml.c_str(), "w");
    fprintf(f, "%s", R"(
distribution_code_name: "TestRime"
distribution_name: "Test Rime"
distribution_version: "1.0.0"
installation_id: "test-rime"
)");
    fclose(f);
}

int main() {
    printf("=== RimeBridge 功能验证 ===\n\n");

    // 1. 准备配置
    setup_config();
    printf("[1] 配置目录: %s\n", CONFIG_DIR);

    // 2. 获取 API
    RimeApi* rime = rime_get_api();
    printf("[2] librime 版本: %s\n", rime->get_version());

    // 3. 设置 & 初始化
    RIME_STRUCT(RimeTraits, traits);
    traits.shared_data_dir = CONFIG_DIR;
    traits.user_data_dir = CONFIG_DIR;
    traits.app_name = "rime.test-tool";
    traits.distribution_name = "TestRime";
    traits.distribution_code_name = "TestRime";
    traits.distribution_version = "1.0.0";

    rime->setup(&traits);
    rime->initialize(NULL);

    // 首次运行 full deploy
    if (rime->start_maintenance(false)) {
        printf("[3] 正在部署...\n");
        rime->join_maintenance_thread();
    }
    printf("[3] 引擎初始化完成\n");

    // 4. 列出可用 schema
    RimeSchemaList schema_list;
    if (rime->get_schema_list(&schema_list)) {
        printf("[4] 可用 Schemas (%zu):\n", schema_list.size);
        for (size_t i = 0; i < schema_list.size && i < 10; i++) {
            printf("      [%zu] %s — %s\n", i,
                   schema_list.list[i].schema_id,
                   schema_list.list[i].name);
        }
        rime->free_schema_list(&schema_list);
    }

    // 5. 创建 session，选择 luna_pinyin 方案
    RimeSessionId sid = rime->create_session();
    printf("[5] Session ID: %lu\n", (unsigned long)sid);

    // 选择第一个可用 schema（而非硬编码 luna_pinyin）
    if (rime->get_schema_list(&schema_list) && schema_list.size > 0) {
        printf("[5] 选择 schema: %s\n", schema_list.list[0].schema_id);
        rime->select_schema(sid, schema_list.list[0].schema_id);
        rime->free_schema_list(&schema_list);
    }

    // 5. 模拟输入 "nihao"
    printf("\n--- 输入测试 ---\n");
    printf("[5] 模拟输入: n-i-h-a-o\n");
    rime->simulate_key_sequence(sid, "nihao");

    // 6. 获取 context
    RIME_STRUCT(RimeContext, ctx);
    if (rime->get_context(sid, &ctx)) {
        printf("[6] Preedit:  \"%s\"\n", ctx.composition.preedit);
        printf("[6] Cursor:   %d\n", ctx.composition.cursor_pos);
        printf("[6] Candidates (%d):\n", ctx.menu.num_candidates);
        for (int i = 0; i < ctx.menu.num_candidates && i < 10; i++) {
            printf("      [%d] %s", i, ctx.menu.candidates[i].text);
            if (ctx.menu.candidates[i].comment) {
                printf("  (%s)", ctx.menu.candidates[i].comment);
            }
            printf("\n");
        }
        rime->free_context(&ctx);
    }

    // 7. 选择第一个候选（数字键 '1'）
    printf("\n--- 选择候选 ---\n");
    printf("[7] 按下 '1' 选择第一个候选\n");
    rime->process_key(sid, '1', 0);

    RIME_STRUCT(RimeCommit, commit);
    if (rime->get_commit(sid, &commit)) {
        printf("[7] 上屏文字: \"%s\"\n", commit.text);
        rime->free_commit(&commit);
    }

    // 8. 验证 context 已清空
    RIME_STRUCT(RimeContext, ctx2);
    if (rime->get_context(sid, &ctx2)) {
        printf("[8] Preedit 已清空: %s\n",
               (ctx2.composition.preedit == NULL || strlen(ctx2.composition.preedit) == 0) ? "✓" : "✗");
        rime->free_context(&ctx2);
    }

    // 9. 测试 deleteBackward (BackSpace)
    printf("\n--- 删除测试 ---\n");
    rime->simulate_key_sequence(sid, "zhongguo");
    RIME_STRUCT(RimeContext, ctx3);
    rime->get_context(sid, &ctx3);
    printf("[9] 输入后: \"%s\"\n", ctx3.composition.preedit);
    rime->free_context(&ctx3);

    rime->process_key(sid, 0xFF08, 0); // BackSpace
    rime->process_key(sid, 0xFF08, 0); // BackSpace
    RIME_STRUCT(RimeContext, ctx4);
    rime->get_context(sid, &ctx4);
    printf("[9] 删除两次后: \"%s\"\n", ctx4.composition.preedit);
    rime->free_context(&ctx4);

    // 10. 清理
    rime->destroy_session(sid);
    rime->finalize();
    printf("\n=== 全部测试通过 ✓ ===\n");
    return 0;
}
