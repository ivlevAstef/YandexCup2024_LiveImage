//
//  LiveImageFramesPanelView.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 29.10.2024.
//

import UIKit

private enum Consts {
    static let backgroundImage = UIImage(named: "background_draw_area")

    static let panelHeight: CGFloat = 192.0
}

final class LiveImageFramesPanelView: UIView, LiveImageFramesViewProtocol {
    var selectedFrameChangedHandler: LiveImageSelectedFrameChangedHandler? {
        get { framesView.selectedFrameChangedHandler }
        set { framesView.selectedFrameChangedHandler = newValue }
    }

    var deleteFrameHandler: LiveImageDeleteFrameHandler? {
        get { framesView.deleteFrameHandler }
        set { framesView.deleteFrameHandler = newValue }
    }
    var dublicateFrameHandler: LiveImageDublicateFrameHandler? {
        get { framesView.dublicateFrameHandler }
        set { framesView.dublicateFrameHandler = newValue }
    }
    var addFrameHandler: LiveImageAddFrameHandler? {
        get { framesView.addFrameHandler }
        set { framesView.addFrameHandler = newValue }
    }
    var generateFramesHandler: LiveImageGenerateFramesHandler? {
        get { framesView.generateFramesHandler }
        set { framesView.generateFramesHandler = newValue }
    }

    var recordOfFrames: [Canvas.Record] {
        get { framesView.recordOfFrames }
        set { framesView.recordOfFrames = newValue }
    }
    var selectedFrameIndex: Int {
        get { framesView.selectedFrameIndex }
        set { framesView.selectedFrameIndex = newValue }
    }

    private let blurEffectView = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial), intensity: 0.5)
    private let contentView = UIView(frame: .zero)
    private let framesView = FramesCollectionView()
    private var hidePositionConstraint: NSLayoutConstraint?
    private var showPositionConstraint: NSLayoutConstraint?

    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        hidePositionConstraint?.isActive = false
        showPositionConstraint?.isActive = true

        UIView.animate(withDuration: 0.25, animations: {
            self.setNeedsUpdateConstraints()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        })
    }

    func hide() {
        showPositionConstraint?.isActive = false
        hidePositionConstraint?.isActive = true

        UIView.animate(withDuration: 0.25, animations: {
            self.setNeedsUpdateConstraints()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        })
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let resultView = super.hitTest(point, with: event), resultView !== self {
            return resultView
        }
        return nil
    }

    private func commonInit() {
        addCSubview(contentView)
        addCSubview(blurEffectView)
        addCSubview(framesView)

        blurEffectView.layer.cornerRadius = 20.0
        blurEffectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        blurEffectView.layer.cornerCurve = .continuous
        blurEffectView.clipsToBounds = true

        framesView.backgroundColor = .clear

        makeConstraints()
    }

    private func makeConstraints() {
        self.showPositionConstraint = contentView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        let hidePositionConstraint = contentView.topAnchor.constraint(equalTo: bottomAnchor)
        self.hidePositionConstraint = hidePositionConstraint
        NSLayoutConstraint.activate([
            hidePositionConstraint,
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.heightAnchor.constraint(equalToConstant: Consts.panelHeight)
        ])

        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: contentView.topAnchor),
            blurEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])


        NSLayoutConstraint.activate([
            framesView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.0),
            framesView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 16.0),
            framesView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -16.0),
            framesView.heightAnchor.constraint(equalToConstant: FramesConsts.itemHeight)
        ])
    }
}
