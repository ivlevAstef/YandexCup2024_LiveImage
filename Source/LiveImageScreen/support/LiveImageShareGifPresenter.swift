//
//  LiveImageGifSaver.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 31.10.2024.
//

import Foundation
import UIKit
import UniformTypeIdentifiers
import CoreGraphics
import ImageIO

typealias LiveImageShouldShareGifHandler = () -> Void
protocol LiveImageShareGifViewProtocol: AnyObject {
    var shouldShareHandler: LiveImageShouldShareGifHandler? { get set }

    func showShareMenu(for file: URL)

    func showProgress(text: String)
    func endProgress(completion: (() -> Void)?)
}

final class LiveImageShareGifPresenter {
    var currentRecordInfoProvider: (() -> (CanvasSize, [Canvas.Record])?)?

    private let view: LiveImageShareGifViewProtocol

    init(view: LiveImageShareGifViewProtocol) {
        self.view = view

        view.shouldShareHandler = { [weak self] in
            self?.shareGif()
        }
    }

    private func shareGif() {
        log.info("share gif file")

        guard let (canvasSize, currentRecords) = currentRecordInfoProvider?() else {
            log.assert("fail get current records for share gif - please setup `currentRecordsProvider`")
            return
        }

        view.showProgress(text: "Creating Gif...")
        DispatchQueue.global().async { [weak self] in
            let savedFileURL = Self.save(records: currentRecords, canvasSize: canvasSize, filename: "animation.gif")
            DispatchQueue.main.async {
                self?.view.endProgress(completion: {
                    guard let savedFileURL else {
                        log.error("fail save file for share gif")
                        return
                    }

                    self?.view.showShareMenu(for: savedFileURL)
                })
            }
        }
    }

    private static func save(records: [Canvas.Record], canvasSize: CanvasSize, filename: String) -> URL? {
        let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)

        //create the file and set the file properties
        guard let animatedGifFile = CGImageDestinationCreateWithURL(destinationURL as CFURL,
                                                                    UTType.gif.identifier as CFString,
                                                                    records.count, nil) else {
            log.warning("fail creating gif file")
            return nil
        }

        let fileProperties: CFDictionary = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: 0,
                kCGImagePropertyGIFHasGlobalColorMap as String: false
            ]
        ] as CFDictionary
        CGImageDestinationSetProperties(animatedGifFile, fileProperties)

        let frameProperties: CFDictionary = [
            kCGImagePropertyGIFDictionary as String: [
                (kCGImagePropertyGIFDelayTime as String): 1.0 / 30.0
            ]
        ] as CFDictionary

        for record in records {
            autoreleasepool {
                if let cgImage = record.makeImage(canvasSize: canvasSize)?.cgImage {
                    CGImageDestinationAddImage(animatedGifFile, cgImage, frameProperties)
                }
            }
        }

        return autoreleasepool {
            if !CGImageDestinationFinalize(animatedGifFile) {
                log.warning("fail creating gif file - finalize failed")
                return nil
            }
            return destinationURL
        }
    }
}
