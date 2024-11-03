//
//  SliderLineWidthView.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 03.11.2024.
//

import UIKit

private enum Consts {
    static let circleSize = 20.0
    static let length = 192.0

    static let minWidth: CGFloat = 1.0
    static let maxWidth: CGFloat = 20.0
}

final class SliderLineWidthView: UIView {
    var widthChanged: LiveImageLineWidthChangedHandler?

    var selectedWidth: CGFloat = Consts.minWidth {
        didSet {
            let procent = (selectedWidth - Consts.minWidth) / (Consts.maxWidth - Consts.minWidth)
            let position = procent * (Consts.length - Consts.circleSize)

            circlePositionConstraint?.constant = position
            circleView.setNeedsUpdateConstraints()
        }
    }

    private let sliderView = UIView(frame: .zero)
    private let backgroundLineLayer = CAGradientLayer()
    private let maskLayer = CAShapeLayer()
    private let circleView = UIView(frame: .zero)

    private var circlePositionConstraint: NSLayoutConstraint?

    init() {
        super.init(frame: .zero)

        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setEnable(_ enable: Bool) {
        isUserInteractionEnabled = enable
        isHidden = !enable
    }

    private func commonInit() {
        addCSubview(sliderView)
        sliderView.addCSubview(circleView)

        circleView.backgroundColor = Colors.textColor
        circleView.layer.cornerRadius = Consts.circleSize * 0.5
        circleView.layer.shadowColor = Colors.backgroundColor.cgColor
        circleView.layer.shadowOffset = CGSize(width: 1, height: 2)
        circleView.layer.shadowRadius = 5.0

        sliderView.layer.insertSublayer(backgroundLineLayer, at: 0)

        fillBackgroundLineLayer()

        makeConstraints()

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureChanged))
        addGestureRecognizer(panGesture)
    }

    private func makeConstraints() {
        let circlePosition = circleView.topAnchor.constraint(equalTo: sliderView.topAnchor, constant: 0.0)
        circlePositionConstraint = circlePosition
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 32.0),
            heightAnchor.constraint(equalToConstant: Consts.length),

            sliderView.widthAnchor.constraint(equalToConstant: Consts.circleSize),
            sliderView.heightAnchor.constraint(equalToConstant: Consts.length),
            sliderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            sliderView.centerXAnchor.constraint(equalTo: centerXAnchor),

            circleView.widthAnchor.constraint(equalToConstant: Consts.circleSize),
            circleView.heightAnchor.constraint(equalToConstant: Consts.circleSize),
            circlePosition,
            circleView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func fillBackgroundLineLayer() {
        let path = UIBezierPath()
        let offset = Consts.circleSize * 0.5
        let length = Consts.length

        let centerTop = CGPoint(x: Consts.circleSize * 0.5, y: Consts.circleSize * 0.1 + offset)
        let centerBottom = CGPoint(x: Consts.circleSize * 0.5, y: length - Consts.circleSize * 0.3 - offset)
        path.move(to: CGPoint(x: centerTop.x - Consts.circleSize * 0.1, y: centerTop.y))
        path.addArc(withCenter: centerTop,
                    radius: Consts.circleSize * 0.1,
                    startAngle: -.pi, endAngle: 0,
                    clockwise: true)
        path.addLine(to: CGPoint(x: centerBottom.x + Consts.circleSize * 0.3, y: centerBottom.y))
        path.addArc(withCenter: centerBottom,
                    radius: Consts.circleSize * 0.3,
                    startAngle: 0, endAngle: .pi,
                    clockwise: true)
        path.close()

        maskLayer.path = path.cgPath
        maskLayer.frame = CGRect(x: 0, y: 0, width: Consts.circleSize, height: Consts.length)

        backgroundLineLayer.colors = [Colors.gradientStart.cgColor, Colors.gradientEnd.cgColor]
        backgroundLineLayer.frame = CGRect(x: 0, y: 0, width: Consts.circleSize, height: Consts.length)

        backgroundLineLayer.mask = maskLayer
    }

    @objc
    private func panGestureChanged(_ panGesture: UIPanGestureRecognizer) {
        let location = panGesture.location(in: sliderView)
        let position = max(0, min(location.y, Consts.length - Consts.circleSize))
        let procent = position / (Consts.length - Consts.circleSize)
        let width = Consts.minWidth + (Consts.maxWidth - Consts.minWidth) * procent
        selectedWidth = width
        widthChanged?(width)
    }
}
