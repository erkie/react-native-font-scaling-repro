#import <UIKit/UIKit.h>

@class RCTRootViewFactory;

@interface ShareExtensionReactHelper : NSObject
- (RCTRootViewFactory *)createRootViewFactoryWithBundleURL:(NSURL * _Nullable)bundleURL;
@end
