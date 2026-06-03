import UIKit

/// 内建 Sheet 样式内容视图。
///
/// 普通和危险 Action 渲染在 Sheet 主体中，
/// 取消 Action 渲染为底部独立按钮。
final class XSheetContentView: UIView, XAlertContentPresenting {
    var onAction: ((XAlertAction) -> Void)?
    var onContentTap: (() -> Void)?
    var hostSafeAreaInsets: UIEdgeInsets = .zero {
        didSet {
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    private let configuration: XAlertConfiguration
    private let bodyContainer = XAlertRoundedContainerView()
    private let bodyScrollView = UIScrollView()
    private let bodyStackView = UIStackView()
    private let actionsStackView = UIStackView()
    private let cancelContainer = XAlertRoundedContainerView()
    private var cancelButton: XAlertActionButton?

    required init(configuration: XAlertConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        backgroundColor = .clear
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let hasCancel = cancelButton != nil
        let cancelHeight: CGFloat = hasCancel ? sheetHeight(for: cancelButton?.action) : 0
        let gap: CGFloat = hasCancel ? configuration.layout.sheetCancelSpacing : 0
        let bottomInset = configuration.layout.extendsSheetIntoBottomSafeArea ? hostSafeAreaInsets.bottom : 0
        let bodyHeight = max(0, bounds.height - cancelHeight - gap - bottomInset)
        let fixedActionHeight = fixedActionsHeight(width: bounds.width)

        bodyContainer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bodyHeight)
        bodyScrollView.frame = CGRect(x: 0, y: 0, width: bodyContainer.bounds.width, height: max(0, bodyContainer.bounds.height - fixedActionHeight))
        let bodySize = bodyStackView.systemLayoutSizeFitting(
            CGSize(width: bodyContainer.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        bodyStackView.frame = CGRect(x: 0, y: 0, width: bodyContainer.bounds.width, height: max(bodyScrollView.bounds.height, bodySize.height))
        bodyScrollView.contentSize = CGSize(width: bodyContainer.bounds.width, height: bodySize.height)
        if fixedActionHeight > 0 {
            actionsStackView.frame = CGRect(x: 0, y: bodyContainer.bounds.height - fixedActionHeight, width: bodyContainer.bounds.width, height: fixedActionHeight)
        }

        if hasCancel {
            cancelContainer.frame = CGRect(x: 0, y: bodyHeight + gap, width: bounds.width, height: cancelHeight)
            cancelButton?.frame = cancelContainer.bounds
        }
    }

    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        let bodySize = bodyStackView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
        let fixedActionHeight = configuration.layout.isActionFollowScrollEnabled ? 0 : actionsStackView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        ).height
        let bottomInset = configuration.layout.extendsSheetIntoBottomSafeArea ? hostSafeAreaInsets.bottom : 0
        let cancelHeight: CGFloat = cancelButton == nil ? 0 : sheetHeight(for: cancelButton?.action) + configuration.layout.sheetCancelSpacing
        return CGSize(width: targetSize.width, height: bodySize.height + fixedActionHeight + cancelHeight + bottomInset)
    }

    private func setup() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(contentTapped))
        addGestureRecognizer(tap)

        bodyContainer.cornerRadii = configuration.layout.cornerRadii
        bodyContainer.backgroundColor = configuration.theme.sheetBackgroundColor
        addSubview(bodyContainer)

        bodyScrollView.isScrollEnabled = configuration.layout.isScrollEnabled
        bodyScrollView.showsVerticalScrollIndicator = configuration.layout.showsScrollIndicator
        bodyContainer.addSubview(bodyScrollView)

        bodyStackView.axis = .vertical
        bodyStackView.alignment = .fill
        bodyStackView.spacing = 10
        bodyStackView.isLayoutMarginsRelativeArrangement = true
        bodyStackView.layoutMargins = configuration.layout.contentInsets
        bodyScrollView.addSubview(bodyStackView)

        actionsStackView.axis = .vertical
        actionsStackView.distribution = .fillEqually
        actionsStackView.spacing = 0
        bodyContainer.addSubview(actionsStackView)

        renderItems()
        renderActions()
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
                bodyStackView.addArrangedSubview(label)
            case let .message(text):
                let label = UILabel()
                label.text = text
                label.textColor = configuration.theme.messageColor
                label.font = configuration.theme.messageFont
                label.textAlignment = .center
                label.numberOfLines = 0
                bodyStackView.addArrangedSubview(label)
            case let .textField(configure):
                let textField = UITextField()
                textField.borderStyle = .roundedRect
                configure(textField)
                bodyStackView.addArrangedSubview(textField)
            case let .customView(view):
                bodyStackView.addArrangedSubview(XAlertCustomViewContainer(customView: view))
            }
        }
    }

    private func renderActions() {
        let normalActions = configuration.actions.filter { $0.role != .cancel }
        let cancelAction = configuration.actions.last { $0.role == .cancel }

        if !normalActions.isEmpty {
            if configuration.layout.isActionFollowScrollEnabled {
                bodyStackView.addArrangedSubview(actionsStackView)
            }
            for action in normalActions {
                let button = XAlertActionButton(action: action, theme: configuration.theme)
                button.heightAnchor.constraint(equalToConstant: sheetHeight(for: action)).isActive = true
                button.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)
                actionsStackView.addArrangedSubview(button)
            }
        }

        if let cancelAction {
            let button = XAlertActionButton(action: cancelAction, theme: configuration.theme)
            button.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)
            cancelContainer.cornerRadii = configuration.layout.sheetCancelCornerRadii
            cancelContainer.backgroundColor = configuration.theme.sheetCancelBackgroundColor
            cancelContainer.addSubview(button)
            addSubview(cancelContainer)
            cancelButton = button
        }
    }

    @objc private func actionTapped(_ sender: XAlertActionButton) {
        onAction?(sender.action)
    }

    @objc private func contentTapped() {
        onContentTap?()
    }

    private func sheetHeight(for action: XAlertAction?) -> CGFloat {
        guard let action else { return 56 }
        return action.appearance.height == 44 ? 56 : action.appearance.height
    }

    private func fixedActionsHeight(width: CGFloat) -> CGFloat {
        guard !configuration.layout.isActionFollowScrollEnabled, !configuration.actions.filter({ $0.role != .cancel }).isEmpty else {
            return 0
        }
        return actionsStackView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }
}
