//
//  ZombieScene.swift
//  mygame
//
//  Created by chenchao on 2019/1/14.
//  Copyright © 2019 chenchao. All rights reserved.
//

import UIKit
import SpriteKit

class ZombieScene: SKScene {

    
    override func didMove(to view: SKView) {
        
        let backGround = SKSpriteNode(imageNamed: "background1")
        backGround.position = CGPoint(x: size.width/2, y: size.height/2)
        backGround.zPosition = -1
        addChild(backGround)
        
        let zombie1 = SKSpriteNode(imageNamed: "zombie1")
        zombie1.position = CGPoint(x: 400, y: 500)
        zombie1.zPosition = 1
        addChild(zombie1)
        
    }
}
