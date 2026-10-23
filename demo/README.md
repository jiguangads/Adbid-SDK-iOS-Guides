# Objective-C 与 Swift Demo

首次使用先看[快速集成](../docs/quick-start.md)；常见问题见 [FAQ](../docs/faq.md)，材料收集见[技术支持手册](../docs/technical-support.md)。

- `oc/Sample.xcodeproj`：Objective-C 宿主。
- `swift-demo/Sample.xcodeproj`：Swift 宿主。

两个工程按 `App`、`Home`、`Common`、`Ads` 组织，最低支持 iOS 15.0。默认 `SampleConfig.plist` 中的 App ID 与五类广告位为空，启动只显示操作入口，不自动申请权限、初始化 SDK 或请求广告。

## 安装与运行

1. 两份 Podfile 使用公开 SDK 仓库的 `1.0.0` Tag，列出 Core 及 11 个可选 Adapter。业务应用应按需选择广告源，首次安装全部厂商依赖下载量较大。
2. 分别进入 `oc`、`swift-demo`，执行 `pod install`，打开生成的 `Sample.xcworkspace`。厂商依赖版本由 Podspec 声明。
3. 在本地填写 `SampleConfig.plist`，不要提交真实广告配置、凭据或设备标识。AdMob 示例采用 [Google 官方测试 App ID](https://developers.google.com/admob/ios/quick-start)，实际应用应使用自己的 App ID。
4. 按应用需要配置签名、隐私描述和广告平台测试位；宿主完成真实隐私流程后，在页面中显式初始化 SDK，再执行广告操作。

设备与模拟器均使用 arm64，不支持 Intel Mac 的 x86_64 模拟器。JAdbid 静态框架只链接，厂商动态框架按官方要求嵌入和签名。示例的模拟器架构配置会影响同一宿主及其它 Pods，应避免自行覆盖为 x86_64。

## Swift Package Manager

在两种语言宿主中添加公开 SDK 仓库，精确选择 **1.0.0**，选择 Core 或所需 Adapter。厂商官方产品和传递依赖须单独配置；Pods Demo 的依赖设置不能直接代替原生 SwiftPM 设置。

资源复制必须在签名前完成，构建后只读核对最终 App。脚本使用所选 `--source` 和 `--integration spm`，每次仅处理一个源，不顺序叠加多源资源。各源布局及 Bigo `6.1.0` 框架内资源要求见[集成说明](../docs/integration.md#原生-spm-资源布局)。Bigo 的 `--vendor-root` 指向选中切片的 `BigoADS.framework`；检查时 App 中须已嵌入同一动态框架。

## 生命周期与日志

浏览器或商店页面返回时，仍存在的广告页面保留有效对象；真正退出页面时释放。冷启动不会自动恢复宿主的隐私流程确认或 SDK 初始化状态。

Debug Demo 显式开启 SDK `debugMode`，Release 普通日志默认关闭，可按需开启，精简错误保留。筛选 `[JAdbid]` 查看 SDK 事件，筛选 `[JAdbidDemo]` 查看示例操作与回调；不输出真实配置、设备标识、原始错误字典或厂商对象。

点击加载后等待明确终态，加载中不提前显示失败；真实失败结束本次请求。当前公共广告信息字段为 `networkName`、`sourceIdentifier`，请以所集成 SDK 的公共头为准。

实际广告加载、展示、曝光和奖励回调需在真实设备与正确的广告平台配置下检查；示例构建和模拟器启动不能替代这些运行结果。
