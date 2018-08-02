//
//  ViewController.swift
//  PaintballAR
//
//  Created by Benjamin Broad, Edison Toole, John Stevens-Webb and Ty Mondragon on 7/26/18.
//  Copyright © 2018 g89 Group Project. All rights reserved.
//  Icon made by (http://www.freepik.com) Freepik from (https://www.flaticon.com/) is licensed by Creative Commons BY 3.0.
//
//

import UIKit
import ARKit
import SceneKit
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var cyanButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var pinkButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var resetButtonAttributes: UIButton!
    @IBOutlet weak var selectColorButton: UIButton!
    @IBOutlet weak var colorIndicator: UIButton!
    
    //Button origin initializers
    var redOrigin: CGPoint!
    var blueOrigin: CGPoint!
    var cyanOrigin: CGPoint!
    var greenOrigin: CGPoint!
    var pinkOrigin: CGPoint!
    var yellowOrigin: CGPoint!
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var audioPlayer = AVAudioPlayer()

    let sceneManager = ARSceneManager()
    var selectedSplat = [#imageLiteral(resourceName: "red1"),#imageLiteral(resourceName: "red2"), #imageLiteral(resourceName: "red3"), #imageLiteral(resourceName: "red4"), #imageLiteral(resourceName: "red5"), #imageLiteral(resourceName: "red6")]
    let redSplat = [#imageLiteral(resourceName: "red1"),#imageLiteral(resourceName: "red2"), #imageLiteral(resourceName: "red3"), #imageLiteral(resourceName: "red4"), #imageLiteral(resourceName: "red5"), #imageLiteral(resourceName: "red6")]
    let greenSplat = [#imageLiteral(resourceName: "green1"), #imageLiteral(resourceName: "green2"), #imageLiteral(resourceName: "green3"), #imageLiteral(resourceName: "green4"), #imageLiteral(resourceName: "green5"), #imageLiteral(resourceName: "green6")]
    let yellowSplat = [#imageLiteral(resourceName: "yellow1"), #imageLiteral(resourceName: "yellow2"), #imageLiteral(resourceName: "yellow3"), #imageLiteral(resourceName: "yellow4"), #imageLiteral(resourceName: "yellow5"), #imageLiteral(resourceName: "yellow6")]
    let blueSplat = [#imageLiteral(resourceName: "blue1"), #imageLiteral(resourceName: "blue2"), #imageLiteral(resourceName: "blue3"), #imageLiteral(resourceName: "blue4"), #imageLiteral(resourceName: "blue5"), #imageLiteral(resourceName: "blue6")]
    let pinkSplat = [#imageLiteral(resourceName: "pink1"), #imageLiteral(resourceName: "pink2"), #imageLiteral(resourceName: "pink3"), #imageLiteral(resourceName: "pink4"), #imageLiteral(resourceName: "pink5"), #imageLiteral(resourceName: "pink6")]
    let cyanSplat = [#imageLiteral(resourceName: "cyan1"), #imageLiteral(resourceName: "cyan2"), #imageLiteral(resourceName: "cyan3"), #imageLiteral(resourceName: "cyan4"), #imageLiteral(resourceName: "cyan5"), #imageLiteral(resourceName: "cyan6")]
    
    let audio = ["squish-1.wav", "smash_2.wav", "wowc.mp3", "splat-1.wav", "splat-2.wav"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneManager.attach(to: sceneView)
        
        UIApplication.shared.isIdleTimerDisabled = true
        //Button rounding
        resetButtonAttributes.layer.cornerRadius = 10
        redButton.layer.cornerRadius = 15
        blueButton.layer.cornerRadius = 15
        cyanButton.layer.cornerRadius = 15
        greenButton.layer.cornerRadius = 15
        pinkButton.layer.cornerRadius = 15
        yellowButton.layer.cornerRadius = 15
        
        //Storing original points
        redOrigin = redButton.center
        blueOrigin = blueButton.center
        cyanOrigin = cyanButton.center
        greenOrigin = greenButton.center
        pinkOrigin = pinkButton.center
        yellowOrigin = yellowButton.center
        
        //Hiding color UI on load
        self.redButton.translatesAutoresizingMaskIntoConstraints = true
        redButton.center = selectColorButton.center
        self.blueButton.translatesAutoresizingMaskIntoConstraints = true
        blueButton.center = selectColorButton.center
        self.cyanButton.translatesAutoresizingMaskIntoConstraints = true
        cyanButton.center = selectColorButton.center
        self.greenButton.translatesAutoresizingMaskIntoConstraints = true
        greenButton.center = selectColorButton.center
        self.pinkButton.translatesAutoresizingMaskIntoConstraints = true
        pinkButton.center = selectColorButton.center
        self.yellowButton.translatesAutoresizingMaskIntoConstraints = true
        yellowButton.center = selectColorButton.center
        
        //Highlights
        redButton.showsTouchWhenHighlighted = true
        blueButton.showsTouchWhenHighlighted = true
        cyanButton.showsTouchWhenHighlighted = true
        greenButton.showsTouchWhenHighlighted = true
        yellowButton.showsTouchWhenHighlighted = true
        pinkButton.showsTouchWhenHighlighted = true
        resetButtonAttributes.showsTouchWhenHighlighted = true
        selectColorButton.showsTouchWhenHighlighted = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScene(_:)))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewDidLayoutSubviews() {
        //Hiding buttons on load

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
        playAudio(soundFileName: audio[Int(arc4random_uniform(5))])
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
        let box = SCNBox(width: 0.15, height: 0.20, length: 0.001, chamferRadius: 0.02)
        let boxNode = SCNNode(geometry: box)
        boxNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: box, options: nil))
        let randomSplatIndex = Int(arc4random_uniform(4))
        boxNode.geometry?.firstMaterial?.diffuse.contents = selectedSplat[randomSplatIndex]
        boxNode.name = "box"
        return boxNode
    }
    
    private func position(node: SCNNode, atHit hit: ARHitTestResult) {
        node.transform = SCNMatrix4(hit.anchor!.transform)
        node.eulerAngles = SCNVector3Make(node.eulerAngles.x + (Float.pi / 2), node.eulerAngles.y, node.eulerAngles.z)
        
        let position = SCNVector3Make(hit.worldTransform.columns.3.x + node.geometry!.boundingBox.min.z, hit.worldTransform.columns.3.y, hit.worldTransform.columns.3.z)
        node.position = position
    }
    
   // Reset paint functionality
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
    
    // Color selection functionality
    @IBAction func red(_ sender: Any) {
        updateIndicator(image: #imageLiteral(resourceName: "redsplat"))
        selectedSplat = redSplat
    }
    
    @IBAction func blue(_ sender: Any) {
        updateIndicator(image: #imageLiteral(resourceName: "bluesplat"))
        selectedSplat = blueSplat
    }
    
    @IBAction func cyan(_ sender: Any) {
        updateIndicator(image: #imageLiteral(resourceName: "cyansplat"))
        selectedSplat = cyanSplat
    }
    
    
    @IBAction func green(_ sender: Any) {
        updateIndicator(image: #imageLiteral(resourceName: "greensplat"))
        selectedSplat = greenSplat
    }
    
   
    @IBAction func pink(_ sender: Any) {
        updateIndicator(image: #imageLiteral(resourceName: "pinksplat"))
        selectedSplat = pinkSplat
    }
    
    @IBAction func yellow(_ sender: Any) {
        updateIndicator(image: #imageLiteral(resourceName: "yellowsplat"))
        selectedSplat = yellowSplat
    }
    
    @IBAction func expandSelect(_ sender: UIButton) {
        if selectColorButton.currentImage == #imageLiteral(resourceName: "arrow-up-color") {
            // expand buttons
            UIView.animate(withDuration: 0.3, animations: {
                self.redButton.alpha = 1
                self.blueButton.alpha = 1
                self.cyanButton.alpha = 1
                self.greenButton.alpha = 1
                self.pinkButton.alpha = 1
                self.yellowButton.alpha = 1
                
                self.redButton.center = self.redOrigin
                self.blueButton.center = self.blueOrigin
                self.cyanButton.center = self.cyanOrigin
                self.greenButton.center = self.greenOrigin
                self.pinkButton.center = self.pinkOrigin
                self.yellowButton.center = self.yellowOrigin
                })
        } else {
            // contract buttons
            UIView.animate(withDuration: 0.3, animations: {
                self.redButton.alpha = 0
                self.blueButton.alpha = 0
                self.cyanButton.alpha = 0
                self.greenButton.alpha = 0
                self.pinkButton.alpha = 0
                self.yellowButton.alpha = 0
                
                self.redButton.center = self.selectColorButton.center
                self.blueButton.center = self.selectColorButton.center
                self.cyanButton.center = self.selectColorButton.center
                self.greenButton.center = self.selectColorButton.center
                self.pinkButton.center = self.selectColorButton.center
                self.yellowButton.center = self.selectColorButton.center
            })

        }
        toggleButton(button: sender, onImage: #imageLiteral(resourceName: "arrow-down-color"), offImage: #imageLiteral(resourceName: "arrow-up-color"))
    }
    
    func toggleButton(button: UIButton, onImage: UIImage, offImage: UIImage) {
        if button.currentImage == offImage {
            button.setImage(onImage, for: .normal)
        } else {
            button.setImage(offImage, for: .normal)
        }
    }
    
    func updateIndicator(image: UIImage) {
        self.colorIndicator.setImage(image, for: .normal)
    }
    
    
}



