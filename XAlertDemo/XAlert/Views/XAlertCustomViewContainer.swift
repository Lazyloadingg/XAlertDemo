import UIKit

/// 承载调用方自定义视图的容器。
///
/// 容器通过 `layoutSubviews` 感知布局变化，并在自定义视图尺寸变化时刷新
/// 固有内容尺寸。
final class XAlertCustomViewContainer: UIView {
    private let customView: UIView
    private var lastMeasuredSize: CGSize = .zero

    /// 创建自定义视图容器。
    init(customView: UIView) {
        self.customView = customView
        super.init(frame: .zero)
        clipsToBounds = true
        addSubview(customView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if customView.translatesAutoresizingMaskIntoConstraints {
            customView.frame = bounds
        } else if customView.superview == self && constraints.isEmpty {
            NSLayoutConstraint.activate([
                customView.leadingAnchor.constraint(equalTo: leadingAnchor),
                customView.trailingAnchor.constraint(equalTo: trailingAnchor),
                customView.topAnchor.constraint(equalTo: topAnchor),
                customView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        let measured = customView.systemLayoutSizeFitting(
            CGSize(width: bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        if measured != lastMeasuredSize {
            lastMeasuredSize = measured
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        if customView.translatesAutoresizingMaskIntoConstraints {
            return customView.bounds.size == .zero ? customView.frame.size : customView.bounds.size
        }
        return customView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }

    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        if customView.translatesAutoresizingMaskIntoConstraints {
            let size = customView.bounds.size == .zero ? customView.frame.size : customView.bounds.size
            return CGSize(width: targetSize.width, height: max(1, size.height))
        }
        let size = customView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
        return CGSize(width: targetSize.width, height: max(1, size.height))
    }
}
