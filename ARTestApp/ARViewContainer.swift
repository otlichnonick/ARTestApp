//
//  ARViewContainer.swift
//  ARTestApp
//
//  Created by Anton on 05.08.2021.
//

import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    @Binding var imageUrl: URL?
    
    func makeCoordinator() -> ARViewCoordinator {
        ARViewCoordinator(self, imageUrl: $imageUrl)
    }
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options: [])

        arView.setupGesture()
        arView.addCoaching()
        arView.session.delegate = context.coordinator

        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

class ARViewCoordinator: NSObject, ARSessionDelegate {
    var arVC: ARViewContainer
    @Binding var imageUrl: URL?
    
    init(_ control: ARViewContainer, imageUrl: Binding<URL?>) {
        self.arVC = control
        _imageUrl = imageUrl
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    }
}

extension ARView {
    func setupGesture() {
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        guard let touchInView = sender?.location(in: self) else { return }
        rayCastingMethod(point: touchInView)
    }
    
    func rayCastingMethod(point: CGPoint) {
        guard let raysastQuery = self.makeRaycastQuery(from: point,
                                                       allowing: .existingPlaneInfinite,
                                                       alignment: .horizontal) else {
            print("failed raysastQuery")
            return
        }
        
        guard let result = self.session.raycast(raysastQuery).first else {
            print("failed first")
            return
        }
        
        guard let coordinator = self.session.delegate as? ARViewCoordinator else { return }
        
        let transformation = Transform(matrix: result.worldTransform)
        let box = CustomBox(imageUrl: coordinator.imageUrl)
        box.generateCollisionShapes(recursive: true)
        box.transform = transformation
                
        let raycastAnchor = AnchorEntity(raycastResult: result)
        raycastAnchor.addChild(box)
        self.installGestures(.all, for: box)
        self.scene.addAnchor(raycastAnchor)
        box.addCollisions()
    }
}

extension ARView: ARCoachingOverlayViewDelegate {
    func addCoaching() {
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.delegate = self
        coachingOverlay.session = self.session
        coachingOverlay.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        coachingOverlay.goal = .anyPlane
        self.addSubview(coachingOverlay)
    }
    
    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        // отключает автоматическое появление оверлея при потере цели (плоскости)
        coachingOverlayView.activatesAutomatically = false
    }
}
