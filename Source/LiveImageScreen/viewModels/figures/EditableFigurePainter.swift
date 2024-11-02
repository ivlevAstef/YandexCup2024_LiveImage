//
//  EditableFigurePainter.swift
//  LiveImage
//
//  Created by Alexander Ivlev on 02.11.2024.
//

import UIKit

protocol EditableFigurePainter: EditableObjectPainter {
    var fillColor: UIColor { get set }
}
