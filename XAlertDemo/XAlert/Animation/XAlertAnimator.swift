import UIKit

/// 传递给弹窗动画器的上下文。
public struct XAlertAnimationContext {
    /// 内容控制器管理的容器视图。
    public let containerView: UIView

    /// 需要执行动画的内容视图。
    public let contentView: UIView

    /// 弹窗配置。
    public let configuration: XAlertConfiguration

    /// 内容视图的可见态布局快照。
    public let visibleFrame: CGRect

    /// 容器视图边界快照。
    public let containerBounds: CGRect

    /// 容器视图安全区快照。
    public let safeAreaInsets: UIEdgeInsets

    /// 创建动画上下文。
    public init(
        containerView: UIView,
        contentView: UIView,
        configuration: XAlertConfiguration,
        visibleFrame: CGRect,
        containerBounds: CGRect,
        safeAreaInsets: UIEdgeInsets
    ) {
        self.containerView = containerView
        self.contentView = contentView
        self.configuration = configuration
        self.visibleFrame = visibleFrame
        self.containerBounds = containerBounds
        self.safeAreaInsets = safeAreaInsets
    }

    /// 创建动画上下文。
    public init(containerView: UIView, contentView: UIView, configuration: XAlertConfiguration) {
        self.init(
            containerView: containerView,
            contentView: contentView,
            configuration: configuration,
            visibleFrame: contentView.frame,
            containerBounds: containerView.bounds,
            safeAreaInsets: containerView.safeAreaInsets
        )
    }
}

/// 展示和关闭动画协议。
public protocol XAlertAnimator {
    /// 执行展示动画。
    func present(context: XAlertAnimationContext, completion: @escaping () -> Void)

    /// 执行关闭动画。
    func dismiss(context: XAlertAnimationContext, completion: @escaping () -> Void)
}

/// 内建动画器工厂。
enum XAlertAnimatorFactory {
    /// 根据配置创建动画器。
    static func animator(for configuration: XAlertConfiguration) -> XAlertAnimator {
        switch configuration.presentationStyle {
        case .center:
            return XAlertFadeScaleAnimator()
        case .top:
            return XAlertSlideAnimator(edge: .top)
        case .bottom:
            return XAlertSlideAnimator(edge: .bottom)
        case .leading:
            return XAlertSlideAnimator(edge: .leading)
        case .trailing:
            return XAlertSlideAnimator(edge: .trailing)
        case let .custom(animator):
            return animator
        }
    }
}
