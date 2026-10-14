import JAdbidCore
import UIKit

/// 仅保存本进程 Demo 操作状态；重启后不恢复“已同意”或广告对象。
final class SampleSession {
  static let shared = SampleSession()

  let configuration = SampleConfiguration()
  private(set) var privacyFlowCompleted = false
  private(set) var initializing = false
  private(set) var lastInitializationResult = "尚未初始化"

  private init() {}

  var initialized: Bool { JAdManager.shared().isInitialized }

  func markHostPrivacyFlowCompleted() {
    precondition(Thread.isMainThread)
    privacyFlowCompleted = true
    lastInitializationResult = "已确认宿主隐私流程完成；尚未初始化 SDK"
  }

  /// 仅由首页按钮调用；缺少宿主隐私确认或 AppID 时绝不调用 SDK 初始化。
  /// - Parameter completion: 主线程返回用于页面展示的状态，不包含 AppID。
  func initialize(completion: @escaping (String) -> Void) {
    precondition(Thread.isMainThread)
    guard privacyFlowCompleted else {
      lastInitializationResult = "请先由宿主完成隐私流程，再点击确认"
      completion(lastInitializationResult)
      return
    }
    guard !configuration.appID.isEmpty else {
      lastInitializationResult = "请先在 SampleConfig.plist 填写测试 AppID"
      completion(lastInitializationResult)
      return
    }
    guard !initialized else {
      lastInitializationResult = "SDK 已初始化"
      completion(lastInitializationResult)
      return
    }
    guard !initializing else {
      lastInitializationResult = "SDK 正在初始化，请等待结果"
      completion(lastInitializationResult)
      return
    }
    initializing = true
    lastInitializationResult = "初始化中…"
    let config = JAdConfig(appID: configuration.appID)
    JAdManager.shared().initialize(config: config) { [weak self] error in
      DispatchQueue.main.async {
        guard let self else { return }
        self.initializing = false
        if let error {
          self.lastInitializationResult = "初始化失败：\((error as NSError).code)"
        } else {
          self.lastInitializationResult = "SDK 初始化成功"
        }
        completion(self.lastInitializationResult)
      }
    }
  }
}
