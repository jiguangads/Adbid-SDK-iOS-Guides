# JAdbid iOS SDK 集成说明

本文面向 JAdbid `jadbid-1.0.0-beta.5`。最低支持 iOS 15；SDK 包含 Core 和 11 个按需选择的广告源 Adapter。本版基于 Jenkins build 5 的 Release 二进制，包内版本为 `1.0.0`；对应分发 Tag 为 `1.0.0-beta.5`，是否已发布须核对 GitHub Tag 与 Trunk 索引。旧 Tag 与旧 CocoaPods Pod 不变。

## CocoaPods（beta.5，以 Trunk 索引为准）

新 Pod `JAdbid 1.0.0-beta.5` 经 Trunk 登记及索引收录后，在应用的 Podfile 中按需添加模块，并执行 `pod install`：

```ruby
platform :ios, '15.0'

target 'YourApp' do
  pod 'JAdbid/Core', '1.0.0-beta.5'
  # 按需添加，例如：
  # pod 'JAdbid/AdMob', '1.0.0-beta.5'
end
```

使用 Adapter subspec 时，Core 和对应厂商 SDK 由 Podspec 声明的依赖解析；不要再手工重复添加同一 Adapter。宿主保留 `$(inherited)` 和 `-ObjC`。上述精确版本写法不能代替 Trunk 索引与实际远端消费验证。已发布旧 Pod 的版本继续按旧名称安装，不会自动切换。

## Swift Package Manager

在 Xcode 添加 `https://github.com/jiguangads/jadbid-ios-sdk.git`；确认远端 Tag 可解析后精确选择 `1.0.0-beta.5`，包展示名为 `JAdbid`，产品仍选择 `JAdbidCore` 或一个待测 `JAdbid<Source>`。Package.swift 只声明 JAdbid 二进制产品，所选广告源的厂商 SDK 及传递依赖仍需宿主按厂商契约单独添加；不能把“选中 Adapter”理解成厂商依赖已自动接入。全源验收须让 11 个源分别进入单源宿主，不是同一 App 多源同装。

纯 SPM AdMob 单源宿主须在 App target 中额外链接下列两个官方产品；这是 build 5 本地验收使用的精确版本，不代表未来厂商版本自动兼容：

- `https://github.com/googleads/swift-package-manager-google-mobile-ads.git`，产品 `GoogleMobileAds`，`exactVersion 13.7.0`。
- `https://github.com/googleads/swift-package-manager-google-user-messaging-platform.git`，产品 `GoogleUserMessagingPlatform`，`exactVersion 3.1.0`。

SPM 集成还须在签名前把 SDK `Resources` 中的 TradPlus 资源及所选厂商要求的主 Bundle 资源复制到宿主。SDK 仓的 `copy_resources.py` 支持 `--resources`、`--destination`、`--source`、`--integration`、`--vendor-root`、`--verify-final`；先查看 `--help`，再按选中的广告源和实际厂商安装目录调用，并检查最终 App 产物。纯 SPM AdMob 应传 `--source AdMob --integration spm`：Google 官方 SPM 产品不包含 Pods 生成的 `GoogleMobileAdsResources.bundle`、`UserMessagingPlatformResources.bundle`，不要求从其安装目录复制两者；仍须检查最终 App 中 Google 框架资源与隐私清单。CocoaPods 正常安装会处理其资源，无需额外运行脚本；只有手工用脚本核验 Pods 来源资源时传 `--integration pods`，仍核验两只 Pods 主 Bundle。当前脚本一次只支持一个源，且会拒绝已有的其它源资源，不能通过顺序调用完成同 App 多源接入。最终 App 隐私清单与申报由宿主审核。

## 手动集成

确认远端 Tag 可解析后，从 `1.0.0-beta.5` 获取 `JAdbidCore.xcframework` 和所选 Adapter XCFramework。JAdbid 静态框架选择 **Do Not Embed**；厂商动态框架依其官方要求 **Embed & Sign**。复制发布包 `Resources` 内容到宿主主 Bundle，保留第三方许可和隐私清单。旧提交 `ae9cabf2dae1a389cc7943d149011bfbce3bbcb5` 仅供历史联调回溯。

## 初始化、隐私与广告生命周期

宿主先完成适用的隐私流程，再显式初始化 JAdbid。ATT 提示和 `NSUserTrackingUsageDescription` 由宿主负责；SDK 示例不会代替用户授权。按广告样式持有广告对象，以复用有效缓存；页面真正退出时再销毁。开屏广告使用宿主 `UIWindow`；Banner 和 Native 在加载前设置尺寸。

公开日志和回调只应使用 JAdbid 公共信息。不要记录 IDFA、App ID、广告位、请求体、原始厂商对象或令牌。最终 App 的隐私申报仍由宿主审核。

## 验证边界

先验证依赖解析、资源、无广告启动、所选广告源的设备/模拟器构建，再在真实设备及已配置的广告平台后台验证加载、可见展示、曝光和回调。Demo 的成功构建不等同于真实广告验收。

## 联调日志与候选身份

初始化前设置config.debugMode（或使用Manager同名开关）可启用普通日志；两语言Demo在Debug显式打开，Release普通事件默认关闭，精简错误仍可见。SDK前缀[JAdbid]、Demo前缀[JAdbidDemo]分别表示加载生命周期和示例操作；日志使用有限首方阶段/原因，不输出IDFA、App ID、广告位、原始错误字典、令牌或厂商对象。屏幕显示的广告源信息不直接拼入控制台事件。

初始化一次build.identity诊断与包内BuildIdentity.json对应，包含SDK/后端版本、source revision/digest、dirty、Debug/Release、构建号和有限模块摘要。beta.5 基于干净源码的 Jenkins build 5 二进制；Demo Podfile 指向本版 Tag，不能再按旧 build 29 的安装结果推断本版验收已通过。该身份不是签名或真机广告成功证明。

加载中继续等待明确成功/失败；真实失败仍结束本次请求，后台自动加载后的新可用性通知尚未实现。公开Demo的隐私确认只是宿主流程操作，不等于ATT或其他系统授权，不新增Internal的ATT/IDFA诊断页。
