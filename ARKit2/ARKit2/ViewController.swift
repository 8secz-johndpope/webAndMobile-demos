//
//  ViewController.swift
//  ARPosterDemo
//
//  Created by Daniel Klein on 06.03.18.
//  Copyright © 2018 House of Bytes Software. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class 2DTrackingViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet var sceneView: ARSCNView!
    
    let sceneKitQueue = DispatchQueue(label: "SceneKitQueue")
    
    let images: [UIImage] = [
        UIImage(named: "Bonn leuchtet 1")!,
        UIImage(named: "Bonn leuchtet 2")!,
        UIImage(named: "Bonn leuchtet 3")!,
        UIImage(named: "Bonn leuchtet 4")!,
        UIImage(named: "Bonn leuchtet 5")!,
        UIImage(named: "Bonn leuchtet 6")!,
        UIImage(named: "Bonn leuchtet 7")!,
        UIImage(named: "Bonn leuchtet 8")!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = ARReferenceImage.referenceImages(inGroupNamed: "Posters", bundle: nil)!
        configuration.maximumNumberOfTrackedImages = 1
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let posterSize = imageAnchor.referenceImage.physicalSize
        
        self.sceneKitQueue.async {
            let videoPlane = SCNPlane(width: posterSize.width, height: posterSize.height)
            let videoPlayer = self.createVideoPlayer()
            videoPlane.firstMaterial!.diffuse.contents = videoPlayer
            videoPlayer.play()

            let videoNode = SCNNode(geometry: videoPlane)
            videoNode.eulerAngles.x = -.pi / 2
            
            node.addChildNode(videoNode)
        }
    }
    
    private func createVideoPlayer() -> AVPlayer {
        let url = Bundle.main.url(forResource: "Video", withExtension: "mp4")!
        let player = AVPlayer(url: url)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: OperationQueue.main) { _ in
            player.seek(to: CMTime.zero)
            player.play()
        }
        
        return player
    }
}
