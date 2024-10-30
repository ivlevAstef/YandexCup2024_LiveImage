//
//  GenerateFrameCell.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 30.10.2024.
//

import UIKit

private enum Consts {
    static let backgroundImage = UIImage(named: "background_draw_area")
}

final class GenerateFrameCell: UICollectionViewCell {
    static let identifier = "\(GenerateFrameCell.self)"

    private let backgroundImageView = UIImageView(image: Consts.backgroundImage)
    private let iconLabel = UILabel()

    private let generateLabel = UILabel()

    private var generatedIconIndex = 0
    private var generateIconTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    deinit {
        generateIconTimer?.invalidate()
    }

    private func commonInit() {
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.layer.cornerCurve = .continuous
        backgroundImageView.layer.cornerRadius = 8.0
        backgroundImageView.clipsToBounds = true
        backgroundImageView.layer.borderColor = Colors.textColor.cgColor
        backgroundImageView.layer.borderWidth = 1.5

        iconLabel.font = UIFont.systemFont(ofSize: 40.0)
        iconLabel.textColor = Colors.textColor

        generateLabel.font = UIFont.systemFont(ofSize: 12.0)
        generateLabel.textColor = Colors.textColor
        generateLabel.textAlignment = .center
        generateLabel.text = "GENERATE"

        contentView.addCSubview(backgroundImageView)
        contentView.addCSubview(iconLabel)
        contentView.addCSubview(generateLabel)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: FramesConsts.itemSpacing),
            backgroundImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -FramesConsts.itemSpacing),
            backgroundImageView.heightAnchor.constraint(equalToConstant: FramesConsts.imageHeight),

            iconLabel.centerXAnchor.constraint(equalTo: backgroundImageView.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: backgroundImageView.centerYAnchor),

            generateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: FramesConsts.itemSpacing),
            generateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.0),
            generateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -FramesConsts.itemSpacing)
        ])

        runGenerateIconUpdate()
    }

    private func runGenerateIconUpdate() {
        generateIconTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            self?.generateIconUpdate()
        })
        generateIconUpdate()
    }

    private func generateIconUpdate() {
        switch generatedIconIndex {
        case 0: iconLabel.text = "⚀"
        case 1: iconLabel.text = "⚁"
        case 2: iconLabel.text = "⚂"
        case 3: iconLabel.text = "⚃"
        case 4: iconLabel.text = "⚄"
        case 5: iconLabel.text = "⚅"
        default: iconLabel.text = "⚀"
        }
        // Не я понимаю, что это можно уйти в бесконечный цикл, но делать защиту, не вижу смысла - вероятность минимальная.
        let currentIndex = generatedIconIndex
        while generatedIconIndex == currentIndex {
            generatedIconIndex = Int.random(in: 0..<6)
        }
    }
}

