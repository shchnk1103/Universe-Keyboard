#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// UIKit can return nil while constructing its document interface. Read in
// Objective-C so Swift receives Optional<UUID>, without an unconditional bridge.
FOUNDATION_EXPORT NSUUID * _Nullable KeyboardReadDocumentIdentifier(id<UITextDocumentProxy> proxy);

NS_ASSUME_NONNULL_END
