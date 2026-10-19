#import "KeyboardDocumentIdentity.h"

NSUUID * _Nullable KeyboardReadDocumentIdentifier(id<UITextDocumentProxy> proxy) {
    return proxy.documentIdentifier;
}
