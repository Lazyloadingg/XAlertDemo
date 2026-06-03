import UIKit

/// 管理边缘弹窗的拖拽关闭交互。
final class XAlertInteractiveDismissController: NSObject {
    private weak var contentView: UIView?
    private weak var coordinateView: UIView?
    private var configuration: XAlertConfiguration?
    private var requestDismiss: (() -> Void)?
    private var onInteractionBegan: (() -> Void)?
    private var onInteractionEnded: (() -> Void)?
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var isClosing = false
    private var startingCenter: CGPoint = .zero

    /// 安装拖拽关闭手势。
    func install(
        on contentView: UIView,
        configuration: XAlertConfiguration,
        requestDismiss: @escaping () -> Void,
        onInteractionBegan: @escaping () -> Void,
        onInteractionEnded: @escaping () -> Void
    ) {
        uninstall()
        guard configuration.interactiveDismiss.isEnabled else { return }
        guard Self.supportsInteractiveDismiss(for: configuration.presentationStyle) else { return }

        self.contentView = contentView
        self.coordinateView = contentView.superview ?? contentView
        self.configuration = configuration
        self.requestDismiss = requestDismiss
        self.onInteractionBegan = onInteractionBegan
        self.onInteractionEnded = onInteractionEnded
        isClosing = false
        startingCenter = contentView.center

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGestureRecognizer.cancelsTouchesInView = false
        panGestureRecognizer.delegate = self
        contentView.addGestureRecognizer(panGestureRecognizer)
        self.panGestureRecognizer = panGestureRecognizer
    }

    /// 移除拖拽关闭手势。
    func uninstall() {
        if let panGestureRecognizer, let contentView {
            contentView.removeGestureRecognizer(panGestureRecognizer)
        }
        panGestureRecognizer = nil
        contentView = nil
        coordinateView = nil
        configuration = nil
        requestDismiss = nil
        onInteractionBegan = nil
        onInteractionEnded = nil
        isClosing = false
        startingCenter = .zero
    }

    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard !isClosing, let contentView, let configuration, let coordinateView else { return }

        switch gestureRecognizer.state {
        case .began:
            startingCenter = contentView.center
            contentView.layer.removeAllAnimations()
            onInteractionBegan?()
        case .changed:
            let translation = gestureRecognizer.translation(in: coordinateView)
            let offset = directionalOffset(from: translation, configuration: configuration)
            contentView.center = CGPoint(x: startingCenter.x + offset.x, y: startingCenter.y + offset.y)
        case .ended, .cancelled, .failed:
            let translation = gestureRecognizer.translation(in: coordinateView)
            let velocity = gestureRecognizer.velocity(in: coordinateView)
            if shouldDismiss(translation: translation, velocity: velocity, contentView: contentView, configuration: configuration) {
                isClosing = true
                requestDismiss?()
            } else {
                animateBack(contentView)
            }
        default:
            break
        }
    }

    private func directionalOffset(
        from translation: CGPoint,
        configuration: XAlertConfiguration
    ) -> CGPoint {
        let allowsRubberBanding = configuration.interactiveDismiss.allowsRubberBanding

        switch configuration.presentationStyle {
        case .top:
            return CGPoint(x: 0, y: filteredOffset(translation.y, dismissSign: -1, allowsRubberBanding: allowsRubberBanding))
        case .bottom:
            return CGPoint(x: 0, y: filteredOffset(translation.y, dismissSign: 1, allowsRubberBanding: allowsRubberBanding))
        case .center, .leading, .trailing, .custom:
            return .zero
        }
    }

    private func filteredOffset(
        _ value: CGFloat,
        dismissSign: CGFloat,
        allowsRubberBanding: Bool
    ) -> CGFloat {
        let signedValue = value * dismissSign
        if signedValue >= 0 {
            return value
        }
        guard allowsRubberBanding else { return 0 }
        let rubberBanded = pow(abs(value), 0.7) * 0.45
        return -dismissSign * rubberBanded
    }

    private func shouldDismiss(
        translation: CGPoint,
        velocity: CGPoint,
        contentView: UIView,
        configuration: XAlertConfiguration
    ) -> Bool {
        let config = configuration.interactiveDismiss
        let distance = dismissDistance(from: translation, configuration: configuration)
        let speed = dismissSpeed(from: velocity, configuration: configuration)
        let size = dismissAxisLength(for: contentView, configuration: configuration)
        let ratio = size > 0 ? distance / size : 0

        return speed > config.velocityThreshold
            || ratio > config.distanceThresholdRatio
            || distance > config.distanceThreshold
    }

    private func dismissDistance(
        from translation: CGPoint,
        configuration: XAlertConfiguration
    ) -> CGFloat {
        switch configuration.presentationStyle {
        case .top:
            return max(0, -translation.y)
        case .bottom:
            return max(0, translation.y)
        case .center, .leading, .trailing, .custom:
            return 0
        }
    }

    private func dismissSpeed(
        from velocity: CGPoint,
        configuration: XAlertConfiguration
    ) -> CGFloat {
        switch configuration.presentationStyle {
        case .top:
            return max(0, -velocity.y)
        case .bottom:
            return max(0, velocity.y)
        case .center, .leading, .trailing, .custom:
            return 0
        }
    }

    private func dismissAxisLength(
        for contentView: UIView,
        configuration: XAlertConfiguration
    ) -> CGFloat {
        switch configuration.presentationStyle {
        case .top, .bottom:
            return contentView.bounds.height
        case .center, .leading, .trailing, .custom:
            return 0
        }
    }

    private func animateBack(_ contentView: UIView) {
        UIView.animate(
            withDuration: 0.32,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0,
            options: [.beginFromCurrentState, .allowUserInteraction],
            animations: {
                contentView.center = self.startingCenter
            },
            completion: { [weak self] _ in
                self?.onInteractionEnded?()
            }
        )
    }

    private static func supportsInteractiveDismiss(for style: XAlertPresentationStyle) -> Bool {
        switch style {
        case .top, .bottom:
            return true
        case .center, .leading, .trailing, .custom:
            return false
        }
    }
}

extension XAlertInteractiveDismissController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer,
              let coordinateView,
              let configuration
        else { return true }

        let velocity = panGestureRecognizer.velocity(in: coordinateView)
        guard abs(velocity.y) >= abs(velocity.x) else { return false }

        switch configuration.presentationStyle {
        case .top:
            return velocity.y < 0 || configuration.interactiveDismiss.allowsRubberBanding
        case .bottom:
            return velocity.y > 0 || configuration.interactiveDismiss.allowsRubberBanding
        case .center, .leading, .trailing, .custom:
            return false
        }
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
