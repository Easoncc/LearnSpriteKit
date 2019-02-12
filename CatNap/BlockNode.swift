//
//  BlockNode.swift
//  CatNap
//
//  Created by chenchao on 2019/2/12.
//  Copyright © 2019 chenchao. All rights reserved.
//

import UIKit
import SpriteKit

class BlockNode: SKSpriteNode, EventListenerNode, InteractiveNode {

    func didMoveToScene() {
        isUserInteractionEnabled = true
    }
    
    func interact() {
        isUserInteractionEnabled = false
        
        run(SKAction.sequence([
            SKAction.playSoundFileNamed("pop.mp3",
                                        waitForCompletion: false),
            SKAction.scale(to: 0.8, duration: 0.1),
            SKAction.removeFromParent()
            ]))
    }

    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        print("destroy block")
        interact()
    }
}
