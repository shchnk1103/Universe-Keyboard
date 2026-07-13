#import <Foundation/Foundation.h>

// SwiftPM 的 Objective-C target 使用这个 umbrella header 向 Swift 导出稳定接口。
// 新增桥接类必须在这里显式列出，避免不同架构的 Xcode 增量构建依赖头文件扫描缓存。
#import "RimeDeployer.h"
#import "RimeSessionManager.h"
#import "RimeUserDataSynchronizer.h"
#import "rime_api.h"
