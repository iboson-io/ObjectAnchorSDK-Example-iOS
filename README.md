# Object Anchor SDK - iOS
- Drag and drop ObjectAnchorFramework.framework to your XCode project
```
import ARKit
import ObjectDetectionFramework
```

- Add the delegate methods
```
ARSessionDelegate, ObjectAnchor.ObjectAnchorDelegate
```

- Implement the functions of delegate 
```
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        objectAnchorHelper.processFrame(frame: frame)
    }

    func onInitialized(){
        // Fill the modelId and apiKey from https://noxvision.ai
        objectAnchorHelper.setDetectionConfig(detectionType: ObjectAnchor.DetectionType.POINTCLOUD, modelId: modelId, token: apiKey)
        objectAnchorHelper.startScan()
    }
    
    func onScenePointsUpdated(points: [SCNVector3]?) {
       
    }
    
    func onObjectPointsUpdated(objectPoints: [SCNVector3]?) {
        
    }
    
    func onObjectTransformationUpdated(transformation: [Float]?) {
        
    }

    func onStatusUpdated(status: String?) {

    }
```
