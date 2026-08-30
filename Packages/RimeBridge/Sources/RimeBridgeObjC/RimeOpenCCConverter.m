#import "RimeOpenCCConverter.h"

#import <opencc.h>
#import <string.h>

static NSString *const RimeOpenCCErrorDomain = @"RimeOpenCCErrorDomain";

@implementation RimeOpenCCConverter

+ (nullable NSString *)convertText:(NSString *)text
                        configPath:(NSString *)configPath
                             error:(NSError *_Nullable *_Nullable)error {
    opencc_t converter = opencc_open(configPath.fileSystemRepresentation);
    if (converter == (opencc_t)-1) {
        if (error != NULL) {
            *error = [NSError errorWithDomain:RimeOpenCCErrorDomain code:1 userInfo:nil];
        }
        return nil;
    }

    const char *input = text.UTF8String;
    char *converted = opencc_convert_utf8(converter, input, strlen(input));
    if (converted == (char *)-1) {
        opencc_close(converter);
        if (error != NULL) {
            *error = [NSError errorWithDomain:RimeOpenCCErrorDomain code:2 userInfo:nil];
        }
        return nil;
    }

    NSString *result = [NSString stringWithUTF8String:converted];
    opencc_convert_utf8_free(converted);
    opencc_close(converter);
    if (result == nil && error != NULL) {
        *error = [NSError errorWithDomain:RimeOpenCCErrorDomain code:3 userInfo:nil];
    }
    return result;
}

@end
