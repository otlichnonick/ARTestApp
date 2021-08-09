//
//  CustomBox.swift
//  ARTestApp
//
//  Created by Anton on 05.08.2021.
//

import Foundation
import SwiftUI
import RealityKit
import Combine

class CustomBox: Entity, HasModel,HasAnchoring, HasCollision {
    var collisionSubscriptions: [Cancellable] = []
    
    required init(imageUrl: URL?) {
        super.init()
        var material = SimpleMaterial()
        setupMaterialForImageWith(imageUrl, &material)
        setupCollisionAndModelComponents(material)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

extension CustomBox {
    func addCollisions() {
        guard let scene = self.scene else {
            debugPrint("there are no scene")
            return
        }
        
        collisionSubscriptions.append(scene.subscribe(to: CollisionEvents.Began.self, on: self, { event in
            guard let boxA = event.entityA as? CustomBox else { return }
            debugPrint("происходит касание")
            boxA.model?.materials = [SimpleMaterial(color: .red, isMetallic: false)]
        }))
        
        collisionSubscriptions.append(scene.subscribe(to: CollisionEvents.Ended.self, on: self, { event in
            guard let boxA = event.entityA as? CustomBox else { return }
            debugPrint("касание заканчивается")
            boxA.model?.materials = [SimpleMaterial(color: .green, isMetallic: false)]
        }))
    }
    
    fileprivate func setupTextureForImageWith(_ url: URL, _ material: inout SimpleMaterial) {
        do {
            let texture = try TextureResource.load(contentsOf: url)
            material.baseColor = MaterialColorParameter.texture(texture)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    fileprivate func setupMaterialForImageWith(_ fileUrl: URL?, _ material: inout SimpleMaterial) {
        if let url = fileUrl {
            setupTextureForImageWith(url, &material)
        } else {
            material = SimpleMaterial(color: .blue, isMetallic: false)
        }
    }
    
    fileprivate func setupCollisionAndModelComponents(_ material: SimpleMaterial) {
        self.components[CollisionComponent] = CollisionComponent(
            shapes: [.generateBox(size: SIMD3<Float>(0.1, 0.1, 0.1))],
            mode: .trigger,
            filter: CollisionFilter(group: CollisionGroup(rawValue: 1), mask: CollisionGroup(rawValue: 1)))
        
        self.components[ModelComponent] = ModelComponent(
            mesh: .generateBox(size: 0.1),
            materials: [material])
        
//        self.components[PhysicsBodyComponent] = PhysicsBodyComponent(massProperties: .default, material: .default, mode: .dynamic)
    }
}
