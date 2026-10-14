import JAdbidCore
import UIKit

enum SampleAdFormat: String, CaseIterable {
  case banner = "Banner"
  case interstitial = "Interstitial"
  case rewarded = "Rewarded"
  case native = "Native"
  case splash = "Splash"

  var title: String {
    switch self {
    case .banner: return "横幅广告"
    case .interstitial: return "插屏广告"
    case .rewarded: return "激励视频"
    case .native: return "原生广告"
    case .splash: return "开屏广告"
    }
  }
}

final class SampleAdViewController: UIViewController {
  private let format: SampleAdFormat
  private let statusLabel = UILabel()
  private let eventText = UITextView()
  private let showButton = UIButton(type: .system)
  private let bannerContainer = UIView()
  private let nativeContainer = UIView()
  private var bannerHeight: NSLayoutConstraint?
  private var loading = false
  private var events: [String] = []
  private var banner: JBannerAd?
  private var interstitial: JInterstitialAd?
  private var rewarded: JRewardedVideoAd?
  private var native: JNativeAd?
  private var splash: JSplashAd?
  private lazy var bannerEvents = SampleBannerEvents(owner: self)
  private lazy var interstitialEvents = SampleInterstitialEvents(owner: self)
  private lazy var rewardedEvents = SampleRewardedEvents(owner: self)
  private lazy var nativeEvents = SampleNativeEvents(owner: self)
  private lazy var splashEvents = SampleSplashEvents(owner: self)

  init(format: SampleAdFormat) {
    self.format = format
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) { fatalError("使用 init(format:) 创建页面") }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = format.title
    view.backgroundColor = .systemBackground
    statusLabel.numberOfLines = 0
    statusLabel.text = "点击加载；广告事件和真实来源会显示在下方"
    let loadButton = UIButton(type: .system)
    loadButton.setTitle("加载广告", for: .normal)
    loadButton.addTarget(self, action: #selector(loadAd), for: .touchUpInside)
    showButton.setTitle(format == .native ? "渲染原生广告" : "展示广告", for: .normal)
    showButton.addTarget(self, action: #selector(showAd), for: .touchUpInside)
    showButton.isEnabled = false
    showButton.isHidden = format == .banner
    bannerContainer.isHidden = format != .banner
    nativeContainer.isHidden = format != .native
    eventText.isEditable = false
    eventText.font = .preferredFont(forTextStyle: .footnote)
    eventText.text = "尚无广告事件"
    let stack = UIStackView(arrangedSubviews: [statusLabel, loadButton, showButton,
                                               bannerContainer, nativeContainer, eventText])
    stack.axis = .vertical
    stack.spacing = 12
    stack.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stack)
    bannerHeight = bannerContainer.heightAnchor.constraint(equalToConstant: 50)
    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
      stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
      stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
      bannerHeight!,
      nativeContainer.heightAnchor.constraint(equalToConstant: 250),
      eventText.heightAnchor.constraint(greaterThanOrEqualToConstant: 180)
    ])
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if !SampleSession.shared.initialized {
      showButton.isEnabled = false
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if isMovingFromParent { destroyAd() }
  }

  deinit { destroyAd() }

  @objc private func loadAd() {
    guard SampleSession.shared.initialized else {
      statusLabel.text = "请返回首页完成宿主隐私流程并初始化 SDK"
      return
    }
    let adUnitID = SampleSession.shared.configuration.adUnitID(for: format.rawValue)
    guard !adUnitID.isEmpty else {
      statusLabel.text = "请在 SampleConfig.plist 填写当前样式广告位"
      return
    }
    guard !loading else {
      statusLabel.text = "广告正在加载，请等待回调"
      return
    }
    destroyAd()
    loading = true
    showButton.isEnabled = false
    statusLabel.text = "加载中…"
    switch format {
    case .banner:
      let ad = JBannerAd(adUnitID: adUnitID)
      ad.delegate = bannerEvents
      ad.adSize = CGSize(width: 320, height: 50)
      banner = ad
      if let adView = ad.bannerView {
        adView.translatesAutoresizingMaskIntoConstraints = false
        bannerContainer.addSubview(adView)
        NSLayoutConstraint.activate([
          adView.leadingAnchor.constraint(equalTo: bannerContainer.leadingAnchor),
          adView.topAnchor.constraint(equalTo: bannerContainer.topAnchor)
        ])
      }
      ad.load(viewController: self)
    case .interstitial:
      let ad = JInterstitialAd(adUnitID: adUnitID)
      ad.delegate = interstitialEvents
      interstitial = ad
      ad.load(viewController: self)
    case .rewarded:
      let ad = JRewardedVideoAd(adUnitID: adUnitID)
      ad.delegate = rewardedEvents
      rewarded = ad
      ad.load(viewController: self)
    case .native:
      let ad = JNativeAd(adUnitID: adUnitID)
      ad.delegate = nativeEvents
      ad.templateRenderSize = CGSize(width: 320, height: 250)
      native = ad
      ad.load(viewController: self)
    case .splash:
      guard let window = view.window else {
        loading = false
        statusLabel.text = "页面尚未显示在窗口中"
        return
      }
      let ad = JSplashAd(adUnitID: adUnitID)
      ad.delegate = splashEvents
      splash = ad
      ad.load(window: window)
    }
  }

  @objc private func showAd() {
    guard SampleSession.shared.initialized else {
      showButton.isEnabled = false
      statusLabel.text = "SDK 尚未初始化"
      return
    }
    switch format {
    case .banner:
      statusLabel.text = "横幅加载后自动展示，以展示回调为准"
    case .interstitial:
      guard let ad = interstitial, ad.isReady else { return notReady() }
      ad.show(from: self)
    case .rewarded:
      guard let ad = rewarded, ad.isReady else { return notReady() }
      ad.show(from: self)
    case .native:
      guard let ad = native, ad.isReady else { return notReady() }
      do {
        nativeContainer.subviews.forEach { $0.removeFromSuperview() }
        let assetView = SampleNativeAssetView(frame: nativeContainer.bounds)
        try ad.render(assetView: assetView, in: nativeContainer, viewController: self)
      } catch {
        statusLabel.text = "原生渲染未提交：\((error as NSError).code)"
      }
    case .splash:
      guard let ad = splash, ad.isReady, let window = view.window else { return notReady() }
      ad.show(in: window)
    }
  }

  private func notReady() {
    statusLabel.text = "广告尚未 ready，请等待加载回调或重新加载"
    showButton.isEnabled = false
  }

  fileprivate func loaded(_ info: JAdInfo?) {
    loading = false
    showButton.isEnabled = format != .banner
    record("load", info: info)
  }

  fileprivate func failed(_ stage: String, error: JAdError) {
    if stage == "load" { loading = false }
    showButton.isEnabled = false
    record("\(stage) failed code=\(error.code.rawValue) reason=\(error.reason ?? "unknown")")
  }

  fileprivate func record(_ event: String, info: JAdInfo? = nil) {
    let network = info?.networkName.flatMap { $0.isEmpty ? nil : $0 } ?? "未知"
    let source = info?.sourceIdentifier.flatMap { $0.isEmpty ? nil : $0 } ?? "未知"
    events.append("\(event) | network=\(network) | source=\(source)")
    if events.count > 40 { events.removeFirst() }
    eventText.text = events.joined(separator: "\n")
    statusLabel.text = event
  }

  fileprivate func closed(_ info: JAdInfo?) {
    showButton.isEnabled = false
    record("close", info: info)
  }

  fileprivate func bannerChangedSize(_ size: CGSize) {
    bannerHeight?.constant = size.height
  }

  private func destroyAd() {
    banner?.delegate = nil
    interstitial?.delegate = nil
    rewarded?.delegate = nil
    native?.delegate = nil
    splash?.delegate = nil
    banner?.destroy()
    interstitial?.destroy()
    rewarded?.destroy()
    native?.destroy()
    splash?.destroy()
    banner = nil
    interstitial = nil
    rewarded = nil
    native = nil
    splash = nil
    bannerContainer.subviews.forEach { $0.removeFromSuperview() }
    nativeContainer.subviews.forEach { $0.removeFromSuperview() }
    loading = false
    showButton.isEnabled = false
  }
}

private final class SampleBannerEvents: NSObject, JBannerAdDelegate {
  weak var owner: SampleAdViewController?
  init(owner: SampleAdViewController) { self.owner = owner }
  func ad(_ ad: JBannerAd, didLoad info: JAdInfo?) { owner?.loaded(info) }
  func ad(_ ad: JBannerAd, didFailToLoad error: JAdError) { owner?.failed("load", error: error) }
  func ad(_ ad: JBannerAd, didShow info: JAdInfo?) { owner?.record("show", info: info) }
  func ad(_ ad: JBannerAd, didClick info: JAdInfo?) { owner?.record("click", info: info) }
  func ad(_ ad: JBannerAd, didClose info: JAdInfo?) { owner?.closed(info) }
  func ad(_ ad: JBannerAd, didFailToShow error: JAdError) { owner?.failed("show", error: error) }
  func ad(_ ad: JBannerAd, didChange size: CGSize) { owner?.bannerChangedSize(size) }
}

private final class SampleInterstitialEvents: NSObject, JInterstitialAdDelegate {
  weak var owner: SampleAdViewController?
  init(owner: SampleAdViewController) { self.owner = owner }
  func ad(_ ad: JInterstitialAd, didLoad info: JAdInfo?) { owner?.loaded(info) }
  func ad(_ ad: JInterstitialAd, didFailToLoad error: JAdError) { owner?.failed("load", error: error) }
  func ad(_ ad: JInterstitialAd, didShow info: JAdInfo?) { owner?.record("show", info: info) }
  func ad(_ ad: JInterstitialAd, didClick info: JAdInfo?) { owner?.record("click", info: info) }
  func ad(_ ad: JInterstitialAd, didClose info: JAdInfo?) { owner?.closed(info) }
  func ad(_ ad: JInterstitialAd, didFailToShow error: JAdError) { owner?.failed("show", error: error) }
  func ad(_ ad: JInterstitialAd, didStartVideo info: JAdInfo?) { owner?.record("videoStart", info: info) }
  func ad(_ ad: JInterstitialAd, didEndVideo info: JAdInfo?) { owner?.record("videoEnd", info: info) }
}

private final class SampleRewardedEvents: NSObject, JRewardedVideoAdDelegate {
  weak var owner: SampleAdViewController?
  init(owner: SampleAdViewController) { self.owner = owner }
  func ad(_ ad: JRewardedVideoAd, didLoad info: JAdInfo?) { owner?.loaded(info) }
  func ad(_ ad: JRewardedVideoAd, didFailToLoad error: JAdError) { owner?.failed("load", error: error) }
  func ad(_ ad: JRewardedVideoAd, didShow info: JAdInfo?) { owner?.record("show", info: info) }
  func ad(_ ad: JRewardedVideoAd, didClick info: JAdInfo?) { owner?.record("click", info: info) }
  func ad(_ ad: JRewardedVideoAd, didClose info: JAdInfo?) { owner?.closed(info) }
  func ad(_ ad: JRewardedVideoAd, didFailToShow error: JAdError) { owner?.failed("show", error: error) }
  func ad(_ ad: JRewardedVideoAd, didReward info: JAdInfo?) { owner?.record("reward", info: info) }
  func ad(_ ad: JRewardedVideoAd, didStartVideo info: JAdInfo?) { owner?.record("videoStart", info: info) }
  func ad(_ ad: JRewardedVideoAd, didEndVideo info: JAdInfo?) { owner?.record("videoEnd", info: info) }
}

private final class SampleNativeEvents: NSObject, JNativeAdDelegate {
  weak var owner: SampleAdViewController?
  init(owner: SampleAdViewController) { self.owner = owner }
  func ad(_ ad: JNativeAd, didLoad info: JAdInfo?) { owner?.loaded(info) }
  func ad(_ ad: JNativeAd, didFailToLoad error: JAdError) { owner?.failed("load", error: error) }
  func ad(_ ad: JNativeAd, didShow info: JAdInfo?) { owner?.record("show", info: info) }
  func ad(_ ad: JNativeAd, didClick info: JAdInfo?) { owner?.record("click", info: info) }
  func ad(_ ad: JNativeAd, didClose info: JAdInfo?) { owner?.closed(info) }
  func ad(_ ad: JNativeAd, didFailToShow error: JAdError) { owner?.failed("show", error: error) }
}

private final class SampleSplashEvents: NSObject, JSplashAdDelegate {
  weak var owner: SampleAdViewController?
  init(owner: SampleAdViewController) { self.owner = owner }
  func ad(_ ad: JSplashAd, didLoad info: JAdInfo?) { owner?.loaded(info) }
  func ad(_ ad: JSplashAd, didFailToLoad error: JAdError) { owner?.failed("load", error: error) }
  func ad(_ ad: JSplashAd, didShow info: JAdInfo?) { owner?.record("show", info: info) }
  func ad(_ ad: JSplashAd, didClick info: JAdInfo?) { owner?.record("click", info: info) }
  func ad(_ ad: JSplashAd, didClose info: JAdInfo?) { owner?.closed(info) }
  func ad(_ ad: JSplashAd, didFailToShow error: JAdError) { owner?.failed("show", error: error) }
}
