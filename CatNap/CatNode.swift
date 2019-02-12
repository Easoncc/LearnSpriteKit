//
//  CatNode.swift
//  CatNap
//
//  Created by chenchao on 2019/2/12.
//  Copyright © 2019 chenchao. All rights reserved.
//

import UIKit
import SpriteKit

class CatNode: SKSpriteNode, EventListenerNode {
    
    func didMoveToScene() {
        print("cat added to scene")
        let catBodyTexture = SKTexture(imageNamed: "cat_body_outline")
        parent!.physicsBody = SKPhysicsBody(texture: catBodyTexture,
                                            size: catBodyTexture.size())
        parent!.physicsBody!.categoryBitMask = PhysicsCategory.Cat
        parent!.physicsBody!.contactTestBitMask = PhysicsCategory.Bed
            | PhysicsCategory.Edge
        parent!.physicsBody!.collisionBitMask = PhysicsCategory.Block
            | PhysicsCategory.Edge
    }
    
    func wakeUp() {
        // 1
        for child in children {
            child.removeFromParent()
        }
        texture = nil
        color = SKColor.clear
        // 2
        
        if let CatWakeUp = SKSpriteNode(fileNamed:
            "CatWakeUp"), let catAwake = CatWakeUp.childNode(withName: "cat_awake") {
            catAwake.move(toParent: self)
            catAwake.position = CGPoint(x: -30, y: 100)
        }
    }
    
    func curlAt(scenePoint: CGPoint) {
        parent!.physicsBody = nil
        for child in children {
            child.removeFromParent()
        }
        texture = nil
        color = SKColor.clear
        let catCurl = SKSpriteNode(fileNamed: "CatCurl")!.childNode(withName:
            "cat_curl")!
        catCurl.move(toParent: self)
        catCurl.position = CGPoint(x: -30, y: 100)
        
        var localPoint = parent!.convert(scenePoint, from: scene!)
        localPoint.y += frame.size.height/3
        
        run(SKAction.group([
            SKAction.move(to: localPoint, duration: 0.66),
            SKAction.rotate(toAngle: -parent!.zRotation, duration: 0.5)
            ]))
    }
}
