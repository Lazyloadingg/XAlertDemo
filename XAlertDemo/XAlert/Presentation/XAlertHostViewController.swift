import UIKit

/// 管理可见弹窗内容控制器的宿主控制器。
final class XAlertHostViewController: UIViewController {
    /// 点击背景遮罩时触发。
    var onBackgroundTap: (() -> Void)?

    private let dimControl = UIControl()
    private let blurView = UIVisualEffectView(effect: nil)
    private var installedControllers: [UUID: XAlertContentController] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        dimControl.frame = view.bounds
        dimControl.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimControl.backgroundColor = .clear
        dimControl.addTarget(self, action: #selector(backgroundTapped), for: .touchUpInside)
        view.addSubview(dimControl)

        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.alpha = 0
        dimControl.addSubview(blurView)
    }

    /// 安装并展示一个弹窗实例。
    func install(_ instance: XAlertInstance) {
        let controller = instance.contentController
        installedControllers[instance.id] = controller
        addChild(controller)
        view.addSubview(controller.view)
        controller.view.frame = view.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controller.didMove(toParent: self)
        controller.present()
    }

    /// 关闭并移除一个弹窗实例。
    func remove(_ instance: XAlertInstance, completion: @escaping () -> Void) {
        guard let controller = installedControllers[instance.id] else {
            completion()
            return
        }
        controller.dismiss { [weak self, weak controller] in
            guard let self, let controller else {
                completion()
                return
            }
            controller.willMove(toParent: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParent()
            self.installedControllers.removeValue(forKey: instance.id)
            completion()
        }
    }

    /// 更新共享背景遮罩。
    func updateDimMode(_ mode: XAlertDimMode, animated: Bool = true) {
        let updates = {
            self.applyDimMode(mode)
        }

        guard animated else {
            updates()
            return
        }

        UIView.animate(
            withDuration: 0.18,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut, .allowUserInteraction],
            animations: updates
        )
    }

    private func applyDimMode(_ mode: XAlertDimMode) {
        switch mode {
        case .none:
            dimControl.backgroundColor = .clear
            blurView.effect = nil
            blurView.alpha = 0
        case let .color(color, _):
            blurView.effect = nil
            blurView.alpha = 0
            dimControl.backgroundColor = color
        case let .blur(style, alpha, _):
            dimControl.backgroundColor = .clear
            blurView.effect = UIBlurEffect(style: style)
            blurView.alpha = alpha
        }
    }

    @objc private func backgroundTapped() {
        onBackgroundTap?()
    }
}
