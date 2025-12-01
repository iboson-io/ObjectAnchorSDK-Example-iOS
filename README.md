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
        objectAnchorHelper.setDetectionConfig(modelId: modelId, token: apiKey)
    }
    
    func onDetected(transformation: [Float]?) {
        
    }

    func onFailed(error: String?) {

    }

    //Call startScan from a button click
    public func startScan(){
        objectAnchorHelper.startScan()
    }
```
