import Foundation

/// 公开示例只从随包的空配置读取测试输入，不内置广告位或账号。
struct SampleConfiguration {
  private let values: [String: String]

  init(bundle: Bundle = .main) {
    guard let url = bundle.url(forResource: "SampleConfig", withExtension: "plist"),
          let data = try? Data(contentsOf: url),
          let object = try? PropertyListSerialization.propertyList(from: data, format: nil),
          let values = object as? [String: String] else {
      self.values = [:]
      return
    }
    self.values = values
  }

  var appID: String { values["AppID"]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }

  func adUnitID(for key: String) -> String {
    values[key]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
  }
}
