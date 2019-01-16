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
    let zombieAnimation: SKAction!
    
    override init(size: CGSize) {
        
        let maxAspectRatio = UIScreen.main.bounds.size.width/UIScreen.main.bounds.size.height
        let playableHeight = size.width/maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        // 1
        var textures:[SKTexture] = []
        // 2
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        // 3
        textures.append(textures[2])
        textures.append(textures[1])
        // 4
        zombieAnimation = SKAction.animate(with: textures,
                                           timePerFrame: 0.1)
        
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
        
        run(SKAction.repeatForever(
            SKAction.sequence([SKAction.run() { [weak self] in
                self?.spawnEnemy()
                }, SKAction.wait(forDuration: 2.0)])))
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run { [weak self] in
            self?.spawnCat()
            }, SKAction.wait(forDuration: 1)])))
    }
    
    func startZombieAnimation() {
        if zombie1.action(forKey: "animation") == nil {
            zombie1.run(SKAction.repeatForever(zombieAnimation), withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        zombie1.removeAction(forKey: "animation")
    }
    
    func spawnCat() {
        // 1
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(min: playableRect.minX,
                              max: playableRect.maxX),
            y: CGFloat.random(min: playableRect.minY,
                              max: playableRect.maxY))
        cat.setScale(0)
        addChild(cat)
        // 2
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
//        let wait = SKAction.wait(forDuration: 10.0)
        
        cat.zRotation = CGFloat(-Double.pi / 16.0)
        let leftWiggle = SKAction.rotate(byAngle: CGFloat(Double.pi/8.0), duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDown = scaleUp.reversed()
        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullScale, fullWiggle])
        let groupWait = SKAction.repeat(group, count: 10)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.run(SKAction.sequence(actions))
    }
    
    func spawnEnemy() {
        
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(
            x: size.width + enemy.size.width/2,
            y: CGFloat.random(
                min: playableRect.minY + enemy.size.height/2,
                max: playableRect.maxY - enemy.size.height/2))
        addChild(enemy)
        let actionMove =
            SKAction.moveTo(x: -enemy.size.width/2, duration: 2.0)
        enemy.run(actionMove)
    }
    
    func zombieHit(cat: SKSpriteNode) {
        cat.removeFromParent()
    }
    
    func zombieHit(enemy: SKSpriteNode) {
        enemy.removeFromParent()
    }
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodes(withName: "cat") { node, _ in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(self.zombie1.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHit(cat: cat)
        }
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") { node, _ in
            let enemy = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 20).intersects(
                self.zombie1.frame) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            zombieHit(enemy: enemy)
        }
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
        checkCollisions()
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
        //        print("Amount to move: \(amountToMove)")
    }
    
    func moveZombieToward(location: CGPoint) {
        
        if zombie1.contains(location) {
            velocity = CGPoint.zero
            stopZombieAnimation()
            return
        }
        
        let offset = location - zombie1.position
        let length = offset.length()
        let direction = offset / CGFloat(length)
        velocity = direction * zombieMovePointsPerSec
        startZombieAnimation()
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
