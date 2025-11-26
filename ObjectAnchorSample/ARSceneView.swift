//
//  ARSceneView.swift
//  ObjectAnchor
//
//  Created by Atul Vasudev A on 03/02/25.
//

import Foundation
import ARKit
import ObjectDetectionFramework

class ARSceneView: NSObject, ARSessionDelegate, ObservableObject, ObjectAnchor.ObjectAnchorDelegate{

    @MainActor let sceneView = ARSCNView()
    @MainActor let objectAnchorHelper = ObjectAnchor()
    @MainActor let detectedNode = SCNNode()
    @Published var statusText : String = ""
    @Published var isScanning : Bool = false
    
    let modelId  = "" //Add modelId from noxvision.ai
    let apiKey  = "" //Add API key from noxvision.ai
    
    var step : Int = 1
    
    @MainActor
    override init() {
        super.init()
        
        sceneView.session.delegate = self

        // start session
        let configuration = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics = .sceneDepth
        } else {
            configuration.planeDetection = [.horizontal, .vertical]
        }
        sceneView.session.run(configuration)
        sceneView.scene.rootNode.addChildNode(detectedNode)
        createOriginAxis()
        detectedNode.isHidden = true
        
        objectAnchorHelper.objectAnchorDelegate = self
    }
    
    // an ARSessionDelegate function for receiving an ARFrame instances
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        Task { @MainActor in
            objectAnchorHelper.processFrame(frame: frame)
        }
    }
    
    public func startScan(){
        Task { @MainActor in
            objectAnchorHelper.startScan()
            isScanning = true
            statusText = "Scanning..."
        }
    }
    
    nonisolated func onInitialized() {
        Task { @MainActor in
            objectAnchorHelper.setDetectionConfig(modelId: modelId, token: apiKey)
        }
    }
    
    nonisolated func onDetected(transformation: [Float]?) {
        print("onDetected")
        Task { @MainActor in
            isScanning = false
            statusText = "Detected"
            let pos = objectAnchorHelper.getPosition(transformation: transformation)
            let rot = objectAnchorHelper.getRotation(transformation: transformation)
            detectedNode.worldPosition = pos
            detectedNode.worldOrientation = rot
            detectedNode.isHidden = false
        }
    }
    
    nonisolated func onFailed(error: String?) {
        if let errorInfo = error{
            print("\(errorInfo)")
            Task { @MainActor in
                isScanning = false
                statusText = errorInfo
                self.statusText = errorInfo
            }
        }
    }
    
    
    @MainActor
    func createOriginAxis(){
        let xNode = SCNNode()
        let yNode = SCNNode()
        let zNode = SCNNode()
        detectedNode.addChildNode(xNode)
        detectedNode.addChildNode(yNode)
        detectedNode.addChildNode(zNode)
        
        let xCubeGeometry = SCNBox(width: 0.2, height: 0.02, length: 0.02, chamferRadius: 0.0)
        let yCubeGeometry = SCNBox(width: 0.02, height: 0.2, length: 0.02, chamferRadius: 0.0)
        let zCubeGeometry = SCNBox(width: 0.02, height: 0.02, length: 0.2, chamferRadius: 0.0)
        xNode.geometry = xCubeGeometry
        yNode.geometry = yCubeGeometry
        zNode.geometry = zCubeGeometry
        xNode.position = SCNVector3(0.1, 0, 0)
        yNode.position = SCNVector3(0, 0.1, 0)
        zNode.position = SCNVector3(0, 0, 0.1)
        xCubeGeometry.firstMaterial?.diffuse.contents = UIColor.red
        yCubeGeometry.firstMaterial?.diffuse.contents = UIColor.green
        zCubeGeometry.firstMaterial?.diffuse.contents = UIColor.blue
    }

    
}

