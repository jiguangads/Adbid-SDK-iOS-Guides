import JAdbidCore
import UIKit

/// 输出Demo白名单日志；不访问UI或改变SDK状态，可从任意线程调用。
/// - Parameters:
///   - stage: 有限首方阶段，未识别值记录unknown。
///   - format: sdk或五种广告类型，未识别值记录unknown。
///   - code: 0表示普通事件；非零值只保留已知首方错误码。
///   - reason: 首方归一化原因，未识别值记录unknown，不接受原始错误正文。
///   - debugEnabled: 既有运行时开关；Demo Debug始终可见，Release普通事件依该值。
func sampleConsoleLog(_ stage: String, format: String = "sdk", code: Int = 0,
                      reason: String = "unknown", debugEnabled: Bool) {
  var enabled = debugEnabled
  #if DEBUG
    enabled = true
  #endif
  guard enabled || code != 0 else { return }
  let stages: Set<String> = ["initialize.begin", "initialize.success", "initialize.failure", "load.begin",
    "load.success", "load.failure", "show.success", "show.failure", "click", "close", "video.start",
    "video.end", "reward", "banner.size"]
  let formats: Set<String> = ["sdk", "banner", "interstitial", "rewarded", "native", "splash"]
  let codes: Set<Int> = [1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 9999]
  let reasons: Set<String> = ["noFill", "networkUnavailable", "requestTimeout", "notInitialized", "notPrepared",
    "invalidAppID", "invalidLoadParameters", "invalidRenderSize", "alreadyLoading", "requestInProgress",
    "adNotReady", "notReady", "destroyed", "adSourceUnavailable", "adapterMissing", "unknown", "renderFailed"]
  let safeStage = stages.contains(stage) ? stage : "unknown"
  let safeFormat = formats.contains(format) ? format : "unknown"
  let level = code != 0 ? "error" : (safeStage.hasSuffix(".begin") ? "debug" : "info")
  var parts = ["[JAdbidDemo]", "level=\(level)", "stage=\(safeStage)", "format=\(safeFormat)"]
  if code != 0 {
    let safeCode = codes.contains(code) ? code : 9999
    let safeReason = codes.contains(code) && reasons.contains(reason) ? reason : "unknown"
    parts.append("code=\(safeCode)")
    parts.append("reason=\(safeReason)")
  }
  NSLog("%@", parts.joined(separator: " "))
}


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
    #if DEBUG
      config.debugMode = true
    #endif
    sampleConsoleLog("initialize.begin", debugEnabled: config.debugMode)
    JAdManager.shared().initialize(config: config) { [weak self] error in
      DispatchQueue.main.async {
        guard let self else { return }
        self.initializing = false
        if let error {
          sampleConsoleLog("initialize.failure", code: (error as NSError).code,
                           debugEnabled: JAdManager.shared().debugMode)
          self.lastInitializationResult = "初始化失败：\((error as NSError).code)"
        } else {
          sampleConsoleLog("initialize.success", debugEnabled: JAdManager.shared().debugMode)
          self.lastInitializationResult = "SDK 初始化成功"
        }
        completion(self.lastInitializationResult)
      }
    }
  }
}
