//
//  ViewController.swift
//  PaintballAR
//
//  Created by Benjamin Broad on 7/26/18.
//  Copyright © 2018 g89 Group Project. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    

    @IBOutlet weak var sceneView: ARSCNView!
    
    var audioPlayer = AVAudioPlayer()

    let sceneManager = ARSceneManager()
    let randomSplat = [#imageLiteral(resourceName: "blue-splat-6"), #imageLiteral(resourceName: "green-splat-14"), #imageLiteral(resourceName: "pink-splat-9"), #imageLiteral(resourceName: "red-splat-1")]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneManager.attach(to: sceneView)
        
        sceneManager.displayDegubInfo()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScene(_:)))
        view.addGestureRecognizer(tapGesture)
        
        do {
            if let fileURL = Bundle.main.path(forResource: "squish-1", ofType: "wav") {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
            } else {
                print("No file with specified name exists")
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }
    }
    
    @objc func didTapScene(_ gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .ended:
            
            let location = gesture.location(ofTouch: 0,
                                            in: sceneView)
            
            let hit = sceneView.hitTest(location,
                                        types: .existingPlaneUsingGeometry)
            
            if let hit = hit.first {
                placeBlockOnPlaneAt(hit)
            }
        default:
            print("tapped default")
            
        }
    }
    
    func placeBlockOnPlaneAt(_ hit: ARHitTestResult) {
        let box = createBox()
        position(node: box, atHit: hit)
        
        sceneView?.scene.rootNode.addChildNode(box)
        audioPlayer.play()
    }
    
    private func createBox() -> SCNNode {
        let box = SCNBox(width: 0.15, height: 0.20, length: 0.02, chamferRadius: 0.02)
        let boxNode = SCNNode(geometry: box)
        boxNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: box, options: nil))
        let randomSplatIndex = Int(arc4random_uniform(4))
        boxNode.geometry?.firstMaterial?.diffuse.contents = randomSplat[randomSplatIndex]
        return boxNode
    }
    
    private func position(node: SCNNode, atHit hit: ARHitTestResult) {
        node.transform = SCNMatrix4(hit.anchor!.transform)
        node.eulerAngles = SCNVector3Make(node.eulerAngles.x + (Float.pi / 2), node.eulerAngles.y, node.eulerAngles.z)
        
        let position = SCNVector3Make(hit.worldTransform.columns.3.x + node.geometry!.boundingBox.min.z, hit.worldTransform.columns.3.y, hit.worldTransform.columns.3.z)
        node.position = position
    }
    
    @IBAction func tappedShoot(_ sender: Any) {
        let camera = sceneView.session.currentFrame!.camera
        let projectile = Projectile()
        
        // transform to location of camera
        var translation = matrix_float4x4(projectile.transform)
        translation.columns.3.z = -0.1
        translation.columns.3.x = 0.03
        
        projectile.simdTransform = matrix_multiply(camera.transform, translation)
        
        let force = simd_make_float4(-1, 0, -3, 0)
        let rotatedForce = simd_mul(camera.transform, force)
        
        let impulse = SCNVector3(rotatedForce.x, rotatedForce.y, rotatedForce.z)
        
        sceneView?.scene.rootNode.addChildNode(projectile)
        
        projectile.launch(inDirection: impulse)
    }
    
    //    @IBAction func tappedShowPlanes(_ sender: Any) {
    //        sceneManager.showPlanes = true
    //    }
    //
    //    @IBAction func tappedHidePlanes(_ sender: Any) {
    //        sceneManager.showPlanes = false
    //    }
    //
    //    @IBAction func tappedStop(_ sender: Any) {
    //        sceneManager.stopPlaneDetection()
    //    }
    //
    //    @IBAction func tappedStart(_ sender: Any) {
    //        sceneManager.startPlaneDetection()
    //    }
    
}

class Projectile: SCNNode {
    
    override init() {
        super.init()
        
        let capsule = SCNCapsule(capRadius: 0.006, height: 0.06)
        
        geometry = capsule
        
        eulerAngles = SCNVector3(CGFloat.pi / 2, (CGFloat.pi * 0.25), 0)
        
        physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func launch(inDirection direction: SCNVector3) {
        physicsBody?.applyForce(direction, asImpulse: true)
    }
}

