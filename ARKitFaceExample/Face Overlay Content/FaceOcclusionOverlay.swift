/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Demonstrates how to simulate occlusion of virtual content by the real-world face.
*/

import ARKit
import SceneKit

class FaceOcclusionOverlay: NSObject, VirtualContentController {
    
    var contentNode: SCNNode?
    
    var occlusionNode: SCNNode!
    
    /// - Tag: OcclusionMaterial
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let sceneView = renderer as? ARSCNView,
            anchor is ARFaceAnchor else { return nil }

        #if targetEnvironment(simulator)
        #error("ARKit is not supported in iOS Simulator. Connect a physical iOS device and select it as your Xcode run destination, or select Generic iOS Device as a build-only destination.")
        #else
        /*
         Write depth but not color and render before other objects.
         This causes the geometry to occlude other SceneKit content
         while showing the camera view beneath, creating the illusion
         that real-world objects are obscuring virtual 3D objects.
         */
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)!
        faceGeometry.firstMaterial!.colorBufferWriteMask = []
        occlusionNode = SCNNode(geometry: faceGeometry)
        occlusionNode.renderingOrder = 1

        // Add 3D asset positioned to appear as "glasses".
        
        let newoverlay = SCNPlane(width: 0.5, height: 0.5)
        let timTesture = SCNMaterial()
        timTesture.diffuse.contents = UIImage(named: "BigTim")
        newoverlay.firstMaterial = timTesture
        let newOverlayNode = SCNNode(geometry: newoverlay)
        
        
       // let faceOverlayContent = SCNReferenceNode(named: "overlayModel")

        contentNode = SCNNode()
        contentNode!.addChildNode(occlusionNode)
        contentNode!.addChildNode(newOverlayNode)
        #endif
        return contentNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceGeometry = occlusionNode.geometry as? ARSCNFaceGeometry,
            let faceAnchor = anchor as? ARFaceAnchor
            else { return }
        
        faceGeometry.update(from: faceAnchor.geometry)
    }

}
