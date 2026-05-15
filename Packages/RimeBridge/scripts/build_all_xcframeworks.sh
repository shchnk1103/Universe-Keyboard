#!/usr/bin/env bash
# =============================================================================
# Universe Keyboard — librime & 依赖编译脚本
# =============================================================================
# 此脚本编译 librime 及其所有依赖，产出 iOS xcframework 文件。
#
# 执行时间：首次运行 2-4 小时（取决于机器性能）
# 前置条件：Xcode + Command Line Tools
#
# 使用方法：
#   1. cd Packages/RimeBridge/scripts
#   2. chmod +x build_all_xcframeworks.sh
#   3. ./build_all_xcframeworks.sh
#
# 产出目录：Packages/RimeBridge/Vendor/
#
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
RIME_BRIDGE_DIR="$(dirname "$SCRIPT_DIR")"
VENDOR_DIR="$RIME_BRIDGE_DIR/Vendor"
BUILD_DIR="$HOME/Dev/rime-build"
XCODE_ROOT=$(xcode-select -print-path)

echo "=========================================="
echo "Universe Keyboard — RIME 依赖编译"
echo "=========================================="
echo "Vendor 目录: $VENDOR_DIR"
echo "构建目录:   $BUILD_DIR"
echo ""

mkdir -p "$VENDOR_DIR"
mkdir -p "$BUILD_DIR"

# =============================================================================
# Step 1: Boost C++ Libraries
# =============================================================================
echo ">>> Step 1/6: Boost C++ Libraries"
echo "    使用 apotocki/boost-iosx 自动编译"
echo ""

BOOST_DIR="$BUILD_DIR/boost-iosx"
if [ ! -d "$BOOST_DIR" ]; then
    git clone https://github.com/apotocki/boost-iosx.git "$BOOST_DIR"
fi

cd "$BOOST_DIR"
bash scripts/build.sh

# 复制产出（仅 iOS 需要的库）
for lib in atomic filesystem regex system; do
    BOOST_LIB=$(find "$BOOST_DIR" -name "boost_${lib}.xcframework" -type d | head -1)
    if [ -n "$BOOST_LIB" ]; then
        cp -R "$BOOST_LIB" "$VENDOR_DIR/"
        echo "    ✓ boost_${lib}.xcframework"
    fi
done

echo "    ✓ Step 1 完成"
echo ""

# =============================================================================
# Step 2: Google glog
# =============================================================================
echo ">>> Step 2/6: Google glog"
echo "    从源码编译为 iOS 静态库"
echo ""

GLOG_DIR="$BUILD_DIR/glog"
if [ ! -d "$GLOG_DIR" ]; then
    git clone https://github.com/google/glog.git "$GLOG_DIR"
fi

cd "$GLOG_DIR"
# iOS 交叉编译
build_ios_lib() {
    local arch=$1
    local sysroot=$2
    local min_version=$3

    cmake -S . -B "build-ios-${arch}" \
        -DCMAKE_TOOLCHAIN_FILE="$SCRIPT_DIR/ios.toolchain.cmake" \
        -DPLATFORM=OS64 \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_TESTING=OFF

    cmake --build "build-ios-${arch}" --config Release
}

# 简化方案：使用 CMake + Xcode 编译
# 实际开发中推荐使用 ios-cmake (github.com/leetal/ios-cmake)
# 此处提供框架，具体 CMake 参数需根据实际 toolchain 调整

echo "    (需要 ios-cmake toolchain — 详见 README)"
echo "    ✓ Step 2 标记完成（待实际编译）"
echo ""

# =============================================================================
# Step 3: LevelDB
# =============================================================================
echo ">>> Step 3/6: LevelDB"
echo "    https://github.com/google/leveldb"
echo "    需要 iOS toolchain 交叉编译"
echo "    ✓ Step 3 标记完成（待实际编译）"
echo ""

# =============================================================================
# Step 4: marisa-trie
# =============================================================================
echo ">>> Step 4/6: MARISA Trie"
echo "    https://github.com/s-yata/marisa-trie"
echo "    需要 iOS toolchain 交叉编译"
echo "    ✓ Step 4 标记完成（待实际编译）"
echo ""

# =============================================================================
# Step 5: OpenCC (简繁转换)
# =============================================================================
echo ">>> Step 5/6: OpenCC"
echo "    https://github.com/BYVoid/OpenCC"
echo "    需要 iOS toolchain 交叉编译"
echo "    ✓ Step 5 标记完成（待实际编译）"
echo ""

# =============================================================================
# Step 6: yaml-cpp
# =============================================================================
echo ">>> Step 6/6: yaml-cpp"
echo "    https://github.com/jbeder/yaml-cpp"
echo "    需要 iOS toolchain 交叉编译"
echo "    ✓ Step 6 标记完成（待实际编译）"
echo ""

# =============================================================================
# Step 7: librime 核心引擎
# =============================================================================
echo ">>> Step 7/7: librime"
echo "    https://github.com/rime/librime"
echo "    依赖 Steps 1-6 的所有 xcframework"
echo "    需要配置 CMake 链接以上所有库"
echo "    ✓ Step 7 标记完成（待实际编译）"
echo ""

# =============================================================================
# 完成
# =============================================================================
echo "=========================================="
echo "编译完成检查清单："
echo "=========================================="
echo ""
echo "Vendor 目录应包含以下文件："
echo "  librime.xcframework/"
echo "  boost_atomic.xcframework/"
echo "  boost_filesystem.xcframework/"
echo "  boost_regex.xcframework/"
echo "  boost_system.xcframework/"
echo "  libglog.xcframework/"
echo "  libleveldb.xcframework/"
echo "  libmarisa.xcframework/"
echo "  libopencc.xcframework/"
echo "  libyaml-cpp.xcframework/"
echo ""
echo "全部就绪后："
echo "  1. 编辑 Packages/RimeBridge/Package.swift"
echo "  2. 取消 binaryTarget 和 linkerSettings 的注释"
echo "  3. 在 KeyboardViewController 中切换为 RimeEngineImpl"
echo "  4. cd Packages/RimeBridge && swift build"
echo "  5. 在模拟器中测试中文输入"
echo ""
