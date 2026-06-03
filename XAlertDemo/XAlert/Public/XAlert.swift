import UIKit

/// 创建、展示和关闭 XAlert 实例的公开入口。
public enum XAlert {
    /// 创建默认 Alert 构建器。
    public static func alert() -> XAlertBuilder {
        XAlertBuilder(configuration: .alertPreset())
    }

    /// 创建绑定到指定 Scene 的默认 Alert 构建器。
    public static func alert(in scene: UIWindowScene) -> XAlertBuilder {
        alert().presentationContext(.windowScene(scene, level: .alert))
    }

    /// 创建绑定到指定视图控制器的默认 Alert 构建器。
    public static func alert(from viewController: UIViewController) -> XAlertBuilder {
        alert().presentationContext(.viewController(viewController))
    }

    /// 创建默认 Sheet 构建器。
    public static func sheet() -> XAlertBuilder {
        XAlertBuilder(configuration: .sheetPreset())
    }

    /// 创建绑定到指定 Scene 的默认 Sheet 构建器。
    public static func sheet(in scene: UIWindowScene) -> XAlertBuilder {
        sheet().presentationContext(.windowScene(scene, level: .alert))
    }

    /// 创建绑定到指定视图控制器的默认 Sheet 构建器。
    public static func sheet(from viewController: UIViewController) -> XAlertBuilder {
        sheet().presentationContext(.viewController(viewController))
    }

    /// 创建空白构建器，调用方应显式设置内容样式和展示样式。
    public static func make() -> XAlertBuilder {
        XAlertBuilder(
            configuration: XAlertConfiguration(
                contentStyle: .alert,
                presentationStyle: .center
            )
        )
    }

    /// 关闭匹配 identifier 的可见或排队弹窗。
    public static func close(identifier: String, in scene: UIWindowScene? = nil) {
        XAlertSceneRegistry.shared.close(identifier: identifier, in: scene)
    }

    /// 关闭指定 Scene 中所有可见和排队弹窗。
    public static func closeAll(in scene: UIWindowScene? = nil) {
        XAlertSceneRegistry.shared.closeAll(in: scene)
    }

    /// 关闭最上层可见弹窗。
    public static func closeTop(in scene: UIWindowScene? = nil) {
        XAlertSceneRegistry.shared.closeTop(in: scene)
    }

    /// 关闭指定 lane 中最上层可见弹窗。
    public static func closeTop(in lane: XAlertPresentationLane, scene: UIWindowScene? = nil) {
        XAlertSceneRegistry.shared.closeTop(in: lane, scene: scene)
    }

    /// 关闭指定 lane 中所有可见和排队弹窗。
    public static func closeAll(in lane: XAlertPresentationLane, scene: UIWindowScene? = nil) {
        XAlertSceneRegistry.shared.closeAll(in: lane, scene: scene)
    }

    /// 移除排队弹窗，但不关闭当前可见弹窗。
    public static func clearQueue(in scene: UIWindowScene? = nil) {
        XAlertSceneRegistry.shared.clearQueue(in: scene)
    }

    /// 移除指定 lane 中的排队弹窗，但不关闭当前可见弹窗。
    public static func clearQueue(in lane: XAlertPresentationLane, scene: UIWindowScene? = nil) {
        XAlertSceneRegistry.shared.clearQueue(in: lane, scene: scene)
    }

    /// 在 lane 容量允许时尝试展示下一个排队弹窗。
    public static func continueQueue(in scene: UIWindowScene? = nil) {
        XAlertSceneRegistry.shared.continueQueue(in: scene)
    }

    /// 当可见或排队弹窗匹配 identifier 时返回 true。
    public static func contains(identifier: String, in scene: UIWindowScene? = nil) -> Bool {
        XAlertSceneRegistry.shared.contains(identifier: identifier, in: scene)
    }

    /// 返回可见弹窗数量。
    public static func visibleCount(in scene: UIWindowScene? = nil) -> Int {
        XAlertSceneRegistry.shared.visibleCount(in: scene)
    }

    /// 返回指定 lane 中的可见弹窗数量。
    public static func visibleCount(in lane: XAlertPresentationLane, scene: UIWindowScene? = nil) -> Int {
        XAlertSceneRegistry.shared.visibleCount(in: lane, scene: scene)
    }

    /// 返回排队弹窗数量。
    public static func queuedCount(in scene: UIWindowScene? = nil) -> Int {
        XAlertSceneRegistry.shared.queuedCount(in: scene)
    }

    /// 返回指定 lane 中的排队弹窗数量。
    public static func queuedCount(in lane: XAlertPresentationLane, scene: UIWindowScene? = nil) -> Int {
        XAlertSceneRegistry.shared.queuedCount(in: lane, scene: scene)
    }

    /// 没有排队弹窗时返回 true。
    public static func isQueueEmpty(in scene: UIWindowScene? = nil) -> Bool {
        queuedCount(in: scene) == 0
    }

    /// 配置 lane 策略。
    ///
    /// 传入 Scene 时只应用到该 Scene；传入 `nil` 时
    /// 更新现有和未来 Scene 协调器使用的全局默认策略。
    public static func configureLane(
        _ lane: XAlertPresentationLane,
        policy: XAlertLanePolicy,
        in scene: UIWindowScene? = nil
    ) {
        XAlertSceneRegistry.shared.configureLane(lane, policy: policy, in: scene)
    }
}
