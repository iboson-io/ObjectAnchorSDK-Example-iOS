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
    @MainActor let scenePointCloudNode = SCNNode()
    @MainActor let detectedPointCloudNode = SCNNode()
    @Published var statusText : String = "status"
    
    let modelId  = "" //Add modelId from noxvision.ai
    let apiKey  = "" //Add API key from noxvision.ai
    
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
        sceneView.scene.rootNode.addChildNode(detectedPointCloudNode)
        sceneView.scene.rootNode.addChildNode(scenePointCloudNode)
        createOriginAxis()
        
        objectAnchorHelper.objectAnchorDelegate = self
    }
    
    // an ARSessionDelegate function for receiving an ARFrame instances
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        Task { @MainActor in
            objectAnchorHelper.processFrame(frame: frame)
        }
    }
    
    nonisolated func onInitialized() {
        Task { @MainActor in
            objectAnchorHelper.setDetectionConfig(detectionType: ObjectAnchor.DetectionType.POINTCLOUD, modelId: modelId, token: apiKey)
            objectAnchorHelper.startScan()
        }
    }
    
    nonisolated func onObjectTransformationUpdated(transformation: [Float]?) {
        print("onObjectTransformationUpdated")
        Task { @MainActor in
            let pos = objectAnchorHelper.getPosition(transformation: transformation)
            let rot = objectAnchorHelper.getRotation(transformation: transformation)
            detectedNode.worldPosition = pos
            detectedNode.worldOrientation = rot
        }
    }
    
    nonisolated func onStatusUpdated(status: String?) {
        if let statusInfo = status{
            print("status \(statusInfo)")
            Task { @MainActor in
                self.statusText = statusInfo
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
    
    func drawDetectedPointCloud(pointCloud : [SCNVector3]?) {
        
        if(pointCloud != nil && pointCloud!.count > 0){
            
            // create a vertex source for geometry
            let vertexSource = SCNGeometrySource(vertices: pointCloud! )
            
            // as we don't use proper geometry, we can pass just an array of
            // indices to our geometry element
            let pointIndices: [UInt32] = Array(0..<UInt32(pointCloud!.count))
            let element = SCNGeometryElement(indices: pointIndices, primitiveType: .point)
            
            // here we can customize the size of the point, rendered in ARView
            element.maximumPointScreenSpaceRadius = 10
            
            let geometry = SCNGeometry(sources: [vertexSource],
                                       elements: [element])
            geometry.firstMaterial?.isDoubleSided = true
            geometry.firstMaterial?.lightingModel = .constant
            geometry.firstMaterial?.diffuse.contents = UIColor.green
            
            Task { @MainActor in
                detectedPointCloudNode.geometry = geometry
                print("Detected Points updated \(pointCloud?.count)")
            }
        }
    }
    
    func drawScenePointCloud(pointCloud : [SCNVector3]?) {
        
        if(pointCloud != nil && pointCloud!.count > 0){
            
            // create a vertex source for geometry
            let vertexSource = SCNGeometrySource(vertices: pointCloud! )
            
            // as we don't use proper geometry, we can pass just an array of
            // indices to our geometry element
            let pointIndices: [UInt32] = Array(0..<UInt32(pointCloud!.count))
            let element = SCNGeometryElement(indices: pointIndices, primitiveType: .point)
            
            // here we can customize the size of the point, rendered in ARView
            element.maximumPointScreenSpaceRadius = 10
            
            let geometry = SCNGeometry(sources: [vertexSource],
                                       elements: [element])
            geometry.firstMaterial?.isDoubleSided = true
            geometry.firstMaterial?.lightingModel = .constant
            geometry.firstMaterial?.diffuse.contents = UIColor.yellow
            
            Task { @MainActor in
                scenePointCloudNode.geometry = geometry
                print("Scene Points updated \(pointCloud?.count)")
            }
        }
    }

    
}

