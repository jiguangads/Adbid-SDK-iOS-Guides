# JAdbid iOS SDK 集成说明

本文面向 JAdbid iOS SDK 1.0.0。最低支持 iOS 15；SDK 包含 Core 和 11 个按需选择的广告源 Adapter。当前使用公开候选build 29，两份Demo固定SDK提交 `ae9cabf2dae1a389cc7943d149011bfbce3bbcb5`。正式1.0.0 Tag尚未发布，以下候选入口可联调，正式版本入口须待发行后验证。

## CocoaPods

候选联调时，在应用的 Podfile 中按需添加模块，并执行 `pod install`：

```ruby
platform :ios, '15.0'

target 'YourApp' do
  pod 'JAdbidSDK/Core', :git => 'https://github.com/jiguangads/jadbid-ios-sdk.git', :commit => 'ae9cabf2dae1a389cc7943d149011bfbce3bbcb5'
  # 按需添加，例如：
  # pod 'JAdbidSDK/AdMob', :git => 'https://github.com/jiguangads/jadbid-ios-sdk.git', :commit => 'ae9cabf2dae1a389cc7943d149011bfbce3bbcb5'
end
```

使用 Adapter subspec 时，Core 和对应厂商 SDK 由 Podspec 声明的依赖解析；不要再手工重复添加同一 Adapter。宿主保留 `$(inherited)` 和 `-ObjC`。正式Tag发布后才可使用 `:tag => '1.0.0'`；CocoaPods Trunk正式发布后，也可改为按版本号安装，但应以届时可解析的正式版本为准。

## Swift Package Manager

候选联调时，在Xcode添加 `https://github.com/jiguangads/jadbid-ios-sdk.git`，选择精确提交 `ae9cabf2dae1a389cc7943d149011bfbce3bbcb5` 及 `JAdbidCore` 或所需的 `JAdbid<Source>` 产品。当前 Package.swift 只声明 JAdbid 二进制产品，所选广告源的厂商 SDK 及传递依赖仍需由宿主按锁定版本添加；不能把“选中 Adapter”理解成厂商依赖已自动接入。

SPM 集成还须把 SDK 发布包 `Resources` 内的静态资源复制到宿主主 Bundle，且应在签名前完成。请按正式发布包的资源目录与隐私清单逐项核对。未验证的厂商依赖组合不应作为已支持配置发布。

## 手动集成

从公开候选提交 `ae9cabf2dae1a389cc7943d149011bfbce3bbcb5`（正式发布后才改用对应Tag）获取 `JAdbidCore.xcframework` 和所选 Adapter XCFramework。JAdbid 静态框架选择 **Do Not Embed**；厂商动态框架依其官方要求 **Embed & Sign**。复制发布包 `Resources` 内容到宿主主 Bundle，保留第三方许可和隐私清单。

## 初始化、隐私与广告生命周期

宿主先完成适用的隐私流程，再显式初始化 JAdbid。ATT 提示和 `NSUserTrackingUsageDescription` 由宿主负责；SDK 示例不会代替用户授权。按广告样式持有广告对象，以复用有效缓存；页面真正退出时再销毁。开屏广告使用宿主 `UIWindow`；Banner 和 Native 在加载前设置尺寸。

公开日志和回调只应使用 JAdbid 公共信息。不要记录 IDFA、App ID、广告位、请求体、原始厂商对象或令牌。最终 App 的隐私申报仍由宿主审核。

## 验证边界

先验证依赖解析、资源、无广告启动、所选广告源的设备/模拟器构建，再在真实设备及已配置的广告平台后台验证加载、可见展示、曝光和回调。Demo 的成功构建不等同于真实广告验收。

## 联调日志与候选身份

初始化前设置config.debugMode（或使用Manager同名开关）可启用普通日志；两语言Demo在Debug显式打开，Release普通事件默认关闭，精简错误仍可见。SDK前缀[JAdbid]、Demo前缀[JAdbidDemo]分别表示加载生命周期和示例操作；日志使用有限首方阶段/原因，不输出IDFA、App ID、广告位、原始错误字典、令牌或厂商对象。屏幕显示的广告源信息不直接拼入控制台事件。

初始化一次build.identity诊断与包内BuildIdentity.json对应，包含SDK/后端版本、source revision/digest、dirty、Debug/Release、构建号和有限模块摘要。当前候选来自干净源码构建，build29；该身份不是签名或真机广告成功证明。

加载中继续等待明确成功/失败；真实失败仍结束本次请求，后台自动加载后的新可用性通知尚未实现。公开Demo的隐私确认只是宿主流程操作，不等于ATT或其他系统授权，不新增Internal的ATT/IDFA诊断页。
