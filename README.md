# JAdbid iOS SDK 集成指南与示例

本仓库提供 JAdbid iOS SDK **1.0.0** 的集成说明和 Objective-C、Swift 示例工程。SDK 二进制、CocoaPods Podspec 与 Swift Package 清单位于 [JAdbid iOS SDK](https://github.com/jiguangads/jadbid-ios-sdk)。

## 开始集成

- [SDK 集成说明](docs/integration.md)：CocoaPods、Swift Package Manager、依赖、资源与隐私配置。
- [Demo 使用说明](demo/README.md)：示例工程、配置和运行步骤。
- [Objective-C Demo](demo/oc/Sample.xcodeproj) 与 [Swift Demo](demo/swift-demo/Sample.xcodeproj)：两个独立的 Xcode 工程。

最低支持 **iOS 15.0**。设备与模拟器均提供 arm64 切片；不支持 Intel Mac 的 x86_64 模拟器。SDK 包含 Core 和 11 个可选广告源 Adapter，业务应用按需选择。

示例 Podfile 列出全部广告源及其厂商依赖，首次安装下载量较大。实际应用应按需删减；SwiftPM 的 JAdbid 产品不自动安装厂商 SDK，需按集成说明单独添加。

Demo 默认配置为空，启动不会自动申请权限、初始化 SDK 或请求广告。请在本地填写自己的配置并完成宿主隐私流程，不要将真实广告配置、凭据或设备标识提交到公开仓库。实际广告表现需在真实设备与正确的平台配置下验证。
