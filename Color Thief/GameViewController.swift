

//
//  GameViewController.swift
//  Color Thief
//
//  Created by Akash Kumar on 19/09/26.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    private var hasPresentedScene = false
    
    // Present after layout so the scene sees real safeAreaInsets (they're zero in viewDidLoad).
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !hasPresentedScene else { return }
        hasPresentedScene = true
        
        let scene = SplashScene(size: view.bounds.size)
        scene.scaleMode = .aspectFill
        
        let skView = view as! SKView
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
    }
}

//
//import UIKit
//import SpriteKit
//import GameplayKit
//
//class GameViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        if let view = self.view as! SKView? {
//            // Load the SKScene from 'GameScene.sks'
//            if let scene = SKScene(fileNamed: "GameScene") {
//                // Set the scale mode to scale to fit the window
//                scene.scaleMode = .aspectFill
//                
//                // Present the scene
//                view.presentScene(scene)
//            }
//            
//            view.ignoresSiblingOrder = true
//            
//            view.showsFPS = true
//            view.showsNodeCount = true
//        }
//    }
//
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            return .allButUpsideDown
//        } else {
//            return .all
//        }
//    }
//
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
//}
