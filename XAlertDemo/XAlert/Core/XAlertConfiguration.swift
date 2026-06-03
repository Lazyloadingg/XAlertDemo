import UIKit

/// 单个弹窗实例的完整配置。
public struct XAlertConfiguration {
    /// 内容布局样式。
    public var contentStyle: XAlertContentStyle

    /// 展示样式。
    public var presentationStyle: XAlertPresentationStyle

    /// 展示上下文。
    public var presentationContext: XAlertPresentationContext

    /// 展示模式。
    public var displayMode: XAlertDisplayMode

    /// 展示通道。
    public var lane: XAlertPresentationLane

    /// 背景遮罩模式。
    public var dimMode: XAlertDimMode

    /// 用于排序可见弹窗层级的优先级。
    public var priority: Int

    /// 可选业务标识。
    public var identifier: String?

    /// 是否忽略重复业务标识的弹窗。
    public var ignoresDuplicateIdentifier: Bool

    /// 点击背景遮罩是否可以关闭弹窗。
    public var isBackgroundDismissEnabled: Bool

    /// 点击内容区域是否可以关闭弹窗。
    public var isContentDismissEnabled: Bool

    /// 弹窗内容项。
    public var items: [XAlertItem]

    /// 弹窗 Action 列表。
    public var actions: [XAlertAction]

    /// 布局配置。
    public var layout: XAlertLayoutConfiguration

    /// 动画配置。
    public var animation: XAlertAnimationConfiguration

    /// 内建内容视图使用的视觉主题。
    public var theme: XAlertTheme

    /// 任意关闭路径触发前调用，返回 false 会保持弹窗可见。
    public var shouldDismiss: (() -> Bool)?

    /// 操作触发关闭前调用，返回 false 会保持弹窗可见。
    public var shouldDismissForAction: ((XAlertAction) -> Bool)?

    /// 弹窗移除后调用。
    public var onDismiss: (() -> Void)?

    /// 创建弹窗配置。
    public init(
        contentStyle: XAlertContentStyle,
        presentationStyle: XAlertPresentationStyle,
        presentationContext: XAlertPresentationContext = .automatic,
        displayMode: XAlertDisplayMode = .queue,
        lane: XAlertPresentationLane? = nil,
        dimMode: XAlertDimMode = .color(UIColor.black.withAlphaComponent(0.45), interactive: false),
        priority: Int = 0,
        identifier: String? = nil,
        ignoresDuplicateIdentifier: Bool = false,
        isBackgroundDismissEnabled: Bool = false,
        isContentDismissEnabled: Bool = false,
        items: [XAlertItem] = [],
        actions: [XAlertAction] = [],
        layout: XAlertLayoutConfiguration = XAlertLayoutConfiguration(),
        animation: XAlertAnimationConfiguration = XAlertAnimationConfiguration(),
        theme: XAlertTheme = .default,
        shouldDismiss: (() -> Bool)? = nil,
        shouldDismissForAction: ((XAlertAction) -> Bool)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.contentStyle = contentStyle
        self.presentationStyle = presentationStyle
        self.presentationContext = presentationContext
        self.displayMode = displayMode
        self.lane = lane ?? XAlertConfiguration.defaultLane(for: presentationStyle)
        self.dimMode = dimMode
        self.priority = max(0, priority)
        self.identifier = identifier
        self.ignoresDuplicateIdentifier = ignoresDuplicateIdentifier
        self.isBackgroundDismissEnabled = isBackgroundDismissEnabled
        self.isContentDismissEnabled = isContentDismissEnabled
        self.items = items
        self.actions = actions
        self.layout = layout
        self.animation = animation
        self.theme = theme
        self.shouldDismiss = shouldDismiss
        self.shouldDismissForAction = shouldDismissForAction
        self.onDismiss = onDismiss
    }

    /// 创建默认 Alert 预设配置。
    public static func alertPreset() -> XAlertConfiguration {
        XAlertConfiguration(
            contentStyle: .alert,
            presentationStyle: .center,
            displayMode: .queue,
            dimMode: .color(UIColor.black.withAlphaComponent(0.45), interactive: false),
            isBackgroundDismissEnabled: false
        )
    }

    /// 创建默认 Sheet 预设配置。
    public static func sheetPreset() -> XAlertConfiguration {
        XAlertConfiguration(
            contentStyle: .sheet,
            presentationStyle: .bottom,
            displayMode: .queue,
            dimMode: .color(UIColor.black.withAlphaComponent(0.45), interactive: true),
            isBackgroundDismissEnabled: true,
            layout: XAlertLayoutConfiguration(maxWidth: UIScreen.main.bounds.width - 20)
        )
    }

    /// 根据展示样式创建默认展示通道。
    public static func defaultLane(for style: XAlertPresentationStyle) -> XAlertPresentationLane {
        switch style {
        case .center:
            return .center
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        case .custom:
            return .center
        }
    }
}

/// 单个弹窗的运行时状态。
final class XAlertInstance {
    /// 稳定的运行时标识。
    let id = UUID()

    /// 展示时捕获的配置。
    let configuration: XAlertConfiguration

    /// 用于层级排序兜底的单调递增创建序号。
    let createdSequence: Int

    /// 负责渲染该弹窗的视图控制器。
    let contentController: XAlertContentController

    /// 创建弹窗运行时实例。
    init(configuration: XAlertConfiguration, createdSequence: Int) {
        self.configuration = configuration
        self.createdSequence = createdSequence
        self.contentController = XAlertContentController(configuration: configuration)
    }
}
