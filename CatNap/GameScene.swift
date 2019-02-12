//
//  GameScene.swift
//  CatNap
//
//  Created by 陈超 on 2019/1/26.
//  Copyright © 2019 chenchao. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None:  UInt32 = 0
    static let Cat:   UInt32 = 0b1 // 1
    static let Block: UInt32 = 0b10 // 2
    static let Bed:   UInt32 = 0b100 // 4
    static let Edge:  UInt32 = 0b1000 // 8
    static let Label: UInt32 = 0b10000 // 16
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var playable = true
    var bedNode: BedNode!
    var catNode: CatNode!
    
    override func didMove(to view: SKView) {
        
        // Get label node from scene and store it for use later
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let maxAspectRatioHeight = size.width / maxAspectRatio
        let playableMargin: CGFloat = (size.height
            - maxAspectRatioHeight)/2
        let playableRect = CGRect(x: 0, y: playableMargin,
                                  width: size.width, height: size.height-playableMargin*2)
        physicsBody = SKPhysicsBody(edgeLoopFrom: playableRect)
        physicsWorld.contactDelegate = self
        physicsBody!.categoryBitMask = PhysicsCategory.Edge
        
        enumerateChildNodes(withName: "//*", using: { node, _ in
            if let eventListenerNode = node as? EventListenerNode {
                eventListenerNode.didMoveToScene()
            }
        })
        
        bedNode = childNode(withName: "bed") as? BedNode
        catNode = childNode(withName: "//cat_body") as? CatNode
        
        SKTAudio.sharedInstance()
            .playBackgroundMusic("backgroundMusic.mp3")
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask
            | contact.bodyB.categoryBitMask
        if collision == PhysicsCategory.Cat | PhysicsCategory.Bed {
            win()
            catNode.curlAt(scenePoint: bedNode.position)
        } else if collision == PhysicsCategory.Cat
            | PhysicsCategory.Edge {
            if !playable {
                return
            }
            playable = false
            lose()
            catNode.wakeUp()
        }
    }
    
    func inGameMessage(text: String) {
        let message = MessageNode(message: text)
        message.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(message)
    }
    
    @objc func newGame() {
        let scene = GameScene(fileNamed:"GameScene")
        scene!.scaleMode = scaleMode
        view!.presentScene(scene)
    }
    
    func lose() {
        //1
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        SKTAudio.sharedInstance().playSoundEffect("lose.mp3")
        //2
        inGameMessage(text: "Try again...")
        //3
        perform(#selector(newGame), with: nil, afterDelay: 5)
    }

    func win() {
        playable = false
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        SKTAudio.sharedInstance().playSoundEffect("win.mp3")
        inGameMessage(text: "Nice job!")
        perform(#selector(GameScene.newGame), with: nil,
                afterDelay: 3)
    }
}

protocol EventListenerNode {
    func didMoveToScene()
}

protocol InteractiveNode {
    func interact()
}
