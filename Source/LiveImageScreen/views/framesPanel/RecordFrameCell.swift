//
//  RecordFrameCell.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 30.10.2024.
//

import UIKit

private enum Consts {
    static let backgroundImage = UIImage(named: "background_draw_area")
}

final class RecordFrameCell: UICollectionViewCell {
    static let identifier = "\(RecordFrameCell.self)"

    var dublicateHandler: (() -> Void)?
    var deleteHandler: (() -> Void)?

    var canDelete: Bool = true {
        didSet {
            deleteButton.isEnabled = canDelete
        }
    }

    private let backgroundImageView = UIImageView(image: Consts.backgroundImage)
    private let imageView = UIImageView(image: nil)

    private let dublicateButton = UIButton(type: .custom)
    private let deleteButton = UIButton(type: .custom)

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
        imageView.image = nil
        setIsCurrent(false)
    }

    func setImage(_ image: UIImage) {
        imageView.image = image
    }

    func setIsCurrent(_ isCurrent: Bool) {
        if isCurrent {
            imageView.layer.borderColor = Colors.selectColor.cgColor
        } else {
            imageView.layer.borderColor = Colors.unaccentColor.cgColor
        }
    }

    private func commonInit() {
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.layer.cornerCurve = .continuous
        backgroundImageView.layer.cornerRadius = 8.0
        backgroundImageView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerCurve = .continuous
        imageView.layer.cornerRadius = 8.0
        imageView.clipsToBounds = true
        imageView.layer.borderColor = Colors.unaccentColor.cgColor
        imageView.layer.borderWidth = 1.5

        dublicateButton.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        dublicateButton.addAction(UIAction(handler: { [weak self] _ in
            self?.dublicateHandler?()
        }), for: .touchUpInside)
        dublicateButton.tintColor = Colors.textColor
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.addAction(UIAction(handler: { [weak self] _ in
            self?.deleteHandler?()
        }), for: .touchUpInside)
        deleteButton.tintColor = Colors.errorColor

        contentView.addCSubview(backgroundImageView)
        contentView.addCSubview(imageView)

        contentView.addCSubview(dublicateButton)
        contentView.addCSubview(deleteButton)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: FramesConsts.itemSpacing),
            backgroundImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -FramesConsts.itemSpacing),
            backgroundImageView.heightAnchor.constraint(equalToConstant: FramesConsts.imageHeight),

            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: FramesConsts.itemSpacing),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -FramesConsts.itemSpacing),
            imageView.heightAnchor.constraint(equalToConstant: FramesConsts.imageHeight),

            dublicateButton.leftAnchor.constraint(equalTo: leftAnchor, constant: FramesConsts.itemSpacing + 6.0),
            dublicateButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            dublicateButton.widthAnchor.constraint(equalToConstant: 24.0),
            dublicateButton.heightAnchor.constraint(equalToConstant: 24.0),

            deleteButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 24.0),
            deleteButton.heightAnchor.constraint(equalToConstant: 24.0),
            deleteButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -FramesConsts.itemSpacing - 6.0),
        ])
    }
}
