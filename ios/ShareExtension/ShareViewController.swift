import UIKit
import React
import React_RCTAppDelegate

class ShareViewController: UIViewController {
  private var reactHelper: ShareExtensionReactHelper?
  private var rootViewFactory: RCTRootViewFactory?

  override func viewDidLoad() {
    super.viewDidLoad()

    let helper = ShareExtensionReactHelper()
    self.reactHelper = helper
    guard let factory = helper.createRootViewFactory(withBundleURL: bundleURL()) else { return }
    self.rootViewFactory = factory

    let rootView = factory.view(withModuleName: "FontScalingReproShare", initialProperties: [:])
    rootView.backgroundColor = .white
    self.view = rootView
  }

  private func bundleURL() -> URL? {
#if DEBUG
    // Use port 8082 to avoid conflicts with the main app's Metro on 8081
    RCTBundleURLProvider.sharedSettings()
      .jsBundleURL(forBundleRoot: "index.share", bundleURLScheme: nil)
#else
    Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
  }
}
