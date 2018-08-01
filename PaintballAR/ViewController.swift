//
//  ViewController.swift
//  PaintballAR
//
//  Created by Benjamin Broad, Edison Toole, John Stevens-Webb and Ty Mondragon on 7/26/18.
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
    let randomSplat = [#imageLiteral(resourceName: "pink-splat-9 (1)"), #imageLiteral(resourceName: "green-splat-14 (1)"), #imageLiteral(resourceName: "blue-splat-6 (1)"), #imageLiteral(resourceName: "red-splat-1 (1)"),]
    let audio = ["squish-1.wav", "smash_2.wav", "wowa.mp3", "wowc.mp3", "wowb.mp3", "splat-1.wav", "splat-2.wav"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneManager.attach(to: sceneView)
        
        sceneManager.displayDegubInfo()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScene(_:)))
        view.addGestureRecognizer(tapGesture)
        
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
        playAudio(soundFileName: audio[Int(arc4random_uniform(6))])
    }
    
    func playAudio(soundFileName: String) {
        do {
            if let fileURL = Bundle.main.path(forResource: soundFileName, ofType: nil) {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
            } else {
                print("No file with specified name exists")
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }
        audioPlayer.play()
    }
    
    private func createBox() -> SCNNode {
        let box = SCNBox(width: 0.15, height: 0.20, length: 0.05, chamferRadius: 0.02)
        let boxNode = SCNNode(geometry: box)
        boxNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: box, options: nil))
        let randomSplatIndex = Int(arc4random_uniform(4))
        boxNode.geometry?.firstMaterial?.diffuse.contents = randomSplat[randomSplatIndex]
        boxNode.name = "box"
        return boxNode
    }
    
    private func position(node: SCNNode, atHit hit: ARHitTestResult) {
        node.transform = SCNMatrix4(hit.anchor!.transform)
        node.eulerAngles = SCNVector3Make(node.eulerAngles.x + (Float.pi / 2), node.eulerAngles.y, node.eulerAngles.z)
        
        let position = SCNVector3Make(hit.worldTransform.columns.3.x + node.geometry!.boundingBox.min.z, hit.worldTransform.columns.3.y, hit.worldTransform.columns.3.z)
        node.position = position
    }
    
   
    @IBAction func resetPaint(_ sender: Any) {
        self.reset()
    }
    
    func reset() {
        self.sceneView.scene.rootNode.enumerateChildNodes { (boxNode, _) in
            if boxNode.name == "box" {
                boxNode.removeFromParentNode()
            }
        }
        playAudio(soundFileName: "whoosh.wav")
    }
    
}



