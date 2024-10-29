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

    init() {
        super.init(frame: .zero)

        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setParentView(_ view: UIView, superView: UIView) {
    }

    private func commonInit() {
        addCSubview(pencilButton)
        addCSubview(brushButton)
        addCSubview(eraseButton)
        addCSubview(moreButton)

        for button in instrumentsButton {
            button.addAction(UIAction { [weak self, instrument = button.instrument] _ in
                self?.selectInstrumentHandler?(instrument)
            }, for: .touchUpInside)
        }

        // TODO: потом
        //        moreButton.addAction(UIAction { [weak self] _ in
        //            self?.showMoreInstruments()
        //        }, for: .touchUpInside)

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

    fileprivate var instrumentsButton: [InstrumentButton] { [] }

    init() {
        super.init(frame: .zero)

        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
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
        }
    }
}

private final class MoreInstrumentsButton: DefaultImageButton {
    init() {
        super.init(image: UIImage(named: "instruments"))
    }
}
