# JAdbid iOS SDK 集成指南与示例

本仓库提供 JAdbid iOS SDK 的对外集成说明，以及 Objective-C、Swift 两个示例工程。SDK 二进制、CocoaPods Podspec 和 Swift Package 清单由独立的 [JAdbid iOS SDK 发布仓库](https://github.com/jiguangads/jadbid-ios-sdk)提供，本仓库不包含 SDK 或第三方广告 SDK 二进制。

> `jadbid-1.0.0-beta` 使用 SwiftPM Tag `1.0.0-beta`。两份 Demo 的 Podfile 仍固定历史提交 `ae9cabf2dae1a389cc7943d149011bfbce3bbcb5`；它们不是 beta SPM 工程，也不代表本次会发布 CocoaPods beta。

## 内容

- [SDK 集成说明](docs/integration.md)：环境、依赖、隐私、资源和初始化要求。
- [Objective-C / Swift Demo 说明](demo/README.md)：工程结构、配置与运行步骤。
- [Objective-C Demo](demo/oc/Sample.xcodeproj) 与 [Swift Demo](demo/swift-demo/Sample.xcodeproj)：两个独立 Xcode 工程。

两个 Demo 默认使用空的 App ID 和广告位，不会在启动时自动初始化 SDK 或请求广告。配置由集成方在本地填写；不要把正式凭据、设备标识或真实广告位提交到公开仓库。

最低支持 iOS 15。示例 Podfile 列出 Core 加 11 个可选广告源适配器及其厂商依赖，用于全源集成检查；实际业务应用应只选择需要的广告源。构建成功不代表广告填充、展示及回调已经通过真机验证。

两语言旧提交的远端 CocoaPods 安装与模拟器 App 构建证据见[Demo验证说明](demo/README.md#旧公开候选的实际验证)。beta 的 SwiftPM 双语言及 11 源消费与该历史 Demo 工程分开验收；本仓库不包含 SDK/第三方二进制、Internal Demo 或实际广告配置。
