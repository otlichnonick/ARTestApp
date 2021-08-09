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
import GXUtilz

struct ContentView : View {
    @State var canvasView = PKCanvasView()
    @State var imageUrl: URL?
    @State var showCanvas = false
    
    var body: some View {
        ZStack {
            ARViewContainer(imageUrl: $imageUrl)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Button(action: {
                    self.showCanvas.toggle()
                }) {
                    Text("Открыть холст")
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
        .sheet(isPresented: $showCanvas) {
            CanvasView(imageUrl: $imageUrl, canvasView: $canvasView, showCanvas: $showCanvas)
        }
    }
}

struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
