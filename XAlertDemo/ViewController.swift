//
//  ViewController.swift
//  XAlertDemo
//
//  Created by lazyloading on 2026/6/3.
//

import UIKit
import LEEAlert

final class ViewController: UIViewController {

    private enum DemoKind: Int, CaseIterable {
        case leeAlert
        case xAlert

        var title: String {
            switch self {
            case .leeAlert:
                return "LEEAlert 原组件示例"
            case .xAlert:
                return "XAlert Swift 新组件示例"
            }
        }

        var detail: String {
            switch self {
            case .leeAlert:
                return "保留原 Objective-C 组件入口"
            case .xAlert:
                return "覆盖 Alert、Sheet、Banner、队列和多弹窗"
            }
        }
    }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "弹窗组件 Demo"
        view.backgroundColor = .systemBackground
        configureTableView()
    }

    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DemoCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func showLEEAlertDemo() {
        _ = LEEAlert.alert().config
            .leeTitle("标题")
            .leeContent("内容")
            .leeAction("确认", {
                print("点击确认")
            })
            .leeShow()
    }

    private func showXAlertDemo() {
        let demoViewController = XAlertDemoViewController()
        let navigationController = UINavigationController(rootViewController: demoViewController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DemoKind.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DemoCell", for: indexPath)
        guard let demo = DemoKind(rawValue: indexPath.row) else { return cell }
        cell.textLabel?.text = demo.title
//        var content = cell.defaultContentConfiguration()
//        content.text = demo.title
//        content.secondaryText = demo.detail
//        content.secondaryTextProperties.color = .secondaryLabel
//        cell.contentConfiguration = content
//        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let demo = DemoKind(rawValue: indexPath.row) else { return }

        switch demo {
        case .leeAlert:
            showLEEAlertDemo()
        case .xAlert:
            showXAlertDemo()
        }
    }
}
