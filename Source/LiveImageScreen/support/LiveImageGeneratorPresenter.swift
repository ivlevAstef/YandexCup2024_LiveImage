//
//  LiveImageGenerator.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 30.10.2024.
//

import UIKit

protocol LiveImageGeneratorViewProtocol: AnyObject {
    func showWriteHowManyFramesGenerate(success: @escaping (Int) -> Void)

    func showProgress(text: String)
    func endProgress()
}

final class LiveImageGeneratorPresenter {
    private let view: LiveImageGeneratorViewProtocol

    init(view: LiveImageGeneratorViewProtocol) {
        self.view = view
    }

    func generate(canvasSize: CanvasSize, success successHandler: @escaping ([Canvas.Record]) -> Void) {
        view.showWriteHowManyFramesGenerate { [weak self, weak view] framesCount in
            view?.showProgress(text: "Generating...")
            DispatchQueue.global().async {
                guard let self else {
                    return
                }

                let records = self.generate(canvasSize: canvasSize, framesCount: framesCount)
                DispatchQueue.main.async {
                    view?.endProgress()
                    successHandler(records)
                }
            }
        }
    }

    private func generate(canvasSize: CanvasSize, framesCount: Int) -> [Canvas.Record] {
        return generateUseMoveFigure(canvasSize: canvasSize, framesCount: framesCount)
    }

    /// генерирует указанное количество картинок, используя перемещение случайной фигуры.
    /// Не буду спорить, этот код можно написать гораздо красивее.
    private func generateUseMoveFigure(canvasSize: CanvasSize, framesCount: Int) -> [Canvas.Record] {
        var result: [Canvas.Record] = []

        let generatedView = GeneratedView(canvasSize: canvasSize)
        if 0 == Int.random(in: 0...1) {
            generatedView.makeSquareFigure()
        } else {
            generatedView.makeCircleFigure()
        }

        let xRandInterval = 50..<max(51, (canvasSize.width - 50.0))
        let yRandInterval = 50..<max(51, (canvasSize.height - 50.0))

        var startPosition = CGPoint(x: CGFloat.random(in: xRandInterval), y: CGFloat.random(in: yRandInterval))
        var endPosition = CGPoint(x: CGFloat.random(in: xRandInterval), y: CGFloat.random(in: yRandInterval))
        var startAngle = CGFloat.random(in: 0..<CGFloat.pi)
        var endAngle = CGFloat.random(in: 0..<2*CGFloat.pi)
        var startScale = CGPoint(x: 1.0, y: 1.0)
        var endScale = CGPoint(x: CGFloat.random(in: 0.5..<2.0), y: CGFloat.random(in:0.5..<2.0))

        // Если задали очень много кадров, то делаем анимацию из просто движение по прямой,
        // но каждые следующие step кадров меняется направление угол поворота и scale, тем самым анимация выглядит плавной, и меняющейся даже на больших интервалах.
        let step = 50
        var index = 0
        while index < framesCount {
            let endIndexInSeries = min(framesCount, index + step)
            let framesInSeries = endIndexInSeries - index
            index = endIndexInSeries

            let vector = CGPoint(x: endPosition.x - startPosition.x, y: endPosition.y - startPosition.y)
            for i in 0..<framesInSeries {
                let progress = CGFloat(i) / CGFloat(framesInSeries)
                let position = CGPoint(x: startPosition.x + progress * vector.x,
                                       y: startPosition.y + progress * vector.y)
                generatedView.position = position
                generatedView.rotate = startAngle + (endAngle - startAngle) * progress
                generatedView.scale = CGPoint(x: startScale.x + (endScale.x - startScale.x) * progress,
                                              y: startScale.y + (endScale.y - startScale.y) * progress)
                autoreleasepool {
                    result.append(generatedView.generateRecord())
                }
            }

            startPosition = endPosition
            startAngle = endAngle
            startScale = endScale

            endPosition = CGPoint(x: CGFloat.random(in: xRandInterval), y: CGFloat.random(in: yRandInterval))
            endAngle = CGFloat.random(in: 0..<2*CGFloat.pi)
            endScale = CGPoint(x: CGFloat.random(in: 0.5..<2.0), y: CGFloat.random(in:0.5..<2.0))
        }

        return result
    }
}

private final class GeneratedView {
    var position: CGPoint = .zero
    var rotate: CGFloat = 0
    var scale: CGPoint = CGPoint(x: 1.0, y: 1.0)

    private let renderer: UIGraphicsImageRenderer
    private let shapeLayer: CAShapeLayer = CAShapeLayer()

    init(canvasSize: CanvasSize) {
        let format = UIGraphicsImageRendererFormat()
        format.scale = canvasSize.scale
        format.opaque = false
        renderer = UIGraphicsImageRenderer(size: canvasSize.size, format: format)

        shapeLayer.contentsScale = canvasSize.scale
        shapeLayer.frame = CGRect(origin: .zero, size: canvasSize.size)
    }

    func makeCircleFigure() {
        let randomSize = CGFloat(Int.random(in: 50..<100))
        let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: CGSize(width: randomSize, height: randomSize)))

        shapeLayer.strokeColor = UIColor.random().cgColor
        shapeLayer.fillColor = UIColor.random().cgColor
        shapeLayer.lineWidth = CGFloat(Int.random(in: 2..<5))
        shapeLayer.opacity = 1.0
        shapeLayer.path = path.cgPath
    }

    func makeSquareFigure() {
        let randomSize = CGFloat(Int.random(in: 50..<100))
        let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: CGSize(width: randomSize, height: randomSize)),
                                cornerRadius: CGFloat(Int.random(in: 2..<10)))

        shapeLayer.strokeColor = UIColor.random().cgColor
        shapeLayer.fillColor = UIColor.random().cgColor
        shapeLayer.lineWidth = CGFloat(Int.random(in: 2..<5))
        shapeLayer.opacity = 1.0
        shapeLayer.path = path.cgPath
    }

    func generateRecord() -> Canvas.Record {
        let resultPngData = renderer.pngData { rendererContext in
            rendererContext.cgContext.translateBy(x: position.x, y: position.y)
            rendererContext.cgContext.rotate(by: rotate)
            rendererContext.cgContext.scaleBy(x: scale.x, y: scale.y)
            shapeLayer.render(in: rendererContext.cgContext)
        }

        return resultPngData
    }
}
