# JAdbid iOS SDK 集成说明

本文面向 JAdbid iOS SDK 1.0.0。最低支持 iOS 15；SDK 包含 Core 和 11 个按需选择的广告源 Adapter。当前公开 SDK 仓库尚未发布 1.0.0 Tag，下列远端安装步骤须待正式发布后执行。

## CocoaPods

SDK 发布后，在应用的 Podfile 中添加需要的模块，并执行 `pod install`：

```ruby
platform :ios, '15.0'

target 'YourApp' do
  pod 'JAdbidSDK/Core', :git => 'https://github.com/jiguangads/jadbid-ios-sdk.git', :tag => '1.0.0'
  # 按需添加，例如：
  # pod 'JAdbidSDK/AdMob', :git => 'https://github.com/jiguangads/jadbid-ios-sdk.git', :tag => '1.0.0'
end
```

使用 Adapter subspec 时，Core 和对应厂商 SDK 由 Podspec 声明的依赖解析；不要再手工重复添加同一 Adapter。宿主保留 `$(inherited)` 和 `-ObjC`。CocoaPods Trunk 正式发布后，也可改为按版本号安装，但应以届时可解析的正式版本为准。

## Swift Package Manager

SDK 发布后，在 Xcode 添加 `https://github.com/jiguangads/jadbid-ios-sdk.git`，选择正式版本 Tag 及 `JAdbidCore` 或所需的 `JAdbid<Source>` 产品。当前 Package.swift 只声明 JAdbid 二进制产品，所选广告源的厂商 SDK 及传递依赖仍需由宿主按锁定版本添加；不能把“选中 Adapter”理解成厂商依赖已自动接入。

SPM 集成还须把 SDK 发布包 `Resources` 内的静态资源复制到宿主主 Bundle，且应在签名前完成。请按正式发布包的资源目录与隐私清单逐项核对。未验证的厂商依赖组合不应作为已支持配置发布。

## 手动集成

从正式发布仓库的对应 Tag 获取 `JAdbidCore.xcframework` 和所选 Adapter XCFramework。JAdbid 静态框架选择 **Do Not Embed**；厂商动态框架依其官方要求 **Embed & Sign**。复制发布包 `Resources` 内容到宿主主 Bundle，保留第三方许可和隐私清单。

## 初始化、隐私与广告生命周期

宿主先完成适用的隐私流程，再显式初始化 JAdbid。ATT 提示和 `NSUserTrackingUsageDescription` 由宿主负责；SDK 示例不会代替用户授权。按广告样式持有广告对象，以复用有效缓存；页面真正退出时再销毁。开屏广告使用宿主 `UIWindow`；Banner 和 Native 在加载前设置尺寸。

公开日志和回调只应使用 JAdbid 公共信息。不要记录 IDFA、App ID、广告位、请求体、原始厂商对象或令牌。最终 App 的隐私申报仍由宿主审核。

## 验证边界

先验证依赖解析、资源、无广告启动、所选广告源的设备/模拟器构建，再在真实设备及已配置的广告平台后台验证加载、可见展示、曝光和回调。Demo 的成功构建不等同于真实广告验收。
