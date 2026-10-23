# JAdbid iOS SDK 1.0.0 API 参考

本文说明 JAdbid 的公开接口、参数、结果和回调。接口以 [1.0.0 公开头文件](https://github.com/jiguangads/jadbid-ios-sdk/blob/1.0.0/Artifacts/JAdbidCore.xcframework/ios-arm64/JAdbidCore.framework/Headers/JAdbidCore.h)为准；安装、厂商依赖和资源配置见[完整集成指南](integration.md)，首次接入见[快速集成](quick-start.md)。Objective-C 导入 `#import <JAdbidCore/JAdbidCore.h>`，Swift 导入 `import JAdbidCore`。

## 目录

- [调用约定](#conventions)
- [初始化与配置](#initialization)
- [隐私与地区](#privacy)
- [广告对象与加载展示](#ads)
- [广告事件回调](#callbacks)
- [原生素材协议](#native-rendering)
- [广告信息与错误](#results)
- [常用示例](#examples)

<a id="conventions"></a>
## 调用约定

- 未注明可空的参数和返回值均不可为 `nil`；Swift 用 `?` 表示可空。表中的“只读”表示不能直接赋值。
- 建议在主线程串行配置和使用广告对象。初始化、地区查询及广告 delegate 回调在主线程交付；`load`、`show` 会调度到主线程。UIKit 视图访问、GDPR 页面和原生渲染必须在主线程进行。
- 宿主强持有广告对象，并保活其弱引用 `delegate`。结束使用时调用 `destroy`；销毁后不能复用，需创建新对象。已进入的回调无法撤回，尚未交付的事件会被屏蔽。
- Objective-C 的 `BOOL` 加 `NSError **` 接口在 Swift 中导入为 `throws`，成功返回 `Void`，用 `do/try/catch` 处理失败。同步接受操作不代表异步加载、渲染或展示成功，应继续等待相应回调。
- 配置或地区状态不等于用户授权。SDK 不代替应用申请 ATT，不提供 IDFA 读写接口或隐私总开关。

<a id="initialization"></a>
## 初始化与配置

### JAdConfig

使用 `initWithAppID:`（Swift：`JAdConfig(appID:)`）创建配置；`init`、`new` 不可用。`appID` 应为非空白字符串，构造本身不校验、不发起网络请求，也不初始化 SDK。

| 属性 | 类型 | 说明 |
| --- | --- | --- |
| `appID` | `NSString *` / `String`，只读 | JAdbid 应用标识，创建时复制 |
| `debugMode` | `BOOL` / `Bool` | 默认 `NO`；开启 SDK 调试日志，正式应用按需使用 |
| `testMode` | `BOOL` / `Bool` | 默认 `NO`；广告测试模式，还需在广告平台登记测试设备和配置测试广告位 |
| `adapterType` | `JAdAdapterType` | 1.0.0 只支持 `JAdAdapterTypeDefault`（Swift：`.default`），值为 `1`；`JAdAdapterTypeA=2`、`JAdAdapterTypeB=3`（Swift：`.A`、`.B`）为保留值，准备配置时会拒绝 |

### JAdManager

通过 `+[JAdManager sharedInstance]`（Swift：`JAdManager.shared()`）获取共享管理器；不能使用 `init` 或 `new`。

| Objective-C 方法 | Swift 方法 | 参数与结果 |
| --- | --- | --- |
| `prepareWithConfig:error:` | `try prepare(config:)` | `config: JAdConfig`；校验并保存配置副本，不初始化；OC 返回 `BOOL`，失败填入 `NSError` |
| `initializeWithConfig:completion:` | `initialize(config:completion:)` | 校验、保存配置后初始化；`completion` 的错误为 `nil` 表示成功，否则失败 |
| `initializeWhenConsentReadyWithCompletion:` | `initializeWhenConsentReady(completion:)` | 使用已准备的配置初始化；未准备时回调错误，`reason=notPrepared`；由宿主判断隐私流程是否就绪 |
| `waitForInitializationWithTimeout:completion:` | `waitForInitialization(timeout:completion:)` | `timeout: NSTimeInterval / TimeInterval`，单位秒；只等待，不触发或取消初始化；回调 `BOOL / Bool` |
| `adInfoForAdUnitID:` | `adInfo(forAdUnitID:)` | 输入广告位 `NSString * / String`，返回最近一次非空 `JAdInfo` 快照；无记录时为 `nil`，不发起请求，也不保证广告仍可展示 |

初始化 completion 类型为 Objective-C `void (^)(NSError * _Nullable error)`，Swift `(Error?) -> Void`。等待回调为 `(BOOL initialized)` / `(Bool) -> Void`，在主线程交付一次；超时、初始化失败、负数或非有限的等待时间得到 `NO`，`0` 表示立即查询。

尚未初始化且没有初始化进行中时，`prepare` 保存配置副本。初始化中或成功后，仅相同 `appID` 且相同 `testMode` 的配置可被接受，但不会替换配置；不同配置会失败。相同配置的并发初始化会合并，成功后重复调用不会重复初始化。修改 `configuration` 返回的副本不会改变当前配置。

| Objective-C 属性 | Swift 属性 | 类型与说明 |
| --- | --- | --- |
| `prepared`（getter `isPrepared`） | `isPrepared` | `BOOL / Bool`，只读；已有有效配置，不等于初始化成功 |
| `initialized`（getter `isInitialized`） | `isInitialized` | `BOOL / Bool`，只读；本进程是否初始化成功 |
| `SDKVersion` | `sdkVersion` | `NSString * / String`，只读；运行时 SDK 版本 |
| `configuration` | `configuration` | `JAdConfig * / JAdConfig?`，可空、只读配置副本 |
| `adapter` | `adapter` | `id<JAdAdapterAccess> / JAdAdapterAccess?`，可空、只读；准备配置成功后可用 |
| `debugMode` | `debugMode` | `BOOL / Bool`，可读写；调试日志开关，默认 `NO` |

Swift 也可使用导入的异步形式：`try await initialize(config:)`、`try await initializeWhenConsentReady()`、`await waitForInitialization(timeout:) -> Bool`、`await checkCurrentArea() -> JAdRegionResult`。它们对应同名回调接口，不增加自动隐私授权或初始化能力。

### JAdAdapterAccess

`manager.adapter` 与 `JAdManager` 共享初始化、配置和隐私状态，不是第二套 SDK。它提供上面的管理方法及隐私/地区接口；`SDKVersion` 与 `adapter` 属性只在 `JAdManager` 上提供。

额外属性：`adapterType: JAdAdapterType` 为只读；`testMode: BOOL / Bool` 可读写。测试模式应在初始化前通过配置确定，初始化开始后修改不会改变已生效的全局模式。

它还提供以下工厂方法；输入均为广告位 `NSString * / String`，返回全新、未加载的广告对象。也可直接使用各广告类的指定构造器。

| Objective-C | Swift | 返回对象 |
| --- | --- | --- |
| `makeBannerAdWithAdUnitID:` | `makeBannerAd(withAdUnitID:)` | `JBannerAd` |
| `makeInterstitialAdWithAdUnitID:` | `makeInterstitialAd(withAdUnitID:)` | `JInterstitialAd` |
| `makeRewardedVideoAdWithAdUnitID:` | `makeRewardedVideoAd(withAdUnitID:)` | `JRewardedVideoAd` |
| `makeNativeAdWithAdUnitID:` | `makeNativeAd(withAdUnitID:)` | `JNativeAd` |
| `makeSplashAdWithAdUnitID:` | `makeSplashAd(withAdUnitID:)` | `JSplashAd` |

<a id="privacy"></a>
## 隐私与地区

以下接口同时适用于 `JAdManager` 和 `JAdAdapterAccess`。隐私设置应在初始化前完成；设置可能异步排入主队列，立即读取时可能仍为旧值。应用负责依据适用要求与真实用户选择调用，不以地区判断自动替代用户同意。

| Objective-C | Swift | 类型、返回与用途 |
| --- | --- | --- |
| `personalizedAdsEnabled` | `personalizedAdsEnabled` | 可读写 `BOOL / Bool`；个性化广告开关，不等于 GDPR 同意或 ATT 授权 |
| `setGDPRDataCollectionAllowed:` | `setGDPRDataCollectionAllowed(_:)` | 输入 `BOOL / Bool`：`YES` 允许、`NO` 拒绝数据收集；无返回值，不提供恢复未知状态的操作 |
| `GDPRConsentState` | `gdprConsentState` | 只读 `JAdConsentState`；当前 GDPR 同意状态，未知不等于拒绝 |
| `GDPRApplicable` | `gdprApplicable` | 只读 `JAdApplicability`；GDPR 是否适用，不表示用户已同意 |
| `canCollectPersonalInfo` | `canCollectPersonalInfo` | 只读 `BOOL / Bool`；当前是否允许收集个人信息的综合判断，不是可写总开关 |
| `trackingAllowed` | `trackingAllowed` | 可读写 `BOOL / Bool`；设置应用追踪许可，读取综合追踪结果；不会弹出 ATT，不能越过系统拒绝 |
| `ccpaDataCollectionAllowed` | `ccpaDataCollectionAllowed` | 可读写 `BOOL / Bool`；CCPA 数据收集许可，`YES` 允许、`NO` 拒绝；读取本进程记录，默认 `YES` |
| `firstGDPRPresentation` | `firstGDPRPresentation` | 可读写 `BOOL / Bool`；本地持久化布尔标记，默认 `NO`；不会自动弹窗或证明同意 |
| `messagePushAllowed` | `messagePushAllowed` | 可读写 `BOOL / Bool`；SDK 消息推送许可，读取本进程记录，默认 `YES`；不代替系统通知授权 |
| `LGPDConsent` | `lgpdConsent` | 只读 `JAdLGPDConsent`；本进程最后设置值，初始未知，不是厂商持久化同意记录的查询接口 |
| `setLGPDConsent:error:` | `try setLGPDConsent(_:)` | 输入 `JAdLGPDConsent`；OC 返回 `BOOL`、失败填 `NSError`；已设置后不能恢复未知，不额外持久化 |
| `ISOCode` | `isoCode` | 可空、只读 `NSString * / String?`；初始化成功后读取国家/地区代码，尚无值时为 `nil` |
| `checkCurrentAreaWithCompletion:` | `checkCurrentArea(completion:)` | 无同步返回值；主线程回调 `JAdRegionResult`，不自动设置隐私状态 |

### 隐私枚举

| 类型 | Objective-C 常量 | Swift 值 | 数值 |
| --- | --- | --- | --- |
| `JAdConsentState`（GDPR） | `JAdConsentStateUnknown` / `JAdConsentStateDenied` / `JAdConsentStateGranted` | `.unknown` / `.denied` / `.granted` | `-1` / `0` / `1` |
| `JAdLGPDConsent`（LGPD） | `JAdLGPDConsentUnknown` / `JAdLGPDConsentGranted` / `JAdLGPDConsentDenied` | `.unknown` / `.granted` / `.denied` | `-1` / `0` / `1` |
| `JAdApplicability`（适用性） | `JAdApplicabilityUnknown` / `JAdApplicabilityNo` / `JAdApplicabilityYes` | `.unknown` / `.no` / `.yes` | `-1` / `0` / `1` |

GDPR 与 LGPD 的“同意/拒绝”数值顺序不同，不能互用。LGPD 的 `.unknown` 仅允许保留初始未知；已设置后恢复未知会失败，原因为 `unsupportedConsentReset`，无效枚举原因为 `invalidConsentValue`。

### 显示 GDPR 同意页面

Objective-C：

```objc
- (BOOL)showGDPRConsentDialogFromViewController:(UIViewController *)controller
                                       didShow:(void (^ _Nullable)(void))didShow
                                    didDismiss:(void (^ _Nullable)(JAdConsentState state))didDismiss
                                         error:(NSError * _Nullable * _Nullable)error;
```

Swift：`try showGDPRConsentDialog(from:didShow:didDismiss:)`，两个回调均可为 `nil`。必须在主线程调用，且 `controller.view` 已挂到窗口。OC 返回 `YES` / Swift 未抛错，仅表示已调用页面流程；`didShow` 表示显示，`didDismiss` 返回关闭时的实际 GDPR 状态，关闭不等于同意。

### JAdRegionResult

只读属性均为 `BOOL / Bool`：`unknown` 表示地区无法判定；`CN` / Swift `cn` 为中国，`CA` / `ca` 为加州，`EU` / `eu` 为 GDPR 适用地区，`BR` / `br` 为巴西。`unknown=YES` 时不能把地区标记视为合规授权；地区为真也不表示用户同意。

### 当前不支持的容量设置

`setMaximumCacheDatabaseSize:error:`（Swift：`try setMaximumCacheDatabaseSize(_:)`）参数为字节数 `int64_t / Int64`。1.0.0 不应用该值，始终返回 `NO` 并给出 `JAdErrorInternal`、`reason=unsupportedCapability`；Swift 抛错。不要依赖此接口控制缓存容量。

<a id="ads"></a>
## 广告对象与加载展示

### 公共属性与生命周期

五种广告类均通过 `initWithAdUnitID:`（Swift：`init(adUnitID:)`）创建，禁止 `init`、`new`。构造不加载广告；空白广告位在加载回调中报告失败。须等待 SDK 初始化成功后再加载。

| 公共成员 | 类型与说明 |
| --- | --- |
| `adUnitID` | 只读 `NSString * / String`；构造时复制的广告位 |
| `sceneID` | 可空、可读写 `NSString * / String?`；Banner 在加载时、其它样式在展示或渲染时使用；`nil` 表示默认场景 |
| `customAdInfo` | 可空、可读写 `NSDictionary<NSString *, id> * / [String: Any]?`；自定义信息快照，仅保留字符串、数值及其字典/数组；加载和展示前传递，勿放凭据 |
| `delegate` | 对应 `J…AdDelegate` 协议，弱引用、可空；宿主负责保活 |
| `destroy` / Swift `destroy()` | 无参数、无返回值；停止后续事件交付并异步释放广告及移除视图，可重复调用；销毁后不能再次加载或展示 |

除开屏外，加载入口均为 `loadWithViewController:(UIViewController *)viewController` / Swift `load(viewController:)`，无返回值，控制器由宿主管理。重复的在途加载会收到 `didFailToLoad`（`reason=alreadyLoading`），不会取消原请求；同一对象复用广告实例，不自动增加重试。

### JBannerAd（横幅）

| 成员 | 类型、参数与用途 |
| --- | --- |
| `adSize` | 可读写 `CGSize`；加载前设置，默认 `320 × 50` point，宽高须为有限正数 |
| `bannerView` | 可空、只读 `UIView * / UIView?`；主线程获取并加入宿主布局；加载前可获取，后台线程或销毁后为 `nil` |
| `loadWithViewController:` / `load(viewController:)` | 加载后自动展示到 `bannerView`，无需独立 `show`；实际尺寸变化通过 delegate 通知 |

### JInterstitialAd（插屏）与 JRewardedVideoAd（激励视频）

两类均提供公共加载方法，并增加以下接口：

| Objective-C | Swift | 说明 |
| --- | --- | --- |
| `ready`（getter `isReady`） | `isReady` | 只读 `BOOL / Bool`；当前缓存是否可展示，销毁或全屏展示中为 `NO` |
| `showFromViewController:` | `show(from:)` | 输入有效 `UIViewController`，无返回值；展示已就绪广告，结果看回调；未就绪或重复展示通过 `didFailToShow` 报错 |

`ready` 不预留缓存，即使查询为真，展示仍可能失败。激励视频仅在 `didReward` 中处理奖励，不能用视频结束或关闭代替奖励；不提供“再看一次”接口。

### JNativeAd（原生）

| 成员 | 类型、参数与用途 |
| --- | --- |
| `ready` / Swift `isReady` | 只读 `BOOL / Bool`；是否有可用缓存，查询不预留缓存 |
| `templateRenderSize` | 可读写 `CGSize`；加载前设置，默认 `CGSizeZero`，禁止负数和非有限值 |
| `renderAssetView:inContainer:viewController:error:` | 参数依次为 `UIView<JAdNativeRendering> *` 素材视图、`UIView *` 独立容器、`UIViewController *`、可选 `NSError **`；主线程调用，OC 返回 `BOOL` |
| Swift `render(assetView:in:viewController:)` | 参数对应上行，使用 `try`；失败抛错，成功无返回值 |
| `nativeAdObject` | 可空、只读 `id / Any?`；已消费并渲染的广告对象，仅供读取；未渲染、无对象、后台线程或销毁后为 `nil` |

`load` 不消费缓存，渲染时消费一条就绪广告。`assetView` 与 `container` 不得相同，`container` 不能位于 `assetView` 的子孙层级；所有素材和点击视图须属于 `assetView`。同步参数、线程或未就绪错误通过 `NSError` / `throws` 返回；提交成功仍可能通过 `didFailToShow` 异步报错。素材协议见[下一节](#native-rendering)。

### JSplashAd（开屏）

| Objective-C | Swift | 说明 |
| --- | --- | --- |
| `loadWithWindow:` | `load(window:)` | 输入宿主持有的 `UIWindow`，须有有效 `rootViewController`；无返回值，加载结果看回调 |
| `showInWindow:` | `show(in:)` | 输入有效窗口，无返回值；展示就绪开屏，参数错误或无缓存通过 `didFailToShow` 报错 |
| `ready`（getter `isReady`） | `isReady` | 只读 `BOOL / Bool`；查询当前缓存，不预留广告 |

开屏不使用其它样式的 `loadWithViewController:`，加载也不等于展示。宿主负责窗口和根控制器的生命周期。

<a id="callbacks"></a>
## 广告事件回调

`JBannerAdDelegate`、`JInterstitialAdDelegate`、`JRewardedVideoAdDelegate`、`JNativeAdDelegate`、`JSplashAdDelegate` 的方法均为可选、在主线程回调。`ad` 参数为对应广告对象；事件信息 `JAdInfo * / JAdInfo?` 可空，失败对象 `JAdError * / JAdError` 非空。不同广告源不保证提供所有事件，不应自行补发成功事件。

### 五种样式共有事件

| Objective-C selector | Swift 方法 | 含义 |
| --- | --- | --- |
| `ad:didLoad:` | `ad(_:didLoad:)` | 加载完成，不等于已展示 |
| `ad:didFailToLoad:` | `ad(_:didFailToLoad:)` | 加载失败，查看 `JAdError` |
| `ad:didShow:` | `ad(_:didShow:)` | 收到展示事件，不能由 `load/show` 返回代替 |
| `ad:didClick:` | `ad(_:didClick:)` | 点击事件 |
| `ad:didClose:` | `ad(_:didClose:)` | 关闭事件，不表示获得奖励 |
| `ad:didFailToShow:` | `ad(_:didFailToShow:)` | 展示或渲染失败，包括 Banner、原生的异步失败 |

例如激励视频奖励回调的完整签名为 Objective-C `- (void)ad:(JRewardedVideoAd *)ad didReward:(JAdInfo * _Nullable)info;`，Swift 为 `func ad(_ ad: JRewardedVideoAd, didReward info: JAdInfo?)`。

### 样式特有事件

| 协议 | Objective-C selector | Swift 方法 | 含义 |
| --- | --- | --- | --- |
| `JBannerAdDelegate` | `ad:didChangeSize:` | `ad(_:didChange:)` | 第二参数 `CGSize`，单位 point；实际有效尺寸变化，宿主更新布局 |
| `JInterstitialAdDelegate`、`JRewardedVideoAdDelegate` | `ad:didStartVideo:` | `ad(_:didStartVideo:)` | 视频开始，仅广告源提供时回调 |
| `JInterstitialAdDelegate`、`JRewardedVideoAdDelegate` | `ad:didEndVideo:` | `ad(_:didEndVideo:)` | 视频结束，不等于发奖 |
| `JRewardedVideoAdDelegate` | `ad:didReward:` | `ad(_:didReward:)` | 同一次展示最多交付一次奖励事件；宿主在此处理奖励，必要时自行核验服务端凭据 |

<a id="native-rendering"></a>
## JAdNativeRendering 原生素材协议

由素材视图遵循此协议。所有方法均可选、返回值可空，主线程访问；返回的素材控件必须是素材视图自身或其子视图。没有提供的素材返回 `nil`。

下表方法在 Swift 中同名并加 `()`；`nibForAd` 为类方法，Swift 使用 `static func nibForAd() -> UINib?`。

| Objective-C 方法 | 返回类型 | 用途 |
| --- | --- | --- |
| `nativeTitleTextLabel` | `UILabel *` | 标题 |
| `nativeMainTextLabel` | `UILabel *` | 正文 |
| `nativeIconImageView` | `UIImageView *` | 图标 |
| `nativeMainImageView` | `UIImageView *` | 主图 |
| `nativeMediaView` | `UIView *` | 媒体容器 |
| `nativeCallToActionTextLabel` | `UILabel *` | 行动按钮文字 |
| `nativeCallToActionView` | `UIView *` | 行动按钮视图 |
| `nativePrivacyInformationIconImageView` | `UIImageView *` | 隐私信息图标 |
| `nativeAdChoiceView` | `UIView *` | 广告选择标识 |
| `clickViewArray` | `NSArray<UIView *> *` | 点击视图数组，所有元素须在素材视图层级内；`nil` 交由渲染器处理 |
| `nativeCloseButton` | `UIButton *` | 关闭按钮 |
| `+nibForAd` | `UINib *` | 可选素材 Nib |

完整用法见 [Objective-C 原生示例](../demo/oc/ObjectiveC/Ads/JAdbidNativeViewController.m)与 [Swift 原生示例](../demo/swift-demo/Swift/Ads/SampleAdViewController.swift)。

<a id="results"></a>
## 广告信息与错误

### JAdInfo

只读事件快照，不包含原始厂商字典。以下属性均可空，类型为 `NSString * / String?`：

| 属性 | 含义 |
| --- | --- |
| `networkName` | 广告来源可读名称 |
| `networkIdentifier` | 广告来源的 JAdbid 归一化标识 |
| `sourceIdentifier` | 当前广告源的 JAdbid 归一化标识 |
| `sourcePlacementIdentifier` | 当前广告源中的位置标识 |
| `ecpm` | 广告价值字符串，SDK 不自行换算币种或单位 |
| `ecpmPrecision` | 价值精度的归一化描述 |
| `sceneIdentifier` | 本次事件的场景标识 |

### JAdError 与 NSError

异步广告失败通过 `JAdError` 回调：`code: JAdErrorCode`、`message: NSString * / String`、可空 `reason: NSString * / String?`，均只读。同步 `BOOL` 接口和初始化错误使用 `NSError`，错误域为 `JAdErrorDomain`；细分原因使用 `NSError.userInfo[JAdReasonKey]`。Swift 的 `throws` 失败可转为 `NSError` 读取这些信息。

业务判断优先使用错误码；`message` 仅供诊断，不作为稳定分支条件。未知失败归为 `Unknown`，不要依赖第三方原始错误码或对象。

| Objective-C 常量 | Swift 值 | 数值 | 含义 |
| --- | --- | --- | --- |
| `JAdErrorNoFill` | `.noFill` | `1001` | 无填充 |
| `JAdErrorNetwork` | `.network` | `1002` | 网络错误 |
| `JAdErrorTimeout` | `.timeout` | `1003` | 超时 |
| `JAdErrorNotInitialized` | `.notInitialized` | `1004` | 未初始化 |
| `JAdErrorInvalidParameters` | `.invalidParameters` | `1005` | 参数或调用线程无效 |
| `JAdErrorLoading` | `.loading` | `1006` | 已有加载进行中 |
| `JAdErrorNotReady` | `.notReady` | `1007` | 缓存不可展示 |
| `JAdErrorInternal` | `.internal` | `1008` | 内部错误或不支持的操作，进一步查看 `reason` |
| `JAdErrorAdapterMissing` | `.adapterMissing` | `1009` | 无法创建适配对象 |
| `JAdErrorUnknown` | `.unknown` | `9999` | 未归类错误 |

<a id="examples"></a>
## 常用示例

以下初始化函数应由应用在完成适用的隐私流程后调用，`appID` 从应用自己的配置中传入。初始化回调成功后才能加载广告。

### Objective-C 初始化

```objc
#import <JAdbidCore/JAdbidCore.h>

static void InitializeAds(NSString *appID) {
    JAdConfig *config = [[JAdConfig alloc] initWithAppID:appID];
    [[JAdManager sharedInstance] initializeWithConfig:config completion:^(NSError *error) {
        if (error != nil) { return; }
        // SDK 初始化成功，可开始加载广告。
    }];
}
```

### Swift 初始化

```swift
import JAdbidCore

func initializeAds(appID: String) {
    let config = JAdConfig(appID: appID)
    JAdManager.shared().initialize(config: config) { error in
        guard error == nil else { return }
        // SDK 初始化成功，可开始加载广告。
    }
}
```

### Swift 同步失败处理

`prepare` 只准备配置，不初始化 SDK。以下 `onFailure` 是应用自己的处理函数，可按 `NSError.domain`、`code` 和可空的 `reason` 显示提示或调整调用。

```swift
import JAdbidCore

func prepareAds(config: JAdConfig, onFailure: (NSError, String?) -> Void) {
    do {
        try JAdManager.shared().prepare(config: config)
    } catch {
        let nsError = error as NSError
        let reason = nsError.userInfo[JAdReasonKey] as? String
        onFailure(nsError, reason)
    }
}
```

### Swift 插屏对象与回调

调用 `load` 前应已初始化成功；加载完成后，由业务选择合适时机调用 `showIfReady`。宿主应持有该控制器及广告对象，离开后不再使用时调用 `finish`。

```swift
import UIKit
import JAdbidCore

final class InterstitialExample: UIViewController, JInterstitialAdDelegate {
    private var ad: JInterstitialAd?

    func load(adUnitID: String) {
        ad?.destroy()
        let object = JInterstitialAd(adUnitID: adUnitID)
        object.delegate = self
        ad = object
        object.load(viewController: self)
    }

    func showIfReady() {
        guard let ad, ad.isReady else { return }
        ad.show(from: self)
    }

    func ad(_ ad: JInterstitialAd, didLoad info: JAdInfo?) {
        // 已加载；根据业务时机展示，不在此假定已展示。
    }

    func ad(_ ad: JInterstitialAd, didFailToLoad error: JAdError) {
        // 使用 error.code 与 error.reason 定位失败。
    }

    func ad(_ ad: JInterstitialAd, didFailToShow error: JAdError) {
        // 展示失败应单独处理。
    }

    func finish() {
        ad?.destroy()
        ad = nil
    }
}
```

其它样式见 [Objective-C 示例](../demo/oc/ObjectiveC/Ads)和 [Swift 示例](../demo/swift-demo/Swift/Ads)。常见失败先查[FAQ](faq.md)和[问题排查](troubleshooting.md)；提交问题所需材料见[技术支持手册](technical-support.md)。
