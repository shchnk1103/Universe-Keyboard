# RimeBridge macOS 测试工具
# 需要: brew install librime

CXX = clang++
CXXFLAGS = -std=c++17 -Wall -O2
LDFLAGS = /opt/homebrew/opt/librime/lib/librime.dylib
INCLUDES = -I/opt/homebrew/opt/librime/include

all: test_rime

test_rime: main.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o $@ $< $(LDFLAGS)

run: test_rime
	./test_rime

clean:
	rm -f test_rime
