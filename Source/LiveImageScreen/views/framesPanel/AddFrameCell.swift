//
//  AddFrameCell.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 30.10.2024.
//


import UIKit

private enum Consts {
    static let backgroundImage = UIImage(named: "background_draw_area")
}

final class AddFrameCell: UICollectionViewCell {
    static let identifier = "\(AddFrameCell.self)"

    private let backgroundImageView = UIImageView(image: Consts.backgroundImage)
    private let plusLabel = UILabel()

    private let addLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

    }

    private func commonInit() {
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.layer.cornerCurve = .continuous
        backgroundImageView.layer.cornerRadius = 8.0
        backgroundImageView.clipsToBounds = true
        backgroundImageView.layer.borderColor = Colors.textColor.cgColor
        backgroundImageView.layer.borderWidth = 1.5

        plusLabel.font = UIFont.systemFont(ofSize: 40.0)
        plusLabel.textColor = Colors.textColor
        plusLabel.text = "+"

        addLabel.font = UIFont.systemFont(ofSize: 12.0)
        addLabel.textColor = Colors.textColor
        addLabel.text = "ADD"
        addLabel.textAlignment = .center

        contentView.addCSubview(backgroundImageView)
        contentView.addCSubview(plusLabel)
        contentView.addCSubview(addLabel)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: FramesConsts.itemSpacing),
            backgroundImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -FramesConsts.itemSpacing),
            backgroundImageView.heightAnchor.constraint(equalToConstant: FramesConsts.imageHeight),

            plusLabel.centerXAnchor.constraint(equalTo: backgroundImageView.centerXAnchor),
            plusLabel.centerYAnchor.constraint(equalTo: backgroundImageView.centerYAnchor),

            addLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: FramesConsts.itemSpacing),
            addLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            addLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -FramesConsts.itemSpacing)
        ])
    }
}

