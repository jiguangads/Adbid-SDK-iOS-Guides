# Objective-C 与 Swift Demo

- `oc/Sample.xcodeproj`：Objective-C 宿主。
- `swift-demo/Sample.xcodeproj`：Swift 宿主。

两个工程按 `App`、`Home`、`Common`、`Ads` 分类。默认 `SampleConfig.plist` 的 App ID 与五类广告位均为空；启动只显示操作入口，不自动初始化或请求广告。宿主完成实际隐私流程后，才在页面上显式确认并初始化 SDK。

## 安装依赖

1. 等待 [SDK 发布仓库](https://github.com/jiguangads/jadbid-ios-sdk)发布与 Podfile 一致的 `1.0.0` Tag。当前 Tag 尚不存在，`pod install` 预计失败。
2. 分别进入 `oc`、`swift-demo` 运行 `pod install`，打开生成的 `Sample.xcworkspace`。Podfile 使用 SDK 公开 Git Tag，并列出 11 个广告源 Adapter；对应厂商 SDK 由发行 Podspec 锁定。
3. 在本地填写各工程的 `SampleConfig.plist`。不要把真实 App ID、广告位或设备标识提交到公开仓库。涉及 AdMob 的工程使用 [Google 公布的测试 App ID](https://developers.google.com/admob/ios/quick-start) 仅供示例；接入实际应用时必须换成自己的 App ID。
4. 按应用需要配置签名、隐私描述和广告平台后台测试位后，在真机验证。11 个广告源的真实填充与回调仍需逐源验收。

项目最低支持 iOS 15。由于示例列出全部广告源，首次安装会拉取各厂商依赖；实际应用应按需要选择，而非照搬全源 Podfile。

浏览器或商店页面返回时，仍存在的广告页面会保留有效对象；真正退出广告页面时释放对象。冷启动不会自动恢复 Demo 的隐私流程确认或 SDK 初始化状态。
