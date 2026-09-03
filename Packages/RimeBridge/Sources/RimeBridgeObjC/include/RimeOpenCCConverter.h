#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Minimal testable bridge over the exact OpenCC binary linked into RimeBridge.
/// Production RIME still owns conversion during candidate generation.
@interface RimeOpenCCConverter : NSObject

+ (nullable NSString *)convertText:(NSString *)text
                        configPath:(NSString *)configPath
                             error:(NSError *_Nullable *_Nullable)error;

@end

NS_ASSUME_NONNULL_END
