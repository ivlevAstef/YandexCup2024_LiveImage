//
//  FramesCollectionView.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 30.10.2024.
//

import UIKit

enum FramesConsts {
    static let itemHeight: CGFloat = 150.0
    static let imageHeight: CGFloat = 120.0
    static let itemSpacing: CGFloat = 8.0
}

final class FramesCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    var selectedFrameChangedHandler: LiveImageSelectedFrameChangedHandler?
    var deleteFrameHandler: LiveImageDeleteFrameHandler?
    var dublicateFrameHandler: LiveImageDublicateFrameHandler?
    var addFrameHandler: LiveImageAddFrameHandler?
    var generateFramesHandler: LiveImageGenerateFramesHandler?

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

    private var canvasSize: CanvasSize?
    private var recordOfFrames: [Canvas.Record] = []

    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: layout)

        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12.0

        register(RecordFrameCell.self, forCellWithReuseIdentifier: RecordFrameCell.identifier)
        register(AddFrameCell.self, forCellWithReuseIdentifier: AddFrameCell.identifier)
        register(GenerateFrameCell.self, forCellWithReuseIdentifier: GenerateFrameCell.identifier)

        showsHorizontalScrollIndicator = false
        delegate = self
        dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(recordOfFrames: [Canvas.Record], canvasSize: CanvasSize) {
        self.canvasSize = canvasSize
        self.recordOfFrames = recordOfFrames
        reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if canvasSize == nil {
            return 0
        }
        // Две ячейки после фреймов - одна добавить, другая сгенерировать.
        return recordOfFrames.count + 2
    }

    func collectionView(_ collectionView: UICollectionView, 
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let canvasSize else {
            return .zero
        }

        let width = FramesConsts.imageHeight * canvasSize.width / canvasSize.height

        return CGSize(width: width + 2 * FramesConsts.itemSpacing, height: FramesConsts.itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < recordOfFrames.count {
            return dequeueReusableCell(withReuseIdentifier: RecordFrameCell.identifier, for: indexPath)
        } else if indexPath.row == recordOfFrames.count {
            return dequeueReusableCell(withReuseIdentifier: AddFrameCell.identifier, for: indexPath)
        } else {
            return dequeueReusableCell(withReuseIdentifier: GenerateFrameCell.identifier, for: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let frameCell = cell as? RecordFrameCell {
            let record = recordOfFrames[indexPath.row]

            frameCell.setImage(record.toImage)
            frameCell.setIsCurrent(selectedFrameIndex == indexPath.row)
            frameCell.canDelete = recordOfFrames.count > 1

            frameCell.dublicateHandler = { [weak self] in
                self?.dublicateFrameHandler?(indexPath.row)
            }
            frameCell.deleteHandler = { [weak self] in
                self?.deleteFrameHandler?(indexPath.row)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedFrameIndex == indexPath.row {
            return
        }
        if indexPath.row < recordOfFrames.count {
            selectedFrameChangedHandler?(indexPath.row)
        } else if indexPath.row == recordOfFrames.count {
            addFrameHandler?()
        } else {
            generateFramesHandler?()
        }
    }
}
