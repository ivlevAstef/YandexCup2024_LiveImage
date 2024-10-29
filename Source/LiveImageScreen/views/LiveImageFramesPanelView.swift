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
    static let itemHeight: CGFloat = 150.0
    static let imageHeight: CGFloat = 120.0
    static let itemSpacing: CGFloat = 8.0
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

    var recordOfFrames: [Canvas.Record] {
        get { framesView.recordOfFrames }
        set { framesView.recordOfFrames = newValue }
    }
    var selectedFrameIndex: Int {
        get { framesView.selectedFrameIndex }
        set { framesView.selectedFrameIndex = newValue }
    }

    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let contentView = UIView(frame: .zero)
    private let framesView = FramesView()
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
            framesView.heightAnchor.constraint(equalToConstant: Consts.itemHeight)
        ])
    }
}

private final class FramesView: UICollectionView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var selectedFrameChangedHandler: LiveImageSelectedFrameChangedHandler?
    var deleteFrameHandler: LiveImageDeleteFrameHandler?
    var dublicateFrameHandler: LiveImageDublicateFrameHandler?

    var recordOfFrames: [Canvas.Record] = [] {
        didSet { reloadData() }
    }

    var selectedFrameIndex: Int = 0 {
        didSet {
            if selectedFrameIndex == oldValue {
                return
            }

            let newIndexPath = IndexPath(row: selectedFrameIndex, section: 0)
            let indexPaths: [IndexPath] = [
                IndexPath(row: oldValue, section: 0),
                newIndexPath
            ].filter { recordOfFrames.indices.contains($0.row) }
            if indexPaths.count > 0 {
                reloadItems(at: indexPaths)
                scrollToItem(at: newIndexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }

    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: layout)

        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12.0

        register(FrameCell.self, forCellWithReuseIdentifier: FrameCell.identifier)

        showsHorizontalScrollIndicator = false
        delegate = self
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recordOfFrames.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let imageSize = recordOfFrames[indexPath.row].size
        let width = Consts.imageHeight * imageSize.width / imageSize.height

        return CGSize(width: width + 2 * Consts.itemSpacing, height: Consts.itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dequeueReusableCell(withReuseIdentifier: FrameCell.identifier, for: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let frameCell = cell as? FrameCell {
            let record = recordOfFrames[indexPath.row]
            frameCell.setImage(record)
            frameCell.setIsCurrent(selectedFrameIndex == indexPath.row)

            frameCell.dublicateHandler = { [weak self] in
                self?.dublicateFrameHandler?(indexPath.row)
            }
            frameCell.deleteHandler = { [weak self] in
                self?.deleteFrameHandler?(indexPath.row)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedFrameChangedHandler?(indexPath.row)
    }
}

private final class FrameCell: UICollectionViewCell {
    static let identifier = "\(FrameCell.self)"

    var dublicateHandler: (() -> Void)?
    var deleteHandler: (() -> Void)?

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
            backgroundImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Consts.itemSpacing),
            backgroundImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Consts.itemSpacing),
            backgroundImageView.heightAnchor.constraint(equalToConstant: Consts.imageHeight),

            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Consts.itemSpacing),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Consts.itemSpacing),
            imageView.heightAnchor.constraint(equalToConstant: Consts.imageHeight),

            dublicateButton.leftAnchor.constraint(equalTo: leftAnchor, constant: Consts.itemSpacing + 6.0),
            dublicateButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            dublicateButton.widthAnchor.constraint(equalToConstant: 24.0),
            dublicateButton.heightAnchor.constraint(equalToConstant: 24.0),

            deleteButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 24.0),
            deleteButton.heightAnchor.constraint(equalToConstant: 24.0),
            deleteButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -Consts.itemSpacing - 6.0),
        ])
    }
}
