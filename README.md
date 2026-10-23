# JAdbid iOS SDK 集成指南与示例

本仓库提供 JAdbid iOS SDK **1.0.0** 的接入文档、技术支持手册，以及 Objective-C、Swift 示例。SDK 二进制与包声明见 [JAdbid iOS SDK](https://github.com/jiguangads/jadbid-ios-sdk)。

## 从这里开始

| 你要完成的事情 | 阅读入口 |
| --- | --- |
| 第一次接入，先运行示例 | [快速集成](docs/quick-start.md) |
| 在应用中配置 CocoaPods、SPM 或手动集成 | [完整集成指南](docs/integration.md) |
| 安装并使用 OC / Swift 示例 | [Demo 使用说明](demo/README.md) |
| 查找常见问题的简要答复 | [FAQ](docs/faq.md) |
| 根据错误现象逐步检查 | [问题排查](docs/troubleshooting.md) |
| 确认问题范围、收集材料并提交支持请求 | [技术支持手册](docs/technical-support.md) |

## 接入前确认

- 最低 **iOS 15.0**；真机、模拟器均为 **arm64**，不支持 x86_64 模拟器。
- 提供 Core 和 11 个可选广告源 Adapter。Core 是基础模块，Adapter 用于连接对应广告源；首次接入建议先选一个源。
- SwiftPM 的 JAdbid 产品不自动安装厂商 SDK；依赖、资源及框架设置统一见[完整集成指南](docs/integration.md)。
- 安装前确认所选版本在对应渠道可用；查不到版本时按 [FAQ](docs/faq.md#version) 检查，不改用不明来源的二进制。

## 示例与验证

[Objective-C Demo](demo/oc/Sample.xcodeproj) 与 [Swift Demo](demo/swift-demo/Sample.xcodeproj) 是两个独立工程。默认广告配置为空，启动不会自动申请权限、初始化 SDK 或请求广告。

先检查“构建成功 → SDK 初始化成功 → 广告加载和展示”，分别记录结果。模拟器启动成功不能代替真实设备上的广告展示及回调验证。真实配置只在本地填写，日志和截图分享前按[技术支持手册](docs/technical-support.md#materials)脱敏。
