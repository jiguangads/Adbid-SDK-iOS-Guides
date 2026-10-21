# JAdbid iOS SDK 集成指南与示例

本仓库提供 JAdbid iOS SDK 的对外集成说明，以及 Objective-C、Swift 两个示例工程。SDK 二进制、CocoaPods Podspec 和 Swift Package 清单由独立的 [JAdbid iOS SDK 发布仓库](https://github.com/jiguangads/jadbid-ios-sdk)提供，本仓库不包含 SDK 或第三方广告 SDK 二进制。

> 当前文档与 Demo Podfile 指向 `jadbid-1.0.0-beta.4`，CocoaPods Pod 名和 SwiftPM 包展示名均为 `JAdbid`。两份使用 Git Tag 的 Demo Podfile 在安装前须核对 GitHub Tag 可解析；按 Trunk 版本号安装的新 Pod 才需另核对 CocoaPods 索引。文档本身不证明渠道可用。beta.3 Tag 保留；截至 2026-10-21，新 Pod 未以 beta.3 上传 Trunk。旧版本与旧 Pod 的历史安装记录不受本版修改影响。

## 内容

- [SDK 集成说明](docs/integration.md)：环境、依赖、隐私、资源和初始化要求。
- [Objective-C / Swift Demo 说明](demo/README.md)：工程结构、配置与运行步骤。
- [Objective-C Demo](demo/oc/Sample.xcodeproj) 与 [Swift Demo](demo/swift-demo/Sample.xcodeproj)：两个独立 Xcode 工程。

两个 Demo 默认使用空的 App ID 和广告位，不会在启动时自动初始化 SDK 或请求广告。配置由集成方在本地填写；不要把正式凭据、设备标识或真实广告位提交到公开仓库。

最低支持 iOS 15。示例 Podfile 列出 Core 加 11 个可选广告源适配器及其厂商依赖，用于全源集成检查；实际业务应用应只选择需要的广告源。构建成功不代表广告填充、展示及回调已经通过真机验证。

两语言旧提交的远端 CocoaPods 安装与模拟器 App 构建证据见[Demo验证说明](demo/README.md#旧公开候选的实际验证)；它不是 beta.4 的验收。beta.4 对应渠道可用后，还须重新验证两份 Demo 对新 Pod 的依赖解析与 App 构建。本仓库不包含 SDK/第三方二进制、Internal Demo 或实际广告配置。
