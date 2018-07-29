//
//  ViewController.swift
//  PaintballAR
//
//  Created by Benjamin Broad on 7/26/18.
//  Copyright © 2018 g89 Group Project. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = [.horizontal, .vertical]
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        ///// Demo purposes for showing the zombie node when a plane is detected
        //        let zombieNode = createZombie()
        //        self.sceneView.scene.rootNode.addChildNode(zombieNode)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    ////Modify the zombie node function to take the plane anchor argument
    func createZombie(planeAnchor: ARPlaneAnchor) -> SCNNode {
        //        let zombieNode = SCNNode(geometry: SCNPlane(width: 1, height: 1))
        /////This will adjust the size of the image to the size of the field recognized
        let zombieNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        zombieNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "lava")
        zombieNode.geometry?.firstMaterial?.isDoubleSided = true
        //        zombieNode.position = SCNVector3(0, 0, -1)
        //////Have the zombieNode have the same postion as the ARPlane Anchor, align it  to the detected surface by centering it relative to the respective view(horizontal, vertical, z
        zombieNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
        zombieNode.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        return zombieNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        //////this instantiates the create zombieNode as a plane when a plane is recognized
        let zombieNode = createZombie(planeAnchor: planeAnchor)
        ////everytime a horiz surface is detected, a node is added to represent that surface.  Make sure that the zombieNode is positioned relative to the (did add node)
        node.addChildNode(zombieNode)
        print("new flat surface detected, new arplane anchor added")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        ////update the image to make the image larger(plane)
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        let zombieNode = createZombie(planeAnchor: planeAnchor)
        node.addChildNode(zombieNode)
        print("updating floor's anchor")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        ////If a plane anchor is removed, need to remove the plane associated with the anchor
        guard let _ = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        //        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
    }
}

extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/180 }

}

