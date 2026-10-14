import JAdbidCore
import UIKit

/// 素材标签属于原生素材视图自身，容器与素材视图分离。
final class SampleNativeAssetView: UIView, JAdNativeRendering {
  private let titleLabel = UILabel()
  private let bodyLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configure()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    configure()
  }

  private func configure() {
    titleLabel.text = "广告标题"
    bodyLabel.text = "广告内容"
    bodyLabel.numberOfLines = 0
    let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
    stack.axis = .vertical
    stack.spacing = 8
    stack.translatesAutoresizingMaskIntoConstraints = false
    addSubview(stack)
    NSLayoutConstraint.activate([
      stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
      stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
      stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
    ])
  }

  func nativeTitleTextLabel() -> UILabel? { titleLabel }
  func nativeMainTextLabel() -> UILabel? { bodyLabel }
}
