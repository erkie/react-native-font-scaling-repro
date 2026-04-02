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
    RCTBundleURLProvider.sharedSettings().jsLocation = "localhost:8082"
    return RCTBundleURLProvider.sharedSettings()
      .jsBundleURL(forBundleRoot: "index.share")
#else
    Bundle.main.url(forResource: "main", withExtension: "jsbundle")
#endif
  }
}
