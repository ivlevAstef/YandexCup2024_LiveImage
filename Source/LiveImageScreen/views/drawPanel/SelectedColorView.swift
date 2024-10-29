//
//  SelectedColorView.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 29.10.2024.
//

import UIKit

private enum Consts {
    static let size: CGFloat = 32.0
}

final class SelectedColorView: UIView {
    var selectColorHandler: LiveImageColorSelectHandler? {
        get { colorPaletteView.selectColorHandler }
        set { colorPaletteView.selectColorHandler = newValue }
    }
    var selectedColor: DrawColor = .black {
        didSet {
            backgroundColor = selectedColor
            if paletteIsShown {
                hidePalette()
            }
            updateBorderState()
        }
    }

    private let colorPaletteView = ColorPaletteView()
    private var paletteIsShown: Bool = false

    init() {
        super.init(frame: .zero)

        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setParentView(_ view: UIView, superView: UIView) {
        superView.addCSubview(colorPaletteView)

        NSLayoutConstraint.activate([
            colorPaletteView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: -16.0),
            colorPaletteView.centerXAnchor.constraint(equalTo: superView.centerXAnchor),
            colorPaletteView.heightAnchor.constraint(equalToConstant: 64.0)
        ])
    }

    func hidePopup() {
        if paletteIsShown {
            hidePalette()
        }
    }

    private func commonInit() {
        paletteIsShown = false
        colorPaletteView.isHidden = true

        layer.cornerRadius = Consts.size * 0.5
        layer.masksToBounds = true
        layer.borderWidth = 1.5

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnSelf)))

        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: Consts.size),
            heightAnchor.constraint(equalToConstant: Consts.size)
        ])
    }

    private func updateBorderState() {
        if paletteIsShown {
            layer.borderColor = Colors.selectColor.cgColor
        } else {
            // Если цвет по яркости, близок к цвету фона, то добавляем рамку, чтобы его было лучше видно.
            if abs(selectedColor.brightness - Colors.backgroundColor.brightness) < 0.1 {
                layer.borderColor = Colors.textColor.cgColor
            } else {
                layer.borderColor = selectedColor.cgColor
            }
        }
    }

    private func showPalette() {
        paletteIsShown = true
        colorPaletteView.isHidden = false
        colorPaletteView.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.colorPaletteView.alpha = 1.0
            self.updateBorderState()
        })
    }

    private func hidePalette() {
        paletteIsShown = false
        UIView.animate(withDuration: 0.25, animations: {
            self.colorPaletteView.alpha = 0.0
            self.updateBorderState()
        }, completion: { [weak self] _ in
            self?.colorPaletteView.isHidden = true
        })
    }

    @objc
    private func tapOnSelf() {
        if paletteIsShown {
            hidePalette()
        } else {
            showPalette()
        }
    }
}

private final class ColorPaletteView: UIView {
    var selectColorHandler: LiveImageColorSelectHandler?

    private let blurEffectView = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial), intensity: 0.3)

    private let moreColorsButton = MoreColorsButton()
    private let blackColorButton = ColoredButton(color: .black)
    private let redColorButton = ColoredButton(color: .red)
    private let blueColorButton = ColoredButton(color: .blue)
    private let greenColorButton = ColoredButton(color: .green)

    private var colorButtons: [ColoredButton] {
        return [blackColorButton, redColorButton, blueColorButton, greenColorButton]
    }


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

        addCSubview(moreColorsButton)
        addCSubview(blackColorButton)
        addCSubview(redColorButton)
        addCSubview(blueColorButton)
        addCSubview(greenColorButton)

        for button in colorButtons {
            button.tapOnColorButton = { [weak self, color = button.color] in
                self?.selectColorHandler?(color)
            }
        }

//        moreColorsButton.addAction(UIAction { [weak self] _ in
//            self?.showMoreColors()
//        }, for: .touchUpInside)

        makeConstraints()
    }

    private func makeConstraints() {
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            blurEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Можно конечно было и на stackView, ну да ладно - мы же тут не за переиспользование, в самом деле :D
        let space = 16.0
        NSLayoutConstraint.activate([
            moreColorsButton.leftAnchor.constraint(equalTo: leftAnchor, constant: space),
            moreColorsButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            blackColorButton.leftAnchor.constraint(equalTo: moreColorsButton.rightAnchor, constant: space),
            blackColorButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            redColorButton.leftAnchor.constraint(equalTo: blackColorButton.rightAnchor, constant: space),
            redColorButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            blueColorButton.leftAnchor.constraint(equalTo: redColorButton.rightAnchor, constant: space),
            blueColorButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            greenColorButton.leftAnchor.constraint(equalTo: blueColorButton.rightAnchor, constant: space),
            greenColorButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            greenColorButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -space)
        ])
    }
}

// MARK: - Buttons

private final class ColoredButton: UIView {
    var tapOnColorButton: (() -> Void)?

    let color: DrawColor

    init(color: DrawColor) {
        self.color = color
        super.init(frame: .zero)

        backgroundColor = color

        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        layer.cornerRadius = Consts.size * 0.5
        layer.masksToBounds = true

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnSelf)))

        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: Consts.size),
            heightAnchor.constraint(equalToConstant: Consts.size)
        ])
    }

    @objc
    private func tapOnSelf() {
        tapOnColorButton?()
    }
}

private final class MoreColorsButton: DefaultImageButton {
    init() {
        super.init(image: UIImage(named: "palette"))
    }
}
