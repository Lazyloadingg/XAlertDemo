import UIKit

/// 定义弹窗内容的组织方式。
///
/// 该值只描述内容布局语义，不描述弹窗从哪里出现。
/// 例如 `.alert` 可以与 `.top` 搭配，表示使用 Alert 布局但从顶部展示。
///
public enum XAlertContentStyle {
    /// 居中弹窗内容样式，两个 Action 可以横向排列。
    case alert

    /// 表单式内容样式，取消按钮会与普通按钮分离。
    case sheet

    /// 紧凑横幅内容样式，适合短消息提示。
    case banner

    /// 完全自定义内容样式，由调用方提供内容视图。
    case custom
}

/// 定义弹窗从哪里进入以及如何展示。
public enum XAlertPresentationStyle {
    /// 在宿主中心展示内容。
    case center

    /// 从顶部边缘展示内容。
    case top

    /// 从底部边缘展示内容。
    case bottom

    /// 从 leading 边缘展示内容。
    case leading

    /// 从 trailing 边缘展示内容。
    case trailing

    /// 使用调用方提供的自定义动画器。
    case custom(XAlertAnimator)
}

/// 定义弹窗安装到哪里。
public enum XAlertPresentationContext {
    /// 自动解析当前前台活跃 Scene。
    case automatic

    /// 展示到指定 Scene 绑定的覆盖窗口中。
    case windowScene(UIWindowScene, level: UIWindow.Level)

    /// 展示到指定视图控制器内部。
    case viewController(UIViewController)

    /// 展示到指定视图内部。
    case view(UIView)
}

/// 定义新弹窗如何与当前可见弹窗交互。
public enum XAlertDisplayMode {
    /// 当 lane 策略允许时立即展示。
    case immediate

    /// 当同 lane 已有弹窗可见时加入该 lane 队列。
    case queue

    /// 替换同 lane 中最上层的可见弹窗。
    case replaceCurrent

    /// 当相同 identifier 已可见或已排队时忽略新弹窗。
    case unique
}

/// 标识一个展示通道。
///
/// 展示通道用于隔离队列和可见数量。
/// 例如居中 Alert 和底部 Sheet 可以同时展示。
public enum XAlertPresentationLane: Hashable {
    /// 顶部展示通道。
    case top

    /// 居中展示通道。
    case center

    /// 底部展示通道。
    case bottom

    /// 左侧语义边缘展示通道。
    case leading

    /// 右侧语义边缘展示通道。
    case trailing

    /// 业务自定义展示通道。
    case custom(XAlertLaneID)
}

/// 自定义 lane 的类型安全标识。
public struct XAlertLaneID: Hashable, ExpressibleByStringLiteral {
    /// 原始 lane 标识。
    public let rawValue: String

    /// 创建 lane 标识。
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// 通过字符串字面量创建 lane 标识。
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

/// 定义 lane 达到可见上限后的处理方式。
public enum XAlertLaneOverflowPolicy {
    /// 达到可见上限后进入队列。
    case queue

    /// 展示新弹窗前移除该 lane 中最早的可见弹窗。
    case replaceOldest

    /// 展示新弹窗前移除该 lane 中最新的可见弹窗。
    case replaceNewest

    /// 丢弃新弹窗。
    case dropNew
}

/// 控制 lane 内的并发可见策略。
public struct XAlertLanePolicy {
    /// 通道内允许同时可见的最大弹窗数量。
    public var maxVisibleCount: Int

    /// 达到可见上限后的溢出策略。
    public var overflow: XAlertLaneOverflowPolicy

    /// 创建 lane 策略。
    public init(maxVisibleCount: Int, overflow: XAlertLaneOverflowPolicy) {
        self.maxVisibleCount = max(1, maxVisibleCount)
        self.overflow = overflow
    }

    /// 指定 lane 的默认策略。
    public static func `default`(for lane: XAlertPresentationLane) -> XAlertLanePolicy {
        switch lane {
        case .top:
            return XAlertLanePolicy(maxVisibleCount: 3, overflow: .queue)
        case .center, .bottom, .leading, .trailing, .custom:
            return XAlertLanePolicy(maxVisibleCount: 1, overflow: .queue)
        }
    }
}

/// 定义背景遮罩行为。
public enum XAlertDimMode {
    /// 不渲染背景遮罩。
    case none

    /// 渲染纯色背景遮罩。
    case color(UIColor, interactive: Bool)

    /// 渲染毛玻璃背景遮罩。
    case blur(UIBlurEffect.Style, alpha: CGFloat, interactive: Bool)

    /// 点击背景遮罩是否视为可交互关闭。
    var isInteractive: Bool {
        switch self {
        case .none:
            return false
        case let .color(_, interactive):
            return interactive
        case let .blur(_, _, interactive):
            return interactive
        }
    }
}

/// 内建弹窗内容视图使用的视觉主题。
public struct XAlertTheme {
    /// 居中弹窗主容器背景色。
    public var alertBackgroundColor: UIColor

    /// 表单式弹窗主体背景色。
    public var sheetBackgroundColor: UIColor

    /// 表单式弹窗取消按钮区域背景色。
    public var sheetCancelBackgroundColor: UIColor

    /// 横幅背景色。
    public var bannerBackgroundColor: UIColor

    /// 标题字体。
    public var titleFont: UIFont

    /// 标题文字颜色。
    public var titleColor: UIColor

    /// 正文字体。
    public var messageFont: UIFont

    /// 正文文字颜色。
    public var messageColor: UIColor

    /// 普通 Action 标题颜色。
    public var normalActionTitleColor: UIColor

    /// 取消 Action 标题颜色。
    public var cancelActionTitleColor: UIColor

    /// 危险 Action 标题颜色。
    public var destructiveActionTitleColor: UIColor

    /// 操作按钮高亮背景色。
    public var actionHighlightedBackgroundColor: UIColor

    /// 操作按钮分隔线颜色。
    public var actionBorderColor: UIColor

    /// 创建主题。
    public init(
        alertBackgroundColor: UIColor = .tertiarySystemBackground,
        sheetBackgroundColor: UIColor = .secondarySystemBackground,
        sheetCancelBackgroundColor: UIColor = .secondarySystemBackground,
        bannerBackgroundColor: UIColor = .secondarySystemBackground,
        titleFont: UIFont = .systemFont(ofSize: 18, weight: .semibold),
        titleColor: UIColor = .label,
        messageFont: UIFont = .systemFont(ofSize: 14),
        messageColor: UIColor = .secondaryLabel,
        normalActionTitleColor: UIColor = .systemBlue,
        cancelActionTitleColor: UIColor = .label,
        destructiveActionTitleColor: UIColor = .systemRed,
        actionHighlightedBackgroundColor: UIColor = .systemGray5,
        actionBorderColor: UIColor = .separator
    ) {
        self.alertBackgroundColor = alertBackgroundColor
        self.sheetBackgroundColor = sheetBackgroundColor
        self.sheetCancelBackgroundColor = sheetCancelBackgroundColor
        self.bannerBackgroundColor = bannerBackgroundColor
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.messageFont = messageFont
        self.messageColor = messageColor
        self.normalActionTitleColor = normalActionTitleColor
        self.cancelActionTitleColor = cancelActionTitleColor
        self.destructiveActionTitleColor = destructiveActionTitleColor
        self.actionHighlightedBackgroundColor = actionHighlightedBackgroundColor
        self.actionBorderColor = actionBorderColor
    }

    /// 默认动态颜色主题。
    public static let `default` = XAlertTheme()
}

/// 定义 Action 角色。
public enum XAlertActionRole {
    /// 默认 Action。
    case normal

    /// 取消 Action。
    case cancel

    /// 危险 Action。
    case destructive
}

/// 应用到 Action 按钮的外观配置。
public struct XAlertActionAppearance {
    /// 应用到 Action 按钮的边框位置。
    public struct BorderPosition: OptionSet {
        /// 原始选项值。
        public let rawValue: Int

        /// 顶部边框。
        public static let top = BorderPosition(rawValue: 1 << 0)

        /// 底部边框。
        public static let bottom = BorderPosition(rawValue: 1 << 1)

        /// 左侧语义边框。
        public static let leading = BorderPosition(rawValue: 1 << 2)

        /// 右侧语义边框。
        public static let trailing = BorderPosition(rawValue: 1 << 3)

        /// 所有边框。
        public static let all: BorderPosition = [.top, .bottom, .leading, .trailing]

        /// 创建边框位置。
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }

    /// 操作按钮标题字体。
    public var font: UIFont?

    /// 普通状态标题颜色。
    public var titleColor: UIColor?

    /// 高亮状态标题颜色。
    public var highlightedTitleColor: UIColor?

    /// 普通状态背景色。
    public var backgroundColor: UIColor?

    /// 高亮状态背景色。
    public var highlightedBackgroundColor: UIColor?

    /// 按钮高度。
    public var height: CGFloat

    /// 边框颜色。
    public var borderColor: UIColor?

    /// 边框宽度。
    public var borderWidth: CGFloat

    /// 边框位置。
    public var borderPosition: BorderPosition

    /// 创建 Action 外观配置。
    public init(
        font: UIFont? = nil,
        titleColor: UIColor? = nil,
        highlightedTitleColor: UIColor? = nil,
        backgroundColor: UIColor? = nil,
        highlightedBackgroundColor: UIColor? = nil,
        height: CGFloat = 44,
        borderColor: UIColor? = nil,
        borderWidth: CGFloat = 1 / UIScreen.main.scale,
        borderPosition: BorderPosition = .top
    ) {
        self.font = font
        self.titleColor = titleColor
        self.highlightedTitleColor = highlightedTitleColor
        self.backgroundColor = backgroundColor
        self.highlightedBackgroundColor = highlightedBackgroundColor
        self.height = max(1, height)
        self.borderColor = borderColor
        self.borderWidth = max(0, borderWidth)
        self.borderPosition = borderPosition
    }
}

/// 定义弹窗中展示的内容项。
public enum XAlertItem {
    /// 标题文本。
    case title(String)

    /// 正文文本。
    case message(String)

    /// 输入框内容项，创建后通过闭包配置。
    case textField((UITextField) -> Void)

    /// 自定义视图内容项。
    case customView(UIView)
}

/// 定义弹窗中展示的 Action。
public struct XAlertAction {
    /// 操作标题。
    public var title: String

    /// 操作角色。
    public var role: XAlertActionRole

    /// 点击 Action 后是否保持弹窗可见。
    public var keepsAlertVisible: Bool

    /// 可选的 Action 外观覆盖配置。
    public var appearance: XAlertActionAppearance

    /// 操作点击回调。
    public var handler: (() -> Void)?

    /// 创建弹窗 Action。
    public init(
        title: String,
        role: XAlertActionRole = .normal,
        keepsAlertVisible: Bool = false,
        appearance: XAlertActionAppearance = XAlertActionAppearance(),
        handler: (() -> Void)? = nil
    ) {
        self.title = title
        self.role = role
        self.keepsAlertVisible = keepsAlertVisible
        self.appearance = appearance
        self.handler = handler
    }
}

/// 描述内建内容视图共享的布局配置。
public struct XAlertLayoutConfiguration {
    /// 应用到内容容器的四角圆角。
    public struct CornerRadii: Equatable {
        /// 左上角圆角。
        public var topLeft: CGFloat

        /// 右上角圆角。
        public var topRight: CGFloat

        /// 左下角圆角。
        public var bottomLeft: CGFloat

        /// 右下角圆角。
        public var bottomRight: CGFloat

        /// 创建四角圆角配置。
        public init(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
            self.topLeft = topLeft
            self.topRight = topRight
            self.bottomLeft = bottomLeft
            self.bottomRight = bottomRight
        }

        /// 创建四角相同的圆角配置。
        public static func all(_ radius: CGFloat) -> CornerRadii {
            CornerRadii(topLeft: radius, topRight: radius, bottomLeft: radius, bottomRight: radius)
        }
    }

    /// 最大内容宽度。
    public var maxWidth: CGFloat

    /// 最大内容高度，`nil` 表示由宿主安全区决定上限。
    public var maxHeight: CGFloat?

    /// 内容项周围的内边距。
    public var contentInsets: UIEdgeInsets

    /// 应用到主内容容器的四角圆角。
    public var cornerRadii: CornerRadii

    /// 应用到 Sheet 取消按钮容器的四角圆角。
    public var sheetCancelCornerRadii: CornerRadii

    /// 居中弹窗样式的操作按钮是否使用竖向布局。
    public var usesVerticalActions: Bool

    /// 内容超出高度时是否允许滚动。
    public var isScrollEnabled: Bool

    /// 内容滚动时是否显示滚动指示器。
    public var showsScrollIndicator: Bool

    /// 操作按钮是否跟随内容项一起滚动。
    public var isActionFollowScrollEnabled: Bool

    /// 表单式弹窗主体与取消按钮之间的垂直间距。
    public var sheetCancelSpacing: CGFloat

    /// 表单式弹窗内容是否延伸到底部安全区。
    public var extendsSheetIntoBottomSafeArea: Bool

    /// 创建默认布局配置。
    public init(
        maxWidth: CGFloat = 280,
        maxHeight: CGFloat? = nil,
        contentInsets: UIEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20),
        cornerRadius: CGFloat = 13,
        usesVerticalActions: Bool = false,
        isScrollEnabled: Bool = true,
        showsScrollIndicator: Bool = true,
        isActionFollowScrollEnabled: Bool = true,
        sheetCancelSpacing: CGFloat = 8,
        extendsSheetIntoBottomSafeArea: Bool = true
    ) {
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.contentInsets = contentInsets
        self.cornerRadii = .all(cornerRadius)
        self.sheetCancelCornerRadii = .all(cornerRadius)
        self.usesVerticalActions = usesVerticalActions
        self.isScrollEnabled = isScrollEnabled
        self.showsScrollIndicator = showsScrollIndicator
        self.isActionFollowScrollEnabled = isActionFollowScrollEnabled
        self.sheetCancelSpacing = sheetCancelSpacing
        self.extendsSheetIntoBottomSafeArea = extendsSheetIntoBottomSafeArea
    }

    /// 统一圆角半径的兼容属性。
    public var cornerRadius: CGFloat {
        get { cornerRadii.topLeft }
        set {
            cornerRadii = .all(newValue)
            sheetCancelCornerRadii = .all(newValue)
        }
    }
}

/// 内建动画样式。
public enum XAlertAnimationStyle {
    /// 根据展示位置选择默认动画。
    case automatic

    /// 淡入淡出。
    case fade

    /// 淡入淡出并缩放。
    case fadeScale

    /// 弹性淡入并缩放。
    case springScale

    /// 普通滑入滑出。
    case slide

    /// 弹性滑入，关闭时普通滑出。
    case springSlide

    /// 无动画。
    case none
}

/// 描述单个动画阶段的配置。
public struct XAlertAnimationPhaseConfiguration {
    /// 动画样式。
    public var style: XAlertAnimationStyle

    /// 动画时长。
    public var duration: TimeInterval

    /// 弹性动画阻尼。
    public var springDamping: CGFloat

    /// 弹性动画初速度。
    public var initialSpringVelocity: CGFloat

    /// 内容视图缩放起始或结束比例。
    public var scale: CGFloat

    /// 创建动画阶段配置。
    public init(
        style: XAlertAnimationStyle = .automatic,
        duration: TimeInterval,
        springDamping: CGFloat = 0.82,
        initialSpringVelocity: CGFloat = 0,
        scale: CGFloat = 0.94
    ) {
        self.style = style
        self.duration = duration
        self.springDamping = springDamping
        self.initialSpringVelocity = initialSpringVelocity
        self.scale = scale
    }
}

/// 描述动画配置。
public struct XAlertAnimationConfiguration {
    /// 展示动画配置。
    public var present: XAlertAnimationPhaseConfiguration

    /// 关闭动画配置。
    public var dismiss: XAlertAnimationPhaseConfiguration

    /// 展示动画时长的兼容属性。
    public var presentDuration: TimeInterval {
        get { present.duration }
        set { present.duration = newValue }
    }

    /// 关闭动画时长的兼容属性。
    public var dismissDuration: TimeInterval {
        get { dismiss.duration }
        set { dismiss.duration = newValue }
    }

    /// 创建默认动画配置。
    public init(
        present: XAlertAnimationPhaseConfiguration,
        dismiss: XAlertAnimationPhaseConfiguration
    ) {
        self.present = present
        self.dismiss = dismiss
    }

    /// 创建默认动画配置。
    public init(presentDuration: TimeInterval = 0.36, dismissDuration: TimeInterval = 0.18) {
        self.init(
            present: XAlertAnimationPhaseConfiguration(duration: presentDuration),
            dismiss: XAlertAnimationPhaseConfiguration(duration: dismissDuration)
        )
    }
}
