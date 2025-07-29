//
//  ARSceneView.swift
//  ObjectAnchor
//
//  Created by Atul Vasudev A on 03/02/25.
//

import Foundation
import ARKit
import ObjectDetectionFramework

actor ARSceneView: NSObject, ARSessionDelegate, ObservableObject, ObjectAnchor.ObjectAnchorDelegate{

    @MainActor let sceneView = ARSCNView()
    @MainActor let objectAnchorHelper = ObjectAnchor()
    @MainActor let detectedNode = SCNNode()
    @MainActor let scenePointCloudNode = SCNNode()
    @MainActor let detectedPointCloudNode = SCNNode()
    @MainActor var savePCDFile = false
    
    @MainActor
    override init() {
        super.init()
        
        sceneView.session.delegate = self

        // start session
        let configuration = ARWorldTrackingConfiguration()
        configuration.frameSemantics = .sceneDepth
        sceneView.session.run(configuration)
        sceneView.scene.rootNode.addChildNode(detectedNode)
        sceneView.scene.rootNode.addChildNode(detectedPointCloudNode)
        sceneView.scene.rootNode.addChildNode(scenePointCloudNode)
        createOriginAxis()
        
        objectAnchorHelper.objectAnchorDelegate = self
    }
    
    // an ARSessionDelegate function for receiving an ARFrame instances
    nonisolated func session(_ session: ARSession, didUpdate frame: ARFrame) {
        objectAnchorHelper.processFrame(frame: frame)
    }
    
    nonisolated func onInitialized() {
        objectAnchorHelper.setDetectionConfig(detectionType: ObjectAnchor.DetectionType.POINTCLOUD, modelId: "modelId", token: "token")
        objectAnchorHelper.startScan()
    }
    
    nonisolated func onObjectPointsUpdated(points: [SCNVector3]?) {
        print("onObjectPointsFound")
        Task { @MainActor in
            await drawDetectedPointCloud(pointCloud: points)
        }
    }
    
    nonisolated func onScenePointsUpdated(points: [SCNVector3]?) {
        print("onScenePointsUpdated")
        Task { @MainActor in
            await drawScenePointCloud(pointCloud: points)
        }
    }
    
    nonisolated func onObjectTransformationUpdated(transformation: [Float]?) {
        print("onObjectTransformationUpdated")
        let pos = objectAnchorHelper.getPosition(transformation: transformation)
        let rot = objectAnchorHelper.getRotation(transformation: transformation)
        detectedNode.worldPosition = pos
        detectedNode.worldOrientation = rot
    }
    
    nonisolated func onStatusUpdated(status: String?) {
        print(status)
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
                if(savePCDFile){
                    savePCDFile = false
                    await saveSceneAsPCD(from: pointCloud!)
                }
            }
        }
    }
    
    func saveSceneAsPCD(from points: [SCNVector3]){
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent("template")
            writePCDFile(from: points, to: fileURL)
        } catch {
            print(error)
        }
    }
    
    func writePCDFile(from points: [SCNVector3], to fileURL: URL) {
        // Header for PCD file (ASCII format)
        var pcdHeader = "# .PCD v0.7 - Point Cloud Data file format\n"
        pcdHeader += "VERSION 0.7\n"
        pcdHeader += "FIELDS x y z\n"
        pcdHeader += "SIZE 4 4 4\n"
        pcdHeader += "TYPE F F F\n"
        pcdHeader += "COUNT 1 1 1\n"
        pcdHeader += "WIDTH \(points.count)\n"
        pcdHeader += "HEIGHT 1\n"
        pcdHeader += "VIEWPOINT 0 0 0 1 0 0 0\n"
        pcdHeader += "POINTS \(points.count)\n"
        pcdHeader += "DATA ascii\n"
        
        // Convert SCNVector3 points into ASCII format
        var pcdPoints = ""
        for point in points {
            pcdPoints += "\(point.x) \(point.y) \(point.z)\n"
        }

        // Combine header and point data
        let pcdContent = pcdHeader + pcdPoints
        
        do {
            // Write to file
            try pcdContent.write(to: fileURL, atomically: true, encoding: .utf8)
            print("PCD file saved to \(fileURL.path)")
        } catch {
            print("Failed to save PCD file: \(error)")
        }
    }

    
}

