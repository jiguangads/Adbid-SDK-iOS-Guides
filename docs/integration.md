# JAdbid iOS SDK 集成说明

本文面向 JAdbid `jadbid-1.0.0-beta.1` SwiftPM 版本。最低支持 iOS 15；SDK 包含 Core 和 11 个按需选择的广告源 Adapter。该版本由 Jenkins build 4 从源码 `4634ec06b81da7718015aebdd3b025902f153765` 构建；包内版本为 `1.0.0`，分发 Tag 为 `1.0.0-beta.1`。原 `1.0.0-beta` Tag 保留。

## CocoaPods（本次 beta 不发布）

候选联调时，在应用的 Podfile 中按需添加模块，并执行 `pod install`：

```ruby
platform :ios, '15.0'

target 'YourApp' do
  pod 'JAdbidSDK/Core', :git => 'https://github.com/jiguangads/jadbid-ios-sdk.git', :commit => 'ae9cabf2dae1a389cc7943d149011bfbce3bbcb5'
  # 按需添加，例如：
  # pod 'JAdbidSDK/AdMob', :git => 'https://github.com/jiguangads/jadbid-ios-sdk.git', :commit => 'ae9cabf2dae1a389cc7943d149011bfbce3bbcb5'
end
```

以上仅用于已公开旧提交联调。使用 Adapter subspec 时，Core 和对应厂商 SDK 由 Podspec 声明的依赖解析；不要再手工重复添加同一 Adapter。宿主保留 `$(inherited)` 和 `-ObjC`。本次不会向 CocoaPods Trunk 发布 beta，不能把当前 Podfile 当作 beta SPM 验收结果。

## Swift Package Manager

在 Xcode 添加 `https://github.com/jiguangads/jadbid-ios-sdk.git`，精确选择 `1.0.0-beta.1`，并选择 `JAdbidCore` 或一个待测 `JAdbid<Source>` 产品。Package.swift 只声明 JAdbid 二进制产品，所选广告源的厂商 SDK 及传递依赖仍需宿主按厂商契约单独添加；不能把“选中 Adapter”理解成厂商依赖已自动接入。全源验收是 11 个源分别进入单源宿主，不是同一 App 多源同装。

SPM 集成还须在签名前把 SDK `Resources` 中的 TradPlus 资源及所选厂商要求的主 Bundle 资源复制到宿主。SDK 仓的 `copy_resources.py` 支持 `--resources`、`--destination`、`--source`、`--vendor-root`、`--verify-final`；先查看 `--help`，再按选中的广告源和实际厂商安装目录调用，并检查最终 App 产物。当前脚本一次只支持一个源，且会拒绝已有的其它源资源，不能通过顺序调用完成同 App 多源接入。最终 App 隐私清单与申报由宿主审核。

## 手动集成

从 `1.0.0-beta.1` Tag 获取 `JAdbidCore.xcframework` 和所选 Adapter XCFramework。JAdbid 静态框架选择 **Do Not Embed**；厂商动态框架依其官方要求 **Embed & Sign**。复制发布包 `Resources` 内容到宿主主 Bundle，保留第三方许可和隐私清单。旧提交 `ae9cabf2dae1a389cc7943d149011bfbce3bbcb5` 仅供历史联调回溯。

## 初始化、隐私与广告生命周期

宿主先完成适用的隐私流程，再显式初始化 JAdbid。ATT 提示和 `NSUserTrackingUsageDescription` 由宿主负责；SDK 示例不会代替用户授权。按广告样式持有广告对象，以复用有效缓存；页面真正退出时再销毁。开屏广告使用宿主 `UIWindow`；Banner 和 Native 在加载前设置尺寸。

公开日志和回调只应使用 JAdbid 公共信息。不要记录 IDFA、App ID、广告位、请求体、原始厂商对象或令牌。最终 App 的隐私申报仍由宿主审核。

## 验证边界

先验证依赖解析、资源、无广告启动、所选广告源的设备/模拟器构建，再在真实设备及已配置的广告平台后台验证加载、可见展示、曝光和回调。Demo 的成功构建不等同于真实广告验收。

## 联调日志与候选身份

初始化前设置config.debugMode（或使用Manager同名开关）可启用普通日志；两语言Demo在Debug显式打开，Release普通事件默认关闭，精简错误仍可见。SDK前缀[JAdbid]、Demo前缀[JAdbidDemo]分别表示加载生命周期和示例操作；日志使用有限首方阶段/原因，不输出IDFA、App ID、广告位、原始错误字典、令牌或厂商对象。屏幕显示的广告源信息不直接拼入控制台事件。

初始化一次build.identity诊断与包内BuildIdentity.json对应，包含SDK/后端版本、source revision/digest、dirty、Debug/Release、构建号和有限模块摘要。beta.1 包来自干净源码构建，Jenkins build 4；现有公开 Demo 的旧 Podfile 仍是 build 29。该身份不是签名或真机广告成功证明。

加载中继续等待明确成功/失败；真实失败仍结束本次请求，后台自动加载后的新可用性通知尚未实现。公开Demo的隐私确认只是宿主流程操作，不等于ATT或其他系统授权，不新增Internal的ATT/IDFA诊断页。
