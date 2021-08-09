//
//  CanvasView.swift
//  ARTestApp
//
//  Created by Anton on 06.08.2021.
//

import SwiftUI
import PencilKit

struct CanvasView: View {
    @Binding var imageUrl: URL?
    @Binding var canvasView: PKCanvasView
    @Binding var showCanvas: Bool
    private let savingImageWorkQueue = DispatchQueue(label: "VisionRequest", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)

    var body: some View {
        ZStack {
            PKCanvasRepresentation(canvasView: $canvasView, showCanvas: $showCanvas)
            
            VStack {
                Spacer()
                
                Button(action: {
                    saveImageFrom(canvas: self.canvasView)
                    self.canvasView.drawing = PKDrawing()
                    self.showCanvas.toggle()
                }) {
                    Text("Сохранить")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                }
                .frame(height: 40, alignment: .center)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.bottom, 20)
            }
        }
    }
    
    private func saveImageFrom(canvas: PKCanvasView) {
        let image = canvas.drawing.image(from: canvas.drawing.bounds, scale: 1)
        let fileUrl = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        savingImageWorkQueue.async {
            let pngData = image.pngData()
            do {
                try pngData?.write(to: fileUrl)
                imageUrl = fileUrl
            } catch {
                debugPrint("save error: \(error.localizedDescription)")
            }
        }
    }
}

struct CanvasView_Previews: PreviewProvider {
    static var previews: some View {
        CanvasView(imageUrl: .constant(URL(string: "")!), canvasView: .constant(PKCanvasView()), showCanvas: .constant(false))
    }
}
