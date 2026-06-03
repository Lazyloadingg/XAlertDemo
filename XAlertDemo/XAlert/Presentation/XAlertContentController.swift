import UIKit

/// 弹窗内容控制器的展示生命周期状态。
private enum XAlertPresentationState {
    /// 已创建但尚未开始展示。
    case idle

    /// 展示动画执行中。
    case presenting

    /// 已稳定展示。
    case visible

    /// 关闭动画执行中。
    case dismissing

    /// 已关闭并等待移除。
    case dismissed
}

/// 渲染单个弹窗实例的视图控制器。
final class XAlertContentController: UIViewController {
    /// 内容请求关闭时触发。
    var onDismissRequest: ((XAlertAction?) -> Void)?

    private let configuration: XAlertConfiguration
    private let contentView: XAlertContentPresenting
    private let animator: XAlertAnimator
    private let layoutEngine = XAlertLayoutEngine()
    private var keyboardOverlap: CGFloat = 0
    private var state: XAlertPresentationState = .idle
    private var visibleFrame: CGRect = .zero

    /// 创建内容控制器。
    init(configuration: XAlertConfiguration) {
        self.configuration = configuration
        self.contentView = XAlertContentController.makeContentView(configuration: configuration)
        self.animator = XAlertAnimatorFactory.animator(for: configuration)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .clear
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.onAction = { [weak self] action in
            self?.handle(action)
        }
        contentView.onContentTap = { [weak self] in
            guard let self, self.configuration.isContentDismissEnabled else { return }
            self.onDismissRequest?(nil)
        }
        view.addSubview(contentView)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard shouldApplyLayout else { return }
        layoutContentView()
    }

    /// 执行展示动画。
    func present() {
        state = .presenting
        view.layoutIfNeeded()
        layoutContentView()
        animator.present(context: animationContext()) { [weak self] in
            self?.state = .visible
        }
    }

    /// 执行关闭动画。
    func dismiss(completion: @escaping () -> Void) {
        guard state != .dismissing, state != .dismissed else { return }
        view.layoutIfNeeded()
        visibleFrame = contentView.frame
        state = .dismissing
        animator.dismiss(context: animationContext()) { [weak self] in
            self?.state = .dismissed
            completion()
        }
    }

    private func handle(_ action: XAlertAction) {
        if action.keepsAlertVisible {
            action.handler?()
            return
        }
        onDismissRequest?(action)
    }

    private func layoutContentView() {
        contentView.hostSafeAreaInsets = view.safeAreaInsets
        visibleFrame = layoutEngine.frame(
            for: XAlertLayoutEngine.Context(
                bounds: view.bounds,
                safeAreaInsets: view.safeAreaInsets,
                keyboardOverlap: keyboardOverlap,
                configuration: configuration,
                contentView: contentView
            )
        )
        contentView.frame = visibleFrame
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard configuration.contentStyle == .alert else { return }
        guard shouldApplyLayout else { return }
        guard let userInfo = notification.userInfo,
              let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else { return }

        let keyboardFrame = view.convert(frameValue.cgRectValue, from: nil)
        keyboardOverlap = max(0, view.bounds.maxY - keyboardFrame.minY)

        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        UIView.animate(withDuration: duration) {
            self.layoutContentView()
        }
    }

    private func animationContext() -> XAlertAnimationContext {
        XAlertAnimationContext(
            containerView: view,
            contentView: contentView,
            configuration: configuration,
            visibleFrame: visibleFrame,
            containerBounds: view.bounds,
            safeAreaInsets: view.safeAreaInsets
        )
    }

    private var shouldApplyLayout: Bool {
        switch state {
        case .idle, .presenting, .visible:
            return true
        case .dismissing, .dismissed:
            return false
        }
    }

    private static func makeContentView(configuration: XAlertConfiguration) -> XAlertContentPresenting {
        switch configuration.contentStyle {
        case .alert, .custom:
            return XAlertContentView(configuration: configuration)
        case .sheet:
            return XSheetContentView(configuration: configuration)
        case .banner:
            return XBannerContentView(configuration: configuration)
        }
    }
}
