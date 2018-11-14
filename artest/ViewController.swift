//
//  ViewController.swift
//  artest
//
//  Created by Hao Zhang on 10/15/18.
//  Copyright © 2018 Hao Zhang. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusTextView: UITextView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var shutterButton: UIButton!
    @IBOutlet weak var center: UIImageView!
    @IBOutlet weak var startButton: UIButton!
    
    var box: Box!
    var status: String!
    var startPosition: SCNVector3!
    var distance: Float!
    var trackingState: ARCamera.TrackingState!
    var closeup: UIImage?
    var overview: UIImage?
    var shotCount: Int!
    var measureCount: Int!
    var steps: String!
    
    var diameterCount: Int!
    var width_height: String!
    var diameter1: Float!
    var diameter2: Float!
    
    // set up haptic feedback
    let impact = UIImpactFeedbackGenerator()
    
    enum Mode {
        case waitingForMeasuring
        case measuring
    }
    
    // mmeasure button function
    @IBAction func measureButton(_ sender: UIButton) {
        // haptic feedback
        impact.impactOccurred()
        // start measuring: set measureCount to 2,
        // hide cross at the center
        // change button label to "STOP"
        if measureCount == 1 {
            measureCount += 1
            mode = .measuring
            center.isHidden = true
            sender.setTitle("STOP", for: .normal)
        // not measuring/finished measuring
        // set measureCount to 1
        } else {
            measureCount = 1
            // if measure has been taken
            // update instruction
            // make shutter button visible
            if distance != 0.0 {
                if diameterCount == 0 {
                    diameterCount += 1
                    diameter1 = distance
                    steps = "Height \n Measure the tallest part of the rash \n Tap Start to measure"
                } else {
                    diameterCount += 1
                    diameter2 = distance
                    steps = "Make sure rash fills the frame. \n Tap the shutter button to take a close up of the rash"
                    shutterButton.isHidden = true
                    sender.isHidden = true
                    shutterButton.isHidden = false
                }
            }

            mode = .waitingForMeasuring
            center.isHidden = false
            
//                let alert = UIAlertController(title: "Done measuring?",
//                                              message: "message", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
//                alert.view.tintColor = UIColor(red: 250/255, green: 181/255, blue: 194/255, alpha: 1.0)
//                self.present(alert, animated: true)
            
            sender.setTitle("START", for: .normal)
        }
    }
    

    var mode: Mode = .waitingForMeasuring {
        didSet {
            switch mode {
            case .waitingForMeasuring:
                status = "NOT READY"
            case .measuring:
                box.update(
                    minExtents: SCNVector3Zero, maxExtents: SCNVector3Zero)
                box.isHidden = false
                startPosition = nil
                distance = 0.0
                setStatusText()
            }
        }
    }
    
    func setStatusText() {
        var text = ""
        if status == "NOT READY" {
            text += "1. Find a well lit area. \n 2. Position phone directly above your rash \n 3. Move side to side to initialize measuring."
        }
        if status == "READY" && mode == .waitingForMeasuring {
            
            text += "Width \n Measure the widest part of the rash, and tap Start to begin measuring. \n"
            // "take a second measurement that is perpendicular to the first measurement"
        }
        if mode == .measuring {
            if diameterCount == 0 {
                text += "Measure the widest part of the rash \n tap Stop to finish \n"
            } else {
                text += "Measure the tallest part of the rash \n tap Stop to finish \n"
            }
            text += "\(String(format:"%.2f cm", distance! * 100.0))"
        }
        if mode == .waitingForMeasuring && distance > 0.0 {
            text = steps
            if diameter1 != 0.0 {
                text += "\n width: \(String(format:"%.2f cm", diameter1! * 100.0))"
                if diameter2 != 0.0 {
                    text += "  height: \(String(format:"%.2f cm", diameter2! * 100.0))"
                }
            }
//            text += "\n Diameter: \(String(format:"%.2f cm", distance! * 100.0))"
        }
        
//        var text = "Status: \(status!)\n"
//        text += "Tracking: \(getTrackigDescription())\n"
//        text += "Distance: \(String(format:"%.2f cm", distance! * 100.0))"
//        text += steps
        statusTextView.text = text
    }
    
    func getTrackigDescription() -> String {
        var description = ""
        if let t = trackingState {
            switch(t) {
            case .notAvailable:
                description = "Initializing"
            case .normal:
                description = "Ready to Measure"
            case .limited(let reason):
                switch reason {
                    case .excessiveMotion:
                        description = "Too much camera movement"
                    case .insufficientFeatures:
                        description = "Not enough surface detail"
                    case .initializing:
                        description = "Initializing"
                    case .relocalizing:
                        description = "relocalizing"
                    }
            }
        }
        
        return description
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set the view's delegate
        sceneView.delegate = self
        
//        statusTextView.layer.cornerRadius = 15.0
        
        // Set a padding in the text view
        // statusTextView.textContainerInset = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        statusTextView.textAlignment = .center
        
        // Instantiate the box and add it to the scene
        box = Box()
        box.isHidden = true;
        sceneView.scene.rootNode.addChildNode(box)
        
        // Set the initial mode
        mode = .waitingForMeasuring
        
        // Set the initial distance
        distance = 0.0
        
        // Initialize instruction string
        steps = ""
        
        // Display the initial status
        setStatusText()
        
        
//      display initial instruction
//        let alert = UIAlertController(title: "Instructions",
//                                      message: "1. Find a well lit area, move around the surface to initialize measuring.  
//\n 2. Once it's ready to measure, [toggle switch to start measuring from ] 
//\n 3. Move rash inside the frame and take an up-close photo of the rash (4 inches away) \n 4. Take an overview photo of the rash (12 inches away)", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        
        // initialize shotCount and measurecount
        shotCount = 0
        measureCount = 1
        
        // hide shutter button and continue button by default
        continueButton.isHidden = true
        shutterButton.isHidden = true
        
        diameterCount = 0
        width_height = "widest"
        diameter1 = 0.0
        diameter2 = 0.0
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration with plane detection
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        trackingState = camera.trackingState
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Call the method asynchronously to perform
        //  this heavy task without slowing down the UI
        DispatchQueue.main.async {
            self.measure(time: time)
        }
    }
    
    func measure(time: TimeInterval) {
        let screenCenter : CGPoint = CGPoint(x: self.sceneView.bounds.midX, y: self.sceneView.bounds.midY)
        let planeTestResults = sceneView.hitTest(screenCenter, types: [.existingPlaneUsingExtent])
        if let result = planeTestResults.first {
            status = "READY"
            
            if mode == .measuring {
                status = "MEASURING"
                let worldPosition = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
                
                if startPosition == nil {
                    startPosition = worldPosition
                    box.position = worldPosition
                }
                
                distance = calculateDistance(from: startPosition!, to: worldPosition)
                box.resizeTo(extent: distance)
                
                let angleInRadians = calculateAngleInRadians(from: startPosition!, to: worldPosition)
                box.rotation = SCNVector4(x: 0, y: 1, z: 0, w: -(angleInRadians + Float.pi))
            }
        } else {
            status = "NOT READY"
        }
        setStatusText()
    }
    
    func calculateDistance(from: SCNVector3, to: SCNVector3) -> Float {
        let x = from.x - to.x
        let y = from.y - to.y
        let z = from.z - to.z
        
        return sqrtf( (x * x) + (y * y) + (z * z))
    }
    
    func calculateAngleInRadians(from: SCNVector3, to: SCNVector3) -> Float {
        let x = from.x - to.x
        let z = from.z - to.z
        
        return atan2(z, x)
    }
    
    // shutterbutton
    // give haptic feedback
    // remove line from view
    // save photo
    // update instruction
    @IBAction func takeShot(_ sender: Any) {
        impact.impactOccurred()
        if shotCount == 0 {
            shotCount += 1
            box.isHidden = true
            closeup = sceneView.snapshot()
//            shotCount += 1
//            closeup = sceneView.snapshot()
//            let alert = UIAlertController(title: "Close-up Shot Taken!",
//                                          message: "Move camera further away to take an over shot", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            steps = "Show us where the rash is \n Take an overview photo, with rash in the center"
            setStatusText()
        } else {
            shotCount += 1
            overview = sceneView.snapshot()
//            shotCount += 1
//            overview = sceneView.snapshot()
//            let alert = UIAlertController(title: "Overview Shot Taken!",
//                                          message: "Tap Details to Continue",
//                                          preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            continueButton.isHidden = false
            steps = "Tap Continue to fill up datails"
            setStatusText()
        }
    }
    
    @IBAction func resetButton(_ sender: Any) {
        startButton.isHidden = false
        continueButton.isHidden = true
        mode = .waitingForMeasuring
        box.isHidden = false
        center.isHidden = false
        distance = 0.0
        measureCount = 1
        mode = .waitingForMeasuring
        setStatusText()
        diameterCount = 0
        diameter1 = 0.0
        diameter2 = 0.0
        
        
    }
    
    // pass images to next viewcontroller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        impact.impactOccurred()
        if let destinationViewController = segue.destination as? DetailsController {
            destinationViewController.close_up = closeup
            destinationViewController.overview = overview
            destinationViewController.diameter = diameter1
            destinationViewController.diameter2 = diameter2
            destinationViewController.diaString = "Size: \(String(format:"%.2f cm", diameter1! * 100.0)) x \(String(format:"%.2f cm", diameter2! * 100.0))"
        }
    }
}

