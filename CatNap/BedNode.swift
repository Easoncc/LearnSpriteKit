//
//  BedNode.swift
//  CatNap
//
//  Created by chenchao on 2019/2/12.
//  Copyright © 2019 chenchao. All rights reserved.
//

import UIKit
import SpriteKit

class BedNode: SKSpriteNode, EventListenerNode {
    
    func didMoveToScene() {
        print("bed added to scene")
        
        let bedBodySize = CGSize(width: 40.0, height: 30.0)
        physicsBody = SKPhysicsBody(rectangleOf: bedBodySize)
        physicsBody!.isDynamic = false
        
        physicsBody!.categoryBitMask = PhysicsCategory.Bed
        physicsBody!.collisionBitMask = PhysicsCategory.None
    }

}
