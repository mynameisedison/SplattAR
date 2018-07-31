//
//  GridMaterial.swift
//  PaintballAR
//
//  Created by Ty Mondragon on 7/31/18.
//  Copyright © 2018 g89 Group Project. All rights reserved.
//

import Foundation
import ARKit

class GridMaterial: SCNMaterial {
    
    override init() {
        super.init()
        // 1
        let image = UIImage(named: "grid-frame")
        
        // 2
        diffuse.contents = image
        diffuse.wrapS = .repeat
        diffuse.wrapT = .repeat
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(anchor: ARPlaneAnchor) {
        // 1
        let mmPerMeter: Float = 1000
        let mmOfImage: Float = 65
        let repeatAmount: Float = mmPerMeter / mmOfImage
        
        // 2
        diffuse.contentsTransform = SCNMatrix4MakeScale(anchor.extent.x * repeatAmount, anchor.extent.z * repeatAmount, 1)
    }
    
}
