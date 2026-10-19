#import "DocumentIdentityProxyFixture.h"

// This fixture deliberately reproduces UIKit's startup contract violation:
// a getter imported by Swift as nonoptional can return nil at runtime.
@interface KeyboardIdentityProxyFixture : NSObject <UITextDocumentProxy>
@property(nonatomic, strong, nullable) NSUUID *fixtureIdentifier;
@end

@implementation KeyboardIdentityProxyFixture
- (NSUUID *)documentIdentifier { return self.fixtureIdentifier; }
- (NSString *)documentContextBeforeInput { return nil; }
- (NSString *)documentContextAfterInput { return nil; }
- (NSString *)selectedText { return nil; }
- (UITextInputMode *)documentInputMode { return nil; }
- (BOOL)hasText { return NO; }
- (void)insertText:(NSString *)text {}
- (void)deleteBackward {}
- (void)adjustTextPositionByCharacterOffset:(NSInteger)offset {}
- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange {}
- (void)unmarkText {}
@end

id<UITextDocumentProxy> KeyboardMakeIdentityProxy(NSUUID * _Nullable identifier) {
    KeyboardIdentityProxyFixture *proxy = [KeyboardIdentityProxyFixture new];
    proxy.fixtureIdentifier = identifier;
    return proxy;
}

NSUUID * _Nullable KeyboardReadDocumentIdentifier(id<UITextDocumentProxy> proxy) {
    return proxy.documentIdentifier;
}
