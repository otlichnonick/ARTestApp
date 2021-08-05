//
//  CustomBox.swift
//  ARTestApp
//
//  Created by Anton on 05.08.2021.
//

import Foundation
import SwiftUI
import RealityKit

class CustomBox: Entity, HasModel,HasAnchoring, HasCollision {
    required init(color: UIColor) {
        super.init()
        self.components[ModelComponent] = ModelComponent(
            mesh: .generateBox(size: 0.1),
            materials: [SimpleMaterial(color: color, isMetallic: false)])
    }
    
    convenience init(color: UIColor, position: SIMD3<Float>) {
        self.init(color: color)
        self.position = position
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
