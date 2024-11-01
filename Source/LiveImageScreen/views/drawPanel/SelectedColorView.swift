//
//  SelectedColorView.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 29.10.2024.
//

import UIKit

private enum Consts {
    static let size: CGFloat = 32.0
    static let space: CGFloat = 16.0
    static let maxShownColors: Int = 5
}

final class SelectedColorView: UIView {
    var showMoreColorsHandler: LiveImageShowMoreColorHandler? {
        get { colorPaletteView.showMoreColorsHandler }
        set {
            colorPaletteView.showMoreColorsHandler = { [weak self] in
                self?.hidePalette()
                newValue?()
            }
        }
    }

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
    var shownColors: [DrawColor] {
        get { colorPaletteView.shownColors }
        set { colorPaletteView.shownColors = newValue }
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
    var showMoreColorsHandler: LiveImageShowMoreColorHandler?

    var shownColors: [DrawColor] = [] {
        didSet {
            updateColorButtons()
        }
    }

    private let blurEffectView = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial), intensity: 0.3)

    private let moreColorsButton = MoreColorsButton()
    private let colorButtonsStack = UIStackView(frame: .zero)


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
        addCSubview(colorButtonsStack)

        moreColorsButton.addAction(UIAction { [weak self] _ in
            self?.showMoreColorsHandler?()
        }, for: .touchUpInside)

        colorButtonsStack.axis = .horizontal
        colorButtonsStack.spacing = Consts.space
        colorButtonsStack.distribution = .equalSpacing

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
            moreColorsButton.leftAnchor.constraint(equalTo: leftAnchor, constant: Consts.space),
            moreColorsButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            colorButtonsStack.leftAnchor.constraint(equalTo: moreColorsButton.rightAnchor, constant: Consts.space),
            colorButtonsStack.rightAnchor.constraint(equalTo: rightAnchor, constant: -Consts.space),
            colorButtonsStack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func updateColorButtons() {
        colorButtonsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for color in shownColors.prefix(Consts.maxShownColors) {
            let button = ColoredButton(color: color)
            button.tapOnColorButton = { [weak self, color = button.color] in
                self?.selectColorHandler?(color)
            }

            colorButtonsStack.addArrangedSubview(button)
        }
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
