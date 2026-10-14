import JAdbidCore
import UIKit

final class SampleHomeViewController: UIViewController {
  private let statusLabel = UILabel()
  private let session = SampleSession.shared

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "JAdbid Swift 广告测试"
    view.backgroundColor = .systemBackground
    statusLabel.numberOfLines = 0
    let stack = UIStackView(arrangedSubviews: [statusLabel])
    stack.axis = .vertical
    stack.spacing = 12
    stack.translatesAutoresizingMaskIntoConstraints = false
    let scroll = UIScrollView()
    scroll.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scroll)
    scroll.addSubview(stack)
    NSLayoutConstraint.activate([
      scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 20),
      stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -20),
      stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 20),
      stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -20),
      stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -40)
    ])
    addButton("我已由宿主完成隐私流程", to: stack, action: #selector(confirmPrivacy))
    addButton("初始化 SDK", to: stack, action: #selector(initializeSDK))
    for format in SampleAdFormat.allCases {
      let button = UIButton(type: .system)
      button.setTitle(format.title, for: .normal)
      button.addAction(UIAction { [weak self] _ in
        self?.navigationController?.pushViewController(SampleAdViewController(format: format), animated: true)
      }, for: .touchUpInside)
      stack.addArrangedSubview(button)
    }
    refreshStatus()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refreshStatus()
  }

  private func addButton(_ title: String, to stack: UIStackView, action: Selector) {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    button.addTarget(self, action: action, for: .touchUpInside)
    stack.addArrangedSubview(button)
  }

  private func refreshStatus() {
    guard isViewLoaded else { return }
    let privacy = session.privacyFlowCompleted ? "宿主隐私流程：已由用户确认" : "宿主隐私流程：未确认"
    let sdk = session.initialized ? "SDK 已初始化" : session.lastInitializationResult
    statusLabel.text = "SDK \(JAdManager.shared().sdkVersion)\n\(privacy)\n\(sdk)\n公开示例不主动申请 ATT。"
  }

  @objc private func confirmPrivacy() {
    session.markHostPrivacyFlowCompleted()
    refreshStatus()
  }

  @objc private func initializeSDK() {
    session.initialize { [weak self] _ in self?.refreshStatus() }
    refreshStatus()
  }
}
