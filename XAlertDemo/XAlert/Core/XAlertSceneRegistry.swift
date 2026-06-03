import UIKit

/// 为每个窗口场景持有一个协调器的注册中心。
final class XAlertSceneRegistry {
    /// 共享注册中心。
    static let shared = XAlertSceneRegistry()

    private var coordinators: [ObjectIdentifier: XAlertSceneCoordinator] = [:]
    private var embeddedCoordinators: [ObjectIdentifier: XAlertSceneCoordinator] = [:]
    private var defaultLanePolicies: [XAlertPresentationLane: XAlertLanePolicy] = [:]

    private init() {}

    /// 展示一份弹窗配置。
    func show(_ configuration: XAlertConfiguration) {
        guard let coordinator = coordinator(for: configuration.presentationContext) else {
            assertionFailure("XAlert could not resolve a presentation context.")
            return
        }
        coordinator.show(configuration)
    }

    /// 关闭匹配业务标识的弹窗。
    func close(identifier: String, in scene: UIWindowScene?) {
        if let scene {
            coordinator(for: scene)?.close(identifier: identifier)
        } else {
            coordinators.values.forEach { $0.close(identifier: identifier) }
            embeddedCoordinators.values.forEach { $0.close(identifier: identifier) }
        }
    }

    /// 关闭所有弹窗。
    func closeAll(in scene: UIWindowScene?) {
        if let scene {
            coordinator(for: scene)?.closeAll()
        } else {
            coordinators.values.forEach { $0.closeAll() }
            embeddedCoordinators.values.forEach { $0.closeAll() }
        }
    }

    /// 关闭最上层可见弹窗。
    func closeTop(in scene: UIWindowScene?) {
        if let scene {
            coordinator(for: scene)?.closeTop()
        } else {
            allCoordinators().forEach { $0.closeTop() }
        }
    }

    /// 关闭指定 lane 中最上层可见弹窗。
    func closeTop(in lane: XAlertPresentationLane, scene: UIWindowScene?) {
        if let scene {
            coordinator(for: scene)?.closeTop(in: lane)
        } else {
            allCoordinators().forEach { $0.closeTop(in: lane) }
        }
    }

    /// 关闭指定 lane 中所有可见和排队弹窗。
    func closeAll(in lane: XAlertPresentationLane, scene: UIWindowScene?) {
        if let scene {
            coordinator(for: scene)?.closeAll(in: lane)
        } else {
            allCoordinators().forEach { $0.closeAll(in: lane) }
        }
    }

    /// 移除排队弹窗。
    func clearQueue(in scene: UIWindowScene?) {
        if let scene {
            coordinator(for: scene)?.clearQueue()
        } else {
            allCoordinators().forEach { $0.clearQueue() }
        }
    }

    /// 移除指定通道中的排队弹窗。
    func clearQueue(in lane: XAlertPresentationLane, scene: UIWindowScene?) {
        if let scene {
            coordinator(for: scene)?.clearQueue(in: lane)
        } else {
            allCoordinators().forEach { $0.clearQueue(in: lane) }
        }
    }

    /// 尝试推进排队展示。
    func continueQueue(in scene: UIWindowScene?) {
        if let scene {
            coordinator(for: scene)?.continueQueue()
        } else {
            allCoordinators().forEach { $0.continueQueue() }
        }
    }

    /// 当弹窗业务标识已可见或已排队时返回 true。
    func contains(identifier: String, in scene: UIWindowScene?) -> Bool {
        if let scene {
            return coordinator(for: scene)?.contains(identifier: identifier) ?? false
        }
        return coordinators.values.contains { $0.contains(identifier: identifier) }
            || embeddedCoordinators.values.contains { $0.contains(identifier: identifier) }
    }

    /// 返回可见弹窗数量。
    func visibleCount(in scene: UIWindowScene?) -> Int {
        if let scene {
            return coordinator(for: scene)?.visibleCount() ?? 0
        }
        return allCoordinators().reduce(0) { $0 + $1.visibleCount() }
    }

    /// 返回指定通道中的可见弹窗数量。
    func visibleCount(in lane: XAlertPresentationLane, scene: UIWindowScene?) -> Int {
        if let scene {
            return coordinator(for: scene)?.visibleCount(in: lane) ?? 0
        }
        return allCoordinators().reduce(0) { $0 + $1.visibleCount(in: lane) }
    }

    /// 返回排队弹窗数量。
    func queuedCount(in scene: UIWindowScene?) -> Int {
        if let scene {
            return coordinator(for: scene)?.queuedCount() ?? 0
        }
        return allCoordinators().reduce(0) { $0 + $1.queuedCount() }
    }

    /// 返回指定通道中的排队弹窗数量。
    func queuedCount(in lane: XAlertPresentationLane, scene: UIWindowScene?) -> Int {
        if let scene {
            return coordinator(for: scene)?.queuedCount(in: lane) ?? 0
        }
        return allCoordinators().reduce(0) { $0 + $1.queuedCount(in: lane) }
    }

    /// 配置 lane 策略。
    func configureLane(_ lane: XAlertPresentationLane, policy: XAlertLanePolicy, in scene: UIWindowScene?) {
        if let scene {
            coordinator(for: scene)?.setLanePolicy(policy, for: lane)
        } else {
            defaultLanePolicies[lane] = policy
            coordinators.values.forEach { $0.setLanePolicy(policy, for: lane) }
            embeddedCoordinators.values.forEach { $0.setLanePolicy(policy, for: lane) }
        }
    }

    private func coordinator(for context: XAlertPresentationContext) -> XAlertSceneCoordinator? {
        switch context {
        case .automatic:
            guard let scene = Self.activeWindowScene() else { return nil }
            return coordinator(for: scene)
        case let .windowScene(scene, _):
            return coordinator(for: scene)
        case let .viewController(viewController):
            if let scene = viewController.view.window?.windowScene {
                return coordinator(for: scene)
            }
            if viewController.isViewLoaded {
                return embeddedCoordinator(for: viewController.view)
            }
            guard let scene = Self.activeWindowScene() else { return nil }
            return coordinator(for: scene)
        case let .view(view):
            if let scene = view.window?.windowScene {
                return coordinator(for: scene)
            }
            guard view.superview != nil else {
                guard let scene = Self.activeWindowScene() else { return nil }
                return coordinator(for: scene)
            }
            return embeddedCoordinator(for: view)
        }
    }

    private func coordinator(for scene: UIWindowScene) -> XAlertSceneCoordinator? {
        let key = ObjectIdentifier(scene)
        if let coordinator = coordinators[key] {
            return coordinator
        }
        let coordinator = XAlertSceneCoordinator(scene: scene, lanePolicies: defaultLanePolicies)
        coordinators[key] = coordinator
        return coordinator
    }

    private func embeddedCoordinator(for view: UIView) -> XAlertSceneCoordinator {
        let key = ObjectIdentifier(view)
        if let coordinator = embeddedCoordinators[key] {
            return coordinator
        }
        let coordinator = XAlertSceneCoordinator(embeddedContainer: view, lanePolicies: defaultLanePolicies)
        embeddedCoordinators[key] = coordinator
        return coordinator
    }

    private func allCoordinators() -> [XAlertSceneCoordinator] {
        Array(coordinators.values) + Array(embeddedCoordinators.values)
    }

    private static func activeWindowScene() -> UIWindowScene? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
    }
}
