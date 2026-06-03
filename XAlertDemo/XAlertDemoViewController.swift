import UIKit

final class XAlertDemoViewController: UIViewController {

    private struct DemoItem {
        let title: String
        let detail: String
        let action: (XAlertDemoViewController) -> Void
    }

    private struct TransitionDemoStep {
        let identifier: String
        let title: String
        let message: String
        let contentStyle: XAlertContentStyle
        let presentationStyle: XAlertPresentationStyle
        let dimMode: XAlertDimMode
        let present: XAlertAnimationPhaseConfiguration
        let dismiss: XAlertAnimationPhaseConfiguration
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private lazy var items: [DemoItem] = [
        DemoItem(title: "基础 Alert", detail: "标题、正文、普通/取消操作", action: { $0.showBasicAlert() }),
        DemoItem(title: "过渡动效示例", detail: "连续展示几种出现 / 消失组合", action: { $0.showTransitionAnimationShowcase() }),
        DemoItem(title: "拖拽关闭", detail: "顶部 Banner 上滑关闭，底部 Sheet 下滑关闭", action: { $0.showInteractiveDismissDemo() }),
        DemoItem(title: "底部 Sheet", detail: "独立取消按钮、危险操作、底部安全区", action: { $0.showSheet() }),
        DemoItem(title: "顶部 Banner", detail: "无遮罩、顶部方向展示", action: { $0.showTopBanner() }),
        DemoItem(title: "方向展示", detail: "同一内容样式从四个方向进入", action: { $0.showDirectionalAlerts() }),
        DemoItem(title: "同时显示 Alert 与 Sheet", detail: "center 与 bottom 通道并发", action: { $0.showAlertAndSheetTogether() }),
        DemoItem(title: "队列与优先级", detail: "同通道排队，关闭后继续展示", action: { $0.showQueueAndPriority() }),
        DemoItem(title: "自定义 Lane 多横幅", detail: "自定义通道允许同时显示多个弹窗", action: { $0.showCustomLaneBanners() }),
        DemoItem(title: "输入框", detail: "添加 UITextField 内容项", action: { $0.showTextFieldAlert() }),
        DemoItem(title: "自定义视图", detail: "承载调用方提供的 UIView", action: { $0.showCustomViewAlert() }),
        DemoItem(title: "主题与圆角", detail: "颜色、字体、四角圆角配置", action: { $0.showThemedAlert() }),
        DemoItem(title: "长内容滚动", detail: "内容超高滚动，操作按钮固定", action: { $0.showLongContentAlert() }),
        DemoItem(title: "去重与业务标识", detail: "相同 identifier 可见或排队时忽略", action: { $0.showUniqueIdentifierAlert() }),
        DemoItem(title: "关闭能力", detail: "关闭顶部、关闭指定通道、清空队列", action: { $0.showCloseControls() })
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "XAlert Demo"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeDemo))
        configureTableView()
    }

    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func closeDemo() {
        XAlert.closeAll()
        dismiss(animated: true)
    }

    private func showBasicAlert() {
        XAlert.alert(from: self)
            .title("基础 Alert")
            .animation({
                $0.present.style = .springScale
                $0.dismiss.style = .fadeScale
            })
            .message("内容样式与展示方向解耦。这里使用居中弹窗样式，并在当前控制器内部展示。")
            .cancel("取消")
            .action("确认")
            .show()
    }

    private func showTransitionAnimationShowcase() {
        let steps: [TransitionDemoStep] = [
            TransitionDemoStep(
                identifier: "transition-demo-center-spring",
                title: "居中弹窗 Spring Scale",
                message: "出现时使用弹性缩放，消失时收成更轻的 fadeScale。",
                contentStyle: .alert,
                presentationStyle: .center,
                dimMode: .color(UIColor.black.withAlphaComponent(0.45), interactive: false),
                present: XAlertAnimationPhaseConfiguration(style: .springScale, duration: 0.36, springDamping: 0.82, initialSpringVelocity: 0, scale: 0.92),
                dismiss: XAlertAnimationPhaseConfiguration(style: .fadeScale, duration: 0.18, springDamping: 0.82, initialSpringVelocity: 0, scale: 0.96)
            ),
            TransitionDemoStep(
                identifier: "transition-demo-bottom-spring",
                title: "底部 Sheet Spring Slide",
                message: "出现时沿底边弹入，消失时直接滑出，体感更干净。",
                contentStyle: .sheet,
                presentationStyle: .bottom,
                dimMode: .color(UIColor.black.withAlphaComponent(0.35), interactive: true),
                present: XAlertAnimationPhaseConfiguration(style: .springSlide, duration: 0.42, springDamping: 0.84, initialSpringVelocity: 0, scale: 0.94),
                dismiss: XAlertAnimationPhaseConfiguration(style: .slide, duration: 0.20, springDamping: 0.84, initialSpringVelocity: 0, scale: 0.94)
            ),
            TransitionDemoStep(
                identifier: "transition-demo-top-fade",
                title: "顶部 Banner Fade",
                message: "当内容本身很轻时，可以直接用淡入淡出，避免过多位移。",
                contentStyle: .banner,
                presentationStyle: .top,
                dimMode: .none,
                present: XAlertAnimationPhaseConfiguration(style: .fade, duration: 0.20, springDamping: 0.82, initialSpringVelocity: 0, scale: 0.98),
                dismiss: XAlertAnimationPhaseConfiguration(style: .fade, duration: 0.16, springDamping: 0.82, initialSpringVelocity: 0, scale: 0.98)
            )
        ]

        for (index, step) in steps.enumerated() {
            let delay = Double(index) * 0.75
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                XAlert.make()
                    .contentStyle(step.contentStyle)
                    .presentationStyle(step.presentationStyle)
                    .displayMode(.queue)
                    .dimMode(step.dimMode)
                    .identifier(step.identifier)
                    .animation {
                        $0.present = step.present
                        $0.dismiss = step.dismiss
                    }
                    .title(step.title)
                    .message(step.message)
                    .action("知道了")
                    .show()

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.62) {
                    XAlert.close(identifier: step.identifier)
                }
            }
        }
    }

    private func showInteractiveDismissDemo() {
        XAlert.make()
            .contentStyle(.banner)
            .presentationStyle(.top)
            .displayMode(.immediate)
            .dimMode(.none)
            .interactiveDismissEnabled(true)
            .title("可拖拽 Banner")
            .message("向上拖动可以关闭，向下轻拉会回弹。")
            .action("关闭")
            .show()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            XAlert.sheet(from: self)
                .interactiveDismissEnabled(true)
                .title("可拖拽 Sheet")
                .message("向下拖动超过距离阈值，或快速下滑，可以关闭这个 Sheet。")
                .action("确认")
                .cancel("取消")
                .show()
        }
    }

    private func showSheet() {
        XAlert.sheet(from: self)
            .title("底部 Sheet")
            .message("Sheet 样式会把取消按钮渲染到主体之外，适合动作列表。")
            .action("保存草稿")
            .destructive("删除")
            .cancel("取消")
            .show()
    }

    private func showTopBanner() {
        XAlert.make()
            .contentStyle(.banner)
            .presentationStyle(.top)
            .dimMode(.none)
            .title("同步成功")
            .message("顶部 Banner 默认进入 top 通道，可与居中弹窗并存。")
            .action("知道了")
            .show()
    }

    private func showDirectionalAlerts() {
        let styles: [(String, XAlertPresentationStyle)] = [
            ("顶部", .top),
            ("底部", .bottom),
            ("左侧", .leading),
            ("右侧", .trailing)
        ]

        for (index, item) in styles.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.35) {
                XAlert.make()
                    .contentStyle(.banner)
                    .presentationStyle(item.1)
                    .dimMode(.none)
                    .title("\(item.0)展示")
                    .message("presentationStyle 决定进入方向。")
                    .identifier("direction-\(index)")
                    .action("关闭")
                    .show()
            }
        }
    }

    private func showAlertAndSheetTogether() {
        XAlert.alert(from: self)
            .title("居中 Alert")
            .message("center 通道和 bottom 通道互相隔离，因此可以同时展示。")
            .action("关闭 Alert")
            .show()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            XAlert.sheet(from: self)
                .title("底部 Sheet")
                .message("这是与 Alert 同时可见的 Sheet。")
                .action("继续")
                .cancel("关闭 Sheet")
                .show()
        }
    }

    private func showQueueAndPriority() {
        for index in 1...3 {
            XAlert.alert(from: self)
                .displayMode(.queue)
                .priority(index)
                .identifier("queue-\(index)")
                .title("队列弹窗 \(index)")
                .message("同一个 center 通道默认只显示一个弹窗，其余进入队列。")
                .action("下一个")
                .show()
        }
    }

    private func showCustomLaneBanners() {
        let lane = XAlertPresentationLane.custom(XAlertLaneID("demo.notice"))
        XAlert.configureLane(lane, policy: XAlertLanePolicy(maxVisibleCount: 2, overflow: .queue))

        for index in 1...4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index - 1) * 0.15) {
                XAlert.make()
                    .contentStyle(.banner)
                    .presentationStyle(.top)
                    .lane(lane)
                    .displayMode(.immediate)
                    .dimMode(.none)
                    .title("自定义通道 \(index)")
                    .message("该通道最多同时显示两个 Banner。")
                    .identifier("notice-\(index)")
                    .action("关闭")
                    .show()
            }
        }
    }

    private func showTextFieldAlert() {
        XAlert.alert(from: self)
            .title("输入框")
            .message("输入框由调用方在闭包中配置。")
            .textField { textField in
                textField.placeholder = "请输入名称"
                textField.borderStyle = .roundedRect
                textField.clearButtonMode = .whileEditing
            }
            .cancel("取消")
            .action("提交")
            .show()
    }

    private func showCustomViewAlert() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12

        let label = UILabel()
        label.text = "这是调用方传入的自定义视图"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .center

        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = 0.68

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(progressView)

        XAlert.alert(from: self)
            .title("自定义视图")
            .customView(stackView)
            .cancel("取消")
            .action("完成")
            .show()
    }

    private func showThemedAlert() {
        XAlert.alert(from: self)
            .title("主题与圆角")
            .message("主题可以独立调整标题、正文、按钮颜色，布局可以设置四角圆角。")
            .theme { theme in
                theme.alertBackgroundColor = UIColor.systemIndigo.withAlphaComponent(0.95)
                theme.titleColor = .white
                theme.messageColor = UIColor.white.withAlphaComponent(0.82)
                theme.normalActionTitleColor = .white
                theme.cancelActionTitleColor = UIColor.white.withAlphaComponent(0.88)
                theme.actionHighlightedBackgroundColor = UIColor.white.withAlphaComponent(0.16)
                theme.actionBorderColor = UIColor.white.withAlphaComponent(0.24)
            }
            .cornerRadii(XAlertLayoutConfiguration.CornerRadii(topLeft: 24, topRight: 8, bottomLeft: 8, bottomRight: 24))
            .cancel("取消")
            .action("确认")
            .show()
    }

    private func showLongContentAlert() {
        let message = Array(repeating: "XAlert 支持内容超高后滚动，并可配置操作按钮是否跟随滚动。", count: 10).joined(separator: "\n\n")

        XAlert.alert(from: self)
            .title("长内容滚动")
            .message(message)
            .maxHeight(560)
            .scrollEnabled(true)
            .showsScrollIndicator(true)
            .actionFollowScrollEnabled(false)
            .cancel("取消")
            .action("确认")
            .show()
    }

    private func showUniqueIdentifierAlert() {
        for index in 1...3 {
            XAlert.alert(from: self)
                .displayMode(.unique)
                .identifier("unique-demo")
                .title("去重弹窗")
                .message("第 \(index) 次触发。相同 identifier 已可见或排队时会忽略后续请求。")
                .action("知道了")
                .show()
        }
    }

    private func showCloseControls() {
        XAlert.make()
            .contentStyle(.banner)
            .presentationStyle(.top)
            .dimMode(.none)
            .identifier("close-banner")
            .title("可关闭横幅")
            .message("点击下面的 Alert 操作可以关闭顶部通道。")
            .action("关闭")
            .show()

        XAlert.alert(from: self)
            .title("关闭能力")
            .message("可以关闭最上层弹窗、关闭指定通道、清空队列或关闭全部。")
            .action("关闭顶部通道") {
                XAlert.closeAll(in: .top)
            }
            .destructive("关闭全部") {
                XAlert.closeAll()
            }
            .cancel("取消")
            .show()
    }
}

extension XAlertDemoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "XAlertDemoCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        let item = items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.detail
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        items[indexPath.row].action(self)
    }
}
