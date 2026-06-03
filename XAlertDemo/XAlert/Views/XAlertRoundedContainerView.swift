import UIKit

/// 内建弹窗视图使用的圆角容器。
class XAlertRoundedContainerView: UIView {
    /// 更新四角圆角。
    var cornerRadii: XAlertLayoutConfiguration.CornerRadii = .all(13) {
        didSet {
            updateMask()
        }
    }

    /// 统一圆角半径的兼容属性。
    var cornerRadius: CGFloat {
        get { cornerRadii.topLeft }
        set { cornerRadii = .all(newValue) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .tertiarySystemBackground
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateMask()
    }

    private func updateMask() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        let path = UIBezierPath()

        let minX = bounds.minX
        let minY = bounds.minY
        let maxX = bounds.maxX
        let maxY = bounds.maxY

        let topLeft = min(cornerRadii.topLeft, min(bounds.width, bounds.height) / 2)
        let topRight = min(cornerRadii.topRight, min(bounds.width, bounds.height) / 2)
        let bottomLeft = min(cornerRadii.bottomLeft, min(bounds.width, bounds.height) / 2)
        let bottomRight = min(cornerRadii.bottomRight, min(bounds.width, bounds.height) / 2)

        path.move(to: CGPoint(x: minX + topLeft, y: minY))
        path.addLine(to: CGPoint(x: maxX - topRight, y: minY))
        path.addArc(
            withCenter: CGPoint(x: maxX - topRight, y: minY + topRight),
            radius: topRight,
            startAngle: -.pi / 2,
            endAngle: 0,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: maxX, y: maxY - bottomRight))
        path.addArc(
            withCenter: CGPoint(x: maxX - bottomRight, y: maxY - bottomRight),
            radius: bottomRight,
            startAngle: 0,
            endAngle: .pi / 2,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: minX + bottomLeft, y: maxY))
        path.addArc(
            withCenter: CGPoint(x: minX + bottomLeft, y: maxY - bottomLeft),
            radius: bottomLeft,
            startAngle: .pi / 2,
            endAngle: .pi,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: minX, y: minY + topLeft))
        path.addArc(
            withCenter: CGPoint(x: minX + topLeft, y: minY + topLeft),
            radius: topLeft,
            startAngle: .pi,
            endAngle: .pi * 1.5,
            clockwise: true
        )
        path.close()

        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}
