#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT id<UITextDocumentProxy> KeyboardMakeIdentityProxy(NSUUID * _Nullable identifier);
// Same read as Keyboard/Bridge/KeyboardDocumentIdentity.m. KeyboardTests does
// not link the extension, so the fixture supplies the symbol under test.
FOUNDATION_EXPORT NSUUID * _Nullable KeyboardReadDocumentIdentifier(id<UITextDocumentProxy> proxy);
NS_ASSUME_NONNULL_END
