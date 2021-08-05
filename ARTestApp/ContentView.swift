//
//  ContentView.swift
//  ARTestApp
//
//  Created by Anton on 04.08.2021.
//

import SwiftUI
import RealityKit
import PencilKit
import ARKit
import Vision

struct ContentView : View {
    @State var canvasView = PKCanvasView()
    @State var digitPredicted = "NA"
    private let textRecognitionWorkQueue = DispatchQueue(label: "VisionRequest", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    var body: some View {
        VStack {
            ARViewContainer(overlayText: $digitPredicted)
                .edgesIgnoringSafeArea(.all)
            
            PKCanvasRepresentation(canvasView: $canvasView)
            
            HStack {
                Button(action: {
                    let image = self.canvasView.drawing.image(from: self.canvasView.drawing.bounds, scale: 1.0)
                    self.recognizeTextInImage(image)
                    self.canvasView.drawing = PKDrawing()
                }) {
                    Text("Extract Digit")
                }
                Text(digitPredicted)
            }
        }
    }
    
    private func recognizeTextInImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        let model = try! VNCoreMLModel(for: MNISTClassifier(configuration: MLModelConfiguration()).model)
        let request = VNCoreMLRequest(model: model)
        
        textRecognitionWorkQueue.async {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try requestHandler.perform([request])
                if let observations = request.results as? [VNClassificationObservation] {
                    debugPrint("observations = \(observations)")
                    self.digitPredicted = observations.first?.identifier ?? ""
                }
            } catch {
                print("error with observations = \(error.localizedDescription)")
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
