import UIKit

/// 默认居中弹窗淡入缩放动画器。
public struct XAlertFadeScaleAnimator: XAlertAnimator {
    /// 创建淡入缩放动画器。
    public init() {}

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
        case .springScale:
            animateSpringScaleIn(context: context, phase: phase, completion: completion)
        case .automatic, .fadeScale, .slide, .springSlide:
            animateFadeScaleIn(context: context, phase: phase, completion: completion)
        }
    }

    public func dismiss(context: XAlertAnimationContext, completion: @escaping () -> Void) {
        let phase = context.configuration.animation.dismiss
        let style = resolvedDismissStyle(phase.style)
        context.contentView.layer.removeAllAnimations()
        context.contentView.frame = context.visibleFrame
        context.contentView.transform = .identity

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
        case .automatic, .fadeScale, .springScale, .slide, .springSlide:
            animateFadeScaleOut(context: context, phase: phase, completion: completion)
        }
    }

    private func animateFadeScaleIn(
        context: XAlertAnimationContext,
        phase: XAlertAnimationPhaseConfiguration,
        completion: @escaping () -> Void
    ) {
        let scale = clampedScale(phase.scale)
        context.contentView.alpha = 0
        context.contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        UIView.animate(
            withDuration: phase.duration,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseOut, .allowUserInteraction],
            animations: {
                context.contentView.alpha = 1
                context.contentView.transform = .identity
            },
            completion: { _ in completion() }
        )
    }

    private func animateSpringScaleIn(
        context: XAlertAnimationContext,
        phase: XAlertAnimationPhaseConfiguration,
        completion: @escaping () -> Void
    ) {
        let scale = clampedScale(phase.scale)
        context.contentView.alpha = 0
        context.contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        UIView.animate(
            withDuration: max(0.01, phase.duration * 0.45),
            delay: 0,
            options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction],
            animations: {
                context.contentView.alpha = 1
            }
        )
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

    private func animateFadeScaleOut(
        context: XAlertAnimationContext,
        phase: XAlertAnimationPhaseConfiguration,
        completion: @escaping () -> Void
    ) {
        let scale = clampedScale(phase.scale)
        UIView.animate(
            withDuration: phase.duration,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseIn, .allowUserInteraction],
            animations: {
                context.contentView.alpha = 0
                context.contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
            },
            completion: { _ in completion() }
        )
    }

    private func resolvedPresentStyle(_ style: XAlertAnimationStyle) -> XAlertAnimationStyle {
        if UIAccessibility.isReduceMotionEnabled {
            return style == .none ? .none : .fade
        }
        return style == .automatic ? .springScale : style
    }

    private func resolvedDismissStyle(_ style: XAlertAnimationStyle) -> XAlertAnimationStyle {
        if UIAccessibility.isReduceMotionEnabled {
            return style == .none ? .none : .fade
        }
        return style == .automatic ? .fadeScale : style
    }

    private func clampedScale(_ scale: CGFloat) -> CGFloat {
        min(max(scale, 0.01), 2)
    }
}
