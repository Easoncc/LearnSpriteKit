//
//  ViewController.swift
//  mygame
//
//  Created by chenchao on 2019/1/10.
//  Copyright © 2019 chenchao. All rights reserved.
//

import UIKit
import SpriteKit
//import GameplayKit

class ViewController: UIViewController {

    var scene: SKScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let skView: SKView = self.view as? SKView {
//            scene = myScene(size: skView.frame.size)

            scene = gameScene(size: CGSize(width: 2048, height: 1536))
            scene?.scaleMode = .aspectFill
            skView.presentScene(scene)
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
        }
    }
}

