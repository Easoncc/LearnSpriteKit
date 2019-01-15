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

    var zombie1: SKSpriteNode!
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let playableRect: CGRect
    
    override init(size: CGSize) {
        
        let maxAspectRatio = UIScreen.main.bounds.size.width/UIScreen.main.bounds.size.height
        let playableHeight = size.width/maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        let backGround = SKSpriteNode(imageNamed: "background1")
        backGround.position = CGPoint(x: size.width/2, y: size.height/2)
        backGround.zPosition = -1
        addChild(backGround)
        
        zombie1 = SKSpriteNode(imageNamed: "zombie1")
        zombie1.position = CGPoint(x: 400, y: 500)
        zombie1.zPosition = 1
        addChild(zombie1)
        
        debugDrawPlayableArea()
        
        spawnEnemy()
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: size.width - enemy.size.width/2, y: size.height/2)
        addChild(enemy)
        
        // 1
        
        let actionMidMove = SKAction.moveBy(x: -size.width/2-enemy.size.width/2, y: -playableRect.height/2 + enemy.size.height/2, duration: 1)
        
        // 2
        let actionMove = SKAction.moveBy(
            x: -size.width/2-enemy.size.width/2,
            y: playableRect.height/2 - enemy.size.height/2,
            duration: 1.0)
        
        let logMessage = SKAction.run {
            print("Reached bottom!")
        }
        
        let waitAction = SKAction.wait(forDuration: 2)
        
        let reverseMid = actionMidMove.reversed()
        let reverseMove = actionMove.reversed()
        
        // 3
        let sequence = SKAction.sequence([waitAction, actionMidMove, logMessage, waitAction, actionMove, reverseMove, logMessage, waitAction, reverseMid])
        
        // 4
        enemy.run(SKAction.repeatForever(sequence))
    }
    
    override func update(_ currentTime: TimeInterval) {
//        zombie1.position = CGPoint(x: zombie1.position.x+8, y: zombie1.position.y)
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        move(sprite: zombie1, velocity: velocity)
        rotate(sprite: zombie1, direction: velocity)
        boundsCheckZombie()
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
        //        print("Amount to move: \(amountToMove)")
    }
    
    func moveZombieToward(location: CGPoint) {
        let offset = location - zombie1.position
        let length = offset.length()
        let direction = offset / CGFloat(length)
        velocity = direction * zombieMovePointsPerSec
    }
    
    func rotate(sprite: SKSpriteNode, direction: CGPoint) {
        sprite.zRotation = direction.angle
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        moveZombieToward(location: touchLocation)
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0, y: playableRect.minY)
        let topRight = CGPoint(x: size.width, y: playableRect.maxY)
        if zombie1.position.x <= bottomLeft.x {
            zombie1.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie1.position.x >= topRight.x {
            zombie1.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie1.position.y <= bottomLeft.y {
            zombie1.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie1.position.y >= topRight.y {
            zombie1.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
}

extension ZombieScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touche = touches.first else {
            return
        }
        
        sceneTouched(touchLocation: touche.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        sceneTouched(touchLocation: touchLocation)
    }
}
