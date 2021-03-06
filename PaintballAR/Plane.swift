//
//  Plane.swift
//  PaintballAR
//
//  Created by Ty Mondragon on 7/31/18.
//  Copyright © 2018 g89 Group Project. All rights reserved.
//

import Foundation
import ARKit

class Plane: SCNNode {
    
    let plane: SCNPlane
    
    init(anchor: ARPlaneAnchor) {
        plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        super.init()
        
        plane.cornerRadius = 0.008
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "grid")
        planeNode.geometry?.firstMaterial?.transparency = 0.3
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        planeNode.eulerAngles.x = -.pi / 2
        
        addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(anchor: ARPlaneAnchor) {
        plane.width = CGFloat(anchor.extent.x)
        plane.height = CGFloat(anchor.extent.z)
        
        if let grid = plane.materials.first as? GridMaterial {
            grid.updateWith(anchor: anchor)
        }
        
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }
    
}
