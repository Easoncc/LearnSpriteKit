//
//  gameScene.swift
//  mygame
//
//  Created by chenchao on 2019/1/10.
//  Copyright © 2019 chenchao. All rights reserved.
//

import UIKit
import SpriteKit

class gameScene: SKScene {
    
    let scale: CGFloat = 3
    var player: SKSpriteNode!
    var currTime: TimeInterval = 0
    
    var monsters: [SKSpriteNode] = []
    var projectiles: [SKSpriteNode] = []
    
    override init(size: CGSize) {
        super.init(size: size)
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        let backGround = SKSpriteNode(imageNamed: "background1")
        backGround.position = CGPoint(x: size.width/2, y: size.height/2)
        backGround.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        backGround.zPosition = -1
        addChild(backGround)
        
        player = SKSpriteNode(imageNamed: "player")
        player.size = CGSize(width: player.size.width*scale, height: player.size.height*scale)
        player.position = CGPoint(x: player.size.width/2+30, y: size.height/2)
        player.zPosition = 1
        addChild(player)
        
        let addMonster = SKAction.run {
            self.addMonster()
        }
        let waitMonster = SKAction.wait(forDuration: 1)
        
        self.run(SKAction.repeatForever(SKAction.sequence([waitMonster, addMonster])))
    }
    
    func addMonster() {
        
        let monster = SKSpriteNode(imageNamed: "monster")
        monster.size = CGSize(width: monster.size.width*scale, height: monster.size.height*scale)
        monster.zPosition = 1
        
        let minY = monster.size.height/2
        let maxY = size.height - monster.size.height/2
        let rangeY = maxY-minY
        
        let y = arc4random()%UInt32(rangeY) + UInt32(minY)
        monster.position = CGPoint(x: size.width+monster.size.width/2, y: CGFloat(y))
        
        let texture = SKTexture(imageNamed: "monster")
        monster.physicsBody = SKPhysicsBody(texture: texture, size: CGSize(width: texture.size().width*scale, height: texture.size().height*scale))
        monster.physicsBody?.affectedByGravity = false
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = 1
        monster.physicsBody?.contactTestBitMask = 2
        
        monsters.append(monster)
        addChild(monster)
        
        let minDuration = 3
        let maxDuration = 6
        let duration = arc4random()%UInt32(maxDuration-minDuration) + UInt32(minDuration)
        
        let action = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: CGFloat(y)), duration: TimeInterval(duration))
        let actionDone = SKAction.run {
            self.monsters.removeAll(where: { $0 == monster })
            monster.removeFromParent()
        }
        
        monster.run(SKAction.sequence([action, actionDone]))
    }
    
    func addprojectile(touch: UITouch) {
        
        if (touch.timestamp - currTime) < 0.2 {
            return
        }
        
        currTime = touch.timestamp
        
        let winSize = self.size
        let position = player.position
        let location = touch.location(in: self)
        let offset = CGPoint(x: location.x - position.x, y: location.y - position.y)
        
        if offset.x == 0 { return }
        
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.size = CGSize(width: projectile.size.width*scale, height: projectile.size.height*scale)
        projectile.position = player.position
        
        let texture = SKTexture(imageNamed: "projectile")
        projectile.physicsBody = SKPhysicsBody(texture: texture, size: CGSize(width: texture.size().width*scale, height: texture.size().height*scale))
        projectile.physicsBody?.affectedByGravity = false
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = 2
        projectile.physicsBody?.contactTestBitMask = 1
        
        projectiles.append(projectile)
        addChild(projectile)
        
        let realX = winSize.width + (projectile.size.width/2)
        let ratio = offset.y / offset.x
        let realY = (realX * ratio) + projectile.position.y
        let realDest = CGPoint(x: realX, y: realY)
        
        //3 Determine the length of how far you're shooting
        let offRealX = realX - projectile.position.x
        let offRealY = realY - projectile.position.y
        let length: CGFloat = CGFloat(sqrtf(Float((offRealX*offRealX)+(offRealY*offRealY))))
        let velocity = self.size.width/1 // projectile speed.
        let realMoveDuration = length/velocity
        
        //4 Move projectile to actual endpoint
        projectile.run(SKAction.move(to: realDest, duration: TimeInterval(realMoveDuration)), completion: {
            self.projectiles.removeAll(where: { $0 == projectile })
            projectile.removeFromParent()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        touches.forEach { (touch) in
            addprojectile(touch: touch)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { (touch) in
            addprojectile(touch: touch)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        print(currentTime)
    }
}

extension gameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        contact.bodyA.node?.removeFromParent()
        contact.bodyB.node?.removeFromParent()
        
    }
}
