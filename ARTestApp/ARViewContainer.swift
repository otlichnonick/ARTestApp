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
    @Binding var overlayText: String
    
    func makeCoordinator() -> ARViewCoordinator {
        ARViewCoordinator(self, overlayText: $overlayText)
    }
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        arView.addCoaching()
        
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        
        arView.session.run(config, options: [])

        arView.setupGesture()
        arView.session.delegate = context.coordinator

        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

class ARViewCoordinator: NSObject, ARSessionDelegate {
    var arVC: ARViewContainer
    @Binding var overlayText: String
    
    init(_ control: ARViewContainer, overlayText: Binding<String>) {
        self.arVC = control
        _overlayText = overlayText
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
        guard let coordinator = self.session.delegate as? ARViewCoordinator else { return }
        
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
        
        let transformation = Transform(matrix: result.worldTransform)
        let box = CustomBox(color: .yellow)
        self.installGestures(.all, for: box)
        box.generateCollisionShapes(recursive: true)
        
        let mesh = MeshResource.generateText(
            coordinator.overlayText,
            extrusionDepth: 0.1,
            font: .systemFont(ofSize: 1),
            containerFrame: .zero,
            alignment: .left,
            lineBreakMode: .byTruncatingTail
        )
        
        let material = SimpleMaterial(color: .red, isMetallic: false)
        let entity = ModelEntity(mesh: mesh, materials: [material])
        entity.scale = SIMD3<Float>(0.03, 0.03, 0.1)
        
        box.addChild(entity)
        box.transform = transformation
        
        entity.setPosition(SIMD3<Float>(0, 0.05, 0), relativeTo: box)
        
        let raycastAnchor = AnchorEntity(raycastResult: result)
        raycastAnchor.addChild(box)
        self.scene.addAnchor(raycastAnchor)
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
