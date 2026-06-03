import UIKit

/// 协调单个展示作用域内的可见弹窗和排队弹窗。
final class XAlertSceneCoordinator {
    private let scene: UIWindowScene?
    private weak var embeddedContainer: UIView?
    private var overlayWindow: XAlertOverlayWindow?
    private var hostViewController: XAlertHostViewController?
    private var visibleInstances: [XAlertInstance] = []
    private var queuedInstances: [XAlertInstance] = []
    private var lanePolicies: [XAlertPresentationLane: XAlertLanePolicy] = [:]
    private var sequence: Int = 0

    /// 创建绑定场景覆盖窗口的协调器。
    init(scene: UIWindowScene, lanePolicies: [XAlertPresentationLane: XAlertLanePolicy] = [:]) {
        self.scene = scene
        self.lanePolicies = lanePolicies
    }

    /// 创建嵌入指定视图的协调器。
    init(embeddedContainer: UIView, lanePolicies: [XAlertPresentationLane: XAlertLanePolicy] = [:]) {
        self.scene = nil
        self.embeddedContainer = embeddedContainer
        self.lanePolicies = lanePolicies
    }

    /// 展示一份弹窗配置。
    func show(_ configuration: XAlertConfiguration) {
        if configuration.ignoresDuplicateIdentifier,
           let identifier = configuration.identifier,
           containsAlert(identifier: identifier) {
            return
        }

        sequence += 1
        let instance = XAlertInstance(configuration: configuration, createdSequence: sequence)

        switch configuration.displayMode {
        case .unique:
            guard let identifier = configuration.identifier, !containsAlert(identifier: identifier) else { return }
            enqueueOrPresent(instance)
        case .queue:
            enqueueOrPresent(instance)
        case .immediate:
            presentOrApplyOverflow(instance)
        case .replaceCurrent:
            replaceCurrent(in: configuration.lane, with: instance)
        }
    }

    /// 关闭匹配 identifier 的可见或排队弹窗。
    func close(identifier: String) {
        queuedInstances.removeAll { $0.configuration.identifier == identifier }
        visibleInstances
            .filter { $0.configuration.identifier == identifier }
            .forEach { dismiss($0) }
    }

    /// 关闭所有可见和排队弹窗。
    func closeAll() {
        queuedInstances.removeAll()
        visibleInstances.forEach { dismiss($0) }
    }

    /// 关闭最上层可见弹窗。
    func closeTop() {
        guard let instance = visibleInstances.sorted(by: isHigherZIndex).last else { return }
        dismiss(instance)
    }

    /// 关闭指定 lane 中最上层可见弹窗。
    func closeTop(in lane: XAlertPresentationLane) {
        guard let instance = visibleInstances
            .filter({ $0.configuration.lane == lane })
            .sorted(by: isHigherZIndex)
            .last
        else { return }
        dismiss(instance)
    }

    /// 关闭指定 lane 中所有可见和排队弹窗。
    func closeAll(in lane: XAlertPresentationLane) {
        queuedInstances.removeAll { $0.configuration.lane == lane }
        visibleInstances
            .filter { $0.configuration.lane == lane }
            .forEach { dismiss($0) }
    }

    /// 移除所有排队弹窗。
    func clearQueue() {
        queuedInstances.removeAll()
    }

    /// 移除指定通道中的排队弹窗。
    func clearQueue(in lane: XAlertPresentationLane) {
        queuedInstances.removeAll { $0.configuration.lane == lane }
    }

    /// 在通道容量允许时尝试展示排队弹窗。
    func continueQueue() {
        lanesWithQueuedAlerts().forEach { presentNextIfPossible(in: $0) }
    }

    /// 当业务标识已可见或已排队时返回 true。
    func contains(identifier: String) -> Bool {
        containsAlert(identifier: identifier)
    }

    /// 返回可见弹窗数量。
    func visibleCount() -> Int {
        visibleInstances.count
    }

    /// 返回指定通道中的可见弹窗数量。
    func visibleCount(in lane: XAlertPresentationLane) -> Int {
        visibleInstances.filter { $0.configuration.lane == lane }.count
    }

    /// 返回排队弹窗数量。
    func queuedCount() -> Int {
        queuedInstances.count
    }

    /// 返回指定通道中的排队弹窗数量。
    func queuedCount(in lane: XAlertPresentationLane) -> Int {
        queuedInstances.filter { $0.configuration.lane == lane }.count
    }

    /// 设置指定通道的并发策略。
    func setLanePolicy(_ policy: XAlertLanePolicy, for lane: XAlertPresentationLane) {
        lanePolicies[lane] = policy
        presentNextIfPossible(in: lane)
    }

    private func enqueueOrPresent(_ instance: XAlertInstance) {
        if visibleCount(in: instance.configuration.lane) < policy(for: instance.configuration.lane).maxVisibleCount {
            present(instance)
        } else {
            queuedInstances.append(instance)
            sortQueue()
        }
    }

    private func presentOrApplyOverflow(_ instance: XAlertInstance) {
        let lane = instance.configuration.lane
        let policy = policy(for: lane)
        guard visibleCount(in: lane) >= policy.maxVisibleCount else {
            present(instance)
            return
        }

        switch policy.overflow {
        case .queue:
            queuedInstances.append(instance)
            sortQueue()
        case .replaceOldest:
            if let target = visibleInstances.filter({ $0.configuration.lane == lane }).min(by: { $0.createdSequence < $1.createdSequence }) {
                dismiss(target) { [weak self] in self?.present(instance) }
            }
        case .replaceNewest:
            if let target = visibleInstances.filter({ $0.configuration.lane == lane }).max(by: { $0.createdSequence < $1.createdSequence }) {
                dismiss(target) { [weak self] in self?.present(instance) }
            }
        case .dropNew:
            break
        }
    }

    private func replaceCurrent(in lane: XAlertPresentationLane, with instance: XAlertInstance) {
        guard let target = visibleInstances
            .filter({ $0.configuration.lane == lane })
            .sorted(by: isHigherZIndex)
            .last
        else {
            present(instance)
            return
        }
        dismiss(target) { [weak self] in self?.present(instance) }
    }

    private func present(_ instance: XAlertInstance) {
        let host = resolvedHost(for: instance.configuration)
        instance.contentController.onDismissRequest = { [weak self, weak instance] action in
            guard let self, let instance else { return }
            self.dismiss(instance, action: action) {
                action?.handler?()
            }
        }
        host.install(instance)
        visibleInstances.append(instance)
        visibleInstances.sort(by: isHigherZIndex)
        host.updateDimMode(topConfiguration()?.dimMode ?? .none)
    }

    private func dismiss(_ instance: XAlertInstance, action: XAlertAction? = nil, completion: (() -> Void)? = nil) {
        guard visibleInstances.contains(where: { $0.id == instance.id }) else {
            completion?()
            return
        }
        guard instance.configuration.shouldDismiss?() ?? true else { return }
        if let action {
            guard instance.configuration.shouldDismissForAction?(action) ?? true else { return }
        }
        let host = resolvedHost(for: instance.configuration)
        host.updateDimMode(topConfiguration(excluding: instance)?.dimMode ?? .none)
        host.remove(instance) { [weak self] in
            guard let self else { return }
            self.visibleInstances.removeAll { $0.id == instance.id }
            self.resolvedHost(for: instance.configuration).updateDimMode(self.topConfiguration()?.dimMode ?? .none)
            self.presentNextIfPossible(in: instance.configuration.lane)
            self.cleanupIfNeeded()
            instance.configuration.onDismiss?()
            completion?()
        }
    }

    private func presentNextIfPossible(in lane: XAlertPresentationLane) {
        guard visibleCount(in: lane) < policy(for: lane).maxVisibleCount else { return }
        guard let index = queuedInstances.firstIndex(where: { $0.configuration.lane == lane }) else { return }
        let next = queuedInstances.remove(at: index)
        present(next)
    }

    private func resolvedHost(for configuration: XAlertConfiguration) -> XAlertHostViewController {
        if let hostViewController {
            return hostViewController
        }

        let host = XAlertHostViewController()
        host.onBackgroundTap = { [weak self] in
            self?.dismissTopBackgroundDismissibleAlert()
        }

        if let embeddedContainer {
            embeddedContainer.addSubview(host.view)
            host.view.frame = embeddedContainer.bounds
            host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        } else if let scene {
            let level: UIWindow.Level
            if case let .windowScene(_, configuredLevel) = configuration.presentationContext {
                level = configuredLevel
            } else {
                level = .alert
            }
            let window = XAlertOverlayWindow(windowScene: scene)
            window.windowLevel = level
            window.rootViewController = host
            window.isHidden = false
            overlayWindow = window
        }

        hostViewController = host
        return host
    }

    private func dismissTopBackgroundDismissibleAlert() {
        guard let instance = visibleInstances
            .sorted(by: isHigherZIndex)
            .last(where: { $0.configuration.isBackgroundDismissEnabled || $0.configuration.dimMode.isInteractive })
        else { return }
        dismiss(instance)
    }

    private func cleanupIfNeeded() {
        guard visibleInstances.isEmpty, queuedInstances.isEmpty else { return }
        overlayWindow?.isHidden = true
        overlayWindow = nil
        hostViewController?.view.removeFromSuperview()
        hostViewController = nil
    }

    private func containsAlert(identifier: String) -> Bool {
        visibleInstances.contains { $0.configuration.identifier == identifier }
            || queuedInstances.contains { $0.configuration.identifier == identifier }
    }

    private func policy(for lane: XAlertPresentationLane) -> XAlertLanePolicy {
        lanePolicies[lane] ?? .default(for: lane)
    }

    private func topConfiguration() -> XAlertConfiguration? {
        visibleInstances.sorted(by: isHigherZIndex).last?.configuration
    }

    private func topConfiguration(excluding instance: XAlertInstance) -> XAlertConfiguration? {
        visibleInstances
            .filter { $0.id != instance.id }
            .sorted(by: isHigherZIndex)
            .last?
            .configuration
    }

    private func sortQueue() {
        queuedInstances.sort(by: isHigherZIndex)
    }

    private func lanesWithQueuedAlerts() -> [XAlertPresentationLane] {
        Array(Set(queuedInstances.map { $0.configuration.lane }))
    }

    private func isHigherZIndex(_ lhs: XAlertInstance, _ rhs: XAlertInstance) -> Bool {
        if lhs.configuration.priority == rhs.configuration.priority {
            return lhs.createdSequence < rhs.createdSequence
        }
        return lhs.configuration.priority < rhs.configuration.priority
    }
}
