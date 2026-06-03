import UIKit

/// 内建弹窗内容视图的公共接口。
protocol XAlertContentPresenting: UIView {
    /// 点击 Action 时触发。
    var onAction: ((XAlertAction) -> Void)? { get set }

    /// 点击内容背景时触发。
    var onContentTap: (() -> Void)? { get set }

    /// 内容控制器提供的安全区。
    var hostSafeAreaInsets: UIEdgeInsets { get set }

    /// 创建内容视图。
    init(configuration: XAlertConfiguration)
}
