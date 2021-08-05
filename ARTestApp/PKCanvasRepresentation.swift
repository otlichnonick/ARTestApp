//
//  PKCanvasRepresentation.swift
//  ARTestApp
//
//  Created by Anton on 05.08.2021.
//

import UIKit
import SwiftUI
import PencilKit

struct PKCanvasRepresentation: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 20)
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
    }
}
