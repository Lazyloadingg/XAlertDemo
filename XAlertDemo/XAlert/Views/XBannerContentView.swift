import UIKit

/// 内建 Banner 样式内容视图。
final class XBannerContentView: XAlertContentView {
    /// 创建 Banner 内容视图。
    required init(configuration: XAlertConfiguration) {
        var adjusted = configuration
        adjusted.layout.contentInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        adjusted.layout.cornerRadius = 10
        super.init(configuration: adjusted)
        backgroundColor = adjusted.theme.bannerBackgroundColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
