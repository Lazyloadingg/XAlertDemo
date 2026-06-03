import UIKit

/// 面向 Objective-C 的 XAlert 入口封装。
///
/// 该封装有意只暴露常用能力，
/// 以便 Swift 优先的主 API 保持强类型和协议扩展能力。
@objc(XAlertObjC)
public final class XAlertObjC: NSObject {
    /// 创建 Objective-C 可链式调用的 Alert 构建器。
    @objc public static func alert() -> XAlertObjCBuilder {
        XAlertObjCBuilder(builder: XAlert.alert())
    }

    /// 创建 Objective-C 可链式调用的 Sheet 构建器。
    @objc public static func sheet() -> XAlertObjCBuilder {
        XAlertObjCBuilder(builder: XAlert.sheet())
    }

    /// 关闭所有场景中匹配业务标识的弹窗。
    @objc public static func close(identifier: String) {
        XAlert.close(identifier: identifier)
    }

    /// 关闭所有场景中的可见和排队弹窗。
    @objc public static func closeAll() {
        XAlert.closeAll()
    }

    /// 关闭所有场景中最上层的可见弹窗。
    @objc public static func closeTop() {
        XAlert.closeTop()
    }

    /// 移除所有场景中的排队弹窗。
    @objc public static func clearQueue() {
        XAlert.clearQueue()
    }

    /// 尝试推进所有场景中的排队展示。
    @objc public static func continueQueue() {
        XAlert.continueQueue()
    }

    /// 没有排队弹窗时返回 true。
    @objc public static func isQueueEmpty() -> Bool {
        XAlert.isQueueEmpty()
    }

    /// 当可见或排队弹窗匹配 identifier 时返回 true。
    @objc public static func contains(identifier: String) -> Bool {
        XAlert.contains(identifier: identifier)
    }

    /// 返回所有场景中的可见弹窗数量。
    @objc public static func visibleCount() -> Int {
        XAlert.visibleCount()
    }

    /// 返回所有场景中的排队弹窗数量。
    @objc public static func queuedCount() -> Int {
        XAlert.queuedCount()
    }
}

/// 面向 Objective-C 的链式构建器。
@objc(XAlertObjCBuilder)
public final class XAlertObjCBuilder: NSObject {
    private var builder: XAlertBuilder

    /// 创建 Objective-C 链式构建器。
    init(builder: XAlertBuilder) {
        self.builder = builder
        super.init()
    }

    /// 设置弹窗要挂载的视图控制器。
    @objc @discardableResult
    public func from(_ viewController: UIViewController) -> XAlertObjCBuilder {
        builder = builder.presentationContext(.viewController(viewController))
        return self
    }

    /// 设置业务标识。
    @objc @discardableResult
    public func identifier(_ identifier: String) -> XAlertObjCBuilder {
        builder = builder.identifier(identifier)
        return self
    }

    /// 设置弹窗优先级。
    @objc @discardableResult
    public func priority(_ priority: Int) -> XAlertObjCBuilder {
        builder = builder.priority(priority)
        return self
    }

    /// 开启或关闭点击背景关闭。
    @objc @discardableResult
    public func backgroundDismissEnabled(_ enabled: Bool) -> XAlertObjCBuilder {
        builder = builder.backgroundDismissEnabled(enabled)
        return self
    }

    /// 设置最大内容宽度。
    @objc @discardableResult
    public func maxWidth(_ width: CGFloat) -> XAlertObjCBuilder {
        builder = builder.maxWidth(width)
        return self
    }

    /// 设置最大内容高度。
    @objc @discardableResult
    public func maxHeight(_ height: CGFloat) -> XAlertObjCBuilder {
        builder = builder.maxHeight(height)
        return self
    }

    /// 开启或关闭内容滚动。
    @objc @discardableResult
    public func scrollEnabled(_ enabled: Bool) -> XAlertObjCBuilder {
        builder = builder.scrollEnabled(enabled)
        return self
    }

    /// 开启或关闭滚动指示器。
    @objc @discardableResult
    public func showsScrollIndicator(_ shows: Bool) -> XAlertObjCBuilder {
        builder = builder.showsScrollIndicator(shows)
        return self
    }

    /// 设置 Action 按钮是否跟随内容项滚动。
    @objc @discardableResult
    public func actionFollowScrollEnabled(_ enabled: Bool) -> XAlertObjCBuilder {
        builder = builder.actionFollowScrollEnabled(enabled)
        return self
    }

    /// 设置 Alert 主背景色。
    @objc @discardableResult
    public func alertBackgroundColor(_ color: UIColor) -> XAlertObjCBuilder {
        builder = builder.alertBackgroundColor(color)
        return self
    }

    /// 设置 Sheet 主体背景色。
    @objc @discardableResult
    public func sheetBackgroundColor(_ color: UIColor) -> XAlertObjCBuilder {
        builder = builder.sheetBackgroundColor(color)
        return self
    }

    /// 设置标题文字颜色。
    @objc @discardableResult
    public func titleColor(_ color: UIColor) -> XAlertObjCBuilder {
        builder = builder.titleStyle(color: color)
        return self
    }

    /// 设置正文文字颜色。
    @objc @discardableResult
    public func messageColor(_ color: UIColor) -> XAlertObjCBuilder {
        builder = builder.messageStyle(color: color)
        return self
    }

    /// 使用排队展示模式。
    @objc @discardableResult
    public func queueDisplay() -> XAlertObjCBuilder {
        builder = builder.displayMode(.queue)
        return self
    }

    /// 使用立即展示模式。
    @objc @discardableResult
    public func immediateDisplay() -> XAlertObjCBuilder {
        builder = builder.displayMode(.immediate)
        return self
    }

    /// 从顶部边缘展示。
    @objc @discardableResult
    public func presentFromTop() -> XAlertObjCBuilder {
        builder = builder.presentationStyle(.top)
        return self
    }

    /// 从底部边缘展示。
    @objc @discardableResult
    public func presentFromBottom() -> XAlertObjCBuilder {
        builder = builder.presentationStyle(.bottom)
        return self
    }

    /// 在屏幕中心展示。
    @objc @discardableResult
    public func presentFromCenter() -> XAlertObjCBuilder {
        builder = builder.presentationStyle(.center)
        return self
    }

    /// 设置自定义展示通道标识。
    @objc @discardableResult
    public func customLane(_ identifier: String) -> XAlertObjCBuilder {
        builder = builder.lane(.custom(XAlertLaneID(identifier)))
        return self
    }

    /// 添加标题内容项。
    @objc @discardableResult
    public func title(_ text: String) -> XAlertObjCBuilder {
        builder = builder.title(text)
        return self
    }

    /// 添加正文内容项。
    @objc @discardableResult
    public func message(_ text: String) -> XAlertObjCBuilder {
        builder = builder.message(text)
        return self
    }

    /// 添加自定义视图内容项。
    @objc @discardableResult
    public func customView(_ view: UIView) -> XAlertObjCBuilder {
        builder = builder.customView(view)
        return self
    }

    /// 添加输入框内容项。
    @objc @discardableResult
    public func textField(_ configure: @escaping (UITextField) -> Void) -> XAlertObjCBuilder {
        builder = builder.textField(configure)
        return self
    }

    /// 添加普通 Action。
    @objc @discardableResult
    public func action(_ title: String, handler: (() -> Void)? = nil) -> XAlertObjCBuilder {
        builder = builder.action(title, handler: handler)
        return self
    }

    /// 添加取消 Action。
    @objc @discardableResult
    public func cancel(_ title: String, handler: (() -> Void)? = nil) -> XAlertObjCBuilder {
        builder = builder.cancel(title, handler: handler)
        return self
    }

    /// 添加危险 Action。
    @objc @discardableResult
    public func destructive(_ title: String, handler: (() -> Void)? = nil) -> XAlertObjCBuilder {
        builder = builder.destructive(title, handler: handler)
        return self
    }

    /// 展示当前配置的弹窗。
    @objc public func show() {
        builder.show()
    }
}
