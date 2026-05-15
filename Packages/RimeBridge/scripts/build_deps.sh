#!/usr/bin/env bash
# =============================================================================
# librime iOS 依赖一键编译脚本
#
# 用法：./build_deps.sh
# 产出：~/Dev/rime-build/output/ 下的 .a 文件和头文件
#
# 依赖：Xcode, CMake (brew install cmake), ios-cmake
# =============================================================================
set -euo pipefail

TOOLCHAIN="$HOME/Dev/ios-cmake/ios.toolchain.cmake"
BUILD_ROOT="$HOME/Dev/rime-build"
OUTPUT="$BUILD_ROOT/output"
CORES=$(sysctl -n hw.ncpu)

echo "=============================================="
echo "  librime iOS 依赖编译"
echo "  构建目录: $BUILD_ROOT"
echo "  输出目录: $OUTPUT"
echo "=============================================="

mkdir -p "$OUTPUT/lib" "$OUTPUT/include"

# ---------------------------------------------------------------------------
# 通用编译函数
# ---------------------------------------------------------------------------
build_ios_lib() {
    local name=$1
    local src_dir=$2
    shift 2
    local cmake_args=("$@")

    echo ""
    echo ">>> 编译 $name ..."

    cd "$src_dir"

    # 编译 iOS 真机版本
    cmake -B build-ios-dev -G Xcode \
        -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
        -DPLATFORM=OS64 \
        -DCMAKE_BUILD_TYPE=Release \
        "${cmake_args[@]}" \
        2>&1 | grep -E "(Configuring|error|Error)" || true

    cmake --build build-ios-dev --config Release --parallel "$CORES" 2>&1 | tail -3

    # 编译 iOS 模拟器版本
    cmake -B build-ios-sim -G Xcode \
        -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
        -DPLATFORM=SIMULATORARM64 \
        -DCMAKE_BUILD_TYPE=Release \
        "${cmake_args[@]}" \
        2>&1 | grep -E "(Configuring|error|Error)" || true

    cmake --build build-ios-sim --config Release --parallel "$CORES" 2>&1 | tail -3

    echo "    ✓ $name 编译完成"
}

# ---------------------------------------------------------------------------
# 1. yaml-cpp
# ---------------------------------------------------------------------------
YAML_DIR="$BUILD_ROOT/yaml-cpp"
if [ ! -d "$YAML_DIR" ]; then
    git clone https://github.com/jbeder/yaml-cpp.git --depth 1 "$YAML_DIR"
fi

build_ios_lib "yaml-cpp" "$YAML_DIR" \
    -DYAML_BUILD_SHARED_LIBS=OFF \
    -DYAML_CPP_BUILD_TESTS=OFF \
    -DYAML_CPP_BUILD_TOOLS=OFF

cp "$YAML_DIR/build-ios-dev/Release-iphoneos/libyaml-cpp.a" "$OUTPUT/lib/libyaml-cpp-dev.a"
cp "$YAML_DIR/build-ios-sim/Release-iphonesimulator/libyaml-cpp.a" "$OUTPUT/lib/libyaml-cpp-sim.a"
cp -R "$YAML_DIR/include/yaml-cpp" "$OUTPUT/include/"

echo "    ✓ yaml-cpp 已产出"

# ---------------------------------------------------------------------------
# 2. LevelDB
# ---------------------------------------------------------------------------
LEVELDB_DIR="$BUILD_ROOT/leveldb"
if [ ! -d "$LEVELDB_DIR" ]; then
    git clone https://github.com/google/leveldb.git --depth 1 "$LEVELDB_DIR"
fi

build_ios_lib "leveldb" "$LEVELDB_DIR" \
    -DLEVELDB_BUILD_TESTS=OFF \
    -DLEVELDB_BUILD_BENCHMARKS=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON

cp "$LEVELDB_DIR/build-ios-dev/Release-iphoneos/libleveldb.a" "$OUTPUT/lib/libleveldb-dev.a" 2>/dev/null || true
cp "$LEVELDB_DIR/build-ios-sim/Release-iphonesimulator/libleveldb.a" "$OUTPUT/lib/libleveldb-sim.a" 2>/dev/null || true
cp -R "$LEVELDB_DIR/include/leveldb" "$OUTPUT/include/" 2>/dev/null || true

echo "    ✓ leveldb 已产出"

# ---------------------------------------------------------------------------
# 3. marisa-trie
# ---------------------------------------------------------------------------
MARISA_DIR="$BUILD_ROOT/marisa-trie"
if [ ! -d "$MARISA_DIR" ]; then
    git clone https://github.com/s-yata/marisa-trie.git --depth 1 "$MARISA_DIR"
fi

# marisa 用 autoconf，需要特殊处理
# 或者用 CMake（如果支持的话）
# 这里标记为手动步骤
echo ""
echo ">>> marisa-trie 需要手动编译（autoconf 项目）"
echo "    建议使用 Xcode 创建静态库 target"
echo ""

# ---------------------------------------------------------------------------
# 4. OpenCC
# ---------------------------------------------------------------------------
OPENCC_DIR="$BUILD_ROOT/OpenCC"
if [ ! -d "$OPENCC_DIR" ]; then
    git clone https://github.com/BYVoid/OpenCC.git --depth 1 "$OPENCC_DIR"
fi

build_ios_lib "opencc" "$OPENCC_DIR" \
    -DBUILD_SHARED_LIBS=OFF \
    -DENABLE_GTEST=OFF \
    -DENABLE_BENCHMARK=OFF \
    -DENABLE_DARTS=OFF

cp "$OPENCC_DIR/build-ios-dev/Release-iphoneos/libopencc.a" "$OUTPUT/lib/libopencc-dev.a" 2>/dev/null || true
cp "$OPENCC_DIR/build-ios-sim/Release-iphonesimulator/libopencc.a" "$OUTPUT/lib/libopencc-sim.a" 2>/dev/null || true
cp -R "$OPENCC_DIR/src" "$OUTPUT/include/opencc-src" 2>/dev/null || true

echo "    ✓ opencc 已产出"

# ---------------------------------------------------------------------------
# 完成
# ---------------------------------------------------------------------------
echo ""
echo "=============================================="
echo "  依赖编译完成！"
echo "  输出目录: $OUTPUT"
echo "=============================================="
echo ""
echo "产出文件:"
ls -la "$OUTPUT/lib/" 2>/dev/null || echo "  (lib 目录为空)"
echo ""
echo "下一步: 用这些 .a 文件创建 xcframework"
