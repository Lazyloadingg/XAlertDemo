import UIKit

/// 用于配置并展示弹窗的构建器。
///
/// 构建器是值类型，每个配置方法都会返回新的构建器，
/// 因此可以链式配置且不会共享可变状态。
public struct XAlertBuilder {
    private var configuration: XAlertConfiguration

    /// 使用配置创建构建器。
    public init(configuration: XAlertConfiguration) {
        self.configuration = configuration
    }

    /// 设置内容布局样式。
    @discardableResult
    public func contentStyle(_ style: XAlertContentStyle) -> XAlertBuilder {
        updating { $0.contentStyle = style }
    }

    /// 设置展示样式，并同步更新默认 lane。
    @discardableResult
    public func presentationStyle(_ style: XAlertPresentationStyle) -> XAlertBuilder {
        updating {
            $0.presentationStyle = style
            $0.lane = XAlertConfiguration.defaultLane(for: style)
        }
    }

    /// 设置展示上下文。
    @discardableResult
    public func presentationContext(_ context: XAlertPresentationContext) -> XAlertBuilder {
        updating { $0.presentationContext = context }
    }

    /// 设置展示模式。
    @discardableResult
    public func displayMode(_ mode: XAlertDisplayMode) -> XAlertBuilder {
        updating { $0.displayMode = mode }
    }

    /// 设置展示 lane。
    @discardableResult
    public func lane(_ lane: XAlertPresentationLane) -> XAlertBuilder {
        updating { $0.lane = lane }
    }

    /// 设置背景遮罩模式。
    @discardableResult
    public func dimMode(_ mode: XAlertDimMode) -> XAlertBuilder {
        updating { $0.dimMode = mode }
    }

    /// 设置弹窗优先级。
    @discardableResult
    public func priority(_ priority: Int) -> XAlertBuilder {
        updating { $0.priority = max(0, priority) }
    }

    /// 设置业务标识。
    @discardableResult
    public func identifier(_ identifier: String) -> XAlertBuilder {
        updating { $0.identifier = identifier }
    }

    /// 开启或关闭重复 identifier 过滤。
    @discardableResult
    public func ignoresDuplicateIdentifier(_ ignores: Bool) -> XAlertBuilder {
        updating { $0.ignoresDuplicateIdentifier = ignores }
    }

    /// 开启或关闭点击背景关闭。
    @discardableResult
    public func backgroundDismissEnabled(_ enabled: Bool) -> XAlertBuilder {
        updating { $0.isBackgroundDismissEnabled = enabled }
    }

    /// 开启或关闭点击内容区域关闭。
    @discardableResult
    public func contentDismissEnabled(_ enabled: Bool) -> XAlertBuilder {
        updating { $0.isContentDismissEnabled = enabled }
    }

    /// 添加标题内容项。
    @discardableResult
    public func title(_ text: String) -> XAlertBuilder {
        updating { $0.items.append(.title(text)) }
    }

    /// 添加正文内容项。
    @discardableResult
    public func message(_ text: String) -> XAlertBuilder {
        updating { $0.items.append(.message(text)) }
    }

    /// 添加输入框内容项。
    @discardableResult
    public func textField(_ configure: @escaping (UITextField) -> Void) -> XAlertBuilder {
        updating { $0.items.append(.textField(configure)) }
    }

    /// 添加自定义视图内容项。
    @discardableResult
    public func customView(_ view: UIView) -> XAlertBuilder {
        updating { $0.items.append(.customView(view)) }
    }

    /// 添加默认 Action。
    @discardableResult
    public func action(
        _ title: String,
        keepsAlertVisible: Bool = false,
        appearance: XAlertActionAppearance = XAlertActionAppearance(),
        handler: (() -> Void)? = nil
    ) -> XAlertBuilder {
        updating {
            $0.actions.append(
                XAlertAction(
                    title: title,
                    role: .normal,
                    keepsAlertVisible: keepsAlertVisible,
                    appearance: appearance,
                    handler: handler
                )
            )
        }
    }

    /// 添加取消 Action。
    @discardableResult
    public func cancel(
        _ title: String,
        appearance: XAlertActionAppearance = XAlertActionAppearance(),
        handler: (() -> Void)? = nil
    ) -> XAlertBuilder {
        updating {
            $0.actions.append(XAlertAction(title: title, role: .cancel, appearance: appearance, handler: handler))
        }
    }

    /// 添加危险 Action。
    @discardableResult
    public func destructive(
        _ title: String,
        appearance: XAlertActionAppearance = XAlertActionAppearance(),
        handler: (() -> Void)? = nil
    ) -> XAlertBuilder {
        updating {
            $0.actions.append(XAlertAction(title: title, role: .destructive, appearance: appearance, handler: handler))
        }
    }

    /// 添加完整配置的 Action。
    @discardableResult
    public func addAction(_ action: XAlertAction) -> XAlertBuilder {
        updating { $0.actions.append(action) }
    }

    /// 设置所有关闭路径共用的关闭判断。
    @discardableResult
    public func shouldDismiss(_ predicate: @escaping () -> Bool) -> XAlertBuilder {
        updating { $0.shouldDismiss = predicate }
    }

    /// 设置 Action 触发关闭时的关闭判断。
    @discardableResult
    public func shouldDismissForAction(_ predicate: @escaping (XAlertAction) -> Bool) -> XAlertBuilder {
        updating { $0.shouldDismissForAction = predicate }
    }

    /// 设置关闭完成回调。
    @discardableResult
    public func onDismiss(_ callback: @escaping () -> Void) -> XAlertBuilder {
        updating { $0.onDismiss = callback }
    }

    /// 更新布局配置。
    @discardableResult
    public func layout(_ configure: (inout XAlertLayoutConfiguration) -> Void) -> XAlertBuilder {
        updating { configure(&$0.layout) }
    }

    /// 设置最大内容宽度。
    @discardableResult
    public func maxWidth(_ width: CGFloat) -> XAlertBuilder {
        layout { $0.maxWidth = width }
    }

    /// 设置最大内容高度。
    @discardableResult
    public func maxHeight(_ height: CGFloat?) -> XAlertBuilder {
        layout { $0.maxHeight = height }
    }

    /// 开启或关闭内容超高时滚动。
    @discardableResult
    public func scrollEnabled(_ enabled: Bool) -> XAlertBuilder {
        layout { $0.isScrollEnabled = enabled }
    }

    /// 开启或关闭内容滚动指示器。
    @discardableResult
    public func showsScrollIndicator(_ shows: Bool) -> XAlertBuilder {
        layout { $0.showsScrollIndicator = shows }
    }

    /// 设置 Action 按钮是否跟随内容项滚动。
    @discardableResult
    public func actionFollowScrollEnabled(_ enabled: Bool) -> XAlertBuilder {
        layout { $0.isActionFollowScrollEnabled = enabled }
    }

    /// 设置统一内容圆角。
    @discardableResult
    public func cornerRadius(_ radius: CGFloat) -> XAlertBuilder {
        layout { $0.cornerRadius = radius }
    }

    /// 设置独立内容四角圆角。
    @discardableResult
    public func cornerRadii(_ radii: XAlertLayoutConfiguration.CornerRadii) -> XAlertBuilder {
        layout { $0.cornerRadii = radii }
    }

    /// 设置 Sheet 取消按钮容器的独立四角圆角。
    @discardableResult
    public func sheetCancelCornerRadii(_ radii: XAlertLayoutConfiguration.CornerRadii) -> XAlertBuilder {
        layout { $0.sheetCancelCornerRadii = radii }
    }

    /// 设置 Sheet 主体与取消按钮之间的间距。
    @discardableResult
    public func sheetCancelSpacing(_ spacing: CGFloat) -> XAlertBuilder {
        layout { $0.sheetCancelSpacing = max(0, spacing) }
    }

    /// 设置 Sheet 内容是否延伸到底部安全区。
    @discardableResult
    public func extendsSheetIntoBottomSafeArea(_ extends: Bool) -> XAlertBuilder {
        layout { $0.extendsSheetIntoBottomSafeArea = extends }
    }

    /// 更新动画配置。
    @discardableResult
    public func animation(_ configure: (inout XAlertAnimationConfiguration) -> Void) -> XAlertBuilder {
        updating { configure(&$0.animation) }
    }

    /// 开启或关闭拖拽关闭。
    @discardableResult
    public func interactiveDismissEnabled(_ enabled: Bool) -> XAlertBuilder {
        updating { $0.interactiveDismiss.isEnabled = enabled }
    }

    /// 更新拖拽关闭配置。
    @discardableResult
    public func interactiveDismiss(_ configure: (inout XAlertInteractiveDismissConfiguration) -> Void) -> XAlertBuilder {
        updating { configure(&$0.interactiveDismiss) }
    }

    /// 设置内建内容视图使用的视觉主题。
    @discardableResult
    public func theme(_ theme: XAlertTheme) -> XAlertBuilder {
        updating { $0.theme = theme }
    }

    /// 更新内建内容视图使用的视觉主题。
    @discardableResult
    public func theme(_ configure: (inout XAlertTheme) -> Void) -> XAlertBuilder {
        updating { configure(&$0.theme) }
    }

    /// 设置 Alert 主背景色。
    @discardableResult
    public func alertBackgroundColor(_ color: UIColor) -> XAlertBuilder {
        theme { $0.alertBackgroundColor = color }
    }

    /// 设置 Sheet 主体和取消按钮背景色。
    @discardableResult
    public func sheetBackgroundColor(_ color: UIColor) -> XAlertBuilder {
        theme {
            $0.sheetBackgroundColor = color
            $0.sheetCancelBackgroundColor = color
        }
    }

    /// 设置标题字体和颜色。
    @discardableResult
    public func titleStyle(font: UIFont? = nil, color: UIColor? = nil) -> XAlertBuilder {
        theme {
            if let font { $0.titleFont = font }
            if let color { $0.titleColor = color }
        }
    }

    /// 设置正文字体和颜色。
    @discardableResult
    public func messageStyle(font: UIFont? = nil, color: UIColor? = nil) -> XAlertBuilder {
        theme {
            if let font { $0.messageFont = font }
            if let color { $0.messageColor = color }
        }
    }

    /// 设置默认 Action 标题颜色。
    @discardableResult
    public func actionTitleColors(
        normal: UIColor? = nil,
        cancel: UIColor? = nil,
        destructive: UIColor? = nil
    ) -> XAlertBuilder {
        theme {
            if let normal { $0.normalActionTitleColor = normal }
            if let cancel { $0.cancelActionTitleColor = cancel }
            if let destructive { $0.destructiveActionTitleColor = destructive }
        }
    }

    /// 展示当前配置的弹窗。
    public func show() {
        XAlertSceneRegistry.shared.show(configuration)
    }

    private func updating(_ update: (inout XAlertConfiguration) -> Void) -> XAlertBuilder {
        var copy = configuration
        update(&copy)
        return XAlertBuilder(configuration: copy)
    }
}
