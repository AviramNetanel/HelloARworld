//
//  ViewController.swift
//  HelloARworld
//
//  Created by Aviram on 5/2/23.
//

import UIKit
import SceneKit
import ARKit

enum BodyType : Int {
    case object = 1
    case plane = 2
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var planes = [OverlayPlane]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSceneView()
    
        //Text
        self.sceneView.scene.rootNode.addChildNode(createText("Hello World!"))
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
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
    
    func setupSceneView(){
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //Debug options:
//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        // Set the scene to the view
        sceneView.scene = SCNScene()
    }
    
    
    //creates a sphere on a plane tap
    @objc func tapped(recognizer: UIGestureRecognizer){
        let sceneView = recognizer.view as! ARSCNView
        let touchLocation = recognizer.location(in: sceneView)
        
        guard let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .any) else {
           return
        }
                
        let results = sceneView.session.raycast(query)
        guard let hitTestResult = results.first else {
           return
        }
        
        let hitColums = hitTestResult.worldTransform.columns
        
        let vector = SCNVector3(hitColums.3.x, hitColums.3.y + 1.5,  hitColums.3.z)
        
        _ = createEarth(position: vector)
        
    }
    
    
    //Create a Text:
    func createText(_ text: String) -> SCNNode{
        let textSCN = SCNText(string: text, extrusionDepth: 1.0)
        textSCN.firstMaterial?.diffuse.contents = UIColor.blue
        let textNode = SCNNode(geometry: textSCN)
        textNode.position = SCNVector3(-0.5, 0.25, -3)
        textNode.scale = SCNVector3(0.02,0.02,0.02)
        textNode.name = "TextNode"
        return textNode
    }
    
    
    //Create an earth sphere:
    func createEarth(position: SCNVector3 = SCNVector3(x: 0, y: 0, z: -1)) -> SCNNode{
        let sphere = SCNSphere(radius: 0.15)
        sphere.firstMaterial?.diffuse.contents = UIImage(named: "earth")
        sphere.firstMaterial?.name = "earth"
        
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = position
        sphereNode.scale = SCNVector3(1, 1, 1)
        sphereNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: .init(geometry: sphere))

        self.sceneView.scene.rootNode.addChildNode(sphereNode)
        return sphereNode
    }
        
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard (anchor is ARPlaneAnchor) else{ return }
        
        let plane = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
        self.planes.append(plane)
        node.addChildNode(plane)
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        let plane = self.planes.filter { plane in
            return plane.anchor.identifier == anchor.identifier
            }.first
        
        if plane == nil {
            return
        }
        
        plane?.update(anchor: anchor as! ARPlaneAnchor)
    }


}//class
