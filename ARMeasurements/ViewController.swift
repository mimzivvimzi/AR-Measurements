//
//  ViewController.swift
//  ARMeasurements
//
//  Created by Michelle Lau on 2020/08/17.
//  Copyright © 2020 Michelle Lau. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var pointNodes = [SCNNode]()
    var measurementNode = SCNNode()
    let testColor = UIColor(red: 29, green: 141, blue: 182, alpha: 0.9)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // TOUCH DETECTED
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if pointNodes.count >= 2 {
            for point in pointNodes {
                point.removeFromParentNode()
            }
            pointNodes = [SCNNode]()
        }
        if let touchedArea = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchedArea, types: .featurePoint)
            if let hitResult = hitTestResults.first {
                displayPoint(at: hitResult)
            }
        }
    }
    
    func displayPoint(at hitResult: ARHitTestResult) {
        let sphere = SCNSphere(radius: 0.003)
        let material = SCNMaterial()
        material.diffuse.contents = testColor
        sphere.materials = [material]
        
        let pointNode = SCNNode(geometry: sphere)
        pointNode.position = SCNVector3(
            x: hitResult.worldTransform.columns.3.x,
            y: hitResult.worldTransform.columns.3.y,
            z: hitResult.worldTransform.columns.3.z
        )
        sceneView.scene.rootNode.addChildNode(pointNode)
        pointNodes.append(pointNode)
        if pointNodes.count >= 2 {
            measure()
        }
    }
    
    func measure() {
        let start = pointNodes[0]
        let end = pointNodes[1]
        print(start.position)
        print(end.position)
        let a = end.position.x - start.position.x
        let b = end.position.y - start.position.y
        let c = end.position.z - start.position.z
        let distance = sqrt(pow(a, 2)+pow(b, 2)+pow(c, 2))
        displayText(text: "\(abs(distance))", atPosition: end.position)
    }
    
    func displayText(text: String, atPosition position: SCNVector3) {
        measurementNode.removeFromParentNode()
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = testColor
        measurementNode = SCNNode(geometry: textGeometry)
        measurementNode.position = SCNVector3(position.x, position.y+0.01, position.z)
        measurementNode.scale = SCNVector3(0.01, 0.01, 0.01)
        sceneView.scene.rootNode.addChildNode(measurementNode)
    }
}
