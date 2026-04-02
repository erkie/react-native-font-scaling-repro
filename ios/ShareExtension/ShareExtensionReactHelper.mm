//
//  ShareExtensionReactHelper.mm
//  Minimal helper to bootstrap React Native in an iOS Share Extension (RN 0.84+, New Architecture).
//
//  This file demonstrates the bug: RCTFontSizeMultiplier() returns 0 in app extensions
//  because UIApplication.sharedApplication is nil, causing all custom-font text to be invisible.

#import "ShareExtensionReactHelper.h"
#import <objc/runtime.h>
#import <React/RCTBridge.h>
#import <React/RCTViewManager.h>
#import <React-RCTAppDelegate/RCTRootViewFactory.h>
#import <React-RCTAppDelegate/RCTAppSetupUtils.h>
#import <React/RCTComponentViewFactory.h>
#import <ReactAppDependencyProvider/RCTAppDependencyProvider.h>
#import <ReactCommon/RCTTurboModuleManager.h>
#import <React/CoreModulesPlugins.h>
#import <react/nativemodule/defaults/DefaultTurboModules.h>
#import <react/featureflags/ReactNativeFeatureFlags.h>
#import <react/featureflags/ReactNativeFeatureFlagsDefaults.h>

// Hermes JS runtime factory
extern "C" JSRuntimeFactoryRef jsrt_create_hermes_factory(void);

#pragma mark - Feature Flags Override

class ShareExtensionFeatureFlags : public facebook::react::ReactNativeFeatureFlagsDefaults {
public:
  bool enableBridgelessArchitecture() override { return true; }
  bool enableFabricRenderer() override { return true; }
  bool useTurboModules() override { return true; }
  bool useNativeViewConfigsInBridgelessMode() override { return true; }
};

__attribute__((constructor(101)))
static void shareExtensionSetupFeatureFlags() {
  try {
    facebook::react::ReactNativeFeatureFlags::override(
        std::make_unique<ShareExtensionFeatureFlags>());
  } catch (...) {
    // Flags may already be overridden
  }
}

#pragma mark - JS Runtime Configurator

@interface ShareExtensionJSConfigurator : NSObject <RCTJSRuntimeConfiguratorProtocol>
@end

@implementation ShareExtensionJSConfigurator
- (JSRuntimeFactoryRef)createJSRuntimeFactory {
  return jsrt_create_hermes_factory();
}
@end

#pragma mark - TurboModule Manager Delegate

@interface ShareExtensionTMDelegate : NSObject <RCTTurboModuleManagerDelegate>
@end

@implementation ShareExtensionTMDelegate
- (Class)getModuleClassFromName:(const char *)name {
  return RCTCoreModulesClassProvider(name);
}

- (id<RCTTurboModule>)getModuleInstanceFromClass:(Class)moduleClass {
  return RCTAppSetupDefaultModuleFromClass(moduleClass, nil);
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const std::string &)name
                                                      jsInvoker:(std::shared_ptr<facebook::react::CallInvoker>)jsInvoker {
  return facebook::react::DefaultTurboModules::getTurboModule(name, jsInvoker);
}
@end

#pragma mark - Factory Helper

@interface ShareExtensionReactHelper () <RCTComponentViewFactoryComponentProvider>
@property (nonatomic, strong) ShareExtensionJSConfigurator *jsConfigurator;
@property (nonatomic, strong) ShareExtensionTMDelegate *tmDelegate;
@property (nonatomic, strong) RCTAppDependencyProvider *dependencyProvider;
@end

@implementation ShareExtensionReactHelper

- (RCTRootViewFactory *)createRootViewFactoryWithBundleURL:(NSURL *)bundleURL {
  RCTEnableTurboModuleInterop(YES);
  RCTEnableTurboModuleInteropBridgeProxy(YES);

  RCTRootViewFactoryConfiguration *config =
      [[RCTRootViewFactoryConfiguration alloc] initWithBundleURLBlock:^NSURL *{
        return bundleURL;
      } newArchEnabled:YES];

  self.jsConfigurator = [[ShareExtensionJSConfigurator alloc] init];
  config.jsRuntimeConfiguratorDelegate = self.jsConfigurator;

  self.tmDelegate = [[ShareExtensionTMDelegate alloc] init];
  self.dependencyProvider = [[RCTAppDependencyProvider alloc] init];

  [RCTComponentViewFactory currentComponentViewFactory].thirdPartyFabricComponentsProvider = self;

  return [[RCTRootViewFactory alloc] initWithConfiguration:config
                          andTurboModuleManagerDelegate:self.tmDelegate];
}

#pragma mark - RCTComponentViewFactoryComponentProvider

- (NSDictionary<NSString *, Class<RCTComponentViewProtocol>> *)thirdPartyFabricComponents {
  return self.dependencyProvider.thirdPartyFabricComponents;
}

@end
