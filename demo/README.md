# Objective-C 与 Swift Demo

- `oc/Sample.xcodeproj`：Objective-C 宿主。
- `swift-demo/Sample.xcodeproj`：Swift 宿主。

两个工程按 `App`、`Home`、`Common`、`Ads` 分类。默认 `SampleConfig.plist` 的 App ID 与五类广告位均为空；启动只显示操作入口，不自动初始化或请求广告。宿主完成实际隐私流程后，才在页面上显式确认并初始化 SDK。

## 安装依赖

1. 当前两份 Demo 仍使用 [SDK 已公开旧候选](https://github.com/jiguangads/jadbid-ios-sdk/commit/ae9cabf2dae1a389cc7943d149011bfbce3bbcb5)，build 29；Podfile 固定该提交。它们不是 `jadbid-1.0.0-beta.1` SwiftPM 工程，不能算作 beta.1 的双语言消费验证。
2. 分别进入 `oc`、`swift-demo` 运行 `pod install`，打开生成的 `Sample.xcworkspace`。Podfile 使用 SDK 公开精确 commit，并列出 11 个广告源 Adapter；对应厂商 SDK 由发行 Podspec 锁定。
3. 在本地填写各工程的 `SampleConfig.plist`。不要把真实 App ID、广告位或设备标识提交到公开仓库。涉及 AdMob 的工程使用 [Google 公布的测试 App ID](https://developers.google.com/admob/ios/quick-start) 仅供示例；接入实际应用时必须换成自己的 App ID。
4. 按应用需要配置签名、隐私描述和广告平台后台测试位后，在真机验证。11 个广告源的真实填充与回调仍需逐源验收。

## beta SwiftPM 验收路径

在 Objective-C、Swift 两种宿主中分别用精确版本 `1.0.0-beta.1` 添加 SDK Package，选择 Core 与一个待测 Adapter 产品；11 个源逐源建立单源验收工程，按厂商官方契约单独安装对应 SDK/传递依赖。每个源都要检查依赖解析、完整 App 构建、签名前主 Bundle 资源、隐私清单和最终产物；不能仅凭当前 Podfile 的成功记录替代。SDK 仓 `copy_resources.py --help` 列出 `--source` 与 `--vendor-root` 等选项，但当前脚本不支持同一 App 多源资源顺序复制。Yandex AppMetrica 官方 SPM 下载的既有网络例外应在验收报告单列，不写成通过。

项目最低支持 iOS 15。由于示例列出全部广告源，首次安装会拉取各厂商依赖；实际应用应按需要选择，而非照搬全源 Podfile。

浏览器或商店页面返回时，仍存在的广告页面会保留有效对象；真正退出广告页面时释放对象。冷启动不会自动恢复 Demo 的隐私流程确认或 SDK 初始化状态。

## 控制台日志与构建身份

Debug宿主会显式打开SDK的debugMode，即使链接Release候选也可联调。筛选[JAdbid]看SDK事件，筛选[JAdbidDemo]看Demo初始化、加载开始/真实成功失败及展示回调；Release普通日志默认关闭，可显式开启debugMode，错误精简输出保留。不打印设备标识、真实配置、原始错误字典或厂商对象。

点击加载后等待明确终态，加载中不提前显示失败；真正失败结束本次请求，当前不承诺后台自动缓存变化会触发新的load回调。公开示例使用当前广告源字段，并保留已验证的固定两代getter兼容读取。

开启SDK日志时，初始化一次build.identity输出版本、source revision/digest、dirty、构型、build与有限模块摘要；只表示实际构建/链接身份，不证明填充或曝光。当前 Demo 旧候选 BuildIdentity.json 的 build=29、dirty=false；beta.1 包为 Jenkins build 4、dirty=false。

## 旧公开候选的实际验证

SDK固定公开提交 `ae9cabf2dae1a389cc7943d149011bfbce3bbcb5`（1.0.0 build29，Release SDK），已从该远端提交分别完成OC/Swift的`pod install --no-repo-update`：每工程11项直接依赖、36个Pods；随后两个`Sample.xcworkspace`的Debug模拟器完整App构建均通过。这些结果仅证明旧提交，不证明 beta。锁定提交与实际安装Core设备/模拟器字节及BuildIdentity一致。验证在源码外全新副本进行，没有在公开仓提交Pods、锁文件、本机配置或构建产物。

第三方旧deployment target与EXCLUDED_ARCHS合并有警告，没有导致旧提交构建失败。此结果不等于 beta 的 SwiftPM 完整消费或真机广告填充/曝光通过。本次不进行 CocoaPods Trunk 发布与完整 lint；beta 的远端精确版本消费与 Release 回查以发行验收记录为准。
