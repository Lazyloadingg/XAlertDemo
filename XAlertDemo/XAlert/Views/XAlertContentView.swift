import UIKit

/// 内建 Alert 样式内容视图。
class XAlertContentView: XAlertRoundedContainerView, XAlertContentPresenting {
    var onAction: ((XAlertAction) -> Void)?
    var onContentTap: (() -> Void)?
    var hostSafeAreaInsets: UIEdgeInsets = .zero

    private let configuration: XAlertConfiguration
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let actionStackView = UIStackView()
    private var actionStackHeight: CGFloat {
        guard !configuration.actions.isEmpty, !configuration.layout.isActionFollowScrollEnabled else { return 0 }
        return actionStackView.systemLayoutSizeFitting(
            CGSize(width: bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }

    required init(configuration: XAlertConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        cornerRadii = configuration.layout.cornerRadii
        backgroundColor = configuration.theme.alertBackgroundColor
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(contentTapped))
        addGestureRecognizer(tap)

        scrollView.isScrollEnabled = configuration.layout.isScrollEnabled
        scrollView.showsVerticalScrollIndicator = configuration.layout.showsScrollIndicator
        addSubview(scrollView)
        addSubview(actionStackView)

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = configuration.layout.contentInsets
        scrollView.addSubview(stackView)

        renderItems()
        renderActions()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let fixedActionHeight = actionStackHeight
        scrollView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: max(0, bounds.height - fixedActionHeight))
        let size = stackView.systemLayoutSizeFitting(
            CGSize(width: bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        stackView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: max(scrollView.bounds.height, size.height))
        scrollView.contentSize = CGSize(width: bounds.width, height: size.height)
        if fixedActionHeight > 0 {
            actionStackView.frame = CGRect(x: 0, y: bounds.height - fixedActionHeight, width: bounds.width, height: fixedActionHeight)
        }
    }

    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        let stackSize = stackView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
        let fixedActionHeight = configuration.layout.isActionFollowScrollEnabled ? 0 : actionStackView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        ).height
        return CGSize(width: targetSize.width, height: stackSize.height + fixedActionHeight)
    }

    private func renderItems() {
        for item in configuration.items {
            switch item {
            case let .title(text):
                let label = UILabel()
                label.text = text
                label.textColor = configuration.theme.titleColor
                label.font = configuration.theme.titleFont
                label.textAlignment = .center
                label.numberOfLines = 0
                stackView.addArrangedSubview(label)
            case let .message(text):
                let label = UILabel()
                label.text = text
                label.textColor = configuration.theme.messageColor
                label.font = configuration.theme.messageFont
                label.textAlignment = .center
                label.numberOfLines = 0
                stackView.addArrangedSubview(label)
            case let .textField(configure):
                let textField = UITextField()
                textField.borderStyle = .roundedRect
                configure(textField)
                stackView.addArrangedSubview(textField)
            case let .customView(view):
                stackView.addArrangedSubview(XAlertCustomViewContainer(customView: view))
            }
        }
    }

    private func renderActions() {
        guard !configuration.actions.isEmpty else { return }

        actionStackView.axis = configuration.layout.usesVerticalActions || configuration.actions.count != 2 ? .vertical : .horizontal
        actionStackView.distribution = .fillEqually
        actionStackView.spacing = 0
        if configuration.layout.isActionFollowScrollEnabled {
            stackView.addArrangedSubview(actionStackView)
        }

        for action in configuration.actions {
            let button = XAlertActionButton(action: action, theme: configuration.theme)
            button.heightAnchor.constraint(equalToConstant: action.appearance.height).isActive = true
            button.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)
            actionStackView.addArrangedSubview(button)
        }
    }

    @objc private func actionTapped(_ sender: XAlertActionButton) {
        onAction?(sender.action)
    }

    @objc private func contentTapped() {
        onContentTap?()
    }
}
