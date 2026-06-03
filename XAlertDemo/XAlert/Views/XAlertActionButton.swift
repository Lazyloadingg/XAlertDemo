import UIKit

/// 用于渲染弹窗 Action 的按钮。
final class XAlertActionButton: UIButton {
    /// 当前按钮代表的 Action。
    let action: XAlertAction
    private let theme: XAlertTheme
    private let topBorder = CALayer()
    private let bottomBorder = CALayer()
    private let leadingBorder = CALayer()
    private let trailingBorder = CALayer()

    /// 创建 Action 按钮。
    init(action: XAlertAction, theme: XAlertTheme) {
        self.action = action
        self.theme = theme
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        setTitle(action.title, for: .normal)
        titleLabel?.font = action.appearance.font ?? .systemFont(ofSize: 17, weight: action.role == .cancel ? .semibold : .regular)
        layer.borderWidth = action.appearance.borderPosition == .all ? action.appearance.borderWidth : 0
        layer.borderColor = (action.appearance.borderColor ?? theme.actionBorderColor).cgColor
        backgroundColor = action.appearance.backgroundColor ?? .clear
        configureBorderLayers()

        switch action.role {
        case .normal:
            setTitleColor(action.appearance.titleColor ?? theme.normalActionTitleColor, for: .normal)
        case .cancel:
            setTitleColor(action.appearance.titleColor ?? theme.cancelActionTitleColor, for: .normal)
        case .destructive:
            setTitleColor(action.appearance.titleColor ?? theme.destructiveActionTitleColor, for: .normal)
        }
        setTitleColor(action.appearance.highlightedTitleColor ?? titleColor(for: .normal)?.withAlphaComponent(0.5), for: .highlighted)
        setBackgroundImage(Self.image(with: action.appearance.backgroundColor ?? .clear), for: .normal)
        setBackgroundImage(Self.image(with: action.appearance.highlightedBackgroundColor ?? theme.actionHighlightedBackgroundColor), for: .highlighted)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = action.appearance.borderWidth
        topBorder.frame = CGRect(x: 0, y: 0, width: bounds.width, height: width)
        bottomBorder.frame = CGRect(x: 0, y: bounds.height - width, width: bounds.width, height: width)
        leadingBorder.frame = CGRect(x: 0, y: 0, width: width, height: bounds.height)
        trailingBorder.frame = CGRect(x: bounds.width - width, y: 0, width: width, height: bounds.height)
    }

    private func configureBorderLayers() {
        [topBorder, bottomBorder, leadingBorder, trailingBorder].forEach {
            $0.removeFromSuperlayer()
            $0.backgroundColor = (action.appearance.borderColor ?? theme.actionBorderColor).cgColor
        }

        guard action.appearance.borderPosition != .all else { return }
        if action.appearance.borderPosition.contains(.top) {
            layer.addSublayer(topBorder)
        }
        if action.appearance.borderPosition.contains(.bottom) {
            layer.addSublayer(bottomBorder)
        }
        if action.appearance.borderPosition.contains(.leading) {
            layer.addSublayer(leadingBorder)
        }
        if action.appearance.borderPosition.contains(.trailing) {
            layer.addSublayer(trailingBorder)
        }
    }

    private static func image(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
}
