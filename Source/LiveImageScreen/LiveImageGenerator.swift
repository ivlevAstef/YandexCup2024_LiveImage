//
//  LiveImageGenerator.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 30.10.2024.
//

import UIKit

protocol LiveImageGeneratorViewProtocol: AnyObject {
    func showWriteHowManyFramesGenerate(success: @escaping (Int) -> Void)
}

final class LiveImageGeneratorPresenter {
    private let view: LiveImageGeneratorViewProtocol

    init(view: LiveImageGeneratorViewProtocol) {
        self.view = view
    }

    func generate(use emptyRecord: Canvas.Record, success successHandler: @escaping ([Canvas.Record]) -> Void) {
        view.showWriteHowManyFramesGenerate { [weak self] framesCount in
            if let self {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    let records = self.generate(use: emptyRecord, framesCount: framesCount)
                    successHandler(records)
                })
            }
        }
    }

    private func generate(use emptyRecord: Canvas.Record, framesCount: Int) -> [Canvas.Record] {
        return generateUseMoveFigure(use: emptyRecord, framesCount: framesCount)
    }

    private func generateUseMoveFigure(use emptyRecord: Canvas.Record, framesCount: Int) -> [Canvas.Record] {
        var result: [Canvas.Record] = []

        let generatedView = GeneratedView(size: emptyRecord.size)
        if 0 == Int.random(in: 0...1) {
            generatedView.makeSquareFigure()
        } else {
            generatedView.makeCircleFigure()
        }

        let startPosition = CGPoint(x: CGFloat.random(in: 50..<(emptyRecord.size.width - 50.0)),
                                    y: CGFloat.random(in: 50..<(emptyRecord.size.height - 50.0)))
        let endPosition = CGPoint(x: CGFloat.random(in: 50..<(emptyRecord.size.width - 50.0)),
                                  y: CGFloat.random(in: 50..<(emptyRecord.size.height - 50.0)))

        let startAngle = CGFloat.random(in: 0..<CGFloat.pi)
        let endAngle = CGFloat.random(in: 0..<2*CGFloat.pi)
        let startScale = CGPoint(x: 1.0, y: 1.0)
        let endScale = CGPoint(x: CGFloat.random(in: 0.5..<2.0), y: CGFloat.random(in:0.5..<2.0))

        let vector = CGPoint(x: endPosition.x - startPosition.x, y: endPosition.y - startPosition.y)

        for i in 0..<framesCount {
            let progress = CGFloat(i) / CGFloat(framesCount)
            let position = CGPoint(x: startPosition.x + progress * vector.x,
                                   y: startPosition.y + progress * vector.y)
            generatedView.position = position
            generatedView.rotate = startAngle + (endAngle - startAngle) * progress
            generatedView.scale = CGPoint(x: startScale.x + (endScale.x - startScale.x) * progress,
                                          y: startScale.y + (endScale.y - startScale.y) * progress)
            result.append(generatedView.generateImage())
        }

        return result
    }
}

private final class GeneratedView: UIView {
    let shapeLayer: CAShapeLayer = CAShapeLayer()

    var position: CGPoint = .zero
    var rotate: CGFloat = 0
    var scale: CGPoint = CGPoint(x: 1.0, y: 1.0)

    init(size: CGSize) {
        super.init(frame: CGRect(origin: .zero, size: size))

        shapeLayer.contentsScale = layer.contentsScale
        layer.addSublayer(shapeLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    func generateImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            rendererContext.cgContext.translateBy(x: position.x, y: position.y)
            rendererContext.cgContext.rotate(by: rotate)
            rendererContext.cgContext.scaleBy(x: scale.x, y: scale.y)
            shapeLayer.render(in: rendererContext.cgContext)
        }
    }
}
