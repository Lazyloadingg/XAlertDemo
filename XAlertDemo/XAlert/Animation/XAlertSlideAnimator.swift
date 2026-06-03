import UIKit

/// 默认边缘滑入滑出动画器。
public struct XAlertSlideAnimator: XAlertAnimator {
    /// 滑动边缘。
    public enum Edge {
        /// 顶部边缘。
        case top

        /// 底部边缘。
        case bottom

        /// 左侧语义方向边缘。
        case leading

        /// 右侧语义方向边缘。
        case trailing
    }

    private let edge: Edge

    /// 创建滑动动画器。
    public init(edge: Edge) {
        self.edge = edge
    }

    public func present(context: XAlertAnimationContext, completion: @escaping () -> Void) {
        let phase = context.configuration.animation.present
        let style = resolvedPresentStyle(phase.style)
        context.contentView.layer.removeAllAnimations()
        context.contentView.frame = context.visibleFrame

        switch style {
        case .none:
            context.contentView.alpha = 1
            context.contentView.transform = .identity
            completion()
        case .fade:
            context.contentView.alpha = 0
            context.contentView.transform = .identity
            UIView.animate(
                withDuration: phase.duration,
                delay: 0,
                options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
                animations: {
                    context.contentView.alpha = 1
                },
                completion: { _ in completion() }
            )
        case .springSlide:
            animateSpringSlideIn(context: context, phase: phase, completion: completion)
        case .automatic, .slide, .fadeScale, .springScale:
            animateSlideIn(context: context, phase: phase, completion: completion)
        }
    }

    public func dismiss(context: XAlertAnimationContext, completion: @escaping () -> Void) {
        let phase = context.configuration.animation.dismiss
        let style = resolvedDismissStyle(phase.style)
        context.contentView.layer.removeAllAnimations()

        switch style {
        case .none:
            context.contentView.alpha = 0
            completion()
        case .fade:
            UIView.animate(
                withDuration: phase.duration,
                delay: 0,
                options: [.beginFromCurrentState, .curveEaseIn, .allowUserInteraction],
                animations: {
                    context.contentView.alpha = 0
                },
                completion: { _ in completion() }
            )
        case .automatic, .slide, .springSlide, .fadeScale, .springScale:
            animateSlideOut(context: context, phase: phase, completion: completion)
        }
    }

    private func animateSlideIn(
        context: XAlertAnimationContext,
        phase: XAlertAnimationPhaseConfiguration,
        completion: @escaping () -> Void
    ) {
        context.contentView.alpha = 1
        context.contentView.transform = offscreenTransform(for: context)
        UIView.animate(
            withDuration: phase.duration,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
            animations: {
                context.contentView.transform = .identity
            },
            completion: { _ in completion() }
        )
    }

    private func animateSpringSlideIn(
        context: XAlertAnimationContext,
        phase: XAlertAnimationPhaseConfiguration,
        completion: @escaping () -> Void
    ) {
        context.contentView.alpha = 1
        context.contentView.transform = offscreenTransform(for: context)
        UIView.animate(
            withDuration: phase.duration,
            delay: 0,
            usingSpringWithDamping: phase.springDamping,
            initialSpringVelocity: phase.initialSpringVelocity,
            options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction],
            animations: {
                context.contentView.transform = .identity
            },
            completion: { _ in completion() }
        )
    }

    private func animateSlideOut(
        context: XAlertAnimationContext,
        phase: XAlertAnimationPhaseConfiguration,
        completion: @escaping () -> Void
    ) {
        UIView.animate(
            withDuration: phase.duration,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseIn, .allowUserInteraction],
            animations: {
                context.contentView.transform = offscreenTransform(for: context)
            },
            completion: { _ in completion() }
        )
    }

    private func resolvedPresentStyle(_ style: XAlertAnimationStyle) -> XAlertAnimationStyle {
        if UIAccessibility.isReduceMotionEnabled {
            return style == .none ? .none : .fade
        }
        return style == .automatic ? .springSlide : style
    }

    private func resolvedDismissStyle(_ style: XAlertAnimationStyle) -> XAlertAnimationStyle {
        if UIAccessibility.isReduceMotionEnabled {
            return style == .none ? .none : .fade
        }
        return style == .automatic ? .slide : style
    }

    private func offscreenTransform(for context: XAlertAnimationContext) -> CGAffineTransform {
        let frame = context.visibleFrame
        let bounds = context.containerBounds

        switch edge {
        case .top:
            return CGAffineTransform(translationX: 0, y: bounds.minY - frame.maxY - 20)
        case .bottom:
            return CGAffineTransform(translationX: 0, y: bounds.maxY - frame.minY + 20)
        case .leading:
            return CGAffineTransform(translationX: bounds.minX - frame.maxX - 20, y: 0)
        case .trailing:
            return CGAffineTransform(translationX: bounds.maxX - frame.minX + 20, y: 0)
        }
    }
}
