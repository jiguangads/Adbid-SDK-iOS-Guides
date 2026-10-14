import JAdbidCore
import UIKit

@main
final class SampleAppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = UINavigationController(rootViewController: SampleHomeViewController())
    window.makeKeyAndVisible()
    self.window = window
    // 启动仅显示入口，不在这里申请权限、初始化 SDK 或请求广告。
    return true
  }
}
