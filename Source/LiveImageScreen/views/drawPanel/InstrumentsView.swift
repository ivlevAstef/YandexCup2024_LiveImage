//
//  InstrumentsView.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 29.10.2024.
//

import UIKit

final class InstrumentsView: UIView {
    var selectInstrumentHandler: LiveImageInstrumentSelectHandler? {
        didSet {
            moreInstrumentsView.selectInstrumentHandler = selectInstrumentHandler
        }
    }
    var selectedInstrument: DrawInstrument = .pencil {
        didSet {
            moreInstrumentsView.selectedInstrument = selectedInstrument

            for button in instrumentsButton {
                button.isSelected = button.instrument == selectedInstrument
            }
            moreButton.isSelected = moreInstrumentsView.instrumentsButton.contains(where: { $0.instrument == selectedInstrument })
        }
    }

    private let pencilButton = InstrumentButton(instrument: .pencil)
    private let brushButton = InstrumentButton(instrument: .brush)
    private let eraseButton = InstrumentButton(instrument: .erase)
    private let moreButton = MoreInstrumentsButton()

    private let moreInstrumentsView = MoreInstrumentsView()

    private var instrumentsButton: [InstrumentButton] {
        return [pencilButton, brushButton, eraseButton]
    }

    private var moreInstrumentsIsShown: Bool = false

    init() {
        super.init(frame: .zero)

        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setEnable(_ enabled: Bool) {
        pencilButton.isEnabled = enabled
        brushButton.isEnabled = enabled
        eraseButton.isEnabled = enabled
        moreButton.isEnabled = enabled
    }

    func hidePopup() {
        if moreInstrumentsIsShown {
            hideMoreInstruments()
        }
    }

    func setParentView(_ view: UIView, superView: UIView) {
        superView.addCSubview(moreInstrumentsView)

        NSLayoutConstraint.activate([
            moreInstrumentsView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -16.0),
            moreInstrumentsView.centerXAnchor.constraint(equalTo: superView.centerXAnchor),
            moreInstrumentsView.heightAnchor.constraint(equalToConstant: 64.0)
        ])
    }

    private func commonInit() {
        moreInstrumentsIsShown = false
        moreInstrumentsView.isHidden = true

        addCSubview(pencilButton)
        addCSubview(brushButton)
        addCSubview(eraseButton)
        addCSubview(moreButton)

        for button in instrumentsButton {
            button.addAction(UIAction { [weak self, instrument = button.instrument] _ in
                self?.selectInstrumentHandler?(instrument)
            }, for: .touchUpInside)
        }

        moreButton.addAction(UIAction { [weak self] _ in
            self?.toggleMoreInstruments()
        }, for: .touchUpInside)

        makeConstraints()
    }

    private func makeConstraints() {
        // Можно конечно было и на stackView, ну да ладно - мы же тут не за переиспользование, в самом деле :D
        let space = 16.0
        NSLayoutConstraint.activate([
            pencilButton.leftAnchor.constraint(equalTo: leftAnchor),
            pencilButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            brushButton.leftAnchor.constraint(equalTo: pencilButton.rightAnchor, constant: space),
            brushButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            eraseButton.leftAnchor.constraint(equalTo: brushButton.rightAnchor, constant: space),
            eraseButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            moreButton.leftAnchor.constraint(equalTo: eraseButton.rightAnchor, constant: space),
            moreButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            moreButton.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }

    private func showMoreInstruments() {
        moreInstrumentsIsShown = true
        moreButton.isSelected = true
        moreInstrumentsView.isHidden = false
        moreInstrumentsView.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.moreInstrumentsView.alpha = 1.0
        })
    }

    private func hideMoreInstruments() {
        moreInstrumentsIsShown = false
        moreButton.isSelected = false
        UIView.animate(withDuration: 0.25, animations: {
            self.moreInstrumentsView.alpha = 0.0
        }, completion: { [weak self] _ in
            self?.moreInstrumentsView.isHidden = true
        })
    }

    private func toggleMoreInstruments() {
        if moreInstrumentsIsShown {
            hideMoreInstruments()
        } else {
            showMoreInstruments()
        }
    }
}

// TODO: пока не актуально, потом реализовать по возможности.
private final class MoreInstrumentsView: UIView {
    var selectInstrumentHandler: LiveImageInstrumentSelectHandler?
    var selectedInstrument: DrawInstrument = .pencil {
        didSet {
            for button in instrumentsButton {
                button.isSelected = button.instrument == selectedInstrument
            }
        }
    }

    private let blurEffectView = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial), intensity: 0.3)

    private let rectangleButton = InstrumentButton(instrument: .rectangle)
    private let circleButton = InstrumentButton(instrument: .circle)
    private let trianleButton = InstrumentButton(instrument: .triangle)
    private let arrowButton = InstrumentButton(instrument: .arrow)
    private let buttonsStackView = UIStackView(frame: .zero)
    fileprivate var instrumentsButton: [InstrumentButton] { [rectangleButton, circleButton, trianleButton, arrowButton] }

    init() {
        super.init(frame: .zero)

        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        layer.cornerCurve = .continuous
        layer.cornerRadius = 16.0
        layer.masksToBounds = true

        addCSubview(blurEffectView)
        addCSubview(buttonsStackView)

        for button in instrumentsButton {
            buttonsStackView.addArrangedSubview(button)
            button.addAction(UIAction { [weak self, instrument = button.instrument] _ in
                self?.selectInstrumentHandler?(instrument)
            }, for: .touchUpInside)
        }

        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 16.0
        buttonsStackView.distribution = .equalSpacing

        makeConstraints()
    }

    private func makeConstraints() {
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            buttonsStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16.0),
            buttonsStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16.0),
            buttonsStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: - Buttons

private final class InstrumentButton: DefaultImageButton {
    let instrument: DrawInstrument

    init(instrument: DrawInstrument) {
        self.instrument = instrument
        super.init(image: instrument.image)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DrawInstrument {
    fileprivate var image: UIImage? {
        switch self {
        case .pencil: return UIImage(named: "pencil")
        case .brush: return UIImage(named: "brush")
        case .erase: return UIImage(named: "erase")
        case .rectangle: return UIImage(named: "rectangle")
        case .circle: return UIImage(named: "circle")
        case .triangle: return UIImage(named: "triangle")
        case .arrow: return UIImage(named: "arrow")
        }
    }
}

private final class MoreInstrumentsButton: DefaultImageButton {
    init() {
        super.init(image: UIImage(named: "instruments"))
    }
}
