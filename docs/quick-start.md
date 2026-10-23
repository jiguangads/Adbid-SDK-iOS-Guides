# 快速集成

目标：先运行一个示例，确认安装和初始化，再验证一种广告样式。本文以 CocoaPods 为主线；需要 Swift Package Manager（SPM）或手动集成时，直接阅读[完整集成指南](integration.md)。

## 1. 准备环境与配置

- 使用 Xcode、CocoaPods 和 iOS 15.0 及以上的 arm64 真机或模拟器。实际广告效果使用真机验证。
- 确认 SDK **1.0.0** 在所用渠道可获取；无法获取时见 [版本问题](faq.md#version)。
- 准备应用配置、所选广告源和一种广告样式的测试广告位，并确认配置所属的应用、平台与样式相符。
- 完成应用需要的签名、隐私说明及厂商配置。App ID 与广告位的用途见 [FAQ](faq.md#config)。

**完成标志：** 能说明将使用哪个示例、广告源、测试设备和广告样式。不要在公开工单或仓库填写真实配置。

## 2. 安装示例依赖

获取本指南仓库并进入仓库根目录；若尚未下载，可执行：

```sh
git clone https://github.com/jiguangads/Adbid-SDK-iOS-Guides.git
cd Adbid-SDK-iOS-Guides
```

然后选择一种语言：

```sh
# Objective-C 示例
cd demo/oc
pod install
open Sample.xcworkspace
```

Swift 示例将目录换成 `demo/swift-demo`，其余命令相同；两套工程分别安装。应打开生成的 `.xcworkspace`，不要打开 `.xcodeproj` 来运行 Pods 示例。

示例 Podfile 列出所有广告源，首次下载较大。首次单源验证可在本地只保留所选 Adapter 的 `pod 'JAdbid/…'` 声明，删除其它源的声明，保留 target 和其它设置；Adapter 已依赖 Core，无需另加一条不同来源的 Core 声明。业务应用最小 Podfile 示例见[完整集成指南](integration.md#cocoapods)。不要在同一 target 重复用 Pods 和 SPM 安装 JAdbid。

**完成标志：** `pod install` 无错误结束，工作区能够打开。失败先看[安装与编译排查](troubleshooting.md#install)。

## 3. 填写本地示例配置

在所选示例目录编辑 `SampleConfig.plist`：

| 字段 | 填写内容 |
| --- | --- |
| `AppID` | 对应应用的 JAdbid App ID |
| `Banner` | Banner 广告位 |
| `Interstitial` | 插屏广告位 |
| `Native` | 原生广告位 |
| `Rewarded` | 激励视频广告位 |
| `Splash` | 开屏广告位 |

先填写 `AppID` 与本次验证样式的广告位，不测试的样式保持为空。广告位与应用、广告源配置是否匹配需在相应平台核对。

厂商要求的应用设置仍需单独配置。例如 AdMob 的 `GADApplicationIdentifier` 位于示例 `SampleInfo.plist`，它与上表的 JAdbid `AppID` 用途不同，不能互相替换。按所选厂商要求及[集成说明](integration.md)配置，保留隐私清单和资源。

**完成标志：** 测试样式使用了匹配的非空配置；本地更改不包含在公开提交中。

## 4. 构建并初始化

1. 在 Xcode 中选择 Sample scheme、测试设备；真机配置自己的签名。
2. 构建并启动，默认页面显示“尚未初始化”属于正常状态。
3. 完成应用实际需要的隐私流程，再点击示例中的“完成隐私流程后初始化 SDK”。页面确认不等于 ATT 等系统授权，详见 [FAQ](faq.md#privacy)。
4. 等待明确的初始化结果，再进入广告样式页面。

**完成标志：** 页面显示初始化成功。若失败，先按[初始化排查](troubleshooting.md#initialize)处理，不反复请求广告。

## 5. 加载并展示一种广告

选择已填写广告位的样式，执行页面提供的加载、展示操作；等待明确回调。不同样式的展示方式以对应示例为准，不重复点击加载或并发发起同一对象的请求。

**完成标志：** 在真实设备记录加载、可见展示及相应回调；激励视频额外检查奖励回调。仅看到页面或编译成功，不等于广告接入完成。失败见[加载与展示排查](troubleshooting.md#ads)。

## 接入自己的应用

保留上述安装、配置、隐私、初始化、加载和展示顺序。先按[完整集成指南](integration.md)设置宿主依赖、资源与框架，按 [API 参考](api-reference.md)查询方法、参数和回调，再参考现有示例的实际调用：

- Objective-C：[初始化管理](../demo/oc/ObjectiveC/Common/JAdbidSDKManager.m)、[广告样式](../demo/oc/ObjectiveC/Ads)。
- Swift：[初始化管理](../demo/swift-demo/Swift/Common/SampleSession.swift)、[广告样式](../demo/swift-demo/Swift/Ads)。

集成 SPM 时还要手动添加所选厂商的官方产品与传递依赖，并在签名前处理资源；不能直接照搬 Pods 的资源布局。技术参数以[完整集成指南](integration.md)为准，示例安装和签名补充见 [Demo 使用说明](../demo/README.md)。

仍无法解决时，按[技术支持手册](technical-support.md)提交脱敏的最小复现材料。
