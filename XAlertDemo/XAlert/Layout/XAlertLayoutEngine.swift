import UIKit

/// 计算弹窗内容视图的最终布局。
///
/// 布局引擎负责内建展示样式的位置和尺寸决策，
/// 具体视图仍负责测量自身的固有内容尺寸。
struct XAlertLayoutEngine {
    /// 计算内容布局所需的输入。
    struct Context {
        /// 宿主视图边界。
        var bounds: CGRect

        /// 宿主安全区。
        var safeAreaInsets: UIEdgeInsets

        /// 从底部边缘计算的键盘遮挡高度。
        var keyboardOverlap: CGFloat

        /// 弹窗配置。
        var configuration: XAlertConfiguration

        /// 需要测量的内容视图。
        var contentView: UIView
    }

    /// 计算最终内容区域。
    func frame(for context: Context) -> CGRect {
        let safeBounds = context.bounds.inset(by: context.safeAreaInsets)
        let horizontalBounds = context.bounds.inset(
            by: UIEdgeInsets(
                top: 0,
                left: context.safeAreaInsets.left,
                bottom: 0,
                right: context.safeAreaInsets.right
            )
        )
        let width = contentWidth(in: horizontalBounds, configuration: context.configuration)
        let height = contentHeight(
            for: context.contentView,
            width: width,
            safeBounds: safeBounds,
            configuration: context.configuration
        )
        let origin = contentOrigin(
            size: CGSize(width: width, height: height),
            safeBounds: safeBounds,
            hostBounds: context.bounds,
            keyboardOverlap: context.keyboardOverlap,
            configuration: context.configuration
        )
        return CGRect(origin: origin, size: CGSize(width: width, height: height))
    }

    private func contentWidth(in horizontalBounds: CGRect, configuration: XAlertConfiguration) -> CGFloat {
        min(configuration.layout.maxWidth, max(1, horizontalBounds.width - 20))
    }

    private func contentHeight(
        for contentView: UIView,
        width: CGFloat,
        safeBounds: CGRect,
        configuration: XAlertConfiguration
    ) -> CGFloat {
        let fittingSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let measured = contentView.systemLayoutSizeFitting(
            fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        let availableHeight = min(configuration.layout.maxHeight ?? .greatestFiniteMagnitude, safeBounds.height - 20)
        return min(max(1, measured.height), max(1, availableHeight))
    }

    private func contentOrigin(
        size: CGSize,
        safeBounds: CGRect,
        hostBounds: CGRect,
        keyboardOverlap: CGFloat,
        configuration: XAlertConfiguration
    ) -> CGPoint {
        switch configuration.presentationStyle {
        case .center, .custom:
            let adjusted = safeBounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: keyboardOverlap, right: 0))
            return CGPoint(x: adjusted.midX - size.width / 2, y: adjusted.midY - size.height / 2)
        case .top:
            return CGPoint(x: safeBounds.midX - size.width / 2, y: safeBounds.minY + 12)
        case .bottom:
            if configuration.contentStyle == .sheet, configuration.layout.extendsSheetIntoBottomSafeArea {
                return CGPoint(x: safeBounds.midX - size.width / 2, y: hostBounds.maxY - size.height)
            }
            return CGPoint(x: safeBounds.midX - size.width / 2, y: safeBounds.maxY - size.height - 12)
        case .leading:
            return CGPoint(x: safeBounds.minX + 12, y: safeBounds.midY - size.height / 2)
        case .trailing:
            return CGPoint(x: safeBounds.maxX - size.width - 12, y: safeBounds.midY - size.height / 2)
        }
    }
}
