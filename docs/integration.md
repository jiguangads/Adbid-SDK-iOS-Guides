# JAdbid iOS SDK 1.0.0 集成说明

快速操作看[快速集成](quick-start.md)，接口与回调看 [API 参考](api-reference.md)，常见问题看 [FAQ](faq.md)，定位错误看[问题排查](troubleshooting.md)，提交问题看[技术支持手册](technical-support.md)。

最低支持 iOS 15.0，提供 Core 与 11 个可选广告源 Adapter。设备和模拟器均为 arm64；不支持 x86_64 模拟器。JAdbid XCFramework 为静态框架，只链接，不作为动态框架嵌入。

## CocoaPods

在应用 Podfile 中选择需要的模块，然后执行 `pod install`：

```ruby
platform :ios, '15.0'

target 'YourApp' do
  pod 'JAdbid/Core', '1.0.0'
  # 按需选择一个广告源，例如：
  # pod 'JAdbid/AdMob', '1.0.0'
end
```

Adapter subspec 会依赖同版本 Core 和对应的厂商 SDK，无需重复添加同一模块。保留宿主已有的 `$(inherited)` 与 `-ObjC`。CocoaPods 按 Podspec 锁定厂商版本并处理其资源。

本版本的 Pod 配置将模拟器构建限制为 arm64，并在 Pod target 排除 x86_64。模拟器 `ARCHS` 设置也会影响同一宿主与其它 Pods；若 App target 自行覆盖该设置，应保持 arm64。真机架构不受此模拟器配置影响。

## Swift Package Manager

在 Xcode 添加 `https://github.com/jiguangads/jadbid-ios-sdk.git`，精确选择版本 **1.0.0**，包名为 `JAdbid`。按需选择 `JAdbidCore` 或一个 `JAdbid<Source>` 产品。

SwiftPM 清单仅声明 JAdbid 的二进制产品，**不会自动安装厂商 SDK**。所选广告源的官方产品及传递依赖须由宿主单独添加，固定为兼容版本，不用浮动分支替代精确依赖。本文的资源脚本说明按单一广告源配置，不通过多次调用叠加不同源。

### 厂商产品与固定版本

在 Xcode 添加下表中的官方包，版本规则选择精确版本，并将对应产品加入 App target。只添加所选广告源的行；AdMob 的两行均需添加。下表是本指南对应的固定接入配置，不表示厂商最新版本。

| 广告源 | 官方 SwiftPM 包 | 精确版本 | App target 产品 |
| --- | --- | --- | --- |
| AdMob | [swift-package-manager-google-user-messaging-platform](https://github.com/googleads/swift-package-manager-google-user-messaging-platform.git) | `3.1.0` | `GoogleUserMessagingPlatform` |
| AdMob | [swift-package-manager-google-mobile-ads](https://github.com/googleads/swift-package-manager-google-mobile-ads.git) | `13.7.0` | `GoogleMobileAds` |
| Bigo | [BigoADS-Swift-Package](https://github.com/bigo-ads/BigoADS-Swift-Package.git) | `6.1.0` | `BigoADS` |
| Facebook | [FBAudienceNetwork](https://github.com/facebook/FBAudienceNetwork.git) | `6.22.0` | `FBAudienceNetwork` |
| Fyber | [DTExchangeSDK-iOS-SPM](https://github.com/inner-active/DTExchangeSDK-iOS-SPM.git) | `8.4.7` | `DTExchangeSDK` |
| InMobi | [InMobiSDK-Swift-Package](https://github.com/InMobi/InMobiSDK-Swift-Package.git) | `11.4.1` | `InMobiSDK` |
| IronSource | [LevelPlay-Swift-Package](https://github.com/ironsource-mobile/LevelPlay-Swift-Package.git) | `9.5.0` | `UnityMediationSDK` |
| Mintegral | [MintegralAdSDK-Swift-Package](https://github.com/Mintegral-official/MintegralAdSDK-Swift-Package.git) | `8.1.5` | `MintegralAdSDK` |
| Pangle | [AdsGlobalPackage](https://github.com/bytedance/AdsGlobalPackage.git) | `8.2.0-release.9` | `TikTokBusinessSDK` |
| Unity | [Unity-Ads-Swift-Package](https://github.com/Unity-Technologies/Unity-Ads-Swift-Package.git) | `4.19.0` | `UnityAds` |
| Vungle | [VungleAdsSDK-SwiftPackageManager](https://github.com/Vungle/VungleAdsSDK-SwiftPackageManager.git) | `7.7.6` | `VungleAdsSDK` |
| Yandex | [yandex-ads-sdk-ios](https://github.com/yandexmobile/yandex-ads-sdk-ios.git) | `8.3.0` | `YandexMobileAds` |

保留官方包解析的传递依赖和 `Package.resolved`，不要修改厂商 manifest 或用 Pods 二进制代替官方 SwiftPM 输入。Yandex 的 AppMetrica 等依赖、IronSource/Unity 的 Ad Quality 等依赖由相应包关系解析，不能只复制一个主框架。资源要求见下文的[原生 SPM 资源布局](#原生-spm-资源布局)。

纯 Objective-C 宿主选择广告源时，还需继承 `$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)` 的 Swift 库搜索路径；该路径不代替厂商 SDK 链接。

### 资源复制

在签名前将 `Resources/TradPlusAds.bundle`、`Resources/TradPlusADX.bundle` 及所选源要求的主 Bundle 复制到 App。先运行 SDK 仓库的 `python3 copy_resources.py --help` 查看参数。

示例命令中的路径需替换为实际 SDK、厂商资源和 App 目录：

```sh
python3 <SDK目录>/copy_resources.py   --resources <SDK目录>/Resources   --destination <App主目录>   --source AdMob --integration spm
```

构建后使用相同来源参数并追加 `--verify-final` 只读核对最终 App，不对已签名 App 补拷资源。脚本每次只处理一个源，会拒绝其它源资源污染；不能通过顺序调用完成同一 App 多源资源叠加。最终 App 的自动资源、框架内资源与隐私清单还需单独检查。

CocoaPods 正常安装已处理资源，无需另跑复制脚本；仅手工核对 Pods 来源资源时使用 `--integration pods`，按该渠道的实际资源布局核验。

## 原生 SPM 资源布局

所有源均需保留两只 JAdbid Core 公共 Bundle。以下是额外厂商资源要求；不得以 Pods 会生成同名 Bundle 推断官方 SwiftPM 包也包含它。

| 广告源 | 官方原生 SPM 资源要求 |
| --- | --- |
| AdMob、Facebook、Fyber、IronSource、Unity、Vungle | 不要求仅由 Pods 生成的同名主 Bundle；保留官方自动资源、框架内资源与隐私清单 |
| InMobi | 无额外主 Bundle，保留厂商资源与隐私清单 |
| Mintegral | 主目录 `MTGResources.bundle` |
| Pangle | 主目录 `PAGAdSDK.bundle` |
| Yandex | 主目录 `MobileAdsBundle.bundle`，并链接其 AppMetrica 等真实传递依赖 |
| Bigo | 按下文保留动态框架内资源及隐私清单 |

Bigo 官方原生 SwiftPM 使用 `6.1.0`。按设备或模拟器切片链接并 **Embed & Sign** `BigoADS.framework`，保留其中的 `BigoADSRes.bundle` 和 `PrivacyInfo.xcprivacy`。脚本使用 `--source Bigo --integration spm`，`--vendor-root` 指向选中的 `BigoADS.framework`；检查时目标 App 中应包含同一 `Frameworks/BigoADS.framework`。使用 `--verify-final` 对照原件核验，不生成 Pods 专用的独立 `BigoADS.bundle`。CocoaPods 的 Bigo 依赖仍为 `5.3.0`，两个渠道按各自契约处理。

## 手动集成

从公开 SDK 仓库的 `1.0.0` Tag 获取 Core 与所选 Adapter XCFramework。JAdbid 选择 **Do Not Embed**；厂商动态框架按其官方要求 **Embed & Sign**。复制 SDK Resources 和所选厂商资源，保留 Licenses 与隐私清单，资源脚本使用对应的 `--integration manual`。

## 初始化、隐私与生命周期

宿主先完成适用的隐私流程，再显式初始化 JAdbid。ATT 提示与 `NSUserTrackingUsageDescription` 由宿主负责，Demo 中的隐私确认操作不代表系统已授权。

持有广告对象以复用有效缓存，真正退出页面时销毁；开屏广告使用宿主 `UIWindow`，Banner 与 Native 在加载前设置尺寸。加载期间等待明确的成功或失败回调；加载失败结束本次请求。不要依赖后台缓存可用性变化自动触发新的加载回调。

不得记录 IDFA、真实 App ID、广告位、请求体、原始厂商对象或令牌。宿主应审核最终 App 的首方及厂商隐私清单、权限描述与隐私申报。

## 调试日志与运行检查

初始化前设置 `JAdConfig.debugMode` 可启用普通日志；具体调用见 [Objective-C 初始化示例](../demo/oc/ObjectiveC/Common/JAdbidSDKManager.m)和 [Swift 初始化示例](../demo/swift-demo/Swift/Common/SampleSession.swift)。Debug Demo 会显式开启；Release 默认关闭普通事件，保留精简错误。通过 `[JAdbid]` 和 `[JAdbidDemo]` 区分 SDK 与示例事件，不将屏幕上的原始广告信息拼入控制台日志。

先检查依赖解析、链接、资源和默认无请求启动，再使用真实设备与广告平台配置验证加载、可见展示、曝光及回调。构建成功或模拟器启动不代表实际广告效果。
