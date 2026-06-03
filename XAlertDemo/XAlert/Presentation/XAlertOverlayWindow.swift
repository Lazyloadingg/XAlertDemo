import UIKit

/// 绑定到 UIWindowScene 的弹窗承载窗口。
final class XAlertOverlayWindow: UIWindow {
    /// 当根视图不处理触摸时允许事件透传。
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let rootView = rootViewController?.view else { return false }
        return rootView.point(inside: point, with: event)
    }
}
